// App/Sources/Preferences/Tabs/ScreenshotSettingsView.swift
import SwiftUI
import SharedKit

struct ScreenshotSettingsView: View {
    @Bindable var viewModel: PreferencesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Screenshots")
                .font(.system(size: 20, weight: .bold))

            SettingGroup(title: "After Capture") {
                SettingCard {
                    SettingRow(label: "Show Preview", sublabel: "Display thumbnail with quick actions") {
                        Toggle("", isOn: $viewModel.screenshotShowPreview)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    SettingRow(label: "Copy to Clipboard", sublabel: "Copy screenshot immediately", showDivider: true) {
                        Toggle("", isOn: $viewModel.screenshotAutoCopy)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    SettingRow(label: "Auto Save", sublabel: "Save to file automatically", showDivider: true) {
                        Toggle("", isOn: $viewModel.screenshotAutoSave)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                }
            }

            SettingGroup(title: "Capture") {
                SettingCard {
                    SettingRow(label: "Capture Window Shadow", sublabel: "Include shadow in window captures") {
                        Toggle("", isOn: $viewModel.captureWindowShadow)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    // TODO: Re-enable the rows below once underlying
                    // behaviors are implemented (freezeScreen, showMagnifier,
                    // rememberLastCaptureArea).
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
