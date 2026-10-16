# Image generation prompt

Tool: built-in imagegen. Intent: ads-marketing, using existing artwork as references.

References, in order:
1. `assets/icons/app_no_bg.png`
2. `assets/backgrounds/bg.webp`
3. `docs/app-store/en-US/raw/iphone-6.9/01-match.png`

Use case: ads-marketing. Create premium landscape marketing key art for Sushi Trio, a cheerful Japanese sushi match-3 mobile game. Inputs: image 1 is the brand's sushi illustration style (salmon nigiri, tamago, cucumber maki); image 2 is the game's Japanese harbor environment; image 3 is real gameplay reference for the tile board. Produce ONE wide landscape 16:9 illustration, ideally 3840x2160. Composition for later wide banner crops: Keep every important subject inside the central 55 percent of image HEIGHT, centered at y=50%. Left 44 percent of image should be calm deep teal #123F45, faint traditional wave pattern, empty negative space for typography added later; NO text in image. On right half, an energetic floating small 4x4 wooden match-3 tile board, angled very slightly, with clearly separated cream wooden square tiles and the exact familiar salmon, tamago, maguro, cucumber maki and ikura sushi shapes from the references. Show a horizontal match of three salmon tiles with a tasteful golden connecting glow and a few tiny sparkles, conveying match-3 gameplay. This is illustrative marketing key art, not a fake phone screenshot. Broad warm cream swash behind the board, restrained distant Japanese harbor roofs and Mount Fuji as subtle background details near far right only. Hand-painted game sprite aesthetic, dark warm brown outlines, soft textures, saturated orange/yellow/green sushi, refined composition, crisp premium casual game finish. Keep the whole board and glints safely inset from outer edges; no sushi tower identical to app icon. No restaurant management, no characters, no chef, no furniture, no phone hardware, no UI controls, no words, letters, numbers, logos, badges, watermarks or CTA. Full opaque background.

Final layouts: `tool/render_store_graphics.cjs` adds the English brand title “Sushi Trio”, the label “SUSHI MATCH-3”, and the tagline “Match three, serve happy!” to the header and feature graphic. Search Results uses “Match three. Serve happy!” and “205 levels · 14 destinations”, with the real gameplay screenshot alongside.
