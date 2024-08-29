import SwiftUI

// MARK: - View

/// A SwiftUI view that displays a hiking image stream based on the user's location.
///
/// `HikeImageStreamView` manages the display of images fetched based on the user's location data,
/// and handles the various states of loading, displaying, or retrying the image fetching process.
struct HikeImageStreamView: View {
    
    struct ViewConstants {
        // Corner radius of the images
        static let imageCornerRadius = 8.0
        
        // Shadow radius of the images
        static let shadowRadius = 4.0
    }
    
    /// The view model that provides the data and business logic for this view.
    @ObservedObject var viewModel: HikeImageStreamViewModel
    
    /// The body of the view.
    var body: some View {
        contentView()
            .onAppear {
                Task {
                    await viewModel.fetchImage()
                }
            }
    }
    
    /// Builds the content view based on the current state of the view model.
    ///
    /// - Returns: A view representing the current state of the image fetching process.
    @ViewBuilder
    private func contentView() -> some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .initial, .loading:
                ProgressView("loading")
                    .apply16to9Frame(for: geometry)
            case .empty:
                NoLocationImageView()
                    .apply16to9Frame(for: geometry)
            case .data(let image):
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .apply16to9Frame(for: geometry)
                        .clipped()
                        .cornerRadius(ViewConstants.imageCornerRadius)
                }
            case .error:
                RetryView {
                    Task {
                        await viewModel.fetchImage()
                    }
                }
            }
        }
        .frame(height: calculate16to9Height())
        .shadow(radius: ViewConstants.shadowRadius)
    }
    
    /// A function that calculates the height based on the aspect ratio 16:9.
    private func calculate16to9Height() -> CGFloat {
        return UIScreen.main.bounds.width * 9 / 16
    }
}
