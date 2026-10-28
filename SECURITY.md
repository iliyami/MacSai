# Security Policy

Mac Sai deletes files on your Mac (at your user's privilege level) and can run a few maintenance commands via the standard macOS administrator prompt, so security matters more here than for most apps.

## Reporting a vulnerability

**Please do not open public GitHub issues for security vulnerabilities.**

Report them privately via [GitHub's Private Vulnerability Reporting](https://github.com/iliyami/MacSai/security/advisories/new):

1. Open the [Security tab](https://github.com/iliyami/MacSai/security) on the repository
2. Click **Report a vulnerability**
3. Include: the affected file or feature, reproduction steps, expected vs actual behavior, and a suggested fix if you have one

Expect an initial response within **72 hours**. Issues that risk data loss get same-day attention.

## Supported versions

Only the latest release on `main` is supported. Please upgrade rather than asking for backports.

| Version | Supported |
|---------|-----------|
| `main` (latest release) | ✅ |
| Older releases | ❌ |

## In scope

Reports about the following areas get priority:

- **`Sources/MacCleanKit/SafetyGuard.swift`**: bypasses of the protected-paths blocklist, the 10,000-file cap, or the symlink TOCTOU re-resolution
- **`Sources/MacClean/Core/Cleaner/CleaningEngine.swift`**: anything that causes data loss outside the intended scan results
- **`Sources/MacClean/Modules/Maintenance/MaintenanceModule.swift`**: anything that turns the administrator-prompt maintenance commands into arbitrary command execution
- **Updates**: bypasses of Sparkle's pinned HTTPS feed, required feed/archive signatures, or verification before extraction; replacement racing with active file operations; a tampered third-party app feed steering the user to a malicious download
- **Network exfiltration**: optional outbound traffic consists of Sparkle checking the feed embedded in a configured signed app and downloading its signed release notes/archives, Homebrew checks (`formulae.brew.sh`) or the GitHub releases API fallback, reading third-party apps' update feeds, and the opt-in MalwareBazaar hash download (`mb-api.abuse.ch`, only after you add an abuse.ch Auth-Key and press Update Now; each request sends only your Auth-Key and the query, never file hashes or paths, and redirects are refused so the key can't be forwarded; when a downloaded hash matches a signed file, macOS also asks Apple whether its signing certificate was revoked, the same OCSP check Gatekeeper makes). Update requests reveal normal connection metadata such as IP address and HTTP headers; Sparkle system profiling and release-note JavaScript are disabled, and scan results/file lists are not uploaded. Project/support and browser-settings links are user-initiated. Report any undisclosed network activity you observe
- **TCC / Full Disk Access**: any path to silently gain or abuse FDA

To check the installed distribution, run
`bash scripts/check-network-surface.sh "/Applications/Mac Sai.app"` from a
matching source checkout. This inspects both Mac Sai executables and all five
Sparkle binaries, including the Downloader/Installer XPC services and
Autoupdate/Updater helpers. Missing or unexpected components, unlisted network
imports/static URLs, and tracker markers fail the check. It also checks the
bundled updater privacy/trust settings and prints the configured feed. The
[explicit allowlists](scripts/check-network-surface.py) run in CI and packaging;
the [README's live-process check](README.md#verify-no-telemetry-yourself) covers
runtime destinations selected by signed feeds and user-requested app feeds.
Apple certificate-revocation requests are performed by macOS trust services.

## Out of scope

- General macOS bugs not specific to Mac Sai
- Findings that require an already-root or already-compromised machine
- Social engineering or physical access to an unlocked Mac

## What we ask of you

- Give us a reasonable window to fix before public disclosure: **14 days for non-critical issues**, **immediate coordination for anything that risks user data**
- Don't test against other people's machines
- Don't pivot from a found vulnerability to access user data

## What you get

- Credit in the release notes (or stay anonymous if you prefer)
- Acknowledgment in this file for significant findings
- Our genuine thanks. Mac Sai is safer because of you

## Verifying a release is genuine

Every release is signed with our Apple **Developer ID** and **notarized by Apple**, so your own Mac can confirm it is genuinely from us and has not been modified. Verify a downloaded DMG without trusting us:

```bash
# 1. The DMG carries a stapled Apple notarization ticket
xcrun stapler validate MacSai-1.9.0.dmg

# 2. Signed by our Developer ID, chaining to Apple
codesign -dvvv "Mac Sai.app"   # Authority: Developer ID Application: Iliya Mirzaei (H3XLS95QV4)

# 3. Gatekeeper's own verdict
spctl -a -vvv "Mac Sai.app"    # accepted, source=Notarized Developer ID
```

`source=Notarized Developer ID` is your Mac confirming with Apple that this exact binary was notarized and signed by team `H3XLS95QV4`. No one without our Developer ID certificate can reproduce that result.

Notarization proves who signed a build, not that it matches this repo. To additionally confirm a release was built from the public source, build it yourself:

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
git checkout v1.9.0
bash scripts/build-dmg.sh
```

The DMG is not bit-for-bit reproducible (signatures embed timestamps and nonces), but the source-to-binary build is straightforward and the behavior should match.

## Past advisories

None yet. Will be linked here when applicable.
