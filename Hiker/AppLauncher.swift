import SwiftUI
import SwiftData

/// The entry point of the application that determines which app variant to launch.
///
/// The `AppLauncher` struct is marked with the `@main` attribute, making it the main entry point for the SwiftUI application.
/// Depending on the environment, it launches either the `HikerApp` for production or `TestApp` for testing.
///
/// - Note: The selection between `HikerApp` and `TestApp` is determined by the presence of the `XCTestCase` class,
///         which indicates whether the application is running in a test environment.
@main
struct AppLauncher {
    
    /// The main entry point function for the application.
    ///
    /// This static `main()` method is responsible for determining whether the application is running in a production
    /// or test environment and then launching the appropriate application variant. The function first checks if the
    /// application is running in production by invoking the `isRunningInProduction()` method. If it is, it launches
    /// `HikerApp`; otherwise, it launches `TestApp`.
    ///
    /// - Throws: Any error that may occur during the execution of the main application logic.
    static func main() throws {
        if isRunningInProduction() {
            HikerApp.main()
        } else {
            TestApp.main()
        }
    }
    
    /// Determines whether the application is running in a production environment.
    ///
    /// This function checks if the `XCTestCase` class is present in the current runtime environment.
    /// If `XCTestCase` is `nil`, it indicates that the application is not running in a test environment
    /// and is therefore running in a production or development mode.
    ///
    /// - Returns: A Boolean value indicating whether the application is running in a production environment (`true`)
    ///            or in a test environment (`false`).
    static func isRunningInProduction() -> Bool {
        return NSClassFromString("XCTestCase") == nil
    }
}

/// The main application structure for production or development environments.
///
/// `HikerApp` is a SwiftUI application that represents the production version of the application.
/// It defines the `body` property that describes the content and behavior of the app's user interface.
///
/// - Note: This struct is only instantiated when the application is running in a production or development environment.
struct HikerApp: App {
    var body: some Scene {
        WindowGroup {
            HikerView(viewModel: HikerViewModel(locationService: AppDependency.shared.locationService,
                                                photoSearchService: AppDependency.shared.photoSearchService))
        }
    }
}

/// The main application structure for testing environments.
///
/// `TestApp` is a SwiftUI application that represents the testing version of the application.
/// It defines the `body` property that describes the content and behavior of the app's user interface.
///
/// - Note: This struct is only instantiated when the application is running in a test environment.
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            
        }
    }
}
