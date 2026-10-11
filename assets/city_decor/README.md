# City decorations

23 cartoon props to make the city feel full and lived-in, plus everything the city mice need (holes, crumbs, cheese).
They're chunky and rounded with bright painted colours, matching the crates, chests, park toys and animals. Each prop
is **one MeshPart with one baked texture** (colour + soft shadows), so it looks finished with no lighting setup and
stays cheap to render.

- `fbx/<Name>.fbx`: import with the 3D Importer. The texture is embedded, and also in `textures/<Name>.png`.
- `previews/all_props.png`: every prop. `previews/street_showcase.png` and `street_closeup.png`: the set dressed
  in front of a building at real scale.
- Sizes are in studs (X × Y × Z, Y up) at scale 1. A player is about 5 studs tall.
- **Front** = -Z (LookVector).
- **Wall props** (`MouseHole_*`, `WindowFlowerBox`, `ShopAwning`): the back is flat and goes flush against the wall
  (their +Z side). The bottom of the mouse holes sits on the ground.

## Mouse stuff
| Prop | What it is | Size | Triangles |
|---|---|---|---|
| `MouseHole_Stone` | plain stone-arch mouse hole | 1.51 × 1.44 × 0.34 | 2,344 |
| `MouseHole_Home` | mouse home: wooden arch frame, open red door, doormat, lantern, "MOUSE HOUSE" sign and crumbs | 1.48 × 1.52 × 0.88 | 1,988 |
| `MouseHole_Cheese` | cracked-plaster mouse hole with a cheese wedge and crumbs | 1.22 × 1.17 × 0.73 | 2,318 |
| `Crumbs` | pile of bread crumbs (a mouse food spot) | 0.69 × 0.13 × 0.5 | 280 |
| `Cheese` | cheese wedge with real holes | 0.75 × 0.42 × 0.8 | 959 |
| `CheeseBits` | small cheese nibbles and crumbs | 0.65 × 0.14 × 0.49 | 1,040 |

## Street furniture
| Prop | What it is | Size | Triangles |
|---|---|---|---|
| `TrashCan` | galvanised metal trash can with a lid, handles and a green paw badge | 1.8 × 3.04 × 1.8 | 4,028 |
| `TrashBags` | pile of 3 tied trash bags | 2.3 × 1.17 × 1.56 | 1,680 |
| `FireHydrant` | red fire hydrant with gold caps | 1.18 × 1.9 × 1.02 | 3,976 |
| `Mailbox` | blue mailbox on legs with a "MAIL" label | 1.5 × 3.06 × 1.54 | 2,544 |
| `StreetLamp` | classic street lamp. **`LampGlass` is a separate part:** make it Neon and add a PointLight | 1.12 × 10.52 × 1.12 | 2,496 |
| `SignPost` | wooden signpost with 3 arrows: WHISKER PARK, PURR AUTOS, BAKERY (they read correctly from both sides) | 6.68 × 6.84 × 2.52 | 880 |

## Greenery
| Prop | What it is | Size | Triangles |
|---|---|---|---|
| `FlowerPlanter` | long wooden planter full of mixed flowers (daisies, tulips, pom flowers) | 3.7 × 1.81 × 1.3 | 6,180 |
| `FlowerPot` | terracotta pot of flowers | 1.44 × 1.72 × 1.44 | 2,584 |
| `Topiary` | round topiary bush in a white planter box with gold corner knobs | 1.66 × 3.1 × 1.68 | 2,200 |
| `WindowFlowerBox` | window box with flowers and trailing ivy; hang it under a window | 3.1 × 1.73 × 0.94 | 4,196 |

## Lively extras
| Prop | What it is | Size | Triangles |
|---|---|---|---|
| `CrateStack` | stack of 3 wooden crates with a "Purr Autos" stamp | 3.05 × 2.8 × 1.71 | 4,812 |
| `Barrel` | wooden barrel with iron bands | 1.44 × 1.8 × 1.44 | 2,240 |
| `CardboardBoxes` | pile of 3 taped cardboard boxes with the "Purr Autos" stamp | 2.81 × 1.91 × 1.54 | 2,280 |
| `CafeSet` | café table with a red-and-cream striped umbrella and 2 bistro chairs | 5.44 × 6.72 × 5.44 | 2,932 |
| `ShopAwning` | striped shop awning with a scalloped edge, 6 wide; mount it over a door or window | 6.2 × 1.75 × 2.43 | 2,596 |
| `Bunting` | 16-stud string of colourful flags; hang it between buildings or lamp posts | 16.18 × 2.08 × 0.05 | 1,960 |
| `CatBowls` | food and water bowls for the strays, on a little mat | 2.0 × 0.36 × 1.1 | 1,732 |

Every prop is under 7k triangles, and most are 1–4k.

`docs/city_decor_prompt.md` tells Studio Claude how to import, set up and place them around the city.
