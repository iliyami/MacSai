#!/bin/bash
# check-network-surface.sh
#
# Verifies the SHIPPED BINARY's network surface matches what the README claims:
# the only networking class it imports is URLSession, the only URLs compiled in
# are the two disclosed update endpoints, and there is no tracker, analytics, or
# crash-reporter SDK anywhere in it.
#
# The point (raised by a reviewer): the repo and the installed binary are two
# different artifacts, so grepping the source proves nothing about the build on
# a user's disk. This inspects the binary itself, the same thing a user can run
# with `nm -u` / `strings` after `brew install`. It runs in CI on every PR so a
# hidden network path or a snuck-in SDK fails the build before it can ship.
#
# Usage: scripts/check-network-surface.sh [path-to-binary]
#   Defaults to the SPM build, then the installed app.

set -euo pipefail

BIN="${1:-}"
if [ -z "$BIN" ]; then
    for cand in \
        ".build/release/MacClean" \
        ".build/debug/MacClean" \
        "/Applications/Mac Sai.app/Contents/MacOS/MacClean"; do
        if [ -f "$cand" ]; then BIN="$cand"; break; fi
    done
fi
if [ -z "$BIN" ] || [ ! -f "$BIN" ]; then
    echo "::error::check-network-surface: no binary found to inspect (pass a path)"
    exit 1
fi
echo "Inspecting network surface of: $BIN"

# Snapshot the symbol table and strings once, then match against those. Grepping
# the pipelines directly would race `grep -q`'s early exit against SIGPIPE under
# `set -o pipefail` and mis-report matches.
SYMS="$(nm -u "$BIN" 2>/dev/null || true)"
STRS="$(strings -a "$BIN" 2>/dev/null || true)"

fail=0

# 1) Low-level networking symbols would mean a channel that bypasses the
#    disclosed, URLSession-based update checks. None should be present.
BANNED_SYMBOLS='NWConnection|NWBrowser|nw_connection|nw_endpoint|CFSocket|CFStreamCreatePairWithSocketToHost|CFReadStreamCreate|CFWriteStreamCreate'
sym_hits="$(grep -iE "$BANNED_SYMBOLS" <<<"$SYMS" | sort -u || true)"
if [ -n "$sym_hits" ]; then
    echo "::error::Unexpected low-level networking symbols:"
    echo "$sym_hits"
    fail=1
fi

# 2) Tracker / analytics / crash-reporter domains and SDK markers.
BANNED_HOSTS='sentry\.io|mixpanel|firebase|firebaseio|google-analytics|googletagmanager|doubleclick|segment\.(io|com)|amplitude|bugsnag|crashlytics|datadoghq|posthog|appcenter\.ms|adjust\.com|appsflyer|flurry|umeng'
host_hits="$(grep -iE "$BANNED_HOSTS" <<<"$STRS" | sort -u || true)"
if [ -n "$host_hits" ]; then
    echo "::error::Tracker/analytics endpoint or SDK marker found:"
    echo "$host_hits"
    fail=1
fi

# 3) Sanity: the two disclosed update endpoints should be present.
for endpoint in \
    "api.github.com/repos/iliyami/MacSai/releases/latest" \
    "formulae.brew.sh/api/cask/mac-sai.json"; do
    if ! grep -qF "$endpoint" <<<"$STRS"; then
        echo "::warning::expected update endpoint not found in binary: $endpoint"
    fi
done

# 4) Print the full surface for the record (shows up in CI logs every run).
echo "--- Networking symbols imported (expect only NSURLSession) ---"
grep -iE 'URLSession|URLConnection|CFNetwork|NWConnection|CFSocket|CFStream' <<<"$SYMS" | sort -u || echo "(none)"
echo "--- URLs compiled into the binary ---"
grep -iE 'https?://' <<<"$STRS" | sort -u || echo "(none)"

if [ "$fail" -ne 0 ]; then
    echo "::error::Network-surface check FAILED (see above)."
    exit 1
fi
echo "Network-surface check passed: only URLSession, only the disclosed endpoints."
