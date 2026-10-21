import Foundation
import Observation

/// 会话层：统一管理登录状态与 Cookie。
///
/// ⚠️ 已知约束（第一阶段不阻塞）：
/// SwiftUI 的 WebPage 不直接暴露底层 WKHTTPCookieStore，
/// 而 Discuz 的 auth cookie 是 HttpOnly（JS 读不到）。
/// 待进入第二阶段（原生请求）时，需要写一个窄封装桥接 Cookie；
/// 届时本类是唯一改动点，外壳层不受影响。
@MainActor
@Observable
final class SessionStore {
    static let shared = SessionStore()

    private(set) var isLoggedIn = false
    private(set) var username: String?

    /// 占位实现：依赖 Cookie 桥接才能正确探测。
    /// 现在调用只会返回“未登录”——因为 URLSession 与 WebView
    /// 的 Cookie 存储互不相通，这正是上面注释说的问题。
    func probeLoginState() async {
        // TODO(phase-2): Cookie 桥接后实现
        // 请求 forum.php?showmobile=yes，检查是否包含退出登录标记
        isLoggedIn = false
        username = nil
    }
}
