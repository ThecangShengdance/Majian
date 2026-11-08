import AppKit
import CoreGraphics
import Foundation

// MARK: - Matrix

struct QRMatrix: Equatable {
    let size: Int
    let modules: [Bool]

    init(size: Int, modules: [Bool]) {
        self.size = size
        self.modules = modules
    }

    var version: Int { (size - 17) / 4 }

    var darkCount: Int { modules.lazy.filter { $0 }.count }

    func isDark(row: Int, column: Int) -> Bool {
        guard row >= 0, row < size, column >= 0, column < size else { return false }
        return modules[row * size + column]
    }

    func finderOrigins() -> [(row: Int, column: Int)] {
        [(0, 0), (0, size - 7), (size - 7, 0)]
    }
}

// MARK: - Errors

enum QRCodeError: LocalizedError {
    case generationFailed
    case unreadableMatrix
    case unreadableImage

    var errorDescription: String? {
        switch self {
        case .generationFailed:
            return "二维码生成失败。内容可能过长，请缩短内容或降低纠错级别。"
        case .unreadableMatrix:
            return "二维码模块读取失败，请重试。"
        case .unreadableImage:
            return "图片渲染失败，请重试。"
        }
    }
}

// MARK: - Generator

enum QRCodeEngine {
    static func generate(payload: Data, correction: QRCorrection, text: String? = nil) throws -> QRMatrix {
        guard !payload.isEmpty else { throw QRCodeError.generationFailed }

        let ecl: QRCodeECC
        switch correction {
        case .low: ecl = .low
        case .medium: ecl = .medium
        case .quartile: ecl = .quartile
        case .high: ecl = .high
        }

        // Let the encoder pick numeric/alphanumeric/byte segments for text.
        // Binary payloads always use byte mode so arbitrary bytes survive.
        let segments: [QRSegment]
        if let text, !text.isEmpty {
            segments = QRSegment.makeSegments(Array(text))
        } else {
            segments = [QRSegment.makeBytes([UInt8](payload))]
        }

        let code: QRCode
        do {
            code = try QRCode.encode(segments: segments, ecl: ecl, boostECL: false)
        } catch {
            throw QRCodeError.generationFailed
        }

        var modules = [Bool](repeating: false, count: code.size * code.size)
        for row in 0..<code.size {
            for column in 0..<code.size {
                modules[row * code.size + column] = code.getModule(x: column, y: row)
            }
        }
        return QRMatrix(size: code.size, modules: modules)
    }
}

// MARK: - Rendering style

enum QRDotStyle: String, CaseIterable, Identifiable {
    case classic
    case soft
    case dots

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: return "经典"
        case .soft: return "柔和"
        case .dots: return "点阵"
        }
    }

    var detail: String {
        switch self {
        case .classic: return "最稳妥，适合打印与远距离扫描。"
        case .soft: return "圆角模块，更柔和，仍保持高识别率。"
        case .dots: return "圆点模块，风格更强；极少数扫码器可能不识别。"
        }
    }
}

struct QRAppearance {
    var foreground: NSColor
    var background: NSColor
    var style: QRDotStyle = .classic
    var quietZone: Int = 4
}

enum QRCodeRenderer {
    static func pngData(
        matrix: QRMatrix,
        appearance: QRAppearance,
        pixelSize: Int
    ) throws -> Data {
        guard let image = try makeImage(
            matrix: matrix,
            appearance: appearance,
            pixelSize: pixelSize
        ) else {
            throw QRCodeError.unreadableImage
        }
        let representation = NSBitmapImageRep(cgImage: image)
        representation.size = NSSize(width: pixelSize, height: pixelSize)
        guard let data = representation.representation(using: .png, properties: [:]) else {
            throw QRCodeError.unreadableImage
        }
        return data
    }

    static func nsImage(
        matrix: QRMatrix,
        appearance: QRAppearance,
        pixelSize: Int
    ) throws -> NSImage {
        guard let image = try makeImage(
            matrix: matrix,
            appearance: appearance,
            pixelSize: pixelSize
        ) else {
            throw QRCodeError.unreadableImage
        }
        return NSImage(cgImage: image, size: NSSize(width: pixelSize, height: pixelSize))
    }

    static func makeImage(
        matrix: QRMatrix,
        appearance: QRAppearance,
        pixelSize: Int
    ) throws -> CGImage? {
        let modulesAcross = matrix.size + appearance.quietZone * 2
        guard pixelSize > 0, modulesAcross > 0 else {
            throw QRCodeError.unreadableImage
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: pixelSize,
            height: pixelSize,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw QRCodeError.unreadableImage
        }

        let module = CGFloat(pixelSize) / CGFloat(modulesAcross)
        let quiet = appearance.quietZone

        context.setFillColor(appearance.background.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize))
        context.setFillColor(appearance.foreground.cgColor)

        let origins = matrix.finderOrigins()

