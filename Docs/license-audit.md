# 码笺（Majian）代码许可审查

日期：2026-11-08  
范围：`/Users/zhangzhouqi/Documents/WorkSpace/Xcode/Majian` 本地源码、资源、构建脚本与 `Dist/Majian.app` 分发包。

> 这是一次工程侧的静态许可审查，不是法律意见；正式商用/上架前建议由律师做 FTO 与商标检索。

## 结论

| 项目 | 结论 | 风险 |
| --- | --- | --- |
| GPL / AGPL / LGPL / MPL 代码 | 本次静态审查未发现 | 低 |
| 第三方依赖 | 仅 Apple 系统框架；无 SPM/CocoaPods/Carthage 依赖 | 低 |
| 内置 QR 编码器 | MIT（Project Nayuki / fwcd），8 个文件均保留完整 MIT 头 | 合规 |
| MIT 声明随二进制分发 | 已随 app 附带，菜单可打开 | 已处理 |
| 应用自身许可 | MIT，仓库根目录有 `LICENSE` | 合规 |
| 原 “Qraft” 名称 | 已弃用，改为「码笺 / Majian」 | 已处理 |
| 示例名片/截图隐私 | 已全部替换为占位数据 | 已处理 |
| 新名称商标 | 初步检索未发现同名二维码应用；未做正式全类检索 | 中，建议上架前处理 |

**一句话：代码里没有引入 GPL/AGPL；原来的 Qraft 名称和示例隐私都已改掉；新名称「码笺」仍建议在上架前做一次正式商标检索。**

## 审查方法与证据

- 扫描 22 个 Swift 文件（5,975 行，含测试），检索 `GPL`、`AGPL`、`LGPL`、`GNU`、`Copyleft`、`MPL`、`Apache`、`BSD`、`Copyright`、`SPDX` 等标记。
- 检查所有 `import`：`AppKit`、`Combine`、`CoreGraphics`、`Foundation`、`SwiftUI`、`UniformTypeIdentifiers`、`Vision`，全部为 Apple 系统框架。
- 检查 `Majian.xcodeproj/project.pbxproj`：`packageProductDependencies` 为空，无远程包引用。
- 检查 `otool -L Dist/Majian.app/Contents/MacOS/Majian`：只链接 `/System/Library/Frameworks` 与 `/usr/lib/swift`，没有第三方动态库。
- 逐一读取 `Sources/Core/Vendor/*.swift` 的文件头；8 个文件均带 Project Nayuki + fwcd 的完整 MIT 许可文本。
- 从上游 `https://raw.githubusercontent.com/fwcd/swift-qrcode-generator/master/LICENSE` 重新获取许可证，确认与本地声明一致（MIT）。
- 检查 `Assets.xcassets`：仅 `AppIcon` 与 `AccentColor`；应用图标由本地脚本生成，没有打包第三方图片或字体。

## 详细发现

### 1. 没有 GPL / AGPL 代码

在源码、测试、资源与工程文件中未发现 GPL/AGPL/LGPL/MPL 许可证文本或 SPDX 标记，也没有从这些项目引入的依赖。

需要说明：静态关键词扫描不能像代码溯源工具那样证明“每一行都绝对原创”。但本项目没有第三方包、没有外部源码目录，QR 算法部分又明确来自 MIT 的上游项目，因此出现未声明 copyleft 代码的可能性很低。

### 2. 内置 QR 编码器是 MIT，署名完整

`Sources/Core/Vendor/` 下 8 个文件来自：

- https://github.com/fwcd/swift-qrcode-generator
- 原始库：https://www.nayuki.io/page/qr-code-generator-library

上游为 MIT。每个文件都保留了原始版权与许可头；`THIRD_PARTY_NOTICES.md` 也附了完整 MIT 文本。项目只把上游的 `QRCodeError` 重命名为 `QRGeneratorError`，避免与渲染层同名类型冲突，算法未改；这一点已在 notices 中注明。

MIT 允许闭源、商用、修改和再分发，只要保留版权与许可声明。当前源码分发满足这一条件。

### 3. 分发包已附带 MIT 声明

`build.sh:27-36` 在签名前把 `LICENSE` 与 `THIRD_PARTY_NOTICES.md` 复制进 `Majian.app/Contents/Resources/`，并校验签名。菜单「码笺 → 第三方许可」通过 `Sources/App/MajianApp.swift:71-80` 打开包内 notices。

分发包内包含：

```
Majian.app/Contents/Resources/LICENSE
Majian.app/Contents/Resources/THIRD_PARTY_NOTICES.md
```

### 4. Apple 框架与系统资源

SwiftUI、AppKit、Vision 等是 Apple SDK 的一部分，不是 GPL 代码。应用没有把 SF Symbols、系统字体或 Apple 的二进制框架打包进自己的资源目录；它们由 macOS 在运行时提供。这部分应遵循 Apple Developer Program / SDK 许可，和 GPL 无关。

