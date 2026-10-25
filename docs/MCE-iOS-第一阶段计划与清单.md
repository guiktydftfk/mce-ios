# MCE iOS 客户端 · 第一阶段计划与清单

> 目标：在自己 iPhone 上跑起"原生壳 + WebView"的最小混合闭环。
> 约束：无付费开发者账号、无法联系站长、开发机为 Windows。
> 更新日期：2026-10-14

---

## 0. 最终流水线（一张图看懂）

```
Windows 写代码 (git push)
        │
        ▼
GitHub Actions (macOS runner, Xcode 26)
  XcodeGen 生成工程 → xcodebuild 编译 → 未签名 IPA
        │  (Actions artifact 下载)
        ▼
Windows: Sideloadly + 免费 Apple ID 签名
        │  (USB 连接 iPhone)
        ▼
iPhone 上运行（7 天有效期，到期重签）
```

**为什么必须走这条线**：免费 Apple ID 没有分发资格，也没有云端签名接口；
Sideloadly 在 Windows 上原生支持，用免费证书现场签名 + USB 安装，是目前唯一
不花钱、不需要 mac 的"编译→装机"闭环。

---

## 1. 准备阶段清单（一次性，约半天）

- [ ] **确认 iPhone 系统版本 ≥ iOS 26.0**（最低支持版本就是 26，低于此无法安装）
- [ ] 注册 GitHub 账号，创建仓库 `mce-ios`（建议 **public**，理由见 §5 风险表）
- [ ] Windows 安装 **iTunes / Apple Devices 应用**（微软商店版即可）
      —— 提供 USB 驱动，Sideloadly 依赖它识别设备
- [ ] 下载安装 **Sideloadly**（sideloadly.io，Windows 版）
- [ ] Apple ID 若开了两步验证：到 appleid.apple.com 生成**App 专用密码**，Sideloadly 登录用
- [ ] iPhone 上：设置 → 通用 → VPN 与设备管理，确认能对开发者 App 信任（装好后操作）
- [ ] 数据线一根（务必是数据线不是纯充电线，装机最常见的坑）

## 2. 开发阶段清单（第一阶段代码，全部在 Windows 完成）

- [ ] 工程骨架：`project.yml`（XcodeGen）+ 目录结构（App / Core / Forum / Tests）
- [ ] `MCEApp.swift` + `RootTabView.swift`：TabView（论坛 / 发现 / 我的）+ NavigationStack
- [ ] `SiteScope.swift`：域名白名单判定（纯函数：host 精确或子域后缀匹配）
- [ ] `NavigationDeciding` 挂接 `page.navigationDeciding`：
      站内 `.allow`，站外 `.openInSystemBrowser`，`target="_blank"` 同一入口处理
- [ ] `WebContentView.swift`：`WebPage` 加载 `https://mce.msi.cn/forum.php`，
      `WebView(page)` 展示，`.navigationTitle(page.title)` 跟随标题
- [ ] `FeatureFlags.swift`：`threadListUsesNative / threadDetailUsesNative` 默认 false（全走 Web）
- [ ] `SessionStore.swift`：仅登录状态探针（空实现即可，第一阶段不碰登录）
- [ ] `ForumRepository.swift` 协议 + Web 实现抛 `notImplemented`（占位）
- [ ] `SiteScopeTests.swift`：域名判定单测（CI 必跑）
- [ ] `.github/workflows/ios.yml`：签出 → 装 XcodeGen → xcodegen → xcodebuild
      (`CODE_SIGNING_ALLOWED=NO`) → 打包未签名 IPA → 上传 artifact

### 第一阶段验收标准（CI 上即可判定，不需要手机在场）

- [ ] workflow 全绿，IPA artifact 可下载
- [ ] 单测全绿（SiteScope）
- [ ] 模拟器截图 artifact：能看到 Tab 壳 + 论坛页正常加载

## 3. 装机阶段清单（每次要装/续期都走这一遍）

