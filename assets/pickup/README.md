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
| `NitroKit` | (0, -0.34, 3.95) | nitro upgrade: roll bar, two NITRO bottles, boost pipes. Hide until bought |
| `NitroFlames` | (0, -2.17, 7.34) | boost flames. Hide normally, show only while boosting (Material Neon looks good) |

## Where things go
- Driver seat (top of the left cushion): (-1.10, -1.53, 0.18). Passenger: (1.10, -1.53, 0.18).
- Bed floor top: Y = -0.99. Inside the bed: 4.5 wide x 4.2 long.
- Box stack slots (centre of the first box): (-1.15, -0.24, 2.55), (1.15, -0.24, 2.55), (-1.15, -0.24, 4.70), (1.15, -0.24, 4.70).

## Suggested stats
Same capacity as the caddy (2 stacks at first, up to 4 x 3 boxes), but faster: about 38 studs/s base, up to 50 with upgrades
(the caddy is ~26 -> 34).

## Nitro upgrade
See `pickup_nitro_preview.png`. Nothing on the kit sits where the box stacks go.
- Boost pipe tips (where flames start): (-0.85, -2.17, 6.57) and (0.85, -2.17, 6.57). Put an Attachment there with a
  `ParticleEmitter` (orange/blue, short Lifetime) as well as, or instead of, the `NitroFlames` mesh.
- Suggested levels at Purr Autos:

| Level | Boost | Duration | Cooldown | Price |
|---|---|---|---|---|
| 1 | +40% speed | 2 s | 12 s | 2,500 |
| 2 | +40% speed | 3 s | 10 s | 4,000 |
| 3 | +50% speed | 4 s | 8 s | 6,500 |
