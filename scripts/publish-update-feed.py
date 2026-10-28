#!/usr/bin/env python3
"""Publish a verified appcast from an existing stable release's curated notes.

Never creates/deletes a release or tag. The release archive must already be
public. A signed candidate is uploaded and read back before the old appcast is
renamed to a recoverable backup and the candidate promoted. GitHub has no atomic
asset swap: the two renames can briefly leave appcast.xml unavailable.
"""
import base64
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from urllib.parse import urlsplit
import uuid

ROOT = Path(__file__).resolve().parent.parent


def require(condition, message):
    if not condition:
        raise ValueError(message)


class GitHub:
    def __init__(self, repository):
        self.repository = repository

    def api(self, suffix, *arguments):
        result = subprocess.run(["gh", "api", f"repos/{self.repository}/{suffix}", *arguments],
                                check=True, capture_output=True)
        return json.loads(result.stdout)

    def release(self, tag):
        release = self.api(f"releases/tags/{tag}")
        pages = self.api(f"releases/{release['id']}/assets", "--paginate", "--slurp")
        release["assets"] = [asset for page in pages for asset in page]
        return release

    def latest(self):
        return self.api("releases/latest")

    def download(self, asset, destination):
        with destination.open("wb") as stream:
            subprocess.run(["gh", "api", f"repos/{self.repository}/releases/assets/{asset['id']}",
                            "-H", "Accept: application/octet-stream"], check=True, stdout=stream)

    def upload(self, tag, path):
        subprocess.run(["gh", "release", "upload", tag, str(path), "--repo", self.repository], check=True)
        matches = [asset for asset in self.release(tag)["assets"] if asset["name"] == path.name]
        require(len(matches) == 1, "Cannot identify uploaded candidate; old appcast has not been renamed")
        return matches[0]

    def rename(self, asset, name):
        updated = self.api(f"releases/assets/{asset['id']}", "--method", "PATCH", "-f", f"name={name}")
        require(updated.get("id") == asset["id"] and updated.get("name") == name,
                f"Cannot confirm rename of release asset {asset['id']}; inspect its current name")
        return updated


def validate_configuration(repository, tag, environment):
    require(re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*", repository),
            "Invalid GITHUB_REPOSITORY")
    require(re.fullmatch(r"v[0-9]+\.[0-9]+\.[0-9]+", tag), "RELEASE_TAG must be a stable vX.Y.Z tag")
    require(bool(environment.get("SPARKLE_PRIVATE_KEY")), "SPARKLE_PRIVATE_KEY is required; refusing an unsigned feed")
    key = environment.get("SPARKLE_PUBLIC_ED_KEY", "")
    require(len(base64.b64decode(key, validate=True)) == 32, "SPARKLE_PUBLIC_ED_KEY must contain 32 public-key bytes")
    feed = urlsplit(environment.get("SPARKLE_FEED_URL", ""))
    require(feed.scheme == "https" and feed.hostname and not feed.username and not feed.password,
            "SPARKLE_FEED_URL must be configured as HTTPS without credentials")


def release_snapshot(github, repository, tag):
    release = github.release(tag)
    latest = github.latest()
    require(release.get("tag_name") == tag and release.get("draft") is False and release.get("prerelease") is False
            and release.get("published_at"), "Feed publication requires an already published stable release")
    require(latest.get("id") == release.get("id") and latest.get("tag_name") == tag,
            "Requested tag is no longer the latest stable release; select the current release and rerun")
    notes = release.get("body")
    require(isinstance(notes, str) and notes.strip(), "Curated release notes must not be empty")
    filename = f"MacSai-{tag[1:]}.dmg"
    archives = [asset for asset in release.get("assets", []) if asset.get("name") == filename]
    require(len(archives) == 1, f"Expected exactly one already uploaded archive: {filename}")
    archive = archives[0]
    expected_url = f"https://github.com/{repository}/releases/download/{tag}/{filename}"
    require(archive.get("state") == "uploaded" and isinstance(archive.get("size"), int)
            and archive["size"] > 0 and isinstance(archive.get("id"), int), "Invalid published archive metadata")
    require(archive.get("browser_download_url") == expected_url, "Archive does not belong to the requested release URL")
    require(re.fullmatch(r"sha256:[0-9a-f]{64}", archive.get("digest") or ""), "Published archive needs a SHA-256 digest")
    old_feeds = [asset for asset in release.get("assets", []) if asset.get("name") == "appcast.xml"]
    require(len(old_feeds) <= 1, "Ambiguous existing appcast asset")
    return {
        "release_id": release["id"], "body": notes, "archive": archive,
        "old_feed": old_feeds[0] if old_feeds else None,
    }


