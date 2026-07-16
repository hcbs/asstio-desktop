# Releasing Asstio Desktop

## Branch model
- `main` = upstream tag + Asstio patch series (see `PATCHES.md`)
- `upstream-vX.Y.Z` tags = pristine upstream release snapshots, unmodified
- Remotes: `origin` = `hcbs/asstio-desktop` (this fork), `upstream` =
  `nextcloud/desktop`

## Taking an upstream release (e.g. v33.0.8)

1. Fetch and tag the new upstream release:
   ```bash
   git fetch upstream tag v33.0.8 --no-tags
   git tag upstream-v33.0.8 v33.0.8
   git push origin upstream-v33.0.8
   ```
2. Start a rebase branch from the new tag:
   ```bash
   git checkout -B rebase-v33.0.8 v33.0.8
   ```
3. Cherry-pick the Asstio patch series on top, oldest first. List the series
   against the *previous* upstream base first (see `PATCHES.md` for the
   canonical numbered list of what belongs in the series):
   ```bash
   git log upstream-v33.0.7..main --oneline
   ```
   Cherry-pick each commit from that list, oldest to newest, onto
   `rebase-v33.0.8`.
4. Resolve conflicts patch-by-patch. Patch discipline is: branding lives ONLY
   in `NEXTCLOUD.cmake`, `theme/`, and `.github/workflows/` (see `PATCHES.md`).
   If a conflict in `NEXTCLOUD.cmake` or `theme/` is non-trivial (i.e. upstream
   restructured how branding vars or icon files work, not just a line moving),
   **STOP** and review upstream's change before resolving — don't blindly take
   "ours" or "theirs".
5. Get CI green on both workflows (`asstio-build-macos.yml`,
   `asstio-build-windows.yml`) on `rebase-v33.0.8` before merging:
   ```bash
   gh workflow run asstio-build-macos.yml --repo hcbs/asstio-desktop --ref rebase-v33.0.8
   gh workflow run asstio-build-windows.yml --repo hcbs/asstio-desktop --ref rebase-v33.0.8
   ```
6. Fast-forward `main` to the rebased branch and delete it:
   ```bash
   git checkout main
   git merge --ff-only rebase-v33.0.8
   git push origin main
   git branch -d rebase-v33.0.8
   ```
7. Record the new base in `PATCHES.md` (bump the "vs upstream-vX.Y.Z" header)
   and in `ASSTIO-FORK.md` (bump the "Base: upstream tag" line).

Branch protection on `main` blocks force-pushes and deletions (see below), so
the rebase always lands via a fast-forward merge from a disposable branch —
never a forced rewrite of `main` itself.

## M1 builds (unsigned)

- Every push to `main` builds both platforms via `asstio-build-macos.yml` and
  `asstio-build-windows.yml`. Artifacts (`Asstio-macos-arm64`,
  `Asstio-windows-x64`) are attached to the workflow run page, retained 14
  days.
- Manual dispatch (no push needed):
  ```bash
  gh workflow run asstio-build-macos.yml --repo hcbs/asstio-desktop
  gh workflow run asstio-build-windows.yml --repo hcbs/asstio-desktop
  ```
- **Nothing is signed.** macOS builds are Gatekeeper-quarantined and Windows
  installers trip SmartScreen — this is expected for M1. See `DOGFOOD.md` for
  the bypass steps dogfooders need, and for daily install/test instructions.

## M2 (signed releases, update feed): not yet

Code signing (Apple Developer ID + Windows Authenticode), a proper installer
(NSIS installer currently still carries the upstream `nextcloud-client-*.exe`
filename internally, cosmetic only), and a real update feed
(`BUILD_UPDATER`/`APPLICATION_UPDATE_URL`, currently off/placeholder) are all
out of scope for M1. See the Phase 2 design spec in `asstio-order-backend`
(`docs/superpowers/specs/2026-07-16-asstio-desktop-client-phase2-design.md`)
for what M2 covers.
