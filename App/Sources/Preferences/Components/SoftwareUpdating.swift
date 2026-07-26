// App/Sources/Preferences/Components/SoftwareUpdating.swift
import Foundation
import Sparkle

/// The slice of Sparkle's updater that Capso drives.
///
/// `UpdateManager` talks to this instead of `SPUUpdater` directly so its behaviour
/// can be unit tested without starting a real updater. `SPUUpdater` is already
/// main-actor isolated (`NS_SWIFT_UI_ACTOR`), matching this protocol's isolation.
@MainActor
protocol SoftwareUpdating: AnyObject {
    /// Whether the user can start an update check right now.
    var canCheckForUpdates: Bool { get }
    /// Whether Sparkle checks for updates in the background.
    var automaticallyChecksForUpdates: Bool { get set }
    /// Whether found updates are downloaded and installed without asking.
    var automaticallyDownloadsUpdates: Bool { get set }
    /// Whether the automatic-install option can be turned on at all.
    var allowsAutomaticUpdates: Bool { get }
    /// How often background checks run, in seconds.
    var updateCheckInterval: TimeInterval { get set }

    /// Silently fetches update information without showing Sparkle's UI.
    func checkForUpdateInformation()
    /// Runs a user-initiated check, showing Sparkle's UI.
    func checkForUpdates()
}

extension SPUUpdater: SoftwareUpdating {}
