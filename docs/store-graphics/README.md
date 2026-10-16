# Sushi Trio — Header, Search Results and Feature Graphic

English creative assets, prepared 2026-10-16.

| File in `en-US/` | Placement | Size |
| --- | --- | --- |
| `app-store-header.png` | App Store Connect → Header and Search Results → Header | 3840 × 1646 |
| `app-store-search-results.png` | App Store Connect → Header and Search Results → Search Results | 3840 × 2560 |
| `google-play-feature-graphic.png` | Google Play Console → Store listing → Feature graphic | 1024 × 500 |

The final files are opaque, 24-bit RGB PNGs in sRGB. `sushi-trio-store-graphics-en-US.zip` contains only these three upload files. `overview.png` is a review sheet, not an upload asset. No files have been uploaded to either store.

Dimensions and alpha requirements were verified against [Apple's creative asset specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/creative-assets-specifications) and [Google Play's preview asset requirements](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en). The composition follows [Apple's asset best practices](https://developer.apple.com/app-store/asset-best-practices/): a clear focal point, short readable copy, and central placement of key content. Store previews should still be checked for placement-specific cropping before publication.

## Artwork

The teal, cream, orange and gold palette continues the existing icon and screenshot campaign. The illustration focuses on matching sushi tiles. Restaurant management is not promoted.

The original key art was illustrative marketing art generated with the built-in imagegen tool, using the existing sushi icon artwork, harbor background and a real level 9 capture as references. The source PNG was deleted after export at the user's request. Final images, previews and ZIP files are retained. The exact generation prompt is saved in `sources/prompt.md`.

The Search Results file includes an unretouched, proportionally scaled real gameplay capture from the Android emulator. The raw file was deleted after export. The illustrated background is subdued in that placement to emphasize the actual game. No phone hardware is depicted. English titles use the project's Mali font; they are typeset separately so spelling and sizing remain deterministic.

## Regenerate exports (requires source images)

The source key-art PNG and raw screenshots were deleted. Restore or recreate those inputs at the paths used by the renderer before rebuilding. Run `node tool/render_store_graphics.cjs` with `playwright` and `sharp` available through Node resolution or `NODE_PATH`. Chrome uses the standard Windows installation path unless `CHROME_PATH` is set.

The renderer waits for fonts and images, checks layout bounds, and validates the exact dimensions, RGB channels and absence of alpha in each export. Repackage `en-US/*.png` after changes.

## Suggested alt text

- Header: Sushi Trio artwork with colorful sushi tiles and a glowing match of three salmon pieces against a Japanese harbor backdrop.
- Search Results: Sushi Trio, a sushi match-3 puzzle game, with a real gameplay board and 205 levels across 14 destinations.
- Feature graphic: Colorful sushi tiles form a glowing match beside the Sushi Trio title on a deep teal Japanese wave background.
