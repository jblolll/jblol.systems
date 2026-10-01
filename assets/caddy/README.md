# Caddy (utility cart)

Second vehicle next to the bicycle: a two-seat cart with an empty flat bed for stacking boxes.

## Files
- `caddy.fbx` - the model (red texture built in). Import with **Home > Import 3D**.
- `textures/caddy_texture_<paint>.png` - one texture per paint job (red, blue, green, yellow, pink,
  same colours as `VehicleUpgrades.Paints`). Every part uses the same texture, so a paint job is just
  setting `TextureID` on all six MeshParts.
- `caddy.blend` - Blender source.

## Parts
All in studs, relative to the `Body` MeshPart's position, in Roblox axes (front of the cart is -Z, like a VehicleSeat).

| Part | Position | Notes |
|---|---|---|
| `Body` | (0, 0, 0) | 10.75 long x 5.16 wide x 3.32 tall, ~8.2k triangles |
| `WheelFL` / `WheelFR` | (-2.15 / 2.15, -1.33, -3.58) | pivot is the axle centre, axle runs along X, radius 0.85 |
| `WheelRL` / `WheelRR` | (-2.15 / 2.15, -1.33, 3.02) | same |
| `SteeringWheel` | (-1.06, 1.24, -2.11) | pivot is the hub, can be turned for steering |

## Where things go
- Driver seat (top of the left cushion): (-1.10, 0.24, -0.23). Passenger: (1.10, 0.24, -0.23).
- Bed floor top: Y = -0.18. Inside the bed: 4.4 wide x 4.0 long.
- Box stack slots (centre of the first box, boxes are 2 x 1.5 x 1.5): (-1.15, 0.57, 1.92), (1.15, 0.57, 1.92),
  (-1.15, 0.57, 3.92), (1.15, 0.57, 3.92). That is a 2 x 2 grid of stacks, like the bike's `BasketSlot`.

## Notes
- If it imports at the wrong size, change **Scale Unit** in the importer until `Body` is about 5.16 studs wide.
- For physics, use simple invisible Parts for collisions and wheels (like the bike's wheel Parts + `HingeConstraint`)
  and set the MeshParts to `CanCollide = false`.
