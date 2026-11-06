#!/usr/bin/env python3
import base64
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("configuration", Path(__file__).with_name("configure-updates.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ConfigurationTests(unittest.TestCase):
    def test_unconfigured_build_has_no_installation_feed(self):
        self.assertEqual(module.configuration({}), {})

    def test_only_public_key_and_https_feed_are_embedded(self):
        key = base64.b64encode(b"x" * 32).decode()
        config = module.configuration({"SPARKLE_FEED_URL": "https://example.org/feed.xml", "SPARKLE_PUBLIC_ED_KEY": key})
        self.assertEqual(config["SUPublicEDKey"], key)
        self.assertTrue(config["SURequireSignedFeed"])
        self.assertTrue(config["SUVerifyUpdateBeforeExtraction"])
        self.assertEqual(config["SUSignedFeedFailureExpirationInterval"], 0)
        self.assertTrue(config["SUEnableAutomaticChecks"])
        self.assertEqual(config["SUScheduledCheckInterval"], 86400)
        self.assertFalse(config["SUAutomaticallyUpdate"])
        self.assertFalse(config["SUEnableSystemProfiling"])

    def test_rejects_partial_http_and_private_key_sized_input(self):
        for values in [
            {"SPARKLE_FEED_URL": "https://example.org/feed.xml"},
            {"SPARKLE_PUBLIC_ED_KEY": base64.b64encode(b"x" * 32).decode()},
            {"SPARKLE_FEED_URL": "http://example.org/feed.xml", "SPARKLE_PUBLIC_ED_KEY": base64.b64encode(b"x" * 32).decode()},
            {"SPARKLE_FEED_URL": "https://example.org/feed.xml", "SPARKLE_PUBLIC_ED_KEY": base64.b64encode(b"x" * 64).decode()},
        ]:
            with self.assertRaises(ValueError):
                module.configuration(values)


class BuildScriptTests(unittest.TestCase):
    def test_build_system_options_work_with_system_bash(self):
        # Run the real script, including set -u, with macOS's /bin/bash 3.2.
        # Stop at the bin-path query so this never builds or packages an app.
        build_script = Path(__file__).with_name("build-dmg.sh").resolve()
        for build_system in (None, "", "native"):
            with self.subTest(build_system=build_system), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                mock_bin = root / "bin"
                mock_bin.mkdir()
                argument_log = root / "swift-arguments.jsonl"
                swift = mock_bin / "swift"
                swift.write_text(
                    "#!/bin/bash\n"
                    'exec "$BUILD_TEST_PYTHON" - "$@" <<\'PY\'\n'
                    "import json, os, sys\n"
                    'with open(os.environ["BUILD_TEST_ARGUMENT_LOG"], "a") as log:\n'
                    '    log.write(json.dumps(sys.argv[1:]) + "\\n")\n'
                    'sys.exit(97 if "--show-bin-path" in sys.argv else 0)\n'
                    "PY\n"
                )
                swift.chmod(0o755)
                env = os.environ.copy()
                for name in ("SWIFT_BUILD_SYSTEM", "DMG_STAGING_ROOT", "BASH_ENV", "ENV"):
                    env.pop(name, None)
                env.update({
                    "PATH": f"{mock_bin}{os.pathsep}{os.defpath}",
                    "VERSION": "1.30.0", "BUILD_NUMBER": "1.30.0",
                    "BUILD_ARCHS": "--arch arm64",
                    "BUILD_TEST_PYTHON": sys.executable,
                    "BUILD_TEST_ARGUMENT_LOG": str(argument_log),
                })
                if build_system is not None:
                    env["SWIFT_BUILD_SYSTEM"] = build_system
                result = subprocess.run(
                    ["/bin/bash", str(build_script), "--app-only"], cwd=root,
                    env=env, capture_output=True, text=True, timeout=10,
                )
                self.assertEqual(result.returncode, 97, result.stdout + result.stderr)
                calls = [json.loads(line) for line in argument_log.read_text().splitlines()]
                options = ["--build-system", build_system] if build_system else []
                prefix = ["build", *options, "-c", "release", "--arch", "arm64", "--product"]
                self.assertEqual(calls, [
                    [*prefix, "MacClean"],
                    [*prefix, "MacCleanMenu"],
                    [*prefix, "MacClean", "--show-bin-path"],
                ])


if __name__ == "__main__":
    unittest.main()
