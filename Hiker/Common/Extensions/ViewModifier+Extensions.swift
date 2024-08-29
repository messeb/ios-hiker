import SwiftUI

/// A custom view modifier that applies a specific frame size to any view.
///
/// `FrameModifier` allows you to set the width and height of a view by passing in the desired dimensions. This is useful when you want to apply a consistent frame size across multiple views without repeating the same code.
///
///
/// - Parameters:
///   - width: The width of the frame to be applied to the view.
///   - height: The height of the frame to be applied to the view.
struct FrameModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    
    /// Modifies the given view by applying the specified frame size.
    ///
    /// - Parameter content: The original view that the modifier is applied to.
    /// - Returns: A view with the specified frame size applied.
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
    }
}
