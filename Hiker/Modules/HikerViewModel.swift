import SwiftUI

// MARK: - Error Handling

/// An enumeration that defines possible errors related to hiking tracking.
///
/// `HikerError` specifies errors such as location permission issues, ensuring that the application can respond
/// appropriately when these errors occur.
enum HikerError: Error {
    case locationPermissionError
}


// MARK: - ViewModel

/// A view model responsible for managing the state and operations of the hiking image stream.
///
/// `HikerViewModel` handles the process of tracking the user's location, fetching images based on that location,
/// and updating the view state accordingly. It communicates with `LocationService` to obtain location data
/// and `PhotoSearchService` to fetch relevant images.
class HikerViewModel: ObservableObject, ViewModelStateHandling {
    
    /// The type of data managed by this view model, specifically an array of `WalkTrackingImageViewModel` instances.
    typealias T = [HikeImageStreamViewModel]
    
    /// The current state of the view model, managing the state of the view.
    @Published var state: ViewModelState<T>
    
    /// A boolean indicating whether location tracking is currently active.
    @Published var isTracking: Bool = false
    
    /// The service responsible for managing location-related operations.
    private var locationService: LocationService
    
    /// The service responsible for searching and fetching photos based on the user's location.
    private var photoSearchService: PhotoSearchService
    
    /// Initializes a new instance of `HikerViewModel`.
    ///
    /// - Parameters:
    ///   - locationService: The service responsible for handling location-related operations.
    ///   - photoSearchService: The service responsible for searching and fetching photos.
    init(locationService: LocationService, photoSearchService: PhotoSearchService) {
        self.locationService = locationService
        self.photoSearchService = photoSearchService
        self.state = .initial
    }
    
    /// Fetches the latest data for the view, updating the state based on the current tracking data.
    ///
    /// This method retrieves the user's location data, checks the location permissions, and then uses the photo search service
    /// to fetch images associated with the location. The view model's state is updated accordingly.
    func fetch() async {
        Task {
            // Check if the state should remain unchanged based on existing data
            if case .data(let existingViewModels) = state, await existingViewModels.count == self.locationService.items.count {
                return
            }
            
            await update(newState: .loading)
            
            // Handle location permission errors
            if locationService.status != .authorizedAlways && locationService.status != .notDetermined {
                await update(newState: .error(HikerError.locationPermissionError))
                await updateTracking(isTracking: false)
                
                locationService.stopTracking()
                stopLocationListening()
                
                return
            }
            
            // Update state to empty if there's no tracking data
            if await !locationService.hasTrackingData {
                await update(newState: .empty)
                return
            }
            
            
            // Map the location data to image view models
            let imagesViewModels = await self.locationService.items.map { item in
                HikeImageStreamViewModel(locationItem: item, photoSearchService: photoSearchService)
            }
            
            await update(newState: .data(imagesViewModels))
        }
    }
    
    /// Starts the hiking tracking process and begins listening for location updates.
    ///
    /// This method ensures that location tracking is activated and that the app listens for changes in the user's location.
    func startHikeTracking() {
        Task {
            await updateTracking(isTracking: true)
        }
        
        locationService.startTracking()
        startLocationListening()
        
        // Handle location permission errors
        if locationService.status != .authorizedAlways && locationService.status != .notDetermined {
            isTracking = false
            locationService.stopTracking()
            
            Task {
                await update(newState: .error(HikerError.locationPermissionError))
            }
        }
    }
    
    /// Stops the hiking tracking process and stops listening for location updates.
    ///
    /// This method halts the location tracking and removes any listeners for location changes.
    func stopHikeTracking() {
        Task {
            await updateTracking(isTracking: false)
        }
        
        locationService.stopTracking()
        stopLocationListening()
    }
    
    /// Updates the tracking status of the location service.
    ///
    /// This method is an asynchronous function that ensures the `isTracking` property is updated
    /// on the main thread. The use of `MainActor.run` ensures that the UI-related state change
    /// occurs on the main thread, which is crucial for maintaining UI consistency.
    ///
    /// - Parameter isTracking: A Boolean value that indicates whether tracking is active (`true`) or inactive (`false`).
    /// - Returns: An asynchronous task that completes when the tracking status has been updated.
    func updateTracking(isTracking: Bool) async {
        await MainActor.run { [weak self] in
            self?.isTracking = isTracking
        }
    }
    
    
    // MARK: - Location Listening
    
    /// Starts listening to location changes and updates the data accordingly.
    ///
    /// This method sets a callback function that triggers data fetching whenever the user's location is updated.
    func startLocationListening() {
        locationService.updatedLocation = {
            await self.fetch()
        }
    }
    
    /// Stops listening to location changes.
    ///
    /// This method removes the callback function, stopping the app from responding to location updates.
    func stopLocationListening() {
        locationService.updatedLocation = nil
    }
    
    /// Clears all tracked data and resets the state.
    ///
    /// This method stops location tracking, clears the stored location data, and refreshes the view model's state.
    func clear() async {
        Task {
            await updateTracking(isTracking: false)
        }
        
        locationService.stopTracking()
        
        try? await locationService.clear()
        await fetch()
    }
}
