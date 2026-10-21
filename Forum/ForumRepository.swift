import Foundation

// MARK: - 模型（第二阶段由解析层填充真实数据）

struct ThreadSummary: Identifiable, Hashable {
    let id: Int
    let title: String
    let author: String?
    let replies: Int?
    let lastPostDate: Date?
}

struct ThreadDetail: Hashable {
    let id: Int
    let title: String
    let posts: [Post]
}

struct Post: Identifiable, Hashable {
    let id: Int
    let author: String
    let contentHTML: String
    let publishedAt: Date?
}

// MARK: - 错误

enum RepositoryError: Error {
    case notImplemented
    case network(any Error)
    case parsing(String)
}

// MARK: - 数据仓库协议

/// 数据抽象：初期由 WebView 承担加载（本协议空转），
/// 第二阶段换 URLSession + SwiftSoup 解析手机版模板 HTML
/// （已实测：掌上论坛 JSON API 未启用，手机版模板可用）。
protocol ForumRepository {
    func loadForumList(fid: Int, page: Int) async throws -> [ThreadSummary]
    func loadThread(tid: Int, page: Int) async throws -> ThreadDetail
}
