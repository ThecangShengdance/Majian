import SwiftUI

struct QRPreviewCanvas: View {
    let matrix: QRMatrix
    let appearance: QRAppearance

    var body: some View {
        Canvas { context, size in
            let quiet = appearance.quietZone
            let total = matrix.size + quiet * 2
            let side = min(size.width, size.height)
            let module = side / CGFloat(total)
            let origin = CGPoint(
                x: (size.width - side) / 2,
                y: (size.height - side) / 2
            )
            let foreground = Color(nsColor: appearance.foreground)
            let background = Color(nsColor: appearance.background)
            let radius = 0.3 * module

            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(background)
            )

            switch appearance.style {
            case .classic:
                var path = Path()
                for row in 0..<matrix.size {
                    var column = 0
                    while column < matrix.size {
                        guard matrix.isDark(row: row, column: column) else {
                            column += 1
                            continue
                        }
                        let start = column
                        while column < matrix.size, matrix.isDark(row: row, column: column) {
                            column += 1
                        }
                        path.addRect(
                            CGRect(
                                x: origin.x + CGFloat(start + quiet) * module,
                                y: origin.y + CGFloat(row + quiet) * module,
                                width: CGFloat(column - start) * module,
                                height: module
                            )
                        )
                    }
                }
                context.fill(path, with: .color(foreground))

            case .soft, .dots:
                for finder in matrix.finderOrigins() {
                    drawFinder(
                        context: &context,
                        row: finder.row,
                        column: finder.column,
                        quiet: quiet,
                        module: module,
                        origin: origin,
                        foreground: foreground,
                        background: background
                    )
                }

                var path = Path()
                for row in 0..<matrix.size {
                    for column in 0..<matrix.size {
                        guard matrix.isDark(row: row, column: column) else { continue }
                        guard !isInsideFinder(
                            row: row,
                            column: column,
                            size: matrix.size
                        ) else { continue }

                        let rect = CGRect(
                            x: origin.x + CGFloat(column + quiet) * module,
                            y: origin.y + CGFloat(row + quiet) * module,
                            width: module,
                            height: module
                        )

                        if appearance.style == .dots {
                            path.addEllipse(
                                in: rect.insetBy(dx: module * 0.08, dy: module * 0.08)
                            )
                        } else {
                            path.addRoundedRect(
                                in: rect.insetBy(dx: module * 0.025, dy: module * 0.025),
                                cornerSize: CGSize(width: radius, height: radius)
                            )
                        }
                    }
                }
                context.fill(path, with: .color(foreground))
            }
        }
        .background(Color(nsColor: appearance.background))
        .accessibilityLabel("二维码预览")
    }

    private func drawFinder(
        context: inout GraphicsContext,
        row: Int,
        column: Int,
        quiet: Int,
        module: CGFloat,
        origin: CGPoint,
        foreground: Color,
        background: Color
    ) {
        let outer = CGRect(
            x: origin.x + CGFloat(column + quiet) * module,
            y: origin.y + CGFloat(row + quiet) * module,
            width: 7 * module,
            height: 7 * module
        )

        context.fill(
            Path(
                roundedRect: outer,
                cornerRadius: module * 1.35
            ),
            with: .color(foreground)
        )
        context.fill(
            Path(
                roundedRect: outer.insetBy(dx: module, dy: module),
                cornerRadius: module * 0.9
            ),
            with: .color(background)
        )
        context.fill(
            Path(
                roundedRect: outer.insetBy(dx: module * 2, dy: module * 2),
                cornerRadius: module * 0.7
            ),
            with: .color(foreground)
        )

    }

    private func isInsideFinder(row: Int, column: Int, size: Int) -> Bool {
        if row < 7 && column < 7 { return true }
        if row < 7 && column >= size - 7 { return true }
        if row >= size - 7 && column < 7 { return true }
        return false
    }
}
