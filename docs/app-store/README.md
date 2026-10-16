# Sushi Trio — English store screenshots

Additional Header, Search Results, and Google Play Feature Graphic assets are in [store-graphics](../store-graphics/README.md).

Captured and exported on 2026-10-16. Locale: English (en-US).

The Home screen replaces Restaurant promotion in the active screenshot set. The app feature is unchanged. Raw captures were deleted after export at the user's request; final images, previews and ZIP files are retained.

## Deliverables

- `en-US/iphone-6.9/`: 5 portrait PNGs, **1320 × 2868**.
- `en-US/ipad-13/`: 5 portrait PNGs, **2048 × 2732**.
- `sushi-trio-app-store-en-US.zip`: the 10 final PNGs, grouped by device.
- `en-US/iphone-6.9-overview.png` and `en-US/ipad-13-overview.png`: review sheets; do not upload these as store screenshots.
- `en-US/index.html`: local review gallery.

Upload the individual PNGs in filename order, 01–05, into the matching English iPhone and iPad screenshot slots. These export sizes are listed in [Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) for iPhone with Dynamic Island (large display) and iPad 13-inch. Dimensions were checked against that page on the export date.

## Source and scope

The source is the actual Flutter app running on **Android emulator Pixel_10_Pro / emulator-5554**, on Windows. These are **Android-sourced store artwork drafts**, not captures from an iOS simulator or an iPhone/iPad. Validate against the submitted iOS build before submission, including iOS safe areas and layout. No iOS build was run in this environment, and nothing was uploaded to App Store Connect.

The phone source viewport was 1260 × 2736 at density 480; the tablet source viewport was 2048 × 2732 at density 320. The tablet screenshots were captured separately at the tablet layout, rather than stretching phone captures. The final phone layouts use 1320 × 2868 canvases. Both sets preserve screenshot aspect ratio.

The HTML/CSS layout adds English headlines, a cream/teal/red palette, and existing sushi sprites around the captured app screens. It does not redraw the board, replace UI labels, or alter in-game values in the images. No device hardware or OS chrome is fabricated.

The capture-only entry point `tool/store_capture.dart` uses the production widgets and engine with an in-memory progressed example save: 205 levels cleared, earned stars, purchased furniture, sushi stock, boosters, and weekly-event progress. Its state never opens or writes the player's Hive save. Level 9 was photographed after a real swap. Level 205 shows the initial advanced board. The Home screen was captured separately from the normal app with its existing emulator save (Salmon Week); the rewards screenshot shows Maguro Week from the capture session. The emulator was returned to its normal viewport and the normal `lib/main.dart` build after capture.

## Screens and order

| File | Content | Headline |
| --- | --- | --- |
| 01-match.png | Level 9 gameplay | Match three. Serve happy! |
| 02-map.png | Nara/Kobe level map | 205 tasty levels. One big adventure. |
| 03-home.png | Home menu | Your next match starts here. |
| 04-challenges.png | Level 205 obstacles | A fresh twist in every puzzle. |
| 05-events.png | Weekly-event rewards | Play. Collect. Come back for more. |

## Recreate (requires new captures)

Raw images are no longer included. Capture new source images before running the renderer.

1. Run `flutter run -t tool/store_capture.dart --dart-define=DETERMINISTIC_SEED=true` on an Android emulator. The menu opens the real product screens for photography. This entry point is for local capture only; release with the normal `lib/main.dart` entry point.
2. Use `adb shell wm size 1260x2736` and `adb shell wm density 480` for phone captures. Use `2048x2732` and density `320` for tablet captures. Allow layout and intro animations to settle before capturing.
3. Capture with `adb shell screencap -p /sdcard/sushi-capture.png`, then `adb pull` into the corresponding `en-US/raw/<device>/` folder. Keep the five filenames above.
4. Run `node tool/render_store_screenshots.cjs` with `playwright` and `sharp` available through `NODE_PATH` or local Node resolution. Chrome defaults to its standard Windows install path; override with `CHROME_PATH` if needed. The renderer checks image loading, font loading, layout bounds, final dimensions and opaque PNG output.
5. Run `adb shell wm size reset` and `adb shell wm density reset`, then reinstall/run the normal app. Repackage the two final PNG folders if captures are updated.

Validation: capture build and normal Android debug build compiled; all ten final exports passed dimension, opacity and layout-bound checks; both overview sheets were visually reviewed. This asset task does not change game rules.

Static analysis of the capture utility could not finish because this machine's Dart Analysis Server failed during shutdown while deleting its `AppData/Local/Dart/perf` file (OS error 1920). Both Android builds completed successfully.
