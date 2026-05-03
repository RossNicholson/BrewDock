import SwiftUI

extension View {
    /// Applies Liquid Glass on macOS 26+, falls back to regularMaterial on older versions.
    @ViewBuilder
    func liquidGlassBackground(in shape: some Shape = Rectangle()) -> some View {
        if #available(macOS 26, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(shape.fill(.regularMaterial))
        }
    }

    /// Applies interactive Liquid Glass on macOS 26+, falls back to ultraThinMaterial.
    @ViewBuilder
    func liquidGlassInteractive(in shape: some Shape = Capsule()) -> some View {
        if #available(macOS 26, *) {
            self.glassEffect(.regular.interactive(), in: shape)
        } else {
            self.background(shape.fill(.ultraThinMaterial))
        }
    }
}
