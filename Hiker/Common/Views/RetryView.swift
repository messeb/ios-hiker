import SwiftUI

// MARK: - View

/// A SwiftUI view that provides a visual representation for retrying an action after an error.
///
/// The view displays an error icon, a message to the user, and a retry button to attempt the action again.
struct RetryView: View {
    
    // UI constants in the view
    struct Constants {
        // Spacing between each element
        static let elementSpacing = 20.0
        
        // Size of the image
        static let imageSize = 60.0
        
        // Corner radius of the button
        static let buttonCornerRadius = 10.0
    }
    
    /// The action to perform when the user taps the retry button.
    let retryAction: () -> Void
    
    /// The content and behavior of the view.
    var body: some View {
        VStack(spacing: Constants.elementSpacing) {
            // Error icon indicating something went wrong
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.imageSize, height: Constants.imageSize)
                .foregroundColor(.red)
            
            // Message to inform the user about the error
            Text("retryView.message")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            // Button to allow the user to retry the failed action
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                    Text("retryView.button")
                        .fontWeight(.bold)
                        .font(.title2)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(Constants.buttonCornerRadius)
            }
        }
        .padding()
    }
}


// MARK: - Preview

#Preview("Locales", traits: .sizeThatFitsLayout) {
    VStack {
        RetryView(retryAction: {})
            .environment(\.locale, .init(identifier: "en"))
        RetryView(retryAction: {})
            .environment(\.locale, .init(identifier: "de"))
    }
    .padding()
}
