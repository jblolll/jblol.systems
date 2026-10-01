# Mystery crates (HD)

16 pixel-art "?" crates in the layout of the reference picture (top-left to bottom-right):
Lava, Galaxy, Ice, Toxic / Redstone, Rainbow, Emerald, Void / Wood, Stone, Gold, Glitch / Lime, Diamond, Amethyst, Celestial.

Each crate is a 2 x 2 x 2 stud cube made of **two parts**:

| Part | What it is |
|---|---|
| `Body` | the crate, with bevelled metal frames, rivets and (on the gem and magic crates) faceted gems on every corner |
| `Glyph` | the raised 3D "?" on all 6 sides. It is its own part so you can make it glow |

## Tiers

| Tier | Crates | Look |
|---|---|---|
| Basic | Wood, Stone, Lime | matte, rivets, no gems |
| Gem | Ice, Redstone, Emerald, Gold, Diamond, Amethyst | glossy panels, metallic frames, corner gems |
| Magic | Lava, Galaxy, Toxic, Rainbow, Void, Glitch, Celestial | chrome frames with a glowing inlay, corner gems, **glowing "?"** |

## Making them shiny in Studio (important)

`TextureID` alone gives you only the colours. To get the shine, add a **SurfaceAppearance** inside **both** `Body` and `Glyph`.
Upload the 4 images from `textures/` (Asset Manager > Bulk Import) and set:

| SurfaceAppearance property | File |
|---|---|
| ColorMap | `crate_<name>.png` |
| NormalMap | `crate_<name>_normal.png` |
| RoughnessMap | `crate_<name>_roughness.png` |
| MetalnessMap | `crate_<name>_metalness.png` |

The normal map makes the bevels, rivets, bricks and gems catch the light. The roughness and metalness maps make the frames
reflect like real metal and the panels look glossy. The game's lighting needs **Lighting.Technology = Future** (or
ShadowMap) and an atmosphere or skybox, so the metal has something to reflect.

## The glowing "?" (magic crates)

On the magic crates, set the `Glyph` part to **Material = Neon**, remove its SurfaceAppearance and set its Color:

| Crate | Glyph Color (RGB) |
|---|---|
| Lava | 255, 110, 50 |
| Galaxy | 220, 190, 255 |
| Toxic | 140, 255, 70 |
| Rainbow | 255, 220, 250 (or cycle the hue in a script) |
| Void | 190, 110, 255 |
| Glitch | 255, 255, 255 |
| Celestial | 255, 225, 120 |

For extra sparkle, add these to `Body`:
- A **PointLight** with the same colour, Brightness 1.5, Range 8.
- A **ParticleEmitter** with Rate 4, Lifetime 1 to 1.5, Speed 0.5, Size 0.15 to 0 and LightEmission 1. Use the colour above
  (Galaxy and Celestial: Texture = a star; Lava: Acceleration 0, 2, 0 for rising embers).

## Files
- `fbx/Crate_<Name>.fbx`: one crate per file, colour texture built in. Import with **Home > Import 3D** and keep the
  parts grouped as a Model.
- `textures/`: 64 maps (colour, normal, roughness and metalness for each crate), 1024 x 1024.
- Every crate uses the same UV layout, so any crate can swap to any texture set.
- Triangles: Body 252 (basic) or 828 (with gems), Glyph 1452.
- `crates_preview.png` and the `closeup_*.png` images are Blender renders with all 4 maps and the glow on.
