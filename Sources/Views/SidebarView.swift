import SwiftUI

struct SidebarView: View {
    @ObservedObject var model: MajianModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            brand
                .padding(.horizontal, 20)
                .padding(.top, 46)
                .padding(.bottom, 30)

            SectionLabel(text: "内容类型")
                .padding(.horizontal, 22)
                .padding(.bottom, 9)

            VStack(spacing: 5) {
                ForEach(ContentKind.allCases) { kind in
                    SidebarKindRow(
                        kind: kind,
                        selected: model.kind == kind
                    ) {
                        model.select(kind: kind)
                    }
                }
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 24)

            HStack(spacing: 8) {
                SidebarActionButton(title: "示例", symbol: "wand.and.stars") {
                    model.loadSample()
                }
                SidebarActionButton(title: "清空", symbol: "arrow.counterclockwise") {
                    model.clear()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)

            footer
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
        }
        .frame(width: 238)
        .frame(maxHeight: .infinity)
        .background(
            ZStack {
                Palette.sidebar
                LinearGradient(
                    colors: [Color.white.opacity(0.028), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .ignoresSafeArea(edges: .top)
    }

    private var brand: some View {
        HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Palette.coral)
                    .frame(width: 36, height: 36)
                Image(systemName: "qrcode")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Palette.card)
            }
            .shadow(color: Palette.coral.opacity(0.22), radius: 12, x: 0, y: 5)

            VStack(alignment: .leading, spacing: 1) {
                Text("码笺")
                    .font(MajianFont.display(22))
                    .foregroundStyle(Palette.card)
                Text("QR 工坊")
                    .font(MajianFont.body(9.5, weight: .medium))
                    .tracking(2.2)
                    .foregroundStyle(Palette.sidebarMuted)
            }
            Spacer(minLength: 0)
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Palette.teal.opacity(0.95))
                Text("100% 本机生成")
                    .font(MajianFont.body(10.5, weight: .semibold))
                    .foregroundStyle(Palette.card.opacity(0.86))
                Spacer(minLength: 0)
            }

            Text("内容不会上传到任何服务器。")
                .font(MajianFont.body(9.5))
                .foregroundStyle(Palette.sidebarMuted)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 1)
                .padding(.vertical, 2)

            HStack {
                Text("v1.0.0")
                    .font(MajianFont.mono(9))
                Spacer()
                Text("macOS")
                    .font(MajianFont.mono(9))
            }
            .foregroundStyle(Palette.sidebarMuted.opacity(0.75))
        }
        .padding(13)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.white.opacity(0.035))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(Color.white.opacity(0.055), lineWidth: 1)
        )
    }
}

private struct SidebarKindRow: View {
    let kind: ContentKind
    let selected: Bool
    let action: () -> Void

    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(kind.index)
                    .font(MajianFont.mono(8.5, weight: .medium))
                    .foregroundStyle(selected ? Palette.coral : Palette.sidebarMuted.opacity(0.55))
                    .frame(width: 16, alignment: .leading)

                Image(systemName: kind.symbol)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(selected ? Palette.coral : Palette.sidebarMuted)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.title)
                        .font(MajianFont.body(13, weight: selected ? .semibold : .medium))
                        .foregroundStyle(selected ? Palette.card : Palette.card.opacity(0.72))
                    Text(kind.subtitle)
                        .font(MajianFont.body(9.5))
                        .foregroundStyle(
                            selected
                                ? Palette.sidebarMuted.opacity(0.9)
                                : Palette.sidebarMuted.opacity(0.56)
                        )
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                if selected {
                    Circle()
                        .fill(Palette.coral)
                        .frame(width: 5, height: 5)
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(
                        selected
                            ? Color.white.opacity(0.075)
                            : (hovered ? Color.white.opacity(0.035) : Color.clear)
                    )
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Palette.coral)
                    .frame(width: 2.5, height: 22)
                    .offset(x: -1)
                    .opacity(selected ? 1 : 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}

private struct SidebarActionButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 9.5, weight: .medium))
                Text(title)
                    .font(MajianFont.body(10.5, weight: .medium))
            }
            .foregroundStyle(hovered ? Palette.card : Palette.sidebarMuted)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(hovered ? 0.075 : 0.045))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.055), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
