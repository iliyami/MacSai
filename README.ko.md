<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Mac Sai 아이콘" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>오픈 소스 Mac 클리너, 최적화 도구, 악성코드 스캐너.</strong><br>
  Swift 6와 SwiftUI로 만든, Apple 공증을 받은 무료 CleanMyMac 대안입니다.<br>
  <sub>125,000+회 다운로드. 영원히 무료이며, 텔레메트리는 전혀 없습니다.</sub>
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-Hant.md">繁體中文</a> | <a href="README.de.md">Deutsch</a> | <a href="README.fr.md">Français</a> | <a href="README.ru.md">Русский</a> | <a href="README.es.md">Español</a> | <a href="README.it.md">Italiano</a> | <a href="README.pt-BR.md">Português (Brasil)</a> | <a href="README.ja.md">日本語</a> | <strong>한국어</strong> | <a href="README.tr.md">Türkçe</a> | <a href="README.fa.md">فارسی</a>
</p>

<p align="center">
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
  <img src="assets/demo.png" width="720" alt="Mac Sai 스크린샷" />
</p>

<p align="center">
  <strong>명령어 한 줄로 설치하기:</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  또는 <a href="https://github.com/iliyami/MacSai/releases/latest">최신 DMG</a>를 내려받으십시오. Apple의 공증을 받았으므로 바로 열립니다. 오른쪽 클릭도, 경고도, 터미널도 필요 없습니다.
</p>

<p align="center">
  <sub>앱에는 앞으로도 광고가 없습니다. 이 페이지에는 <a href="SPONSORS.md">엄선된 스폰서 자리가 하나</a> 있으며, 현재 비어 있습니다.</sub>
</p>

---

## 왜 Mac Sai인가요?

모든 기능을 갖춘 Mac 클리너라면 연간 구독료를 요구하거나, 파일에 깊이 접근하는 블랙박스를 믿어 달라고 요구해서는 안 됩니다. Mac Sai는 모든 도구를 투명하게 공개된 형태로 제공합니다.

