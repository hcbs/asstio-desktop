# Task 3 report: Branding patch — NEXTCLOUD.cmake + theme assets

## Status: DONE, pushed to origin/main

## Commits

- `3d77cb6e4f` — branding: Asstio identity, enforced server URL, updater off, fresh win GUIDs
  (NEXTCLOUD.cmake, PATCHES.md, branding/asstio-logo-white.svg, branding/BRAND.md correction)
- `4643fd1f04` — branding: Asstio icon set and wizard logo
  (theme/colored/Asstio-icon.svg + 9 PNG sizes, wizard_logo.svg/.png/@2x.png)

Pushed: `origin/main` now at `4643fd1f04` (was `c472190f4e` before this task).

## What was done

**NEXTCLOUD.cmake** — edited exactly per the brief:
- `APPLICATION_NAME/SHORTNAME` = "Asstio", `APPLICATION_EXECUTABLE` = "asstio"
- `APPLICATION_DOMAIN` = "asstio.com", `APPLICATION_VENDOR` = "Asstio"
- `APPLICATION_REV_DOMAIN` = "com.asstio.desktopclient"
- `APPLICATION_ICON_NAME` = "Asstio" (unconditional, common section)
- `APPLICATION_UPDATE_URL` = "" (no feed yet), `APPLICATION_VIRTUALFILE_SUFFIX` = "asstio"
- `APPLICATION_SERVER_URL` = "https://files.asstio.com", `APPLICATION_SERVER_URL_ENFORCE ON`
- Removed the `Nextcloud-macOS-icon.svg` conditional (dead for us — only ever
  matched `APPLICATION_NAME STREQUAL "Nextcloud"`)
- `BUILD_UPDATER` OFF
- `NEXTCLOUD_BACKGROUND_COLOR` = `#6D3EFF` (brand primary, per branding/BRAND.md)
- All `WIN_SHELLEXT_*_GUID` + `WIN_MSI_UPGRADE_CODE` regenerated with fresh `uuidgen`
  output, matching upstream's exact format (braced uppercase for the shellext GUIDs,
  unbraced for the MSI upgrade code)
- `DEVELOPMENT_TEAM` and `THEME_CLASS` left untouched per brief

