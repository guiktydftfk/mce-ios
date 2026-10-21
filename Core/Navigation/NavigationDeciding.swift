import SwiftUI
import WebKit

/// 导航决策：站内放行，站外交给系统浏览器。
/// `target="_blank"` / `window.open` 的请求同样会经过 navigationDeciding，
/// 因此一个入口同时覆盖本页跳转与新窗口请求。
enum NavigationPolicy {
    static func decide(_ action: WebPage.NavigationAction) -> WebPage.NavigationDecision {
        guard let url = action.target.request.url else { return .cancel }
        return SiteScope.isInternal(url) ? .allow : .openInSystemBrowser
    }
}
