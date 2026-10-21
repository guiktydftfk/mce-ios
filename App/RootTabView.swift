import SwiftUI

/// 原生外壳层（永久保留）：TabView + 导航栈。
/// 每个 Tab 的内容区都是 ForumContentView 的可替换实现，
/// 第一阶段全部走 WebContentView。
struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                WebContentView()
            }
            .tabItem { Label("论坛", systemImage: "bubble.left.and.bubble.right") }

            NavigationStack {
                WebContentView(
                    initialURL: URL(string: "https://mce.msi.cn/forum.php?mod=guide&view=newthread")!
                )
            }
            .tabItem { Label("发现", systemImage: "sparkles") }

            NavigationStack {
                ProfilePlaceholderView()
            }
            .tabItem { Label("我的", systemImage: "person") }
        }
    }
}

/// “我的”页占位：展示 SessionStore 状态。
/// 第一阶段未接入登录，probeLoginState 为占位实现。
struct ProfilePlaceholderView: View {
    @State private var session = SessionStore.shared

    var body: some View {
        List {
            Section("登录状态") {
                LabeledContent("状态", value: session.isLoggedIn ? "已登录" : "未登录（第一阶段未接入）")
                LabeledContent("用户名", value: session.username ?? "—")
            }
            Section {
                Button("探测登录态") {
                    Task { await session.probeLoginState() }
                }
            }
            Section("关于") {
                LabeledContent("阶段", value: "Phase 1 · 原生壳 + WebView")
                LabeledContent("最低支持", value: "iOS 26.0")
            }
        }
        .navigationTitle("我的")
    }
}
