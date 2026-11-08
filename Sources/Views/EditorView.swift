import SwiftUI

struct EditorView: View {
    @ObservedObject var model: MajianModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                editorCard
                SettingsCard(model: model)
                footnote
            }
            .padding(.top, 46)
            .padding(.horizontal, 30)
            .padding(.bottom, 34)
            .frame(maxWidth: 760, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .background(Palette.paper)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 6) {
                    Text("新建二维码")
                        .font(MajianFont.body(9.5, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(Palette.muted)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(Palette.muted.opacity(0.5))
                    Text(model.contentTitle)
                        .font(MajianFont.body(9.5, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(Palette.coral)
                }

                Text(model.kind.headline)
                    .font(MajianFont.display(29))
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text(model.kind.blurb)
                    .font(MajianFont.body(14))
                    .foregroundStyle(Palette.muted)
                    .lineSpacing(3.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 510, alignment: .leading)
            }

            Spacer(minLength: 0)

            StatusBadge(
                text: model.statusText,
                color: model.statusColor
            )
            .padding(.top, 2)
        }
    }

    private var editorCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Palette.coralSoft)
                        .frame(width: 34, height: 34)
                    Image(systemName: editorSymbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Palette.coral)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(editorTitle)
                        .font(MajianFont.heading(14))
                        .foregroundStyle(Palette.ink)
                    Text(model.editorHint)
                        .font(MajianFont.body(10.5))
                        .foregroundStyle(Palette.muted)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text("\(model.payload.byteCount) B")
                    .font(MajianFont.mono(9.5, weight: .medium))
                    .foregroundStyle(Palette.muted)
                    .padding(.horizontal, 7)
                    .frame(height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Palette.paper)
                    )
            }

            Rectangle()
                .fill(Palette.line.opacity(0.7))
                .frame(height: 1)

            editorContent
        }
        .majianCard(padding: 20, radius: 18)
    }

    private var editorSymbol: String {
        model.kind == .structured
            ? model.draft.structured.kind.symbol
            : model.kind.symbol
    }

    private var editorTitle: String {
        if model.kind == .structured {
            return "\(model.draft.structured.kind.title) 设置"
        }
        return model.editorTitle
    }

    @ViewBuilder
    private var editorContent: some View {
        switch model.kind {
        case .numeric:
            numericEditor
        case .text:
            textEditor
        case .url:
            urlEditor
        case .structured:
            StructuredEditorView(model: model)
        case .binary:
            BinaryEditorView(model: model)
        }
    }

    // MARK: Numeric

    private var numericEditor: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 10) {
                Image(systemName: "number")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Palette.muted.opacity(0.7))
                    .frame(width: 18)

                TextField("例如 13800000000", text: $model.draft.numeric)
                    .textFieldStyle(.plain)
                    .font(MajianFont.mono(21, weight: .semibold))
                    .foregroundStyle(Palette.ink)

                if !model.draft.numeric.isEmpty {
                    Button {
                        model.draft.numeric = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.muted.opacity(0.55))
                    }
                    .buttonStyle(.plain)
                    .help("清空数字")
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Palette.paper.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )

            if let note = model.payload.note {
                Label(note, systemImage: "sparkles")
                    .font(MajianFont.body(10.5))
                    .foregroundStyle(Palette.amber)
            } else if let error = model.payload.error {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(MajianFont.body(10.5))
                    .foregroundStyle(Palette.danger)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                HStack(spacing: 6) {
                    Text("扫描结果")
                        .font(MajianFont.body(10.5))
                        .foregroundStyle(Palette.muted)
                    Text(model.payload.text)
                        .font(MajianFont.mono(11, weight: .medium))
                        .foregroundStyle(Palette.teal)
                        .lineLimit(1)
                    Spacer()
                    Text("\(model.draft.numeric.filter(\.isNumber).count) 位")
                        .font(MajianFont.mono(9.5))
                        .foregroundStyle(Palette.muted)
                }
            }

            HStack(spacing: 6) {
                ExampleChip(title: "手机号") { model.draft.numeric = "13800000000" }
                ExampleChip(title: "订单号") { model.draft.numeric = "202611080001" }
                ExampleChip(title: "序列号") { model.draft.numeric = "8691200450017" }
                ExampleChip(title: "ID") { model.draft.numeric = "100086" }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: Text

    private var textEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            MajianTextArea(
                title: "文本内容",
                placeholder: "例如：你好，世界 👋",
                text: $model.draft.text,
                minHeight: 128
            )

            HStack(spacing: 6) {
                Text("插入")
                    .font(MajianFont.body(10))
                    .foregroundStyle(Palette.muted)
                ForEach(["👋", "✨", "🎉", "❤️", "📍", "🔗"], id: \.self) { emoji in
                    Button {
                        model.draft.text.append(emoji)
                    } label: {
                        Text(emoji)
                            .font(.system(size: 13))
                            .frame(width: 25, height: 25)
                            .background(
                                Circle()
                                    .fill(Palette.paper.opacity(0.65))
                            )
                            .overlay(Circle().strokeBorder(Palette.line, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Text("\(model.draft.text.count) 字符 · \(model.payload.byteCount) 字节")
                    .font(MajianFont.mono(9.5))
                    .foregroundStyle(Palette.muted)
            }

            HStack(spacing: 6) {
                ExampleChip(title: "一句话") {
                    model.draft.text = "你好，码笺 👋\n把想法，装进一个小小的方块。"
                }
                ExampleChip(title: "中文") {
                    model.draft.text = "山有木兮木有枝，心悦君兮君不知。"
                }
                ExampleChip(title: "多行") {
                    model.draft.text = "第一行：你好\n第二行：Majian\n第三行：👋"
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: URL

    private var urlEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "globe")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Palette.muted.opacity(0.7))
                    .frame(width: 18)

                TextField("bilibili.com 或 https://…", text: $model.draft.url)
                    .textFieldStyle(.plain)
                    .font(MajianFont.body(14.5, weight: .medium))
                    .foregroundStyle(Palette.ink)

                if !model.draft.url.isEmpty {
                    Button {
                        model.draft.url = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.muted.opacity(0.55))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 13)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Palette.paper.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )

            MajianToggleRow(
                title: "自动补全 https://",
                detail: "输入 bilibili.com 时自动生成完整网址",
                isOn: $model.draft.autoHTTPS
            )

            if let error = model.payload.error {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(MajianFont.body(10.5))
                    .foregroundStyle(Palette.danger)
                    .fixedSize(horizontal: false, vertical: true)
            } else if let note = model.payload.note {
                Label(note, systemImage: "wand.and.stars")
                    .font(MajianFont.body(10.5))
                    .foregroundStyle(Palette.amber)
            } else if !model.payload.text.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8, weight: .bold))
                    Text(model.payload.text)
                        .font(MajianFont.mono(10, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .foregroundStyle(Palette.teal)
            }

            HStack(spacing: 6) {
                ExampleChip(title: "B 站") { model.draft.url = "https://www.bilibili.com" }
                ExampleChip(title: "GitHub") { model.draft.url = "https://github.com" }
                ExampleChip(title: "Apple") { model.draft.url = "https://www.apple.com" }
                ExampleChip(title: "下载链接") {
                    model.draft.url = "https://example.com/download/majian.zip"
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var footnote: some View {
        HStack(spacing: 7) {
            Image(systemName: "info.circle")
                .font(.system(size: 9.5))
            Text("二维码四周会自动保留 4 个模块的静区；导出 PNG 时按 \(model.exportSizeLabel) 渲染。")
                .font(MajianFont.body(10))
        }
        .foregroundStyle(Palette.muted.opacity(0.86))
        .padding(.horizontal, 2)
    }
}

// MARK: - Status

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
                .shadow(color: color.opacity(0.5), radius: 4)
            Text(text)
                .font(MajianFont.body(10, weight: .semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 9)
        .frame(height: 25)
        .background(
            Capsule()
                .fill(Palette.card)
        )
        .overlay(
            Capsule()
                .strokeBorder(Palette.line, lineWidth: 1)
        )
    }
}

// MARK: - Example chip

struct ExampleChip: View {
    let title: String
    let action: () -> Void

    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MajianFont.body(10, weight: .medium))
                .foregroundStyle(hovered ? Palette.ink : Palette.muted)
                .padding(.horizontal, 9)
                .frame(height: 25)
                .background(
                    Capsule()
                        .fill(hovered ? Palette.paperDeep : Palette.card)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Palette.line, lineWidth: 1)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}

// MARK: - Settings

struct SettingsCard: View {
    @ObservedObject var model: MajianModel

    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("扫描设置")
                        .font(MajianFont.heading(14))
                        .foregroundStyle(Palette.ink)
                    Text("修改会立即应用到预览与导出。")
                        .font(MajianFont.body(10.5))
                        .foregroundStyle(Palette.muted)
                }
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Palette.muted.opacity(0.7))
            }

            Rectangle()
                .fill(Palette.line.opacity(0.7))
                .frame(height: 1)

            correctionSetting
            styleSetting
            colorSetting

            HStack(spacing: 7) {
                Image(systemName: model.contrastWarning == nil ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                    .font(.system(size: 10.5, weight: .semibold))
                Text(model.contrastWarning ?? "对比度适合扫描，深色前景配浅色背景最稳妥。")
                    .font(MajianFont.body(10.5))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Text(String(format: "%.1f:1", model.contrastRatio))
                    .font(MajianFont.mono(10, weight: .medium))
            }
            .foregroundStyle(model.contrastWarning == nil ? Palette.success : Palette.amber)
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(
                        model.contrastWarning == nil
                            ? Palette.success.opacity(0.06)
                            : Palette.amberSoft
                    )
            )
        }
        .majianCard(padding: 20, radius: 18)
    }

    private var correctionSetting: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("纠错等级")
                    .font(MajianFont.body(11.5, weight: .medium))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Text("\(model.correction.title) · 可恢复 \(model.correction.recovery)")
                    .font(MajianFont.body(10))
                    .foregroundStyle(Palette.muted)
            }

            HStack(spacing: 7) {
                ForEach(QRCorrection.allCases) { level in
                    ChoicePill(
                        title: "\(level.rawValue) · \(level.title)",
                        detail: level.recovery,
                        selected: model.correction == level
                    ) {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            model.correction = level
                        }
                    }
                }
            }
        }
    }

    private var styleSetting: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("模块样式")
                    .font(MajianFont.body(11.5, weight: .medium))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Text(model.style.detail)
                    .font(MajianFont.body(9.5))
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
            }

            HStack(spacing: 7) {
                ForEach(QRDotStyle.allCases) { style in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            model.style = style
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: styleSymbol(style))
                                .font(.system(size: 10, weight: .medium))
                            Text(style.title)
                                .font(MajianFont.body(11, weight: model.style == style ? .semibold : .medium))
                        }
                        .foregroundStyle(model.style == style ? Palette.card : Palette.muted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(model.style == style ? Palette.ink : Palette.card)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(
                                    model.style == style ? Color.clear : Palette.line,
                                    lineWidth: 1
                                )
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var colorSetting: some View {
        HStack(alignment: .top, spacing: 18) {
            ColorControl(
                title: "前景色",
                hex: model.foregroundHex,
                presets: Palette.foregroundPresets
            ) { hex in
                model.setForeground(hex)
            }

            Rectangle()
                .fill(Palette.line)
                .frame(width: 1, height: 52)
                .padding(.top, 4)

            ColorControl(
                title: "背景色",
                hex: model.backgroundHex,
                presets: Palette.backgroundPresets
            ) { hex in
                model.setBackground(hex)
            }
        }
    }

    private func styleSymbol(_ style: QRDotStyle) -> String {
        switch style {
        case .classic: return "square.grid.3x3.fill"
        case .soft: return "square.grid.3x3.topleft.filled"
        case .dots: return "circle.grid.3x3.fill"
        }
    }
}

struct ColorControl: View {
    let title: String
    let hex: String
    let presets: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Text(title)
                    .font(MajianFont.body(10.5, weight: .medium))
                    .foregroundStyle(Palette.ink)
                Text(hex.uppercased())
                    .font(MajianFont.mono(8.5))
                    .foregroundStyle(Palette.muted)
            }

            HStack(spacing: 4) {
                ForEach(presets, id: \.self) { preset in
                    ColorSwatchButton(
                        hex: preset,
                        selected: hex.uppercased() == preset.uppercased()
                    ) {
                        onSelect(preset)
                    }
                }

                ColorPicker(
                    "",
                    selection: Binding(
                        get: { Color(hex: hex) },
                        set: { onSelect($0.hexString) }
                    ),
                    supportsOpacity: false
                )
                .labelsHidden()
                .frame(width: 27, height: 24)
                .help("自定义颜色")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
