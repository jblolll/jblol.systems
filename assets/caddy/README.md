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
| `TowHitch` | (0, -1.09, 5.24) | tow hitch upgrade: receiver + chrome ball under the rear bumper. Hide it until the upgrade is bought |
| `Canopy` | (0, 2.35, -0.78) | canopy roof upgrade: striped awning on 4 chrome posts. Hide until bought |
| `TowBar` | (0, -0.77, 7.32) | the bar that tows the bike. Only shown while a bike is hitched |
| `CargoCage` | (0, 2.40, 3.09) | cargo cage upgrade: steel frame + wire grid over the bed. Hide until bought |
| `CageGate` | (-0.015, 2.37, 5.24) | the cage's rear gate with padlock and "NO DOGS!" sign. Hide until bought |

## Where things go
- Driver seat (top of the left cushion): (-1.10, 0.24, -0.23). Passenger: (1.10, 0.24, -0.23).
- Bed floor top: Y = -0.18. Inside the bed: 4.4 wide x 4.0 long.
- Box stack slots (centre of the first box, boxes are 2 x 1.5 x 1.5): (-1.15, 0.57, 1.92), (1.15, 0.57, 1.92),
  (-1.15, 0.57, 3.92), (1.15, 0.57, 3.92). That is a 2 x 2 grid of stacks, like the bike's `BasketSlot`.

## Notes
- If it imports at the wrong size, change **Scale Unit** in the importer until `Body` is about 5.16 studs wide.
- For physics, use simple invisible Parts for collisions and wheels (like the bike's wheel Parts + `HingeConstraint`)
  and set the MeshParts to `CanCollide = false`.

## Tow hitch upgrade (towing the bike)
See `caddy_tow_hitch_preview.png`. The bike rolls on its own wheels behind the caddy, facing the same way:

- **Hitch ball centre:** (0, -0.95, 5.75) from `Body`. The bar's coupler sits on this point.
- **Bike clamp point:** (0, -0.80, 8.97) from `Body`. This is where the bike's front axle goes. The bar's yoke grips
  both sides of the front fork there.
- **Bike end:** use the bike's `Drive.FrontWheelAxle` attachment, which is on the seat, not on the wheel. The wheel spins,
  so clamping to it would spin the bar too. Weld `TowBar` to `bike.Drive` so the clamp point lands on `FrontWheelAxle`.
- **Caddy end:** a `BallSocketConstraint` between an attachment at the ball (on `TowHitch`) and one at the same point
  on `TowBar`. Use limits like the bike wagon (`UpperAngle` 35, twist limits on), so the bike swings behind
  in turns but can't flip over.
- Add `NoCollisionConstraint`s between the bike and the caddy, unanchor the bike and set its network owner to the
  driver (same as `WagonService.attach`).

## Canopy roof upgrade
See `caddy_canopy_preview.png`. The stripes and the scalloped edge use the paint colour from the texture, so the
canopy always matches the caddy: set the same `TextureID` on `Canopy` as on the other parts. The roof underside is
6.3 studs above the ground, which clears a seated character's head, and the rear posts continue the cargo rail posts
so the bed and stacked boxes are untouched.

## Cargo cage upgrade (keeps the dogs out)
See `caddy_cargo_cage_preview.png`. A dark steel frame with a white wire grid that clamps onto the bed rails and
covers the sides, front and top of the bed. The back is a lockable gate with a brass padlock and a "NO DOGS!" sign.

- **Fits full stacks:** the inside is 6.6 studs from the ground, so 3-high box stacks (`MaxLevel`) fit.
- **Fits with the canopy:** the front of the cage roof slopes down under the canopy's back edge, so both upgrades can
  be on at the same time.
- **Paint:** both parts use the same texture as the rest of the caddy. Set the same `TextureID` on them and they match
  every paint job. The frame and wires are neutral steel colours on every paint.
- **The gate opens:** `CageGate` is its own part so the player can open it to load boxes. Its hinge is a vertical axis at
  (-2.23, ·, 5.15) from `Body`, which is (-2.215, 0, -0.087) from the `CageGate` centre. To swing it open (outward,
  towards the back), rotate it around that axis, using a `HingeConstraint` or a tween of
  `gate.CFrame = hingeCF * CFrame.Angles(0, -angle, 0) * hingeCF:Inverse() * closedCF`.
- **Gameplay idea:** while the cage is on and the gate is shut, dogs can't take pastries from the caddy. Have them sniff
  around and give up, or only let them steal while the gate is open.
- **Size:** CargoCage is about 4,400 triangles and CageGate about 1,600.
- **Texture change:** the 5 caddy textures now have the sign artwork in a spot that was empty before. Nothing else
  changed, so re-upload them and keep using them for every part.
