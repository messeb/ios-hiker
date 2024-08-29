import SwiftUI

// MARK: - View

/// A SwiftUI view that displays a placeholder image when no location-based images are available.
///
/// `NoLocationImageView` provides a simple and clear indication to the user that no images are available,
/// typically used as a fallback in scenarios where the expected images cannot be fetched or loaded.
struct NoLocationImageView: View {
    
    // UI constants in the view
    struct Constants {
        // Height / width of the image
        static let imageFrameSize = 100.0
        
        // Padding of the text
        static let textPadding = 8.0
    }
    
    /// The content and behavior of the view.
    var body: some View {
        VStack {
            // Placeholder icon representing the absence of images
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.imageFrameSize, height: Constants.imageFrameSize)
                .foregroundColor(.gray)
                .padding()
            
            // Text message informing the user that no images are available
            Text("noimage")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, Constants.textPadding)
        }
        .padding()
    }
}


// MARK: - Preview

#Preview("Locales", traits: .sizeThatFitsLayout) {
    VStack {
        NoLocationImageView()
            .environment(\.locale, .init(identifier: "en"))
        NoLocationImageView()
            .environment(\.locale, .init(identifier: "de"))
    }
    .padding()
}
