import Foundation

// MARK: - Content categories

enum ContentKind: String, CaseIterable, Identifiable {
    case numeric
    case text
    case url
    case structured
    case binary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .numeric: return "纯数字"
        case .text: return "文本"
        case .url: return "网址"
        case .structured: return "协议"
        case .binary: return "二进制"
        }
    }

    var subtitle: String {
        switch self {
        case .numeric: return "手机号、订单号、序列号"
        case .text: return "中文、英文、符号、emoji"
        case .url: return "网页、视频、下载链接"
        case .structured: return "tel / wifi / vCard 等"
        case .binary: return "小文件、配置、短脚本"
        }
    }

    var symbol: String {
        switch self {
        case .numeric: return "number"
        case .text: return "text.alignleft"
        case .url: return "link"
        case .structured: return "wave.3.right.circle"
        case .binary: return "doc.badge.gearshape"
        }
    }

    var index: String {
        switch self {
        case .numeric: return "01"
        case .text: return "02"
        case .url: return "03"
        case .structured: return "04"
        case .binary: return "05"
        }
    }

    var headline: String {
        switch self {
        case .numeric: return "一串数字，也能被看见。"
        case .text: return "把一段话，交给一个小小的方块。"
        case .url: return "扫一下，直接抵达。"
        case .structured: return "让扫码器知道下一步该做什么。"
        case .binary: return "把字节原封不动地装进去。"
        }
    }

    var blurb: String {
        switch self {
        case .numeric:
            return "专为电话、订单、序列号与 ID 设计；输入里的空格与连字符会被忽略。"
        case .text:
            return "支持汉字、English、标点与 emoji，内容以 UTF-8 写入二维码。"
        case .url:
            return "输入网页、B 站或下载链接；缺少协议时会自动补上 https://。"
        case .structured:
            return "生成电话、邮件、短信、Wi-Fi、坐标、名片与比特币地址等标准协议内容。"
        case .binary:
            return "读取一个文件的原始字节并写入二维码。仅适合很小的文件。"
        }
    }
}

// MARK: - Structured protocols

enum StructuredKind: String, CaseIterable, Identifiable {
    case phone
    case email
    case sms
    case wifi
    case location
    case contact
    case bitcoin

    var id: String { rawValue }

    var title: String {
        switch self {
        case .phone: return "电话"
        case .email: return "邮件"
        case .sms: return "短信"
        case .wifi: return "Wi-Fi"
        case .location: return "坐标"
        case .contact: return "名片"
        case .bitcoin: return "比特币"
        }
    }

    var prefix: String {
        switch self {
        case .phone: return "tel:"
        case .email: return "mailto:"
        case .sms: return "SMSTO:"
        case .wifi: return "WIFI:"
        case .location: return "geo:"
        case .contact: return "VCARD"
        case .bitcoin: return "bitcoin:"
        }
    }

    var symbol: String {
        switch self {
        case .phone: return "phone.fill"
        case .email: return "envelope.fill"
        case .sms: return "message.fill"
        case .wifi: return "wifi"
        case .location: return "location.fill"
        case .contact: return "person.text.rectangle.fill"
        case .bitcoin: return "bitcoinsign.circle.fill"
        }
    }

    var helper: String {
        switch self {
        case .phone: return "扫码后提示拨打电话。"
        case .email: return "扫码后打开邮件 App，可预填主题与正文。"
        case .sms: return "扫码后打开短信 App，可预填号码与内容。"
        case .wifi: return "扫码后一键连接；密码不会离开本机。"
        case .location: return "扫码后在地图 App 中查看经纬度。"
        case .contact: return "扫码后可直接存入通讯录。"
        case .bitcoin: return "扫码后打开钱包并填入地址与金额。"
        }
    }
}

enum WifiSecurity: String, CaseIterable, Identifiable {
    case wpa = "WPA"
    case wep = "WEP"
    case open = "nopass"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wpa: return "WPA/WPA2"
        case .wep: return "WEP"
        case .open: return "无密码"
        }
    }
}