- **영원히 무료.** 구독도, 앱 내 구입도, "Pro로 업그레이드"도, 귀찮은 알림 화면도 없습니다. BSD-3 라이선스입니다.
- **텔레메트리 제로.** 분석 도구도, 충돌 보고 도구도, 추적기도, 데이터를 보내는 서버도 없습니다. 저희 말을 그대로 믿을 필요도 없습니다. 명령어 두 개로 [직접 확인](#텔레메트리-없음을-직접-확인하기)할 수 있습니다.
- **CleanMyMac의 주요 도구를 모두 하나의 앱에.** 정리, 보호, 성능, 응용 프로그램, 디스크 분석에 걸친 22개 모듈과 메뉴 막대 위젯을 제공합니다.
- **설계부터 안전하게.** 휴지통 우선 삭제, 보호 경로 차단 목록, 심볼릭 링크 및 TOCTOU 방어, 모든 경로를 검증하는 `SafetyGuard`를 갖추고 있습니다. 데이터를 절대 잃지 않도록 만들어졌습니다.
- **Apple 공증 및 완전한 오픈 소스.** Mac이 실행할 때마다 서명을 검증하며, 모든 코드를 여기에서 읽을 수 있습니다.

---

## 기능 한눈에 보기

<table>
<tr>
<td width="33%" valign="top">

### 🧹 정리
- **Smart Scan** (클릭 한 번)
- **System Junk** (16개 이상의 카테고리)
- **Mail Attachments**
- **Trash Bins**
- **Project Junk** (빌드 폴더)
- **Disk Hogs** (Docker, 시뮬레이터)
- **Clean History** (클릭 한 번으로 복원)

</td>
<td width="33%" valign="top">

### 🛡️ 보호
- **Malware Removal**
- **Privacy** (브라우저)
- **Browser Extensions**
- **Saved Wi-Fi**
- **Permissions Overview**

</td>
<td width="33%" valign="top">

### ⚡ 성능
- **Optimization** (로그인 항목)
- **Maintenance** (시스템 작업)

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 응용 프로그램
- **Uninstaller** (+ 기본값으로 재설정)
- **Unused Apps**
- **Extensions** (환경설정 패널, 플러그인)
- **Updater**

</td>
<td width="33%" valign="top">

### 🗂️ 파일
- **Space Lens** (디스크 트리맵)
- **Large & Old Files**
- **Duplicates** (+ 통합)
- **Shredder**

</td>
<td width="33%" valign="top">

### 📊 메뉴 막대
- 실시간 CPU / 메모리 / 디스크 / 배터리
- 네트워크, 가동 시간, 스왑
- 바로 실행할 수 있는 권장 사항

</td>
</tr>
</table>

---

## 기능 상세

### 🧹 정리
| 모듈 | 기능 |
|--------|------------|
| **Smart Scan** | 클릭 한 번으로 정리, 보호, 성능 모듈을 함께 실행하고 진행 상황을 실시간으로 보여 주며, 완료 후 모듈별로 확보한 공간을 정확히 표시합니다 |
| **System Junk** | 16개 이상의 스캔 카테고리: 사용자 및 시스템 캐시, 로그, 언어 파일, 손상된 환경설정, 손상된 로그인 항목, 문서 버전, iOS 백업, Xcode 불필요한 파일, 패키지 관리자 / IDE / AI 도구 캐시, 삭제된 사용자의 잔여 파일, 그리고 **Universal Binary 축소** (arm64와 x86_64를 모두 포함한 fat Mach-O 바이너리를 찾아 `lipo`로 사용자의 네이티브 아키텍처용으로 다시 작성하며, 취소를 지원합니다) |
| **Mail Attachments** | Apple Mail, Outlook, Spark에 캐시된 첨부 파일을 찾습니다 |
| **Trash Bins** | 외장 드라이브를 포함한 모든 위치의 휴지통을 비웁니다 |
| **Project Junk** | 프로젝트 전반에서 다시 생성할 수 있는 빌드 폴더를 찾습니다: `node_modules`, `.next`, `dist`, Rust 및 Maven `target`, Gradle `build`, Python virtualenv, CocoaPods `Pods`. 옆에 있는 파일로 프로젝트 유형이 확인될 때만 대상으로 간주하며, `dist`와 `Pods`는 `.gitignore`에 명시된 경우에만 해당합니다. 모든 항목은 휴지통으로 이동합니다 |
| **Disk Hogs** | Docker와 Xcode 시뮬레이터가 차지하는 공간을 보여 줍니다. 중지된 컨테이너, 댕글링 이미지, 댕글링 빌드 캐시를 정리하고(각각 확인 절차를 거칩니다), 사용할 수 없는 시뮬레이터와 오래된 시뮬레이터 런타임을 삭제합니다. Docker 볼륨과 각 플랫폼의 최신 런타임은 절대 건드리지 않습니다 |
| **Clean History** | 최근 정리 내역(최근 30일, 최대 20개)을 보여 주며, 클릭 한 번으로 정리 전체를 휴지통에서 되돌립니다. 기록은 Mac의 `~/Library/Logs/MacClean/clean-history.json`에 보관되고, 사용자 계정만 읽을 수 있으며, 어디로도 전송되지 않습니다 |

### 🛡️ 보호
| 모듈 | 기능 |
|--------|------------|
| **Malware Removal** | 3단계 깊이(빠르게 / 균형 / 정밀)의 시그니처 기반 스캔: 실행 에이전트와 데몬, 앱 번들, 브라우저 확장 프로그램, 알려진 애드웨어/악성코드 패턴을 검사합니다. Mac에 이미 있는 Apple XProtect 시그니처와 정확한 해시로 오프라인 대조하며, 선택적으로 MalwareBazaar(abuse.ch) 해시 피드도 사용할 수 있습니다. Apple 차단 목록에 있는 Safari 확장 프로그램과 MalwareBazaar 일치 항목은 검토용으로 표시될 뿐 미리 선택되지 않습니다(백신 프로그램이 아니며, 앱에서도 그렇게 안내합니다) |
| **Privacy** | Safari, Chrome, Firefox의 방문 기록, 쿠키, 캐시를 기간 필터와 함께 정리합니다. Safari **책갈피는 절대 건드리지 않습니다** |
| **Browser Extensions** | Safari, Chrome, Brave, Edge, Arc, Firefox에 설치된 확장 프로그램을 나열합니다. 직접 설치한 Chromium 및 Firefox 확장 프로그램은 해당 브라우저가 닫혀 있을 때 휴지통으로 보낼 수 있으며, 정책이나 브라우저 자체가 설치한 항목은 표시만 하고 그대로 둡니다. Safari 확장 프로그램은 Safari 설정으로 연결됩니다 |
| **Saved Wi-Fi** | 선호하는 무선 네트워크를 나열하고 선택한 네트워크를 삭제합니다 |
| **Permissions Overview** | 각 앱이 보유한 개인정보(TCC) 권한을 앱별로 보여 주는 읽기 전용 화면으로, 시스템 설정에서는 볼 수 없는 관점을 제공합니다. 모든 동작은 토글을 관리하는 시스템 설정으로 바로 연결됩니다 |

### ⚡ 성능
| 모듈 | 기능 |
|--------|------------|
| **Optimization** | 로그인 항목과 실행 에이전트를 항목별로 활성화/비활성화하며 관리합니다 |
| **Maintenance** | 시스템 작업: RAM 확보, 유지 관리 스크립트 실행, 시동 디스크 검증, Launch Services 재구축, Spotlight 색인 재생성, DNS 캐시 비우기, Time Machine 스냅샷 줄이기. 작업은 위험도별로 표시되고, "안전한 작업 실행"은 순차적으로 진행되며, 관리자 암호는 **한 번만** 묻습니다 |

### 📦 응용 프로그램
| 모듈 | 기능 |
|--------|------------|
| **Uninstaller** | 17개 이상의 Library 하위 디렉터리(공급업체 하위 폴더에 중첩된 앱 포함)에서 관련 파일을 모두 찾는 패턴 매칭 엔진입니다. 완전 제거, **기본값으로 재설정**(앱은 유지하고 캐시와 환경설정만 삭제), 사용하지 않는 앱 감지를 지원합니다 |
| **Unused Apps** | Spotlight의 마지막 사용 날짜를 바탕으로 3개월, 6개월, 12개월 동안 열지 않은 앱을 찾아 크기순으로 정렬합니다. 실행 중인 앱은 절대 표시하지 않으며, Spotlight에 사용 데이터가 없으면 추측하는 대신 그렇다고 알려 줍니다. 클릭 한 번으로 앱을 Uninstaller에 넘깁니다 |
| **Extensions** | 타사 환경설정 패널, 인터넷 플러그인, Safari 확장 프로그램을 검토합니다. 사용자가 설치한 패널과 플러그인은 휴지통으로 보낼 수 있습니다 |
| **Updater** | 설치된 앱의 자체 Sparkle appcast 피드를 통해 업데이트를 확인합니다(버전 정보만 읽으며, 사용자에 대한 정보는 전혀 보내지 않습니다) |

### 🗂️ 파일
| 모듈 | 기능 |
|--------|------------|
| **Space Lens** | 디스크 사용량을 squarified 트리맵으로 시각화하고 하위 항목으로 파고들며 탐색할 수 있습니다 |
| **Large & Old Files** | 50 MB가 넘는 파일을 찾아 크기와 마지막 접근 날짜순으로 정렬합니다 |
| **Duplicates** | 단계별 감지(크기 그룹화, 부분 SHA-256, 전체 해시, inode 검증)와 함께, 사본을 하나도 삭제하지 않고 APFS copy-on-write 클론으로 공간을 되찾는 **통합** 모드를 제공합니다 |
| **Shredder** | 표준, 영구, 안전 덮어쓰기 모드로 파일을 안전하게 지웁니다 |

### 📊 메뉴 막대 위젯

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Mac Sai 메뉴 막대 위젯" />
</p>

Mac의 핵심 상태를 클릭 한 번 거리에 두는 글래스모피즘 스타일의 메뉴 막대 위젯입니다. 로그인할 때 실행되는 독립 프로세스이며 앱의 사이드바에서 켜고 끌 수 있으므로, 상태를 확인하려고 메인 윈도우를 열 필요가 없습니다.

- **실시간 상태 링**: CPU 부하, 메모리 압력, 디스크 사용량, 배터리를 2x2 링 그리드로 표시하며(`host_processor_info`, `vm_statistics64`, APFS 용량, IOKit 전원), 녹색에서 주황색, 빨간색으로 색이 바뀝니다
- **사용자 설정 가능한 표시 항목**: 디스크 여유 공간, GPU 사용량, 메모리 사용량, 배터리 온도 중에서 선택할 수 있습니다. 선택은 유지되며, 사용할 수 없는 센서는 `--`로 표시됩니다
- **네트워크, 가동 시간, 스왑**: 실시간 업로드/다운로드 처리량, 시스템 가동 시간, 스왑 사용량
- **권장 사항**: 바로 실행하거나 닫을 수 있는 팁("사용자 캐시가 2.52 GB로 늘어났습니다. System Junk를 실행하십시오"), 한 번 탭하면 실행되며, 닫으면 30일 동안 표시되지 않습니다
- **보호 상태**: 마지막 악성코드 스캔 시간과 위협 수를 최신 여부에 따라 색상으로 구분해 표시합니다
- **연결된 기기**: 외장 볼륨(여유 공간 포함)과 디스플레이를 한눈에 보여 줍니다
- **상태 알림**: 디스크 공간이 심각하게 부족하거나 메모리 압력이 계속 높을 때 빈도를 제한한 알림을 보냅니다(사용자가 켠 경우에만)

### ⌨️ 키보드 단축키

| 단축키 | 동작 |
|----------|--------|
| **⌘R** | 현재 모듈에서 스캔 시작 |
| **⌘K** | 현재 선택 항목 정리(결과가 표시된 경우) |
| **⌘1 ~ ⌘9** | 사이드바의 처음 아홉 개 모듈로 이동 |
| **⌘,** | 설정 열기 |

---

## Mac Sai 비교

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **가격** | 무료 | $39.95/년 | 무료 | 무료 | 무료 | 무료 (CLI) |
| **오픈 소스** | ✅ BSD-3 | ❌ | ✅ Fair-code | ✅ MIT | ❌ | ✅ MIT |
| **텔레메트리** | ❌ 없음 | ⚠️ 있음 | ❌ 없음 | ❌ 없음 | ❌ 없음 | ❌ 없음 |
| **네이티브 GUI 앱** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ CLI (유료 GUI 별도) |
| **Smart Scan (원클릭)** | ✅ | ✅ | ❌ | ➖ 일부 | ❌ | ➖ 대화형 CLI |
| **System Junk (16개 이상 카테고리)** | ✅ | ✅ | ➖ | ✅ | ➖ 제한적 | ✅ |
| **Universal Binary 축소** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **악성코드 스캐너** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **브라우저 개인정보 정리** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **잔여 파일 감지 기능이 있는 제거 도구** | ✅ | ✅ | ✅ 주력 기능 | ❌ | ❌ | ✅ |
| **중복 파일 찾기 (+ 통합)** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **디스크 트리맵 시각화** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ 분석기 |
| **메뉴 막대 시스템 모니터** | ✅ | ✅ 메뉴 | ❌ | ❌ | ❌ | ❌ |
| **유지 관리 스크립트** | ✅ | ✅ | ❌ | ❌ | ✅ 강력함 | ➖ |
| **Apple 공증** | ✅ | ✅ | ✅ | ✅ | ✅ | N/A |
| **macOS 버전** | 14+ | 13+ | 13+ | 13+ | 다양함 | 다양함 |

> CleanMyMac은 훌륭한 제품이며, 세련되고 지원이 보장되는 경험을 원하는 분이라면 기꺼이 비용을 지불할 만합니다. Mac Sai는 투명한 소스 코드와 구독 없는 사용을 원하는 모든 분을 위한 앱입니다.

---

## 인터페이스 언어

설정 → 인터페이스 언어에서 시스템, English, 简体中文, 繁體中文, Русский, Deutsch, Français, Español, Italiano, Português (Brasil), Türkçe, 日本語, 한국어, فارسی 중 하나를 선택할 수 있습니다. 영어, 중국어 간체, 러시아어는 인터페이스 전체를 지원합니다. 그 외 언어는 고정된 인터페이스 문자열을 번역하며, 변수가 삽입되는 메시지는 당분간 영어 문구와 복수형 규칙을 그대로 사용합니다(중국어 번체는 중국어 간체로 대체됩니다). 메인 윈도우와 메뉴 막대 위젯은 같은 언어 설정을 공유합니다. 페르시아어에서는 인터페이스가 오른쪽에서 왼쪽 방향으로 표시됩니다.

## 설치

### Homebrew (권장)

Mac Sai는 공식 Homebrew cask에 포함되어 있으므로 tap을 추가할 필요가 없습니다:

```bash
brew install --cask mac-sai
```

Apple의 공증을 받았으므로 Spotlight나 응용 프로그램 폴더에서 경고나 추가 단계 없이 바로 실행됩니다.

<details>
<summary><strong>기타 설치 방법</strong> (한 줄 스크립트, DMG, 소스에서 빌드)</summary>

<br>

**한 줄 설치 스크립트**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

최신 DMG를 내려받아 앱을 `/Applications`에 설치합니다.

**DMG 다운로드**

[Releases](https://github.com/iliyami/MacSai/releases/latest)에서 최신 DMG를 내려받은 다음 Mac Sai를 응용 프로그램 폴더로 드래그하십시오.

**소스에서 빌드**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # run the full 1,048-test suite
bash scripts/build-dmg.sh      # build a local DMG (unsigned)
```

Swift 6 툴체인(Xcode 16+)이 필요합니다.

**이전 tap으로 설치하셨나요?**

이제 Mac Sai는 공식 cask에 포함되어 있으므로 tap을 제거해도 됩니다: `brew untap iliyami/macsai` (이미 설치된 앱과 이후의 `brew upgrade`에는 영향이 없습니다).

</details>

### 전체 디스크 접근 권한 부여

일부 모듈(Mail Attachments, Privacy, Malware)은 보호된 영역을 스캔하기 위해 전체 디스크 접근 권한이 필요합니다:

1. **시스템 설정, 개인정보 보호 및 보안, 전체 디스크 접근 권한**을 엽니다
2. **+**를 클릭하고 **Mac Sai.app**을 추가합니다
3. Mac Sai를 다시 시작합니다

### 제거

Homebrew로 설치한 경우:

```bash
brew uninstall --zap --cask mac-sai
```

DMG 또는 수동으로 설치한 경우(Homebrew 설치도 처리합니다):

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

두 방법 모두 Mac Sai와 함께 `~/Library` 아래의 환경설정, 캐시, 로그, 데이터베이스를 제거합니다.

---

## 서명과 공증으로 신뢰할 수 있는 앱

Mac Sai는 Apple **Developer ID**로 코드 서명되어 있으며 **Apple의 공증**을 받았습니다. 이는 다른 어떤 앱보다 클리너 앱에서 더 중요합니다. 파일에 깊이 접근할 수 있는 권한을 주게 되므로, Mac에서 실행되는 것이 정말로 저희가 만든 것이며 변조되지 않았다는 사실을 알 권리가 있기 때문입니다. 이 모든 것은 저희의 약속이 아니라 여러분의 Mac이 직접 강제합니다:

- **Apple이 검사했습니다.** 모든 릴리스는 배포 전에 Apple에 제출되어 악성코드 검사를 받습니다.
- **변조할 수 없습니다.** 서명은 모든 파일을 덮는 암호화 봉인입니다. 단 1바이트만 바뀌어도 macOS가 열기를 거부합니다.
- **저희가 만들었다는 것을 증명할 수 있습니다.** 서명은 저희의 Apple Developer 신원에 연결되어 있으므로, 다른 누구도 Mac이 Mac Sai로 인정하는 앱을 배포할 수 없습니다.
- **그냥 작동합니다.** Gatekeeper 경고도, 오른쪽 클릭으로 열기도, 터미널도 필요 없습니다.

완전한 오픈 소스와 결합하면, 이는 믿음에 기대지 않는 신뢰의 사슬이 됩니다: 코드는 공개되어 있고, 저희는 모든 릴리스에 서명하며, Apple이 이를 검증하고, 여러분의 Mac은 앱을 열 때마다 봉인을 다시 확인합니다.

### 텔레메트리 없음을 직접 확인하기

저희 말을 그대로 믿지 마십시오. 소스 코드와 실행 중인 프로세스 모두 확인할 수 있습니다.

**1. 소스에서 네트워킹 API 검색하기**

```bash
rg -n 'URLSession|NSURLConnection|Sparkle|SecTrustEvaluate' Sources --glob '*.swift'
```

선택적인 네트워크 경로는 아래에 모두 공개되어 있습니다. 로컬 정리는 스캔 결과나 파일 목록을 업로드하지 않습니다:

- `Sources/MacClean/Services/SelfUpdateController.swift`: Sparkle은 서명된 앱에 봉인된 HTTPS 피드를 확인하고, 서명된 릴리스 노트와 업데이트 아카이브를 내려받습니다. 자동 확인과 자동 다운로드/설치는 별도의 설정이며, 시스템 프로파일링과 릴리스 노트의 JavaScript는 비활성화되어 있습니다. [업데이트 설정](docs/IN_APP_UPDATES.md)을 참조하십시오. 피드가 구성된 직접 설치 버전에서는 자동 업데이트 확인이 기본적으로 켜져 있으며 하루에 한 번 실행됩니다. 각 요청의 User-Agent에는 앱 버전과 Sparkle 버전이 포함되며, 확인 기능은 설정에서 끌 수 있습니다.
- `Sources/MacCleanKit/UpdateChecker.swift`: Homebrew 업데이트 확인, 그리고 서명된 피드가 구성되지 않은 빌드를 위한 릴리스 페이지 대체 경로
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`: Updater를 열었을 때 사용자가 직접 실행하는 *다른 앱의* Sparkle 피드 확인
- `Sources/MacCleanKit/MalwareBazaarFeed.swift`: 사용자가 선택해야 동작하는 MalwareBazaar 해시 다운로드. 직접 발급받은 abuse.ch Auth-Key를 추가하고 설정 > 악성코드 데이터베이스에서 지금 업데이트를 눌러야만 실행됩니다. 각 요청은 Auth-Key와 쿼리만 보내며, 파일 해시나 경로는 절대 보내지 않습니다. 내려받은 해시가 서명된 파일과 일치하면 macOS가 Apple에 해당 파일의 서명 인증서가 폐기되었는지 확인합니다. 이는 Gatekeeper가 수행하는 것과 같은 검사이며, 이 요청은 파일이 아니라 인증서에 관한 것입니다

코드베이스 어디에도 분석 도구, 충돌 보고 도구, 추적기 SDK는 없습니다.

**2. 실행 중인 프로세스 관찰하기**

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

이 스냅샷은 선택한 앱 번들 내부의 실행 파일 경로로 PID를 고르므로, 관련 없는 Installer/Updater 프로세스는 제외됩니다. 다른 위치로 복사된 Sparkle 헬퍼와 macOS 신뢰 서비스는 이 스냅샷의 범위 밖이므로, 이를 관찰하려면 프로세스 단위 방화벽을 사용하십시오. 짧게 유지되는 연결까지 잡으려면 업데이트를 확인하거나 내려받는 동안 실행하십시오.

업데이트 확인/다운로드와 선택적 악성코드 검증이 비활성 상태일 때, 로컬 정리는 네트워크 연결을 전혀 열지 않습니다. 업데이트를 관찰할 때는 Sparkle의 하위 프로세스도 포함하십시오. Apple 인증서 확인은 macOS 신뢰 서비스를 통해 실행됩니다. Little Snitch나 LuLu로도 이러한 연결을 확인할 수 있습니다.

**3. 실제로 설치한 바이너리 검사하기**

DMG 또는 Homebrew로 설치한 경우, 이 반복문은 소스 체크아웃이나 Python 없이 macOS 명령어 도구만 사용합니다. 번들에 포함된 바이너리 7개를 모두 읽고, 직접 검사할 수 있도록 일반적인 네트워크 import, 정적 URL, 추적기 문자열을 나열합니다:

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

이 목록은 합격/불합격을 판정하는 감사가 아니며, 런타임에 접속하는 모든 대상이 드러난다는 증거도 아닙니다. 전체 구성 요소 목록, 명시적 허용 목록, 번들에 포함된 개인정보 설정까지 확인하려면 아래의 자동 검사를 사용하십시오.

설치된 버전과 일치하는 소스 체크아웃에서 검사를 실행하십시오. 이 검사는 메인 실행 파일, 메뉴 헬퍼, `Sparkle.framework`, `Autoupdate`, `Updater.app`, `Downloader.xpc`, `Installer.xpc`를 포함한 실제 앱 번들을 검사합니다:

```bash
bash scripts/check-network-surface.sh "/Applications/Mac Sai.app"
```

예상 결과: Mach-O 파일 7개가 통과합니다. 누락되었거나 예상하지 못한 바이너리, 목록에 없는 네트워크 import나 정적 URL, 추적기 표식이 있으면 검사가 실패합니다. URLSession import는 Mac Sai, 메뉴 헬퍼, Sparkle, Downloader에서만 허용되며, 나머지 Sparkle 헬퍼에는 허용된 네트워크 import가 없습니다. Sparkle의 문서 링크와 XML 네임스페이스는 다운로드 엔드포인트로 취급하지 않고 명시적으로 구분합니다.

스크립트는 번들에 포함된 `SUFeedURL`도 출력하고, 서명된 피드, 사전 추출, 개인정보 설정을 검증합니다. 해당 피드의 아카이브/릴리스 노트 대상과 요청한 다른 앱의 피드를 위에서 본 실시간 연결과 대조해 보십시오. 대체 엔드포인트는 `api.github.com/repos/iliyami/MacSai/releases/latest`와 `formulae.brew.sh/api/cask/mac-sai.json`이며, 사용자가 선택해야 동작하는 악성코드 엔드포인트는 `mb-api.abuse.ch/api/v1/`입니다. 프로젝트/지원 링크와 브라우저 설정 링크는 요청할 때만 열립니다. 패키징 중에도 동일한 전체 번들 검사가 실행되며, CI는 빌드된 실행 파일 두 개와 고정된 Sparkle 바이너리 다섯 개를 모두 검사합니다. [검사 구현 및 명시적 허용 목록](scripts/check-network-surface.py).

---

## 아키텍처

```
Mac Sai
├── MacClean          Main SwiftUI app (22 modules)
├── MacCleanKit       Shared framework (models, constants, protocols)
├── MacCleanHelper    XPC privileged helper (LaunchDaemon for root ops)
└── MacCleanMenu      Menu-bar monitor (independent process)
```

### 기술 스택

| 계층 | 기술 |
|-------|-----------|
| 언어 | 엄격한 동시성 검사를 적용한 Swift 6 |
| UI | SwiftUI + AppKit 하이브리드 |
| 동시성 | Actors, TaskGroup, async/await, `@Sendable` |
| 데이터베이스 | WAL 모드를 사용하는 GRDB.swift (SQLite) |
| 파일 스캔 | APFS에서 `URLResourceKey` 프리페칭 |
| 증분 업데이트 | 과거 이벤트 재생을 지원하는 FSEvents |
| 권한 상승 작업 | SMAppService + NSXPCConnection |
| 시스템 통계 | Mach API (`host_processor_info`, `vm_statistics64`, `proc_pidinfo`) |

### 안전 모델

Mac Sai는 **절대 데이터 손실을 일으키지 않도록** 설계되었습니다:

- **보호 경로 차단 목록**: `/System`, `/usr`, `/bin`, `/sbin` 및 Apple 시스템 앱은 건드릴 수 없으며, macOS firmlink를 정규화하여 심볼릭 링크 리디렉션 감지가 정상적인 시스템 경로를 잘못 탐지하지 않도록 합니다
- **스캔 전 정리 가능 여부 필터**: 현재 프로세스가 휴지통으로 보낼 수 없는 항목(시스템 캐시 안의 root 소유 하위 항목, 데이터 보호된 `~/Library/Caches/com.apple.*` 디렉터리)은 스캔 단계에서 제외되므로 정리 가능 항목으로 나타나지 않습니다
- **휴지통 우선 삭제**: 모든 제거 항목은 기본적으로 휴지통으로 이동하며, 드라이런 모드로 아무것도 건드리지 않고 미리 볼 수 있습니다
- **TOCTOU 방지**: 삭제 직전에 심볼릭 링크를 다시 확인합니다
- **제외된 폴더**: 설정에서 스캔이 완전히 건너뛸 폴더를 고를 수 있으며, `SafetyGuard`는 그 아래의 항목 삭제도 추가로 거부합니다
- **분할 처리와 취소 가능한 정리**: 대량의 선택 항목은 5k개 단위로 나누어 처리하고 단위 사이마다 취소 여부를 확인하며, 취소를 누르면 스캔이 약 1초 안에 대기 상태로 돌아갑니다
- **앱 내 활동 로그**: 정리 중 발생한 모든 오류를 전체 경로와 함께 기록하며, 정리 후 화면에서 보고 복사할 수 있고, 30일이 지나면 자동으로 정리됩니다
- **커널이 강제하는 XPC 게이트**: 권한 헬퍼는 `NSXPCListener.setCodeSigningRequirement`를 사용하므로, 코드 서명이 앱의 식별자 및 팀과 일치하지 않는 연결은 커널이 직접 거부합니다

---

## 테스트

```bash
swift test
```

XCTest 테스트 모음에는 **1,048개 테스트**가 있으며, `SafetyGuard`와 `CleaningEngine`(생사를 가르는 파일)을 반드시 완벽해야 하는 대상으로 다룹니다: 심볼릭 링크, 경로 순회, NULL 바이트, SIP, 보호된 앱, 파일 수 상한, TOCTOU, 멱등성에 대한 공격적 테스트와 함께, 드라이런 / 휴지통 / 영구 정리, 스캔 상태 머신, 모든 System Junk 카테고리, 트리맵 계산, 제거 도구 매칭 엔진, 중복 파일 감지, appcast 파싱, 그리고 픽스처부터 정리까지의 전체 종단 간 사이클을 통합 테스트합니다. 픽스처(`withTempHome`, `withFakeApp`, `withFakePlist`)를 사용하므로 어떤 테스트도 실제 홈 디렉터리를 건드리지 않습니다.

---

## 기여하기

기여는 언제나 환영합니다. [기여 가이드라인](CONTRIBUTING.md)을 읽은 다음:

1. 저장소를 포크하고 기능 브랜치를 만듭니다
2. 변경 사항을 작성합니다(PR마다 하나의 집중된 변경을 담으면 리뷰가 쉬워집니다)
3. `swift test`를 실행합니다
4. Pull Request를 엽니다

[기능 투표](https://github.com/iliyami/MacSai/issues/55)도 열려 있습니다: 다음에 만들었으면 하는 도구에 👍를 눌러 주십시오.

## 라이선스

BSD 3-Clause. [LICENSE](LICENSE)를 참조하십시오. 저작권 및 라이선스 문구를 유지하고, 허가 없이 "Mac Sai"라는 이름이나 기여자의 이름을 파생 제품의 홍보에 사용하지 않는 한, 코드를 사용, 수정, 재배포할 수 있습니다.

## 감사의 말

오픈 소스 Mac 유틸리티 커뮤니티에서 영감을 받았습니다:

- [Pearcleaner](https://github.com/alienator88/Pearcleaner): 앱 제거 패턴
- [Mole](https://github.com/tw93/Mole): 정리 카테고리
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner): 모듈형 아키텍처
- Bruls, Huizing, van Wijk의 Squarified Treemap 알고리즘(2000)

## 후원 및 스폰서

Mac Sai는 무료이며 앞으로도 무료입니다: 유료 등급도, 광고도, 추적도 없습니다. 클리너 구독에서 벗어나는 데 도움이 되었다면 [커피 한 잔 사 주기 ☕](https://buymeacoffee.com/iliyami)나 [멤버 가입](https://buymeacoffee.com/iliyami/membership)으로 응원해 주십시오. 이는 릴리스가 계속 서명되고, 공증을 받고, 꾸준히 나올 수 있도록 하는 힘이 됩니다.

### 후원자

멤버는 비하인드 스토리 게시물, 각 릴리스 미리 보기, 선택형 베타 빌드를 받고, 앱에 이름이 실립니다. 앱의 어떤 기능도 멤버십 뒤에 잠기지 않습니다.

<p align="center">
  <em>아직 멤버가 없습니다.</em> <a href="https://buymeacoffee.com/iliyami/membership">첫 번째 멤버가 되어 주세요 →</a><br>
  <sub>Power User 및 Team 멤버에게는 이곳에서 감사를 전합니다. 모든 후원자는 <a href="SUPPORTERS.md">SUPPORTERS.md</a>에 실려 있습니다.</sub>
</p>

### 스폰서 자리

Mac Sai에는 스폰서 자리가 **하나**뿐이며, 이 README의 모든 언어 버전에서 이곳과 페이지 상단에 표시됩니다.

<div align="center">
<table>
  <tr>
    <td align="center" width="25%"><h3>125,000+</h3><sub>다운로드</sub></td>
    <td align="center" width="25%"><h3>2,000+</h3><sub>GitHub 스타</sub></td>
    <td align="center" width="25%"><h3>23,000</h3><sub>월간 페이지 조회수</sub></td>
    <td align="center" width="25%"><h3>13</h3><sub>README 언어</sub></td>
  </tr>
</table>
</div>

방문자 대부분은 개발자와 Mac 파워 유저이며, 주로 Google 검색을 통해 유입되고, 그다음으로 YouTube, GitHub, Reddit에서 찾아옵니다.

- **한 번에 한 스폰서만**, 그래서 수많은 로고 속에 이름이 묻히지 않습니다.
- **엄선된 스폰서.** 개발자 도구, 개인정보 보호 및 보안 제품, 사용자를 존중하는 Mac 앱. 클리너나 "최적화 도구", 암호화폐, 제휴 VPN 상품, 사람을 추적하는 그 어떤 것도 받지 않습니다.
- **앱 안에는 절대 넣지 않습니다.** Mac Sai에는 광고도 텔레메트리도 없으며, 어떤 스폰서도 이를 바꿀 수 없습니다.

<p align="center">
  <strong>이 자리는 비어 있습니다.</strong> <a href="mailto:macsai.team@gmail.com?subject=Mac%20Sai%20sponsor">스폰서 되기 →</a><br>
  <sub>방문자 정보 및 신청 방법: <a href="SPONSORS.md">SPONSORS.md</a></sub>
</p>

## 스타 기록

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
  <strong>Mac Sai는 커뮤니티가 커뮤니티를 위해 만든 자유 소프트웨어입니다.</strong><br>
  구독에서 벗어나는 데 도움이 되었다면, ⭐는 다른 사람들이 이 앱을 찾는 데 도움이 되고, <a href="https://buymeacoffee.com/iliyami">커피 ☕</a>는 프로젝트를 계속 이어가게 합니다.
</p>
