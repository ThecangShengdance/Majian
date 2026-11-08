import AppKit
import Foundation
import Vision

// Headless verification for Majian's payload builder, pure Swift encoder and
// Core Graphics renderer. The resulting PNGs are decoded with Vision, which is
// the same framework macOS uses for camera QR scanning.

struct TestCase {
    let name: String
    let kind: ContentKind
    let correction: QRCorrection
    let configure: (inout QRDraft) -> Void
    let validate: (String?) -> Bool
    let isBinary: Bool

    init(
        _ name: String,
        kind: ContentKind,
        correction: QRCorrection = .quartile,
        isBinary: Bool = false,
        configure: @escaping (inout QRDraft) -> Void,
        validate: @escaping (String?) -> Bool
    ) {
        self.name = name
        self.kind = kind
        self.correction = correction
        self.isBinary = isBinary
        self.configure = configure
        self.validate = validate
    }
}

func exact(_ expected: String) -> (String?) -> Bool {
    { $0 == expected }
}

func contains(_ parts: [String]) -> (String?) -> Bool {
    { decoded in
        guard let decoded else { return false }
        return parts.allSatisfy { decoded.contains($0) }
    }
}

let numeric = "8613800000000"
let text = "你好，Majian 👋 二维码"
let url = "https://www.bilibili.com/video/BV1xx411c7mD"
let wifi = "WIFI:T:WPA;S:Majian Studio;P:majian2026;;"

let cases: [TestCase] = [
    TestCase("纯数字", kind: .numeric, configure: { $0.numeric = numeric }, validate: exact(numeric)),
    TestCase("汉字 emoji", kind: .text, configure: { $0.text = text }, validate: exact(text)),
    TestCase("网址自动补全", kind: .url, configure: {
        $0.url = "www.bilibili.com/video/BV1xx411c7mD"
        $0.autoHTTPS = true
    }, validate: exact(url)),
    TestCase("电话 tel:", kind: .structured, configure: {
        $0.structured.kind = .phone
        $0.structured.phone = "+86 138-0000-0000"
    }, validate: exact("tel:+8613800000000")),
    TestCase("邮件 mailto:", kind: .structured, configure: {
        $0.structured.kind = .email
        $0.structured.email = "hi@example.com"
        $0.structured.emailSubject = "Hello Majian"
        $0.structured.emailBody = "Made on a Mac."
    }, validate: contains(["mailto:hi@example.com", "subject=Hello%20Majian", "body=Made%20on%20a%20Mac."])),
    TestCase("短信 SMSTO:", kind: .structured, configure: {
        $0.structured.kind = .sms
        $0.structured.smsNumber = "13800000000"
        $0.structured.smsMessage = "Hello Majian"
        $0.structured.smsStyle = .universal
    }, validate: exact("SMSTO:13800000000:Hello Majian")),
    TestCase("Wi-Fi", kind: .structured, configure: {
        $0.structured.kind = .wifi
        $0.structured.wifiSSID = "Majian Studio"
        $0.structured.wifiPassword = "majian2026"
        $0.structured.wifiSecurity = .wpa
    }, validate: exact(wifi)),
    TestCase("坐标 geo:", kind: .structured, configure: {
        $0.structured.kind = .location
        $0.structured.latitude = "31.2304"
        $0.structured.longitude = "121.4737"
        $0.structured.geoLabel = "上海外滩"
    }, validate: contains(["geo:31.2304,121.4737", "q=%E4%B8%8A%E6%B5%B7%E5%A4%96%E6%BB%A9"])),
    TestCase("名片 vCard", kind: .structured, configure: {
        $0.structured.kind = .contact
        $0.structured.fullName = "张三"
        $0.structured.organization = "Majian Studio"
        $0.structured.jobTitle = "独立开发者"
        $0.structured.contactPhone = "13800000000"
        $0.structured.contactEmail = "hello@example.com"
        $0.structured.street = "中山东一路"
        $0.structured.city = "上海"
    }, validate: contains(["BEGIN:VCARD", "VERSION:3.0", "FN:张三", "ORG:Majian Studio", "TEL;TYPE=CELL:13800000000", "END:VCARD"])),
    TestCase("比特币 BIP21", kind: .structured, configure: {
        $0.structured.kind = .bitcoin
        $0.structured.bitcoinAddress = "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq"
        $0.structured.bitcoinAmount = "0.00120000"
        $0.structured.bitcoinLabel = "Majian"
    }, validate: exact("bitcoin:bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq?amount=0.0012&label=Majian")),
    TestCase("二进制字节", kind: .binary, isBinary: true, configure: {
        $0.binary.url = URL(fileURLWithPath: "/tmp/majian-bytes.bin")
        $0.binary.fileName = "bytes.bin"
        $0.binary.data = Data([0x00, 0x01, 0x02, 0x03, 0x7F, 0x80, 0xFE, 0xFF, 0x51, 0x52, 0x61, 0x66, 0x74])
        $0.binary.fileSize = 13
    }, validate: { _ in true }),
]

var failures = 0
var pngURLs: [URL] = []

func fail(_ message: String) {
    failures += 1
    print("FAIL \(message)")
}