def fingerprint(snapshot):
    archive = snapshot["archive"]
    old_feed = snapshot["old_feed"]
    return (snapshot["release_id"], snapshot["body"],
            tuple(archive.get(key) for key in ("id", "name", "size", "digest", "browser_download_url")),
            tuple(old_feed.get(key) for key in ("id", "size", "digest")) if old_feed else None)


def generate_feed(directory, prefix):
    # The generator validates archive signatures against the configured public
    # key, exact lengths/HTTPS URLs, and the signed feed with the same key source.
    # It receives the existing secret only through its environment and stdin.
    subprocess.run(["bash", str(ROOT / "scripts/generate-update-feed.sh"), str(directory), prefix],
                   cwd=ROOT, check=True)


def publish(repository, tag, environment, github=None, generator=generate_feed):
    validate_configuration(repository, tag, environment)
    github = github or GitHub(repository)
    snapshot = release_snapshot(github, repository, tag)
    prefix = f"https://github.com/{repository}/releases/download/{tag}/"
    with tempfile.TemporaryDirectory(prefix="macsai-publish-feed-") as temporary:
        directory = Path(temporary)
        archive = snapshot["archive"]
        archive_path = directory / archive["name"]
        github.download(archive, archive_path)
        archive_bytes = archive_path.read_bytes()
        require(len(archive_bytes) == archive["size"], "Downloaded archive size differs from the published asset")
        require("sha256:" + hashlib.sha256(archive_bytes).hexdigest() == archive["digest"],
                "Downloaded archive SHA-256 differs from the published asset")
        # Preserve the exact API body, including its newlines. Sparkle embeds
        # these curated notes before signing; do not rewrite the generated XML.
        archive_path.with_suffix(".md").write_bytes(snapshot["body"].encode("utf-8"))
        generator(directory, prefix)
        feed = directory / "appcast.xml"
        require(feed.is_file() and feed.stat().st_size > 0, "No verified appcast was produced")
        require(fingerprint(release_snapshot(github, repository, tag)) == fingerprint(snapshot),
                "Release notes/archive/feed changed during signing; rerun after curation finishes")

        suffix = uuid.uuid4().hex
        candidate_path = directory / f"appcast-candidate-{suffix}.xml"
        candidate_path.write_bytes(feed.read_bytes())
        candidate = github.upload(tag, candidate_path)
        downloaded = directory / "downloaded-candidate.xml"
        github.download(candidate, downloaded)
        require(downloaded.read_bytes() == feed.read_bytes(),
                f"Uploaded candidate bytes differ; old appcast is unchanged. Inspect candidate asset {candidate['id']}")
        require(fingerprint(release_snapshot(github, repository, tag)) == fingerprint(snapshot),
                "Release notes/archive/feed changed before promotion; old appcast is unchanged, rerun dispatch")

        previous = snapshot["old_feed"]
        if previous:
            backup_name = f"appcast-previous-{suffix}.xml"
            github.rename(previous, backup_name)
            print(f"Recoverable previous feed: asset {previous['id']} ({backup_name})")
        try:
            promoted = github.rename(candidate, "appcast.xml")
        except Exception as promotion_error:
            # Do not delete either candidate or previous signed bytes. If the
            # request outcome was ambiguous, inspect GitHub before any retry.
            if previous:
                try:
                    github.rename(previous, "appcast.xml")
                    print("Promotion failed; previous appcast name restored.", file=sys.stderr)
                except Exception as restore_error:
                    raise RuntimeError(
                        f"Promotion/rollback need manual recovery. Previous asset {previous['id']}; "
                        f"candidate asset {candidate['id']}. Both bytes are retained. "
                        "Inspect asset names before rerunning; see docs/IN_APP_UPDATES.md."
                    ) from restore_error
            raise promotion_error
        print(f"Published verified appcast asset {promoted['id']} using final notes from {tag}.")
        print("The source archive was already public; no release/tag or historical asset was deleted.")


if __name__ == "__main__":
    try:
        publish(os.environ.get("GITHUB_REPOSITORY", ""), os.environ.get("RELEASE_TAG", ""), os.environ)
    except (ValueError, OSError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"::error::Update-feed publication stopped: {error}", file=sys.stderr)
        sys.exit(1)
