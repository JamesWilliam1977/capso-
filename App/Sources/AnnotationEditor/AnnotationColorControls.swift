import AppKit
import SwiftUI
import AnnotationKit

struct AnnotationColorControls: View {
    @Binding var currentColor: AnnotationColor

    var swatchSize: CGFloat = 19
    var spacing: CGFloat = 3
    var selectedRingColor: Color = .accentColor

    @State private var sampler: NSColorSampler?

    private var customColor: Binding<Color> {
        Binding(
            get: { Color(nsColor: currentColor.nsColor) },
            set: { currentColor = AnnotationColor(nsColor: NSColor($0)) }
        )
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(AnnotationColor.allCases, id: \.self) { color in
                Button(action: { currentColor = color }) {
                    Circle()
                        .fill(Color(cgColor: color.cgColor))
                        .frame(width: swatchSize, height: swatchSize)
                        .overlay(Circle().stroke(currentColor == color ? selectedRingColor : Color.clear, lineWidth: 2))
                        .overlay(Circle().stroke(Color.black.opacity(0.24), lineWidth: 0.5))
                        .padding(2)
                        .background(
                            Circle()
                                .fill(currentColor == color ? selectedRingColor.opacity(0.12) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .help(Text(color.displayName))
            }

            ColorPicker("", selection: customColor, supportsOpacity: false)
                .labelsHidden()
                .frame(width: swatchSize + 8, height: swatchSize + 8)
                .help("Custom Color")

            Button(action: pickScreenColor) {
                Image(systemName: "eyedropper")
                    .font(.system(size: max(12, swatchSize - 6), weight: .medium))
                    .foregroundStyle(Color.primary.opacity(0.88))
                    .frame(width: swatchSize + 8, height: swatchSize + 8)
                    .background(Circle().fill(Color.primary.opacity(0.08)))
            }
            .buttonStyle(.plain)
            .help("Pick Color From Screen")
        }
    }

    private func pickScreenColor() {
        let sampler = NSColorSampler()
        self.sampler = sampler
        sampler.show { color in
            if let color {
                currentColor = AnnotationColor(nsColor: color)
            }
            self.sampler = nil
        }
    }
}
