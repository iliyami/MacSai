#!/bin/bash
# Sign a prepared update archive and its release notes using Sparkle's pinned
# tooling. The archive directory must contain the already signed/notarized DMG
# and an optional same-basename .md file. Never modify files after this step.
set -euo pipefail

ARCHIVES="${1:?Usage: generate-update-feed.sh archive-directory HTTPS-download-prefix}"
PREFIX="${2:?HTTPS-download-prefix is required}"
case "$PREFIX" in https://*) ;; *) echo "ERROR: download prefix must use HTTPS"; exit 1 ;; esac
TOOL=".build/artifacts/sparkle/Sparkle/bin/generate_appcast"
if [[ ! -x "$TOOL" ]]; then
    echo "ERROR: resolve the pinned Sparkle package before generating updates"
    exit 1
fi
OPTIONS=(--download-url-prefix "$PREFIX" --release-notes-url-prefix "$PREFIX"
    --embed-release-notes --maximum-deltas 0 -o "$ARCHIVES/appcast.xml")
if [[ -n "${SPARKLE_PRIVATE_KEY:-}" ]]; then
    # Standard input keeps the secret out of argv and generated build files.
    printf '%s' "$SPARKLE_PRIVATE_KEY" | "$TOOL" --ed-key-file - "${OPTIONS[@]}" "$ARCHIVES"
else
    # Local release tests may use a key generated in the login Keychain.
    "$TOOL" --account "${SPARKLE_KEY_ACCOUNT:-ed25519}" "${OPTIONS[@]}" "$ARCHIVES"
fi
test -s "$ARCHIVES/appcast.xml"
