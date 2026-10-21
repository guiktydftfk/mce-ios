# MCE iOS 客户端（第一阶段）

mce.msi.cn（Discuz! X3.5）的原生 iOS 外壳：SwiftUI TabView + iOS 26 `WebPage`/`WebView`。
按绞杀者模式逐屏替换为纯原生，见仓库外的《MCE-iOS-第一阶段计划与清单.md》。

## 关键事实

- 最低支持：iOS 26.0（iPhone only）
- 掌上论坛 JSON API **未启用**（实测 `module_not_exists`），数据解析目标为手机版模板
- 工程文件 `MCE.xcodeproj` 由 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 从 `project.yml` 生成，**不入库**
- CI：GitHub Actions（macOS）编译出**未签名 IPA** artifact；Windows 上用 Sideloadly 签名装机

## 目录

```
App/     外壳：@main、TabView
Core/    FeatureFlags / SiteScope（域判定）/ NavigationPolicy / SessionStore
Forum/   ForumRepository 协议 + Web 路线实现（WebContentView）
Tests/   SiteScope 单测
```

## 日常流程

1. 改代码 → push 到 main → Actions 自动：生成工程 → 单测 → 编译 → 产出 `MCE-unsigned-ipa`
2. 下载 artifact → Sideloadly（Windows）+ 免费 Apple ID 签名 → USB 装机
3. 每 7 天重签一次（同 Apple ID + 同 Bundle ID 覆盖安装可保留数据）

## 装机当天才需要装的东西

- 微软商店 Apple Devices 应用（USB 驱动）
- Sideloadly（sideloadly.io）
