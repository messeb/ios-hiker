import Foundation
import CoreLocation
import OSLog

// MARK: - LocationService

/// Protocol defining the methods and properties for a location service.
protocol LocationService {
    
    /// Indicates whether the service has tracking data available.
    var hasTrackingData: Bool { get async }
    
    /// The list of tracked location items.
    var items: [LocationItem] { get async }
    
    /// The current authorization status of the location service.
    var status: CLAuthorizationStatus { get }
    
    /// A closure that is called when the location is updated.
    var updatedLocation: (() async -> Void)? { get set }
    
    /// A closure that is called the the permission is updated.
    var updatedStatus: ((CLAuthorizationStatus) async -> Void)? { get set }
    
    /// Clears the stored location data.
    func clear() async throws
    
    /// Starts tracking the location.
    func startTracking()
    
    /// Stops tracking the location.
    func stopTracking()
}


// MARK: - HikerLocationServiceConfig

/// Protocol defining the configuration for the HikerLocationService.
protocol HikerLocationServiceConfig {
    
    /// The minimum distance (in meters) a device must move horizontally before an update event is generated.
    var distanceFilter: CLLocationDistance { get }
    
    /// The desired accuracy of the location data.
    var desiredAccuracy: CLLocationAccuracy { get }
    
    /// A Boolean value indicating whether the location manager can continue to deliver location updates in the background.
    var allowsBackgroundLocationUpdates: Bool { get }
    
    /// A Boolean value indicating whether the location manager pauses location updates automatically.
    var pausesLocationUpdatesAutomatically: Bool { get }
}


// MARK: - HikerLocationService

/// A service that tracks location updates for every 100 meters, even in the background.
class HikerLocationService: NSObject, ObservableObject, CLLocationManagerDelegate, LocationService {
    
    
    /// A closure that is called when the location is updated.
    var updatedLocation: (() async -> Void)?
    
    /// A closure that is called the the permission is updated.
    var updatedStatus: ((CLAuthorizationStatus) async -> Void)?
    
    /// Indicates whether the service has tracking data available.
    var hasTrackingData: Bool {
        get async {
            guard let locations = try? await locationStore.fetchAllLocations() else {
                return false
            }
            return !locations.isEmpty
        }
    }
    
    /// The current authorization status of the location service.
    var status: CLAuthorizationStatus = .notDetermined
    
    /// The list of tracked location items.
    var items: [LocationItem] {
        get async {
            guard let locations = try? await locationStore.fetchAllLocations() else {
                return []
            }
            return locations
        }
    }
    
    /// The location manager that handles location updates.
    private let locationManager: CLLocationManager
    
    /// The store where location data is saved.
    private let locationStore: LocationStore
    
    /// The configuration for the location service.
    private let config: HikerLocationServiceConfig
    
    /// The last known location.
    private var lastLocation: CLLocation?
    
    /// Logger instance for the HikerLocationService.
    private let logger = Logger(subsystem: "net.messeb.ios.Hiker", category: "LocationService")
    
    /// Initializes the HikerLocationService with a given configuration and location store.
    /// - Parameters:
    ///   - config: The configuration for the location service.
    ///   - locationStore: The store where location data is saved.
    init(config: HikerLocationServiceConfig, locationStore: LocationStore) {
        self.config = config
        self.locationStore = locationStore
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = config.desiredAccuracy
        locationManager.distanceFilter = config.distanceFilter
        locationManager.allowsBackgroundLocationUpdates = config.allowsBackgroundLocationUpdates
        locationManager.pausesLocationUpdatesAutomatically = config.pausesLocationUpdatesAutomatically
        
        logger.info("HikerLocationService initialized with desired accuracy: \(config.desiredAccuracy) and distance filter: \(config.distanceFilter)")
    }
    
    /// Starts tracking the location.
    func startTracking(){
        requestPermissions()
        locationManager.startUpdatingLocation()
        logger.info("Location tracking started.")
    }
    
    /// Stops tracking the location.
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        logger.info("Location tracking stopped.")
    }
    
    /// Clears the stored location data.
    func clear() async throws {
        try await locationStore.deleteAll()
        logger.info("All location data cleared.")
    }
    
    /// Requests the necessary location permissions.
    private func requestPermissions() {
        locationManager.requestAlwaysAuthorization()
        logger.info("Requested location permissions.")
    }
    
    /// Starts location updates.
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        logger.info("Started updating location.")
    }
    
    /// Delegate method called when the location manager updates locations.
    /// - Parameters:
    ///   - manager: The location manager object that generated the update event.
    ///   - locations: An array of `CLLocation` objects representing the new locations.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            logger.warning("Received empty locations array from location manager.")
            return
        }
        
        // Ensure that the update is at least 100 meters away from the last update
        if let lastLocation = lastLocation {
            let distance = location.distance(from: lastLocation)
            if distance < config.distanceFilter {
                logger.debug("Location update ignored because the distance (\(distance) meters) is less than the filter threshold (\(self.config.distanceFilter) meters).")
                return
            }
        }
        
        logger.info("New location update received: \(location)")
        
        // Update the last location
        lastLocation = location
        
        // Save the new location to SwiftData and propagate location
        Task {
            do {
                try await self.locationStore.save(location)
                logger.debug("Location saved successfully.")
                await updatedLocation?()
            } catch {
                logger.error("Failed to save location: \(error.localizedDescription)")
            }
        }
    }
    
    /// Delegate method called when the location manager fails with an error.
    /// - Parameters:
    ///   - manager: The location manager object that generated the error.
    ///   - error: The error object containing the error details.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error("Location update failed with error: \(error.localizedDescription)")
    }
    
    /// Delegate method called when the authorization status changes.
    /// - Parameters:
    ///   - manager: The location manager object reporting the change.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
        
        Task {
            await updatedStatus?(manager.authorizationStatus)
        }
        
        switch status {
        case .authorizedAlways, .notDetermined:
            logger.info("Tracking will continue.")
            break
        default:
            logger.warning("Tracking will stop.")
            stopTracking()
        }
    }
}
