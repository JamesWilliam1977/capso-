import Foundation
import CoreGraphics

public final class LineObject: AnnotationObject, @unchecked Sendable {
    public let id = ObjectID()
    public var style: StrokeStyle
    public var start: CGPoint
    public var end: CGPoint

    public init(start: CGPoint, end: CGPoint, style: StrokeStyle = StrokeStyle()) {
        self.start = start
        self.end = end
        self.style = style
    }

    public var bounds: CGRect {
        let padding = max(style.lineWidth, 1)
        let minX = min(start.x, end.x) - padding
        let minY = min(start.y, end.y) - padding
        let maxX = max(start.x, end.x) + padding
        let maxY = max(start.y, end.y) + padding
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    public func hitTest(point: CGPoint, threshold: CGFloat) -> Bool {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSq = dx * dx + dy * dy
        guard lengthSq > 0 else { return hypot(point.x - start.x, point.y - start.y) <= threshold }

        var t = ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSq
        t = max(0, min(1, t))
        let projection = CGPoint(x: start.x + t * dx, y: start.y + t * dy)
        return hypot(point.x - projection.x, point.y - projection.y) <= threshold + style.lineWidth / 2
    }

    public func render(in ctx: CGContext) {
        ctx.saveGState()
        ctx.setStrokeColor(style.color.cgColor)
        ctx.setLineWidth(style.lineWidth)
        ctx.setAlpha(style.opacity)
        ctx.setLineCap(.round)
        ctx.move(to: start)
        ctx.addLine(to: end)
        ctx.strokePath()
        ctx.restoreGState()
    }

    public func move(by delta: CGSize) {
        start.x += delta.width
        start.y += delta.height
        end.x += delta.width
        end.y += delta.height
    }

    public func copy() -> any AnnotationObject {
        LineObject(start: start, end: end, style: style)
    }
}
