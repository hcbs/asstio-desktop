# Patch series vs upstream-v33.0.7

1. docs: fork marker (ASSTIO-FORK.md, branding/, PATCHES.md, RELEASING.md — additive, no upstream files)
2. branding: NEXTCLOUD.cmake — names/domain/vendor, server URL enforced to files.asstio.com,
   updater OFF (M1), brand color, fresh Windows GUIDs/UpgradeCode
3. branding: theme/colored — Asstio icon set + wizard logo (replaces upstream art like-for-like)
4. ci: .github/workflows — Asstio build workflows (upstream's PR workflows left untouched/disabled)

Rebase procedure: see RELEASING.md. Rule: no src/ patches without a documented reason here.

## Known gaps (tracked for Task 4/5, not fixed here)

_Resolved — see "Task 3 follow-up" below._ `APPLICATION_ICON_NAME` = "Asstio" also
changed the expected filenames for a few platform-specific icon inputs that Task
3's brief did not include in scope; all three now exist under their Asstio
names.

## Task 3 follow-up: platform-specific icon files added

Added the three `Asstio-*` platform icon inputs that
`APPLICATION_ICON_NAME` = "Asstio" now expects (previously only the old
`Nextcloud-*` names existed, which would have hard-failed a real macOS/Windows
build — see git history for the pre-fix text of this section):

- `theme/colored/Asstio-sidebar.svg` — macOS sidebar icon (`if(APPLE)`,
  src/gui/CMakeLists.txt:445). Built as a monochrome/template-style mark per
  `Nextcloud-macOS-sidebar.svg`'s convention (macOS re-tints template images at
  render time): the Asstio icon-mark path, scaled from its native 200x200
  viewBox into a 128x128 canvas, filled flat black.
- `theme/colored/Asstio-w10startmenu.svg` — Windows Start-menu tile
  (`if(WIN32)`, src/gui/CMakeLists.txt:454). Built per
  `Nextcloud-w10startmenu.svg`'s convention (full-color disc + white mark on
  top): solid brand-purple (`#6D3EFF`) circle background with the Asstio white
  mark (`branding/asstio-logo-white.svg`) composited on top, both sharing a
  0 0 200 200 viewBox.
- `theme/colored/icons/Asstio-icon-win-folder.svg` — Windows folder overlay
  (WIN32, src/gui/CMakeLists.txt:463; path confirmed via
  `APP_SECONDARY_ICONS = ${theme_dir}/colored/icons`). Upstream composites the
  Nextcloud round-logo badge onto Adobe-Illustrator-exported folder artwork
  inside group `g69`/`g925`; kept the folder artwork and the badge's
  position/size (circle r=79 at cx=283.08823, cy=126.10294, same outer
  transform matrix) verbatim, and only swapped the circle fill (gradient →
  flat `#6D3EFF`) and the mark inside it (Nextcloud path → Asstio white mark,
  fit into the same circle via `translate(cx-r, cy-r) scale(2r/200)`).

Verified: `rsvg-convert` renders all three to valid PNGs at build-relevant
sizes (128, 150, 256) with the expected composition (Asstio mark on the
sidebar/tile/folder-badge). The build renders PNGs from these SVGs at build
time via inkscape/rsvg-convert (`cmake/modules/GenerateIconsUtils.cmake`) —
no pre-rendered PNGs are required for these three inputs.

Grepped `APPLICATION_ICON_NAME` usage across `src/gui/CMakeLists.txt` and
`CMakeLists.txt` for other filename patterns derived from it — no further
gaps found. The remaining consumers (`VISUAL_ELEMENTS` install glob,
`MACOSX_BUNDLE_ICON_FILE`, the primary `Asstio-icon.svg`/PNGs, state icons)
were already covered by Task 3 or don't depend on new filenames.

## Task 5 follow-up: Windows VisualElements tile manifest added

The Task 3 sweep grepped only `APPLICATION_ICON_NAME`, but the Windows tile
manifest filename derives from `APPLICATION_EXECUTABLE` ("asstio"):
`src/gui/CMakeLists.txt:589` installs
`theme/${APPLICATION_EXECUTABLE}.VisualElementsManifest.xml`. Upstream ships
`theme/nextcloud.VisualElementsManifest.xml`, so the Windows `cmake_install`
step hard-failed (`file INSTALL cannot find "theme/asstio.VisualElementsManifest.xml"`).
macOS never references this file, so Task 4 didn't surface it.

Added `theme/asstio.VisualElementsManifest.xml` (+ `.license`), copied from the
upstream file with:
- Tile image references pointed at the PNGs that actually get installed to
  `bin/visualelements` — the build generates `70-Asstio-w10startmenu.png` and
  `150-Asstio-w10startmenu.png` from `Asstio-w10startmenu.svg`
  (`generate_sized_png_from_svg` → `${size}-${name}.png`, GLOB'd by
  `*-Asstio-w10startmenu*` at CMakeLists.txt:587). Upstream's manifest pointed
  at a static `Nextcloud-w10starttile.png` that the install glob does not
  actually ship; using the generated names makes the tile images resolve.
- `BackgroundColor="#6D3EFF"` (Asstio brand purple) for the Start-menu tile.
