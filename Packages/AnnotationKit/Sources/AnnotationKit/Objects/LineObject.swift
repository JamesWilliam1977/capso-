import Foundation
import CoreGraphics

public final class LineObject: AnnotationObject, @unchecked Sendable {
    public let id = ObjectID()
    public var style: StrokeStyle
    public var start: CGPoint
    public var end: CGPoint
    public var controlPoint: CGPoint?

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
        if let controlPoint {
            return CGRect(
                x: min(minX, controlPoint.x - padding),
                y: min(minY, controlPoint.y - padding),
                width: max(maxX, controlPoint.x + padding) - min(minX, controlPoint.x - padding),
                height: max(maxY, controlPoint.y + padding) - min(minY, controlPoint.y - padding)
            )
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    public func hitTest(point: CGPoint, threshold: CGFloat) -> Bool {
        if let controlPoint {
            return Self.distanceToQuadraticCurve(
                point: point,
                start: start,
                control: controlPoint,
                end: end
            ) <= threshold + style.lineWidth / 2
        }

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
        if let controlPoint {
            ctx.addQuadCurve(to: end, control: controlPoint)
        } else {
            ctx.addLine(to: end)
        }
        ctx.strokePath()
        ctx.restoreGState()
    }

    public func move(by delta: CGSize) {
        start.x += delta.width
        start.y += delta.height
        end.x += delta.width
        end.y += delta.height
        controlPoint?.x += delta.width
        controlPoint?.y += delta.height
    }

    public func copy() -> any AnnotationObject {
        let copy = LineObject(start: start, end: end, style: style)
        copy.controlPoint = controlPoint
        return copy
    }

    private static func distanceToQuadraticCurve(
        point: CGPoint,
        start: CGPoint,
        control: CGPoint,
        end: CGPoint
    ) -> CGFloat {
        var best = CGFloat.greatestFiniteMagnitude
        var previous = start

        for i in 1...32 {
            let t = CGFloat(i) / 32
            let current = quadraticPoint(t: t, start: start, control: control, end: end)
            best = min(best, distanceToSegment(point: point, start: previous, end: current))
            previous = current
        }

        return best
    }

    private static func quadraticPoint(
        t: CGFloat,
        start: CGPoint,
        control: CGPoint,
        end: CGPoint
    ) -> CGPoint {
        let u = 1 - t
        return CGPoint(
            x: u * u * start.x + 2 * u * t * control.x + t * t * end.x,
            y: u * u * start.y + 2 * u * t * control.y + t * t * end.y
        )
    }

    private static func distanceToSegment(point: CGPoint, start: CGPoint, end: CGPoint) -> CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSq = dx * dx + dy * dy
        guard lengthSq > 0 else { return hypot(point.x - start.x, point.y - start.y) }

        var t = ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSq
        t = max(0, min(1, t))
        let projection = CGPoint(x: start.x + t * dx, y: start.y + t * dy)
        return hypot(point.x - projection.x, point.y - projection.y)
    }
}
