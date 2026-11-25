# Arhipelagul Comorilor — harta jocului

Imaginea: `docs/harta.png`. Toate coordonatele sunt în **studs**, pe planul X/Z.
Nivelul apei este la **Y = 0**. Nordul hărții = direcția **−Z**.

## Lumea
- Ocean: 2000 × 2000 studs, centrat în (0, 0) → de la X −1000..1000 și Z −1000..1000.
- Margine: pereți invizibili la marginea oceanului (nava nu poate ieși).
- Apă turcoaz (Terrain Water sau un Part plat Neon/SmoothPlastic albastru-turcoaz).

## Insule
| Insulă | Centru (X, Z) | Rază aprox. | Ce are |
|---|---|---|---|
| Insula Portului | (0, 740) | 150 | Portul (spawn), 2 case, magazinul. Debarcader spre nord până la Z ≈ 600 |
| Insula Palmierilor | (−550, 300) | 120 | Cufăr ușor |
| Insulița Pescarilor | (500, 250) | 80 | Cufăr ușor |
| Insula Pescărușilor | (−150, −150) | 90 | Cufăr mediu |
| Insula Craniului | (600, −500) | 150 | Fort pirat cu tunuri (inamic static), cufăr mare |
| Insula Vulcanului | (−600, −620) | 165 | Vulcan (con + lavă Neon în vârf), cufăr mare |
| Stânca Singuratică | (820, 750) | 70 | Cufăr secret |

Insulele: margine de nisip (bej) + interior cu iarbă și palmieri. Forme neregulate, nu cercuri perfecte.

## Puncte importante
- **Spawn navă:** (0, 525), cu fața spre nord (−Z).
- **Cufere (✕):** (−560, 260), (−150, −120), (500, 230), (640, −470), (−620, −560), (820, 740) — pe plajă, lângă apă, ca nava să poată ajunge lângă ele.
- **Recif:** zonă în jurul (250, −150), rază ~60 — stânci mici de abia ieșite din apă; nava merge cu 50% viteză acolo.

## Zone
| Zonă | Unde | Reguli |
|---|---|---|
| Zona sigură (verde) | cerc cu raza 320 în jurul (0, 700) | Fără inamici, fără damage. Inamicii nu intră |
| Zona medie (galben) | cerc cu raza 650 în jurul (0, 700) | Nave inamice slabe (albe) |
| Ape periculoase (roșu) | Z < −450 (toată partea de nord) | Nave inamice grele (negre) + fortul de pe Insula Craniului |

## Trasee de patrulare inamice (puncte, în ordine, în buclă)
- **Patrulă slabă (centru):** (−300, 0) → (150, −250) → (450, 0) → (100, 350) → înapoi. 3 nave albe.
- **Patrulă grea (Craniu):** (250, −750) → (850, −650) → (850, −250) → (350, −300) → înapoi. 2–3 nave negre.
- **Patrulă grea (Vulcan):** (−850, −300) → (−300, −450) → (−350, −850) → (−850, −850) → înapoi. 2 nave negre.

Navele inamice părăsesc traseul ca să urmărească jucătorul dacă e la < 150 studs, și se întorc la traseu dacă jucătorul fuge la > 300 studs sau intră în zona sigură.
