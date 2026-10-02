# Bat rarities

Five bats, all the same length as the starter bat (`assets/bat`), with the grip in the same place. They all fit the
same Tool setup and swing animation.

| Rarity | Name idea | Model | Look |
|---|---|---|---|
| Common | Ash Slugger | starter bat mesh | plain natural ash wood, black tape, a burnt-in paw brand |
| Uncommon | Rookie Green | starter bat mesh | green lacquered barrel with white pinstripes, green tape, white paw logos |
| Rare | Blue Alloy | **new: metal bat** | anodized blue aluminium with white swoosh graphics, rubber end cap, wide flared knob, blue accent ring, blue-striped grip |
| Epic | Royal Violet | **new: ornate bat** | purple lacquered wood, silver bands (one set with 4 gems), silver crown cap with a big purple gem, silver pommel, stitched leather grip |
| Legendary | Golden Paw | **new: gold slugger** | polished gold with flowing white-gold engravings, 5 pink gems around the sweet spot, a glowing amber ring, and a **cat-paw end cap** (pink pad + 4 toe beans), white tape |

## Files
- `fbx/Bat_<Rarity>.fbx`: each is one MeshPart named `Handle`, with its colour texture built in.
- `textures/bat_<rarity>.png` + `_normal`, `_roughness`, `_metalness`: put these in a **SurfaceAppearance** so the alloy,
  silver and gold actually shine (`Lighting.Technology = Future`). Common and Uncommon look fine with just the
  colour texture.
- Common and Uncommon use the starter mesh, so you can upload only their texture and set `TextureID` on the
  starter bat instead of importing a new model.
- Triangles: Common/Uncommon 1,840, Rare 2,400, Epic 4,070, Legendary 5,050.

## Tool setup (same for all)
The length runs along the part's Y axis, knob at -Y. Use the same Grip as the starter bat. Roblox centres each mesh,
and the Epic and Legendary tips end slightly differently, so for a perfect fit use:

| Bat | `Tool.Grip` |
|---|---|
| Common, Uncommon, Rare | `CFrame.new(0, -1.2, 0)` |
| Epic | `CFrame.new(0, -1.204, 0)` |
| Legendary | `CFrame.new(0, -1.178, 0)` |

(-1.2 works for all of them; the difference is under 0.03 studs.)

## Effects suggestion
To make higher rarities feel special in the swing:
- **Rare:** a blue `Trail` on the barrel.
- **Epic:** a purple trail plus a small sparkle `ParticleEmitter` on the gem.
- **Legendary:** a gold trail, pink paw-print particles on hit, and a soft gold `PointLight`.
