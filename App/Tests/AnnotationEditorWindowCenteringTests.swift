import AppKit
import XCTest
import SharedKit
@testable import Capso

@MainActor
final class AnnotationEditorWindowCenteringTests: XCTestCase {
    /// The regression from issue #236: a capture small enough that the
    /// image-derived width falls below the toolbar's intrinsic width. AppKit
    /// installs the hosting view's `contentMinSize` and applies it a runloop
    /// pass *after* the window has been positioned, widening it rightwards
    /// from a fixed origin and dragging it off-center.
    func testSmallCaptureStaysCenteredAfterAppKitAppliesMinimumSize() throws {
        let screen = try XCTUnwrap(NSScreen.main)
        let window = try makeWindow(pixelWidth: 600, pixelHeight: 400, screen: screen)
        defer { window.close() }

        window.show()
        settleLayout()

        assertCentered(window, on: screen)
        // Guards the premise: the toolbar forced the window wider than the
        // 600px image. Without that growth this test proves nothing.
        XCTAssertGreaterThan(window.frame.width, 600)
    }

    /// A wide Retina capture is sized from the image rather than the toolbar
    /// minimum, and must be converted from pixels to points so it stays inside
    /// the viewport budget instead of overflowing the display.
    func testWideRetinaCaptureIsCenteredAndFitsTheVisibleFrame() throws {
        let screen = try XCTUnwrap(NSScreen.main)
        let window = try makeWindow(pixelWidth: 6000, pixelHeight: 1500, screen: screen)
        defer { window.close() }

        // Centering is asserted before presentation: once the window is on
        // screen, macOS occasionally nudges wide windows during app activation
        // (observed as a ~40pt drift), which is unrelated to this sizing path.
        assertCentered(window, on: screen)

        let sizeBeforeShow = window.frame.size
        window.show()
        settleLayout()

        // The SwiftUI tree must not have forced it any wider.
        XCTAssertEqual(window.frame.width, sizeBeforeShow.width, accuracy: 1)
        XCTAssertEqual(window.frame.height, sizeBeforeShow.height, accuracy: 1)
        XCTAssertLessThanOrEqual(window.frame.width, screen.visibleFrame.width + 1)
        XCTAssertLessThanOrEqual(window.frame.height, screen.visibleFrame.height + 1)
    }

    /// `show()` positions the window once. A window the user has dragged
    /// elsewhere must not be yanked back to center by a later `show()`.
    func testSubsequentShowDoesNotRepositionAMovedWindow() throws {
        let screen = try XCTUnwrap(NSScreen.main)
        let window = try makeWindow(pixelWidth: 600, pixelHeight: 400, screen: screen)
        defer { window.close() }

        window.show()
        settleLayout()

        let moved = window.frame.offsetBy(dx: 40, dy: -30)
        window.setFrame(moved, display: false)
        window.show()

        XCTAssertEqual(window.frame.origin.x, moved.origin.x, accuracy: 1)
        XCTAssertEqual(window.frame.origin.y, moved.origin.y, accuracy: 1)
    }

    // MARK: - Helpers

    private func assertCentered(
        _ window: AnnotationEditorWindow,
        on screen: NSScreen,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            window.frame.midX, screen.visibleFrame.midX, accuracy: 1,
            "Window is horizontally off-center: \(window.frame) in \(screen.visibleFrame)",
            file: file, line: line
        )
        XCTAssertEqual(
            window.frame.midY, screen.visibleFrame.midY, accuracy: 1,
            "Window is vertically off-center: \(window.frame) in \(screen.visibleFrame)",
            file: file, line: line
        )
    }

    /// Lets AppKit apply the hosting view's `contentMinSize`, which happens on
    /// a later runloop pass. Without this the assertions run against a frame
    /// the user never actually sees.
    private func settleLayout() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.3))
    }

    private func makeWindow(
        pixelWidth: Int,
        pixelHeight: Int,
        screen: NSScreen
    ) throws -> AnnotationEditorWindow {
        AnnotationEditorWindow(
            image: try makeImage(width: pixelWidth, height: pixelHeight),
            anchorScreen: screen,
            screenshotOutputPreset: .losslessPNG,
            screenshotFilenameTemplate: "Screenshot",
            onSave: { _ in true },
            onCopy: { _ in },
            onPin: { _, _ in },
            onClose: {}
        )
    }

    private func makeImage(width: Int, height: Int) throws -> CGImage {
        let context = try XCTUnwrap(CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return try XCTUnwrap(context.makeImage())
    }
}
