# Wolf (pastry thief)

A scary but stylized wolf that matches the dog and cat style: angry slanted glowing eyes with slit pupils, a heavy
scowling brow, a long wedge muzzle, fangs that show over the lip and claws. **The mouth really opens**: the lower jaw is
a separate lip with a painted palate, tongue and 30 teeth inside.

**Fur:** sculpted as layered rows of long, pointed fur clumps that overlap like real fur instead of spikes. They form a
big neck mane from the cheeks and behind the ears down to the withers and chest, a bushy tail, elbow tufts and fluffy
"trousers" on the back legs. The clumps are part of the body surface, so there are no floating pieces. The texture
adds strands that follow the fur direction, lighter clump tips and darker gaps between clumps.

**Teeth and claws are rooted:** each tooth starts inside the gum and each claw inside the paw (placed by casting onto
the real surface and sinking the root in), so there are no gaps at any jaw angle. Each one copies the skin weights of
the gum or paw it grows from, so it stays attached when the jaw opens or the toes bend.

| | Wolf | Dog | Player |
|---|---|---|---|
| Height (to ear tips) | 2.82 studs | 2.39 | ~5 |
| Length (nose to tail) | 3.63 | 2.78 | |
| Triangles | 16k | 10k | |

At most 4 bone influences per vertex (the Roblox limit). Every surface faces outward and is closed, checked with
Roblox-style rendering (back faces hidden), so there are no see-through spots, including inside the open mouth.

## Files
- `Wolf.fbx`: **for hand animation**. Paws are children of the legs.
- `Wolf_CatGait.fbx`: same model, but the paw bones hang off `spine.014` like the cat and dog, for the procedural
  `CatGait`/`DogGait` walk with planted paws.
- `textures/`, one per coat (same UVs, so swap `TextureID`):
  - `wolf_timber.png`: grey timber wolf, dark saddle, cream chest, **yellow** eyes
  - `wolf_shadow.png`: black shadow wolf, **red** eyes, a battle scar across one eye
  - `wolf_frost.png`: white frost wolf, blue-grey saddle, **icy cyan** eyes
  - **Rare coats** (`wolf_rare_preview.png`):
    - `wolf_ember.png`: charcoal wolf with glowing molten cracks, smouldering orange fur tips and ear tips, **orange** eyes
    - `wolf_celestial.png`: night-sky wolf, indigo fur with purple and teal nebula patches, stars, starlight-blue
      fur tips, **gold** eyes
    - `wolf_golden.png`: polished gold wolf with a bright sheen, white-gold fur tips, sparkles, **emerald** eyes

  Tip for the rare coats in Roblox: a texture can't glow by itself. To make the ember and celestial wolves pop, add a
  dim `PointLight` (orange or blue) to the head and a slow `ParticleEmitter` (embers, stars or gold sparkles).
- `wolf.blend`: the source file, rigged, with all 3 textures packed.
- `wolf_preview.png`: the 3 coats, a fur close-up and snarling faces. `wolf_mouth_and_roblox_check.png`: renders
  with back faces hidden (the way Roblox draws them), plus teeth and claw close-ups.

## Skeleton (same names as the dog and cat, plus jaw and ears)
```
RootPart └ spine.014
  ├ spine.004 hips ── spine.010 chest ── spine.011 shoulders ── spine.012 neck ── spine.013 HEAD
  │   │                                    │                                      ├ jaw          (opens the mouth)
  │   │                                    │                                      ├ ear.L ── ear.L.001
  │   │                                    │                                      └ ear.R ── ear.R.001
  │   │                                    ├ front_thigh.L/R ── .001 ── .002 ── .003 paw ── .004 toes
  │   ├ spine.003 ── spine.005 ── .006 ── .007 ── .008 ── .009   (bushy tail)
  │   └ thigh.L/R ── .001 ── .002 ── .003 paw ── .004 toes
```
- **Jaw:** rotate the `jaw` bone around its X axis by about **-30°** to fully open the mouth (-10° for a pant, -40° for
  a big snarl). If it closes into the skull instead, use a positive angle. The teeth and tongue move with it.
- **Ears:** `ear.*` pin back (snarl), perk forward (alert) or flick.
- **Tail:** 6 bones, enough for a low, menacing sway or tucked between the legs when it flees.
- **Legs:** every leg has hip/shoulder, knee/elbow, hock/wrist, paw and toes.
- **Bone axes:** every bone's X axis points to the wolf's right, so X rotation is bend or nod, and Z rotation is side
  to side.

## Import
Same as the dog: 3D Importer → custom rig → you get `RootPart`, the `Wolf` MeshPart and the Bones. Add an
AnimationController and Animator and anchor `RootPart`.

## Swapping it in for the dog raid
The wolf uses the dog's bone names, so the raid code, `DogGait` and animations carry over:
1. Point the raid's model at the wolf.
2. Swap the coat list for the 3 wolf textures.
3. Re-tune `DogGait` for the wolf's longer legs. It reads the bone positions, so it mostly adapts.
4. Use the jaw for biting boxes and snarling, and swap the bark and yelp sounds for growls, snarls and a yelp.
