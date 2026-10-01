# Pickup truck (American full-size, regular cab)

Big two-door pickup with two seats. The bed takes a 2 x 3 grid of box stacks: **6 boxes** to start, **12** when upgraded
to stack two high. The nitro booster is an upgrade: the truck ships without it (`NitroKit` hidden).

## Files
- `pickup.fbx` - the model (red texture built in). Import with **Home > Import 3D**.
- `pickup.blend` - Blender source.
- Textures: the **same 5 textures as the caddy**, `assets/caddy/textures/caddy_texture_<paint>.png`.
  A paint job is setting `TextureID` on every MeshPart.

## Parts
In studs, relative to the `Body` MeshPart, Roblox axes (front is -Z).

| Part | Position | Notes |
|---|---|---|
| `Body` | (0, 0, 0) | 15.6 long x 6.5 wide x 5.8 tall, ~10k triangles |
| `Windows` | (0, 1.22, -0.26) | one sealed glass piece; set **Transparency 0.4**, Material Glass |
| `SteeringWheel` | (-1.25, 0.19, -1.11) | pivot is the hub |
| `WheelFL` / `WheelFR` | (-2.55 / 2.55, -2.77, -4.41) | radius 1.15, axle along X |
| `WheelRL` / `WheelRR` | (-2.55 / 2.55, -2.77, 4.19) | same |
| `NitroKit` | (0, 0.28, 4.62) | nitro upgrade: roll bar + NITRO bottles + boost pipes. **Hidden until bought** |
| `NitroFlames` | (0, -2.42, 8.71) | boost flames: hidden, shown only while boosting (Material Neon looks good) |

## Where things go
- Driver seat (top of the left cushion): (-1.25, -1.47, -0.16). Passenger: (1.25, -1.47, -0.16).
- Bed floor top: Y = -1.17.
- Box stack slots (centre of the first box), 2 across x 3 along:
  X = -1.2 / 1.2, Y = -0.42, Z = 2.44 / 4.24 / 6.04. Capacity 1 each = 6 boxes, capacity 2 = 12.
- Boost pipe tips (flames / particles start here): (-0.95, -2.42, 7.94) and (0.95, -2.42, 7.94).

## Suggested stats
Faster than the caddy: ~38 studs/s, up to 50 with upgrades. Nitro: +40-50% speed for 2-4 s, 12-8 s cooldown.
