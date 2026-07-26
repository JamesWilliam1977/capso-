import Foundation

/// How often the app checks for updates in the background.
///
/// The selected interval is stored by Sparkle itself (`SPUUpdater.updateCheckInterval`,
/// persisted as `SUScheduledCheckInterval`), so this type only maps between the
/// user-facing choices and the raw interval Sparkle expects.
public enum UpdateCheckFrequency: String, CaseIterable, Sendable {
    case daily
    case weekly
    case monthly

    /// The background check interval, in seconds.
    public var timeInterval: TimeInterval {
        switch self {
        case .daily: return 86_400
        case .weekly: return 604_800
        case .monthly: return 2_592_000
        }
    }

    /// The frequency whose interval sits closest to `interval`.
    ///
    /// Sparkle stores an arbitrary `TimeInterval`, which may have been written by an
    /// older build or by the Info.plist default, so an exact match is not guaranteed.
    /// Non-positive intervals resolve to `.daily`.
    public init(closestTo interval: TimeInterval) {
        guard interval > 0 else {
            self = .daily
            return
        }

        self = Self.allCases.min { lhs, rhs in
            abs(lhs.timeInterval - interval) < abs(rhs.timeInterval - interval)
        } ?? .daily
    }
}
