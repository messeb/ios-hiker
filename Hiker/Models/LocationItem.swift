import SwiftData
import CoreLocation

@Model
final class LocationItem {
    /// The unique identifier for the location entity.
    @Attribute(.unique) var id: UUID
    
    /// The latitude of the location.
    @Attribute var latitude: Double
    
    /// The longitude of the location.
    @Attribute var longitude: Double
    
    /// The timestamp when the location was recorded.
    @Attribute var timestamp: Date

    /// Initializes a new `LocationItem` with the specified latitude, longitude, and timestamp.
    /// - Parameters:
    ///   - latitude: The latitude of the location.
    ///   - longitude: The longitude of the location.
    ///   - timestamp: The time at which the location was recorded.
    init(latitude: Double, longitude: Double, timestamp: Date = Date()) {
        self.id = UUID() // Automatically generate a unique identifier
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
}
