import SwiftUI
import UIKit
import WebKit

/// 导航决策：站内放行，站外交给系统浏览器。
///
/// iOS 26 的 SwiftUI WebPage 不接收闭包，而是要求实现
/// `WebPage.NavigationDeciding` 协议，返回 WebKit 的策略枚举。
/// 参考 Apple 官方 SwiftBrowser 示例（WebKit 仓库）的写法。
@MainActor
struct SiteNavigationDecider: WebPage.NavigationDeciding {

    /// 决定“要不要开始加载”某个导航动作。
    /// target="_blank" / window.open 的新窗口请求同样会走到这里。
    func decidePolicy(
        for action: WebPage.NavigationAction,
        preferences: inout WebPage.NavigationPreferences
    ) async -> WKNavigationActionPolicy {
        guard let url = action.request.url else { return .cancel }

        guard SiteScope.isInternal(url) else {
            // 站外链接：用系统浏览器打开，WebView 内取消加载
            await UIApplication.shared.open(url)
            return .cancel
        }
        return .allow
    }

    /// 决定“已收到的响应”是否展示在 WebView 里。
    /// 第一阶段一律放行（下载类行为放到后续阶段处理）。
    func decidePolicy(
        for response: WebPage.NavigationResponse
    ) async -> WKNavigationResponsePolicy {
        .allow
    }
}
