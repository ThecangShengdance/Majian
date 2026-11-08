import AppKit
import SwiftUI

@main
struct MajianApp: App {
    @NSApplicationDelegateAdaptor(MajianAppDelegate.self) private var appDelegate
    @StateObject private var model = MajianModel()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
                .frame(minWidth: 1120, minHeight: 740)
                .preferredColorScheme(.light)
                .background(WindowConfigurator())
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1360, height: 860)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("第三方许可") {
                    openThirdPartyNotices()
                }
            }

            CommandGroup(replacing: .newItem) {
                Button("新建二维码") {
                    model.clear()
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandMenu("二维码") {
                Button("载入示例") {
                    model.loadSample()
                }
                .keyboardShortcut("l", modifiers: .command)

                Divider()

                Button("导出 PNG…") {
                    model.exportPNG()
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(!model.isReady)

                Button("导出 SVG…") {
                    model.exportSVG()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                .disabled(!model.isReady)

                Divider()

                Button("复制二维码图片") {
                    model.copyImage()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .disabled(!model.isReady)

                Button("复制二维码内容") {
                    model.copyContent()
                }
                .keyboardShortcut("c", modifiers: [.command, .option])
                .disabled(!model.isReady)
            }
        }
    }

    private func openThirdPartyNotices() {
        guard let url = Bundle.main.url(forResource: "THIRD_PARTY_NOTICES", withExtension: "md") else {
            let alert = NSAlert()
            alert.messageText = "未找到第三方许可文件"
            alert.informativeText = "请通过 build.sh 重新构建应用，许可声明会随应用一起分发。"
            alert.runModal()
            return
        }
        NSWorkspace.shared.open(url)
    }
}

final class MajianAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
