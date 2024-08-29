import Foundation
import SwiftUI

// MARK: - ViewModel

/// A view model responsible for managing the state and operations of an individual hiking image stream.
///
/// `HikeImageStreamViewModel` handles fetching images based on the user's location and updating the view's state
/// accordingly. It interacts with the `PhotoSearchService` to retrieve images and uses the `LocationItem` to
/// determine which location to fetch images for.
class HikeImageStreamViewModel: ObservableObject, ViewModelStateHandling, Identifiable {
    
    /// The type of data managed by this view model, specifically an optional `UIImage`.
    typealias T = UIImage?
    
    /// The current state of the view model, managing the state of the view.
    @Published var state: ViewModelState<T>
    
    /// The location item associated with this view model.
    private var locationItem: LocationItem
    
    /// The service responsible for searching and fetching photos based on the user's location.
    private var photoSearchService: PhotoSearchService
    
    /// A unique identifier for the view model, used for SwiftUI's `ForEach` and other identification purposes.
    let id: UUID
    
    /// Initializes a new instance of `HikeImageStreamViewModel`.
    ///
    /// - Parameters:
    ///   - locationItem: The `LocationItem` representing the location for which images are fetched.
    ///   - photoSearchService: The service responsible for searching and fetching photos.
    init(locationItem: LocationItem, photoSearchService: PhotoSearchService) {
        self.id = locationItem.id
        self.locationItem = locationItem
        self.photoSearchService = photoSearchService
        self.state = .initial
    }
    
    /// Fetches an image for the specified location and updates the state accordingly.
    ///
    /// This method interacts with the `PhotoSearchService` to retrieve an image based on the latitude and longitude
    /// of the associated `LocationItem`. The state is updated to reflect loading, success, or failure.
    func fetchImage() async {
        await update(newState: .loading)
        
        guard let imageData = try? await photoSearchService.fetchImage(latitude: locationItem.latitude, longitude: locationItem.longitude) else {
            await update(newState: .error(nil))
            return
        }
        
        await update(newState: .data(UIImage(data: imageData)))
    }
}
