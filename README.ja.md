<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Mac Sai アイコン" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>オープンソースの Mac クリーナー、最適化ツール、マルウェアスキャナ。</strong><br>
  CleanMyMac に代わる、Apple の公証を受けた無料アプリ。Swift 6 と SwiftUI で開発されています。<br>
  <sub>125,000+ 回ダウンロード。ずっと無料で、テレメトリは一切ありません。</sub>
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-Hant.md">繁體中文</a> | <a href="README.de.md">Deutsch</a> | <a href="README.fr.md">Français</a> | <a href="README.ru.md">Русский</a> | <a href="README.es.md">Español</a> | <a href="README.it.md">Italiano</a> | <a href="README.pt-BR.md">Português (Brasil)</a> | <strong>日本語</strong> | <a href="README.ko.md">한국어</a> | <a href="README.tr.md">Türkçe</a> | <a href="README.fa.md">فارسی</a>
</p>

<p align="center">
  <a href="https://iliyami.github.io/MacSai/ja/"><img src="https://img.shields.io/badge/website-iliyami.github.io%2FMacSai-7c5cff?style=flat-square" alt="Website" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/downloads/iliyami/MacSai/total?style=flat-square&label=downloads&color=2ea44f" alt="Total downloads" /></a>
  <a href="https://github.com/iliyami/MacSai/stargazers"><img src="https://img.shields.io/github/stars/iliyami/MacSai?style=flat-square&color=gold" alt="GitHub stars" /></a>
  <a href="https://formulae.brew.sh/cask/mac-sai"><img src="https://img.shields.io/homebrew/cask/installs/dm/mac-sai?style=flat-square&label=homebrew&color=orange" alt="Homebrew installs" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/v/release/iliyami/MacSai?style=flat-square&color=blue" alt="Latest release" /></a>
  <a href="https://github.com/iliyami/MacSai/graphs/commit-activity"><img src="https://img.shields.io/github/commit-activity/m/iliyami/MacSai?style=flat-square&label=commits" alt="Commit activity" /></a>
  <br>
  <img src="https://img.shields.io/badge/Apple-notarized-black?style=flat-square&logo=apple" alt="Notarized" />
  <img src="https://img.shields.io/badge/telemetry-none-brightgreen?style=flat-square" alt="No telemetry" />
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey?style=flat-square" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6-orange?style=flat-square" alt="Swift 6" />
  <a href="https://github.com/iliyami/MacSai/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/iliyami/MacSai/ci.yml?branch=main&style=flat-square&label=tests" alt="Tests" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-BSD--3--Clause-green?style=flat-square" alt="License" /></a>
</p>

<p align="center">
  <img src="assets/demo.png" width="720" alt="Mac Sai のスクリーンショット" />
</p>

<p align="center">
  <strong>コマンド1つでインストール：</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  または<a href="https://github.com/iliyami/MacSai/releases/latest">最新の DMG</a> をダウンロードしてください。Apple の公証を受けているため、右クリックも警告もターミナルも不要で、そのまま開けます。
</p>

<p align="center">
  <sub>アプリ内に広告が入ることは今後もありません。このページには<a href="SPONSORS.md">審査制のスポンサー枠が1つ</a>あり、現在募集中です。</sub>
</p>

---

## Mac Sai を選ぶ理由

高機能な Mac クリーナーのために年額のサブスクリプションを払ったり、ファイルへの深いアクセス権を中身の見えないブラックボックスに預けたりする必要はありません。Mac Sai は、すべてのツールをオープンな形で提供します。