如果未来上架 Mac App Store，当前关闭 App Sandbox 的做法需要另做调整；这是上架要求，不是本次开源许可问题。

### 5. 名称已从 Qraft 改为码笺 / Majian

初审时发现原名称存在明显的商标与混淆风险：

- App Store 已有一个直接同类的 **QRAFT: QR Code Generator**：  
  https://apps.apple.com/cn/app/qraft-qr-code-generator/id6778674846
- 美国有 **Qraft Technologies Inc.** 的 `QRAFT` 商标申请：  
  https://trademarks.justia.com/906/93/qraft-90693308.html

这两个链接仅作为改名原因的历史记录保留，不再对应本项目。

现在已统一改为：

- 显示名：`码笺`
- 代码/工程名：`Majian`
- Bundle ID：`com.zhangzhouqi.Majian`
- 工程：`Majian.xcodeproj`，scheme：`Majian`
- 产物：`Dist/Majian.app`、`Dist/Majian-1.0.0.zip`

「码笺」是自造的产品名，初步网络检索没有发现同名二维码应用；但这不是正式商标检索。`Majian` 是常见音译/地名，作为代码名可以，作为独立品牌最好与「码笺」一起使用。**如果准备上架 App Store，仍建议做中国及目标市场的商标检索。**

### 6. 示例隐私已清理

原来的示例名片和截图包含真实姓名与电话号码，现在统一替换为：

- 姓名：`张三`
- 电话：`13800000000`
- 邮箱：`hello@example.com`
- 单位：`示例工作室`
- 地址：`示例路 1 号`
- 邮编：`200000`

`Docs/majian-contact.png` 已用新数据重新截图；源码里的输入框 placeholder 也全部改成 `张三` / `13800000000`。仓库内不再出现原来的姓名和号码。

### 7. 没有做专利/FTO 检索

本次只做了版权与开源许可证审查，没有做二维码标准必要专利、商标全类检索或外观设计检索。二维码核心专利已过期是常见说法，但若要正式商用，仍建议让知识产权律师做一次 FTO（自由实施）检索。

### 8. QR Code 商标

`QR Code` 是 DENSO WAVE INCORPORATED 的注册商标。项目对“二维码/QR”的使用属于描述性使用，README 已加商标归属说明；不要把产品本身注册成“QR Code”品牌即可。

## 已修改的文件

- `Majian.xcodeproj/project.pbxproj`：target/product 改 `Majian`，显示名 `码笺`，bundle ID `com.zhangzhouqi.Majian`。
- `Sources/App/MajianApp.swift`、`Sources/Model/MajianModel.swift`：类型与源文件改名；菜单「第三方许可」保留。
- `build.sh:27-36`：把 `LICENSE`、`THIRD_PARTY_NOTICES.md` 放进 app 包，清理 FinderInfo 后签名校验。
- `build.sh:38-48`：从干净副本打包，并用 `--noextattr` 排除扩展属性，避免 zip 内签名被 FinderInfo 破坏。
- `THIRD_PARTY_NOTICES.md`：注明仅重命名错误类型，算法未改。
- `README.md`：改为「码笺」品牌；补充二进制分发许可、QR Code 商标说明、审查报告链接。
- `Docs/majian-contact.png`：用张三/示例数据重新截图。
- `LICENSE`：改为 `Copyright (c) 2026 Majian Contributors`。

## 验证

```bash
cd /Users/zhangzhouqi/Documents/WorkSpace/Xcode/Majian
./build.sh
./Tests/verify.sh
codesign --verify --deep --strict Dist/Majian.app
```

结果：

- `** BUILD SUCCEEDED **`
- `ALL PASS`（5 类内容、7 种协议、4 种纠错、3 种 PNG/SVG 样式，Vision 回读）
- `build.sh` 签名完成时 `Dist/Majian.app` 通过校验
- 解压后的 `Majian.app` 通过 `codesign --verify --deep --strict`，zip 内不含 FinderInfo
- 包内包含 `LICENSE` 与 `THIRD_PARTY_NOTICES.md`

分发给别人时请使用 `Dist/Majian-1.0.0.zip`。本地直接启动 `Dist/Majian.app` 后，macOS 可能往 bundle 根目录写入 `com.apple.FinderInfo`，导致再次 `codesign --verify` 报 detritus；重建或重签前先 `xattr -cr` 即可。

## 建议优先级

1. **上架前做「码笺 / Majian」的商标检索**；GitHub 开源本身不要求注册商标（中）。
2. 若商用，做一次专利/FTO 与目标市场商标检索（中）。
3. 保留 `LICENSE`、`THIRD_PARTY_NOTICES.md` 与包内 notices；以后新增依赖时继续做同样检查（持续）。
4. 公开仓库前确认没有把 `.build/`、`Dist/`、`.work/` 或旧截图提交进去（低，`.gitignore` 已覆盖）。
