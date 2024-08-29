import SwiftUI
import SwiftData
import CoreLocation

// MARK: - View

/// The main content view of the application.
///
/// `HikerView` is a SwiftUI view that represents the main user interface of the hiking tracking application.
/// It manages the display of hike tracking data, user interactions, and app state changes.
struct HikerView: View {
    
    /// The view model that manages the business logic and data for this view.
    @StateObject var viewModel: HikerViewModel
    
    /// The current phase of the app's scene.
    @Environment(\.scenePhase) var scenePhase
    
    /// The body of the view.
    var body: some View {
        NavigationView {
            VStack {
                contentView() // Displays the main content based on the current state
            }
            .navigationBarItems(leading: clearButton(), trailing: startStopButton())
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
    }
    
    /// Builds the main content view based on the current state of the view model.
    ///
    /// - Returns: A view representing the current state of the hike tracking data.
    @ViewBuilder
    private func contentView() -> some View {
        switch viewModel.state {
        case .initial, .loading:
            ProgressView("loading") // Shows a loading indicator
        case .empty:
            EmptyHikesView() // Shows an empty state view when no data is available
        case .data(let viewModels):
            ScrollView {
                LazyVStack {
                    ForEach(viewModels, id: \.id) { viewModel in
                        HikeImageStreamView(viewModel: viewModel) // Displays each hike tracking image
                    }
                }
                .id(viewModels.count)
                .padding()
            }
        case .error:
            PermissionErrorView() // Shows an error view when permissions are not granted
        }
    }
    
    /// Builds the start/stop button for hike tracking.
    ///
    /// - Returns: A button view that toggles hike tracking on and off.
    @ViewBuilder
    private func startStopButton() -> some View {
        if !viewModel.isTracking {
            Button(action: {
                viewModel.startHikeTracking() // Starts tracking the hike
            }) {
                Text("hikeTracker.start")
            }
            .disabled(!canEnableButton())
        } else {
            Button(action: {
                viewModel.stopHikeTracking() // Stops tracking the hike
            }) {
                Text("hikeTracker.stop")
            }
        }
    }
    
    /// Builds the clear button for removing all tracked data.
    ///
    /// - Returns: A button view that clears all tracked hike data.
    private func clearButton() -> some View {
        Button(action: {
            Task {
                await viewModel.clear() // Clears all tracked hike data
            }
        }) {
            Text("hikeTracker.clear")
        }
        .disabled(!canEnableButton())
    }
    
    /// Determines whether the start and clear buttons should be enabled.
    ///
    /// - Returns: A boolean indicating if the buttons should be enabled.
    private func canEnableButton() -> Bool {
        switch viewModel.state {
        case .data, .empty, .error(_):
            return true
        default:
            return false
        }
    }
    
    /// Handles changes in the scene phase, such as the app moving to the foreground or background.
    ///
    /// - Parameters:
    ///   - oldPhase: The previous scene phase.
    ///   - newPhase: The new scene phase.
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        if newPhase == .active {
            Task {
                await viewModel.fetch()
            }
            if viewModel.isTracking {
                viewModel.startLocationListening()
            }
        } else {
            if viewModel.isTracking {
                viewModel.stopLocationListening()
            }
        }
    }
}
