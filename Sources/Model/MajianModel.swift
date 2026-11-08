import AppKit
import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum MajianToastKind {
    case success
    case info
    case error

    var symbol: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .success: return Palette.success
        case .info: return Palette.teal
        case .error: return Palette.danger
        }
    }
}

struct MajianToast: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let kind: MajianToastKind

    static func == (lhs: MajianToast, rhs: MajianToast) -> Bool {
        lhs.id == rhs.id
    }
}

final class MajianModel: ObservableObject {
    @Published var kind: ContentKind = .numeric {
        didSet { rebuild() }
    }

    @Published var draft = QRDraft() {
        didSet { rebuild() }
    }

    @Published var correction: QRCorrection = .quartile {
        didSet { rebuild() }
    }

    @Published var style: QRDotStyle = .classic
    @Published var foregroundHex = Palette.foregroundPresets[0]
    @Published var backgroundHex = Palette.backgroundPresets[0]
    @Published var exportSize = 1024

    @Published private(set) var payload = PayloadResult.empty
    @Published private(set) var matrix: QRMatrix?
    @Published private(set) var generationError: String?
    @Published var toast: MajianToast?

    private var toastWorkItem: DispatchWorkItem?

    init() {
        rebuild()
        applyLaunchDemoIfNeeded()
    }

    // MARK: Derived state

    var foregroundColor: Color { Color(hex: foregroundHex) }
    var backgroundColor: Color { Color(hex: backgroundHex) }

    var appearance: QRAppearance {
        QRAppearance(
            foreground: NSColor(hex: foregroundHex) ?? .black,
            background: NSColor(hex: backgroundHex) ?? .white,
            style: style
        )
    }

    var contrastRatio: CGFloat {
        Color.contrastRatio(foregroundColor, backgroundColor)
    }

    var contrastWarning: String? {
        if foregroundColor.relativeLuminance > backgroundColor.relativeLuminance {
            return "检测到浅色码 / 深色底。部分扫码器只识别深色前景，建议交换前景与背景。"
        }
        if contrastRatio < 3 {
            return String(format: "前景与背景的对比度只有 %.1f:1，可能无法稳定扫描。", contrastRatio)
        }
        if contrastRatio < 7 {
            return String(format: "对比度为 %.1f:1，偏低；打印或远距离扫描时建议提高到 7:1 以上。", contrastRatio)
        }
        return nil
    }

    var capacityFraction: Double {
        let maximum = payload.mode.maxCapacity(for: correction)
        guard maximum > 0 else { return 0 }
        return min(1, Double(payload.usedUnits) / Double(maximum))
    }

    var isNearCapacity: Bool { capacityFraction >= 0.9 }

    var isReady: Bool {
        matrix != nil && generationError == nil && payload.error == nil
    }

    var statusText: String {
        if payload.error != nil || generationError != nil { return "需调整" }
        if matrix != nil { return "可扫描" }
        return "待输入"
    }

    var statusColor: Color {
        if payload.error != nil || generationError != nil { return Palette.danger }
        if matrix != nil { return Palette.success }
        return Palette.muted
    }

    var editorTitle: String {
        switch kind {
        case .numeric: return "输入数字"
        case .text: return "输入文本"
        case .url: return "输入网址"
        case .structured: return "选择协议并填写"
        case .binary: return "选择一个小文件"
        }
    }

    var editorHint: String {
        switch kind {
        case .numeric: return "空格、连字符等非数字字符会被自动忽略。"
        case .text: return "内容以 UTF-8 编码，支持 emoji 与多行文本。"
        case .url: return "支持 http / https；缺少协议时可按开关自动补全。"
        case .structured: return "生成标准协议文本，扫码软件会自动识别并执行。"
        case .binary: return "文件原始字节直接写入二维码，最大 2,953 字节。"
        }
    }

    var contentTitle: String {
        if kind == .structured { return draft.structured.kind.title }
        return kind.title
    }

    var summaryTitle: String {
        if kind == .binary, !draft.binary.fileName.isEmpty { return draft.binary.fileName }
        return contentTitle
    }

    var exportSizeLabel: String { "\(exportSize) × \(exportSize) px" }

    var versionLabel: String {
        guard let matrix else { return "—" }
        return "V\(matrix.version) · \(matrix.size) × \(matrix.size)"
    }

