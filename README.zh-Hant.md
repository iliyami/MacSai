<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Mac Sai 圖示" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>開源的 Mac 清理、最佳化與惡意軟體掃描工具。</strong><br>
  免費、經 Apple 公證的 CleanMyMac 替代品，使用 Swift 6 和 SwiftUI 構建。
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a> | <strong>繁體中文</strong> | <a href="README.de.md">Deutsch</a> | <a href="README.fr.md">Français</a> | <a href="README.ru.md">Русский</a>
</p>

<p align="center">
  <a href="https://github.com/iliyami/MacSai/stargazers"><img src="https://img.shields.io/github/stars/iliyami/MacSai?style=flat-square&color=gold" alt="GitHub stars" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/v/release/iliyami/MacSai?style=flat-square&color=blue" alt="最新版本" /></a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey?style=flat-square" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6.0-orange?style=flat-square" alt="Swift 6" />
  <img src="https://img.shields.io/badge/tests-862%20passing-brightgreen?style=flat-square" alt="測試" />
  <img src="https://img.shields.io/badge/telemetry-none-brightgreen?style=flat-square" alt="無遙測" />
  <img src="https://img.shields.io/badge/Apple-notarized-black?style=flat-square&logo=apple" alt="已公證" />
  <img src="https://img.shields.io/badge/license-BSD--3--Clause-green?style=flat-square" alt="許可證" />
  <img src="https://img.shields.io/badge/PRs-welcome-ff69b4?style=flat-square" alt="歡迎 PR" />
</p>

<p align="center">
  <img src="assets/demo.png" width="720" alt="Mac Sai 截圖" />
</p>

<p align="center">
  <strong>一條命令即可安裝：</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  或下載<a href="https://github.com/iliyami/MacSai/releases/latest">最新的 DMG</a>。它已經過 Apple 公證，雙擊即可開啟，無需右鍵、無警告、無需終端命令。
</p>

---

## 為什麼選擇 Mac Sai？

一款功能完整的 Mac 清理工具，不該收取年度訂閱費，也不該讓你把對檔案的深度訪問權限交給一個黑盒。Mac Sai 把整套工具完全透明地交到你手中。

