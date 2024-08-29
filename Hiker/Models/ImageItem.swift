import Foundation
import CoreLocation

/// Represents an image item with associated location data.
struct ImageItem: Identifiable {
    /// A unique identifier for the image item.
    let id = UUID()
    
    /// The URL of the image.
    let url: URL
    
    /// The geographical location where the image was taken or associated with.
    let location: CLLocation
}
