#!/usr/bin/env python3
"""Negative fixtures for nested binary inventory and network allowlists."""
import importlib.util
from pathlib import Path
import plistlib
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("network_surface", Path(__file__).with_name("check-network-surface.py"))
SURFACE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SURFACE)


class NetworkSurfaceTests(unittest.TestCase):
    def testReviewedSparkleImportsAndDocumentationPass(self):
        for role in ("Sparkle", "Downloader"):
            SURFACE.audit_surface("_OBJC_CLASS_$_NSURLSession\n_NSURLSessionTransferSizeUnknown", "", role)
        SURFACE.audit_surface("", "\n".join(SURFACE.SPARKLE_URLS), "Installer")
        # AppKit's double-click callback must not be mistaken for an ad domain.
        SURFACE.audit_surface("", "textView:doubleClickedOnCell:inRect:", "Sparkle")

    def testUnlistedNetworkSchemesAndUppercaseURLsFailInEveryComponent(self):
        for role in ("app", "Sparkle", "Downloader", "Installer", "Autoupdate", "Updater"):
            for url in ("HTTPS://unlisted.example/path", "wss://unlisted.example/socket",
                        "ftp://unlisted.example/file", "ldap://unlisted.example/query"):
                with self.subTest(role=role, url=url), self.assertRaisesRegex(ValueError, "Unlisted static URL"):
                    SURFACE.audit_surface("", url, role)

    def testNewNetworkAPIsFailEvenWithoutAStaticURL(self):
        symbols = ["_DNSServiceQueryRecord", "_CFNetServiceCreate", "_OBJC_CLASS_$_NSNetService",
                   "_$s7Network10NWListenerC", "_connectx", "_connect$NOCANCEL", "_socket", "_curl_easy_perform"]
        for role in ("app", "Sparkle", "Downloader", "Installer", "Autoupdate", "Updater"):
            for symbol in symbols:
                with self.subTest(role=role, symbol=symbol), self.assertRaisesRegex(ValueError, "Unlisted network import"):
                    SURFACE.audit_surface(symbol, "", role)

    def testInstallerAndAutoupdateCannotAcquireDownloaderPrivileges(self):
        for role in ("Installer", "Autoupdate", "Updater"):
            with self.subTest(role=role), self.assertRaisesRegex(ValueError, "Unlisted network import"):
                SURFACE.audit_surface("_OBJC_CLASS_$_NSURLSession", "", role)

    def testTrackerInAnXPCFails(self):
        for text in ("https://analytics.example/collect", "https://stats.doubleclick.net/event", "FirebaseApp"):
            with self.subTest(text=text), self.assertRaises(ValueError):
                SURFACE.audit_surface("", text, "Downloader")

    def bundle_fixture(self, root):
        bundle = root / "Audit.app"
        info = bundle / "Contents/Info.plist"
        info.parent.mkdir(parents=True)
        info.write_bytes(plistlib.dumps({}))
        framework = bundle / "Contents/Frameworks/Sparkle.framework"
        files = [bundle / "Contents/MacOS/MacClean",
                 bundle / "Contents/Library/LoginItems/MacCleanMenu.app/Contents/MacOS/MacCleanMenu"]
        files += [framework / relative for relative in SURFACE.SPARKLE_COMPONENTS]
        for path in files:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(bytes.fromhex("cffaedfe") + b"fixture")
        framework_info = framework / "Versions/B/Resources/Info.plist"
        framework_info.parent.mkdir(parents=True)
        framework_info.write_bytes(plistlib.dumps({"CFBundleShortVersionString": "2.10.1"}))
        return bundle, framework

    def testInventoryRequiresAllSevenBinaries(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle, _ = self.bundle_fixture(Path(directory))
            self.assertEqual(len(SURFACE.binaries_for(bundle)), 7)

    def testMissingAndAdditionalSparkleComponentsFail(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle, framework = self.bundle_fixture(Path(directory))
            (framework / "Versions/B/XPCServices/Installer.xpc/Contents/MacOS/Installer").unlink()
            with self.assertRaisesRegex(ValueError, "missing=.*Installer"):
                SURFACE.binaries_for(bundle)
        with tempfile.TemporaryDirectory() as directory:
            bundle, framework = self.bundle_fixture(Path(directory))
            (framework / "Versions/B/Unexpected").write_bytes(bytes.fromhex("cffaedfe"))
            with self.assertRaisesRegex(ValueError, "unexpected=.*Unexpected"):
                SURFACE.binaries_for(bundle)

    def testHiddenFrameworkCannotMasqueradeAsTheMainExecutable(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle, _ = self.bundle_fixture(Path(directory))
            hidden = bundle / "Contents/Resources/Unknown.framework/MacClean"
            hidden.parent.mkdir(parents=True)
            hidden.write_bytes(bytes.fromhex("cffaedfe"))
            with self.assertRaisesRegex(ValueError, "Unreviewed shipped Mach-O"):
                SURFACE.binaries_for(bundle)

    def testDefaultChecksCurrentBuildEvenWhenStalePackagingExists(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            bundle, framework = self.bundle_fixture(root)
            staging = root / ".build/dmg/Mac Sai.app"
            staging.parent.mkdir(parents=True)
            bundle.rename(staging)
            framework = staging / "Contents/Frameworks/Sparkle.framework"
            executable = root / ".build/debug/MacClean"
            executable.parent.mkdir(parents=True)
            executable.write_bytes(bytes.fromhex("cffaedfe"))
            executable.with_name("MacCleanMenu").write_bytes(bytes.fromhex("cffaedfe"))
            with patch.object(SURFACE, "ROOT", root), patch.object(SURFACE, "PINNED_FRAMEWORK", framework):
                binaries = SURFACE.binaries_for(None)
            self.assertEqual(binaries[0], (executable, "app"))
            self.assertEqual(binaries[1], (executable.with_name("MacCleanMenu"), "app"))


if __name__ == "__main__":
    unittest.main()