    // MARK: Rebuild

    private func rebuild() {
        let result = PayloadBuilder.build(kind: kind, draft: draft)
        payload = result
        generationError = nil

        guard let data = result.data, result.error == nil else {
            matrix = nil
            return
        }

        let maximum = result.mode.maxCapacity(for: correction)
        if result.usedUnits > maximum {
            matrix = nil
            generationError = "当前内容约 \(result.usedUnits) \(result.mode.unit)，超过 \(correction.rawValue) 级纠错的上限 \(maximum) \(result.mode.unit)。请缩短内容或降低纠错级别。"
            return
        }

        do {
            matrix = try QRCodeEngine.generate(payload: data, correction: correction, text: result.isBinary ? nil : result.text)
        } catch {
            matrix = nil
            generationError = error.localizedDescription
        }
    }

    // MARK: Actions

    func select(kind newKind: ContentKind) {
        guard kind != newKind else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            kind = newKind
        }
    }

    func selectStructured(_ newKind: StructuredKind) {
        withAnimation(.easeInOut(duration: 0.18)) {
            draft.structured.kind = newKind
        }
    }

    func clear() {
        withAnimation(.easeInOut(duration: 0.2)) {
            draft = QRDraft()
            generationError = nil
        }
        showToast("已清空当前内容", kind: .info)
    }

    func loadSample() {
        switch kind {
        case .numeric:
            draft.numeric = "13800000000"
        case .text:
            draft.text = "你好，码笺 👋\n把想法，装进一个小小的方块。"
        case .url:
            draft.url = "https://www.bilibili.com"
            draft.autoHTTPS = true
        case .structured:
            loadStructuredSample()
        case .binary:
            showToast("二进制模式需要选择一个本地文件", kind: .info)
        }
    }

    private func loadStructuredSample() {
        switch draft.structured.kind {
        case .phone:
            draft.structured.phone = "13800000000"
        case .email:
            draft.structured.email = "hello@example.com"
            draft.structured.emailSubject = "来自码笺的问候"
            draft.structured.emailBody = "你好！这是一张用码笺生成的二维码。"
        case .sms:
            draft.structured.smsNumber = "13800000000"
            draft.structured.smsMessage = "你好，我在码笺等你。"
        case .wifi:
            draft.structured.wifiSSID = "Majian Studio"
            draft.structured.wifiPassword = "majian2026"
            draft.structured.wifiSecurity = .wpa
            draft.structured.wifiHidden = false
        case .location:
            draft.structured.latitude = "31.230416"
            draft.structured.longitude = "121.473701"
            draft.structured.geoLabel = "上海 · 外滩"
        case .contact:
            draft.structured.fullName = "张三"
            draft.structured.organization = "示例工作室"
            draft.structured.jobTitle = "独立开发者"
            draft.structured.contactPhone = "13800000000"
            draft.structured.contactEmail = "hello@example.com"
            draft.structured.website = "example.com"
            draft.structured.street = "示例路 1 号"
            draft.structured.city = "上海"
            draft.structured.postalCode = "200000"
            draft.structured.country = "中国"
            draft.structured.contactNote = "扫码认识一下。"
        case .bitcoin:
            draft.structured.bitcoinAddress = "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq"
            draft.structured.bitcoinAmount = "0.001"
            draft.structured.bitcoinLabel = "Majian"
            draft.structured.bitcoinMessage = "感谢支持"
        }
    }

    func loadBinary(_ url: URL) {
        let loaded = BinaryFileLoader.load(url)
        withAnimation(.easeInOut(duration: 0.2)) {
            draft.binary = loaded
        }
        if let error = loaded.error {
            showToast(error, kind: .error)
        }
    }

    func removeBinary() {
        withAnimation(.easeInOut(duration: 0.18)) {
            draft.binary = BinaryDraft()
        }
    }

    func setForeground(_ hex: String) {
        withAnimation(.easeInOut(duration: 0.15)) { foregroundHex = hex }
    }

    func setBackground(_ hex: String) {
        withAnimation(.easeInOut(duration: 0.15)) { backgroundHex = hex }
    }

    // MARK: Export

    func exportPNG() {
        guard let matrix else {
            showToast(generationError ?? "还没有可导出的二维码", kind: .error)
            return
        }
        let panel = NSSavePanel()
        panel.title = "导出 PNG"
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = suggestedFileName(extension: "png")
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let data = try QRCodeRenderer.pngData(
                matrix: matrix,
                appearance: appearance,
                pixelSize: exportSize
            )
            try data.write(to: url, options: .atomic)
            showToast("已导出 \(exportSizeLabel) PNG", kind: .success)
        } catch {
            showToast("导出失败：\(error.localizedDescription)", kind: .error)
        }
    }

    func exportSVG() {
        guard let matrix else {
            showToast(generationError ?? "还没有可导出的二维码", kind: .error)
            return
        }
        let panel = NSSavePanel()
        panel.title = "导出 SVG"
        panel.allowedContentTypes = [.svg]
        panel.nameFieldStringValue = suggestedFileName(extension: "svg")
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }

        let svg = QRCodeRenderer.svg(matrix: matrix, appearance: appearance, pixelSize: exportSize)
        do {
            try Data(svg.utf8).write(to: url, options: .atomic)
            showToast("已导出矢量 SVG", kind: .success)
        } catch {
            showToast("导出失败：\(error.localizedDescription)", kind: .error)
        }
    }

    func copyImage() {
        guard let matrix else {
            showToast(generationError ?? "还没有可复制的二维码", kind: .error)
            return
        }
        do {
            let data = try QRCodeRenderer.pngData(
                matrix: matrix,
                appearance: appearance,
                pixelSize: exportSize
            )
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setData(data, forType: .png)
            showToast("二维码图片已复制", kind: .success)
        } catch {
            showToast("复制失败：\(error.localizedDescription)", kind: .error)
        }
    }

    func copyContent() {
        guard payload.isValid else {
            showToast(payload.error ?? "没有可复制的内容", kind: .error)
            return
        }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        if payload.isBinary, let data = payload.data {
            pasteboard.setString(data.base64EncodedString(), forType: .string)
            showToast("已复制完整数据的 Base64", kind: .success)
        } else {
            pasteboard.setString(payload.text, forType: .string)
            showToast("二维码内容已复制", kind: .success)
        }
    }

    private func suggestedFileName(extension fileExtension: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmm"
        let stamp = formatter.string(from: Date())
        return "Majian-\(kind.rawValue)-\(stamp).\(fileExtension)"
    }

    // MARK: Toast

    func showToast(_ text: String, kind: MajianToastKind = .success) {
        let newToast = MajianToast(text: text, kind: kind)
        toastWorkItem?.cancel()
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            toast = newToast
        }

        let work = DispatchWorkItem { [weak self] in
            guard let self, self.toast?.id == newToast.id else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                self.toast = nil
            }
        }
        toastWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8, execute: work)
    }

    // MARK: Demo launch

    private func applyLaunchDemoIfNeeded() {
        var selectedDemo: String?
        #if DEBUG
        selectedDemo = UserDefaults.standard.string(forKey: "MajianDemoMode")
        #endif
        if selectedDemo?.isEmpty != false {
            selectedDemo = ProcessInfo.processInfo.environment["MAJIAN_DEMO"]
        }
        if selectedDemo?.isEmpty != false,
           let argument = CommandLine.arguments.first(where: { $0.hasPrefix("--demo") }) {
            selectedDemo = argument.split(separator: "=", maxSplits: 1).last.map(String.init) ?? "wifi"
        }
        guard let demo = selectedDemo, !demo.isEmpty else { return }

        switch demo {
        case "text":
            kind = .text
            draft.text = "你好，码笺 👋\n把想法，装进一个小小的方块。"
        case "numeric":
            kind = .numeric
            draft.numeric = "202611081380"
        case "contact":
            kind = .structured
            draft.structured.kind = .contact
            loadStructuredSample()
        case "url":
            kind = .url
            draft.url = "https://www.bilibili.com/video/BV1xx411c7mD"
        default:
            kind = .structured
            draft.structured.kind = .wifi
            draft.structured.wifiSSID = "Majian Studio"
            draft.structured.wifiPassword = "majian2026"
            draft.structured.wifiSecurity = .wpa
        }
        correction = .quartile
        style = .classic
        foregroundHex = "#17181B"
        backgroundHex = "#FFFFFF"
        rebuild()
    }
}
