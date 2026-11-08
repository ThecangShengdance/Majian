import SwiftUI

struct PreviewRail: View {
    @ObservedObject var model: MajianModel

    private let previewSide: CGFloat = 250

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 10) {
                header
                previewCard

                if let generationError = model.generationError {
                    NoticeBanner(
                        kind: .error,
                        title: "无法生成",
                        message: generationError
                    )
                } else if let error = model.payload.error {
                    NoticeBanner(
                        kind: .error,
                        title: "还差一点",
                        message: error
                    )
                }

                metricsCard

                if let warning = model.payload.warning {
                    NoticeBanner(kind: .warning, title: "请留意", message: warning)
                }

                if let contrastWarning = model.contrastWarning {
                    NoticeBanner(kind: .warning, message: contrastWarning)
                } else if let note = model.payload.note {
                    NoticeBanner(kind: .info, message: note)
                }

                exportCard

                HStack(spacing: 5) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                    Text("本机生成 · 内容不会离开这台 Mac")
                        .font(MajianFont.body(9.5))
                }
                .foregroundStyle(Palette.muted.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.top, 1)
            }
            .padding(.top, 46)
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
        }
        .scrollIndicators(.hidden)
        .frame(width: 388)
        .frame(maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Palette.paperDeep.opacity(0.72),
                    Palette.paperDeep.opacity(0.36),
                    Palette.paper,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Palette.line.opacity(0.8))
                .frame(width: 1)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("实时预览")
                    .font(MajianFont.heading(16))
                    .foregroundStyle(Palette.ink)
                Text("所见即所得，改动立即生效")
                    .font(MajianFont.body(10))
                    .foregroundStyle(Palette.muted)
            }
            Spacer()
            HStack(spacing: 5) {
                Circle()
                    .fill(model.isReady ? Palette.success : Palette.muted.opacity(0.5))
                    .frame(width: 5, height: 5)
                Text(model.isReady ? "实时" : "等待")
                    .font(MajianFont.body(9.5, weight: .semibold))
                    .foregroundStyle(model.isReady ? Palette.success : Palette.muted)
            }
            .padding(.horizontal, 8)
            .frame(height: 23)
            .background(Capsule().fill(Palette.card))
            .overlay(Capsule().strokeBorder(Palette.line, lineWidth: 1))
        }
    }

    private var previewCard: some View {
        VStack(spacing: 10) {
            if let matrix = model.matrix {
                QRPreviewCanvas(matrix: matrix, appearance: model.appearance)
                    .frame(width: previewSide, height: previewSide)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(Palette.line.opacity(0.65), lineWidth: 1)
                    )
                    .shadow(color: Palette.ink.opacity(0.06), radius: 10, x: 0, y: 5)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            } else {
                emptyPreview
                    .frame(width: previewSide, height: previewSide)
                    .frame(maxWidth: .infinity)
            }

            HStack {
                Text(model.style.title)
                    .font(MajianFont.body(9.5, weight: .medium))
                    .foregroundStyle(Palette.muted)
                Text("·")
                    .foregroundStyle(Palette.muted.opacity(0.5))
                Text("静区 4")
                    .font(MajianFont.body(9.5))
                    .foregroundStyle(Palette.muted)
                Spacer()
                Text(model.versionLabel)
                    .font(MajianFont.mono(8.5))
                    .foregroundStyle(Palette.muted.opacity(0.8))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Palette.line, lineWidth: 1)
        )
        .shadow(color: Palette.ink.opacity(0.07), radius: 22, x: 0, y: 12)
    }

    private var emptyPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Palette.paper.opacity(0.65))

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Palette.card)
                        .frame(width: 58, height: 58)
                    Image(systemName: "qrcode")
                        .font(.system(size: 27, weight: .light))
                        .foregroundStyle(Palette.muted.opacity(0.55))
                }
                Text("等待内容")
                    .font(MajianFont.body(11, weight: .medium))
                    .foregroundStyle(Palette.muted)
                Text("在左侧输入后，二维码会出现在这里")
                    .font(MajianFont.body(9.5))
                    .foregroundStyle(Palette.muted.opacity(0.7))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(
                    Palette.line,
                    style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                )
        )
    }

    private var metricsCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            MetricRow(label: "内容", value: model.summaryTitle)
            MetricRow(label: "数据模式", value: "\(model.payload.modeLabel) · \(model.payload.byteCount) B")
            MetricRow(
                label: "纠错等级",
                value: "\(model.correction.rawValue) · \(model.correction.recovery)"
            )

            Rectangle()
                .fill(Palette.line.opacity(0.65))
                .frame(height: 1)
                .padding(.vertical, 2)

            HStack {
                Text("容量")
                    .font(MajianFont.body(10))
                    .foregroundStyle(Palette.muted)
                Spacer()
                Text("\(model.payload.usedUnits) / \(model.payload.mode.maxCapacity(for: model.correction)) \(model.payload.mode.unit)")
                    .font(MajianFont.mono(9, weight: .medium))
                    .foregroundStyle(model.isNearCapacity ? Palette.amber : Palette.muted)
            }

            CapacityBar(
                fraction: model.capacityFraction,
                warning: model.isNearCapacity
            )
        }
        .majianCard(padding: 12, radius: 14)
    }

    private var exportCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("导出")
                    .font(MajianFont.heading(12.5))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Text("PNG / SVG")
                    .font(MajianFont.mono(8.5))
                    .foregroundStyle(Palette.muted)
            }

            HStack(spacing: 6) {
                ForEach([512, 1024, 2048], id: \.self) { size in
                    ChoicePill(
                        title: "\(size)",
                        selected: model.exportSize == size
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            model.exportSize = size
                        }
                    }
                }
            }

            Button {
                model.exportPNG()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 11, weight: .semibold))
                    Text("导出 PNG")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!model.isReady)
            .opacity(model.isReady ? 1 : 0.45)

            Button {
                model.exportSVG()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 11, weight: .semibold))
                    Text("导出 SVG 矢量图")
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(!model.isReady)
            .opacity(model.isReady ? 1 : 0.45)

            HStack(spacing: 7) {
                CopyActionButton(title: "复制图片", symbol: "doc.on.doc") {
                    model.copyImage()
                }
                CopyActionButton(title: "复制内容", symbol: "text.quote") {
                    model.copyContent()
                }
            }
            .opacity(model.isReady ? 1 : 0.45)
            .disabled(!model.isReady)
        }
        .majianCard(padding: 12, radius: 14)
    }
}

private struct CopyActionButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 9, weight: .medium))
                Text(title)
                    .font(MajianFont.body(10, weight: .medium))
            }
            .foregroundStyle(hovered ? Palette.ink : Palette.muted)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(hovered ? Palette.paperDeep : Palette.paper.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
