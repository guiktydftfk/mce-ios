import Foundation

/// 站内域判定 —— 纯函数，无任何框架依赖，CI 上必测。
enum SiteScope {
    /// 允许在 App 内浏览的域名后缀白名单。
    /// 站点若有独立 CDN/附件域名，实测后加入此表（而不是外开）。
    static let hostSuffixWhitelist: Set<String> = [
        "mce.msi.cn",
    ]

    /// host 精确匹配，或为白名单域的子域，即视为站内。
    /// - "mce.msi.cn"        → true（精确）
    /// - "www.mce.msi.cn"    → true（子域）
    /// - "evilmce.msi.cn"    → false（只是长得像，后缀不匹配）
    /// - "example.com"       → false
    /// - 无 host 的 URL       → false
    static func isInternal(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased(), !host.isEmpty else { return false }
        return hostSuffixWhitelist.contains { domain in
            host == domain || host.hasSuffix("." + domain)
        }
    }

    /// 是否 Discuz 站内脚本入口，供后续解析层复用。
    /// 注意：URLComponents.path 带前导斜杠（"/forum.php"），
    /// 因此用 lastPathComponent 取末段再比对。
    static func isForumScriptPath(_ url: URL) -> Bool {
        guard isInternal(url) else { return false }
        let script = url.lastPathComponent.lowercased()
        return [
            "forum.php", "portal.php", "home.php", "misc.php",
            "plugin.php", "member.php", "search.php",
        ].contains(script)
    }
}
