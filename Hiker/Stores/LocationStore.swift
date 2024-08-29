import Foundation
import SwiftUI
import CoreLocation
import SwiftData
import OSLog

// MARK: - LocationStore

/// A protocol defining the required functionality for a location storage system.
/// This protocol defines the methods for saving, fetching, and deleting location data.
protocol LocationStore {

    /// Saves a location to the storage.
    ///
    /// - Parameter location: The `CLLocation` object representing the location to be saved.
    /// - Throws: An error if the location could not be saved.
    func save(_ location: CLLocation) async throws

    /// Fetches all stored locations.
    ///
    /// - Returns: An array of `LocationItem` objects representing the stored locations.
    /// - Throws: An error if the locations could not be fetched.
    func fetchAllLocations() async throws -> [LocationItem]

    /// Deletes all stored locations.
    ///
    /// - Throws: An error if the locations could not be deleted.
    func deleteAll() async throws
}


// MARK: - HikerLocationStore

/// An actor class responsible for managing the storage of location data.
/// This class conforms to the `LocationStore` protocol and provides an implementation for saving, fetching,
/// and deleting location data using SwiftData.
actor HikerLocationStore: LocationStore {
    private let modelContainer: ModelContainer?

    /// Initializes a new instance of `HikerLocationStore`.
    /// Attempts to create a `ModelContainer` for storing `LocationItem` objects.
    init() {
        do {
            self.modelContainer = try ModelContainer(for: LocationItem.self)
        } catch {
            self.modelContainer = nil
            print("Failed to create ModelContainer: \(error)")
        }
    }

    /// Saves a location to the storage.
    ///
    /// - Parameter location: The `CLLocation` object representing the location to be saved.
    /// - Throws: An error if the location could not be saved.
    func save(_ location: CLLocation) async throws {
        guard let modelContainer = modelContainer else {
            throw NSError(domain: "HikerLocationStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
        }

        let context = ModelContext(modelContainer)
        let locationItem = LocationItem(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: Date())

        context.insert(locationItem)
        try context.save()
    }

    /// Fetches all stored locations.
    ///
    /// - Returns: An array of `LocationItem` objects representing the stored locations.
    /// - Throws: An error if the locations could not be fetched.
    func fetchAllLocations() async throws -> [LocationItem] {
        guard let modelContainer = modelContainer else {
            throw NSError(domain: "HikerLocationStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
        }

        let context = ModelContext(modelContainer)
        let fetchRequest = FetchDescriptor<LocationItem>(
            sortBy: [SortDescriptor<LocationItem>(\LocationItem.timestamp, order: .reverse)]
        )

        return try context.fetch(fetchRequest)
    }

    /// Deletes all stored locations.
    ///
    /// - Throws: An error if the locations could not be deleted.
    func deleteAll() async throws {
        guard let modelContainer = modelContainer else {
            throw NSError(domain: "HikerLocationStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
        }

        let context = ModelContext(modelContainer)
        try context.delete(model: LocationItem.self)
    }
}