for testCase in cases {
    var draft = QRDraft()
    testCase.configure(&draft)
    let payload = PayloadBuilder.build(kind: testCase.kind, draft: draft)
    guard let data = payload.data, payload.error == nil, !data.isEmpty else {
        fail("\(testCase.name): \(payload.error ?? "无内容")")
        continue
    }
    if payload.isBinary != testCase.isBinary {
        fail("\(testCase.name): isBinary 标记错误")
        continue
    }

    do {
        let matrix = try QRCodeEngine.generate(
            payload: data,
            correction: testCase.correction,
            text: payload.isBinary ? nil : payload.text
        )
        let appearance = QRAppearance(foreground: .black, background: .white, style: .classic)
        let png = try QRCodeRenderer.pngData(matrix: matrix, appearance: appearance, pixelSize: 720)
        let pngURL = URL(fileURLWithPath: "/tmp/majian-\(testCase.name.replacingOccurrences(of: " ", with: "-")).png")
        try png.write(to: pngURL)
        pngURLs.append(pngURL)

        var decoded: String?
        if !payload.isBinary {
            guard let image = NSImage(data: png),
                  let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                fail("\(testCase.name): 无法读取渲染结果")
                continue
            }
            let request = VNDetectBarcodesRequest()
            request.symbologies = [.qr]
            try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
            decoded = (request.results?.first as? VNBarcodeObservation)?.payloadStringValue
        }

        let passed = testCase.validate(decoded)
        if !passed {
            fail("\(testCase.name): 解码结果 = \(decoded ?? "nil")")
        } else {
            print("PASS \(testCase.name)  v\(matrix.version)  \(matrix.size)×\(matrix.size)  \(payload.byteCount) B")
        }
    } catch {
        fail("\(testCase.name): \(error.localizedDescription)")
    }
}

// Verify every correction level still decodes the same content.
for correction in QRCorrection.allCases {
    let payload = PayloadBuilder.build(kind: .text, draft: QRDraft(text: text))
    guard let data = payload.data else { continue }
    do {
        let matrix = try QRCodeEngine.generate(payload: data, correction: correction, text: payload.text)
        let appearance = QRAppearance(foreground: .black, background: .white, style: .classic)
        let png = try QRCodeRenderer.pngData(matrix: matrix, appearance: appearance, pixelSize: 720)
        guard let image = NSImage(data: png),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fail("纠错 \(correction.rawValue): 无法读取渲染结果")
            continue
        }
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        let decoded = (request.results?.first as? VNBarcodeObservation)?.payloadStringValue
        if decoded == text {
            print("PASS 纠错 \(correction.rawValue)  v\(matrix.version)")
        } else {
            fail("纠错 \(correction.rawValue): 解码结果 = \(decoded ?? "nil")")
        }
    } catch {
        fail("纠错 \(correction.rawValue): \(error.localizedDescription)")
    }
}

// Every module style must survive both PNG and SVG rendering, then decode.
for style in QRDotStyle.allCases {
    let payload = PayloadBuilder.build(kind: .text, draft: QRDraft(text: text))
    guard let data = payload.data,
          let matrix = try? QRCodeEngine.generate(payload: data, correction: .quartile, text: payload.text) else {
        fail("样式 \(style.rawValue): 无法生成矩阵")
        continue
    }
    let appearance = QRAppearance(foreground: .black, background: .white, style: style)

    do {
        let png = try QRCodeRenderer.pngData(matrix: matrix, appearance: appearance, pixelSize: 720)
        guard let image = NSImage(data: png),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fail("样式 \(style.rawValue) PNG: 无法读取")
            continue
        }
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        let decoded = (request.results?.first as? VNBarcodeObservation)?.payloadStringValue
        if decoded == text {
            print("PASS PNG \(style.rawValue)")
        } else {
            fail("样式 \(style.rawValue) PNG: 解码结果 = \(decoded ?? "nil")")
        }
    } catch {
        fail("样式 \(style.rawValue) PNG: \(error.localizedDescription)")
    }

    let svg = QRCodeRenderer.svg(matrix: matrix, appearance: appearance, pixelSize: 2048)
    let hasStyleShape = style == .classic ? svg.contains("<path") : (style == .soft ? svg.contains("<rect x=") : svg.contains("<circle"))
    let svgURL = URL(fileURLWithPath: "/tmp/majian-style-\(style.rawValue).svg")
    do {
        try svg.write(to: svgURL, atomically: true, encoding: .utf8)
        guard svg.hasPrefix("<?xml"), svg.contains("width=\"2048\""), hasStyleShape,
              let image = NSImage(contentsOf: svgURL),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fail("SVG \(style.rawValue): 结构或样式不正确")
            continue
        }
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        let decoded = (request.results?.first as? VNBarcodeObservation)?.payloadStringValue
        if decoded == text {
            print("PASS SVG \(style.rawValue)  \(svg.utf8.count) B")
        } else {
            fail("SVG \(style.rawValue): 解码结果 = \(decoded ?? "nil")")
        }
    } catch {
        fail("SVG \(style.rawValue): \(error.localizedDescription)")
    }
}

// Error paths.
if PayloadBuilder.build(kind: .numeric, draft: QRDraft(numeric: "abc")).error != nil {
    print("PASS 拒绝空数字")
} else {
    fail("空数字未被拒绝")
}

if PayloadBuilder.build(kind: .url, draft: QRDraft(url: "example.com", autoHTTPS: false)).error != nil {
    print("PASS 拒绝缺少 scheme 的网址")
} else {
    fail("缺少 scheme 的网址未被拒绝")
}

let tooLong = String(repeating: "A", count: 3000)
if let data = PayloadBuilder.build(kind: .text, draft: QRDraft(text: tooLong)).data {
    do {
        _ = try QRCodeEngine.generate(payload: data, correction: .high, text: tooLong)
        fail("超容量内容未报错")
    } catch {
        print("PASS 超容量内容被拒绝")
    }
}

print(failures == 0 ? "ALL PASS" : "\(failures) FAILURE(S)")
exit(failures == 0 ? 0 : 1)
