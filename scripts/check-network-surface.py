#!/usr/bin/env python3
"""Fail closed on unreviewed network imports/URLs in every distributed binary.

This is a reproducible binary check, not source grep: unknown Mach-O components,
missing Sparkle helpers, new network APIs, tracker markers and unlisted static
URLs fail. Dynamic appcast/app-feed URLs are disclosed separately; this command
prints the configured appcast and checks the bundled updater privacy settings.
"""
import base64
from pathlib import Path
import plistlib
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
PINNED_FRAMEWORK = ROOT / ".build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"
SPARKLE_COMPONENTS = {
    "Versions/B/Sparkle": "Sparkle",
    "Versions/B/Autoupdate": "Autoupdate",
    "Versions/B/Updater.app/Contents/MacOS/Updater": "Updater",
    "Versions/B/XPCServices/Downloader.xpc/Contents/MacOS/Downloader": "Downloader",
    "Versions/B/XPCServices/Installer.xpc/Contents/MacOS/Installer": "Installer",
}
MACHO_MAGIC = {bytes.fromhex(value) for value in (
    "cffaedfe", "feedfacf", "cefaedfe", "feedface", "cafebabe", "bebafeca", "cafebabf", "bfbafeca")}
APP_URLS = {
    "https://api.github.com/repos/iliyami/MacSai/releases/latest",
    "https://formulae.brew.sh/api/cask/mac-sai.json",
    "https://mb-api.abuse.ch/api/v1/",
    # These are user-initiated browser links, not background fetches.
    "https://auth.abuse.ch/", "https://buymeacoffee.com/iliyami",
    "https://github.com/iliyami/MacSai", "https://github.com/iliyami/MacSai/releases",
    "https://github.com/iliyami/MacSai/issues/new/choose",
    # Local browser/settings routes and the menu helper's own deep link.
    "arc://extensions", "brave://extensions", "edge://extensions",
    "macappstore://showUpdatesPage", "macclean://module/",
}
SPARKLE_URLS = {
    # An XML namespace identifier and diagnostics documentation, not endpoints.
    "http://www.andymatuschak.org/xml-namespaces/sparkle",
    "https://sparkle-project.org/documentation/#3-segue-for-security-concerns",
    "https://sparkle-project.org/documentation/#3-segue-for-security-concerns.",
    "https://sparkle-project.org/documentation/app-transport-security",
    "https://sparkle-project.org/documentation/customization/",
    "https://sparkle-project.org/documentation/gentle-reminders",
    "https://sparkle-project.org/documentation/sandboxing/",
    "https://sparkle-project.org/documentation/sandboxing#code-signing",
    "https://sparkle-project.org/documentation/sandboxing/#testing",
}
URL_PATTERN = re.compile(r"[a-z][a-z0-9+.-]*://[^\s<>\"']+", re.I)
NETWORK_SYMBOL = re.compile(
    r"URLSession|URLConnection|CFNetwork|NW[A-Z]|nw_|\$s7Network|DNSService|dns_sd|CFNetService|NSNetService|"
    r"CFHost|CFHTTP|CFFTP|CFURLRequest|CFURLResponse|CFSocket|CFStream|CFReadStream|CFWriteStream|"
    r"AsyncSocket|curl_|SSL(?:Connect|Read|Write)|"
    r"^_(?:socket|socketpair|connect|connectx|accept|bind|listen|send|sendto|sendmsg|recv|recvfrom|recvmsg|"
    r"getaddrinfo|gethostbyname|gethostbyname2|res_query|res_search)(?:\$.*)?$")
URLSESSION_IMPORTS = {"_OBJC_CLASS_$_NSURLSession", "_OBJC_CLASS_$_NSURLSessionConfiguration"}
TRACKERS = re.compile(
    r"sentry\.io|mixpanel|firebase|firebaseio|google-analytics|googletagmanager|\bdoubleclick\b|"
    r"segment\.(?:io|com)|amplitude|bugsnag|crashlytics|datadoghq|posthog|appcenter\.ms|"
    r"adjust\.com|appsflyer|flurry|umeng", re.I)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def is_macho(path):
    if path.is_symlink() or not path.is_file():
        return False
    with path.open("rb") as stream:
        return stream.read(4) in MACHO_MAGIC


def framework_binaries(framework):
    require(framework.is_dir(), f"Missing shipped Sparkle framework: {framework}")
    found = {str(p.relative_to(framework)): p for p in framework.rglob("*") if is_macho(p)}
    require(set(found) == set(SPARKLE_COMPONENTS),
            f"Sparkle component inventory differs: missing={sorted(set(SPARKLE_COMPONENTS) - set(found))}, "
            f"unexpected={sorted(set(found) - set(SPARKLE_COMPONENTS))}")
    info = plistlib.loads((framework / "Versions/B/Resources/Info.plist").read_bytes())
    require(info.get("CFBundleShortVersionString") == "2.10.1", "Review the allowlist before changing pinned Sparkle 2.10.1")
    return [(found[path], role) for path, role in SPARKLE_COMPONENTS.items()]