- [ ] Actions 运行完 → 下载 artifact 里的 `MCE-unsigned.ipa`
- [ ] iPhone 用 USB 连电脑，解锁并信任此电脑
- [ ] Sideloadly：拖入 IPA → 填 Apple ID（+App 专用密码）→ Start
- [ ] iPhone 上首次启动若提示"不受信任"：设置 → 通用 → VPN与设备管理 → 信任证书
- [ ] **设置循环提醒：每 7 天重签一次**（日历/提醒事项，第一天就建）

> 续期注意：用**同一个 Apple ID、同一个 Bundle ID** 重签覆盖安装，
> App 内数据（如 WebView 登录态）可以保留；换了 ID 会当成新 App。

## 4. 里程碑排序（建议节奏）

| # | 里程碑 | 验证方式 | 预估 |
|---|--------|----------|------|
| M1 | 工程骨架 + CI 编译通过 | Actions 绿灯 | 1 次迭代 |
| M2 | 壳 + WebView 首页可浏览 | 模拟器截图 | 1 次迭代 |
| M3 | Sideloadly 装上真机 | 手机上打开 App | 半小时 |
| M4 | 导航策略 + 标题跟随 + 返回手势正常 | 真机点一遍 | 1 次迭代 |
| M5 | 下拉刷新（`page.reload()` 自定义触发） | 真机试验* | 1 次迭代，有不确定性 |

*M5 是第一阶段唯一有技术不确定性的点：WebView 嵌在 ScrollView 里手势归属
需要真机试。备选方案：导航栏刷新按钮兜底，体验略降但不阻塞。

## 5. 风险与对策

| 风险 | 影响 | 对策 |
|------|------|------|
| private 仓库 macOS 计费 10×，免费额度只有 ~200 分钟 | CI 配额几周耗尽 | 仓库设为 **public**（macos runner 免费不限时）；代码无敏感信息 |
| Xcode 26 runner 镜像变动 | workflow 挂 | 锁定 `macos-15` 镜像 + `xcode-select` 指定 26.x，报错时只改一行 |
| 免费 Apple ID 7 天过期、3 台设备、每周 10 个 App ID | 需定期维护 | 只自用 1 台即可无感；重签脚本化（§3 清单） |
| `WebPage` 不暴露 WKHTTPCookieStore | 第二阶段 Cookie 同步受阻 | 预留窄封装口子；先用 JS 探针验证能读到哪些 cookie |
| 手机版模板 DOM 变动 | HTML 解析失效（第二阶段） | 解析层 + Web 兜底双轨；FeatureFlags 逐屏切换 |
| Sideloadly 识别不到设备 | 装不上 | 换数据线/重装 Apple Devices 驱动，先确认资源管理器能看到 iPhone 照片目录 |

## 6. 明确不做的（第一阶段）

- 登录、发帖、回帖（formhash 动态表单，放最后）
- HTML 解析（等壳稳定后再上，目标锁定手机版模板 `showmobile=yes`）
- 任何分发考虑（TestFlight 等，等付费账号计划确定）
- 深链 / 通知 / Widget

---

**下一步**：确认本文档后，我直接在工作区生成 §2 的全部工程骨架文件。

---

## 7. 实际进展记录

| 日期 | 进展 |
|------|------|
| 2026-10-21 | 工程骨架完成；GitHub Actions 全链路打通（XcodeGen → 编译 → 8 项单测 → 未签名 IPA artifact）；M1/M2 达成 |
| 2026-10-21 | 网络通道定型：SSH over 443（`ssh.github.com`）+ 原生 OpenSSH + `~/.ssh/config`，零依赖稳定推送 |
| 2026-10-23 | 装机受阻：Sideloadly `-22406` / `404`，AltServer `Incorrect Apple ID` → `-80046`，判定为 Apple ID 侧风控限流 |
| 2026-10-23 | 已卸载 Sideloadly；决定暂停重试（失败会延长锁定），改走全新专用 Apple ID 路线 |

**当前阻塞点**：免费 Apple ID 签名登录被苹果限流（`-80046`）。等待锁定期结束，或使用全新专用 Apple ID。

**已确认可用**：iTunes 桌面版 + iCloud 桌面版（已登录）+ Apple Mobile Device Support `20.0.0.35`；手机 iPhone 16 Pro / iOS 26.0 已被工具正常识别。

