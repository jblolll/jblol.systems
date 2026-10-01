# Delivery truck (car hauler)

Purr Autos semi truck with a flatbed trailer and a rear loading ramp, for delivering vehicles to factories.
The deck fits two caddies end to end (or a caddy plus bikes).

## Files
- `delivery_truck.fbx` - the model, texture built in. Import with **Home > Import 3D**.
- `truck_texture.png` - the texture (every part uses it).
- `delivery_truck.blend` - Blender source.

## Parts
All in studs, relative to the `Trailer` MeshPart's position, in Roblox axes (front of the truck is -Z).

| Part | Notes |
|---|---|
| `Cab` | the tractor, at (0, 1.58, -14.51). 6.3 wide x 12.75 long x 8.7 tall |
| `Trailer` | at (0, 0, 0). 7.1 wide x 22.9 long. Deck top is Y = -0.10, usable deck 6.6 x 22.2 |
| `Ramp` | hinge line at (0, -0.22, 11.33), runs along X. Modelled **lowered** (26 degrees, end on the ground) |
| `WheelFL/FR`, `WheelR1L/R1R`, `WheelR2L/R2R` | cab wheels, radius 1.3, pivot at the axle centre |
| `TrailerWheel1L/1R`, `TrailerWheel2L/2R` | trailer wheels, radius 1.2, pivot at the axle centre |

## Ramp
To raise it for driving, rotate it -116 degrees about the X axis through the hinge, so it stands up like a tailgate:
`ramp.CFrame = hinge * CFrame.Angles(math.rad(-116), 0, 0) * hinge:Inverse() * ramp.CFrame`
where `hinge = trailer.CFrame * CFrame.new(0, -0.22, 11.33)`. Rotating it back by +116 lowers it again.

## Notes
- If it imports at the wrong size, change **Scale Unit** in the importer until `Trailer` is about 7.1 studs wide.
- For a scripted delivery, anchor everything and move the whole model with `PivotTo`/tweens; spin the wheels for show.
