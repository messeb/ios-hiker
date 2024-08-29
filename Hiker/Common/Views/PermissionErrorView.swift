import SwiftUI

// MARK: - View

/// A SwiftUI view that informs the user of a location permission error and provides an option to open the app settings.
///
/// The view displays an icon indicating a location error, a title, a description of the error, and an action button to guide the user.
struct PermissionErrorView: View {
    
    // UI constants in the view
    struct Constants {
        // Spacing between each element
        static let elementSpacing = 20.0
        
        // Size of the image
        static let imageSize = 60.0
        
        // Corner radius of the button
        static let buttonCornerRadius = 10.0
    }
    
    /// The content and behavior of the view.
    var body: some View {
        VStack(spacing: Constants.elementSpacing) {
            // Icon indicating that location permissions are disabled or not granted
            Image(systemName: "location.slash.fill")
                .font(.system(size: Constants.imageSize))
                .foregroundColor(.red)
            
            // Title text to highlight the permission error
            Text("permissionError.title")
                .font(.title2)
                .fontWeight(.bold)
            
            // Description text explaining the nature of the permission error
            Text("permissionError.description")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Instructional text guiding the user to take action
            Text("permissionError.action.text")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Button that allows the user to open the app settings to enable permissions
            Button(action: openAppSettings) {
                Text("permissionError.action.button")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(Constants.buttonCornerRadius)
            }
        }
        .padding()
    }
    
    /// Opens the app settings so the user can enable location permissions.
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}


// MARK: - Preview

#Preview("Locales", traits: .sizeThatFitsLayout) {
    VStack {
        PermissionErrorView()
            .environment(\.locale, .init(identifier: "en"))
        PermissionErrorView()
            .environment(\.locale, .init(identifier: "de"))
    }
    .padding()
}

