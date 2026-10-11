# Prompt: dress the city with my new decorations (paste into Claude with Roblox Studio MCP)

I made a set of 23 cartoon city decorations (in my repo under `assets/city_decor/`). They include:
- trash cans and bags, a fire hydrant, a mailbox, street lamps and a signpost
- flower planters, pots, topiaries, window boxes, a shop awning and bunting
- crates, a barrel, cardboard boxes, a café set and cat bowls
- **mouse holes, crumbs and cheese** for the city mice

Use them to make the city feel **full, cosy and lived-in** instead of empty, like a front-page Roblox town. Look at
`assets/city_decor/previews/street_showcase.png` first: that's the vibe I want.

**This replaces the props you were going to make for the mouse feature.** Use these mouse holes, crumbs, cheese,
trash cans, crates and planters for the mice (spawn spots, escape holes, food spots, cover).

---

## 0. Before you place anything
1. I'll import every FBX from `assets/city_decor/fbx/` with the 3D Importer into
   `ServerStorage.CityDecor.<Name>` (or tell me if you can do the import).
   - Each prop is **one MeshPart with its texture embedded**.
   - `StreetLamp` also has a separate `LampGlass` part.
2. Read how the city is laid out: the buildings, sidewalks, roads, the bakery stand, Whisker Park, the stray
   cat/dog/wolf routes, and any `PathfindingModifier`s from the mouse work. Decorations must **never block a
   sidewalk route, a road, a door or a car's path**.
3. Back up the city (an `_OLD` copy of the map folder, disabled).
4. Show me a short placement plan (how many of each, and roughly where), then do it.

## 1. Settings for every prop
- `Anchored = true`.
- **Collision:**
  - Solid things players walk around keep `CanCollide = true`, with `CollisionFidelity = Box` (or `Hull` for round
    things): trash cans, the hydrant, mailbox, lamps, planters, topiaries, crates, barrels, boxes, the signpost,
    the café table.
  - Small or flat things get `CanCollide = false` and `CanQuery = false`, so players, cats and cars never snag on
    them: crumbs, cheese, cheese bits, cat bowls, bunting, the awning, window boxes, mouse holes, trash bags.
- `CastShadow`: on for big props, off for crumbs, cheese bits and bunting.
- `RenderFidelity = Automatic`.
- Keep the imported `TextureID`. Don't change `Material` or `Color` (the colours are baked into the texture).
- **Variety:** when you place copies of the same prop, give each a random rotation (except wall props and
  signposts) and a random scale of 0.92–1.08 (`Model:ScaleTo` or Size), so nothing looks copy-pasted.
- Put everything in `workspace.City.Decor`, in sub-folders per area.

## 2. Wall props (they need to sit flush)
- `MouseHole_Stone`, `MouseHole_Home`, `MouseHole_Cheese`, `WindowFlowerBox` and `ShopAwning` have a **flat back
  on their +Z side**: place them with that side against the building wall, facing outward (LookVector pointing away
  from the wall). Raycast to find the wall surface, then offset by half the prop's Z size so it's exactly flush,
  with no gap and no clipping.
- **Mouse holes:** their bottom edge sits **on the ground**, at the base of building walls. Prefer the gaps between
  buildings, back walls and quiet corners, not right next to the main doors.
  - Use about **8–10 holes**: about 4 `MouseHole_Stone`, 3 `MouseHole_Home`, 2–3 `MouseHole_Cheese`.
  - A mouse diving in should look like it goes into the dark opening. Its centre is at the middle of the arch,
    about 0.5 studs above the ground.
- **Window boxes:** directly under windows (centred, about 0.2 studs below the sill).
- **Awnings:** over shop and building doors and big ground-floor windows. The top edge goes about 0.5 studs above
  the door frame. Put one over the bakery stand if it fits.

## 3. Where to put things (make it feel alive)
Spread props so every street has something interesting, without cluttering:

| Area | What to put there |
|---|---|
| **Along the sidewalks** (in a "furniture strip" at the outer edge, next to the road, never in the walking lane) | `StreetLamp` every 30–40 studs on both sides of main streets, a `FireHydrant` near corners, a `Mailbox` or two, `TrashCan`s near corners and benches |
| **Building fronts** | a `ShopAwning` over most doors, `WindowFlowerBox`es under windows, a `FlowerPot` or `Topiary` on each side of doors |
| **Bakery stand** | a `CafeSet` or two, `FlowerPot`s, a `TrashCan`, `Crumbs` under the tables (mice love it) |
| **Between buildings and alleys** | `CrateStack`, `Barrel`, `CardboardBoxes`, `TrashCan` + `TrashBags`, and the mouse holes. These make good hiding spots for the mice. |
| **Near Purr Autos / the factory** | `CardboardBoxes` and `CrateStack` (they have the Purr Autos stamp) |
| **Street corners** | a `SignPost` at the main crossroads, pointing the right way to Whisker Park, Purr Autos and the Bakery (rotate the post so each arrow points toward its place) |
| **Overhead** | `Bunting` strung between buildings across side streets and at the bakery (at about 10–14 studs high, never low enough to hit cars). Stretch it to fit the gap by scaling X. |
| **Whisker Park** | `FlowerPlanter`s along paths, `FlowerPot`s by benches, a few `Topiary`s at the entrance, `CatBowls` near the park cats, `Crumbs` and `CheeseBits` near benches |
| **For the strays** | 3–4 `CatBowls` in quiet spots (by a back door, next to the park) |

- **Rough totals:** about 12–16 lamps, 6–8 trash cans (half with bags), 3–4 hydrants, 2 mailboxes, 2 signposts,
  6–8 planters, 8–12 pots, 4–6 topiaries, window boxes on most windows, 4–6 awnings, 4–6 bunting strings,
  4–5 crate stacks, 4–6 barrels, 3–4 box piles, 2–3 café sets, 3–4 bowl sets, 8–10 mouse holes, 6–10 crumb
  spots, 3–4 cheese spots.
- Tune these to the size of the city. The street should look busy but every path stays clear. Walk the city
  afterwards and check it.

## 4. Street lamps at night
- `LampGlass`:
  - `Material = Neon`, `Color = (255, 214, 140)`
  - add a `PointLight` (Brightness 1.5, Range 18, the same warm colour, Shadows off for performance)
  - add a soft `SurfaceLight` or `SpotLight` pointing down if it looks better
- **If the day/night cycle exists:** lamps turn **on at dusk and off at dawn**, flickering on one after another
  (0–2 s random delay each). Tag them `NightLight` so the existing day/night system can drive them. Off by day =
  `Material = Glass` / light disabled.
- The `MouseHole_Home` has a tiny lantern baked in. Optionally add a very small PointLight there at night
  (Range 4, warm) so the mouse homes glow cutely.

## 5. Hook into the mice (if the mouse feature is built or being built)
Tag the props so the mouse code finds them:

| Tag | Put it on | Used for |
|---|---|---|
| `MouseHole` | every mouse hole | spawn and escape holes; use the arch centre as the entry point |
| `MouseFood` | `Crumbs`, `Cheese`, `CheeseBits`, and the cheese and crumbs already in `MouseHole_Cheese` / `MouseHole_Home` | nibble spots |
| `MouseSpot` | crates, barrels, box piles, trash cans and bags, planters, topiaries | cover and wander points |

Cats sniff at `MouseHole`s when a mouse escapes into one.

## 6. Performance
- Every copy of a prop shares the same MeshId and TextureID (clone from `ServerStorage`), so memory stays low.
- If `StreamingEnabled` is on, group the props into Models per block with `ModelStreamingMode = Default`, and make
  sure nothing important to gameplay (the mouse holes) streams out while players are nearby.
- Lamps: Shadows off on PointLights. If there are more than about 20 lights, only light lamps within about 150
  studs of the player (client-side).

## 7. Check and report
- [ ] Walk every sidewalk, crossing and the park: nothing blocks a path, a door or a road; no floating or sunken
      props (everything sits on the ground, or flush on walls).
- [ ] Wall props are flush with no gaps; mouse holes sit on the ground with the opening facing out.
- [ ] Stray cat, dog and wolf routes still work (no new stuck spots); mice can reach the holes.
- [ ] Lamps glow at night and turn off by day.
- [ ] Take 4 screenshots (main street, bakery, an alley with mouse holes, the park), and send me the counts of each
      prop you placed.
