import Foundation
import Testing
@testable import SharedKit

@Suite("UpdateCheckFrequency")
struct UpdateCheckFrequencyTests {
    @Test("Cases are ordered from most to least frequent")
    func caseOrder() {
        #expect(UpdateCheckFrequency.allCases == [.daily, .weekly, .monthly])
    }

    @Test("Raw values are stable identifiers")
    func rawValues() {
        #expect(UpdateCheckFrequency.daily.rawValue == "daily")
        #expect(UpdateCheckFrequency.weekly.rawValue == "weekly")
        #expect(UpdateCheckFrequency.monthly.rawValue == "monthly")
    }

    @Test("Each frequency maps to its Sparkle check interval")
    func timeIntervals() {
        #expect(UpdateCheckFrequency.daily.timeInterval == 86_400)
        #expect(UpdateCheckFrequency.weekly.timeInterval == 604_800)
        #expect(UpdateCheckFrequency.monthly.timeInterval == 2_592_000)
    }

    @Test("Exact intervals round-trip")
    func exactIntervalsRoundTrip() {
        for frequency in UpdateCheckFrequency.allCases {
            #expect(UpdateCheckFrequency(closestTo: frequency.timeInterval) == frequency)
        }
    }

    @Test("Unknown intervals snap to the closest frequency")
    func unknownIntervalsSnap() {
        #expect(UpdateCheckFrequency(closestTo: 3_600) == .daily)
        #expect(UpdateCheckFrequency(closestTo: 200_000) == .daily)
        #expect(UpdateCheckFrequency(closestTo: 500_000) == .weekly)
        #expect(UpdateCheckFrequency(closestTo: 1_500_000) == .weekly)
        #expect(UpdateCheckFrequency(closestTo: 2_000_000) == .monthly)
        #expect(UpdateCheckFrequency(closestTo: 10_000_000) == .monthly)
    }

    @Test("Non-positive intervals fall back to daily")
    func nonPositiveIntervalsFallBackToDaily() {
        #expect(UpdateCheckFrequency(closestTo: 0) == .daily)
        #expect(UpdateCheckFrequency(closestTo: -1) == .daily)
    }
}