enum SMSStyle: String, CaseIterable, Identifiable {
    case universal
    case apple

    var id: String { rawValue }

    var title: String {
        switch self {
        case .universal: return "通用 SMSTO"
        case .apple: return "Apple sms:"
        }
    }
}

struct StructuredDraft {
    var kind: StructuredKind = .phone

    // Phone
    var phone = ""

    // Email
    var email = ""
    var emailSubject = ""
    var emailBody = ""

    // SMS
    var smsNumber = ""
    var smsMessage = ""
    var smsStyle: SMSStyle = .universal

    // Wi-Fi
    var wifiSSID = ""
    var wifiPassword = ""
    var wifiSecurity: WifiSecurity = .wpa
    var wifiHidden = false

    // Geo
    var latitude = ""
    var longitude = ""
    var geoLabel = ""

    // vCard
    var fullName = ""
    var organization = ""
    var jobTitle = ""
    var contactPhone = ""
    var contactEmail = ""
    var website = ""
    var street = ""
    var city = ""
    var postalCode = ""
    var country = ""
    var contactNote = ""

    // Bitcoin
    var bitcoinAddress = ""
    var bitcoinAmount = ""
    var bitcoinLabel = ""
    var bitcoinMessage = ""
}

struct BinaryDraft {
    var url: URL?
    var fileName = ""
    var fileSize = 0
    var data: Data?
    var previewHex = ""
    var error: String?

    var isEmpty: Bool { url == nil }
}

struct QRDraft {
    var numeric = ""
    var text = ""
    var url = ""
    var autoHTTPS = true
    var structured = StructuredDraft()
    var binary = BinaryDraft()
}

// MARK: - Error correction and capacity

enum QRCorrection: String, CaseIterable, Identifiable, Codable {
    case low = "L"
    case medium = "M"
    case quartile = "Q"
    case high = "H"

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .low: return "L"
        case .medium: return "M"
        case .quartile: return "Q"
        case .high: return "H"
        }
    }

    var title: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .quartile: return "四分"
        case .high: return "高"
        }
    }

    var recovery: String {
        switch self {
        case .low: return "约 7%"
        case .medium: return "约 15%"
        case .quartile: return "约 25%"
        case .high: return "约 30%"
        }
    }

    var detail: String {
        "可恢复 \(recovery) 的污损；等级越高越可靠，可容纳的内容也越少。"
    }

    var maxNumericCapacity: Int {
        switch self {
        case .low: return 7089
        case .medium: return 5596
        case .quartile: return 3993
        case .high: return 3057
        }
    }

    var maxAlphanumericCapacity: Int {
        switch self {
        case .low: return 4296
        case .medium: return 3391
        case .quartile: return 2420
        case .high: return 1852
        }
    }

    var maxByteCapacity: Int {
        switch self {
        case .low: return 2953
        case .medium: return 2331
        case .quartile: return 1663
        case .high: return 1273
        }
    }
}

enum QRDataMode {
    case numeric
    case alphanumeric
    case byte

    func maxCapacity(for correction: QRCorrection) -> Int {
        switch self {
        case .numeric: return correction.maxNumericCapacity
        case .alphanumeric: return correction.maxAlphanumericCapacity
        case .byte: return correction.maxByteCapacity
        }
    }

    var title: String {
        switch self {
        case .numeric: return "数字模式"
        case .alphanumeric: return "字母数字模式"
        case .byte: return "字节模式"
        }
    }

    var unit: String {
        switch self {
        case .numeric: return "位"
        case .alphanumeric: return "字符"
        case .byte: return "字节"
        }
    }
}

// MARK: - Built payload

struct PayloadResult {
    var data: Data?
    var text: String
    var display: String
    var byteCount: Int
    var mode: QRDataMode
    var isBinary: Bool
    var error: String?
    var warning: String?
    var note: String?

    var isValid: Bool { error == nil && data != nil }

    var usedUnits: Int {
        mode == .byte ? byteCount : text.count
    }

