import Foundation

/// Web 路线占位：第一阶段页面内容全部由 WebContentView 直接渲染，
/// 不经过本仓库。保留实现是为了让协议的调用方可稳定注入。
struct WebForumRepository: ForumRepository {
    func loadForumList(fid: Int, page: Int) async throws -> [ThreadSummary] {
        throw RepositoryError.notImplemented
    }

    func loadThread(tid: Int, page: Int) async throws -> ThreadDetail {
        throw RepositoryError.notImplemented
    }
}
