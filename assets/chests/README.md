# Treasure chests (one per rarity)

Seven chests, one per rarity in the game (`CatCatalog.Colors` order). Each one looks clearly better than the one
before it:

| Rarity | Look | Triangles |
|---|---|---|
| Common | oak planks, iron bands, plain iron lock | 1.7k |
| Uncommon | lighter oak, green-painted bands (chipped), rivets, bottom corner caps | 2.6k |
| Rare | dark walnut, steel bands, blue enamel trim, all corners capped, side handles, ball feet, blue gem lock | 4.4k |
| Epic | purple lacquer, silver bands, purple enamel rim trim, two front gems in bezels, purple gem lock | 5.1k |
| Legendary | red lacquer, wide gold bands, gold filigree trim, gold lid medallion with a big gem, claw feet | 6.3k |
| Mythic | white pearl marble with pink and gold veins, gold bands, pink filigree, pink crystal clusters on the lid and feet | 7.0k |
| Secret | obsidian with glowing aqua cracks, dark chrome bands with an aqua line, glowing rune trim, a crown of aqua crystals | 7.3k |

The loot pile inside gets richer too: Common is just coins, and higher rarities add more gems.

## Files
- `fbx/Chest_<Rarity>.fbx`: one chest per file, with 3 parts:
  - `Base`: the box
  - `Lid`: opens on its hinge
  - `Loot`: the coin and gem pile inside; hide it until the chest opens if you like
- `textures/chest_<rarity>.png`: the colour map (also embedded in the FBX).
- `textures/chest_<rarity>_normal / _roughness / _metalness.png`: for a **SurfaceAppearance** (ColorMap, NormalMap,
  RoughnessMap, MetalnessMap) on all 3 parts. This is what makes the metal, gems and lacquer shine. Use
  `Lighting.Technology = Future`.
- `chests.blend`: the source file. `chests_preview.png`: all 7 chests closed (top) and open (bottom).
  `closeups.png`: Legendary, Mythic and Secret up close.

## Size and part positions
- About 4.4 wide × 2.9 deep × 3.4 tall studs (Mythic and Secret are a bit taller because of the crystals). Scale the
  model if you want them bigger or smaller.
- The front (lock side) faces the model's -Z (LookVector), like a VehicleSeat.
- Positions below are relative to `Base`, in Roblox axes, measured from each part's centre:

| Chest | Lid from Base | Hinge from Lid centre | Loot from Base |
|---|---|---|---|
| Common | (0, 1.43, -0.01) | (0, -0.50, 1.36) | (0, 0.34, 0.02) |
| Uncommon | (0, 1.43, -0.03) | (0, -0.50, 1.36) | (0, 0.33, 0.01) |
| Rare | (0, 1.52, -0.07) | (0, -0.50, 1.40) | (0, 0.42, 0.01) |
| Epic | (0, 1.52, -0.07) | (0, -0.50, 1.40) | (0, 0.41, 0.01) |
| Legendary | (0, 1.52, -0.08) | (0, -0.50, 1.41) | (0, 0.45, 0.01) |
| Mythic | (0, 1.76, -0.09) | (0, -0.74, 1.41) | (0, 0.42, 0.00) |
| Secret | (0, 1.80, -0.10) | (0, -0.78, 1.42) | (0, 0.46, 0.00) |

## Opening the lid
The hinge runs along the back top edge (the X axis). To open the lid:
```lua
local hinge = lid.CFrame * CFrame.new(hingeOffset)   -- the "Hinge from Lid centre" value above
local closed = hinge:ToObjectSpace(lid.CFrame)
-- tween a NumberValue `angle` from 0 to ~105 degrees, and each step set:
lid.CFrame = hinge * CFrame.Angles(math.rad(angle), 0, 0) * closed
```
If it swings the wrong way, use `-angle`.

## Glow (optional)
For extra shine on the better chests, add a `PointLight` inside `Loot` (gold, Brightness 1–2, Range 8) that turns on
as the lid opens. For Mythic and Secret, also add one tinted pink or aqua near the crystals, plus a slow sparkle
`ParticleEmitter`.
