# Signed in-app updates

Configured direct-install builds use Sparkle 2.10.1 for release notes, download
progress, signature validation, installation and relaunch. Automatic checking
and automatic downloading/installing are separate settings. Automatic
installation starts disabled. Existing `automaticUpdateChecks` choices migrate
on the first launch; later choices made in Sparkle's window are respected.
Homebrew installations retain their Homebrew route.

The first version containing Sparkle must be installed normally. Earlier Mac Sai
versions only open a release page and cannot install their own bootstrap update.

## Trust and configuration

The build has no default feed or signing key. A build without both values keeps
the previous release-page fallback and clearly labels in-app installation as
unconfigured. Partial/invalid configuration fails the package build.

Set these public build values together:

- `SPARKLE_FEED_URL`: an HTTPS appcast URL without URL credentials.
- `SPARKLE_PUBLIC_ED_KEY`: a base64 Ed25519 public key, exactly 32 decoded bytes.
- `BUILD_NUMBER`: a monotonically increasing numeric `CFBundleVersion`. The
  release workflow uses its run number; never mix numbering schemes in one feed.
  A manual build defaults to the numeric part of `VERSION`.
- Optional `UPDATE_CHANNEL_NAME`: a visible channel label, useful for private
  previews. Changing this label does not grant trust or select a Sparkle channel.

Both update archives and feed/release-note metadata must be signed. Signature
validation occurs before extraction; signed-feed failures never expire into an
unsigned fallback. The feed is pinned to the value sealed in the app bundle,
even if old preferences contain a different `SUFeedURL`. System profiling and
JavaScript in release notes are disabled. Keys and URLs are never fetched from
an untrusted configuration service at runtime.

The Sparkle private key is a separate secret. Generate and retain it using
Sparkle's `generate_keys` tool in the login Keychain, or put the exported value
in a protected CI secret. Never commit it, include it in `Info.plist`, paste it
into command arguments, or distribute it with an archive.

## Official release setup

1. Configure repository variables `SPARKLE_FEED_URL` and
   `SPARKLE_PUBLIC_ED_KEY`. For the existing GitHub release workflow the feed can
   be `https://github.com/iliyami/MacSai/releases/latest/download/appcast.xml`.
   This is a suggested deployment location, not a claim that it is already live.
2. The release owner generates and retains their own EdDSA key pair, with the
   private key in their login Keychain and an offline backup. They add the
   matching private key as the Actions secret `SPARKLE_PRIVATE_KEY`; nobody
   needs to share a private key with contributors. Existing Developer ID and
   notarization secrets remain required for building official releases.
3. Build/publish the stable release through the existing **Release** workflow,
   then finish editing its GitHub release notes. The app/DMG is already signed,
   notarized and publicly downloadable at this point. **A new latest stable
   release has no appcast until the next required step succeeds.** If using
   `/releases/latest/download/appcast.xml`, clients may temporarily find no feed;
   they fail closed and can retry. Plan the release/curation/publication window.
4. Run **Publish curated update feed** (`publish-update-feed.yml`) manually,
   selecting the current published stable `vX.Y.Z` tag. This is required for
   the first official feed and every later stable release. The workflow reads
   that release's final body, downloads its existing DMG, verifies its published
   SHA-256/size, and embeds those exact curated notes before signing. It does
   not call `releases/generate-notes`. It uses the existing `GITHUB_TOKEN` and
   `SPARKLE_PRIVATE_KEY`; no extra token or secret is needed. The private key
   reaches Sparkle through stdin, never argv or a generated source file.
5. Before any feed replacement, the generator verifies every archive against
   the configured public key, its HTTPS URL and exact size, and the signed feed
   with the same signing-key source. A warning-only signing failure cannot
   publish an unsigned or mismatched update. The workflow rejects draft,
   prerelease, non-latest, empty-notes and missing-archive releases. It rechecks
   the latest release, exact notes, archive identity and old feed after signing
   and again before promotion. If anything changed, finish curation and rerun.
6. Download the published feed and archive and test an old configured build
   updating to the new version before announcing automatic updates as available.

After editing published release notes, rerun **Publish curated update feed**
for the same latest stable tag. Do not rerun **Release** to refresh the appcast:
feed regeneration never rebuilds/recreates the release or tag. Old signed feed
bytes remain untouched until the new candidate has passed all checks. The
archive is published first, and `appcast.xml` is promoted last. A custom-domain
operator must mirror the exact signed bytes after publication, without editing
the XML. Automatic checks and automatic download/install remain separate;
automatic installation starts disabled.

