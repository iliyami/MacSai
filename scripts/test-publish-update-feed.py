#!/usr/bin/env python3
"""Publication fixtures; no GitHub writes or real release credentials are used.

The signing/generator boundary is covered with real Sparkle signatures by
test-update-feed.py. These fixtures exercise ordering, release identity, exact
curated notes, downloaded bytes and recovery with a deterministic GitHub double.
"""
import base64
import copy
import hashlib
import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location("publish_update_feed", Path(__file__).with_name("publish-update-feed.py"))
PUBLISH = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PUBLISH)
REPOSITORY = "example/MacSai"
TAG = "v1.28.0"
ARCHIVE = b"already published archive fixture"
OLD_FEED = b"previous signed appcast bytes"
ENVIRONMENT = {"SPARKLE_PRIVATE_KEY": "fixture-only-not-a-real-signing-key",
               "SPARKLE_PUBLIC_ED_KEY": base64.b64encode(bytes(range(32))).decode(),
               "SPARKLE_FEED_URL": "https://github.com/example/MacSai/releases/latest/download/appcast.xml"}


def asset(identifier, name, data):
    return {"id": identifier, "name": name, "size": len(data), "state": "uploaded",
            "digest": "sha256:" + hashlib.sha256(data).hexdigest(),
            "browser_download_url": f"https://github.com/{REPOSITORY}/releases/download/{TAG}/{name}"}


class FakeGitHub:
    def __init__(self):
        self.data = {1: ARCHIVE, 2: OLD_FEED}
        self.record = {"id": 17, "tag_name": TAG, "draft": False, "prerelease": False,
                       "published_at": "2026-10-28T00:00:00Z", "body": "## Curated improvements\r\n\r\nUser-reviewed notes.\n",
                       "assets": [asset(1, "MacSai-1.28.0.dmg", ARCHIVE), asset(2, "appcast.xml", OLD_FEED)]}
        self.latest_tag = TAG
        self.events = []
        self.tamper_candidate = False
        self.fail_upload = False
        self.fail_promotion = False
        self.fail_rollback = False
        self.after_upload = None

    def release(self, tag):
        return copy.deepcopy(self.record)

    def latest(self):
        return {"id": 17 if self.latest_tag == TAG else 18, "tag_name": self.latest_tag}

    def download(self, target, destination):
        self.events.append(("download", target["id"]))
        data = self.data[target["id"]]
        if target["id"] == 3 and self.tamper_candidate:
            data += b"tampered"
        destination.write_bytes(data)

    def upload(self, tag, path):
        self.events.append(("upload", path.name))
        if self.fail_upload:
            raise RuntimeError("upload failed")
        data = path.read_bytes()
        self.data[3] = data
        candidate = asset(3, path.name, data)
        self.record["assets"].append(candidate)
        if self.after_upload:
            self.after_upload()
        return copy.deepcopy(candidate)

    def rename(self, target, name):
        self.events.append(("rename", target["id"], name))
        if target["id"] == 3 and name == "appcast.xml" and self.fail_promotion:
            raise RuntimeError("promotion failed")
        if target["id"] == 2 and name == "appcast.xml" and self.fail_rollback:
            raise RuntimeError("rollback failed")
        for current in self.record["assets"]:
            if current["id"] == target["id"]:
                current["name"] = name
                return copy.deepcopy(current)
        raise AssertionError("Unknown fixture asset")


