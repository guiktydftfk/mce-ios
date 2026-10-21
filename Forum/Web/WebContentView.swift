import SwiftUI
import UIKit
import WebKit

/// 内容渲染层（可替换）：第一阶段用 iOS 26 原生 WebPage + WebView。
/// 后续 NativeContentView 实现同样的角色，通过 FeatureFlags 逐屏切换。
///
/// API 均已按 Apple 官方 SwiftBrowser 示例（WebKit 仓库）核对：
/// - 初始化：WebPage(configuration:navigationDecider:dialogPresenter:)
/// - 当前地址：page.url
/// - 后退历史：page.backForwardList.backList，导航用 page.load(item)
/// - 刷新/停止：page.reload() / page.stopLoading()（同步）
struct WebContentView: View {
    private let initialURL: URL
    @State private var page: WebPage

    init(initialURL: URL = URL(string: "https://mce.msi.cn/forum.php")!) {
        self.initialURL = initialURL
        _page = State(initialValue: WebPage(
            configuration: WebPage.Configuration(),
            navigationDecider: SiteNavigationDecider()
        ))
    }

    var body: some View {
        WebView(page)
            // 开启系统的前进/后退边缘手势（M4 验收项之一）
            .webViewBackForwardNavigationGestures(.enabled)
            .ignoresSafeArea(.container, edges: .bottom)
            .navigationTitle(page.title.isEmpty ? "MCE星光班" : page.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if let item = page.backForwardList.backList.last {
                            page.load(item)
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(page.backForwardList.backList.isEmpty)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // M5 下拉刷新落地前的兜底刷新入口
                    Button {
                        page.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }

                    // 只有当前页是站外页时才显示“用 Safari 打开”
                    if let url = page.url, !SiteScope.isInternal(url) {
                        Button {
                            UIApplication.shared.open(url)
                        } label: {
                            Image(systemName: "safari")
                        }
                    }
                }
            }
            .task {
                if page.url == nil {
                    page.load(URLRequest(url: initialURL))
                }
            }
    }
}
