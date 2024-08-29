import SwiftUI

// MARK: - View

/// A SwiftUI view that displays an empty state for the hikes tracker, indicating no hikes are available.
///
/// The view shows a walking figure icon and a message to the user. It is designed to be displayed
/// when there are no recorded hikes to show, providing a visual cue to the user.
struct EmptyHikesView: View {
    
    // UI constants in the view
    struct Constants {
        // Size of the walk image
        static let imageSize = 100.0
    }
    
    /// The content and behavior of the view.
    var body: some View {
        VStack {
            // Walking figure icon
            Image(systemName: "figure.walk")
                .font(.system(size: Constants.imageSize))
                .foregroundColor(.gray)
            
            // Empty state text
            Text("walktracker.emptyStateText")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}


// MARK: - Preview

#Preview("Locales", traits: .sizeThatFitsLayout) {
    VStack {
        EmptyHikesView()
            .environment(\.locale, .init(identifier: "en"))
        EmptyHikesView()
            .environment(\.locale, .init(identifier: "de"))
    }
    .padding()
}
