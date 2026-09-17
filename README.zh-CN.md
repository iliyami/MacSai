<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Mac Sai 图标" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>开源的 Mac 清理、优化与恶意软件扫描工具。</strong><br>
  免费、经 Apple 公证的 CleanMyMac 替代品，使用 Swift 6 和 SwiftUI 构建。
</p>

<p align="center">
  <a href="README.md">English</a> | <strong>简体中文</strong> | <a href="README.ru.md">Русский</a>
</p>

<p align="center">
  <a href="https://github.com/iliyami/MacSai/stargazers"><img src="https://img.shields.io/github/stars/iliyami/MacSai?style=flat-square&color=gold" alt="GitHub stars" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/v/release/iliyami/MacSai?style=flat-square&color=blue" alt="最新版本" /></a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey?style=flat-square" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6.0-orange?style=flat-square" alt="Swift 6" />
  <img src="https://img.shields.io/badge/tests-862%20passing-brightgreen?style=flat-square" alt="测试" />
  <img src="https://img.shields.io/badge/telemetry-none-brightgreen?style=flat-square" alt="无遥测" />
  <img src="https://img.shields.io/badge/Apple-notarized-black?style=flat-square&logo=apple" alt="已公证" />
  <img src="https://img.shields.io/badge/license-BSD--3--Clause-green?style=flat-square" alt="许可证" />
  <img src="https://img.shields.io/badge/PRs-welcome-ff69b4?style=flat-square" alt="欢迎 PR" />
</p>

<p align="center">
  <img src="assets/demo.png" width="720" alt="Mac Sai 截图" />
</p>

<p align="center">
  <strong>一条命令即可安装：</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  或下载<a href="https://github.com/iliyami/MacSai/releases/latest">最新的 DMG</a>。它已经过 Apple 公证，双击即可打开，无需右键、无警告、无需终端命令。
</p>

---

## 为什么选择 Mac Sai？

一款功能完整的 Mac 清理工具，不该收取年度订阅费，也不该让你把对文件的深度访问权限交给一个黑盒。Mac Sai 把整套工具完全透明地交到你手中。

