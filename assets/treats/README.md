# Cat treats

8 new treats for the treat shop, from Common to Mythic. The higher the rarity, the fancier the pack:
plain paper and tins at Common, glossy pouches and cartons at Uncommon, glass and ribbons at Rare,
real food at Epic, gold and gems at Legendary, glowing galaxy stuff at Mythic.

## Files
- `fbx/<Treat>.fbx` - one file per treat. Import with **Home > Import 3D**.
- `treats_texture.png` - the one texture every treat uses (set it as `TextureID` if the importer doesn't).
- `treats.blend` - Blender source.

## After importing
- Parts ending in `_Glass` (Catnip Cookies jar, Cosmic Kibble orb): **Transparency 0.5**, Material **Glass**.
- Parts ending in `_Glow` (Golden Fish Feast halo, Cosmic Kibble stars): Material **Neon**. A Sparkles or
  ParticleEmitter on the Legendary and Mythic treats makes them pop even more.
- For a held Tool, weld the parts to a `Handle` the same way as your current treats.

## Suggested catalog entries (same format as `Shared.TreatCatalog`)
```lua
CrunchyBits    = { Name = "Crunchy Bits",      Rarity = "Common",    Price = 20,  XP = 15,  Chance = 100, MinStock = 10, MaxStock = 14 },
TunaNibbles    = { Name = "Tuna Nibbles",      Rarity = "Common",    Price = 30,  XP = 25,  Chance = 100, MinStock = 8,  MaxStock = 12 },
SalmonSnaps    = { Name = "Salmon Snaps",      Rarity = "Uncommon",  Price = 70,  XP = 60,  Chance = 95,  MinStock = 5,  MaxStock = 8 },
MilkyMoo       = { Name = "Milky Moo Drops",   Rarity = "Uncommon",  Price = 80,  XP = 70,  Chance = 95,  MinStock = 5,  MaxStock = 8 },
CatnipCookies  = { Name = "Catnip Cookies",    Rarity = "Rare",      Price = 110, XP = 100, Chance = 90,  MinStock = 4,  MaxStock = 6 },
PurrfectSushi  = { Name = "Purrfect Sushi",    Rarity = "Epic",      Price = 200, XP = 180, Chance = 80,  MinStock = 2,  MaxStock = 4 },
GoldenFishFeast= { Name = "Golden Fish Feast", Rarity = "Legendary", Price = 450, XP = 450, Chance = 55,  MinStock = 1,  MaxStock = 3 },
CosmicKibble   = { Name = "Cosmic Kibble",     Rarity = "Mythic",    Price = 800, XP = 850, Chance = 35,  MinStock = 1,  MaxStock = 2 },
```
