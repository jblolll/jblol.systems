# Dog pet

A cute puppy built to match the cat's style: a big round head, painted eyes and a soft, chunky body. It is one skinned
mesh with a full skeleton, ready for the Roblox Animation Editor.

| | Dog | Cat (for comparison) |
|---|---|---|
| Size (W × L × H, studs) | 1.23 × 2.78 × 2.39 | 1.26 × 3.26 × 2.42 |
| Triangles | 10,000 | |
| Bone influences per vertex | max 4 (the Roblox limit) | |

## Files
| File | Use |
|---|---|
| `Dog.fbx` | **For hand animation.** Paws are children of the legs, so moving a leg carries its paw. |
| `Dog_CatGait.fbx` | **For your existing `CatGait` / `PetCats` code.** Same hierarchy as the cat: the paws (`*.003`/`*.004`) hang off `spine.014`, so the script can plant them with IK. |
| `textures/dog_golden.png` | Golden Retriever: gold with a cream muzzle, chest and socks (embedded in the FBX by default) |
| `textures/dog_dalmatian.png` | Dalmatian: white with black spots and black ears |
| `textures/dog_beagle.png` | Beagle: tan head, black saddle, white blaze, chest, legs and tail tip |
| `dog.blend` | Source file with the rig and all 3 textures packed in |

All 3 textures share the same UVs. Upload them once, then swap the MeshPart's `TextureID` to change the coat.

## Import into Studio
1. **Avatar tab → Import 3D** (or the 3D Importer) and choose `Dog.fbx`.
2. Set the rig type to **custom/none** (not R15), keep "Import as model", and import.
3. You get a Model containing a `RootPart` Part, the `Dog` MeshPart and the Bones. That's the same layout as `Cat Walk Rig`.
4. Add an `AnimationController` with an `Animator` (copy them from the cat rig) and anchor `RootPart`. The
   **Animation Editor** will then open it, and every bone can be posed and keyframed.

## Skeleton
The names and hierarchy are copied from the cat, so the cat's scripts and bone names carry over:

```
RootPart                         root (not skinned)
└ spine.014                      ground control (not skinned)
  ├ spine.004  hips / body ── spine.010 chest ── spine.011 shoulders ── spine.012 neck ── spine.013 HEAD
  │   │                                            │                                       ├ ear.L ── ear.L.001
  │   │                                            │                                       ├ ear.R ── ear.R.001
  │   │                                            │                                       └ hatpoint  (hat anchor)
  │   │                                            ├ front_thigh.L ── .001 ── .002 ── .003 paw ── .004 toes
  │   │                                            └ front_thigh.R ── .001 ── .002 ── .003 paw ── .004 toes
  │   ├ spine.003 tail base ── spine.005 ── .006 ── .007 ── .008 ── .009 tail tip
  │   ├ thigh.L ── .001 ── .002 ── .003 paw ── .004 toes
  │   └ thigh.R ── .001 ── .002 ── .003 paw ── .004 toes
```
In `Dog_CatGait.fbx` the four `.003` paw bones are children of `spine.014` instead, exactly like the cat.

**New compared to the cat:**
- 2-bone **floppy ears** on each side, for flaps, perks and head shakes.
- `hatpoint` is a bone on top of the head. `Bone` is a type of `Attachment`, so
  `RootPart:FindFirstChild("hatpoint", true)` in `PetCats` still finds it.

**Bone axes:** every bone's X axis points to the dog's right. So rotating a bone around its X axis is the "nod" or
"bend" direction for the legs, neck, head and tail, and rotating around Z is "side to side" (tail wags, head tilts).

## Using it with the cat code
`PetCats` and `CatGait` use the cat's bone names, which the dog shares. The code refers to the mesh as `model.Cat`, so
either rename the dog's MeshPart to `Cat` in the dog model, or change those lines to look up the mesh by type.
Use `Dog_CatGait.fbx` for this. The dog is a bit shorter and its legs are a bit shorter than the cat's. CatGait reads the
bone positions, so the walk should adapt, but test it in Studio.