        if appearance.style == .classic {
            context.setShouldAntialias(false)
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
                    let width = CGFloat(column - start)
                    context.fill(
                        CGRect(
                            x: (CGFloat(start) + CGFloat(quiet)) * module,
                            y: (CGFloat(matrix.size - row - 1) + CGFloat(quiet)) * module,
                            width: width * module,
                            height: module
                        )
                    )
                }
            }
        } else {
            context.setShouldAntialias(true)
            for origin in origins {
                drawFinder(
                    context: context,
                    row: origin.row,
                    column: origin.column,
                    matrixSize: matrix.size,
                    quiet: quiet,
                    module: module,
                    foreground: appearance.foreground,
                    background: appearance.background,
                    style: appearance.style
                )
            }

            for row in 0..<matrix.size {
                for column in 0..<matrix.size {
                    guard matrix.isDark(row: row, column: column) else { continue }
                    if isInsideFinder(row: row, column: column, size: matrix.size) { continue }

                    let rect = CGRect(
                        x: (CGFloat(column) + CGFloat(quiet)) * module,
                        y: (CGFloat(matrix.size - row - 1) + CGFloat(quiet)) * module,
                        width: module,
                        height: module
                    )
                    if appearance.style == .dots {
                        let circle = rect.insetBy(dx: module * 0.08, dy: module * 0.08)
                        context.fillEllipse(in: circle)
                    } else {
                        let inset = rect.insetBy(dx: module * 0.025, dy: module * 0.025)
                        let path = CGPath(
                            roundedRect: inset,
                            cornerWidth: module * 0.28,
                            cornerHeight: module * 0.28,
                            transform: nil
                        )
                        context.addPath(path)
                        context.fillPath()
                    }
                }
            }
        }

        return context.makeImage()
    }

    static func svg(
        matrix: QRMatrix,
        appearance: QRAppearance,
        pixelSize: Int = 1024
    ) -> String {
        let quiet = appearance.quietZone
        let total = matrix.size + quiet * 2
        let foreground = appearance.foreground.hexRGB
        let background = appearance.background.hexRGB

        var body = ""
        switch appearance.style {
        case .classic:
            var path = ""
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
                    let length = column - start
                    path += "M\(start + quiet) \(row + quiet)h\(length)v1h-\(length)z"
                }
            }
            body = "<path fill=\"\(foreground)\" d=\"\(path)\"/>"

        case .soft, .dots:
            var shapes = ""
            for row in 0..<matrix.size {
                for column in 0..<matrix.size {
                    guard matrix.isDark(row: row, column: column),
                          !isInsideFinder(row: row, column: column, size: matrix.size) else { continue }
                    let x = Double(column + quiet)
                    let y = Double(row + quiet)
                    if appearance.style == .dots {
                        shapes += "<circle cx=\"\(x + 0.5)\" cy=\"\(y + 0.5)\" r=\"0.42\"/>"
                    } else {
                        shapes += "<rect x=\"\(x + 0.025)\" y=\"\(y + 0.025)\" width=\"0.95\" height=\"0.95\" rx=\"0.28\"/>"
                    }
                }
            }
            for origin in matrix.finderOrigins() {
                shapes += svgFinder(
                    row: origin.row,
                    column: origin.column,
                    quiet: quiet,
                    foreground: foreground,
                    background: background
                )
            }
            body = "<g fill=\"\(foreground)\">\(shapes)</g>"
        }

        let rendering = appearance.style == .classic ? "crispEdges" : "geometricPrecision"
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 \(total) \(total)" width="\(pixelSize)" height="\(pixelSize)" shape-rendering="\(rendering)">
          <rect width="\(total)" height="\(total)" fill="\(background)"/>
          \(body)
        </svg>
        """
    }

    private static func svgFinder(
        row: Int,
        column: Int,
        quiet: Int,
        foreground: String,
        background: String
    ) -> String {
        let x = Double(column + quiet)
        let y = Double(row + quiet)
        return [
            "<rect x=\"\(x)\" y=\"\(y)\" width=\"7\" height=\"7\" rx=\"1.45\" fill=\"\(foreground)\"/>",
            "<rect x=\"\(x + 1)\" y=\"\(y + 1)\" width=\"5\" height=\"5\" rx=\"0.95\" fill=\"\(background)\"/>",
            "<rect x=\"\(x + 2)\" y=\"\(y + 2)\" width=\"3\" height=\"3\" rx=\"0.72\" fill=\"\(foreground)\"/>",
        ].joined()
    }

    private static func drawFinder(
        context: CGContext,
        row: Int,
        column: Int,
        matrixSize: Int,
        quiet: Int,
        module: CGFloat,
        foreground: NSColor,
        background: NSColor,
        style: QRDotStyle
    ) {
        let outer = CGRect(
            x: (CGFloat(column) + CGFloat(quiet)) * module,
            y: (CGFloat(matrixSize - row - 7) + CGFloat(quiet)) * module,
            width: 7 * module,
            height: 7 * module
        )

        context.setFillColor(foreground.cgColor)
        let outerPath = CGPath(
            roundedRect: outer,
            cornerWidth: module * 1.45,
            cornerHeight: module * 1.45,
            transform: nil
        )
        context.addPath(outerPath)
        context.fillPath()

        context.setFillColor(background.cgColor)
        let ring = outer.insetBy(dx: module, dy: module)
        let ringPath = CGPath(
            roundedRect: ring,
            cornerWidth: module * 0.95,
            cornerHeight: module * 0.95,
            transform: nil
        )
        context.addPath(ringPath)
        context.fillPath()

        context.setFillColor(foreground.cgColor)
        let center = outer.insetBy(dx: module * 2, dy: module * 2)
        let centerPath = CGPath(
            roundedRect: center,
            cornerWidth: module * 0.72,
            cornerHeight: module * 0.72,
            transform: nil
        )
        context.addPath(centerPath)
        context.fillPath()
    }

    private static func isInsideFinder(row: Int, column: Int, size: Int) -> Bool {
        if row < 7 && column < 7 { return true }
        if row < 7 && column >= size - 7 { return true }
        if row >= size - 7 && column < 7 { return true }
        return false
    }
}

extension NSColor {
    var hexRGB: String {
        guard let color = usingColorSpace(.sRGB) else { return "#000000" }
        return String(
            format: "#%02X%02X%02X",
            Int(round(color.redComponent * 255)),
            Int(round(color.greenComponent * 255)),
            Int(round(color.blueComponent * 255))
        )
    }
}
