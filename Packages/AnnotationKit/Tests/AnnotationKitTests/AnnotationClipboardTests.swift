import CoreGraphics
import Testing

@testable import AnnotationKit

@Suite("AnnotationClipboard")
@MainActor
struct AnnotationClipboardTests {
    @Test("Copied selection pastes as a detached offset object and can be undone")
    func copyAndPaste() throws {
        let clipboard = AnnotationClipboard()
        let sourceDocument = AnnotationDocument(imageSize: CGSize(width: 400, height: 300))
        let source = RectangleObject(rect: CGRect(x: 20, y: 30, width: 80, height: 50))
        sourceDocument.addObject(source)

        #expect(clipboard.copySelection(from: sourceDocument))
        source.move(by: CGSize(width: 100, height: 100))

        let destinationDocument = AnnotationDocument(imageSize: CGSize(width: 400, height: 300))
        #expect(clipboard.paste(
            into: destinationDocument,
            offset: CGSize(width: 12, height: 12)
        ))

        let pasted = try #require(destinationDocument.objects.first as? RectangleObject)
        #expect(pasted.rect == CGRect(x: 32, y: 42, width: 80, height: 50))
        #expect(pasted.id != source.id)
        #expect(destinationDocument.selectedObjectID == pasted.id)

        destinationDocument.undo()
        #expect(destinationDocument.objects.isEmpty)
    }

    @Test("Duplicate selection leaves clipboard contents untouched")
    func duplicateSelection() throws {
        let clipboard = AnnotationClipboard()

        let copiedDocument = AnnotationDocument(imageSize: CGSize(width: 400, height: 300))
        let copied = RectangleObject(rect: CGRect(x: 10, y: 20, width: 30, height: 40))
        copiedDocument.addObject(copied)
        #expect(clipboard.copySelection(from: copiedDocument))

        let duplicatedDocument = AnnotationDocument(imageSize: CGSize(width: 400, height: 300))
        let source = RectangleObject(rect: CGRect(x: 100, y: 120, width: 60, height: 50))
        duplicatedDocument.addObject(source)
        #expect(duplicatedDocument.duplicateSelected(by: CGSize(width: 12, height: 12)))

        let duplicate = try #require(duplicatedDocument.objects.last as? RectangleObject)
        #expect(duplicate.rect == CGRect(x: 112, y: 132, width: 60, height: 50))
        #expect(duplicate.id != source.id)
        #expect(duplicatedDocument.selectedObjectID == duplicate.id)

        duplicatedDocument.undo()
        #expect(duplicatedDocument.objects.count == 1)

        let pastedDocument = AnnotationDocument(imageSize: CGSize(width: 400, height: 300))
        #expect(clipboard.paste(into: pastedDocument, offset: .zero))
        let pasted = try #require(pastedDocument.objects.first as? RectangleObject)
        #expect(pasted.rect == copied.rect)
    }
}
