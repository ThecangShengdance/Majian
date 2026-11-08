import AppKit
import SwiftUI

enum Palette {
    static let ink = Color(hex: "#17181B")
    static let inkSoft = Color(hex: "#2B2C31")
    static let sidebar = Color(hex: "#141518")
    static let sidebarMuted = Color(hex: "#8D8B85")
    static let paper = Color(hex: "#F3EEE3")
    static let paperDeep = Color(hex: "#E9E1D2")
    static let card = Color(hex: "#FFFCF6")
    static let line = Color(hex: "#E2D8C7")
    static let muted = Color(hex: "#797265")
    static let coral = Color(hex: "#E9553B")
    static let coralSoft = Color(hex: "#FBE3DB")
    static let teal = Color(hex: "#1E5F59")
    static let amber = Color(hex: "#A96D16")
    static let amberSoft = Color(hex: "#FAEFD8")
    static let danger = Color(hex: "#B93C2E")
    static let dangerSoft = Color(hex: "#FBE5E1")
    static let success = Color(hex: "#2F7A57")
    static let white = Color.white

    static let foregroundPresets: [String] = [
        "#17181B", "#1E3A5F", "#173F35", "#5A1F2B", "#3A2A5A", "#7A3B12",
    ]

    static let backgroundPresets: [String] = [
        "#FFFFFF", "#FBF6EC", "#F3F6F2",
    ]
}

enum MajianFont {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func heading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        switch cleaned.count {
        case 8:
            red = Double((value >> 24) & 0xFF) / 255
            green = Double((value >> 16) & 0xFF) / 255
            blue = Double((value >> 8) & 0xFF) / 255
            alpha = Double(value & 0xFF) / 255
        case 6:
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255
            alpha = 1
        default:
            red = 0
            green = 0
            blue = 0
            alpha = 1
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    var hexString: String {
        guard let color = NSColor(self).usingColorSpace(.sRGB) else { return "#000000" }
        return String(
            format: "#%02X%02X%02X",
            Int(round(color.redComponent * 255)),
            Int(round(color.greenComponent * 255)),
            Int(round(color.blueComponent * 255))
        )
    }

    /// Relative luminance of the sRGB color, used for the QR contrast check.
    var relativeLuminance: CGFloat {
        guard let color = NSColor(self).usingColorSpace(.sRGB) else { return 0 }
        func linear(_ component: CGFloat) -> CGFloat {
            component <= 0.04045 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(color.redComponent)
            + 0.7152 * linear(color.greenComponent)
            + 0.0722 * linear(color.blueComponent)
    }

    /// WCAG contrast ratio (1...21).
    static func contrastRatio(_ foreground: Color, _ background: Color) -> CGFloat {
        let light = max(foreground.relativeLuminance, background.relativeLuminance)
        let dark = min(foreground.relativeLuminance, background.relativeLuminance)
        return (light + 0.05) / (dark + 0.05)
    }
}

extension NSColor {
    convenience init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else { return nil }
        self.init(
            srgbRed: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}

struct CardSurface: ViewModifier {
    var padding: CGFloat
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Palette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )
            .shadow(color: Palette.ink.opacity(0.045), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func majianCard(padding: CGFloat = 22, radius: CGFloat = 20) -> some View {
        modifier(CardSurface(padding: padding, radius: radius))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = Palette.ink

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MajianFont.body(14, weight: .semibold))
            .foregroundStyle(Palette.card)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(configuration.isPressed ? color.opacity(0.82) : color)
            )
            .contentShape(Rectangle())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MajianFont.body(13, weight: .medium))
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(configuration.isPressed ? Palette.paperDeep : Palette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )
            .contentShape(Rectangle())
    }
}

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Palette.muted)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Palette.paperDeep : Palette.card)
            )
            .overlay(Circle().strokeBorder(Palette.line, lineWidth: 1))
            .contentShape(Circle())
    }
}

struct SelectionPillStyle: ButtonStyle {
    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MajianFont.body(12, weight: selected ? .semibold : .medium))
            .foregroundStyle(selected ? Palette.card : Palette.muted)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(
                Capsule()
                    .fill(
                        selected
                            ? Palette.ink
                            : (configuration.isPressed ? Palette.paperDeep : Palette.card)
                    )
            )
            .overlay(
                Capsule()
                    .strokeBorder(selected ? Color.clear : Palette.line, lineWidth: 1)
            )
            .contentShape(Capsule())
    }
}

struct SoftDivider: View {
    var body: some View {
        Rectangle()
            .fill(Palette.line)
            .frame(height: 1)
    }
}
