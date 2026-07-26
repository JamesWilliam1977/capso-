import AppKit
import CoreGraphics
import Foundation

public enum ScreenshotClipboard {
    @discardableResult
    public static func copy(
        _ image: CGImage,
        content: ScreenshotClipboardContent,
        imageFormat: ScreenshotClipboardFormat,
        pasteboard: NSPasteboard = .general,
        fileURLProvider: () throws -> URL
    ) -> Bool {
        switch content {
        case .image:
            return ImageUtilities.copyToPasteboard(
                image,
                format: imageFormat,
                pasteboard: pasteboard
            )
        case .filePath:
            guard let fileURL = try? fileURLProvider(),
                  fileURL.isFileURL,
                  FileManager.default.isReadableFile(atPath: fileURL.path) else {
                return false
            }
            pasteboard.clearContents()
            return pasteboard.setString(fileURL.path, forType: .string)
        }
    }
}
