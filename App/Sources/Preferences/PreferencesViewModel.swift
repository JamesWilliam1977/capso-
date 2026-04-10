// App/Sources/Preferences/PreferencesViewModel.swift
import Foundation
import Observation
import SharedKit

@MainActor
@Observable
final class PreferencesViewModel {
    private let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    // MARK: General
    var playShutterSound: Bool {
        get { settings.playShutterSound }
        set { settings.playShutterSound = newValue }
    }
    var showMenuBarIcon: Bool {
        get { settings.showMenuBarIcon }
        set { settings.showMenuBarIcon = newValue }
    }

    // MARK: Screenshots
    var screenshotAutoCopy: Bool {
        get { settings.screenshotAutoCopy }
        set { settings.screenshotAutoCopy = newValue }
    }
    var screenshotFormat: ScreenshotFormat {
        get { settings.screenshotFormat }
        set { settings.screenshotFormat = newValue }
    }
    var captureWindowShadow: Bool {
        get { settings.captureWindowShadow }
        set { settings.captureWindowShadow = newValue }
    }
    var freezeScreen: Bool {
        get { settings.freezeScreen }
        set { settings.freezeScreen = newValue }
    }
    var showMagnifier: Bool {
        get { settings.showMagnifier }
        set { settings.showMagnifier = newValue }
    }
    var rememberLastCaptureArea: Bool {
        get { settings.rememberLastCaptureArea }
        set { settings.rememberLastCaptureArea = newValue }
    }

    // MARK: Recording
    var recordingFormat: RecordingFormat {
        get { settings.recordingFormat }
        set { settings.recordingFormat = newValue }
    }
    var showCursor: Bool {
        get { settings.showCursor }
        set { settings.showCursor = newValue }
    }
    var highlightClicks: Bool {
        get { settings.highlightClicks }
        set { settings.highlightClicks = newValue }
    }
    var cursorSmoothing: Bool {
        get { settings.cursorSmoothing }
        set { settings.cursorSmoothing = newValue }
    }
    var showCountdown: Bool {
        get { settings.showCountdown }
        set { settings.showCountdown = newValue }
    }
    var dimScreenWhileRecording: Bool {
        get { settings.dimScreenWhileRecording }
        set { settings.dimScreenWhileRecording = newValue }
    }
    var rememberLastRecordingArea: Bool {
        get { settings.rememberLastRecordingArea }
        set { settings.rememberLastRecordingArea = newValue }
    }

    // MARK: Camera
    var cameraShape: CameraShape {
        get { settings.cameraShape }
        set { settings.cameraShape = newValue }
    }
    var cameraSize: CameraSize {
        get { settings.cameraSize }
        set { settings.cameraSize = newValue }
    }
    var cameraMirror: Bool {
        get { settings.cameraMirror }
        set { settings.cameraMirror = newValue }
    }
    var cameraCustomSizePt: Double {
        get { settings.cameraCustomSizePt }
        set { settings.cameraCustomSizePt = newValue }
    }

    // MARK: Quick Access
    var quickAccessPosition: QuickAccessPosition {
        get { settings.quickAccessPosition }
        set { settings.quickAccessPosition = newValue }
    }
    var quickAccessAutoClose: Bool {
        get { settings.quickAccessAutoClose }
        set { settings.quickAccessAutoClose = newValue }
    }
    var quickAccessAutoCloseInterval: Int {
        get { settings.quickAccessAutoCloseInterval }
        set { settings.quickAccessAutoCloseInterval = newValue }
    }

    // MARK: Export
    var exportQuality: ExportQuality {
        get { settings.exportQuality }
        set { settings.exportQuality = newValue }
    }
    var exportLocation: URL {
        settings.exportLocation
    }
    func setExportLocation(_ url: URL) {
        settings.setExportLocation(url)
    }

    // MARK: OCR
    var ocrKeepLineBreaks: Bool {
        get { settings.ocrKeepLineBreaks }
        set { settings.ocrKeepLineBreaks = newValue }
    }
    var ocrDetectLinks: Bool {
        get { settings.ocrDetectLinks }
        set { settings.ocrDetectLinks = newValue }
    }
    var ocrPrimaryLanguage: String? {
        get { settings.ocrPrimaryLanguage }
        set { settings.ocrPrimaryLanguage = newValue }
    }

    // MARK: Version
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
