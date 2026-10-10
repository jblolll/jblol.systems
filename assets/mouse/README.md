# Mouse (for cats to chase)

A small, cute cartoon mouse that matches the cat, dog and wolf style. It has big glossy eyes, big round cupped ears with
pink insides, blushing cheeks, a pink nose, two buck teeth, 3 whiskers per side, pink hands and feet, and a long
pink tail. Fully rigged and ready to animate.

| | Mouse |
|---|---|
| Size (whole model, tail included) | 0.70 wide × 0.84 tall × 2.26 long studs (the body alone is about 0.9 long) |
| Triangles | about 6.1k |
| Bones | 40 (max 4 influences per vertex, the Roblox limit) |

Every surface faces outward and is closed, checked with Roblox-style rendering (back faces hidden), so there are no
see-through spots (`mouse_roblox_check.png`).

## Files
- `Mouse.fbx`: **for hand animation**. Paws are children of the legs.
- `Mouse_CatGait.fbx`: same model, but the paw bones (`*.003`) hang off `spine.014` like the cat/dog/wolf, for a
  procedural gait with planted paws.
- `textures/`, 3 coats with the same UVs (swap `TextureID`):
  - `mouse_brown.png`: field mouse, warm brown with a cream belly
  - `mouse_grey.png`: house mouse, soft grey with a white belly
  - `mouse_white.png`: white mouse, all white with pink accents
- `mouse.blend`: the source file, rigged, with all 3 textures packed.
- `mouse_preview.png`: the 3 coats, face close-ups, and a running and a begging pose.

## Skeleton (same names as the cat/dog/wolf, plus nose and whiskers)
```
RootPart └ spine.014
  ├ spine.004 hips ── spine.010 chest ── spine.011 shoulders ── spine.012 neck ── spine.013 HEAD
  │   │                                    │                                      ├ nose ── whiskers.L / whiskers.R
  │   │                                    │                                      ├ ear.L ── ear.L.001
  │   │                                    │                                      └ ear.R ── ear.R.001
  │   │                                    ├ front_thigh.L/R ── .001 ── .002 ── .003 hand ── .004 fingers
  │   ├ spine.003 ── spine.005 ── .006 ── .007 ── .008 ── .009   (long tail)
  │   └ thigh.L/R ── .001 ── .002 ── .003 foot ── .004 toes
```
- **Nose:** small fast X rotations (±5–8°) make the cute sniffing twitch. The snout tip follows it.
- **Whiskers:** rotate `whiskers.L/R` around Z to flick them. They follow the nose.
- **Ears:** each ear has 2 bones: pin them back when running, perk them up when alert, flick them when idle.
- **Tail:** 6 bones. Use spring follow-through for a whippy tail.
- **Legs:** hip/shoulder, knee/elbow, ankle/wrist, foot/hand, toes.
- **Bone axes:** every bone's X axis points to the mouse's right, so X rotation is bend or nod, and Z rotation is side
  to side.

## Import
3D Importer → rig → you get `RootPart`, the `Mouse` MeshPart and the Bones. Add an AnimationController and
Animator and anchor `RootPart`. Scale it with `Model:ScaleTo()` if it needs to be bigger or smaller next to your
cats; the bones scale with it.
