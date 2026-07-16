# Patch series vs upstream-v33.0.7

1. docs: fork marker (ASSTIO-FORK.md, branding/, PATCHES.md, RELEASING.md — additive, no upstream files)
2. branding: NEXTCLOUD.cmake — names/domain/vendor, server URL enforced to files.asstio.com,
   updater OFF (M1), brand color, fresh Windows GUIDs/UpgradeCode
3. branding: theme/colored — Asstio icon set + wizard logo (replaces upstream art like-for-like)
4. ci: .github/workflows — Asstio build workflows (upstream's PR workflows left untouched/disabled)

Rebase procedure: see RELEASING.md. Rule: no src/ patches without a documented reason here.

## Known gaps (tracked for Task 4/5, not fixed here)

`APPLICATION_ICON_NAME` = "Asstio" also changes the expected filenames for a few
platform-specific icon inputs that Task 3's brief did not include in scope:
- macOS sidebar icon: `theme/colored/${APPLICATION_ICON_NAME}-sidebar.svg` (only
  looked up `if(APPLE)`, src/gui/CMakeLists.txt:445) — currently only
  `Nextcloud-macOS-sidebar.svg` exists.
- Windows Start-menu tile: `theme/colored/${APPLICATION_ICON_NAME}-w10startmenu.svg`
  (only looked up `if(WIN32)`, src/gui/CMakeLists.txt:454) — currently only
  `Nextcloud-w10startmenu.svg` exists.
- Windows folder icon: `theme/colored/icons/${APPLICATION_ICON_NAME}-icon-win-folder.svg`
  (WIN32, src/gui/CMakeLists.txt:463) — currently only
  `Nextcloud-icon-win-folder.svg` exists.

None of these are reached by Task 3's configure-only sanity check (they're
generated inside `src/gui/CMakeLists.txt`, downstream of the Qt package lookup
that check intentionally fails on), but a *real* macOS or Windows build (Task 4/5)
will hit `generate_sized_png_from_svg` with a missing input file and hard-fail
with `FATAL_ERROR`. Task 4/5 must supply `Asstio-sidebar.svg`,
`Asstio-w10startmenu.svg`, and `theme/colored/icons/Asstio-icon-win-folder.svg`
(square-mark derivatives are fine) before those CI builds can go green.