**theme/colored/** — replaced like-for-like:
- `Asstio-icon.svg` (new) — brand-purple square mark, copied from `branding/asstio-logo.svg`
- `16/24/32/48/64/128/256/512/1024-Asstio-icon.png` (new) — rendered via `rsvg-convert`
  (installed librsvg via brew; not previously present on this machine)
- `wizard_logo.svg` / `wizard_logo.png` (100x100) / `wizard_logo@2x.png` (200x200) —
  overwritten with the **white** mark per the Task 2 review correction

**branding/** additions (bundled into the cmake commit, as instructed):
- `branding/asstio-logo-white.svg` — copied verbatim from
  `asstio-order-web/projects/asstio-order-web/public/icons/asstio-icon-white.svg`
- `branding/BRAND.md` updated with a "Correction (Task 3 review)" section citing the
  source and explaining why the wizard logo needed the white variant (wizard header
  background defaults to `NEXTCLOUD_BACKGROUND_COLOR` = brand purple; a purple mark on
  a purple header would be invisible)

**PATCHES.md** (new) — the standard patch-series doc from the brief, plus a
"Known gaps" section (see Concerns below).

## Sanity check result

**PASS** — `cmake -S . -B /tmp/asstio-configure-test -DCMAKE_PREFIX_PATH=/dev/null`
processes `NEXTCLOUD.cmake` (included at `CMakeLists.txt:31`) with zero errors, then
fails at `CMakeLists.txt:87` (`find_package(ECM 6.0.0 REQUIRED)` — missing dependency,
expected/desired since no Craft/Qt/ECM environment exists on this machine yet). No
error originated inside `NEXTCLOUD.cmake`. (Also had to `brew install cmake` — it
wasn't present on this machine either.)

## Concerns / follow-ups for Task 4 & 5

Not fixed here (out of Task 3's stated file scope), but flagged in `PATCHES.md`
"Known gaps" section: setting `APPLICATION_ICON_NAME=Asstio` also changes the
expected filenames for three platform-specific icon inputs that still only exist
under their old `Nextcloud-*` names:

- macOS sidebar icon: `theme/colored/Asstio-sidebar.svg` (only `Nextcloud-macOS-sidebar.svg` exists)
- Windows Start-menu tile: `theme/colored/Asstio-w10startmenu.svg` (only `Nextcloud-w10startmenu.svg` exists)
- Windows folder icon: `theme/colored/icons/Asstio-icon-win-folder.svg` (only `Nextcloud-icon-win-folder.svg` exists)

These aren't reached by the configure-only sanity check (they're generated inside
`src/gui/CMakeLists.txt`, downstream of the Qt/ECM lookup this check intentionally
fails on), but a real macOS build (Task 4, `if(APPLE)`) or Windows build (Task 5,
`if(WIN32)`) will hit `generate_sized_png_from_svg` with a missing input SVG and
hard-fail with `CMake FATAL_ERROR`. Task 4/5 should add square-mark derivatives for
these three files before the CI builds can go green.

Also left untouched (deliberately, to keep the diff minimal): the old
`theme/colored/Nextcloud-icon.svg` and `Nextcloud-icon-square.svg` files are now
unreferenced (glob is `*-Asstio-icon*`, doesn't match them) but weren't deleted —
they're harmless dead weight, not a build risk, and deleting them isn't in Task 3's
file list. `REUSE.toml`'s license-attribution list still references them (and the
now-changed `wizard_logo.*` content) — a REUSE-lint follow-up, not a build blocker.

## Follow-up (2026-07-16): platform-specific icon gaps closed

Status: DONE, committed and pushed to origin/main.

Added the three missing `Asstio-*` icon inputs flagged above, so Task 4/5's
macOS/Windows builds won't hard-fail on a missing SVG:

1. `theme/colored/Asstio-sidebar.svg` — read `Nextcloud-macOS-sidebar.svg`
   (viewBox 0 0 128 128, flat black fill/stroke, no color — a macOS
   NSImage-template convention: the OS re-tints template images to match
   sidebar selection state). Built the Asstio equivalent the same way: the
   Asstio icon-mark path (from `branding/asstio-logo.svg`, native viewBox
   0 0 200 200) scaled by 0.64 (128/200) into the 128x128 canvas, filled flat
   `#000000`.

2. `theme/colored/Asstio-w10startmenu.svg` — read `Nextcloud-w10startmenu.svg`
   (viewBox ~0 0 150 150, full color: a gradient disc background with the
   white Nextcloud mark composited on top, occupying most of the disc). Built
   the Asstio equivalent as a solid brand-purple (`#6D3EFF`, matching
   `NEXTCLOUD_BACKGROUND_COLOR`/wizard-header background from Task 3) circle
   filling a 0 0 200 200 viewBox, with the Asstio **white** mark
   (`branding/asstio-logo-white.svg`'s path, reused verbatim since both share
   the 200x200 coordinate space) on top — no scaling/repositioning needed.

3. `theme/colored/icons/Asstio-icon-win-folder.svg` — confirmed the exact
   expected path via `src/gui/CMakeLists.txt:462-463`
   (`APP_SECONDARY_ICONS = ${theme_dir}/colored/icons`,
   `APP_ICON_WIN_FOLDER_SVG = ${APP_SECONDARY_ICONS}/${APPLICATION_ICON_NAME}-icon-win-folder.svg`).
   Read `Nextcloud-icon-win-folder.svg`: an Adobe-Illustrator-exported Windows
   folder illustration with the Nextcloud round-logo badge (circle + mark,
   group `g925` inside `g69`) composited in the top-right corner via an
   already-flattened absolute-coordinate transform (circle r=79 centered at
   cx=283.08823, cy=126.10294, under an outer
   `matrix(0.81518987,0,0,0.81518987,-44.170655,200.60216)` then
   `translate(0,-100)`). Copied the file byte-for-byte and replaced only the
   `g925` contents: circle fill (gradient → flat `#6D3EFF`) and the mark
   (Nextcloud path → the Asstio white mark's path data, wrapped in a
   `translate(204.08823,47.10294) scale(0.79)` group so its native 0 0 200 200
   viewBox maps exactly onto the existing circle: translate by
   `(cx-r, cy-r)`, scale by `2r/200`). Folder artwork, defs, clipPath, and
   outer transforms are untouched.

Grepped for other `APPLICATION_ICON_NAME`-derived filename patterns:
`grep -rn "APPLICATION_ICON_NAME" --include="*.cmake" --include="CMakeLists.txt" src/ CMakeLists.txt cmake/ admin/`
plus all `generate_sized_png_from_svg` call sites in
`src/gui/CMakeLists.txt`. No further gaps: the remaining consumers
(`VISUAL_ELEMENTS` install glob at line 587, `MACOSX_BUNDLE_ICON_FILE` at line
600, the primary `Asstio-icon.svg`/PNGs, and the `STATE_ICONS_COLORS` loop)
either reuse filenames already produced by the three inputs above, are outputs
(not additional inputs), or don't key off `APPLICATION_ICON_NAME` at all
(state icons glob on `state-*.svg` regardless of icon name).

Verification: `rsvg-convert` (already installed from Task 3) rendered all
three new SVGs to valid PNGs at representative build sizes (128/150/256) with
the expected visual composition confirmed by inspection — solid black "a"
mark on sidebar, white mark on purple disc for the Start-menu tile, purple
badge with white mark on the folder artwork's bottom-right corner. No
pre-rendered PNGs were added: `cmake/modules/GenerateIconsUtils.cmake` renders
PNGs from SVG at build time via `inkscape`/`rsvg-convert`
(`generate_sized_png_from_svg`), so these SVG inputs are sufficient.

`PATCHES.md`'s "Known gaps" section updated to mark the gap resolved and
document the new "Task 3 follow-up" entries with file paths and design
rationale.

No src/ files were touched (icon-file-only change), consistent with
PATCHES.md's "no src/ patches without a documented reason" rule.
