#!/usr/bin/env python3
import base64
import importlib.util
from pathlib import Path
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


if __name__ == "__main__":
    unittest.main()
