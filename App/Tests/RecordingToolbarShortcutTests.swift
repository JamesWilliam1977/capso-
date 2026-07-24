import AppKit
import XCTest
@testable import Capso
import SharedKit

@MainActor
final class RecordingToolbarShortcutTests: XCTestCase {
    func testReturnStartsVideoRecording() throws {
        let harness = try makeHarness()
        defer { harness.cleanUp() }

        let event = try makeReturnEvent(
            modifierFlags: [],
            windowNumber: harness.window.windowNumber
        )

        NSApp.sendEvent(event)
        XCTAssertEqual(harness.recordedFormats(), [.video])
    }

    func testOptionReturnStartsGIFRecording() throws {
        let harness = try makeHarness()
        defer { harness.cleanUp() }

        let event = try makeReturnEvent(
            modifierFlags: .option,
            windowNumber: harness.window.windowNumber
        )

        NSApp.sendEvent(event)
        XCTAssertEqual(harness.recordedFormats(), [.gif])
    }

    private func makeHarness() throws -> RecordingToolbarHarness {
        let suiteName = "RecordingToolbarShortcutTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        let settings = AppSettings(defaults: defaults)
        let screen = try XCTUnwrap(NSScreen.main)
        var recordedFormats: [RecordingFormatChoice] = []

        let window = RecordingToolbarWindow(
            selectionRect: CGRect(x: 100, y: 100, width: 640, height: 480),
            screen: screen,
            settings: settings,
            onRecord: { format, _, _, _, _ in
                recordedFormats.append(format)
            },
            onCameraToggled: { _, _ in true },
            onChangeArea: {},
            onCancel: {},
            onCameraSettingsChanged: {}
        )
        window.show()

        return RecordingToolbarHarness(
            window: window,
            suiteName: suiteName,
            recordedFormats: { recordedFormats }
        )
    }

    private func makeReturnEvent(
        modifierFlags: NSEvent.ModifierFlags,
        windowNumber: Int
    ) throws -> NSEvent {
        try XCTUnwrap(NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: modifierFlags,
            timestamp: 0,
            windowNumber: windowNumber,
            context: nil,
            characters: "\r",
            charactersIgnoringModifiers: "\r",
            isARepeat: false,
            keyCode: 36
        ))
    }
}

final class CaptureWindowPolicyTests: XCTestCase {
    func testElevatedWindowsUseTheFrozenDisplayCapture() {
        XCTAssertTrue(CaptureCoordinator.shouldUseFrozenWindowCapture(windowLayer: 27))
        XCTAssertFalse(CaptureCoordinator.shouldUseFrozenWindowCapture(windowLayer: 0))
    }

    func testElevatedApplicationWindowIncludesNativeShadowPadding() {
        let windowRect = CGRect(x: 100, y: 100, width: 240, height: 160)

        let captureRect = CaptureCoordinator.frozenWindowCaptureRect(
            windowRect: windowRect,
            screenSize: CGSize(width: 1920, height: 1080),
            windowLayer: 27,
            appName: "Control Center",
            appBundleIdentifier: "com.apple.controlcenter",
            captureWindowShadow: true
        )

        XCTAssertEqual(captureRect, CGRect(x: 50, y: 50, width: 340, height: 260))
    }

    func testDisabledShadowKeepsExactFrozenWindowRect() {
        let windowRect = CGRect(x: 100, y: 100, width: 240, height: 160)

        let captureRect = CaptureCoordinator.frozenWindowCaptureRect(
            windowRect: windowRect,
            screenSize: CGSize(width: 1920, height: 1080),
            windowLayer: 27,
            appName: "Control Center",
            appBundleIdentifier: "com.apple.controlcenter",
            captureWindowShadow: false
        )

        XCTAssertEqual(captureRect, windowRect)
    }

    func testSystemMenuBarKeepsExactRectWhenShadowIsEnabled() {
        let menuBarRect = CGRect(x: 0, y: 1050, width: 1920, height: 30)

        let captureRect = CaptureCoordinator.frozenWindowCaptureRect(
            windowRect: menuBarRect,
            screenSize: CGSize(width: 1920, height: 1080),
            windowLayer: Int(CGWindowLevelForKey(.mainMenuWindow)),
            appName: "",
            appBundleIdentifier: "",
            captureWindowShadow: true
        )

        XCTAssertEqual(captureRect, menuBarRect)
    }
}

@MainActor
private struct RecordingToolbarHarness {
    let window: RecordingToolbarWindow
    let suiteName: String
    let recordedFormats: () -> [RecordingFormatChoice]

    func cleanUp() {
        window.close()
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
    }
}