def app_configuration(bundle):
    from urllib.parse import urlsplit
    info = plistlib.loads((bundle / "Contents/Info.plist").read_bytes())
    feed, key = info.get("SUFeedURL"), info.get("SUPublicEDKey")
    if not feed and not key:
        print("Update feed: unconfigured (release-page fallback)")
        return
    require(isinstance(feed, str) and isinstance(key, str), "Incomplete updater configuration")
    url = urlsplit(feed)
    require(url.scheme == "https" and url.hostname and not url.username and not url.password,
            "Configured update feed must use HTTPS without credentials")
    require(len(base64.b64decode(key, validate=True)) == 32, "Invalid updater public key")
    require(info.get("SUEnableSystemProfiling") is False, "Sparkle system profiling must be disabled")
    require(info.get("SUEnableJavaScript") is False, "Release-note JavaScript must be disabled")
    require(info.get("SUVerifyUpdateBeforeExtraction") is True, "Verify updates before extraction")
    require(info.get("SURequireSignedFeed") is True, "A signed feed is required")
    require(info.get("SUSignedFeedFailureExpirationInterval") == 0, "Signed-feed failures must not expire")
    print(f"Update feed (sealed in this app): {feed}")


def binaries_for(target):
    if target is None:
        # Packaging supplies an explicit bundle. Never let stale staging in a
        # restored .build cache replace the current SwiftPM audit target.
        candidates = [ROOT / '.build/debug/MacClean', ROOT / '.build/release/MacClean',
                      Path('/Applications/Mac Sai.app')]
        target = next((candidate for candidate in candidates if candidate.exists()), None)
    require(target is not None and target.exists(), "No app or SwiftPM executable found; pass an explicit path")
    bundle = target if target.name.endswith(".app") else next(
        (parent for parent in target.parents if parent.name.endswith(".app")), None)
    if bundle:
        app_configuration(bundle)
        framework = bundle / "Contents/Frameworks/Sparkle.framework"
        binaries = framework_binaries(framework)
        covered = {path for path, _ in binaries}
        expected_app_paths = {
            "Contents/MacOS/MacClean",
            "Contents/Library/LoginItems/MacCleanMenu.app/Contents/MacOS/MacCleanMenu",
        }
        found_app_paths = set()
        for path in bundle.rglob("*"):
            if path in covered or not is_macho(path):
                continue
            relative = str(path.relative_to(bundle))
            require(relative in expected_app_paths,
                    f"Unreviewed shipped Mach-O component: {path}")
            found_app_paths.add(relative)
            binaries.append((path, "app"))
        require(found_app_paths == expected_app_paths, f"Missing app executables: {sorted(expected_app_paths - found_app_paths)}")
        return binaries
    require(target.name == "MacClean" and is_macho(target), "Expected MacClean Mach-O executable or .app bundle")
    menu = target.with_name("MacCleanMenu")
    require(is_macho(menu), "Missing SwiftPM menu helper; build all products before checking")
    return [(target, "app"), (menu, "app")] + framework_binaries(PINNED_FRAMEWORK)


def inspect(path, role):
    # Fail if either tool cannot read a binary. Do not silently inspect nothing.
    symbols = subprocess.run(["nm", "-uj", str(path)], check=True, capture_output=True, text=True).stdout
    strings = subprocess.run(["strings", "-a", str(path)], check=True, capture_output=True, text=True).stdout
    audit_surface(symbols, strings, role)
    network = sorted({line.strip() for line in symbols.splitlines() if NETWORK_SYMBOL.search(line)})
    urls = sorted(set(URL_PATTERN.findall(strings)))
    print(f"PASS {role}: {path}")
    for symbol in network:
        print(f"  import {symbol}")
    for url in urls:
        print(f"  URL {url}")


def audit_surface(symbols, strings, role):
    require(not TRACKERS.search(strings), f"Tracker/analytics marker found in {role}")
    for symbol in {line.strip() for line in symbols.splitlines() if NETWORK_SYMBOL.search(line)}:
        allowed = False
        if role == "app":
            allowed = symbol in URLSESSION_IMPORTS or symbol.startswith("_$sSo12NSURLSessionC10FoundationE")
        elif role in {"Sparkle", "Downloader"}:
            allowed = symbol in URLSESSION_IMPORTS | {"_NSURLSessionTransferSizeUnknown"}
        require(allowed, f"Unlisted network import in {role}: {symbol}")
    allowed_urls = APP_URLS if role == "app" else SPARKLE_URLS
    unexpected = set(URL_PATTERN.findall(strings)) - allowed_urls
    require(not unexpected, f"Unlisted static URL in {role}: {sorted(unexpected)}")


def main():
    require(len(sys.argv) <= 2, "Usage: check-network-surface.sh [app-bundle-or-main-executable]")
    binaries = binaries_for(Path(sys.argv[1]) if len(sys.argv) == 2 else None)
    for path, role in binaries:
        try:
            inspect(path, role)
        except (ValueError, subprocess.CalledProcessError) as error:
            raise ValueError(f"{path}: {error}") from error
    print(f"Network-surface check passed: {len(binaries)} Mach-O files; all five Sparkle components checked.")
    print("Dynamic destinations: configured signed appcast/notes/archives and user-requested other-app feeds.")
    print("macOS certificate-revocation checks contact Apple through system trust services.")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, plistlib.InvalidFileException) as error:
        print(f"::error::Network-surface check failed: {error}", file=sys.stderr)
        sys.exit(1)