- **永久免費。** 沒有訂閱、沒有內購、沒有“升級到 Pro”、沒有彈窗催促。BSD-3 許可證。
- **零遙測。** 沒有分析統計、沒有崩潰上報、沒有追蹤器、沒有可回傳的伺服器。而且不必只聽我們說，你可以[自行驗證](#自行驗證無遙測)，兩條命令即可。
- **CleanMyMac 的每一項主要工具，集於一身。** 17 個模組，覆蓋清理、防護、效能、應用管理和磁碟洞察，外加一個選單欄小元件。
- **安全為先。** 優先移入廢紙簍、受保護路徑黑名單、符號連結與 TOCTOU 防護，以及會校驗每一條路徑的 `SafetyGuard`。它從設計上就力求絕不丟失你的資料。
- **經 Apple 公證，且完全開源。** 你的 Mac 每次啟動都會校驗簽名，而每一行程式碼都在這裡供你審閱。

---

## 功能一覽

<table>
<tr>
<td width="33%" valign="top">

### 🧹 清理
- **智慧掃描**（一鍵）
- **系統垃圾**（16+ 類別）
- **郵件附件**
- **廢紙簍**

</td>
<td width="33%" valign="top">

### 🛡️ 防護
- **惡意軟體清理**
- **隱私清理**（瀏覽器）
- **已儲存的 Wi-Fi**
- **權限總覽**

</td>
<td width="33%" valign="top">

### ⚡ 效能
- **最佳化**（登入項）
- **維護**（系統任務）

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 應用
- **解除安裝器**（含重置為預設）
- **擴充功能**（面板、外掛）
- **應用更新**

</td>
<td width="33%" valign="top">

### 🗂️ 檔案
- **空間透視**（磁碟樹狀圖）
- **大檔案與舊檔案**
- **重複檔案**（含合併）
- **檔案粉碎**

</td>
<td width="33%" valign="top">

### 📊 選單欄
- 即時 CPU / 記憶體 / 磁碟 / 電池
- 網路、執行時間、交換空間
- 可操作的建議

</td>
</tr>
</table>

---

## 功能詳解

### 🧹 清理
| 模組 | 說明 |
|--------|------------|
| **智慧掃描** | 一鍵同時執行清理、防護和效能模組，即時顯示進度，並按模組顯示實際釋放了多少空間 |
| **系統垃圾** | 16+ 個掃描類別：使用者/系統快取、日誌、語言檔案、損壞的偏好設定、損壞的登入項、文稿版本、iOS 備份、Xcode 垃圾、包管理器 / IDE / AI 工具快取、已刪除使用者的殘留，以及 **Universal Binary 瘦身**（檢測同時包含 arm64 和 x86_64 切片的胖 Mach-O 二進位制檔案，透過 `lipo` 重寫為你的原生架構，支援取消） |
| **郵件附件** | 查詢來自 Apple Mail、Outlook 和 Spark 的快取附件 |
| **廢紙簍** | 清空所有位置（包括外接磁碟）的廢紙簍 |

### 🛡️ 防護
| 模組 | 說明 |
|--------|------------|
| **惡意軟體清理** | 基於特徵碼的掃描，提供 3 種深度（快速 / 平衡 / 深度）：檢查啟動代理與守護程序、瀏覽器擴充功能，以及已知的廣告軟體/惡意軟體模式（這是一份精選清單，並非防毒軟體，我們也如實說明） |
| **隱私清理** | 清理 Safari、Chrome 和 Firefox 的歷史記錄、Cookie 和快取，可按時間過濾。Safari **書籤絕不會被清理** |
| **已儲存的 Wi-Fi** | 列出你的首選無線網路，並忘記你選擇的那些 |
| **權限總覽** | 以“按應用”的視角只讀檢視每個應用持有哪些隱私（TCC）授權，這是系統設定不提供的角度。所有操作都會深鏈到系統設定，由系統設定負責實際的開關 |

### ⚡ 效能
| 模組 | 說明 |
|--------|------------|
| **最佳化** | 管理登入項和啟動代理，可逐項啟用/停用 |
| **維護** | 系統任務：釋放記憶體、執行維護指令碼、驗證啟動磁碟、重建啟動服務、重建 Spotlight 索引、重新整理 DNS、精簡 Time Machine 快照。任務按風險等級標記，“執行安全任務”按順序執行，且管理員密碼只需輸入**一次** |

### 📦 應用
| 模組 | 說明 |
|--------|------------|
| **解除安裝器** | 模式匹配引擎，可在 17 個以上的 Library 子目錄中找出每一個關聯檔案（包括安裝在廠商子資料夾中的應用）。支援徹底刪除、**重置為預設**（清除應用的快取和偏好設定但保留應用本身），以及未使用應用檢測 |
| **擴充功能** | 檢視第三方偏好設定面板、Internet 外掛和 Safari 擴充功能。使用者安裝的面板和外掛可移到廢紙簍 |
| **應用更新** | 透過已安裝應用自身的 Sparkle appcast 源檢查更新（只讀取版本資訊，不傳送任何關於你的資料） |

### 🗂️ 檔案
| 模組 | 說明 |
|--------|------------|
| **空間透視** | 以方形化樹狀圖視覺化磁碟佔用，可逐層下鑽瀏覽 |
| **大檔案與舊檔案** | 查詢大於 50 MB 的檔案，按大小和最後訪問日期排序 |
| **重複檔案** | 漸進式檢測（按大小分組、部分 SHA-256、完整雜湊、inode 校驗），並提供**合併**模式：在 APFS 上用寫時複製克隆回收空間，不刪除任何一份副本 |
| **檔案粉碎** | 安全擦除檔案，提供標準、永久和安全覆寫模式 |

### 📊 選單欄小元件

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Mac Sai 選單欄小元件" />
</p>

一個毛玻璃風格的選單欄小元件，讓你的 Mac 關鍵狀態一鍵可達。它是一個獨立程序，登入時啟動，可從應用側邊欄開關，無需開啟主視窗即可隨時檢視。

- **即時狀態環**：CPU 負載、記憶體壓力、磁碟佔用和電池，以 2x2 環形網格呈現（`host_processor_info`、`vm_statistics64`、APFS 容量、IOKit 電源），按綠 → 黃 → 紅分級著色
- **可配置讀數**：可選擇顯示可用磁碟、GPU 使用率、記憶體使用率或電池溫度；選擇會儲存，不可用的感測器顯示 `--`
- **網路、執行時間與交換空間**：即時上/下行吞吐、系統執行時間、交換空間使用
- **建議**：可操作、可關閉的提示（“使用者快取已增長到 2.52 GB，執行系統垃圾清理”），點選即可執行，關閉後 30 天內不再提示
- **防護狀態**：上次惡意軟體掃描時間和威脅數量，按時效著色
- **已連線裝置**：一眼檢視外接卷（含剩餘空間）和外接顯示器
- **健康提醒**：當磁碟空間嚴重不足或記憶體壓力持續偏高時發出通知（已限流、可選啟用）

### ⌨️ 鍵盤快捷鍵

| 快捷鍵 | 操作 |
|----------|--------|
| **⌘R** | 在當前模組開始掃描 |
| **⌘K** | 清理當前選中項（有結果時） |
| **⌘1 至 ⌘9** | 跳到側邊欄前九個模組 |
| **⌘,** | 開啟設定 |

---

## Mac Sai 橫向對比

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **價格** | 免費 | $39.95/年 | 免費 | 免費 | 免費 | 免費（命令列） |
| **開源** | ✅ BSD-3 | ❌ | ✅ Fair-code | ✅ MIT | ❌ | ✅ MIT |
| **遙測** | ❌ 無 | ⚠️ 有 | ❌ 無 | ❌ 無 | ❌ 無 | ❌ 無 |
| **原生圖形應用** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ 命令列（圖形介面另售） |
| **智慧掃描（一鍵）** | ✅ | ✅ | ❌ | ➖ 部分 | ❌ | ➖ 互動式命令列 |
| **系統垃圾（16+ 類別）** | ✅ | ✅ | ➖ | ✅ | ➖ 有限 | ✅ |
| **Universal Binary 瘦身** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **惡意軟體掃描** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **瀏覽器隱私清理** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **帶殘留檢測的解除安裝器** | ✅ | ✅ | ✅ 專注 | ❌ | ❌ | ✅ |
| **重複檔案查詢（含合併）** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **磁碟樹狀圖視覺化** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ 分析器 |
| **選單欄系統監視器** | ✅ | ✅ 選單 | ❌ | ❌ | ❌ | ❌ |
| **維護指令碼** | ✅ | ✅ | ❌ | ❌ | ✅ 強大 | ➖ |
| **經 Apple 公證** | ✅ | ✅ | ✅ | ✅ | ✅ | 不適用 |
| **macOS 版本** | 14+ | 13+ | 13+ | 13+ | 視情況 | 視情況 |

> CleanMyMac 是一款很棒的產品，願意為打磨精良、有官方支援的體驗付費的使用者理應讓他們獲得收入。Mac Sai 則面向所有更希望擁有透明原始碼、零訂閱的人。

---

## 安裝

### Homebrew（推薦）

Mac Sai 已收錄進官方 Homebrew cask，無需 tap：

```bash
brew install --cask mac-sai
```

它已經過 Apple 公證，可從聚焦或“應用程式”直接啟動，沒有警告，也無需額外步驟。

<details>
<summary><strong>其他安裝方式</strong>（一行指令碼、DMG、從原始碼構建）</summary>

<br>

**一行安裝指令碼**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

會下載最新的 DMG 並將應用安裝到 `/Applications`。

**下載 DMG**

從 [Releases](https://github.com/iliyami/MacSai/releases/latest) 下載最新的 DMG，將 Mac Sai 拖入“應用程式”資料夾。

**從原始碼構建**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # 執行完整的 862 個測試
bash scripts/build-dmg.sh      # 構建本地 DMG（未簽名）
```

需要 Swift 6 工具鏈（Xcode 16+）。

**之前透過舊的 tap 安裝的？**

現在 Mac Sai 已進入官方 cask，可以移除它：`brew untap iliyami/macsai`（不影響已安裝的應用和後續的 `brew upgrade`）。

</details>

### 授予完全磁碟訪問權限

部分模組（郵件附件、隱私、惡意軟體）需要完全磁碟訪問權限才能掃描受保護區域：

1. 開啟 **系統設定、隱私與安全性、完全磁碟訪問權限**
2. 點選 **+**，新增 **Mac Sai.app**
3. 重新啟動 Mac Sai

### 解除安裝

Homebrew 安裝：

```bash
brew uninstall --zap --cask mac-sai
```

DMG 或手動安裝（也能處理 Homebrew 安裝）：

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

兩者都會刪除 Mac Sai 及其在 `~/Library` 下的偏好設定、快取、日誌和資料庫。

---

## 已簽名、已公證，值得信任

Mac Sai 使用 Apple **Developer ID** 進行程式碼簽名，並經 **Apple 公證**。對於清理類應用而言，這一點比幾乎任何你安裝的軟體都更重要，因為你即將賦予它對檔案的深度訪問權限，你有權確認執行在你 Mac 上的確實是我們的、且未被篡改的版本。以下這些都由你自己的 Mac 強制執行，而不僅僅是我們的承諾：

- **Apple 已掃描過它。** 每個版本都會提交給 Apple 並在釋出前檢查惡意軟體。
- **它無法被篡改。** 簽名是覆蓋每個檔案的加密封印；哪怕改動一個位元組，macOS 也會拒絕開啟。
- **它確實來自我們。** 簽名繫結到我們的 Apple 開發者身份，任何其他人都無法釋出你的 Mac 會當作 Mac Sai 接受的東西。
- **開箱即用。** 沒有 Gatekeeper 警告，無需右鍵開啟，也無需終端命令。

再加上完全開源，這是一條你無需盲信的信任鏈：程式碼公開、我們對每個版本簽名、Apple 進行驗證、而你的 Mac 在每次開啟時都會重新校驗這個封印。

### 自行驗證無遙測

不必只聽我們說，原始碼和執行中的程序都可以核對。

**1. 在原始碼中搜尋網路 API**

```bash
rg -n 'URLSession|NSURLConnection' Sources --glob '*.swift'
```

你應當只會看到兩條網路路徑，二者都是可選且只讀的：

- `Sources/MacCleanKit/UpdateChecker.swift`：可選的 Mac Sai 更新檢查（可在設定中關閉）
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`：開啟“應用更新”模組時，由使用者觸發的對其它應用 Sparkle 源的檢查

程式碼庫中沒有任何分析、崩潰上報或追蹤 SDK。

**2. 觀察即時程序**

```bash
lsof -i -P -n | grep -i 'MacClean\|Mac Sai\|MacSai' || echo "no network sockets"
```

預期：僅做本地清理時沒有已建立的連線。Little Snitch 或 LuLu 可做同樣的視覺化檢查。

**3. 檢查你實際安裝的二進位制檔案**

原始碼和簽名後的二進位制檔案是兩個不同的產物，因此最有力的檢查是針對你磁碟上的應用，而不是這個倉庫。執行 `brew install --cask mac-sai` 之後：

```bash
APP="/Applications/Mac Sai.app/Contents/MacOS/MacClean"

# 二進位制檔案匯入的網路類（只會出現 URLSession）：
nm -u "$APP" | grep -iE 'URLSession|NWConnection|CFSocket' | sort -u

# 編譯進二進位制檔案的所有 URL（只有兩個更新端點會被請求）：
strings -a "$APP" | grep -iE 'https?://' | sort -u
```

預期：唯一的網路類是 `_OBJC_CLASS_$_NSURLSession`，唯一會被請求的端點是 `api.github.com/repos/iliyami/MacSai/releases/latest` 和 `formulae.brew.sh/api/cask/mac-sai.json`。其餘的 `github.com/iliyami/MacSai` 連結只會在瀏覽器中開啟。沒有任何跟蹤器或分析域名，也沒有其他東西。更新後可以再次執行，它始終反映你正在執行的確切構建。

注意：對於本應用這樣未啟用沙盒的 Developer ID 應用，網路訪問不受 entitlement 限制，因此真正的檢查是這種符號和字串檢查，而不是 `codesign --entitlements`。同樣的守衛會在每次改動時於 CI 中執行（[`scripts/check-network-surface.sh`](scripts/check-network-surface.sh)）。

---

## 架構

```
Mac Sai
├── MacClean          主 SwiftUI 應用（17 個模組）
├── MacCleanKit       共享框架（模型、常量、協議）
├── MacCleanHelper    XPC 特權助手（用於 root 操作的 LaunchDaemon）
└── MacCleanMenu      選單欄監視器（獨立程序）
```

### 技術棧

| 層 | 技術 |
|-------|-----------|
| 語言 | Swift 6，嚴格併發 |
| UI | SwiftUI + AppKit 混合 |
| 併發 | Actor、TaskGroup、async/await、`@Sendable` |
| 資料庫 | GRDB.swift（SQLite），WAL 模式 |
| 檔案掃描 | 基於 APFS 的 `URLResourceKey` 預取 |
| 增量更新 | FSEvents，支援歷史回放 |
| 特權操作 | SMAppService + NSXPCConnection |
| 系統統計 | Mach API（`host_processor_info`、`vm_statistics64`、`proc_pidinfo`） |

### 安全模型

Mac Sai 的設計目標是**絕不造成資料丟失**：

- **受保護路徑黑名單**：`/System`、`/usr`、`/bin`、`/sbin` 以及 Apple 系統應用不可觸碰，並對 macOS firmlink 做規範化，使符號連結重定向檢測不會誤判合法系統路徑
- **掃描前的可清理性過濾**：當前程序無法移入廢紙簍的專案（系統快取中 root 擁有的子項、`~/Library/Caches/com.apple.*` 下被資料保險庫保護的目錄）在掃描時即被剔除，絕不會作為“可清理”出現
- **優先移入廢紙簍**：所有刪除預設進入廢紙簍，預演模式可在不觸碰任何檔案的前提下預覽
- **TOCTOU 防護**：刪除前立即重新解析符號連結
- **排除資料夾**：可在設定中選擇讓掃描完全跳過的資料夾，`SafetyGuard` 還會拒絕刪除這些資料夾下的任何內容
- **分塊、可取消的清理**：大批次選擇會拆分為每批 5000 項，在批次之間遵循取消；點選取消後掃描約在一秒內回到空閒
- **應用內活動日誌**：清理過程中的每個錯誤都會記錄完整路徑，可在清理後介面檢視並複製，日誌 30 天后自動清理
- **核心強制的 XPC 閘門**：特權助手使用 `NSXPCListener.setCodeSigningRequirement`，由核心本身拒絕任何程式碼簽名與主應用識別符號和團隊不匹配的連線

---

## 測試

```bash
swift test
```

基於 XCTest 的測試套件包含 **862 個測試**，並把 `SafetyGuard` 和 `CleaningEngine`（生死攸關的檔案）視為必須完美：對符號連結、路徑穿越、NULL 位元組、SIP、受保護應用、檔案數量上限、TOCTOU 和冪等性的對抗式覆蓋，外加對預演 / 移入廢紙簍 / 永久刪除清理、掃描狀態機、每一個系統垃圾類別、樹狀圖演算法、解除安裝器匹配引擎、重複檔案檢測、appcast 解析，以及完整的“從合成夾具到清理”端到端流程的整合覆蓋。測試夾具（`withTempHome`、`withFakeApp`、`withFakePlist`）確保每個測試都不會觸碰你真實的個人目錄。

---

## 參與貢獻

非常歡迎貢獻。請閱讀[貢獻指南](CONTRIBUTING.md)，然後：

1. Fork 倉庫並建立功能分支
2. 進行修改（每個 PR 聚焦一件事，便於審閱）
3. 執行 `swift test`
4. 提交 Pull Request

這裡還有一個開放的[功能投票](https://github.com/iliyami/MacSai/issues/55)：為你希望接下來構建的工具點 👍。

## 許可證

BSD 3-Clause。詳見 [LICENSE](LICENSE)。你可以使用、修改和再分發本程式碼，但須保留版權與許可證文字，且未經許可不得使用“Mac Sai”名稱或貢獻者姓名為衍生產品背書。

## 致謝

靈感來自開源 Mac 實用工具社群：

- [Pearcleaner](https://github.com/alienator88/Pearcleaner)：應用解除安裝模式
- [Mole](https://github.com/tw93/Mole)：清理類別
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner)：模組化架構
- 方形化樹狀圖演算法，作者 Bruls、Huizing 與 van Wijk（2000）

## Star 歷史

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
  <strong>Mac Sai 是由社群、為社群打造的免費軟體。</strong><br>
  如果它幫你省下了一筆訂閱費，點個 ⭐ 能幫助更多人發現它。
</p>
