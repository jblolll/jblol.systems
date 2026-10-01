# Pickup truck

Next vehicle after the caddy: same box space (a 2 x 2 grid of stacks), but quicker, with an enclosed cab,
driver and passenger seats you can see through the windows, and big off-road wheels.

## Files
- `pickup.fbx` - the model (red texture built in). Import with **Home > Import 3D**.
- `pickup.blend` - Blender source.
- Textures: it uses the **same textures as the caddy**, `assets/caddy/textures/caddy_texture_<paint>.png`.
  Paint jobs work the same way: set `TextureID` on every MeshPart. (Those textures now also contain the window glass.)

## Parts
In studs, relative to the `Body` MeshPart, Roblox axes (front is -Z).

| Part | Position | Notes |
|---|---|---|
| `Body` | (0, 0, 0) | 12.8 long x 5.7 wide x 5.3 tall, ~8.1k triangles |
| `Windows` | (0, 1.11, -0.18) | set **Transparency 0.4** (and Material Glass) so the seats show |
| `SteeringWheel` | (-1.10, 0.04, -0.83) | pivot is the hub |
| `WheelFL` / `WheelFR` | (-2.25 / 2.25, -2.54, -3.70) | radius 1.05, axle along X |
| `WheelRL` / `WheelRR` | (-2.25 / 2.25, -2.54, 3.60) | same |

## Where things go
- Driver seat (top of the left cushion): (-1.10, -1.53, 0.18). Passenger: (1.10, -1.53, 0.18).
- Bed floor top: Y = -0.99. Inside the bed: 4.5 wide x 4.2 long.
- Box stack slots (centre of the first box): (-1.15, -0.24, 2.55), (1.15, -0.24, 2.55), (-1.15, -0.24, 4.70), (1.15, -0.24, 4.70).

## Suggested stats
Same capacity as the caddy (2 stacks at first, up to 4 x 3 boxes), but faster: about 38 studs/s base, up to 50 with upgrades
(the caddy is ~26 -> 34).
