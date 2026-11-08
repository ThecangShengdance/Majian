import SwiftUI
import UniformTypeIdentifiers

struct BinaryEditorView: View {
    @ObservedObject var model: MajianModel
    @State private var showImporter = false
    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if model.draft.binary.url == nil {
                dropZone
            } else {
                fileCard
            }

            NoticeBanner(
                kind: .warning,
                message: "二进制内容没有统一的扫码显示方式。普通相机通常只会显示乱码；请确认你的扫码器支持原始字节，或优先使用文本 / Base64。"
            )
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    model.loadBinary(url)
                }
            case .failure(let error):
                model.showToast("无法打开文件：\(error.localizedDescription)", kind: .error)
            }
        }
    }

    private var dropZone: some View {
        Button {
            showImporter = true
        } label: {
            VStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(isTargeted ? Palette.coralSoft : Palette.paper)
                        .frame(width: 46, height: 46)
                    Image(systemName: isTargeted ? "arrow.down.doc.fill" : "arrow.down.doc")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isTargeted ? Palette.coral : Palette.muted)
                }

                Text(isTargeted ? "松开以载入文件" : "拖入文件，或点击选择")
                    .font(MajianFont.body(13, weight: .semibold))
                    .foregroundStyle(Palette.ink)

                Text("短配置、脚本、二进制片段 · 最大 2,953 字节")
                    .font(MajianFont.body(10))
                    .foregroundStyle(Palette.muted)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 158)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isTargeted ? Palette.coralSoft.opacity(0.45) : Palette.paper.opacity(0.34))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        isTargeted ? Palette.coral : Palette.line,
                        style: StrokeStyle(lineWidth: 1.2, dash: [6, 5])
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            provider.loadItem(
                forTypeIdentifier: UTType.fileURL.identifier,
                options: nil
            ) { item, error in
                guard error == nil else { return }
                var url: URL?
                if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else if let nsURL = item as? NSURL {
                    url = nsURL as URL
                }
                guard let url else { return }
                DispatchQueue.main.async {
                    model.loadBinary(url)
                }
            }
            return true
        }
    }

    private var fileCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Palette.paper)
                        .frame(width: 38, height: 38)
                    Image(systemName: "doc.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Palette.teal)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.draft.binary.fileName)
                        .font(MajianFont.body(12.5, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text("\(BinaryFileLoader.formatBytes(model.draft.binary.fileSize)) · \(model.draft.binary.data?.count ?? 0) 字节可写入")
                        .font(MajianFont.body(9.5))
                        .foregroundStyle(Palette.muted)
                }

                Spacer(minLength: 8)

                Button {
                    showImporter = true
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(IconButtonStyle())
                .help("更换文件")

                Button {
                    model.removeBinary()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(IconButtonStyle())
                .help("移除文件")
            }

            if let error = model.draft.binary.error {
                NoticeBanner(kind: .error, title: "无法使用这个文件", message: error)
            }

            if !model.draft.binary.previewHex.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("原始字节预览")
                            .font(MajianFont.body(9.5, weight: .medium))
                            .foregroundStyle(Palette.muted)
                        Spacer()
                        if let data = model.draft.binary.data {
                            Text("\(data.count) B / 上限 \(model.correction.maxByteCapacity) B")
                                .font(MajianFont.mono(8.5))
                                .foregroundStyle(Palette.muted)
                        }
                    }

                    Text(model.draft.binary.previewHex)
                        .font(MajianFont.mono(9.5))
                        .foregroundStyle(Palette.ink.opacity(0.78))
                        .lineSpacing(4)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Palette.paper.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .strokeBorder(Palette.line, lineWidth: 1)
                )
            }

            if let data = model.draft.binary.data, !data.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("容量")
                            .font(MajianFont.body(9.5))
                            .foregroundStyle(Palette.muted)
                        Spacer()
                        Text("\(Int(min(1, Double(data.count) / Double(max(1, model.correction.maxByteCapacity))) * 100))%")
                            .font(MajianFont.mono(9))
                            .foregroundStyle(Palette.muted)
                    }
                    CapacityBar(
                        fraction: min(1, Double(data.count) / Double(max(1, model.correction.maxByteCapacity))),
                        warning: data.count > model.correction.maxByteCapacity
                    )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Palette.paper.opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .strokeBorder(Palette.line, lineWidth: 1)
        )
    }
}