- **永久免费。** 没有订阅、没有内购、没有“升级到 Pro”、没有弹窗催促。BSD-3 许可证。
- **零遥测。** 没有分析统计、没有崩溃上报、没有追踪器、没有可回传的服务器。而且不必只听我们说，你可以[自行验证](#自行验证无遥测)，两条命令即可。
- **CleanMyMac 的每一项主要工具，集于一身。** 17 个模块，覆盖清理、防护、性能、应用管理和磁盘洞察，外加一个菜单栏小组件。
- **安全为先。** 优先移入废纸篓、受保护路径黑名单、符号链接与 TOCTOU 防护，以及会校验每一条路径的 `SafetyGuard`。它从设计上就力求绝不丢失你的数据。
- **经 Apple 公证，且完全开源。** 你的 Mac 每次启动都会校验签名，而每一行代码都在这里供你审阅。

---

## 功能一览

<table>
<tr>
<td width="33%" valign="top">

### 🧹 清理
- **智能扫描**（一键）
- **系统垃圾**（16+ 类别）
- **邮件附件**
- **废纸篓**

</td>
<td width="33%" valign="top">

### 🛡️ 防护
- **恶意软件清理**
- **隐私清理**（浏览器）
- **已保存的 Wi-Fi**
- **权限总览**

</td>
<td width="33%" valign="top">

### ⚡ 性能
- **优化**（登录项）
- **维护**（系统任务）

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 应用
- **卸载器**（含重置为默认）
- **扩展**（面板、插件）
- **应用更新**

</td>
<td width="33%" valign="top">

### 🗂️ 文件
- **空间透视**（磁盘树状图）
- **大文件与旧文件**
- **重复文件**（含合并）
- **文件粉碎**

</td>
<td width="33%" valign="top">

### 📊 菜单栏
- 实时 CPU / 内存 / 磁盘 / 电池
- 网络、运行时间、交换空间
- 可操作的建议

</td>
</tr>
</table>

---

## 功能详解

### 🧹 清理
| 模块 | 说明 |
|--------|------------|
| **智能扫描** | 一键同时运行清理、防护和性能模块，实时显示进度，并按模块显示实际释放了多少空间 |
| **系统垃圾** | 16+ 个扫描类别：用户/系统缓存、日志、语言文件、损坏的偏好设置、损坏的登录项、文稿版本、iOS 备份、Xcode 垃圾、包管理器 / IDE / AI 工具缓存、已删除用户的残留，以及 **Universal Binary 瘦身**（检测同时包含 arm64 和 x86_64 切片的胖 Mach-O 二进制文件，通过 `lipo` 重写为你的原生架构，支持取消） |
| **邮件附件** | 查找来自 Apple Mail、Outlook 和 Spark 的缓存附件 |
| **废纸篓** | 清空所有位置（包括外置磁盘）的废纸篓 |

### 🛡️ 防护
| 模块 | 说明 |
|--------|------------|
| **恶意软件清理** | 基于特征码的扫描，提供 3 种深度（快速 / 平衡 / 深度）：检查启动代理与守护进程、浏览器扩展，以及已知的广告软件/恶意软件模式（这是一份精选清单，并非杀毒软件，我们也如实说明） |
| **隐私清理** | 清理 Safari、Chrome 和 Firefox 的历史记录、Cookie 和缓存，可按时间过滤。Safari **书签绝不会被清理** |
| **已保存的 Wi-Fi** | 列出你的首选无线网络，并忘记你选择的那些 |
| **权限总览** | 以“按应用”的视角只读查看每个应用持有哪些隐私（TCC）授权，这是系统设置不提供的角度。所有操作都会深链到系统设置，由系统设置负责实际的开关 |

### ⚡ 性能
| 模块 | 说明 |
|--------|------------|
| **优化** | 管理登录项和启动代理，可逐项启用/停用 |
| **维护** | 系统任务：释放内存、运行维护脚本、验证启动磁盘、重建启动服务、重建 Spotlight 索引、刷新 DNS、精简 Time Machine 快照。任务按风险等级标记，“运行安全任务”按顺序执行，且管理员密码只需输入**一次** |

### 📦 应用
| 模块 | 说明 |
|--------|------------|
| **卸载器** | 模式匹配引擎，可在 17 个以上的 Library 子目录中找出每一个关联文件（包括安装在厂商子文件夹中的应用）。支持彻底删除、**重置为默认**（清除应用的缓存和偏好设置但保留应用本身），以及未使用应用检测 |
| **扩展** | 查看第三方偏好设置面板、Internet 插件和 Safari 扩展。用户安装的面板和插件可移到废纸篓 |
| **应用更新** | 通过已安装应用自身的 Sparkle appcast 源检查更新（只读取版本信息，不发送任何关于你的数据） |

### 🗂️ 文件
| 模块 | 说明 |
|--------|------------|
| **空间透视** | 以方形化树状图可视化磁盘占用，可逐层下钻浏览 |
| **大文件与旧文件** | 查找大于 50 MB 的文件，按大小和最后访问日期排序 |
| **重复文件** | 渐进式检测（按大小分组、部分 SHA-256、完整哈希、inode 校验），并提供**合并**模式：在 APFS 上用写时复制克隆回收空间，不删除任何一份副本 |
| **文件粉碎** | 安全擦除文件，提供标准、永久和安全覆写模式 |

### 📊 菜单栏小组件

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Mac Sai 菜单栏小组件" />
</p>

一个毛玻璃风格的菜单栏小组件，让你的 Mac 关键状态一键可达。它是一个独立进程，登录时启动，可从应用侧边栏开关，无需打开主窗口即可随时查看。

- **实时状态环**：CPU 负载、内存压力、磁盘占用和电池，以 2x2 环形网格呈现（`host_processor_info`、`vm_statistics64`、APFS 容量、IOKit 电源），按绿 → 黄 → 红分级着色
- **可配置读数**：可选择显示可用磁盘、GPU 使用率、内存使用率或电池温度；选择会保存，不可用的传感器显示 `--`
- **网络、运行时间与交换空间**：实时上/下行吞吐、系统运行时间、交换空间使用
- **建议**：可操作、可关闭的提示（“用户缓存已增长到 2.52 GB，运行系统垃圾清理”），点击即可执行，关闭后 30 天内不再提示
- **防护状态**：上次恶意软件扫描时间和威胁数量，按时效着色
- **已连接设备**：一眼查看外置卷（含剩余空间）和外接显示器
- **健康提醒**：当磁盘空间严重不足或内存压力持续偏高时发出通知（已限流、可选启用）

### ⌨️ 键盘快捷键

| 快捷键 | 操作 |
|----------|--------|
| **⌘R** | 在当前模块开始扫描 |
| **⌘K** | 清理当前选中项（有结果时） |
| **⌘1 至 ⌘9** | 跳到侧边栏前九个模块 |
| **⌘,** | 打开设置 |

---

## Mac Sai 横向对比

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **价格** | 免费 | $39.95/年 | 免费 | 免费 | 免费 | 免费（命令行） |
| **开源** | ✅ BSD-3 | ❌ | ✅ Fair-code | ✅ MIT | ❌ | ✅ MIT |
| **遥测** | ❌ 无 | ⚠️ 有 | ❌ 无 | ❌ 无 | ❌ 无 | ❌ 无 |
| **原生图形应用** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ 命令行（图形界面另售） |
| **智能扫描（一键）** | ✅ | ✅ | ❌ | ➖ 部分 | ❌ | ➖ 交互式命令行 |
| **系统垃圾（16+ 类别）** | ✅ | ✅ | ➖ | ✅ | ➖ 有限 | ✅ |
| **Universal Binary 瘦身** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **恶意软件扫描** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **浏览器隐私清理** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **带残留检测的卸载器** | ✅ | ✅ | ✅ 专注 | ❌ | ❌ | ✅ |
| **重复文件查找（含合并）** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **磁盘树状图可视化** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ 分析器 |
| **菜单栏系统监视器** | ✅ | ✅ 菜单 | ❌ | ❌ | ❌ | ❌ |
| **维护脚本** | ✅ | ✅ | ❌ | ❌ | ✅ 强大 | ➖ |
| **经 Apple 公证** | ✅ | ✅ | ✅ | ✅ | ✅ | 不适用 |
| **macOS 版本** | 14+ | 13+ | 13+ | 13+ | 视情况 | 视情况 |

> CleanMyMac 是一款很棒的产品，愿意为打磨精良、有官方支持的体验付费的用户理应让他们获得收入。Mac Sai 则面向所有更希望拥有透明源代码、零订阅的人。

---

## 安装

### Homebrew（推荐）

Mac Sai 已收录进官方 Homebrew cask，无需 tap：

```bash
brew install --cask mac-sai
```

它已经过 Apple 公证，可从聚焦或“应用程序”直接启动，没有警告，也无需额外步骤。

<details>
<summary><strong>其他安装方式</strong>（一行脚本、DMG、从源码构建）</summary>

<br>

**一行安装脚本**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

会下载最新的 DMG 并将应用安装到 `/Applications`。

**下载 DMG**

从 [Releases](https://github.com/iliyami/MacSai/releases/latest) 下载最新的 DMG，将 Mac Sai 拖入“应用程序”文件夹。

**从源码构建**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # 运行完整的 862 个测试
bash scripts/build-dmg.sh      # 构建本地 DMG（未签名）
```

需要 Swift 6 工具链（Xcode 16+）。

**之前通过旧的 tap 安装的？**

现在 Mac Sai 已进入官方 cask，可以移除它：`brew untap iliyami/macsai`（不影响已安装的应用和后续的 `brew upgrade`）。

</details>

### 授予完全磁盘访问权限

部分模块（邮件附件、隐私、恶意软件）需要完全磁盘访问权限才能扫描受保护区域：

1. 打开 **系统设置、隐私与安全性、完全磁盘访问权限**
2. 点击 **+**，添加 **Mac Sai.app**
3. 重新启动 Mac Sai

### 卸载

Homebrew 安装：

```bash
brew uninstall --zap --cask mac-sai
```

DMG 或手动安装（也能处理 Homebrew 安装）：

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

两者都会删除 Mac Sai 及其在 `~/Library` 下的偏好设置、缓存、日志和数据库。

---

## 已签名、已公证，值得信任

Mac Sai 使用 Apple **Developer ID** 进行代码签名，并经 **Apple 公证**。对于清理类应用而言，这一点比几乎任何你安装的软件都更重要，因为你即将赋予它对文件的深度访问权限，你有权确认运行在你 Mac 上的确实是我们的、且未被篡改的版本。以下这些都由你自己的 Mac 强制执行，而不仅仅是我们的承诺：

- **Apple 已扫描过它。** 每个版本都会提交给 Apple 并在发布前检查恶意软件。
- **它无法被篡改。** 签名是覆盖每个文件的加密封印；哪怕改动一个字节，macOS 也会拒绝打开。
- **它确实来自我们。** 签名绑定到我们的 Apple 开发者身份，任何其他人都无法发布你的 Mac 会当作 Mac Sai 接受的东西。
- **开箱即用。** 没有 Gatekeeper 警告，无需右键打开，也无需终端命令。

再加上完全开源，这是一条你无需盲信的信任链：代码公开、我们对每个版本签名、Apple 进行验证、而你的 Mac 在每次打开时都会重新校验这个封印。

### 自行验证无遥测

不必只听我们说，源码和运行中的进程都可以核对。

**1. 在源码中搜索网络 API**

```bash
rg -n 'URLSession|NSURLConnection' Sources --glob '*.swift'
```

你应当只会看到两条网络路径，二者都是可选且只读的：

- `Sources/MacCleanKit/UpdateChecker.swift`：可选的 Mac Sai 更新检查（可在设置中关闭）
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`：打开“应用更新”模块时，由用户触发的对其它应用 Sparkle 源的检查

代码库中没有任何分析、崩溃上报或追踪 SDK。

**2. 观察实时进程**

```bash
lsof -i -P -n | grep -i 'MacClean\|Mac Sai\|MacSai' || echo "no network sockets"
```

预期：仅做本地清理时没有已建立的连接。Little Snitch 或 LuLu 可做同样的可视化检查。

---

## 架构

```
Mac Sai
├── MacClean          主 SwiftUI 应用（17 个模块）
├── MacCleanKit       共享框架（模型、常量、协议）
├── MacCleanHelper    XPC 特权助手（用于 root 操作的 LaunchDaemon）
└── MacCleanMenu      菜单栏监视器（独立进程）
```

### 技术栈

| 层 | 技术 |
|-------|-----------|
| 语言 | Swift 6，严格并发 |
| UI | SwiftUI + AppKit 混合 |
| 并发 | Actor、TaskGroup、async/await、`@Sendable` |
| 数据库 | GRDB.swift（SQLite），WAL 模式 |
| 文件扫描 | 基于 APFS 的 `URLResourceKey` 预取 |
| 增量更新 | FSEvents，支持历史回放 |
| 特权操作 | SMAppService + NSXPCConnection |
| 系统统计 | Mach API（`host_processor_info`、`vm_statistics64`、`proc_pidinfo`） |

### 安全模型

Mac Sai 的设计目标是**绝不造成数据丢失**：

- **受保护路径黑名单**：`/System`、`/usr`、`/bin`、`/sbin` 以及 Apple 系统应用不可触碰，并对 macOS firmlink 做规范化，使符号链接重定向检测不会误判合法系统路径
- **扫描前的可清理性过滤**：当前进程无法移入废纸篓的项目（系统缓存中 root 拥有的子项、`~/Library/Caches/com.apple.*` 下被数据保险库保护的目录）在扫描时即被剔除，绝不会作为“可清理”出现
- **优先移入废纸篓**：所有删除默认进入废纸篓，预演模式可在不触碰任何文件的前提下预览
- **TOCTOU 防护**：删除前立即重新解析符号链接
- **排除文件夹**：可在设置中选择让扫描完全跳过的文件夹，`SafetyGuard` 还会拒绝删除这些文件夹下的任何内容
- **分块、可取消的清理**：大批量选择会拆分为每批 5000 项，在批次之间遵循取消；点击取消后扫描约在一秒内回到空闲
- **应用内活动日志**：清理过程中的每个错误都会记录完整路径，可在清理后界面查看并复制，日志 30 天后自动清理
- **内核强制的 XPC 闸门**：特权助手使用 `NSXPCListener.setCodeSigningRequirement`，由内核本身拒绝任何代码签名与主应用标识符和团队不匹配的连接

---

## 测试

```bash
swift test
```

基于 XCTest 的测试套件包含 **862 个测试**，并把 `SafetyGuard` 和 `CleaningEngine`（生死攸关的文件）视为必须完美：对符号链接、路径穿越、NULL 字节、SIP、受保护应用、文件数量上限、TOCTOU 和幂等性的对抗式覆盖，外加对预演 / 移入废纸篓 / 永久删除清理、扫描状态机、每一个系统垃圾类别、树状图算法、卸载器匹配引擎、重复文件检测、appcast 解析，以及完整的“从合成夹具到清理”端到端流程的集成覆盖。测试夹具（`withTempHome`、`withFakeApp`、`withFakePlist`）确保每个测试都不会触碰你真实的个人目录。

---

## 参与贡献

非常欢迎贡献。请阅读[贡献指南](CONTRIBUTING.md)，然后：

1. Fork 仓库并创建功能分支
2. 进行修改（每个 PR 聚焦一件事，便于审阅）
3. 运行 `swift test`
4. 提交 Pull Request

这里还有一个开放的[功能投票](https://github.com/iliyami/MacSai/issues/55)：为你希望接下来构建的工具点 👍。

## 许可证

BSD 3-Clause。详见 [LICENSE](LICENSE)。你可以使用、修改和再分发本代码，但须保留版权与许可证文本，且未经许可不得使用“Mac Sai”名称或贡献者姓名为衍生产品背书。

## 致谢

灵感来自开源 Mac 实用工具社区：

- [Pearcleaner](https://github.com/alienator88/Pearcleaner)：应用卸载模式
- [Mole](https://github.com/tw93/Mole)：清理类别
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner)：模块化架构
- 方形化树状图算法，作者 Bruls、Huizing 与 van Wijk（2000）

## Star 历史

<p align="center">
  <a href="https://www.star-history.com/?repos=iliyami%2FMacSai&type=date&legend=top-left">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&theme=dark&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
    </picture>
  </a>
</p>

<p align="center">
  <strong>Mac Sai 是由社区、为社区打造的免费软件。</strong><br>
  如果它帮你省下了一笔订阅费，点个 ⭐ 能帮助更多人发现它。
</p>
