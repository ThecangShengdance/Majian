# 参与开发

## 环境

- macOS 14+
- Xcode 16+
- 不需要 CocoaPods、SwiftPM 或网络依赖

## 本地构建

```bash
git clone https://github.com/ThecangShengdance/Majian.git
cd Majian
./build.sh
```

产物在 `Dist/Majian.app` 和 `Dist/Majian-1.0.0.zip`。如果只想在 Xcode 中运行，打开 `Majian.xcodeproj`，选择 `Majian` scheme。

## 验证

提交前请运行：

```bash
./Tests/verify.sh
```

脚本会编译核心代码，生成 PNG / SVG，并用 Vision 扫码回读。预期结尾为 `ALL PASS`。

## 提交约定

- 一个提交只做一件事，提交信息使用 `feat:`、`fix:`、`docs:`、`test:`、`chore:` 前缀。
- 不提交 `.build/`、`Dist/`、`.work/`、`DerivedData/` 或 `xcuserdata/`。
- 修改协议格式时，同时更新 `Tests/main.swift` 与 README 的协议示例。
- 新增第三方代码必须保留原始版权头，并在 `THIRD_PARTY_NOTICES.md` 中登记许可证。

## 许可

提交即表示同意以 MIT 许可证发布你的贡献。详见 [LICENSE](LICENSE)。
