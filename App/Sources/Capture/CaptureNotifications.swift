// App/Sources/Capture/CaptureNotifications.swift
import Foundation

extension Notification.Name {
    /// Posted after the desktop (including any system alert) has been frozen.
    static let capsoCaptureDidFreezeDesktop = Notification.Name("capsoCaptureDidFreezeDesktop")
    /// Posted after the interactive capture overlay has been dismissed.
    static let capsoCaptureDidEnd = Notification.Name("capsoCaptureDidEnd")
}
