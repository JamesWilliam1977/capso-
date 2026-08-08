import CoreGraphics

/// Pure layout math for the full-screen-independent Annotate window.
///
/// Two things have to line up for the window to open centered (issue #236):
///
/// 1. Capture images are pixel-backed (Retina screenshots are typically 2×),
///    but `NSWindow` frames are measured in points, so pixels have to be
///    divided by the screen's backing scale before they mean anything.
/// 2. The editor's SwiftUI toolbar is a row of fixed-width controls, so the
///    hosting view wants far more width than a small capture needs. AppKit
///    applies that want on a *later* runloop pass, growing the window
///    rightwards from its existing origin — so a frame that ignores it gets
///    silently widened and pushed off-center after being positioned. The
///    window is therefore sized to it up front, and the toolbar's tool row
///    scrolls so that width stays a preference the display can override.
public enum AnnotationEditorWindowGeometry {
    /// Content-area size (points) for an image that must fit inside a fraction
    /// of the screen, leaving vertical room for toolbar / zoom chrome.
    public static func contentSize(
        imagePixelSize: CGSize,
        backingScaleFactor: CGFloat,
        visibleSize: CGSize,
        chromeHeight: CGFloat,
        maxViewportFraction: CGFloat = 0.8
    ) -> CGSize {
        guard imagePixelSize.width > 0,
              imagePixelSize.height > 0,
              visibleSize.width > 0,
              visibleSize.height > 0,
              maxViewportFraction > 0 else {
            return .zero
        }

        let scaleFactor = max(backingScaleFactor, 1)
        let pointWidth = imagePixelSize.width / scaleFactor
        let pointHeight = imagePixelSize.height / scaleFactor

        let maxWidth = visibleSize.width * maxViewportFraction
        let maxHeight = max(0, visibleSize.height * maxViewportFraction - max(chromeHeight, 0))
        guard maxWidth > 0, maxHeight > 0 else { return .zero }

        let fitScale = min(1, min(maxWidth / pointWidth, maxHeight / pointHeight))
        return CGSize(
            width: pointWidth * fitScale,
            height: pointHeight * fitScale + max(chromeHeight, 0)
        )
    }

    /// Reconciles the image-derived content size with the size the SwiftUI tree
    /// actually needs, so the window is born at the size AppKit would force it
    /// to anyway.
    ///
    /// `fitting` is the size the SwiftUI tree would like — in practice the
    /// toolbar's natural width. The window grows to it so every editing tool is
    /// visible without scrolling, but it is a preference rather than a floor,
    /// because the toolbar scrolls horizontally when squeezed. That lets
    /// `visibleSize` cap it outright, which is what keeps the window on a
    /// display too narrow for the whole toolbar.
    public static func resolvedContentSize(
        preferred: CGSize,
        fitting: CGSize,
        visibleSize: CGSize
    ) -> CGSize {
        CGSize(
            width: resolve(preferred: preferred.width, fitting: fitting.width, visible: visibleSize.width),
            height: resolve(preferred: preferred.height, fitting: fitting.height, visible: visibleSize.height)
        )
    }

    private static func resolve(preferred: CGFloat, fitting: CGFloat, visible: CGFloat) -> CGFloat {
        min(max(preferred, max(fitting, 0)), max(visible, 0))
    }

    /// Centers a window frame of `size` inside `visibleFrame` (absolute desktop
    /// coordinates), keeping it on the display.
    ///
    /// An axis larger than `visibleFrame` cannot be centered, so it is pinned
    /// to the visible origin instead of overhanging both edges. AppKit would
    /// clamp it anyway; doing it here keeps the frame we compute and the frame
    /// we get the same. Returns `.zero` when either input is empty.
    public static func centeredFrame(size: CGSize, in visibleFrame: CGRect) -> CGRect {
        guard size.width > 0,
              size.height > 0,
              visibleFrame.width > 0,
              visibleFrame.height > 0 else {
            return .zero
        }

        return CGRect(
            x: onscreenOrigin(length: size.width, lower: visibleFrame.minX, upper: visibleFrame.maxX),
            y: onscreenOrigin(length: size.height, lower: visibleFrame.minY, upper: visibleFrame.maxY),
            width: size.width,
            height: size.height
        )
    }

    private static func onscreenOrigin(length: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        let centered = (lower + upper) / 2 - length / 2
        let maxOrigin = upper - length
        guard maxOrigin > lower else { return lower }
        return min(max(centered, lower), maxOrigin)
    }
}
