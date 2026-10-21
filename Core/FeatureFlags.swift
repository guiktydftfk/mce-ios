import Foundation

/// 特性开关：逐屏灰度替换（Web ↔ 原生）的开关面板。
/// 后续可接入远端配置或 UserDefaults，第一阶段仅编译期默认值。
struct FeatureFlags: Codable, Equatable {
    var threadListUsesNative = false    // 帖子列表走原生
    var threadDetailUsesNative = false  // 帖子详情走原生

    static let `default` = FeatureFlags()
}
