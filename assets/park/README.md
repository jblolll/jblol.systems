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
All five share one texture, `textures/cat_toys.png`, and each is one MeshPart:

| File | Toy | Size (studs) | Triangles |
|---|---|---|---|
| `Toy_YarnBall.fbx` | pink yarn ball with a loose strand | 1.0 × 0.8 × 0.6 (ball diameter 0.6) | 960 |
| `Toy_ToyMouse.fbx` | grey felt mouse: pink ears, nose, whiskers, string tail | 0.7 × 1.0 × 0.4 | 3.1k |
| `Toy_JingleBall.fbx` | rainbow ball with stars and a little gold bell | 0.44 × 0.44 × 0.5 | 820 |
| `Toy_CatnipFish.fbx` | orange plush fish with scales, fins and googly eyes, lying on its side | 0.4 × 1.0 × 0.26 | ~0.9k |
| `Toy_FeatherWand.fbx` | wooden wand lying on the ground, with a string, gold bell and purple feathers | 2.7 × 1.0 × 0.1 | 580 |

Every mesh is a closed, outward-facing solid, so there are no see-through faces in Roblox.
Previews: `butterflies_preview.png`, `toys_preview.png` (shown next to the dog for scale) and `toys_closeup.png`.
