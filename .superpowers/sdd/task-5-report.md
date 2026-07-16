# Task 5 report: Windows CI workflow (unsigned build + artifact)

Status: **DONE — workflow green, installer artifact verified (payload decompressed and inspected).** 2026-07-16.

Green run: https://github.com/hcbs/asstio-desktop/actions/runs/29521341213
Final commit: `5221fbf770`
Artifact: `Asstio-windows-x64` (143 MB) — NSIS installer
`nextcloud-client-latest-master-windows-cl-msvc2022-x86_64.exe`, unsigned,
14-day retention.

## What was built

- `.github/workflows/asstio-build-windows.yml` — self-contained workflow,
  mirroring the working `asstio-build-macos.yml` structure and adapting
  upstream's `windows-build-and-test.yml`:
  - Triggers: push to `main` + `workflow_dispatch`.
  - Runner `windows-2022`, Python 3.12, `CRAFT_TARGET=windows-msvc2022_64-cl`,
    craftmaster clone from invent.kde.org, both blueprint repos pinned
    `stable-33.0`, Craft cache (restore + save, key `hashFiles(craftmaster.ini)`),
    `--install-deps nextcloud-client`, compile with `--src-dir` at workspace,
    choco inkscape.
  - Dropped vs upstream: OpenCppCoverage, ctest, PR-comment steps.
  - Added: "Craft package (NSIS)" (`craft --package nextcloud-client`),
    a blueprint-patch step (see iteration log), defensive "Collect installer"
    (name contains `asstio` AND size > 50MB; nextcloud+>50MB fallback), and
    `upload-artifact@v4` `Asstio-windows-x64`, retention 14 days.
- Verified `windows-build-and-test.yml` already carries the
  `if: github.repository == 'nextcloud/desktop'` guard (added in Task 4) — no
  change needed.
- `theme/asstio.VisualElementsManifest.xml` (+ `.license`) — see iteration 1.

## CI iteration log

Run URLs under https://github.com/hcbs/asstio-desktop/actions/runs/<id>.

1. **Runs 29502115615 / 29502189355 — FAILED (install step)** — coordinator
   diagnosed: compile SUCCEEDS (~22 min); `src/gui/cmake_install.cmake:48`
   fails — `file INSTALL cannot find "theme/asstio.VisualElementsManifest.xml"`.
   The Windows tile manifest filename derives from `APPLICATION_EXECUTABLE`
   ("asstio"), and `src/gui/CMakeLists.txt:589` installs
   `theme/${APPLICATION_EXECUTABLE}.VisualElementsManifest.xml`; upstream ships
   `theme/nextcloud.VisualElementsManifest.xml`. macOS never references it, so
   Task 4 didn't surface it.
   - Fix (commit `5e98f46012`): added `theme/asstio.VisualElementsManifest.xml`
     (+ `.license`), pointing tile images at the PNGs actually installed to
     `bin/visualelements` (`150-Asstio-w10startmenu.png` / `70-...`, generated
     by `generate_sized_png_from_svg` and GLOB'd by `*-Asstio-w10startmenu*`),
     `BackgroundColor="#6D3EFF"`.
2. **Run 29516823885 — FAILED (Craft package step)** — install now passes
   (manifest fix good). `craft --package` crashes:
   `nextcloud-client.py:92 -> NameError: name 'os' is not defined`. The
   `stable-33.0` desktop-client-blueprints' `createPackage()` calls
   `os.path.join` without importing `os`; upstream's own Windows workflow only
   compiles+tests (never `--package`), so the bug is unfixed on that branch.
   The blueprint also hardcodes installer `appname`/`applicationExecutable`/
   `company` to Nextcloud values.
   - Fix (commit `58922d3199`): added a "Patch NSIS blueprint" workflow step
     that edits the CI-fetched blueprint copy (we can't touch the upstream
     repo) — inserts `import os`, and rebrands `appname`/`applicationExecutable`
     to `asstio` (must match `APPLICATION_EXECUTABLE`) and `company` to
     `Asstio`. Also broadened the collect fallback to asstio|nextcloud (>50MB).
3. **Run 29518707652 — "green" but artifact BROKEN (caught by inspection)** —
   package + collect + upload all succeeded, 139 MB artifact. But decompressing
   the NSIS payload (7z) showed the only `.exe` was `QtWebEngineProcess.exe` —
   NO main `asstio.exe`. Root cause: the blueprint's `blacklist.txt` has
   `bin/(?!(nextcloud|nextcloudcmd|QtWebEngineProcess)).*\.exe` — it strips every
   `bin/*.exe` whose name isn't in that whitelist. Our binary is `asstio.exe`,
   so the app (and `asstiocmd.exe`) were silently stripped; the installer had
   all DLLs but nothing launchable. A plain `strings | grep asstio` on the raw
   installer finds nothing either way (NSIS solid-LZMA compresses the payload),
   so the only real check is decompress-and-list.
   - Fix (commit `5221fbf770`): extended the blueprint-patch step to also
     rewrite `blacklist.txt`'s whitelist to `asstio|asstiocmd|QtWebEngineProcess`.
4. **Run 29521341213 — GREEN, artifact verified** —
   https://github.com/hcbs/asstio-desktop/actions/runs/29521341213
   - ~28 min warm cache.

## Verification (done — no Windows box, so payload inspected on this Mac)

- Workflow green; artifact `Asstio-windows-x64` (143 MB) present.
- `gh run download` → NSIS installer is a nested 7z; extracted the inner
  payload with `7zz` (Homebrew `sevenzip`) and confirmed:
  - `bin/asstio.exe` (9.4 MB) present + `bin/asstiocmd.exe` + QtWebEngineProcess.
  - `asstio.exe` carries "Asstio" (14× UTF-16LE) and zero "Nextcloud" strings.
  - `asstiosync.dll` has the enforced `https://files.asstio.com`.
  - `bin/asstio.VisualElementsManifest.xml` + `visualelements/{70,150}-Asstio-w10startmenu.png`.
  - No `nextcloud`-named payload files.
- NOTE: raw `strings ... | grep -i asstio` returns nothing (NSIS solid-LZMA
  compression) — that brief-suggested check is not valid for NSIS; decompress
  the payload instead.
- Real install = Task 7 dogfood on a team Windows machine.

## Notes / concerns

- The blueprint patch lives entirely in `.github/workflows/` (patches
  runtime-fetched third-party files, not our `src/`), so patch discipline holds.
  Recorded in PATCHES.md.
- Installer filename is `nextcloud-client-...-x86_64.exe` (derived from the
  craft package name, not `appname`) — acceptable for M1 per plan; internals
  are fully Asstio. M2's installer task owns naming. The collect step's
  asstio-name+>50MB primary match therefore falls through to the
  asstio|nextcloud+>50MB fallback (working as designed).
- Warm-cache runs ~28-30 min; the collect step's >50MB guard was load-bearing —
  the payload tree contains dozens of sub-1MB helper `.exe`s (pip/setuptools).
