// App/Sources/Preferences/Tabs/ScreenshotSettingsView.swift
import SwiftUI
import SharedKit

struct ScreenshotSettingsView: View {
    @Bindable var viewModel: PreferencesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Screenshots")
                .font(.system(size: 20, weight: .bold))

            SettingGroup(title: "Capture") {
                SettingCard {
                    SettingRow(label: "Auto Copy to Clipboard", sublabel: "Copy screenshot immediately after capture") {
                        Toggle("", isOn: $viewModel.screenshotAutoCopy)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    SettingRow(label: "Capture Window Shadow", sublabel: "Include shadow in window captures", showDivider: true) {
                        Toggle("", isOn: $viewModel.captureWindowShadow)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    // TODO: Re-enable the three rows below once the underlying
                    // behaviors are implemented. They are currently dead UI —
                    // the values are stored in AppSettings but never read by
                    // CaptureCoordinator / CaptureOverlayView. Uncomment each
                    // row when its feature ships:
                    //   - freezeScreen: freeze the display during area selection
                    //     (needs capture overlay to snapshot the desktop on entry)
                    //   - showMagnifier: pixel-level loupe in the overlay
                    //   - rememberLastCaptureArea: persist last drag rect across runs
                    // SettingRow(label: "Freeze Screen", sublabel: "Freeze display during area selection", showDivider: true) {
                    //     Toggle("", isOn: $viewModel.freezeScreen)
                    //         .toggleStyle(.switch)
                    //         .controlSize(.small)
                    // }
                    // SettingRow(label: "Show Magnifier", sublabel: "Pixel-level loupe during selection", showDivider: true) {
                    //     Toggle("", isOn: $viewModel.showMagnifier)
                    //         .toggleStyle(.switch)
                    //         .controlSize(.small)
                    // }
                    // SettingRow(label: "Remember Last Area", sublabel: "Restore previous selection on next capture", showDivider: true) {
                    //     Toggle("", isOn: $viewModel.rememberLastCaptureArea)
                    //         .toggleStyle(.switch)
                    //         .controlSize(.small)
                    // }
                }
            }

            SettingGroup(title: "Format") {
                SettingCard {
                    SettingRow(label: "Screenshot Format") {
                        Picker("", selection: $viewModel.screenshotFormat) {
                            Text("PNG").tag(ScreenshotFormat.png)
                            Text("JPEG").tag(ScreenshotFormat.jpeg)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 140)
                    }
                }
            }
        }
    }


}
