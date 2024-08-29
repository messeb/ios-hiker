import Foundation
import CoreLocation

// MARK: - AppDependency

/// A structure that encapsulates the dependencies required for the application.
///
/// `AppDependency` serves as a central point for managing and providing instances of services used throughout the app,
/// such as location tracking and photo search services. This approach simplifies dependency management and ensures
/// that the same instances are shared across different parts of the application.
struct AppDependency {
    
    /// The store responsible for managing and persisting location data.
    let locationStore: LocationStore
    
    /// The service responsible for tracking and managing location updates.
    let locationService: LocationService
    
    /// The service responsible for searching and fetching photos based on location.
    let photoSearchService: PhotoSearchService
    
    /// A shared singleton instance of `AppDependency`, providing easy access to dependencies throughout the app.
    static let shared = AppDependency()
    
    /// A configuration structure that provides the API key and host details for the Flickr API.
    ///
    /// This structure conforms to the `APIConfig` protocol and supplies the necessary credentials and endpoint
    /// information required for interacting with the Flickr API.
    struct FlickerAPIConfig: APIConfig {
        /// The API key used for authentication with the Flickr API.
        /// It's an API key grabbed for GitHub - so not my fault to put it in code. ;) 
        var apiKey: String = "f7e7fb8cc34e52db3e5af5e1727d0c0b"
        
        /// The base URL or host of the Flickr API service.
        var host: String = "https://api.flickr.com/services/rest/"
    }
    
    /// A configuration structure that provides settings for the location tracking service.
    ///
    /// This structure conforms to the `HikerLocationServiceConfig` protocol and supplies the necessary settings
    /// such as distance filter, accuracy, and background update capabilities for the location service.
    struct LocationConfguration: HikerLocationServiceConfig {
        /// The minimum distance (in meters) a device must move horizontally before an update event is generated.
        var distanceFilter: CLLocationDistance = 100
        
        /// The desired accuracy of the location data.
        var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
        
        /// A Boolean value indicating whether the location manager can continue to deliver location updates in the background.
        var allowsBackgroundLocationUpdates: Bool = true
        
        /// A Boolean value indicating whether the location manager pauses location updates automatically.
        var pausesLocationUpdatesAutomatically: Bool = true
    }
    
    /// Initializes a new instance of `AppDependency`, setting up all necessary services and configurations.
    ///
    /// This initializer creates instances of the location store, location service, and photo search service using
    /// the provided configurations. These instances are then shared throughout the application via the `shared` singleton.
    init() {
        locationStore = HikerLocationStore()
        locationService = HikerLocationService(config: AppDependency.LocationConfguration(), locationStore: locationStore)
        photoSearchService = FlickrService(config: AppDependency.FlickerAPIConfig())
    }
}
