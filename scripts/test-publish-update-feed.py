#!/usr/bin/env python3
"""Publication fixtures; no GitHub writes or real release credentials are used.

The signing/generator boundary is covered with real Sparkle signatures by
test-update-feed.py. These fixtures exercise ordering, release identity, exact
curated notes, downloaded bytes and recovery with a deterministic GitHub double.
Archive inspection uses real fixture plists and a mocked hdiutil boundary, so
these unit tests neither mount images nor inspect the installed application.
"""
import base64
import copy
import hashlib
import importlib.util
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile
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

    def archive_verifier(self, archive_path, version, environment):
        self.assertEqual(archive_path.read_bytes(), ARCHIVE)
        self.assertEqual(version, TAG[1:])
        self.github.events.append(("archive-validated",))

    def publish(self, generator=None, environment=None, tag=TAG, archive_verifier=None):
        PUBLISH.publish(REPOSITORY, tag, environment or ENVIRONMENT,
                        github=self.github, generator=generator or self.generator,
                        archive_verifier=archive_verifier or self.archive_verifier)

    def assertOldFeedUntouched(self):
        self.assertEqual(self.github.data[2], OLD_FEED)
        old = next(a for a in self.github.record["assets"] if a["id"] == 2)
        self.assertEqual(old["name"], "appcast.xml")
        self.assertFalse(any(event[0] == "rename" for event in self.github.events))

    def testPublishedFinalNotesArePreservedAndCandidateReadBackBeforePromotion(self):
        self.publish()
        self.assertEqual(self.notes_seen, self.github.record["body"].encode())
        kinds = [event[0] for event in self.github.events]
        self.assertEqual(kinds, ["download", "archive-validated", "validated", "upload", "download", "rename", "rename"])
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

    def testArchiveConfigurationOrMountFailureStopsBeforeSigningAndUpload(self):
        for error in (ValueError("published feed URL drift"), RuntimeError("archive mount failed")):
            self.github = FakeGitHub()
            def fail(archive_path, version, environment):
                raise error
            with self.subTest(error=error), self.assertRaises(type(error)):
                self.publish(archive_verifier=fail)
            self.assertOldFeedUntouched()
            self.assertEqual(self.github.events, [("download", 1)])

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


class ArchiveConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.info = {"CFBundleIdentifier": "com.macclean.app", "CFBundleShortVersionString": TAG[1:],
                     "SUFeedURL": ENVIRONMENT["SPARKLE_FEED_URL"],
                     "SUPublicEDKey": ENVIRONMENT["SPARKLE_PUBLIC_ED_KEY"],
                     "SURequireSignedFeed": True, "SUVerifyUpdateBeforeExtraction": True,
                     "SUSignedFeedFailureExpirationInterval": 0,
                     "SUEnableSystemProfiling": False, "SUEnableJavaScript": False}
        self.events = []
        self.mode = "valid"
        self.detach_failure = False
        self.mount = None
        self.outside = tempfile.TemporaryDirectory(prefix="macsai-mount-fixture-")
        self.addCleanup(self.outside.cleanup)

    def runner(self, command, **options):
        self.events.append(command[1])
        if command[1] == "attach":
            self.assertIn("-readonly", command)
            self.assertIn("-nobrowse", command)
            self.assertIn("-noautoopen", command)
            self.assertEqual(options["stdin"], subprocess.DEVNULL)
            self.mount = Path(command[command.index("-mountpoint") + 1])
            self.addCleanup(shutil.rmtree, self.mount, True)
            if self.mode == "attach-failure":
                raise subprocess.CalledProcessError(1, command)
            if self.mode == "attach-timeout":
                raise subprocess.TimeoutExpired(command, 60)
            app = self.mount / ("Other.app" if self.mode == "wrong-app" else "Mac Sai.app")
            contents = app / "Contents"
            if self.mode != "missing-app":
                contents.mkdir(parents=True)
                (contents / "Info.plist").write_bytes(plistlib.dumps(self.info))
            if self.mode == "extra-app":
                (self.mount / "Other.app").mkdir()
            if self.mode in {"app-symlink", "contents-symlink", "plist-symlink"}:
                outside = Path(self.outside.name)
                (outside / "Info.plist").write_bytes(plistlib.dumps(self.info))
                if self.mode == "app-symlink":
                    shutil.rmtree(app)
                    app.symlink_to(outside, target_is_directory=True)
                elif self.mode == "contents-symlink":
                    shutil.rmtree(contents)
                    contents.symlink_to(outside, target_is_directory=True)
                else:
                    (contents / "Info.plist").unlink()
                    (contents / "Info.plist").symlink_to(outside / "Info.plist")
            if self.mode == "invalid-plist":
                (contents / "Info.plist").write_bytes(b"not a plist")
            if self.mode == "plist-array":
                (contents / "Info.plist").write_bytes(plistlib.dumps([]))
            # A normal DMG's Applications shortcut must not be traversed.
            (self.mount / "Applications").symlink_to(Path(self.outside.name), target_is_directory=True)
            entities = [{"mount-point": str(self.mount)}]
            if self.mode == "wrong-mount":
                entities = [{"mount-point": self.outside.name}]
            if self.mode == "extra-mount":
                entities.append({"mount-point": self.outside.name})
            if self.mode == "invalid-metadata":
                entities = "not a volume list"
            return subprocess.CompletedProcess(command, 0, stdout=plistlib.dumps({"system-entities": entities}))
        if self.detach_failure:
            raise subprocess.CalledProcessError(1, command)
        shutil.rmtree(command[2])
        return subprocess.CompletedProcess(command, 0, stdout=b"")

    def verify(self):
        PUBLISH.verify_archive_configuration(Path("fixture.dmg"), TAG[1:], ENVIRONMENT, runner=self.runner)

    def testMatchingPublishedAppPassesAndDetaches(self):
        self.verify()
        self.assertEqual(self.events, ["attach", "detach"])
        self.assertFalse(self.mount.exists())

    def testFeedKeyVersionAndIdentityDriftFailAndDetach(self):
        for key, value in (("SUFeedURL", "https://other.example.org/appcast.xml"),
                           ("SUPublicEDKey", base64.b64encode(b"x" * 32).decode()),
                           ("CFBundleShortVersionString", "1.27.1"),
                           ("CFBundleIdentifier", "org.example.other")):
            previous = self.info[key]
            self.info[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                self.verify()
            self.assertEqual(self.events[-2:], ["attach", "detach"])
            self.info[key] = previous

    def testMissingOrWeakenedTrustAndPrivacySettingsFail(self):
        for key in ("SURequireSignedFeed", "SUVerifyUpdateBeforeExtraction", "SUSignedFeedFailureExpirationInterval",
                    "SUEnableSystemProfiling", "SUEnableJavaScript"):
            previous = self.info[key]
            for value in (None, not previous):
                self.info[key] = value
                if value is None:
                    del self.info[key]
                with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                    self.verify()
                self.assertEqual(self.events[-2:], ["attach", "detach"])
            self.info[key] = previous

    def testAmbiguousAppsAndEscapingSymlinksFailWithoutFollowingApplicationsShortcut(self):
        for mode in ("missing-app", "wrong-app", "extra-app", "app-symlink", "contents-symlink", "plist-symlink"):
            self.mode = mode
            with self.subTest(mode=mode), self.assertRaises(ValueError):
                self.verify()
            self.assertEqual(self.events[-2:], ["attach", "detach"])

    def testInvalidPlistsAndUnexpectedMountsFailAndDetach(self):
        for mode in ("invalid-plist", "plist-array", "wrong-mount", "extra-mount", "invalid-metadata"):
            self.mode = mode
            with self.subTest(mode=mode), self.assertRaises(ValueError):
                self.verify()
            self.assertEqual(self.events[-2:], ["attach", "detach"])

    def testFailedOrTimedOutMountStillAttemptsDetach(self):
        for mode in ("attach-failure", "attach-timeout"):
            self.mode = mode
            with self.subTest(mode=mode), self.assertRaisesRegex(RuntimeError, "Cannot mount published archive"):
                self.verify()
            self.assertEqual(self.events[-2:], ["attach", "detach"])

    def testDetachFailurePreventsPublicationAndRetainsMountForRecovery(self):
        self.detach_failure = True
        with self.assertRaisesRegex(RuntimeError, "Could not detach published archive"):
            self.verify()
        self.assertEqual(self.events, ["attach", "detach"])
        self.assertTrue(self.mount.exists())


if __name__ == "__main__":
    unittest.main()
