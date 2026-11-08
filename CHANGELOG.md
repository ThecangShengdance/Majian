# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2026-11-08

### Added

- 五种内容类型：纯数字、文本、网址、结构化协议、任意二进制。
- 七种结构化协议：`tel:`、`mailto:`、`SMSTO:` / `sms:`、`WIFI:`、`geo:`、vCard 3.0、BIP21 比特币。
- L / M / Q / H 四种纠错等级，经典 / 柔和 / 点阵三种模块样式。
- PNG 512 / 1024 / 2048 px 与 SVG 矢量导出，复制图片与复制内容。
- 实时容量、对比度与协议格式提示；4 模块静区；完全离线运行。
- 纯 Swift QR 编码器（Project Nayuki / fwcd，MIT），不依赖 Core Image。
- 无头验证脚本：Vision 扫码回读 5 类内容、7 种协议、4 种纠错和 3 种样式。
- 应用内「第三方许可」入口，MIT 声明随 App 一起分发。

### Changed

- 应用名从开发期代号改为「码笺 / Majian」。
- 示例名片与截图改用 `张三` / `13800000000` / `example.com` 等占位信息。

### Notes

- 二进制模式在 L 级最多 2,953 字节，H 级 1,273 字节；普通相机可能把原始字节显示为乱码，需要最大兼容性时请使用 Base64 文本。
- 当前为 ad-hoc 签名，公开分发未做 Apple 公证；上架 App Store 前需要完成签名、沙盒和商标检索。
