import AppKit
import SwiftUI

// MARK: - Small labels

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 9, weight: .semibold))
            .tracking(1.6)
            .foregroundStyle(Palette.muted)
    }
}

struct ProtocolTag: View {
    let text: String
    var tint: Color = Palette.teal

    var body: some View {
        Text(text)
            .font(MajianFont.mono(10, weight: .medium))
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .frame(height: 20)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(tint.opacity(0.09))
            )
    }
}

struct KeyHint: View {
    let text: String

    var body: some View {
        Text(text)
            .font(MajianFont.mono(9, weight: .medium))
            .foregroundStyle(Palette.muted)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Palette.paperDeep)
            )
    }
}

// MARK: - Inputs

struct MajianTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String?
    var mono = false
    var isSecure = false

    @State private var revealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(MajianFont.body(11, weight: .medium))
                .foregroundStyle(Palette.muted)

            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Palette.muted.opacity(0.8))
                        .frame(width: 14)
                }

                Group {
                    if isSecure && !revealed {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(.plain)
                .font(mono ? MajianFont.mono(13, weight: .medium) : MajianFont.body(13))
                .foregroundStyle(Palette.ink)

                if isSecure {
                    Button {
                        revealed.toggle()
                    } label: {
                        Image(systemName: revealed ? "eye.slash" : "eye")
                            .font(.system(size: 11))
                            .foregroundStyle(Palette.muted)
                    }
                    .buttonStyle(.plain)
                    .help(revealed ? "隐藏密码" : "显示密码")
                }
            }
            .padding(.horizontal, 11)
            .frame(height: 39)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Palette.paper.opacity(0.46))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )
        }
    }
}

struct MajianTextArea: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 88
    var mono = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(MajianFont.body(11, weight: .medium))
                .foregroundStyle(Palette.muted)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(mono ? MajianFont.mono(12) : MajianFont.body(13))
                    .foregroundStyle(Palette.ink)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 6)

                if text.isEmpty {
                    Text(placeholder)
                        .font(MajianFont.body(13))
                        .foregroundStyle(Palette.muted.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .allowsHitTesting(false)
                }
            }
            .frame(minHeight: minHeight)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Palette.paper.opacity(0.46))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )
        }
    }
}

struct MajianToggleRow: View {
    let title: String
    var detail: String?
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MajianFont.body(12.5, weight: .medium))
                    .foregroundStyle(Palette.ink)
                if let detail {
                    Text(detail)
                        .font(MajianFont.body(10.5))
                        .foregroundStyle(Palette.muted)
                }
            }
            Spacer(minLength: 12)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
                .tint(Palette.coral)
        }
        .padding(.horizontal, 11)
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Palette.paper.opacity(0.36))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(Palette.line, lineWidth: 1)
        )
    }
}

// MARK: - Choices

struct ChoicePill: View {
    let title: String
    var detail: String?
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(MajianFont.body(12, weight: selected ? .semibold : .medium))
                if let detail {
                    Text(detail)
                        .font(MajianFont.body(9.5))
                        .opacity(selected ? 0.78 : 0.62)
                }
            }
            .foregroundStyle(selected ? Palette.card : Palette.muted)
            .frame(maxWidth: .infinity)
            .frame(height: detail == nil ? 32 : 44)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(selected ? Palette.ink : Palette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(selected ? Color.clear : Palette.line, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notices

enum NoticeKind {
    case error
    case warning
    case info
    case success

    var color: Color {
        switch self {
        case .error: return Palette.danger
        case .warning: return Palette.amber
        case .info: return Palette.teal
        case .success: return Palette.success
        }
    }

    var background: Color {
        switch self {
        case .error: return Palette.dangerSoft
        case .warning: return Palette.amberSoft
        case .info: return Palette.teal.opacity(0.07)
        case .success: return Palette.success.opacity(0.08)
        }
    }

    var symbol: String {
        switch self {
        case .error: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        }
    }
}

struct NoticeBanner: View {
    let kind: NoticeKind
    var title: String?
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: kind.symbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(kind.color)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                if let title {
                    Text(title)
                        .font(MajianFont.body(11.5, weight: .semibold))
                        .foregroundStyle(kind.color)
                }
                Text(message)
                    .font(MajianFont.body(11))
                    .foregroundStyle(Palette.ink.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
            Spacer(minLength: 0)
        }
        .padding(11)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(kind.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(kind.color.opacity(0.16), lineWidth: 1)
        )
    }
}

// MARK: - Preview metrics

struct MetricRow: View {
    let label: String
    let value: String
    var mono = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(MajianFont.body(11))
                .foregroundStyle(Palette.muted)
            Spacer(minLength: 8)
            Text(value)
                .font(mono ? MajianFont.mono(10.5, weight: .medium) : MajianFont.body(11.5, weight: .medium))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
        }
    }
}

struct CapacityBar: View {
    let fraction: Double
    var warning: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Palette.line.opacity(0.7))
                Capsule()
                    .fill(warning ? Palette.amber : Palette.teal)
                    .frame(
                        width: fraction <= 0
                            ? 0
                            : max(4, geometry.size.width * fraction)
                    )
            }
        }
        .frame(height: 5)
    }
}

// MARK: - Colors

struct ColorSwatchButton: View {
    let hex: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(hex: hex))
                .frame(width: 22, height: 22)
                .overlay(
                    Circle()
                        .strokeBorder(
                            selected ? Palette.coral : Palette.line,
                            lineWidth: selected ? 2 : 1
                        )
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.8), lineWidth: 0.5)
                        .padding(1)
                )
                .padding(2)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .help(hex)
    }
}

// MARK: - Toast

struct ToastOverlay: View {
    let toast: MajianToast

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: toast.kind.symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(toast.kind.tint)
            Text(toast.text)
                .font(MajianFont.body(12, weight: .medium))
                .foregroundStyle(Palette.card)
                .lineLimit(2)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Palette.ink.opacity(0.96))
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.09), lineWidth: 1)
        )
        .shadow(color: Palette.ink.opacity(0.24), radius: 20, x: 0, y: 8)
        .padding(.bottom, 22)
    }
}

// MARK: - Window

struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isMovableByWindowBackground = true
            window.backgroundColor = NSColor(Palette.paper)
            window.appearance = NSAppearance(named: .aqua)
            window.tabbingMode = .disallowed
            window.minSize = NSSize(width: 1120, height: 740)
            window.setContentSize(NSSize(width: 1360, height: 860))
            window.center()
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
