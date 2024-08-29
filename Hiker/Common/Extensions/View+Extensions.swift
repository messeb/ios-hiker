import SwiftUI

extension View {
    /// Applies the standard frame size used in `HikeImageStreamView` to the view.
    ///
    /// - Parameter geometry: The geometry proxy used to calculate the width and height.
    /// - Returns: A view with the standard frame size applied.
    func apply16to9Frame(for geometry: GeometryProxy) -> some View {
        self.modifier(FrameModifier(width: geometry.size.width, height: geometry.size.width * 9 / 16))
    }
}
