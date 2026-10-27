#!/usr/bin/env python3
"""Exercise release failures with real Sparkle signatures and disposable fixtures."""
import base64
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent
SIGN = ROOT / ".build/artifacts/sparkle/Sparkle/bin/sign_update"
SCRIPT = ROOT / "scripts/generate-update-feed.sh"
# RFC 8032 public test vector; this is not a release credential.
SEED = base64.b64encode(bytes.fromhex("9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60")).decode()
PUBLIC = base64.b64encode(bytes.fromhex("d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a")).decode()
OTHER_SEED = base64.b64encode(bytes(range(32))).decode()
PREFIX = "https://example.org/releases/v2/"


class FeedTests(unittest.TestCase):
    def setUp(self):
        self.assertTrue(SIGN.is_file(), "Resolve Sparkle with swift build before running feed fixtures")
        self.temporary = tempfile.TemporaryDirectory(prefix="macsai-feed-test-")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.archives = self.directory / "archives"
        self.archives.mkdir()
        self.archive = self.archives / "MacSai-2.dmg"
        self.archive.write_bytes(b"Disposable archive fixture, not a mountable DMG.\n")
        self.feed = self.directory / "fixture.xml"
        self.environment = dict(os.environ, SPARKLE_PRIVATE_KEY=SEED, SPARKLE_PUBLIC_ED_KEY=PUBLIC,
                                SPARKLE_TEST_FEED=str(self.feed))
        # Stub only archive discovery: real DMGs are unnecessary to test the
        # failure where generate_appcast exits 0 with an unusable enclosure.
        tool_directory = self.directory / ".build/artifacts/sparkle/Sparkle/bin"
        tool_directory.mkdir(parents=True)
        (tool_directory / "sign_update").symlink_to(SIGN)
        generator = tool_directory / "generate_appcast"
        generator.write_text("#!/bin/bash\nset -eu\ncat >/dev/null\nwhile [[ $# -gt 0 ]]; do\n"
                             "if [[ $1 == -o ]]; then cp \"$SPARKLE_TEST_FEED\" \"$2\"; exit; fi\nshift\ndone\nexit 1\n")
        generator.chmod(0o755)

    def sign(self, path, seed=SEED):
        result = subprocess.run([str(SIGN), "--ed-key-file", "-", str(path)], input=seed,
                                text=True, capture_output=True, check=True)
        return result.stdout

    def write_feed(self, signature=None, length=None, url=PREFIX + "MacSai-2.dmg", seed=SEED):
        if signature is None:
            signature = re.search(r'edSignature="([^"]+)"', self.sign(self.archive, seed)).group(1)
        signature_attribute = "" if signature == "missing" else f' sparkle:edSignature="{signature}"'
        length = self.archive.stat().st_size if length is None else length
        self.feed.write_text(f'''<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"><channel><item>
<sparkle:version>2</sparkle:version><enclosure url="{url}" length="{length}" type="application/octet-stream"{signature_attribute}/>
</item></channel></rss>''')
        self.sign(self.feed, seed)

    def generate(self, expected_success=False, expected_error=None, trace=False):
        # Keep an existing published feed to prove failures do not replace it.
        target = self.archives / "appcast.xml"
        target.write_text("previous verified feed")
        command = ["bash"] + (["-x"] if trace else []) + [str(SCRIPT), str(self.archives), PREFIX]
        result = subprocess.run(command, cwd=self.directory,
                                env=self.environment, text=True, capture_output=True)
        self.assertNotIn(SEED, result.stdout + result.stderr)
        self.assertNotIn(OTHER_SEED, result.stdout + result.stderr)
        if expected_success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(target.read_bytes(), self.feed.read_bytes())
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(target.read_text(), "previous verified feed")
            if expected_error:
                self.assertIn(expected_error, result.stdout + result.stderr)
        return result

    def test_accepts_signed_feed_and_archive(self):
        self.write_feed()
        self.generate(expected_success=True)

    def test_disables_shell_tracing_before_reading_private_key(self):
        self.write_feed()
        self.generate(expected_success=True, trace=True)

    def test_rejects_missing_malformed_and_short_archive_signatures(self):
        for signature in ["missing", "not-base64!", base64.b64encode(b"x" * 63).decode()]:
            with self.subTest(signature=signature):
                self.write_feed(signature=signature)
                self.generate(expected_error="Every archive needs a valid base64 Ed25519 signature")

    def test_rejects_zero_negative_and_wrong_archive_lengths(self):
        for length in [0, -1, self.archive.stat().st_size + 1]:
            with self.subTest(length=length):
                self.write_feed(length=length)
                self.generate(expected_error="Archive length must be positive and match the file exactly")

    def test_rejects_non_https_credentials_and_other_download_locations(self):
        for url in ["http://example.org/MacSai-2.dmg", "https://user:pass@example.org/MacSai-2.dmg",
                    "https://other.example.org/releases/v2/MacSai-2.dmg"]:
            with self.subTest(url=url):
                self.write_feed(url=url)
                self.generate(expected_error="Archive URL")

    def test_rejects_wrong_signing_key_even_with_complete_signatures(self):
        self.write_feed(seed=OTHER_SEED)
        self.environment["SPARKLE_PRIVATE_KEY"] = OTHER_SEED
        self.generate(expected_error="Archive signature does not match the configured public key or archive bytes")

    def test_rejects_archive_tampering(self):
        self.write_feed()
        original = self.archive.read_bytes()
        self.archive.write_bytes(b"X" + original[1:])
        self.generate(expected_error="Archive signature does not match the configured public key or archive bytes")

    def test_rejects_unsigned_and_tampered_feeds(self):
        for tamper in [False, True]:
            with self.subTest(tamper=tamper):
                self.write_feed()
                data = self.feed.read_bytes()
                if tamper:
                    data = data.replace(b"<sparkle:version>2", b"<sparkle:version>3")
                else:
                    # Keep the XML payload while removing Sparkle's signed trailer.
                    data = data[:data.index(b"<!-- sparkle-signatures:")]
                self.feed.write_bytes(data)
                self.generate(expected_error="Error:")

    def test_verifies_feed_with_the_same_signing_key_source(self):
        self.write_feed()
        self.environment["SPARKLE_PRIVATE_KEY"] = OTHER_SEED
        self.generate(expected_error="failed to pass signing verification")

    def test_rejects_missing_and_invalid_configured_public_keys(self):
        for key in ["", "not-base64", base64.b64encode(b"x" * 64).decode()]:
            with self.subTest(key=key):
                self.write_feed()
                self.environment["SPARKLE_PUBLIC_ED_KEY"] = key
                self.generate(expected_error="SPARKLE_PUBLIC_ED_KEY" if key == "" else "Configured public key must decode to exactly 32 bytes")


if __name__ == "__main__":
    unittest.main()