    var modeLabel: String {
        if isBinary { return "原始字节" }
        switch mode {
        case .numeric: return "数字 · UTF-8"
        case .alphanumeric: return "字母数字"
        case .byte: return "UTF-8"
        }
    }

    static var empty: PayloadResult {
        PayloadResult(
            data: nil,
            text: "",
            display: "",
            byteCount: 0,
            mode: .byte,
            isBinary: false,
            error: nil,
            warning: nil,
            note: nil
        )
    }

    static func failure(_ message: String) -> PayloadResult {
        PayloadResult(
            data: nil,
            text: "",
            display: "",
            byteCount: 0,
            mode: .byte,
            isBinary: false,
            error: message,
            warning: nil,
            note: nil
        )
    }

    static func textual(
        _ text: String,
        warning: String? = nil,
        note: String? = nil
    ) -> PayloadResult {
        let data = Data(text.utf8)
        return PayloadResult(
            data: data,
            text: text,
            display: text,
            byteCount: data.count,
            mode: PayloadBuilder.detectMode(text),
            isBinary: false,
            error: nil,
            warning: warning,
            note: note
        )
    }
}

// MARK: - Payload builder

enum PayloadBuilder {
    static func build(kind: ContentKind, draft: QRDraft) -> PayloadResult {
        switch kind {
        case .numeric:
            return buildNumeric(draft.numeric)
        case .text:
            return buildText(draft.text)
        case .url:
            return buildURL(draft.url, autoHTTPS: draft.autoHTTPS)
        case .structured:
            return buildStructured(draft.structured)
        case .binary:
            return buildBinary(draft.binary)
        }
    }

    static func detectMode(_ text: String) -> QRDataMode {
        guard !text.isEmpty else { return .byte }
        let numericScalars = CharacterSet(charactersIn: "0123456789")
        if text.unicodeScalars.allSatisfy({ $0.isASCII && numericScalars.contains($0) }) {
            return .numeric
        }

        let alphanumericSet = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:")
        if text.unicodeScalars.allSatisfy({ $0.isASCII && alphanumericSet.contains($0) }) {
            return .alphanumeric
        }
        return .byte
    }

    // MARK: Basic content

    private static func buildNumeric(_ raw: String) -> PayloadResult {
        let digits = raw.filter { $0.isASCII && $0.isNumber }
        guard !digits.isEmpty else {
            return .failure("请输入数字，例如手机号、订单号或序列号。")
        }

        let removed = raw.count - digits.count
        let note = removed > 0 ? "已忽略 \(removed) 个非数字字符。" : nil
        return .textual(digits, note: note)
    }

    private static func buildText(_ raw: String) -> PayloadResult {
        guard !raw.isEmpty else {
            return .failure("输入一段文字，中文、英文、符号或 emoji 都可以。")
        }
        return .textual(raw)
    }

    private static func buildURL(_ raw: String, autoHTTPS: Bool) -> PayloadResult {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .failure("输入一个网址，例如 bilibili.com 或 https://example.com/file.zip。")
        }
        guard !trimmed.contains(where: { $0.isWhitespace }) else {
            return .failure("网址中不能包含空格；请使用 %20 代替。")
        }

        var candidate = trimmed
        var addedScheme = false
        if !trimmed.contains("://") {
            if autoHTTPS {
                candidate = "https://" + trimmed
                addedScheme = true
            } else {
                return .failure("网址需要以 http:// 或 https:// 开头。")
            }
        }

        guard let components = URLComponents(string: candidate),
              let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = components.host,
              !host.isEmpty else {
            return .failure("这看起来不是一个有效的网址。请检查域名与路径。")
        }

