# Dogfooding Asstio Desktop (M1)

M1 builds are **unsigned**. This is expected — signing is an M2 item (see
`RELEASING.md`). That means both OSes will complain on first run; the bypass
steps below are normal, not a sign of a broken build.

## Where artifacts live

Every push to `main` (and manual dispatch) builds both platforms via GitHub
Actions:
- macOS: `.github/workflows/asstio-build-macos.yml` → artifact
  `Asstio-macos-arm64`
- Windows: `.github/workflows/asstio-build-windows.yml` → artifact
  `Asstio-windows-x64`

Artifacts are attached to the workflow run page and kept for 14 days:
https://github.com/hcbs/asstio-desktop/actions

To grab the latest without a browser:
```bash
# macOS
gh run download --repo hcbs/asstio-desktop -n Asstio-macos-arm64 -D ~/Downloads/asstio-macos

# Windows
gh run download --repo hcbs/asstio-desktop -n Asstio-windows-x64 -D ~/Downloads/asstio-windows
```
If you don't pass `-n`, `gh run download` will download the artifacts of the
most recent completed run.

## Install — macOS

1. Download and unzip the `Asstio-macos-arm64` artifact — you get `Asstio.app`.
2. Gatekeeper will refuse to open it (unsigned, unnotarized). Bypass the
   quarantine flag before first launch:
   ```bash
   xattr -dr com.apple.quarantine /path/to/Asstio.app
   ```
   (Do this once per download — a fresh download from Actions carries a fresh
   quarantine flag.)
3. `open /path/to/Asstio.app`. You should see the Asstio icon, name, and
   wizard branding — not Nextcloud's.

## Install — Windows

1. Download the `Asstio-windows-x64` artifact and run the `.exe` installer.
   (Note: the installer's **filename** is still `nextcloud-client-*.exe` —
   that's an upstream packaging default M2 will fix; the app inside is fully
   Asstio-branded.)
2. Windows SmartScreen will block the unsigned installer with "Windows
   protected your PC". Bypass:
   - Click **More info**
   - Click **Run anyway**
3. Proceed through the installer normally.

## Daily dogfood checklist

- Launch the app; confirm it starts and shows the account wizard (or your
  existing account, once set up).
- Exercise sync: add/edit/delete a file locally and on
  `https://files.asstio.com`; confirm both directions propagate within a
  reasonable time.
- Watch for crashes, hangs, or sync errors in the tray/menu-bar icon.
- Note anything that still looks or reads like "Nextcloud" instead of
  "Asstio" (window titles, tray tooltip, About dialog, error dialogs, etc.) —
  these are branding gaps worth filing even if cosmetic.

## Filing issues

File anything you hit — crashes, sync bugs, branding leaks, confusing
UX — as an issue in this repo:
https://github.com/hcbs/asstio-desktop/issues

Include: OS + version, which artifact/run you used (run ID or artifact
download date), and repro steps.

## M1 known limits

- **Unsigned.** Both platforms require the bypass steps above every time you
  install a fresh download. This is intentional for M1 — see `RELEASING.md`
  for the M2 signing plan.
- **No auto-update.** `BUILD_UPDATER` is off in M1 — there is no update
  check or self-update. To pick up a new build, download the latest artifact
  and reinstall (macOS: replace `Asstio.app`; Windows: rerun the installer).
- **Installer filename is cosmetic-wrong.** The Windows installer is still
  named `nextcloud-client-*.exe` even though the app inside (`asstio.exe`,
  icons, tile manifest, wizard) is fully Asstio-branded. M2's installer task
  owns fixing the filename.
- **Windows is CI-verified only, not yet run on real hardware.** There is no
  team Windows machine available during M1 build-out. Verification so far is:
  workflow green, installer present and correctly sized, and the NSIS payload
  decompressed and inspected to confirm `asstio.exe` (not just DLLs) is
  actually inside. A real install/sync smoke test on physical Windows
  hardware is still outstanding.
- **How the Windows verification was actually done (worth knowing before you
  "just check with `strings`"):** NSIS installers are LZMA-solid-compressed,
  so `strings installer.exe | grep asstio` finds nothing even on a correctly
  branded installer — it's not a signal of anything. The only way to confirm
  what's really inside is to decompress the payload (e.g. `7z x` /
  `7zz x installer.exe`) and inspect the extracted files directly. This is
  also how a real bug was caught during Task 5: a blueprint blacklist was
  silently stripping `asstio.exe` from an otherwise "green" build, leaving an
  installer full of DLLs but nothing launchable — `strings` alone would never
  have shown that.

## First dogfood run (Henrik)

This is the one step deliberately left undone by automation — it mints a
real device/app-password credential on your `files.asstio.com` account, so
it's yours to run and approve.

1. Install the macOS build (steps above) and launch it.
2. Go through the connect flow: it should open your system browser at the
   consent/login page for `https://files.asstio.com` with **no server-URL
   field shown** (the server is baked in and enforced). Log in and approve
   the request; name the device something identifiable, e.g. `M1 dogfood`.
3. Selective sync screen: confirm **nothing is preselected**. Pick one small
   folder to sync (don't sync everything on the first run).
4. Two-way smoke test:
   - Add a file locally → confirm it appears on the web UI.
   - Upload a file via the web UI → confirm it lands locally.
   - Rename a file locally → confirm the rename propagates.
   - Delete a file locally → confirm it lands in trash (not permanently
     deleted) on the server.
5. Confirm branding end-to-end: menu-bar/tray icon, app name in Finder and
   the menu bar, the wizard screens, and the About dialog all say "Asstio",
   not "Nextcloud".
6. Record each of the above as PASS/FAIL with notes (a comment on the M1
   plan or a note back to the team is fine — doesn't need to be fancy).
7. Optional cleanup: if you'd rather not leave the app password live,
   revoke it afterwards:
   ```bash
   # list first to get the id
   GET  https://files.asstio.com/ocs/v2.php/apps/dav/api/v1/app-passwords
   DELETE https://files.asstio.com/ocs/v2.php/apps/dav/api/v1/app-passwords/{id}
   ```
   (adjust the path to whatever the backend's actual app-password endpoint is
   — see `docs/dav-desktop-sync.md` in `asstio-order-backend`.)

If anything looks wrong at any step, stop and file an issue (see above)
rather than pushing through — this run is meant to catch exactly that kind
of thing before a wider team rollout.