class PublicationTests(unittest.TestCase):
    def setUp(self):
        self.github = FakeGitHub()
        self.notes_seen = None

    def generator(self, directory, prefix):
        self.github.events.append(("validated",))
        self.notes_seen = (directory / "MacSai-1.28.0.md").read_bytes()
        (directory / "appcast.xml").write_bytes(b"verified signed feed: " + self.notes_seen)

    def publish(self, generator=None, environment=None, tag=TAG):
        PUBLISH.publish(REPOSITORY, tag, environment or ENVIRONMENT,
                        github=self.github, generator=generator or self.generator)

    def assertOldFeedUntouched(self):
        self.assertEqual(self.github.data[2], OLD_FEED)
        old = next(a for a in self.github.record["assets"] if a["id"] == 2)
        self.assertEqual(old["name"], "appcast.xml")
        self.assertFalse(any(event[0] == "rename" for event in self.github.events))

    def testPublishedFinalNotesArePreservedAndCandidateReadBackBeforePromotion(self):
        self.publish()
        self.assertEqual(self.notes_seen, self.github.record["body"].encode())
        kinds = [event[0] for event in self.github.events]
        self.assertEqual(kinds, ["download", "validated", "upload", "download", "rename", "rename"])
        self.assertEqual(self.github.events[-1], ("rename", 3, "appcast.xml"))
        self.assertEqual(self.github.data[2], OLD_FEED, "Previous signed bytes remain recoverable")

    def testFirstFeedPublicationNeedsNoPreviousAsset(self):
        self.github.record["assets"] = self.github.record["assets"][:1]
        self.publish()
        renames = [event for event in self.github.events if event[0] == "rename"]
        self.assertEqual(renames, [("rename", 3, "appcast.xml")])

    def testDraftPrereleaseNonLatestAndEmptyNotesFailBeforeAnyWrite(self):
        for change in ({"draft": True}, {"prerelease": True}, {"published_at": None}, {"body": " \n"}):
            with self.subTest(change=change):
                self.github = FakeGitHub()
                self.github.record.update(change)
                with self.assertRaises(ValueError):
                    self.publish()
                self.assertEqual(self.github.events, [])
        self.github = FakeGitHub()
        self.github.latest_tag = "v1.29.0"
        with self.assertRaisesRegex(ValueError, "latest stable"):
            self.publish()
        self.assertEqual(self.github.events, [])

    def testMissingArchiveAndPrivateKeyFailBeforeWrites(self):
        self.github.record["assets"] = [self.github.record["assets"][1]]
        with self.assertRaisesRegex(ValueError, "already uploaded archive"):
            self.publish()
        self.assertEqual(self.github.events, [])
        environment = dict(ENVIRONMENT, SPARKLE_PRIVATE_KEY="")
        with self.assertRaisesRegex(ValueError, "PRIVATE_KEY"):
            self.publish(environment=environment)
        self.assertEqual(self.github.events, [])

    def testTagCannotInjectArgumentsOrPrerelease(self):
        for tag in ("--repo=attacker/repo", "v1.28.0; touch /tmp/no", "v1.28.0-beta.1", "../latest"):
            with self.subTest(tag=tag), self.assertRaises(ValueError):
                self.publish(tag=tag)
        self.assertEqual(self.github.events, [])

    def testWrongArchiveBytesOrSizeFailBeforeGeneration(self):
        for replacement in (ARCHIVE + b"extra", b"x" * len(ARCHIVE)):
            self.github = FakeGitHub()
            self.github.data[1] = replacement
            with self.assertRaisesRegex(ValueError, "Downloaded archive"):
                self.publish()
            self.assertOldFeedUntouched()
            self.assertNotIn(("validated",), self.github.events)

    def testSigningFailureCannotTouchOldFeed(self):
        def fail(directory, prefix):
            raise RuntimeError("signature/key mismatch")
        with self.assertRaisesRegex(RuntimeError, "signature"):
            self.publish(generator=fail)
        self.assertOldFeedUntouched()

    def testEditedNotesOrNewStableDuringSigningStopsBeforeUpload(self):
        for change in ("notes", "latest"):
            self.github = FakeGitHub()
            def generate(directory, prefix):
                self.generator(directory, prefix)
                if change == "notes":
                    self.github.record["body"] += "Edited again"
                else:
                    self.github.latest_tag = "v1.29.0"
            with self.subTest(change=change), self.assertRaises(ValueError):
                self.publish(generator=generate)
            self.assertOldFeedUntouched()
            self.assertFalse(any(e[0] == "upload" for e in self.github.events))

    def testEditedNotesAfterUploadStopsBeforeRenamingOldFeed(self):
        self.github.after_upload = lambda: self.github.record.update(body="New curation")
        with self.assertRaisesRegex(ValueError, "changed before promotion"):
            self.publish()
        self.assertOldFeedUntouched()

    def testUploadFailureOrTamperedReadbackLeavesOldFeedNamedAndIntact(self):
        self.github.fail_upload = True
        with self.assertRaisesRegex(RuntimeError, "upload failed"):
            self.publish()
        self.assertOldFeedUntouched()
        self.github = FakeGitHub()
        self.github.tamper_candidate = True
        with self.assertRaisesRegex(ValueError, "candidate bytes differ"):
            self.publish()
        self.assertOldFeedUntouched()

    def testPromotionFailureRestoresPreviousNameAndRetainsBothSignedFiles(self):
        self.github.fail_promotion = True
        with self.assertRaisesRegex(RuntimeError, "promotion failed"):
            self.publish()
        self.assertEqual(self.github.events[-1], ("rename", 2, "appcast.xml"))
        self.assertEqual(self.github.data[2], OLD_FEED)
        self.assertIn(3, self.github.data)

    def testFailedRollbackRetainsRecoverableAssetsAndExplainsRecovery(self):
        self.github.fail_promotion = True
        self.github.fail_rollback = True
        with self.assertRaisesRegex(RuntimeError, "manual recovery.*Previous asset 2; candidate asset 3"):
            self.publish()
        self.assertEqual(self.github.data[2], OLD_FEED)
        self.assertIn(3, self.github.data)


if __name__ == "__main__":
    unittest.main()
