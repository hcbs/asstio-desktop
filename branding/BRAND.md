# Asstio brand values used by this fork

All values below were extracted from `asstio-order-web` (checked out at
`/Users/henrikvonheland/code/asstio-order-web`) on 2026-07-16. No color or
artwork here is invented — every entry cites its exact source.

## Primary color

- **Primary: `#6D3EFF`**
  - `projects/asstio-order-web/src/styles.scss:188` — `--primary: #6D3EFF;` (light theme root custom property)
  - `projects/asstio-order-web/src/index.html:12` — `<meta name="theme-color" content="#6D3EFF" media="(prefers-color-scheme: light)">`
  - Also used as the literal icon fill in the app's own sidebar logo: `projects/asstio-order-web/src/app/layout/sidebar-nav/sidebar-nav.html:6` (`fill="#6D3EFF"`)
  - This is the color used for `NEXTCLOUD_BACKGROUND_COLOR` in `NEXTCLOUD.cmake` (Task 3).

- Dark-theme companion (not used as the primary brand color, recorded for completeness): `#1a1430` — `projects/asstio-order-web/src/index.html:13` (`theme-color` for `prefers-color-scheme: dark`).

- Not used: `#415F91` at `projects/asstio-order-web/src/index.html:31` (`msapplication-TileColor`) — this looks like a stale/unrelated Windows-tile value inconsistent with the rest of the theme (doesn't match `--primary` in any theme variant in `styles.scss`); ignored in favor of the consistently-used `#6D3EFF`.

## Icon master (square mark)

- **`branding/asstio-logo.svg`** (staged in this repo)
  - Shape source: `projects/asstio-order-web/public/icons/asstio-icon-black.svg` — single path (`id="path33628"`), `viewBox="0 0 200 200"`, already square.
  - Fill color source: `projects/asstio-order-web/src/app/layout/sidebar-nav/sidebar-nav.html:6` — the identical path data used inline with `fill="#6D3EFF"` as the in-app sidebar logo icon. Confirmed byte-for-byte identical `d=` attribute between the two files.
  - A white variant also exists at `projects/asstio-order-web/public/icons/asstio-icon-white.svg` (different path data, same silhouette, `fill="#ffffff"`) — not staged; only one master mark is needed per Task 2's brief, and the brand-purple-on-transparent version is the more broadly reusable one (renders correctly on both light and dark chrome backgrounds since NEXTCLOUD's `theme.qrc.in` composites square PNGs, not swap-by-media-query SVGs).

## Wordmark / wizard logo

- **No dedicated wordmark SVG/PNG asset exists anywhere in `asstio-order-web`.** Searched `public/`, `src/assets` (does not exist), all `*.svg` files repo-wide (excluding `node_modules`/`dist`), and all logo/wordmark references in `.ts`/`.html` files.
- The app's own header (`sidebar-nav.html:4-11`) composes its "wordmark" live from the square icon mark (above) plus two `<span>` elements of styled text (`{{ companyName() }}` + `Order`) — it is not a static image asset, so it cannot be extracted as one.
- **Decision (per Task 2 brief's fallback guidance):** since no separate wordmark image exists to use for the wizard logo, `branding/asstio-logo.svg` (the square brand-purple mark) is reused as-is for both the app icon *and* the wizard logo in Task 3. This is the inverse of the brief's anticipated fallback case (brief anticipated "wordmark exists, no square mark → derive a square mark"; here the actual situation is "square mark exists, no wordmark → reuse the square mark for both slots"). No letter-mark derivation was needed since a square mark already exists natively.