        let note = addedScheme ? "已自动补全 https://。" : nil
        return .textual(candidate, note: note)
    }

    // MARK: Structured content

    private static func buildStructured(_ draft: StructuredDraft) -> PayloadResult {
        switch draft.kind {
        case .phone:
            let raw = draft.phone.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !raw.isEmpty else { return .failure("请输入电话号码。") }
            let number = sanitizePhone(raw)
            guard number.filter({ $0.isNumber }).count >= 3 else {
                return .failure("电话号码至少需要 3 位数字。")
            }
            return .textual("tel:\(number)", note: raw == number ? nil : "已移除空格与装饰符号。")

        case .email:
            let address = draft.email.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !address.isEmpty else { return .failure("请输入收件人邮箱。") }
            guard isValidEmail(address) else { return .failure("邮箱格式看起来不正确。") }

            var payload = "mailto:\(address)"
            var query: [String] = []
            if !draft.emailSubject.isEmpty {
                query.append("subject=\(percentEncode(draft.emailSubject))")
            }
            if !draft.emailBody.isEmpty {
                query.append("body=\(percentEncode(draft.emailBody))")
            }
            if !query.isEmpty {
                payload += "?" + query.joined(separator: "&")
            }
            return .textual(payload)

        case .sms:
            let raw = draft.smsNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !raw.isEmpty else { return .failure("请输入接收短信的号码。") }
            let number = sanitizePhone(raw)
            guard number.filter({ $0.isNumber }).count >= 3 else {
                return .failure("短信号码至少需要 3 位数字。")
            }

            let payload: String
            switch draft.smsStyle {
            case .universal:
                payload = draft.smsMessage.isEmpty
                    ? "SMSTO:\(number)"
                    : "SMSTO:\(number):\(draft.smsMessage)"
            case .apple:
                payload = draft.smsMessage.isEmpty
                    ? "sms:\(number)"
                    : "sms:\(number)?body=\(percentEncode(draft.smsMessage))"
            }

            let note = draft.smsStyle == .universal
                ? "SMSTO 兼容多数安卓扫码器；iPhone 相机可改用 Apple sms: 格式。"
                : "Apple sms: 格式更适合 iPhone / iPad 扫码。"
            return .textual(payload, note: note)

        case .wifi:
            return buildWiFi(draft)

        case .location:
            return buildGeo(draft)

        case .contact:
            return buildVCard(draft)

        case .bitcoin:
            return buildBitcoin(draft)
        }
    }

    private static func buildWiFi(_ draft: StructuredDraft) -> PayloadResult {
        let ssid = draft.wifiSSID
        guard !ssid.isEmpty else { return .failure("请输入 Wi-Fi 名称（SSID）。") }

        if draft.wifiSecurity != .open && draft.wifiPassword.isEmpty {
            return .failure("请输入 Wi-Fi 密码，或将加密方式改为「无密码」。")
        }

        var payload = "WIFI:T:\(draft.wifiSecurity.rawValue);S:\(wifiEscape(ssid));"
        if draft.wifiSecurity != .open {
            payload += "P:\(wifiEscape(draft.wifiPassword));"
        }
        if draft.wifiHidden {
            payload += "H:true;"
        }
        payload += ";"

        var warning: String? = nil
        if draft.wifiSecurity == .wpa {
            let length = draft.wifiPassword.count
            if length < 8 || length > 63 {
                warning = "WPA/WPA2 密码通常是 8–63 个字符，请确认密码是否完整。"
            }
        }
        if draft.wifiHidden {
            warning = [warning, "隐藏网络在部分设备上可能无法直接连接。"].compactMap { $0 }.joined(separator: " ")
        }
        return .textual(payload, warning: warning)
    }

    private static func buildGeo(_ draft: StructuredDraft) -> PayloadResult {
        guard let latitude = parseCoordinate(draft.latitude, limit: 90) else {
            return .failure("纬度需要是 -90 到 90 之间的数字。")
        }
        guard let longitude = parseCoordinate(draft.longitude, limit: 180) else {
            return .failure("经度需要是 -180 到 180 之间的数字。")
        }

        var payload = "geo:\(compactCoordinate(latitude)),\(compactCoordinate(longitude))"
        let label = draft.geoLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !label.isEmpty {
            payload += "?q=\(percentEncode(label))"
        }
        return .textual(payload, note: "部分地图 App 对 geo: 协议的支持不同，必要时可改用地图分享链接。")
    }

    private static func buildVCard(_ draft: StructuredDraft) -> PayloadResult {
        let name = draft.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return .failure("名片至少需要填写姓名。") }

        var lines: [String] = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:;\(vcardEscape(name));;;",
            "FN:\(vcardEscape(name))",
        ]

        if !draft.organization.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("ORG:\(vcardEscape(draft.organization.trimmingCharacters(in: .whitespacesAndNewlines)))")
        }
        if !draft.jobTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("TITLE:\(vcardEscape(draft.jobTitle.trimmingCharacters(in: .whitespacesAndNewlines)))")
        }
        if !draft.contactPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("TEL;TYPE=CELL:\(vcardEscape(draft.contactPhone.trimmingCharacters(in: .whitespacesAndNewlines)))")
        }
        if !draft.contactEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("EMAIL;TYPE=INTERNET:\(vcardEscape(draft.contactEmail.trimmingCharacters(in: .whitespacesAndNewlines)))")
        }

        let addressParts = [draft.street, draft.city, "", draft.postalCode, draft.country]
        if addressParts.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            let escaped = addressParts.map { vcardEscape($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            lines.append("ADR;TYPE=WORK:;;\(escaped[0]);\(escaped[1]);\(escaped[2]);\(escaped[3]);\(escaped[4])")
        }

        var website = draft.website.trimmingCharacters(in: .whitespacesAndNewlines)
        if !website.isEmpty {
            if !website.contains("://") { website = "https://" + website }
            lines.append("URL:\(vcardEscape(website))")
        }
        if !draft.contactNote.isEmpty {
            lines.append("NOTE:\(vcardEscape(draft.contactNote))")
        }
        lines.append("END:VCARD")

        let payload = lines.joined(separator: "\r\n") + "\r\n"
        let hasPhone = !draft.contactPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasEmail = !draft.contactEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let note = (!hasPhone && !hasEmail) ? "名片还没有电话或邮箱，扫码后只会显示姓名与单位。" : nil
        return .textual(payload, note: note)
    }

    private static func buildBitcoin(_ draft: StructuredDraft) -> PayloadResult {
        let address = draft.bitcoinAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else { return .failure("请输入比特币地址。") }
        guard isValidBitcoinAddress(address) else {
            return .failure("地址格式看起来不正确，请核对后重试。")
        }

        var payload = "bitcoin:\(address)"
        var query: [String] = []

        let amountText = draft.bitcoinAmount.trimmingCharacters(in: .whitespacesAndNewlines)
        if !amountText.isEmpty {
            let normalized = amountText.replacingOccurrences(of: ",", with: ".")
            guard let amount = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")),
                  amount > 0 else {
                return .failure("金额需要是大于 0 的数字。")
            }
            let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)
            guard parts.count <= 2, parts.count == 1 || parts[1].count <= 8 else {
                return .failure("比特币金额最多保留 8 位小数。")
            }
            let formatted = compactAmount(amount)
            query.append("amount=\(formatted)")
        }

        let label = draft.bitcoinLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !label.isEmpty {
            query.append("label=\(percentEncode(label))")
        }
        let message = draft.bitcoinMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        if !message.isEmpty {
            query.append("message=\(percentEncode(message))")
        }
        if !query.isEmpty {
            payload += "?" + query.joined(separator: "&")
        }

        return .textual(
            payload,
            warning: "转账前请再次核对地址与金额；二维码本身无法验证地址归属。"
        )
    }

    // MARK: Binary

    private static func buildBinary(_ binary: BinaryDraft) -> PayloadResult {
        if let error = binary.error {
            return .failure(error)
        }
        guard let data = binary.data, binary.url != nil else {
            return .failure("选择一个文件，或把它拖到上方区域。")
        }
        guard !data.isEmpty else {
            return .failure("这个文件是空的。")
        }

        let preview = data.hexPreview
        return PayloadResult(
            data: data,
            text: "",
            display: preview,
            byteCount: data.count,
            mode: .byte,
            isBinary: true,
            error: nil,
            warning: "二进制内容依赖扫码器支持；普通相机可能只显示乱码或无法识别。",
            note: nil
        )
    }

    // MARK: Helpers

    private static let unreserved = CharacterSet.alphanumerics.union(
        CharacterSet(charactersIn: "-._~")
    )

    static func percentEncode(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: unreserved) ?? value
    }

    private static func sanitizePhone(_ raw: String) -> String {
        String(raw.filter { $0.isNumber || $0 == "+" || $0 == "*" || $0 == "#" })
    }

    private static func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$"#
        return value.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private static func wifiEscape(_ value: String) -> String {
        var output = ""
        for character in value {
            if "\\;,:\"".contains(character) {
                output.append("\\")
            }
            output.append(character)
        }
        return output
    }

    private static func vcardEscape(_ value: String) -> String {
        var output = ""
        for character in value {
            switch character {
            case "\\": output += "\\\\"
            case ";": output += "\\;"
            case ",": output += "\\,"
            case "\r": continue
            case "\n": output += "\\n"
            default: output.append(character)
            }
        }
        return output
    }

    private static func parseCoordinate(_ raw: String, limit: Double) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(trimmed), value.isFinite, abs(value) <= limit else {
            return nil
        }
        return value
    }

    private static func compactCoordinate(_ value: Double) -> String {
        var text = String(format: "%.6f", value)
        while text.contains(".") && text.last == "0" {
            text.removeLast()
        }
        if text.last == "." { text.removeLast() }
        return text == "-0" ? "0" : text
    }

    private static func compactAmount(_ amount: Decimal) -> String {
        var text = String(format: "%.8f", NSDecimalNumber(decimal: amount).doubleValue)
        while text.contains(".") && text.last == "0" {
            text.removeLast()
        }
        if text.last == "." { text.removeLast() }
        return text
    }

    private static func isValidBitcoinAddress(_ address: String) -> Bool {
        guard (14...90).contains(address.count),
              !address.contains(where: { $0.isWhitespace }) else {
            return false
        }
        let allowed = CharacterSet.alphanumerics
        guard address.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            return false
        }
        let lower = address.lowercased()
        return address.hasPrefix("1")
            || address.hasPrefix("3")
            || lower.hasPrefix("bc1")
            || lower.hasPrefix("tb1")
            || lower.hasPrefix("bcrt1")
            || address.hasPrefix("m")
            || address.hasPrefix("n")
            || address.hasPrefix("2")
    }
}

