# Scooter (starter vehicle)

A regular **kick scooter** in the style of a Razor A5:
- a long, thin, low deck with black grip tape
- small wheels with 5-spoke hubs
- a thin aluminium stem with a quick-release collar
- a T-bar with foam grips and a little bell
- a slim neck from the deck up to the head tube
- a rear fender that works as the foot brake

No engine, no headlight, no big fenders. **Every piece is physically connected.** The build script checks this
automatically: every piece of every part must touch the rest of its part, and the parts must touch each other.

The **handlebar steers** (the fork, stem and bar turn together on a tilted head tube, like a real scooter), and both
**wheels are separate parts** so they can spin. It has the **same 5 paint jobs** as the caddy and pickup (red,
blue, green, yellow, pink) and no upgrades, only colour.

## Files
- `Scooter.fbx`: the model, 4 MeshParts, with the red texture built in. Import it with **Home > Import 3D**.
- `textures/scooter_<paint>.png`: one 1024 px texture per paint. **All 4 parts share the same UVs**, so a paint
  job is just setting `TextureID` on every MeshPart.
- `scooter.blend`: the Blender source, with all 5 textures packed.
- Previews:

  | File | Shows |
  |---|---|
  | `scooter_paints.png` | the 5 paints |
  | `scooter_details.png` | the front, back, fender brake, fork and wheel, T-bar and bell, and a top view while steering |
  | `scooter_steering.png` | the handlebar straight and turned 28° each way |
  | `scooter_rider_pose.png` | a blocky R15-sized rider on the deck, hands on the grips and carrying a box |
  | `scooter_roblox_check.png` | renders with back faces hidden, the way Roblox draws them (no see-through spots) |

- `specs.json`: every number below in machine-readable form.

## Parts
Roblox axes (Y up, **front is -Z**), in studs, relative to the centre of the `Body` MeshPart. About 12.3k triangles
in total.

| Part | Size (X × Y × Z) | Position from `Body` | Triangles | Notes |
|---|---|---|---|---|
| `Body` | 1.15 × 1.51 × 4.78 | (0, 0, 0) | 2,878 | deck and grip tape, neck, head tube, rear dropouts, fender brake, kickstand |
| `Steering` | 2.50 × 3.18 × 1.44 | (0, 0.878, -1.948) | 4,024 | headset cups, fork crown and fork, stem, collar, T-bar, grips, bell. **Turns for steering** |
| `WheelF` | 0.40 × 0.84 × 0.84 | (0, -0.625, -2.586) | 2,700 | **pivot = axle centre**, axle along X, radius 0.42 |
| `WheelR` | 0.40 × 0.84 × 0.84 | (0, -0.625, 1.864) | 2,700 | same |

Overall: about 2.5 studs wide (handlebar), 3.4 tall, and 5.4 long. The deck is 1.15 wide and 2.8 long.

## Steering
The handlebar assembly turns around the head-tube axis, which is tilted back by 20°:
- **Axis point:** (0, -0.625, -2.486) from `Body` (the axis at axle height)
- **Axis direction (up):** (0, 0.9397, 0.342)
- `Steering` and `WheelF` turn together around this axis. `WheelF` also spins around its own axle.
- The steering angle is up to about ±28°. There's clearance for it at full lock.

Wheel spin, rolling forward (toward -Z): rotate each wheel by **-speed / 0.42** rad per second around its local X
axis.

## Rider (a standard R15 character, standing)
Positions from `Body`, in Roblox axes:

| Point | Position |
|---|---|
| Deck top (sole level) | Y = -0.400 |
| Front foot (left) | (-0.16, -0.400, -0.486) |
| Back foot (right) | (0.16, -0.400, 0.714) |
| Left grip centre | (-0.91, 2.255, -1.438) |
| Right grip centre | (0.91, 2.255, -1.438) |
| Bell | (0.40, 2.385, -1.438) |
| Top of the fender brake (where the back foot stomps) | (0, -0.115, 1.864) |
| Carried boxes clear the bar and bell | box bottoms above Y = 2.605 |

The feet stand one behind the other, the left foot forward, on the narrow deck. The knees are slightly bent and the
grips are at about waist height.

## Notes
- If it imports at the wrong size, change **Scale Unit** in the importer until the deck is about 1.15 studs wide.
- For physics use simple invisible parts (like the bike's wheel parts) and set the MeshParts to `CanCollide = false`.
- `docs/scooter_prompt.md` explains how to set up the riding, steering, animation, paint and effects.
