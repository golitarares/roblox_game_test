# Generator sprite navă (2D, 16 direcții)

Construiește o navă pirat 3D în three.js și o „fotografiază” din 16 direcții,
cu camera la 55° deasupra apei. Rezultatul: `docs/nava_sprites.png`
(1024×1024, 4×4 cadre de 256×256, fundal transparent, umbra inclusă).

Cadrul `i` (0–15, de la stânga-sus, pe rânduri) = prora navei rotită cu
`i × 22.5°` în sensul acelor de ceasornic față de „sus pe ecran”.

Regenerare (Node.js + Playwright):
```
npm install three@0.160.0 playwright
npx playwright install chromium
node render.js ../../docs/nava_sprites.png
```
