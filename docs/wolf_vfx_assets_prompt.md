# Prompt: use my custom wolf VFX pack (paste into Claude with Roblox Studio MCP)

I made a custom VFX pack for the wolf fights: **25 effect meshes**, **17 particle textures**, **9 flipbook animations**,
ground decals, screen overlays, trail/beam textures and health-bar emblems. They're in my repo under `assets/vfx/`.
Use them to rebuild the wolf effects described in the wolf polish prompt (section 5, "Full effects revamp"), so
everything looks like a front-page boss battle.

This prompt tells you **what each file is**, **how to set it up in Roblox**, and **which pieces make up each
wolf ability**. Read it all before you start. Where this prompt and the polish prompt describe the same effect, use
the assets from this prompt and the look and timing from the polish prompt.

---

## 0. Uploading (I'll do this part; you wire it up)
- **Images:** I'll bulk-upload every PNG with the Asset Manager and give you the asset IDs. Put them all in one
  module, `ReplicatedStorage.Shared.VFXAssets`, as `Images = { p_glow = "rbxassetid://…", … }`, keyed by the file
  name without `.png`.
  - Don't use placeholder IDs. Ask me for any you're missing.
- **Meshes:** I'll import each FBX from `assets/vfx/meshes/` with the 3D Importer into
  `ReplicatedStorage.WolfVFX.Meshes` (one Model per FBX, named like the file).
  - Some FBX files contain several parts (for example `IceBlock` has `IceBlock` + `IceBlockGlow`); keep their
    names. Their relative positions are kept by the importer.
  - Check every imported MeshPart, then **turn the textures that came embedded in the FBX into SurfaceAppearances**
    as listed below (or strip them and use the IDs from `VFXAssets`).
- `assets/vfx/previews/` has pictures of everything, including 3 showcase renders (Frost, Celestial, Ember) that
  show the look I want. Look at them first.
- **Exact sizes** of every mesh (in studs, in Roblox axes) are in `assets/vfx/meshes/mesh_specs.json`.

---

## 1. How to use these assets in Roblox (rules for every effect)

### 1a. Mesh effects
Every VFX MeshPart:
- `Anchored = true`, `CanCollide = false`, `CanQuery = false`, `CanTouch = false`, `CastShadow = false`,
  `Massless = true`
- **cloned from a pool** (pre-create a few of each; never `Instance.new` per effect), parented to a
  `workspace.VFX` folder, returned to the pool when done
- animated with `TweenService` on `Size` (the mesh scales with Size), `CFrame` and `Transparency`
  - typical effect: start small and nearly opaque, grow fast with `Quint/Out`, fade out with `Quad/In`
- **"Neon" meshes:** `Material = Neon`, `Color` = the wolf's palette colour, no texture
- **Textured meshes:** add a `SurfaceAppearance` with:
  - `ColorMap` = the texture listed for that mesh
  - **`AlphaMode = Transparency`**, so the soft texture edges fade properly
  - `Color` = the tint colour (the textures are mostly white so they can be tinted)
- **Energy and shimmer meshes** (aura, breath cone, wind cone, dome): `Material = ForceField` with
  `TextureID = mt_energy` and `Color` = the tint. ForceField makes the texture glow and shimmer like magic.
  Rotate the mesh slowly (or tween its CFrame) so the pattern moves.
- **Ice meshes:** `Material = Glass`, `Color = (175, 230, 255)`, `Transparency = 0.25–0.35`, `Reflectance = 0.1`,
  plus a `SurfaceAppearance` with `mt_ice` (AlphaMode Transparency).
  - Glass only looks right with `Lighting.Technology = Future` or `ShadowMap`. Check what the game uses; if it looks
    flat, use SmoothPlastic + `mt_ice` instead.
- Flat meshes (rings, slashes, pillars, rays, cones) are **already double-sided**, so they show from every angle.
- Add a `PointLight` (brightness 2–4, range 8–14, palette colour) to the main mesh of big effects, tweened along with
  the effect.

### 1b. Particles
- All particle textures are **white** (except the fire/explosion flipbooks, debris, leaf and the coin), so
  `ParticleEmitter.Color` tints them.
- Use `LightEmission` 1 for glowing things (sparks, stars, magic, fire, embers) and 0–0.2 for smoke, dust and
  debris.
