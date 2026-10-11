# Scooter (starter vehicle)

A chunky cartoon kick scooter in the same style as the caddy and pickup: a paw-print deck, cream pin-stripe, big knobby
wheels with paw hubs, a little gold bell and a headlight. The **handlebar steers** (the whole front end turns on a
raked head tube, like a real scooter) and both **wheels are separate parts** so they can spin. It has the **same 5
paint jobs** as the caddy and pickup (red, blue, green, yellow, pink) and no upgrades, only colour.

## Files
- `Scooter.fbx`: the model, 5 MeshParts, red texture built in. Import with **Home > Import 3D**.
- `textures/scooter_<paint>.png`: one 1024 px texture per paint. **All 5 parts share the same UVs**, so a paint job is
  just setting `TextureID` on every MeshPart.
- `scooter.blend`: Blender source, with all 5 textures packed.
- `scooter_paints.png`: the 5 paints. `scooter_steering.png`: the handlebar straight and turned 28° each way.
  `scooter_rider_pose.png`: a blocky rider standing on it (hands on the grips, and carrying a box).
  `scooter_roblox_check.png`: renders with back faces hidden, the way Roblox draws them (no see-through spots).
- `specs.json`: every number below in machine-readable form.

## Parts
Roblox axes (Y up, **front is -Z**), in studs, relative to the `Body` MeshPart's centre. About 13.9k triangles in total.

| Part | Size (X × Y × Z) | Position from `Body` | Triangles | Notes |
|---|---|---|---|---|
| `Body` | 1.59 × 2.28 × 5.34 | (0, 0, 0) | 4,770 | deck with grip tape, head tube, rear fork and fender, brake reflector, kickstand |
| `Steering` | 2.73 × 3.32 × 1.98 | (0, 0.677, -2.712) | 4,604 | fork, front fender, stem, handlebar, grips, bell, headlight housing. **Turns for steering** |
| `Headlight` | 0.35 × 0.35 × 0.07 | (0, 1.373, -2.578) | 288 | the lens, welded to `Steering`. Make it Neon and add a light |
| `WheelF` | 0.45 × 1.54 × 1.55 | (0, -0.843, -2.741) | 2,104 | **pivot = axle centre**, axle along X, radius 0.75 |
| `WheelR` | 0.45 × 1.54 × 1.55 | (0, -0.843, 1.709) | 2,104 | same |

Overall: about 2.7 studs wide (handlebar), 3.8 tall, 6.2 long.

## Steering
The handlebar assembly turns around the head-tube axis, which is tilted back by 14°:
- **Axis point:** (0, 0.257, -2.361) from `Body` (bottom of the head tube)
- **Axis direction (up):** (0, 0.9703, 0.2419)
- `Steering`, `Headlight` and `WheelF` all turn together around this axis. `WheelF` also spins around its own axle.
- The steering angle is up to about ±28°.

Wheel spin, rolling forward (toward -Z): rotate each wheel by **-speed / 0.75** rad per second around its local X axis.

## Rider (a standard R15 character, standing)
Positions from `Body`, in Roblox axes:

| Point | Position |
|---|---|
| Deck top (sole level) | Y = -0.389 |
| Front foot (left) | (-0.38, -0.393, -0.991) |
| Back foot (right) | (0.38, -0.393, 0.009) |
| Left grip centre | (-1.03, 2.007, -1.926) |
| Right grip centre | (1.03, 2.007, -1.926) |
| Bell | (0.42, 2.107, -1.926) |
| Handlebar top (clearance for carried boxes) | box bottoms above Y = 2.4 |

The feet are staggered, with the left foot forward, and the knees slightly bent. The deck is 1.6 wide and 2.5 long. The
grips are at about waist height, so the arms are slightly bent.

## Notes
- If it imports at the wrong size, change **Scale Unit** in the importer until the deck is about 1.6 studs wide.
- For physics use simple invisible parts (like the bike's wheel parts) and set the MeshParts to `CanCollide = false`.
- `docs/scooter_prompt.md` explains how to set up the riding, steering, animation, paint and effects.
