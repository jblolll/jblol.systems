# Whisker Park props: butterflies and cat toys

## Butterflies
Three colourways with the same mesh: **Monarch** (orange), **Morpho** (blue, with eye spots) and **Kitty** (pink, with
white paw prints).
- `fbx/Butterfly_<Name>.fbx` has 3 parts: **`Body`**, **`WingR`** and **`WingL`**. The wings are separate so they can
  flap. About 3.7k triangles.
- Size: wingspan about 0.7 studs (right for the cat, which is about 1.3 wide). Body length about 0.38. It faces -Z
  (LookVector). The wings lie flat in the XZ plane.
- Positions, measured from part centres in Roblox axes:
  - `WingR` from `Body`: (0.178, -0.035, 0.021)
  - `WingL` from `Body`: (-0.178, -0.035, 0.021)
  - **Hinge** (the wing root, running front to back along Z):
    - `WingR`: (-0.160, 0, 0) from its centre
    - `WingL`: (0.160, 0, 0) from its centre
  - **Flap:** rotate each wing around its hinge's Z axis, by +angle for `WingR` and -angle for `WingL` (or the other
    way round; check in Studio). Use about 0° to 70°.
- Textures: `textures/butterfly_<name>.png`. Swap the colourway by changing `TextureID` on all 3 parts.

## Cat toys
All five share one texture, `textures/cat_toys.png`. Three are single MeshParts; the **yarn ball** and **feather wand** are split into parts so their strand, string and feathers can move:

| File | Toy | Size (studs) | Triangles |
|---|---|---|---|
| `Toy_YarnBall.fbx` | pink yarn ball with a loose strand | 1.0 × 0.8 × 0.6 (ball diameter 0.6) | 960 |
| `Toy_ToyMouse.fbx` | grey felt mouse: pink ears, nose, whiskers, string tail | 0.7 × 1.0 × 0.4 | 3.1k |
| `Toy_JingleBall.fbx` | rainbow ball with stars and a little gold bell | 0.44 × 0.44 × 0.5 | 820 |
| `Toy_CatnipFish.fbx` | orange plush fish with scales, fins and googly eyes, lying on its side | 0.4 × 1.0 × 0.26 | ~0.9k |
| `Toy_FeatherWand.fbx` | wooden wand lying on the ground, with a string, gold bell and purple feathers | 2.7 × 1.0 × 0.1 | 580 |

### Toys with moving parts
Positions are in Roblox axes, measured from part centres.

**`Toy_YarnBall`: `Ball` + `Strand`**
- `Strand` sits at (0.444, -0.246, 0.274) from `Ball`.
- The strand's **root pivot** (where it leaves the ball) is (-0.264, 0.031, -0.174) from the `Strand` centre. Rotate
  or wiggle it around that point to make it jiggle.

**`Toy_FeatherWand`: `Stick` + `String` + `Feathers`**
- `String` sits at (1.211, -0.008, -0.209) from `Stick`. Its pivot (where it ties to the stick tip) is at
  (-0.201, 0.008, 0.209) from the `String` centre.
- `Feathers` (including the gold bell) sit at (1.41, 0.02, -0.70) from `Stick`. Their pivot (the knot and bell) is at
  (0, 0, 0.25) from the `Feathers` centre. Swing and flick them around it; the string follows.

Every mesh is a closed, outward-facing solid, so there are no see-through faces in Roblox.
Previews: `butterflies_preview.png`, `toys_preview.png` (shown next to the dog for scale) and `toys_closeup.png`.
