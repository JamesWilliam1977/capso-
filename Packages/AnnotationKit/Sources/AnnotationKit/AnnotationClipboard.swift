import CoreGraphics

@MainActor
public final class AnnotationClipboard {
    public static let shared = AnnotationClipboard()

    private var copiedObject: (any AnnotationObject)?

    public init() {}

    @discardableResult
    public func copySelection(from document: AnnotationDocument) -> Bool {
        guard let selectedObject = document.selectedObject else { return false }
        copiedObject = selectedObject.copy()
        return true
    }

    @discardableResult
    public func paste(into document: AnnotationDocument, offset: CGSize) -> Bool {
        guard let copiedObject else { return false }
        let pastedObject = copiedObject.copy()
        pastedObject.move(by: offset)
        document.addObject(pastedObject)
        return true
    }
}
