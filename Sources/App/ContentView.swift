import SwiftUI

struct ContentView: View {
    @ObservedObject var model: MajianModel

    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                SidebarView(model: model)
                EditorView(model: model)
                PreviewRail(model: model)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let toast = model.toast {
                ToastOverlay(toast: toast)
                    .padding(.top, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .background(Palette.paper)
        .ignoresSafeArea(.container, edges: .top)
        .animation(.easeInOut(duration: 0.2), value: model.toast)
    }
}
