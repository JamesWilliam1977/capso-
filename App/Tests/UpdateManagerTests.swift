import XCTest
@testable import Capso
import SharedKit

/// Stand-in for Sparkle's `SPUUpdater` so `UpdateManager` can be exercised
/// without starting a real updater inside the test host.
@MainActor
final class FakeSoftwareUpdater: SoftwareUpdating {
    var canCheckForUpdates = true
    var allowsAutomaticUpdates = true
    var updateCheckInterval: TimeInterval = 86_400
    var checkForUpdateInformationCount = 0
    var checkForUpdatesCount = 0

    var automaticallyChecksForUpdates = true {
        didSet { automaticallyChecksForUpdatesWriteCount += 1 }
    }
    private(set) var automaticallyChecksForUpdatesWriteCount = 0

    var automaticallyDownloadsUpdates = false {
        didSet { automaticallyDownloadsUpdatesWriteCount += 1 }
    }
    private(set) var automaticallyDownloadsUpdatesWriteCount = 0

    func checkForUpdateInformation() {
        checkForUpdateInformationCount += 1
    }

    func checkForUpdates() {
        checkForUpdatesCount += 1
    }
}

@MainActor
final class UpdateManagerTests: XCTestCase {
    func testInitReadsCurrentUpdaterState() {
        let updater = FakeSoftwareUpdater()
        updater.canCheckForUpdates = false
        updater.automaticallyDownloadsUpdates = true

        let manager = UpdateManager(updater: updater)

        XCTAssertFalse(manager.canCheckForUpdates)
        XCTAssertTrue(manager.automaticallyDownloadsUpdates)
    }

    func testInitReadsAutomaticCheckSetting() {
        let updater = FakeSoftwareUpdater()
        updater.automaticallyChecksForUpdates = false

        let manager = UpdateManager(updater: updater)

        XCTAssertFalse(manager.automaticallyChecksForUpdates)
    }

    func testDisablingAutomaticChecksWritesThroughToTheUpdater() {
        let updater = FakeSoftwareUpdater()
        let manager = UpdateManager(updater: updater)

        manager.automaticallyChecksForUpdates = false

        XCTAssertFalse(updater.automaticallyChecksForUpdates)
    }

    func testEnablingAutomaticChecksWritesThroughToTheUpdater() {
        let updater = FakeSoftwareUpdater()
        updater.automaticallyChecksForUpdates = false
        let manager = UpdateManager(updater: updater)

        manager.automaticallyChecksForUpdates = true

        XCTAssertTrue(updater.automaticallyChecksForUpdates)
    }

    func testSettingTheSameAutomaticCheckValueDoesNotRewrite() {
        let updater = FakeSoftwareUpdater()
        let manager = UpdateManager(updater: updater)
        let writes = updater.automaticallyChecksForUpdatesWriteCount

        manager.automaticallyChecksForUpdates = true

        XCTAssertEqual(updater.automaticallyChecksForUpdatesWriteCount, writes)
    }

    func testInitDerivesFrequencyFromTheUpdaterInterval() {
        let updater = FakeSoftwareUpdater()
        updater.updateCheckInterval = UpdateCheckFrequency.weekly.timeInterval

        let manager = UpdateManager(updater: updater)

        XCTAssertEqual(manager.updateCheckFrequency, .weekly)
    }

    func testInitSnapsAnUnknownIntervalToTheClosestFrequency() {
        let updater = FakeSoftwareUpdater()
        updater.updateCheckInterval = 3_600

        let manager = UpdateManager(updater: updater)

        XCTAssertEqual(manager.updateCheckFrequency, .daily)
    }

    func testChangingFrequencyWritesTheIntervalToTheUpdater() {
        let updater = FakeSoftwareUpdater()
        let manager = UpdateManager(updater: updater)

        manager.updateCheckFrequency = .monthly

        XCTAssertEqual(updater.updateCheckInterval, UpdateCheckFrequency.monthly.timeInterval)
    }

    func testChangingFrequencyLeavesTheAutomaticCheckSettingAlone() {
        let updater = FakeSoftwareUpdater()
        let manager = UpdateManager(updater: updater)
        let writes = updater.automaticallyChecksForUpdatesWriteCount

        manager.updateCheckFrequency = .weekly

        XCTAssertTrue(updater.automaticallyChecksForUpdates)
        XCTAssertEqual(updater.automaticallyChecksForUpdatesWriteCount, writes)
    }

    func testFrequencyStillPersistsWhileAutomaticChecksAreOff() {
        let updater = FakeSoftwareUpdater()
        updater.automaticallyChecksForUpdates = false
        let manager = UpdateManager(updater: updater)

        manager.updateCheckFrequency = .weekly

        XCTAssertEqual(updater.updateCheckInterval, UpdateCheckFrequency.weekly.timeInterval)
    }

    func testAutomaticInstallIsConfigurableWhenSparkleAllowsIt() {
        let updater = FakeSoftwareUpdater()
        updater.allowsAutomaticUpdates = true

        let manager = UpdateManager(updater: updater)

        XCTAssertTrue(manager.canConfigureAutomaticInstall)
    }

    func testAutomaticInstallIsNotConfigurableWhenSparkleDisallowsIt() {
        let updater = FakeSoftwareUpdater()
        updater.allowsAutomaticUpdates = false

        let manager = UpdateManager(updater: updater)

        XCTAssertFalse(manager.canConfigureAutomaticInstall)
    }

    func testDisablingAutomaticChecksKeepsTheAutomaticInstallPreference() {
        let updater = FakeSoftwareUpdater()
        updater.automaticallyDownloadsUpdates = true
        let manager = UpdateManager(updater: updater)

        manager.automaticallyChecksForUpdates = false

        XCTAssertTrue(updater.automaticallyDownloadsUpdates)
        XCTAssertTrue(manager.automaticallyDownloadsUpdates)
    }

    func testManualCheckStillRunsWhileAutomaticChecksAreOff() {
        let updater = FakeSoftwareUpdater()
        updater.automaticallyChecksForUpdates = false
        let manager = UpdateManager(updater: updater)

        manager.checkForUpdates()

        XCTAssertEqual(updater.checkForUpdateInformationCount, 1)
        XCTAssertEqual(manager.status?.kind, .checking)
    }

    func testManualCheckIsIgnoredWhenTheUpdaterCannotCheck() {
        let updater = FakeSoftwareUpdater()
        updater.canCheckForUpdates = false
        let manager = UpdateManager(updater: updater)

        manager.checkForUpdates()

        XCTAssertEqual(updater.checkForUpdateInformationCount, 0)
        XCTAssertNil(manager.status)
    }

    func testInitDoesNotWriteBackToTheUpdater() {
        let updater = FakeSoftwareUpdater()
        let checksWrites = updater.automaticallyChecksForUpdatesWriteCount
        let downloadsWrites = updater.automaticallyDownloadsUpdatesWriteCount

        _ = UpdateManager(updater: updater)

        XCTAssertEqual(updater.automaticallyChecksForUpdatesWriteCount, checksWrites)
        XCTAssertEqual(updater.automaticallyDownloadsUpdatesWriteCount, downloadsWrites)
    }
}
