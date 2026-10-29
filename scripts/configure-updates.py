#!/usr/bin/env python3
"""Embed public update configuration. Never accepts or writes a private key."""
import base64
import os
import plistlib
import sys
from urllib.parse import urlparse


def configuration(environment):
    feed = environment.get("SPARKLE_FEED_URL", "")
    public_key = environment.get("SPARKLE_PUBLIC_ED_KEY", "")
    if not feed and not public_key:
        return {}  # Local/unconfigured build: no in-app installation.
    parsed = urlparse(feed)
    if (parsed.scheme != "https" or not parsed.hostname or parsed.username
            or parsed.password or parsed.fragment):
        raise ValueError("SPARKLE_FEED_URL must be an HTTPS URL without credentials or a fragment")
    try:
        decoded = base64.b64decode(public_key, validate=True)
    except ValueError as error:
        raise ValueError("SPARKLE_PUBLIC_ED_KEY must be a base64 Ed25519 public key") from error
    if len(decoded) != 32:
        raise ValueError("SPARKLE_PUBLIC_ED_KEY must decode to exactly 32 bytes")
    result = {
        "SUFeedURL": feed,
        "SUPublicEDKey": public_key,
        "SUVerifyUpdateBeforeExtraction": True,
        "SURequireSignedFeed": True,
        "SUSignedFeedFailureExpirationInterval": 0,
        "SUEnableSystemProfiling": False,
        "SUEnableJavaScript": False,
        "SUEnableAutomaticChecks": True,
        "SUScheduledCheckInterval": 86400,
        "SUAutomaticallyUpdate": False,
        "SUShowReleaseNotes": True,
    }
    if environment.get("UPDATE_CHANNEL_NAME"):
        result["MacSaiUpdateChannelName"] = environment["UPDATE_CHANNEL_NAME"]
    return result


if __name__ == "__main__":
    try:
        updates = configuration(os.environ)
        path = sys.argv[1]
        with open(path, "rb") as stream:
            info = plistlib.load(stream)
        info.update(updates)
        with open(path, "wb") as stream:
            plistlib.dump(info, stream, sort_keys=False)
    except (ValueError, OSError, IndexError) as error:
        sys.exit(f"Update configuration error: {error}")