- **ずっと無料**。サブスクリプションも、アプリ内課金も、「Pro にアップグレード」も、しつこい催促画面もありません。BSD-3 ライセンスです。
- **テレメトリなし**。アナリティクスも、クラッシュレポーターも、トラッカーも、データを送信する先のサーバーもありません。私たちの言葉を鵜呑みにする必要はありません。2つのコマンドで[ご自身で確認](#テレメトリがないことを自分で確認する)できます。
- **CleanMyMac の主要ツールをすべて1つのアプリに**。クリーンアップ、保護、パフォーマンス、アプリケーション、ディスク分析にわたる22のモジュールに加え、メニューバーウィジェットも備えています。
- **設計段階から安全**。まずゴミ箱に移す削除方式、保護パスのブロックリスト、シンボリックリンクと TOCTOU への対策、そしてすべてのパスを検証する `SafetyGuard` を備えています。データを決して失わないように作られています。
- **Apple の公証済みで、完全なオープンソース**。Mac は起動のたびに署名を検証し、すべてのコードをここで読むことができます。

---

## 機能一覧

<table>
<tr>
<td width="33%" valign="top">

### 🧹 クリーンアップ
- **スマートスキャン**（ワンクリック）
- **システムの不要ファイル**（16+ カテゴリ）
- **メールの添付ファイル**
- **ゴミ箱**
- **プロジェクトの不要ファイル**（ビルドフォルダ）
- **開発用ストレージ**（Docker、シミュレータ）
- **クリーンアップ履歴**（ワンクリックで復元）

</td>
<td width="33%" valign="top">

### 🛡️ 保護
- **マルウェアの削除**
- **プライバシー**（ブラウザ）
- **ブラウザ拡張機能**
- **保存済み Wi-Fi**
- **アクセス権の概要**

</td>
<td width="33%" valign="top">

### ⚡ パフォーマンス
- **最適化**（ログイン項目）
- **メンテナンス**（システムタスク）

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 アプリケーション
- **アンインストーラー**（+ デフォルトにリセット）
- **未使用のアプリ**
- **拡張機能**（設定パネル、プラグイン）
- **アップデート**

</td>
<td width="33%" valign="top">

### 🗂️ ファイル
- **ディスク使用状況**（ディスクのツリーマップ）
- **大きくて古いファイル**
- **重複**（+ 統合）
- **ファイルシュレッダー**

</td>
<td width="33%" valign="top">

### 📊 メニューバー
- CPU / メモリ / ディスク / バッテリーをリアルタイム表示
- ネットワーク、稼働時間、スワップ
- すぐに実行できるおすすめ

</td>
</tr>
</table>

---

## 機能の詳細

### 🧹 クリーンアップ
| モジュール | 機能 |
|--------|------------|
| **スマートスキャン** | ワンクリックでクリーンアップ、保護、パフォーマンスの各モジュールをまとめて実行し、進行状況をリアルタイムで表示したうえで、モジュールごとに解放した容量を正確に示します |
| **システムの不要ファイル** | 16+ のスキャンカテゴリ：ユーザーとシステムのキャッシュ、ログ、言語ファイル、破損した環境設定、壊れたログイン項目、書類のバージョン、iOS バックアップ、Xcode の不要ファイル、パッケージマネージャ / IDE / AI ツールのキャッシュ、削除済みユーザーの残留ファイル、そして **ユニバーサルバイナリの軽量化**（arm64 と x86_64 の両方を含む fat Mach-O バイナリを見つけ、`lipo` でお使いの Mac のネイティブアーキテクチャ用に書き換えます。キャンセルにも対応） |
| **メールの添付ファイル** | Apple Mail、Outlook、Spark にキャッシュされた添付ファイルを見つけます |
| **ゴミ箱** | 外付けドライブを含む、すべての場所のゴミ箱を空にします |
| **プロジェクトの不要ファイル** | プロジェクト全体から再生成可能なビルドフォルダを見つけます：`node_modules`、`.next`、`dist`、Rust と Maven の `target`、Gradle の `build`、Python の仮想環境（virtualenv）、CocoaPods の `Pods`。隣にあるファイルからプロジェクトの種類を確認できた場合にのみ対象となり、`dist` と `Pods` は `.gitignore` に記載されている場合に限ります。すべてゴミ箱に移動されます |
| **開発用ストレージ** | Docker と Xcode シミュレータが使用している容量を表示します。停止中のコンテナ、未使用（dangling）のイメージ、未使用のビルドキャッシュを削除し（それぞれ確認後に実行）、利用できないシミュレータと古いシミュレータランタイムも削除します。Docker ボリュームと各プラットフォームの最新ランタイムには一切手を触れません |
| **クリーンアップ履歴** | 最近のクリーンアップ（過去30日間、最大20件）を一覧表示し、1回分のクリーンアップ全体をワンクリックでゴミ箱から元に戻せます。履歴は Mac 上の `~/Library/Logs/MacClean/clean-history.json` に保存され、あなたのユーザーアカウントからのみ読み取り可能で、どこにも送信されません |

### 🛡️ 保護
| モジュール | 機能 |
|--------|------------|
| **マルウェアの削除** | 3段階の深さ（クイック / バランス / 詳細）によるシグネチャベースのスキャン：起動エージェントとデーモン、アプリバンドル、ブラウザ拡張機能、既知のアドウェア / マルウェアのパターンを調べます。Mac にすでにある Apple の XProtect シグネチャとのハッシュ完全一致をオフラインで照合し、オプションで MalwareBazaar（abuse.ch）のハッシュフィードも利用できます。Apple のブロックリストに載っている Safari 拡張機能と MalwareBazaar に一致したものは確認用に一覧表示され、事前に選択されることはありません（ウイルス対策ソフトではなく、アプリでもそう明示しています） |
| **プライバシー** | Safari、Chrome、Firefox の履歴、Cookie、キャッシュを、期間を指定して消去します。Safari の**ブックマークには一切手を触れません** |
| **ブラウザ拡張機能** | Safari、Chrome、Brave、Edge、Arc、Firefox にインストールされている拡張機能を一覧表示します。自分でインストールした Chromium と Firefox の拡張機能は、そのブラウザを終了している間にゴミ箱へ移動できます。ポリシーやブラウザ自体によってインストールされたものは表示のみで、そのまま残します。Safari 拡張機能は Safari の設定へのリンクを表示します |
| **保存済み Wi-Fi** | 優先するワイヤレスネットワークを一覧表示し、選んだネットワークを削除します |
| **アクセス権の概要** | 各アプリが持つプライバシー（TCC）権限をアプリごとに確認できる読み取り専用のビューで、システム設定では得られない視点を提供します。各操作はシステム設定の該当箇所へ直接リンクし、切り替え自体はシステム設定で行います |

### ⚡ パフォーマンス
| モジュール | 機能 |
|--------|------------|
| **最適化** | ログイン項目と起動エージェントを、項目ごとに有効化 / 無効化して管理します |
| **メンテナンス** | システムタスク：RAM の解放、メンテナンススクリプトの実行、起動ディスクの検証、Launch Services の再構築、Spotlight のインデックス再作成、DNS キャッシュの消去、Time Machine スナップショットの削減。タスクには重要度のタグが付き、「安全なタスクを実行」は1つずつ順番に実行され、管理者パスワードは**一度だけ**求められます |

### 📦 アプリケーション
| モジュール | 機能 |
|--------|------------|
| **アンインストーラー** | パターンマッチングエンジンが、17+ の Library サブディレクトリ（ベンダーのサブフォルダ内にあるアプリを含む）から関連ファイルをすべて見つけます。完全な削除、**デフォルトにリセット**（アプリ本体は残したまま、キャッシュと環境設定を消去）、未使用アプリの検出に対応しています |
| **未使用のアプリ** | Spotlight の最終使用日をもとに、3、6、12ヶ月間開いていないアプリをサイズ順に表示します。実行中のアプリは表示されず、Spotlight に使用データがない場合は推測せずにその旨を表示します。ワンクリックでアプリをアンインストーラーに渡せます |
| **拡張機能** | サードパーティの設定パネル、インターネットプラグイン、Safari 拡張機能を確認できます。ユーザーがインストールした設定パネルとプラグインはゴミ箱に移動できます |
| **アップデート** | インストール済みアプリのアップデートを、各アプリ独自の Sparkle appcast フィードで確認します（バージョン情報を読み取るだけで、あなたに関する情報は何も送信しません） |

### 🗂️ ファイル
| モジュール | 機能 |
|--------|------------|
| **ディスク使用状況** | ディスク使用量を Squarified ツリーマップで視覚化し、ドリルダウンで掘り下げて確認できます |
| **大きくて古いファイル** | 50 MB を超えるファイルを見つけ、サイズと最終アクセス日で並べ替えて表示します |
| **重複** | 段階的な検出（サイズによるグループ化、部分的な SHA-256、完全なハッシュ、inode の検証）に加え、コピーを1つも削除せずに APFS のコピーオンライトクローンで容量を取り戻す **統合** モードを備えています |
| **ファイルシュレッダー** | 標準、完全削除、安全な上書きの各モードによる安全なファイル消去 |

### 📊 メニューバーウィジェット

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Mac Sai メニューバーウィジェット" />
</p>

Mac の状態をワンクリックで確認できる、グラスモーフィズムデザインのメニューバーウィジェットです。ログイン時に起動する独立したプロセスで、アプリのサイドバーからオン / オフを切り替えられるため、状態を確認するだけのためにメインウィンドウを開く必要はありません。

- **リアルタイムのステータスリング**：CPU 負荷、メモリプレッシャー、ディスク使用量、バッテリーを 2x2 のリンググリッドで表示します（`host_processor_info`、`vm_statistics64`、APFS の容量、IOKit の電源情報）。緑から黄、赤へと色分けされます
- **表示項目のカスタマイズ**：空きディスク容量、GPU 使用率、メモリ使用量、バッテリー温度から選べます。選択は保持され、利用できないセンサーは `--` と表示されます
- **ネットワーク、稼働時間、スワップ**：リアルタイムのアップロード / ダウンロード速度、システムの稼働時間、スワップ使用量
- **おすすめ**：すぐに実行でき、非表示にもできるヒント（「ユーザーキャッシュが 2.52 GB に増えました。システムの不要ファイルを実行してください」）。ワンタップで実行でき、非表示にすると30日間は表示されません
- **保護ステータス**：前回のマルウェアスキャンの日時と脅威の数を、経過時間に応じて色分けして表示します
- **接続中のデバイス**：外部ボリューム（空き容量付き）とディスプレイをひと目で確認できます
- **ヘルスアラート**：ディスクの空き容量が極端に少なくなったときや、メモリプレッシャーが高い状態が続いたときに、頻度を抑えて通知します（オプトイン）

### ⌨️ キーボードショートカット

| ショートカット | 操作 |
|----------|--------|
| **⌘R** | 現在のモジュールでスキャンを開始 |
| **⌘K** | 現在の選択項目をクリーンアップ（結果が表示されているとき） |
| **⌘1〜⌘9** | サイドバーの最初の9つのモジュールに移動 |
| **⌘,** | 設定を開く |

---

## Mac Sai と他のアプリの比較

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **価格** | 無料 | $39.95/年 | 無料 | 無料 | 無料 | 無料（CLI） |
| **オープンソース** | ✅ BSD-3 | ❌ | ✅ Fair-code | ✅ MIT | ❌ | ✅ MIT |
| **テレメトリ** | ❌ なし | ⚠️ あり | ❌ なし | ❌ なし | ❌ なし | ❌ なし |
| **ネイティブ GUI アプリ** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ CLI（GUI は別売の有料版） |
| **スマートスキャン（ワンクリック）** | ✅ | ✅ | ❌ | ➖ 一部 | ❌ | ➖ 対話型 CLI |
| **システムの不要ファイル（16+ カテゴリ）** | ✅ | ✅ | ➖ | ✅ | ➖ 限定的 | ✅ |
| **ユニバーサルバイナリの軽量化** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **マルウェアスキャナ** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **ブラウザのプライバシークリーナー** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **残留ファイル検出付きアンインストーラー** | ✅ | ✅ | ✅ 主力機能 | ❌ | ❌ | ✅ |
| **重複ファイル検出（+ 統合）** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **ディスクのツリーマップ表示** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ アナライザー |
| **メニューバーのシステムモニター** | ✅ | ✅ メニュー | ❌ | ❌ | ❌ | ❌ |
| **メンテナンススクリプト** | ✅ | ✅ | ❌ | ❌ | ✅ 充実 | ➖ |
| **Apple による公証** | ✅ | ✅ | ✅ | ✅ | ✅ | N/A |
| **macOS バージョン** | 14+ | 13+ | 13+ | 13+ | バージョンにより異なる | バージョンにより異なる |

> CleanMyMac は優れた製品です。洗練された、サポート付きの体験を求める方は、ぜひ購入してください。Mac Sai は、透明性のあるソースコードとサブスクリプション不要を望むすべての人のためのアプリです。

---

## インターフェース言語

「設定」→「インターフェース言語」で、システム、English、简体中文、繁體中文、Русский、Deutsch、Français、Español、Italiano、Português (Brasil)、Türkçe、日本語、한국어、فارسی から選択できます。英語、簡体字中国語、ロシア語はインターフェース全体に対応しています。その他の言語では静的なインターフェース文字列が翻訳されており、値を埋め込むメッセージは現時点では英語の文言と複数形のルールのままです（繁体字中国語では簡体字中国語が代わりに表示されます）。メインウィンドウとメニューバーウィジェットは同じ言語設定を共有します。ペルシア語ではインターフェースが右から左に表示されます。

## インストール

### Homebrew（推奨）

Mac Sai は Homebrew の公式 cask に含まれているため、tap は不要です：

```bash
brew install --cask mac-sai
```

Apple の公証を受けているため、Spotlight やアプリケーションフォルダから、警告も追加の手順もなく起動できます。

<details>
<summary><strong>その他のインストール方法</strong>（ワンライナースクリプト、DMG、ソースからビルド）</summary>

<br>

**ワンライナーインストーラ**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

最新の DMG をダウンロードし、アプリを `/Applications` にインストールします。

**DMG のダウンロード**

[Releases](https://github.com/iliyami/MacSai/releases/latest) から最新の DMG を入手し、Mac Sai をアプリケーションフォルダにドラッグしてください。

**ソースからビルド**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # run the full 1,048-test suite
bash scripts/build-dmg.sh      # build a local DMG (unsigned)
```

Swift 6 ツールチェーン（Xcode 16+）が必要です。

**以前の tap からインストールした場合**

Mac Sai は現在公式の cask に含まれているため、tap は削除して構いません：`brew untap iliyami/macsai`（インストール済みのアプリや今後の `brew upgrade` には影響しません）。

</details>

### フルディスクアクセスの許可

一部のモジュール（メールの添付ファイル、プライバシー、マルウェア）は、保護された領域をスキャンするためにフルディスクアクセスが必要です：

1. **システム設定 > プライバシーとセキュリティ > フルディスクアクセス** を開きます
2. **+** をクリックして **Mac Sai.app** を追加します
3. Mac Sai を再起動します

### アンインストール

Homebrew でインストールした場合：

```bash
brew uninstall --zap --cask mac-sai
```

DMG または手動でインストールした場合（Homebrew でインストールした場合にも使えます）：

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

どちらの方法でも、Mac Sai 本体と、`~/Library` 以下にある環境設定、キャッシュ、ログ、データベースが削除されます。

---

## 署名と公証を受けた、信頼できるアプリ

Mac Sai は Apple の **Developer ID** でコード署名され、**Apple の公証**を受けています。クリーニングアプリでは、ほかのどんなアプリよりもこの点が重要です。ファイルへの深いアクセス権を与えることになるため、Mac で実行されているものが本当に私たちが作ったもので、改ざんされていないと確認できるべきだからです。これらはすべて、私たちが約束しているだけでなく、あなたの Mac 自身によって強制されています：

- **Apple がスキャン済み**。すべてのリリースは Apple に提出され、配布前にマルウェアのチェックを受けています。
- **改ざんできません**。署名はすべてのファイルにかけられた暗号学的な封印です。1バイトでも変更されると、macOS は開くことを拒否します。
- **私たちが作ったことを証明できます**。署名は私たちの Apple Developer ID に紐づいているため、他の誰かが、Mac に Mac Sai として受け入れられるものを配布することはできません。
- **そのまま動きます**。Gatekeeper の警告も、右クリックで開く操作も、ターミナルも不要です。

完全なオープンソースであることと合わせて、これは信じるしかない信頼ではなく、確かめられる信頼の連鎖です：コードは公開されており、私たちがすべてのリリースに署名し、Apple がそれを検証し、あなたの Mac がアプリを開くたびに封印を再確認します。

### テレメトリがないことを自分で確認する

私たちの言葉を鵜呑みにしないでください。ソースコードも、実行中のプロセスも確認できます。

**1. ソースコードでネットワーク API を検索する**

```bash
rg -n 'URLSession|NSURLConnection|Sparkle|SecTrustEvaluate' Sources --glob '*.swift'
```

オプションのネットワーク通信経路は以下のとおりです。ローカルでのクリーニングでは、スキャン結果やファイル一覧がアップロードされることはありません：

- `Sources/MacClean/Services/SelfUpdateController.swift`：Sparkle は、署名済みアプリに組み込まれた HTTPS フィードを確認し、署名済みのリリースノートとアップデートアーカイブをダウンロードします。自動確認と自動ダウンロード / インストールはそれぞれ別の設定です。システムプロファイリングとリリースノート内の JavaScript は無効化されています。[アップデートの設定](docs/IN_APP_UPDATES.md)を参照してください。設定済みの直接インストール版では、アップデートの自動確認はデフォルトでオンになっており、1日1回実行されます。各リクエストの User-Agent にはアプリと Sparkle のバージョンが含まれ、確認は設定でオフにできます。
- `Sources/MacCleanKit/UpdateChecker.swift`：Homebrew のアップデート確認と、署名済みフィードが設定されていないビルド向けのリリースページへのフォールバック
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`：アップデートモジュールを開いたときに、ユーザーの操作で行われる*他のアプリ*の Sparkle フィードの確認
- `Sources/MacCleanKit/MalwareBazaarFeed.swift`：オプトインの MalwareBazaar ハッシュのダウンロード。自分の abuse.ch Auth-Key を追加し、「設定」>「マルウェアデータベース」で「今すぐアップデート」を押したときにのみ実行されます。各リクエストで送信されるのは Auth-Key とクエリだけで、ファイルのハッシュやパスが送信されることはありません。ダウンロードしたハッシュが署名済みファイルと一致した場合、macOS は Gatekeeper と同じ確認として、その署名証明書が失効しているかどうかを Apple に問い合わせます。このリクエストは証明書に関するもので、あなたのファイルに関するものではありません

コードベースのどこにも、アナリティクス、クラッシュレポーター、トラッカーの SDK はありません。

**2. 実行中のプロセスを監視する**

```bash
(
MACSAI_APP=$(cd "/Applications/Mac Sai.app" && pwd -P) || exit 1
MACSAI_PIDS=$(ps -ww -axo pid=,comm= | awk -v bundle="$MACSAI_APP/" '
  { pid=$1; sub(/^[[:space:]]*[0-9]+[[:space:]]+/, "")
    if (index($0, bundle) == 1) print pid }' | paste -sd, -)
if [ -n "$MACSAI_PIDS" ]; then
  ps -p "$MACSAI_PIDS" -o pid=,comm=
  lsof -nP -a -p "$MACSAI_PIDS" -i
else
  echo "No running executables from this Mac Sai bundle"
fi
)
```

このスナップショットは、選択したアプリバンドル内の実行ファイルのパスで PID を選ぶため、無関係な Installer / Updater プロセスは除外されます。他の場所にコピーされた Sparkle のヘルパーや macOS の信頼サービスは、このスナップショットの対象外です。それらを観察するには、プロセスを識別できるファイアウォールを使ってください。短時間だけの接続を捉えるには、アップデートの確認中またはダウンロード中に実行してください。

アップデートの確認 / ダウンロードとオプションのマルウェア検証が動作していない状態では、ローカルでのクリーニングがネットワーク接続を開くことはありません。アップデートを観察する際は、Sparkle の子プロセスも含めてください。Apple の証明書確認は macOS の信頼サービスを通じて実行されます。Little Snitch や LuLu でも、これらの接続を確認できます。

**3. 実際にインストールしたバイナリを調べる**

DMG または Homebrew でインストールした場合、このループに必要なのは macOS のコマンドラインツールだけで、ソースのチェックアウトや Python は不要です。同梱されている7つのバイナリすべてを読み取り、よく使われるネットワーク関連のインポート、静的 URL、トラッカーの文字列を一覧表示するので、手動で確認できます：

```bash
(
MACSAI_APP="/Applications/Mac Sai.app"
MACSAI_SPARKLE="$MACSAI_APP/Contents/Frameworks/Sparkle.framework/Versions/B"
for MACSAI_BINARY in \
  "$MACSAI_APP/Contents/MacOS/MacClean" \
  "$MACSAI_APP/Contents/Library/LoginItems/MacCleanMenu.app/Contents/MacOS/MacCleanMenu" \
  "$MACSAI_SPARKLE/Sparkle" "$MACSAI_SPARKLE/Autoupdate" \
  "$MACSAI_SPARKLE/Updater.app/Contents/MacOS/Updater" \
  "$MACSAI_SPARKLE/XPCServices/Downloader.xpc/Contents/MacOS/Downloader" \
  "$MACSAI_SPARKLE/XPCServices/Installer.xpc/Contents/MacOS/Installer"
do
  printf '\n%s\n' "$MACSAI_BINARY"
  MACSAI_IMPORTS=$(nm -uj "$MACSAI_BINARY") || exit 1
  printf '%s\n' "$MACSAI_IMPORTS" | grep -Ei \
    'URLSession|URLConnection|CFNetwork|Network|nw_|DNSService|NetService|curl_|^_(socket|connect|connectx|send|recv)([$]|$)' || true
  MACSAI_STRINGS=$(strings -a "$MACSAI_BINARY") || exit 1
  printf '%s\n' "$MACSAI_STRINGS" | grep -Ei \
    '://|sentry|firebase|mixpanel|amplitude|bugsnag|crashlytics|posthog|appsflyer' || true
done
)
```

これらの一覧は合否を判定する監査ではなく、実行時のすべての接続先が見えることを証明するものでもありません。コンポーネントの完全な一覧、明示的な許可リスト、同梱のプライバシー設定を確認するには、以下の自動チェックを使ってください。

インストール済みのバージョンと一致するソースのチェックアウトから、チェックを実行してください。メインの実行ファイル、メニューヘルパー、`Sparkle.framework`、`Autoupdate`、`Updater.app`、`Downloader.xpc`、`Installer.xpc` を含む、実際のアプリバンドルを検査します：

```bash
bash scripts/check-network-surface.sh "/Applications/Mac Sai.app"
```

期待される結果：7つの Mach-O ファイルが合格します。欠落しているバイナリや想定外のバイナリ、リストにないネットワークインポートや静的 URL、トラッカーの痕跡があると、チェックは失敗します。URLSession のインポートが許可されているのは Mac Sai、そのメニューヘルパー、Sparkle、Downloader だけで、その他の Sparkle ヘルパーにはネットワークインポートが一切許可されていません。Sparkle のドキュメントへのリンクと XML 名前空間は明示的に識別され、ダウンロード先としては扱われません。

スクリプトは同梱の `SUFeedURL` も出力し、署名済みフィード、展開前の検証、プライバシーの各設定を検証します。そのフィードのアーカイブ / リリースノートの接続先と、確認をリクエストした他のアプリのフィードを、上記のライブ接続と照らし合わせてください。フォールバックのエンドポイントは `api.github.com/repos/iliyami/MacSai/releases/latest` と `formulae.brew.sh/api/cask/mac-sai.json` で、オプトインのマルウェア用エンドポイントは `mb-api.abuse.ch/api/v1/` です。プロジェクト / サポートへのリンクとブラウザ設定へのリンクは、リクエストしたときにのみ開きます。パッケージング時にも同じバンドル全体のチェックが実行され、CI ではビルドされた両方の実行ファイルと、バージョンを固定した5つの Sparkle バイナリすべてをチェックします。[チェックの実装と明示的な許可リスト](scripts/check-network-surface.py)。

---

## アーキテクチャ

```
Mac Sai
├── MacClean          Main SwiftUI app (22 modules)
├── MacCleanKit       Shared framework (models, constants, protocols)
├── MacCleanHelper    XPC privileged helper (LaunchDaemon for root ops)
└── MacCleanMenu      Menu-bar monitor (independent process)
```

### 技術スタック

| レイヤー | 技術 |
|-------|-----------|
| 言語 | Swift 6（strict concurrency） |
| UI | SwiftUI + AppKit のハイブリッド |
| 並行処理 | Actors、TaskGroup、async/await、`@Sendable` |
| データベース | GRDB.swift（SQLite）、WAL モード |
| ファイルスキャン | APFS 上での `URLResourceKey` のプリフェッチ |
| 差分更新 | FSEvents（履歴の再生付き） |
| 特権操作 | SMAppService + NSXPCConnection |
| システム統計 | Mach API（`host_processor_info`、`vm_statistics64`、`proc_pidinfo`） |

### 安全モデル

Mac Sai は**データを決して失わない**ように設計されています：

- **保護パスのブロックリスト**：`/System`、`/usr`、`/bin`、`/sbin`、および Apple のシステムアプリには一切手を触れません。macOS のファームリンクは正規化されるため、シンボリックリンクのリダイレクト検出が正当なシステムパスを誤検出することはありません
- **スキャン前のクリーンアップ可否フィルタ**：現在のプロセスがゴミ箱に移動できない項目（システムキャッシュ内の root 所有の子項目や、データ保護された `~/Library/Caches/com.apple.*` ディレクトリ）はスキャン時に除外されるため、クリーンアップ可能な項目として表示されることはありません
- **ゴミ箱優先の削除**：すべての削除はデフォルトでゴミ箱に移動され、ドライランモードでは何も変更せずにプレビューできます
- **TOCTOU 対策**：シンボリックリンクは削除の直前に再解決されます
- **除外フォルダ**：スキャンで完全にスキップするフォルダを設定で選択でき、さらに `SafetyGuard` はそれらのフォルダ以下にあるものの削除を拒否します
- **分割処理とキャンセルに対応したクリーンアップ**：大量の選択項目は5,000件ずつのチャンクに分割され、チャンクの合間にキャンセルを受け付けます。スキャンはキャンセルを押してから約1秒以内にアイドル状態に戻ります
- **アプリ内アクティビティログ**：クリーンアップ中のすべてのエラーはフルパス付きで記録され、クリーンアップ後の画面で表示・コピーでき、30日後に自動的に削除されます
- **カーネルが強制する XPC ゲート**：特権ヘルパーは `NSXPCListener.setCodeSigningRequirement` を使用するため、コード署名がアプリの識別子とチームに一致しない接続は、カーネル自体が拒否します

---

## テスト

```bash
swift test
```

XCTest スイートには **1,048 件のテスト**があり、`SafetyGuard` と `CleaningEngine`（データの生死を分けるファイル）は完璧でなければならないものとして扱っています。シンボリックリンク、パストラバーサル、NULL バイト、SIP、保護されたアプリ、ファイル数の上限、TOCTOU、べき等性を攻撃的な観点で網羅し、さらにドライラン / ゴミ箱 / 完全削除によるクリーニング、スキャンのステートマシン、システムの不要ファイルの全カテゴリ、ツリーマップの計算、アンインストーラーのマッチングエンジン、重複検出、appcast の解析、フィクスチャからクリーンアップまでのエンドツーエンドのサイクル全体を統合テストでカバーしています。フィクスチャ（`withTempHome`、`withFakeApp`、`withFakePlist`）により、どのテストも実際のホームディレクトリには触れません。

---

## コントリビュート

コントリビュートは大歓迎です。[コントリビューションガイドライン](CONTRIBUTING.md)を読んでから、次の手順に従ってください：

1. リポジトリをフォークし、機能ブランチを作成します
2. 変更を加えます（1つの PR につき1つの変更に絞ると、レビューが楽になります）
3. `swift test` を実行します
4. プルリクエストを作成します

[機能投票](https://github.com/iliyami/MacSai/issues/55)も実施中です：次に作ってほしいツールに 👍 を付けてください。

## ライセンス

BSD 3-Clause。[LICENSE](LICENSE) を参照してください。著作権表示とライセンス文を残し、許可なく「Mac Sai」の名前やコントリビューターの名前を派生製品の推奨や宣伝に使用しない限り、コードの使用、改変、再配布が可能です。

## 謝辞

オープンソースの Mac ユーティリティコミュニティから着想を得ています：

- [Pearcleaner](https://github.com/alienator88/Pearcleaner)：アプリのアンインストールのパターン
- [Mole](https://github.com/tw93/Mole)：クリーンアップのカテゴリ
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner)：モジュール型アーキテクチャ
- Bruls、Huizing、van Wijk による Squarified Treemap アルゴリズム（2000年）

## サポートとスポンサー

Mac Sai は無料で、これからも無料です：有料プランも、広告も、トラッキングもありません。クリーナーのサブスクリプションを払わずに済んだなら、[コーヒーをおごる ☕](https://buymeacoffee.com/iliyami) か、[メンバーになる](https://buymeacoffee.com/iliyami/membership)ことで応援していただけます。いただいた支援が、署名と公証を受けたリリースを届け続ける力になります。

### サポーター

メンバーには、舞台裏の投稿、各リリースの先行公開、オプトインのベータ版ビルド、そしてアプリ内へのお名前の掲載といった特典があります。アプリの機能がメンバーシップ限定になることは決してありません。

<p align="center">
  <em>まだメンバーはいません。</em> <a href="https://buymeacoffee.com/iliyami/membership">最初のメンバーになる →</a><br>
  <sub>Power User と Team のメンバーはここでご紹介します。全員の名前は <a href="SUPPORTERS.md">SUPPORTERS.md</a> に掲載しています。</sub>
</p>

### スポンサー枠

Mac Sai のスポンサー枠は**1つだけ**です。この README のすべての言語版で、ここと本ページの冒頭に表示されます。

<div align="center">
<table>
  <tr>
    <td align="center" width="25%"><h3>125,000+</h3><sub>ダウンロード</sub></td>
    <td align="center" width="25%"><h3>2,000+</h3><sub>GitHub スター</sub></td>
    <td align="center" width="25%"><h3>23,000</h3><sub>月間ページビュー</sub></td>
    <td align="center" width="25%"><h3>13</h3><sub>README の言語</sub></td>
  </tr>
</table>
</div>

訪問者の多くは開発者と Mac のパワーユーザーで、主に Google 検索から、次いで YouTube、GitHub、Reddit から訪れています。

- **スポンサーは一度に1社のみ**。ずらりと並んだロゴの中に、あなたの名前が埋もれることはありません。
- **審査制**。開発者ツール、プライバシーとセキュリティの製品、そしてユーザーを尊重する Mac アプリが対象です。クリーナーや「最適化」ツール、暗号資産、VPN のアフィリエイト案件、人を追跡するものは一切お断りしています。
- **アプリ内には決して表示しません**。Mac Sai には広告もテレメトリもなく、どのスポンサーもそれを変えることはありません。

<p align="center">
  <strong>この枠は現在募集中です。</strong> <a href="mailto:macsai.team@gmail.com?subject=Mac%20Sai%20sponsor">スポンサーになる →</a><br>
  <sub>オーディエンスの詳細と応募方法：<a href="SPONSORS.md">SPONSORS.md</a></sub>
</p>

## スター履歴

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
  <strong>Mac Sai は、コミュニティによる、コミュニティのためのフリーソフトウェアです。</strong><br>
  サブスクリプションを払わずに済んだなら、⭐ を付けていただくと他の人が見つけやすくなります。<a href="https://buymeacoffee.com/iliyami">コーヒー ☕</a> は開発の継続を支えます。
</p>