- Fire a burst with `emitter:Emit(n)` from an attachment; don't leave emitters running unless the effect loops.
- **Flipbooks** are 4×4 grids (16 frames):
  - set `FlipbookLayout = Grid4x4`
  - `FlipbookMode = OneShot` for one-off puffs/bursts (the 16 frames play over the particle's lifetime)
  - `FlipbookMode = Loop` with `FlipbookFramerate` 18–24 for looping fire/energy
  - `p_debris_2x2` is a **2×2** grid: use `FlipbookLayout = Grid2x2` with `FlipbookMode = Random` to get a different
    piece per particle
- **Low graphics quality** (`UserSettings().GameSettings.SavedQualityLevel` ≤ 3): halve particle counts and skip
  the secondary layers.

### 1c. Decals on the ground
- Put each decal on a thin invisible part (`Transparency = 1`, size about 0.05 thick) **projected onto the
  ground** with the raycast method from the polish prompt (section 1e), on the part's **Top** face.
- Tint with `Decal.Color3`, fade with `Decal.Transparency`.
- `d_frost_crack_line` and `d_telegraph_bar` are **long strips** (4:1): stretch the part along the direction they
  point.
- `d_telegraph_bar` also works as a **Beam** texture: `TextureMode = Wrap`, `TextureLength` 3, `TextureSpeed` 2, for
  scrolling chevrons.

### 1d. Screen overlays
- A full-screen `ImageLabel` (`Size = UDim2.fromScale(1, 1)`, `ScaleType = Stretch`, `BackgroundTransparency = 1`,
  high `ZIndex`, `IgnoreGuiInset = true` on the ScreenGui).
- Fade with `ImageTransparency`. Respect the "Reduce flashing effects" setting.

### 1e. Trails and beams
- `tr_*` textures go on `Trail.Texture` (`TextureMode = Stretch`, `LightEmission` 1, `FaceCamera = true`,
  `Lifetime` 0.2–0.4, `WidthScale` tapering to 0, `Transparency` sequence 0 → 1).
- `tr_beam_core` is a glowing beam core for any Beam (tether lines, blink path, light shafts).

### 1f. Palette (use everywhere)

| Wolf | Core | Accent | Dark |
|---|---|---|---|
| Timber | `#FFF4E0` | `#FFB43C` | `#6E645A` |
| Frost | `#FFFFFF` | `#7FDBFF` | `#2A5A9A` |
| Celestial | `#FFFFFF` | `#FFD750` | `#7A50FF` |
| Shadow | `#FF3A2A` | `#B0102A` | `#14060E` |
| Ember | `#FFF0B0` | `#FF8C1E` | `#8A1A08` |
| Golden | `#FFFFFF` | `#FFC828` | `#28EB82` |

---

## 2. The files

### 2a. Meshes (`assets/vfx/meshes/*.fbx`)
Sizes are the imported size in studs (X × Y × Z, Y up). The **front** of a mesh is its **-Z side (LookVector)**
unless noted.

| Mesh (FBX → parts) | Size | Look / how to use it |
|---|---|---|
| `ShockwaveRing` | 2 × 0 × 2 | flat ring lying on the ground. SurfaceAppearance `mt_ring`. Tween Size from 0.5 to 8–20, fade out. Lay it on the ground for shockwaves, or stand it up for pulses. |
| `ShockwaveDome` | 2 × 1 × 2 | half-sphere shell, open at the bottom. ForceField + `mt_energy`. Big impacts and charged hits: grows from 1 to 8 in 0.25 s and fades. |
| `SlashCrescent` | 1.9 × 0.1 × 0.75 | crescent slash arc, bulging toward the front. SurfaceAppearance `mt_slash` (the bright edge is the outer curve). Bites (2 mirrored, closing), bat swing smears, combo afterimages, fire bite (orange). |
| `WindCone` | 2 × 2 × 0.9 | short cone opening toward the front. ForceField + `mt_energy`. The air burst behind a lunge launch, a dash start or a dodge hop. |
| `LightPillar` | 2 × 2 × 2 | open cylinder, bright at the bottom and fading at the top. SurfaceAppearance `mt_pillar`. The chest drop pillar, meteor warning column, enrage column, KO burst. Scale the height up to 10–30. |
| `HowlRing` | 2.1 × 0.1 × 2.1 | thin glowing torus ring. Neon. Howl sound-waves (stand it vertical in front of the mouth, ×3 expanding), enrage pulse, "Exposed" glint ring. |
| `GodRays` | 1.8 × 1.9 × 0 | fan of light rays facing the front. SurfaceAppearance `mt_pillar`. **Point it at the camera every frame.** KO flash, Golden Flash, counter hits, chest reveal. Spin it slowly. |
| `DizzyStars` | 1.3 × 0.4 × 1.3 | ring of 5 cartoon stars. Neon gold. Spins over a staggered wolf's head or a dazed player's head. |
| `IceBlock` → `IceBlock`, `IceBlockGlow` | 6.3 × 7.2 × 6.0 | crystal ice block around a frozen player. `IceBlock` = Glass ice; `IceBlockGlow` = an inner core, Neon cyan at `Transparency` 0.85 (a soft inner glow). Place it so the bottom sits on the floor under the player (centre about 3.6 studs above the floor). |
| `IceShards` → `Shard1`…`Shard10` | 0.4–2.3 | ice chunks for **every ice shatter** (ice block break, Ice Armour break, spike crumble). Clone and throw them unanchored with random velocities, let them bounce, fade and shrink after 1.5–2 s (Debris service). Use `Size × 0.3–0.6` for small shards. |
| `IceSpikes` → `IceSpikeA/B/C` | about 2 × 3.2 × 1.6 | ice spike clusters. Glass ice. **The base is the bottom of the mesh:** spawn each one sunk fully under the floor and tween it **up** so it bursts out of the ground. |
| `BreathCone` | 0.84 × 0.84 × 1 | two nested cones opening toward the front (the narrow end at +Z). ForceField + `mt_energy`, cyan. Scale to about (8.4, 8.4, 10) for a 10-stud breath. Place it so the narrow end is at the mouth: `mouthCFrame * CFrame.new(0, 0, -length/2)`. Spin the inner pattern by rotating it around its Z axis. |
| `IceArmour` | 1.3 × 1.2 × 1.76 | ice crystals **modelled on the Frost Wolf's back and shoulders**. Glass ice. Every frame (client): `armour.CFrame = wolfMesh.CFrame * CFrame.new(0.058, 0.599, 0.106)`, where `wolfMesh` is the wolf's skinned MeshPart. Nudge the offset if it's slightly off in your rig. |
| `StarOrb` → `StarOrb`, `StarOrbGlow` | 0.95 / 0.84 | Star Orb: a faceted 3D star (Neon gold) in front of a glowing ball (`StarOrbGlow`: SurfaceAppearance `mt_galaxy` or ForceField violet). Weld them together, and spin the star. |
| `StarBurst` | 1.5 | spiky 3D starburst. Neon (white core, gold/violet tint). Blink out/in, star impacts, orb pops, KO flash. Scale 0 → 5 in 0.12 s and fade. Rotate it randomly each time. |
| `BlinkStreak` | 0.5 × 0.5 × 2 | spindle of light, length 2 along Z. Neon violet/white. Stretch it between the blink start and end points for 0.2 s (Size.Z = distance), then thin it out. |
| `Meteor` → `Meteor`, `MeteorTail` | star 1.9; tail 4.5 long | star meteor (Neon gold) + a tapered light tail behind it (+Z side, SurfaceAppearance `mt_pillar`). It flies toward its front (-Z). |
| `Fireball` → `Fireball`, `FireballShell` | 2.1 / 2.7 | rolling fire sphere. `Fireball`: SurfaceAppearance `mt_fire`, Neon-bright colours. `FireballShell`: `mt_fire` at about 50% transparency, spinning the other way (the rolling look). |
| `FireRing` | 2.24 × 0.8 × 2.24 | ring wall of flames. SurfaceAppearance `mt_fire_wall` (tongues). Ember Burst (scale 1 → 10 radius), fireball impact ring. Scroll the flames by rotating it. |
| `Debris` → `Rock1`…`Rock6` | 0.3–1.2 | charred rocks with glowing cracks (SurfaceAppearance `mt_rock`). Thrown unanchored on fire impacts and slams, then shrink and fade. |
| `FlameStreak` | 0.5 × 0.5 × 2.4 | comet-shaped flame. The round head is at the front (-Z), the tail at the back. SurfaceAppearance `tr_fire` (it's mapped along its length). The Flame Dash body. |
| `ClawSlash` | 0.5 × 1.5 × 0.75 | 3 parallel claw slashes in a vertical plane. SurfaceAppearance `mt_slash`, red/black. The Shadow ambush hit, any claw swipe. |
| `ShadowTendrils` | 1.5 × 2.4 × 1.7 | 7 curling smoke tendrils rising from a point. Dark (`#14060E`), SmoothPlastic, `Transparency` 0.2. Vanish (rise + twist + fade), Darkness, Shadow pack call. |
| `AuraShell` | 1.56 × 3.0 × 4.1 | energy shell that fits around the whole wolf. ForceField + `mt_energy` in the type colour. `CFrame = wolfMesh.CFrame`. Enrage aura, Celestial decoy shimmer, spawn-protection shield (scaled to a player). |
| `Coin` | 1 × 1 × 0.12 | my game coin with the paw emblem. SurfaceAppearance `mt_coin` (+ `Material = Foil` or Metal for shine). The coin-reward fountain (polish prompt 4b). |

`wolf_vfx.blend` is the Blender source for all of them (you don't need it).

### 2b. Particle textures (`assets/vfx/particles/`)

| File | What it is | Use it for |
|---|---|---|
| `p_glow` | soft round glow | glow behind orbs, eyes, fireballs, light flashes |
| `p_spark` | streak spark (use `Orientation = VelocityParallel`) | hit sparks, fire sparks, ice chips flying |
| `p_sparkle` | 4-point twinkle star | magic, Golden sparkles, coin glints, "Exposed" glint |
| `p_star` | cartoon 5-point star | Celestial stars, dizzy stars, star trails |
| `p_snowflake` | snowflake | Frost aura, frost breath, ice spike puffs, Chilled |
| `p_iceshard` | ice shard sprite | ice chips on armour hits, shatters |
| `p_ember` | hot ember dot | Ember aura, fire impacts, burning player |
| `p_ring` | thin ring | flat shockwave sprites (`Orientation = FacingCameraWorldUp` or flat) |
| `p_impact` | cartoon impact burst | bat hits, bites landing |
| `p_slash` | crescent slash sprite | quick slash flashes |
| `p_leaf` | green leaf (coloured) | door poof, retreat into the woods |
| `p_fur` | fur tuft | fur puffs on hits (tint with the coat colour) |
| `p_debris_2x2` | cardboard bits + crumbs (2×2 grid, coloured) | the wolf eating a box, box stolen |
| `p_pawprint` | paw print | Legendary bat hits, coin magnet, my game's brand sparkle |
| `p_rune_circle` | magic rune circle (1024) | Meteor warning circle, Celestial blink ground mark (use as a ground decal too) |
| `p_wisp` | dark smoke tendril | Shadow aura, Darkness ground fog |
| `p_soundwave` | `)))` sound arcs | Howl, growl warning |

### 2c. Flipbooks (`assets/vfx/flipbooks/`, all Grid4x4)

| File | Mode | Look | Use it for |
|---|---|---|---|
| `fb_fire_4x4` | Loop | cartoon flame (coloured) | flame aura, burning player, fire patches, Flame Dash trail |
| `fb_smoke_4x4` | OneShot | cel-shaded puff cluster | dust (tint brown/grey), door poof, landing dust, snow puffs (tint white-blue), fireball smoke |
| `fb_explosion_4x4` | OneShot | fireball explosion that cools to smoke (coloured) | fireball impact, Ember Burst, Flame Dash end |
| `fb_magic_burst_4x4` | OneShot | flash + ring + rays + sparkles | blink in/out, star orb impact, meteor impact, counter hits (gold) |
| `fb_frost_mist_4x4` | OneShot | swirling cold mist | Frost Breath, ice shatter, freeze |
| `fb_impact_4x4` | OneShot | flash + spikes + ring | every bat hit and bite impact |
| `fb_shadow_smoke_4x4` | OneShot | dark smoke with a red-purple rim (coloured) | Vanish, ambush reveal, shadow clones, Shadow aura |
| `fb_energy_4x4` | Loop | white flame-like energy (tint it) | enrage aura flames (type colour), Timber frenzy (amber), spawn shield |
| `fb_coin_spin_4x4` | Loop | spinning game coin (coloured) | coin particles in reward bursts and Golden Wolf hits (cheaper than meshes) |

### 2d. Decals, overlays, trails and icons

| File | Kind | Use it for |
|---|---|---|
| `d_crack` | ground decal | lunge landings, slams, ice spike bases |
| `d_frost_crack_line` | ground strip (4:1) | the **Ice Spikes telegraph line** running toward the player |
| `d_frost_patch` | ground decal | frozen ground under Frost Breath, the freeze, frost footprints (small) |
| `d_scorch` | ground decal (with ember cracks) | fireball impacts, the Flame Dash trail, Ember Burst, fire footprints (small) |
| `d_telegraph_circle` | ground decal | the Snap circle that shrinks under the target |
| `d_telegraph_bar` | ground strip / Beam | the lunge path bar (chevrons point along the lunge) |
| `s_burning` | screen overlay | Burning (flames up from the bottom and sides) |
| `s_frost` | screen overlay | Chilled / Frozen (ice creeping in from the edges) |
| `s_shadow` | screen overlay | Darkness, the Shadow ambush hit |
| `s_claws` | screen overlay | a big bite or ambush hit on the player (flash it for 0.4 s) |
| `s_speedlines` | screen overlay | charged hits and KO hits (0.15 s flash), lunge hits on the player |
| `s_vignette` | screen overlay (white, tint it) | low health (red), slow-mo death cam (black), type tints |
| `tr_energy`, `tr_fire`, `tr_smoke`, `tr_stars` | Trail textures | lunge body trail, flame dash/fireball, fireball smoke, star orbs/star pounce/Golden |
| `tr_beam_core` | Beam texture | blink path, tethers, light shafts |
| `mt_*` | mesh textures | listed per mesh in 2a |
| `i_timber`, `i_frost`, `i_celestial`, `i_shadow`, `i_ember`, `i_golden` | 256 px icons | the **type emblem** on the wolf health bar (polish prompt 2b) |

---

## 3. Recipes: which pieces make each effect
Timings are a guide. Keep the anticipation → impact → fade rhythm from the polish prompt. Every effect also has its
sound from the polish prompt.

### 3a. Shared wolf attacks and states
- **Snap (bite):**
  - **Telegraph:** `d_telegraph_circle` under the target, shrinking 1.2× → 0.6× during the wind-up, type colour.
  - **Bite:** two `SlashCrescent`s, one rotated 180° (upper and lower jaw), stood vertically in front of the mouth.
    They snap toward each other in 0.08 s with a white flash, then fade. Plus a `p_spark` burst (8).
  - **Hit:** `fb_impact_4x4` + `p_impact` (1, big) + `p_fur` (4, coat colour) on the player.
- **Lunge:**
  - **Telegraph:** a `d_telegraph_bar` strip (or a Beam with scrolling chevrons) along the ground path, filling
    during the wind-up.
  - **Launch:** a `WindCone` behind the wolf (grows 0.5 → 2.5 and fades in 0.25 s), `fb_smoke_4x4` dust (tinted
    `#BFA88A`, 6) at the back paws.
  - **In the air:** a `Trail` with `tr_energy` along the spine (two attachments), type colour.
  - **Landing:** `ShockwaveRing` (1 → 7, 0.3 s) + `d_crack` + `fb_smoke_4x4` dust ring (10, radial) + `Debris`
    (2–3 small rocks).
- **Hit on a wolf (bat):**
  - **Normal hit:** `fb_impact_4x4` (1, size 4) + `p_spark` (12) + `p_fur` (5, coat colour) + `SlashCrescent` smear
    in the swing direction (white, 0.12 s) + a small `ShockwaveRing` facing the camera.
  - **Counter:** the same, plus a gold `StarBurst` and `GodRays` flash (0.2 s).
  - **Charged hit:** the same, plus a `ShockwaveDome` (1 → 7) + two `ShockwaveRing`s + an `s_speedlines` flash.
  - **KO:** everything from the charged hit, bigger, plus `LightPillar` (gold, 0.4 s) + `GodRays` (spinning) +
    `StarBurst`, then the coin fountain (`Coin` meshes / `fb_coin_spin_4x4` particles + `p_sparkle`).
- **Stagger:** `DizzyStars` spinning over the head (1.5 s) + `p_star` (3, orbiting).
- **Exposed:** a gold `HowlRing` pulse over the wolf + `p_sparkle` (3).
- **Enrage:**
  - **Burst:** `HowlRing` ×2 expanding (vertical and flat) + `LightPillar` (type colour, 0.6 s) + `ShockwaveRing`
    (1 → 12).
  - **Rest of the fight:** `AuraShell` (ForceField, type colour, `Transparency` 0.6, slowly rotating) +
    `fb_energy_4x4` flames rising off the back (looping, 6/s).
- **Howl:** 3 `HowlRing`s stood vertically in front of the mouth, expanding outward one after another
  (0.15 s apart), + `p_soundwave` (3).
- **Door poof:** `fb_smoke_4x4` (12, grey-white) + `p_leaf` (6) + `p_sparkle` in the type colour (8) + a quick
  `p_glow` flash.
- **Retreat:** `fb_smoke_4x4` dust behind the feet; at the treeline a `fb_smoke_4x4` + `p_leaf` puff. Golden uses
  `p_sparkle`, Celestial `p_star`.
- **Eating the box (death cutscene):** `p_debris_2x2` (cardboard + crumbs, 6 per bite) + a small `fb_smoke_4x4`
  puff.

### 3b. Frost Wolf
- **Ice Armour:**
  - **On the wolf:** the `IceArmour` mesh following the wolf (offset in 2a).
  - **Each normal hit:** `p_iceshard` (6) + `p_spark` (cyan, 6) + a short white flash on the armour (tween the
    Glass `Color` to white and back).
  - **Shatter:**
    - hide the armour
    - throw 10–14 `IceShards` (small, unanchored, cyan Glass)
    - `fb_frost_mist_4x4` (4, big)
    - a cyan `ShockwaveRing` (1 → 9)
    - `d_frost_patch` under the wolf
    - `p_snowflake` (20)
    - an `s_frost` flash on screen (0.3 s)
  - **Regrow:** the armour scales from 0.2 → 1 with `p_snowflake` swirling in.
- **Frost Breath:**
  - **Telegraph:** `fb_frost_mist_4x4` and `p_snowflake` pulled **into** the mouth (an emitter with negative
    `Speed`, or particles spawned in a ring with velocity toward the mouth).
  - **Breath:**
    - a `BreathCone` (ForceField cyan) that grows from the mouth to full length in 0.15 s and spins
    - a `fb_frost_mist_4x4` stream (30/s along the cone) + `p_iceshard` (8/s) + `p_snowflake` (15/s)
    - `d_frost_patch` decals spreading along the ground under the cone
  - **Players inside:** `s_frost` overlay + `p_snowflake` on them.
- **Freeze (Frozen):**
  - `IceBlock` + `IceBlockGlow` grow around the player (0.6 → 1 scale in 0.15 s), `d_frost_patch` under it,
    `fb_frost_mist_4x4` puff.
  - **Cracking:** spawn `p_iceshard` chips.
  - **Breaking:** 12 `IceShards` + `fb_frost_mist_4x4` + a `ShockwaveRing` + an ice-shatter sound.
- **Ice Spikes:**
  - **Telegraph:** `d_frost_crack_line` strips appear along the line toward the player (fade in, then pulse
    brighter).
  - **Each spike** (0.08 s apart):
    - `IceSpikeA/B/C` (random, random yaw, scale 0.8–1.3) bursts up from under the floor in 0.1 s
    - `fb_smoke_4x4` snow puff (white-blue, 6), a `ShockwaveRing` (1 → 4), `d_crack`, `p_snowflake` (8)
  - **Crumble** after 1.5 s: each spike sinks/shrinks and throws 4–6 small `IceShards` + `p_iceshard`.
- **Ambient:** `p_snowflake` (3/s) + `fb_frost_mist_4x4` (1/s, very transparent) around the body; small
  `d_frost_patch` footprints that fade in 3 s.

### 3c. Celestial Wolf
- **Star Orbs:**
  - 3 `StarOrb` models **orbit above its back**: radius 1.2, height +1.5 above the wolf mesh centre, spinning. Each
    has a gold `PointLight`, a `p_glow` sprite behind it, a `Trail` (`tr_stars`) and a `p_sparkle` aura (4/s).
  - **Fire:** one by one (0.3 s apart) they fly at the player as homing projectiles, with the `tr_stars` trail
    stretching behind them.
  - **Impact:** `fb_magic_burst_4x4` (gold) + `p_star` (10) + `p_sparkle` (12) + a small `ShockwaveRing`.
  - **Popped by the bat:** a bright `StarBurst` (0 → 3 in 0.1 s) + a gold `ShockwaveRing` + `p_sparkle` (16).
- **Blink:**
  - **Out:**
    - `p_sparkle` and `p_star` rushing **inward** (spawn on a sphere of radius 3, velocity toward the centre) for
      0.25 s
    - the wolf squashes thin (scale its visual Y up and X/Z down quickly, or just hide it) and vanishes in a
      `StarBurst` (0 → 5) + `fb_magic_burst_4x4` (violet/gold) + a flat `ShockwaveRing` on the ground
  - **Path:** a `BlinkStreak` stretched from the start to the end point (0.2 s), plus a Beam with `tr_beam_core`.
  - **In:** the reverse burst at the destination + `p_rune_circle` flashing on the ground under it (0.5 s) +
    lingering `p_star` motes.
- **Starfall Decoys:**
  - Clones of the wolf mesh with **`Material = ForceField`** in violet, no shadow, plus an `AuraShell` at
    `Transparency` 0.8.
  - **Split:** a `fb_magic_burst_4x4` flash.
  - **Popping a decoy:** `fb_magic_burst_4x4` + `p_star` (12) + a small `StarBurst`.
- **Meteor:**
  - **Warning:** `p_rune_circle` as a ground decal (6-stud radius) **rotating** and pulsing, with a `LightPillar`
    (violet, 0.3 transparency) rising from it.
  - **Strike:** a `Meteor` model streaks down from high above along a slanted path, with the `MeteorTail` behind it.
  - **Impact:**
    - a `StarBurst` (0 → 8) + a big `ShockwaveRing` (1 → 14) + a `ShockwaveDome` (1 → 8)
    - `fb_magic_burst_4x4` (3, big)
    - a `p_sparkle` rain (30) + `p_star` (15)
    - `d_crack` + camera shake
- **Ambient:** `p_star` motes rising (2/s); a soft violet glow under it (a `p_glow` decal on the ground, or a
  `PointLight`).

### 3d. Ember Wolf
- **Fire Bite:** the Snap slashes tinted orange + `fb_fire_4x4` burst (3) + `p_ember` (10) on the target.
- **Burning player:**
  - `fb_fire_4x4` emitters (Loop, 12/s total) on attachments in the torso, arms and legs
  - `p_ember` (6/s), dark `fb_smoke_4x4` (2/s, tint `#3A3030`)
  - an orange `PointLight`
  - the `s_burning` overlay (pulsing with each burn tick)
- **Flame Dash:**
  - **Telegraph:** `p_ember` spiralling around the wolf + `fb_energy_4x4` (orange) flaring.
  - **Dash:** the `FlameStreak` mesh wraps the wolf and points along the dash, with a `Trail` using `tr_fire` and a
    `WindCone` at the start.
  - **Trail left behind:** `d_scorch` decals every 1.5 studs along the path, each with a small `fb_fire_4x4`
    emitter (Loop, 4 s), then `fb_smoke_4x4` as they go out.
- **Fireball Spit:**
  - **Charge:** a growing `fb_fire_4x4` + `p_glow` at the jaw, and `p_ember` spiralling in.
  - **Projectile:**
    - `Fireball` + `FireballShell` (scale 0.6), spinning in opposite directions, flying in an arc
    - a `Trail` with `tr_fire` + an `fb_smoke_4x4` trail emitter (dark grey, 20/s) + `p_ember` (15/s) + an orange
      `PointLight`
  - **Impact:**
    - `fb_explosion_4x4` (2, big) + a `FireRing` (1 → 4 radius, 0.4 s, then sinks and fades)
    - `d_scorch` + `Debris` rocks (4, thrown) + `p_ember` (25) + an orange `ShockwaveRing`
- **Ember Burst:**
  - **Telegraph:** the wolf glows (`AuraShell` orange) and `p_ember` rises fast.
  - **Burst:**
    - a `FireRing` that expands from radius 1 → 10 over 0.6 s along the ground (that's the ring players jump over)
    - `fb_fire_4x4` emitters riding its edge
    - a `ShockwaveRing` + `fb_explosion_4x4` at the centre
    - `d_scorch` under the wolf
    - an `s_burning` flash for nearby players
- **Ambient / enraged:** `fb_fire_4x4` on the back and paws (Loop), `p_ember` (5/s), an orange flicker
  `PointLight`, and small `d_scorch` footprints that fade in 3 s.

### 3e. Shadow Wolf
- **Vanish:**
  - `ShadowTendrils` rise from the wolf (scale 0.5 → 1.5) while twisting and fading
  - `fb_shadow_smoke_4x4` (6) + `p_wisp` (10)
  - the wolf fades out except its eyes (polish prompt 1c)
- **Ambush:**
  - **Telegraph:** two red `p_glow` + `p_sparkle` flare at the eye positions.
  - **Burst:** `fb_shadow_smoke_4x4` (8) at the launch point, and a Trail on the body with `tr_smoke` tinted black.
  - **Hit:** a red `ClawSlash` across the player + the `s_claws` overlay flash + `fb_impact_4x4` tinted red.
- **Shadow Clones:**
  - Two copies of the wolf mesh with `Material = ForceField`, colour `#2A0A1A`, no shadow.
  - They're born from `fb_shadow_smoke_4x4` and trail `p_wisp`.
  - Fakes burst into `fb_shadow_smoke_4x4` (6) on contact.
- **Darkness:**
  - the `s_shadow` overlay (fading in to about 0.35 transparency)
  - ground fog of `p_wisp` + `fb_shadow_smoke_4x4` (very transparent, low and slow) around the fight
  - a local `ColorCorrection` (brightness -0.15, saturation -0.3)
  - `ShadowTendrils` rising at 3–4 spots
- **Ambient:** `p_wisp` (4/s) off the back, and red eye light trails (a short Trail on each eye, red).

### 3f. Timber Wolf
- **Combos:** each Snap leaves a `SlashCrescent` afterimage (amber, fading in 0.25 s); the final lunge uses an
  amber `tr_energy` trail.
- **Frenzy (enraged):** an `AuraShell` (amber ForceField, `Transparency` 0.7) + `fb_energy_4x4` (amber, 8/s) + dust
  `fb_smoke_4x4` on every sharp turn.

### 3g. Golden Wolf
- **Always:** a `Trail` with `tr_stars` (gold) + `p_sparkle` (6/s) + `fb_coin_spin_4x4` (1/s, small).
- **Dodge:** a gold ForceField afterimage of the wolf mesh, fading in 0.3 s.
- **Gold Flash:** `GodRays` (gold, spinning, 0 → 6 in 0.1 s) + `StarBurst` + `p_sparkle` (30) + a white screen
  flash (reduced by the "Reduce flashing" setting); then the wolf streaks off with a `tr_stars` trail.
- **Every hit on it:** the coin shower (`Coin` meshes, or `fb_coin_spin_4x4` particles for cheap ones) +
  `p_sparkle`.

### 3h. Rewards, chests, status and UI
- **Coin reward fountain** (polish prompt 4b): pooled `Coin` meshes for the 3D burst (spinning, bouncing),
  `p_sparkle` glints, `p_pawprint` sparkles when they magnet to the player.
- **Chest drop:**
  - `LightPillar` (rarity colour, height 12–30 by rarity) + `GodRays` behind the chest
  - `p_sparkle` (rarity colour)
  - `ShockwaveRing` on landing
  - Epic+ also get a `ShockwaveDome`
- **Dazed player:** `DizzyStars` over the head.
- **Chilled:** `p_snowflake` around the player + a light `s_frost` overlay.
- **Spawn protection:** a player-sized `AuraShell` (white-gold ForceField, `Transparency` 0.75).
- **Low health:** `s_vignette` tinted red, pulsing.
- **Health bar emblems:** `i_timber`, `i_frost`, `i_celestial`, `i_shadow`, `i_ember`, `i_golden`.

---

## 4. Build it cleanly
- Put all of this in the `WolfVFX` client module from the polish prompt, with one function per effect, for example
  `WolfVFX.IceSpikes(origin, direction, count)` or `WolfVFX.Blink(fromCF, toCF, palette)`.
  - The server only fires a remote with the effect name and parameters.
  - Clients build the effect from pooled pieces.
- **Budgets:** max about 150 live particles per effect, about 400 on screen in total. Keep at most 6 pooled copies
  of each mesh, and on low graphics skip secondary layers. Clean everything up when the fight ends.
- Make an **admin "VFX test"** command that plays every effect in a row in the test arena, so I can review them all.

## 5. Test and report
Play every recipe in the test arena from different camera angles, at day and at night, on PC and on a phone-sized
screen. Check:
- [ ] Every mesh shows from all sides (no invisible back faces) and fades cleanly.
- [ ] The textures look soft-edged (SurfaceAppearance `AlphaMode = Transparency` set), not as black or white boxes.
- [ ] Flipbooks animate (the right grid layout) instead of showing the whole sheet.
- [ ] The Ice Armour sits on the Frost Wolf's back and moves with it.
- [ ] Spikes come up out of the floor and ground decals sit on the ground.
- [ ] No errors, and the frame rate stays smooth with 3 wolves fighting.

**Report:**
- the asset IDs you used, in one list
- any mesh that needed a different offset or size than listed here
- any effect you think still needs a better texture or mesh (I can make more)