// MARK: - Binary file loading

enum BinaryFileLoader {
    /// Files larger than this can never fit into a QR code (byte mode max is 2953 B).
    static let absoluteReadLimit = 4096

    static func load(_ url: URL) -> BinaryDraft {
        var draft = BinaryDraft(url: url, fileName: url.lastPathComponent)

        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed { url.stopAccessingSecurityScopedResource() }
        }

        do {
            let values = try url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
            guard values.isRegularFile == true else {
                draft.error = "请选择一个普通文件，而不是文件夹。"
                return draft
            }
            let size = values.fileSize ?? 0
            draft.fileSize = size

            guard size > 0 else {
                draft.error = "这个文件是空的。"
                return draft
            }

            if size > absoluteReadLimit {
                draft.previewHex = readHead(url, count: 64).hexPreview
                draft.error = "文件 \(formatBytes(size))，超过二维码的最大容量（2,953 字节）。"
                return draft
            }

            let data = try Data(contentsOf: url)
            draft.fileSize = data.count
            draft.data = data
            draft.previewHex = data.hexPreview
            if data.isEmpty {
                draft.error = "这个文件是空的。"
            }
        } catch {
            draft.error = "无法读取文件：\(error.localizedDescription)"
        }
        return draft
    }

    private static func readHead(_ url: URL, count: Int) -> Data {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return Data() }
        defer { try? handle.close() }
        return (try? handle.read(upToCount: count)) ?? Data()
    }

    static func formatBytes(_ count: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(count), countStyle: .file)
    }
}

extension Data {
    var hexPreview: String {
        let limit = 64
        let prefix = self.prefix(limit).map { String(format: "%02X", $0) }.joined(separator: " ")
        return count > limit ? prefix + " …" : prefix
    }
}
