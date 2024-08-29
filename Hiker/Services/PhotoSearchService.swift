import Foundation
import OSLog

// MARK: - PhotoSearchService

/// Configuration structure to hold API key and host details.
protocol APIConfig {
    /// The API key used for authentication with the API service.
    var apiKey: String { get }
    
    /// The base URL or host of the API service.
    var host: String { get }
}

/// Protocol defining a photo search service.
protocol PhotoSearchService {
    
    /// Fetches an image from the service based on latitude and longitude coordinates.
    ///
    /// This method performs an asynchronous network operation to search for an image at the given coordinates.
    /// It will first check if the image is available in the cache. If not, it will request the image from the network,
    /// cache it, and return the image data.
    ///
    /// - Parameters:
    ///   - latitude: The latitude coordinate for the image search.
    ///   - longitude: The longitude coordinate for the image search.
    /// - Returns: The image data as `Data?` if available, otherwise `nil`.
    /// - Throws: An error if the image could not be fetched due to network issues, decoding errors, or other unexpected conditions.
    func fetchImage(latitude: Double, longitude: Double) async throws -> Data?
}


// MARK: - PhotoSearchService Implementation

/// Model representing a photo from Flickr.
struct FlickrPhoto: Codable {
    /// The URL of the large size photo.
    let url_l: String?
}

/// Model representing the response from Flickr's photo search API.
struct FlickrSearchResponse: Codable {
    /// The photos section of the response containing an array of `FlickrPhoto`.
    let photos: FlickrPhotos
}

/// Model representing the photos section of the Flickr search response.
struct FlickrPhotos: Codable {
    /// An array of photos returned by the Flickr API.
    let photo: [FlickrPhoto]
}

/// Service class to interact with the Flickr API for searching and fetching photos.
class FlickrService: PhotoSearchService {
    
    /// The API configuration containing the key and host details.
    private let config: APIConfig
    
    /// Logger instance for the FlickrService.
    private let logger = Logger(subsystem: "net.messeb.ios.Hiker", category: "PhotoSearchService")
    
    /// Shared URL cache for caching responses.
    private let cache = URLCache.shared
    
    /// The latest URL request made to Flickr API.
    private var flickrRequest: URLRequest?
    
    /// Initializes the FlickrService with a given API configuration.
    /// - Parameter config: The API configuration containing the API key and host.
    init(config: APIConfig) {
        self.config = config
    }
    
    /// Fetches an image from Flickr based on latitude and longitude, using cache if available.
    /// - Parameters:
    ///   - latitude: The latitude coordinate for the search.
    ///   - longitude: The longitude coordinate for the search.
    /// - Returns: The image data if available, otherwise `nil`.
    func fetchImage(latitude: Double, longitude: Double) async throws -> Data? {
        logger.info("Fetching image for coordinates: latitude=\(latitude), longitude=\(longitude)")
        
        // Check if the image is already cached
        if let cachedImageData = try cachedData(latitude: latitude, longitude: longitude) {
            logger.info("Returning cached image data for coordinates: latitude=\(latitude), longitude=\(longitude)")
            return cachedImageData
        }
        
        // Search for the photo using the provided coordinates
        guard let photo = try await searchPhoto(latitude: latitude, longitude: longitude),
              let urlString = photo.url_l,
              let url = URL(string: urlString) else {
            logger.warning("No photo found for coordinates: latitude=\(latitude), longitude=\(longitude)")
            return nil
        }
        
        // Create a request to fetch the image data
        let request = URLRequest(url: url)
        logger.debug("Fetching image from URL: \(urlString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Cache the image data if the response is successful
        storeCacheData(latitude: latitude, longitude: longitude, response: response, data: data)
        logger.info("Image data fetched and cached for coordinates: latitude=\(latitude), longitude=\(longitude)")
        
        return data
    }
    
    /// Searches for a photo on Flickr based on latitude and longitude.
    /// - Parameters:
    ///   - latitude: The latitude coordinate for the search.
    ///   - longitude: The longitude coordinate for the search.
    /// - Returns: An optional `FlickrPhoto` object if a photo is found.
    private func searchPhoto(latitude: Double, longitude: Double) async throws -> FlickrPhoto? {
        let request = try flickrURLRequest(latitude: latitude, longitude: longitude)
        
        logger.debug("Searching for photo with request: \(request.url?.absoluteString ?? "invalid URL")")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedResponse = try JSONDecoder().decode(FlickrSearchResponse.self, from: data)
        flickrRequest = request
        logger.debug("Photo search successful for coordinates: latitude=\(latitude), longitude=\(longitude)")
        
        return decodedResponse.photos.photo.first
    }
    
    /// Creates a URL request for the Flickr API based on latitude and longitude.
    /// - Parameters:
    ///   - latitude: The latitude coordinate for the search.
    ///   - longitude: The longitude coordinate for the search.
    /// - Returns: A configured `URLRequest` for the Flickr API.
    /// - Throws: An error if the URL is invalid.
    private func flickrURLRequest(latitude: Double, longitude: Double) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: config.host) else {
            logger.error("Failed to create URL components from host: \(self.config.host)")
            throw URLError(.badURL)
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: config.apiKey),
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "lon", value: "\(longitude)"),
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "extras", value: "url_l")
        ]
        
        guard let url = urlComponents.url else {
            logger.error("Failed to create URL from components: \(urlComponents)")
            throw URLError(.badURL)
        }
        
        return URLRequest(url: url)
    }
    
    /// Retrieves cached data if available for the specified latitude and longitude.
    /// - Parameters:
    ///   - latitude: The latitude coordinate for the search.
    ///   - longitude: The longitude coordinate for the search.
    /// - Returns: The cached data if available, otherwise `nil`.
    /// - Throws: An error if the request could not be created.
    private func cachedData(latitude: Double, longitude: Double) throws -> Data? {
        let request = try flickrURLRequest(latitude: latitude, longitude: longitude)
        
        if let cachedResponse = cache.cachedResponse(for: request) {
            logger.debug("Cache hit for coordinates: latitude=\(latitude), longitude=\(longitude)")
            return cachedResponse.data
        }
        
        logger.debug("Cache miss for coordinates: latitude=\(latitude), longitude=\(longitude)")
        return nil
    }
    
    /// Stores the image data in the cache.
    /// - Parameters:
    ///   - latitude: The latitude coordinate for the search.
    ///   - longitude: The longitude coordinate for the search.
    ///   - response: The URL response received from the network request.
    ///   - data: The image data to be cached.
    private func storeCacheData(latitude: Double, longitude: Double, response: URLResponse, data: Data) {
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            let cachedResponse = CachedURLResponse(response: httpResponse, data: data)
            if let flickrRequest = flickrRequest {
                cache.storeCachedResponse(cachedResponse, for: flickrRequest)
                logger.debug("Cached image data for coordinates: latitude=\(latitude), longitude=\(longitude)")
            }
        } else {
            logger.warning("Failed to cache image data due to invalid response or status code")
        }
    }
}
