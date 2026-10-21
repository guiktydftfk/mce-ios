import SwiftUI
import UIKit
import WebKit

/// 内容渲染层（可替换）：第一阶段用 iOS 26 原生 WebPage + WebView。
/// 后续 NativeContentView 实现同样的角色，通过 FeatureFlags 逐屏切换。
struct WebContentView: View {
    private let initialURL: URL
    @State private var page: WebPage

    init(initialURL: URL = URL(string: "https://mce.msi.cn/forum.php")!) {
        self.initialURL = initialURL
        let page = WebPage(configuration: WebPage.Configuration())
        page.navigationDeciding = NavigationPolicy.decide
        _page = State(initialValue: page)
    }

    var body: some View {
        WebView(page)
            .ignoresSafeArea(.container, edges: .bottom)
            .navigationTitle(page.title.isEmpty ? "MCE星光班" : page.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { await page.goBack() }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(!page.canGoBack)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // M5 下拉刷新落地前的兜底刷新入口
                    Button {
                        page.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }

                    // 只有当前页是站外页时才显示“用 Safari 打开”
                    if let url = page.currentURL, !SiteScope.isInternal(url) {
                        Button {
                            UIApplication.shared.open(url)
                        } label: {
                            Image(systemName: "safari")
                        }
                    }
                }
            }
            .task {
                if page.currentURL == nil {
                    try? await page.load(URLRequest(url: initialURL))
                }
            }
    }
}