## Feed publication recovery

Publication is serialized (`cancel-in-progress: false`). A uniquely named
`appcast-candidate-<id>.xml` is uploaded and downloaded again; its bytes must
exactly match the locally verified signed feed. The previous `appcast.xml`, if
present, is renamed to `appcast-previous-<id>.xml`, then the candidate is renamed
to `appcast.xml`. **This is not an atomic swap:** GitHub can briefly return no
feed between the two renames. A failed promotion attempts to restore the old
name; previous signed bytes and candidates are retained for recovery, never
deleted by this workflow. Neither historical assets nor tags are deleted.

If the job is interrupted during promotion, inspect the release assets first:

```sh
gh release view vX.Y.Z --repo OWNER/MacSai --json assets
```

Use the previous asset ID printed in the job log to restore its name if no
`appcast.xml` exists:

```sh
gh api --method PATCH repos/OWNER/MacSai/releases/assets/PREVIOUS_ASSET_ID \
  -f name=appcast.xml
```

If a candidate already has that name, first verify which signed bytes it holds.
Keep the previous backup until the new feed is confirmed. Do not blindly delete
assets or repeat a rename after an ambiguous API error. When notes/latest have
changed, rerun the publication workflow for the current latest stable release.

Prereleases do not replace the stable appcast. A preview channel needs its own
feed URL and explicit build configuration. A custom-domain feed must be mirrored
by its operator; this workflow only uploads GitHub release assets.

## Building and testing locally

`scripts/build-dmg.sh --app-only` packages both the main app and menu helper,
embeds Sparkle, and signs nested components inside out. `LOCAL_SIGNING_IDENTITY`
optionally selects a stable local signing certificate for a non-notarized test
build; absent this value, signing is ad hoc. A local certificate is not an Apple
Developer ID and does not make a build notarized or suitable for public release.
`--notarize` always uses `APPLE_DEVELOPER_ID` instead.

If a synced Documents folder continually adds FinderInfo metadata and breaks
codesigning, set `DMG_STAGING_ROOT=/private/tmp` to create a fresh staging
directory outside that folder. `.build/last-app-path` records the resulting
bundle path after `--app-only`. `SWIFT_BUILD_SYSTEM=native` is an optional
compatibility override for toolchains with resource-signing issues.

For a test feed, place the archive and matching-basename `.md` notes in a fresh
directory, then run:

```sh
SPARKLE_KEY_ACCOUNT=your-keychain-account \
SPARKLE_PUBLIC_ED_KEY=your-base64-public-key \
  bash scripts/generate-update-feed.sh path/to/archives https://your-host/path/
```

The script can alternatively read `SPARKLE_PRIVATE_KEY` from its environment for
CI. Do not modify the generated XML or notes after signing. Only publish a feed
after its referenced archive is available.

Required acceptance checks include old-to-new installation/relaunch, helper
relaunch, unchanged settings, active cleanup/maintenance/shred/restore finishing
before replacement, cancellation, skipped versions, automatic install on Quit,
offline/retry behavior, and rejection of tampered feed/archive signatures.

## File-operation and helper lifecycle

Outer cleanup, maintenance, shred and restore operations hold an
`AppOperationActivity` token. Preparing an update atomically closes the gate to
new operations, then waits asynchronously for existing tokens to finish. Do not
acquire a second token inside a token-holding operation: that can deadlock if an
update closes the gate between the two acquisitions. Aborting an update reopens
the gate and resumes queued operations. Acquiring an operation token is
cancellation-aware: a cancelled waiter throws `CancellationError`, leaves the
queue promptly, and never becomes an active operation later. Cancelling an
update wait releases only that request, keeping any other update's gate closed.
No timeout permits installation over active file operations.

Before replacement, Mac Sai suspends its menu-helper watchdog, requests the
helper to exit, and waits for its exit. A timed-out helper stop leaves the update
pending with a retry action; it never force-kills unrelated applications. Normal
Quit also prepares the helper when Sparkle has staged an install-on-quit update.
Skipping/cancelling clears that state. The newly launched app reuses the saved
menu preference and launches its newly embedded helper through the usual path.
Manual installation and ordinary Quit share one preparation owner. A duplicate
Quit cannot replace a manual installation's pending task; cancellation
invalidates the owner before waking suspended work, so stale helper completion
cannot invoke an old install handler. A cancelled pending Quit receives its
negative termination reply immediately.
