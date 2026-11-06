#!/bin/bash
# Sign a prepared update archive and its release notes using Sparkle's pinned
# tooling. The archive directory must contain the already signed/notarized DMG
# and an optional same-basename .md file. Never modify files after this step.
# Do not expose a private key even if a caller invokes this script with bash -x.
set +x
set -euo pipefail

ARCHIVES="${1:?Usage: generate-update-feed.sh archive-directory HTTPS-download-prefix}"
PREFIX="${2:?HTTPS-download-prefix is required}"
PUBLIC_KEY="${SPARKLE_PUBLIC_ED_KEY:?Set SPARKLE_PUBLIC_ED_KEY to the key embedded in the app}"
case "$PREFIX" in https://*) ;; *) echo "ERROR: download prefix must use HTTPS"; exit 1 ;; esac
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOOL_DIR=".build/artifacts/sparkle/Sparkle/bin"
TOOL="$TOOL_DIR/generate_appcast"
VERIFY_TOOL="$TOOL_DIR/sign_update"
if [[ ! -x "$TOOL" || ! -x "$VERIFY_TOOL" ]]; then
    echo "ERROR: resolve the pinned Sparkle package before generating updates"
    exit 1
fi
VERIFY_DIR="$(mktemp -d "${TMPDIR:-/tmp}/macsai-appcast.XXXXXX")"
trap 'rm -rf "$VERIFY_DIR"' EXIT
CANDIDATE="$VERIFY_DIR/appcast.xml"
OPTIONS=(--download-url-prefix "$PREFIX" --release-notes-url-prefix "$PREFIX"
    --embed-release-notes --maximum-deltas 0 -o "$CANDIDATE")
if [[ -n "${SPARKLE_PRIVATE_KEY:-}" ]]; then
    # Standard input keeps the secret out of argv and generated build files.
    printf '%s' "$SPARKLE_PRIVATE_KEY" | "$TOOL" --ed-key-file - "${OPTIONS[@]}" "$ARCHIVES"
else
    # Local release tests may use a key generated in the login Keychain.
    "$TOOL" --account "${SPARKLE_KEY_ACCOUNT:-ed25519}" "${OPTIONS[@]}" "$ARCHIVES"
fi
test -s "$CANDIDATE"
# generate_appcast can return success after warning that an archive's embedded
# public key differs from the signing key. Presence of XML alone is not enough.
xcrun swift "$SCRIPT_DIR/verify-update-feed.swift" "$CANDIDATE" "$ARCHIVES" "$PUBLIC_KEY" "$PREFIX"
if [[ -n "${SPARKLE_PRIVATE_KEY:-}" ]]; then
    printf '%s' "$SPARKLE_PRIVATE_KEY" | "$VERIFY_TOOL" --ed-key-file - --verify "$CANDIDATE"
else
    "$VERIFY_TOOL" --account "${SPARKLE_KEY_ACCOUNT:-ed25519}" --verify "$CANDIDATE"
fi
# Publish the candidate only after both the archives and signed feed validate.
mv "$CANDIDATE" "$ARCHIVES/appcast.xml"
echo "Verified signed update feed and all referenced archives."
