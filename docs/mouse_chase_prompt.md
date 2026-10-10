# Prompt: city mice + stray cats chasing them (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. I've put a **mouse model in Workspace**. Build a "city mice" feature:
- cute mice wander around the city and, less often, Whisker Park
- **stray cats spot them, stalk them, chase them and pounce**
- the mice run for their lives through the grass, between buildings and across roads

It should feel alive and charming, like a front-page Roblox game: great animations, cute sounds, small polished
effects and no bugs. **Keep it cute and family-friendly: cats never hurt or eat the mice.** A caught mouse always
wriggles free and escapes.

---

## 0. Before you build anything
1. **Read the existing code first** and reuse its patterns, remotes, helpers and data:
   - the **stray cat system** (how city cats spawn, follow the sidewalks, are animated and despawn)
   - the stray dog/wolf city system
   - **Whisker Park** and its park cats
   - `ReplicatedStorage.Shared.CatGait` / `DogGait`, `ReplicatedStorage.Shared.Sfx`
   - the VFX pack module (`VFXAssets`/`WolfVFX`) if it's built
   - the admin panel

   Mice and the chase must plug into these systems, not run a parallel cat system.
2. **Inspect the mouse model in Workspace.**
   - It's a skinned MeshPart rigged with Bones, using the **same bone names as my cats**:
     - `RootPart` → `spine.014` → `spine.004` (hips) → `spine.010`/`.011` (chest) → `spine.012` (neck) → `spine.013` (head)
     - extra head bones:
       - `nose` (sniff twitch: small X rotations)
       - `whiskers.L`/`whiskers.R` (flicks: Z rotation, children of `nose`)
       - `ear.L`/`ear.L.001`, `ear.R`/`ear.R.001`
     - tail: `spine.003` → `spine.005`…`spine.009`
     - legs: `thigh.L/.R` and `front_thigh.L/.R` (+ `.001`–`.004`)
     - every bone's X axis points to the mouse's right (X rotation = bend or nod, Z rotation = side to side)
   - Tell me which version is in Workspace: `Mouse.fbx` (paws children of the legs) or `Mouse_CatGait.fbx` (paws
     hang off `spine.014`, for a procedural gait like `CatGait`).
   - **Size:** it's 0.84 studs tall and 2.26 long including the tail (the body alone is about 0.9 long). Compare it
     with my cats. The mouse's body should be about **a third of a cat's body length**. If it isn't, scale it with
     `Model:ScaleTo()` and tell me the scale you used.
3. **Random coat on every spawn.** The mouse has 3 textures with the same UVs, so changing the coat is just
   setting the MeshPart's `TextureID`:

   | Coat | File | Spawn weight |
   |---|---|---|
   | Brown field mouse | `mouse_brown.png` | 45 |
   | Grey house mouse | `mouse_grey.png` | 40 |
   | White mouse | `mouse_white.png` | 15 (rarer) |

   - I'll upload them and give you the asset IDs. **Ask me for them. Don't use placeholder IDs.**
   - Set the texture before parenting the mouse to Workspace, so it never shows the wrong coat for a frame.
   - Store the coat in a `Coat` attribute.
4. **Back up** anything you change (an `_OLD` copy, disabled).
5. Tell me your plan in a few lines, then build it. All numbers go in a `MouseConfig` module.

---

## 1. Spawning
- **How many:** about **3–4 mice in the city at once** (target 3, hard max 4). That includes the park. Never more.
- **Where:** the **city** most of the time, the **park less often**: about **75% city, 25% Whisker Park**.
- **Good spawn spots** (tag them with CollectionService, `MouseSpot`; place a set around the map):
  - grassy patches and lawns
  - the gaps and alleys between buildings
  - along building walls
  - behind bins, boxes and crates
  - under benches, by bushes and planters
  - in the park: near flower beds, the edges of paths, under benches

  **Never spawn** on sidewalks or roads.
- **Mouse holes:** add a few cute **mouse holes** at the bottom of building walls (a small dark arched opening, and
  a tiny doorway trim if it fits the style). Mice can **pop out of a hole** to spawn and **dive into a hole** to
  escape or leave. That's the nicest way to appear and disappear.
- **Spawning in:** spawn out of every player's view if possible; otherwise the mouse pops out of a hole or scurries
  out from behind a bush. **Never just pop into existence in plain sight.**
- **Leaving:**
  - Each mouse lives **6–10 minutes**, then wanders to the nearest hole or bush and disappears into it.
  - A mouse more than 250 studs from every player for 60 s is quietly removed.
  - Keep the count topped up to the target with a short random delay (20–60 s), so it never feels like a swap.
- **Only spawn** while at least one player is in the city or park area.

---

## 2. How mice wander (not on sidewalks)
Mice **don't follow the sidewalks** the way cats, dogs and wolves do. They roam their own little world:
- **Where they go:** grass, the edges of buildings (**mice love hugging walls**: prefer paths that run along walls),
  between buildings, under benches, around planters and bins.
- **Avoid by default:** sidewalks (crossing one quickly is fine) and roads (only cross while fleeing, see 3).
- **Pathfinding:** use `PathfindingService` with a small agent (`AgentRadius` 0.5, `AgentHeight` 1,
  `AgentCanJump = false`) and **costs**:
  - grass and dirt: low
  - sidewalk: high
  - road: very high (blocked when not fleeing)

  Use material costs and/or `PathfindingModifier` regions on sidewalks and roads (check how the map is built and
  pick what works).
- **Rhythm:** mice move in **short scurry bursts**: scurry 1–3 s at 5–7 studs/s, then stop for 1.5–5 s and do an
  idle action, then pick a new spot 6–20 studs away. Slow overall, but quick when moving.
- **Idle actions** (pick randomly, no repeat twice in a row):
  - **sniff** (nose twitching, whiskers flicking, head tilting)
  - **look around** (head turns left and right, ears swivel)
  - **rear up** on its hind legs to look around
  - **groom** (front paws rubbing its face)
  - **nibble a crumb** (hunched over, paws to mouth, quick small head bobs, tiny crumbs falling)
  - **wash its ears** (paws pull an ear down)
  - **sit and breathe** (fast tiny breathing)
- **Skittish around players:** if a player comes within **8 studs**, the mouse **freezes** (0.4 s, ears up), then
  does a quick dash 6–10 studs away and freezes again.
  - It doesn't fully flee from players unless they keep chasing.
  - The bat **passes through mice** with no effect. Mice can't be hurt.
- **Never** get stuck, slide, clip into walls or walk in mid-air. Add a stuck check (stuck 2 s → re-path; stuck
  6 s → go to the nearest hole/bush and despawn).

---

## 3. Stray cats chase mice (the main event)
Applies to the **city stray cats and the Whisker Park cats** (not player-owned cats unless I say so later).

### 3a. Cat states

| State | Behaviour |
|---|---|
| **Notice** | The cat can see a mouse: within **30 studs**, in a 140° view cone, with a clear line of sight (raycast). The cat **stops instantly**: ears snap forward, head locks onto the mouse, tail tip starts twitching. Hold 0.5–0.8 s. It makes a soft "chatter" (cats really chatter at prey). |
| **Stalk** | It **leaves the sidewalk** and creeps toward the mouse: body low, slow deliberate steps (4 studs/s), head level and locked on, tail low with the tip flicking. It stops dead if the mouse looks up, then keeps creeping. Until it's within **9–12 studs**, or the mouse notices. |
| **Chase** | Full sprint (22–24 studs/s) after the mouse, re-pathing every 0.25 s toward where the mouse is **going** (lead the target slightly). The cat follows the mouse's route: grass, between buildings, across roads. |
| **Pounce** | Within **4–6 studs**: a quick **butt wiggle** (hips sway side to side 2–3 times, 0.4–0.6 s; this is the iconic tell), then a **leap** in an arc to where the mouse will be, front paws reaching. |
| **Pounce result** | **Miss** (most of the time): the cat lands with its paws together on empty ground, skids, shakes its head, and goes back to Chase. **Catch** (about 25% of pounces, config): the cat lands with the mouse **pinned under its paws** for 1 s, with a cartoon dust puff, little stars and an indignant squeak; then the mouse **wriggles free** and zips away with a speed burst (no harm, ever). The cat sits up looking proud for 1 s, then may chase again if there's time left. |
| **Give up** | **After 60 seconds of chasing in total** (from Stalk), or if the mouse escapes into a hole, or it's lost for 5 s: the cat stops, sits, does a **"I meant to do that"** move (licks a paw, flicks its tail, looks away), then walks back to its normal route and routine. |
| **Cooldown** | The cat won't chase **any** mouse for **2 minutes** after giving up. |

- **One cat chases a mouse at a time.** A second cat may *watch* (Notice pose) but not join.
- A cat never chases a mouse into the factory or onto private plots (if those exist).
- Cats chasing must still avoid cars (if there's traffic) and must not trample players or clip through walls.

### 3b. How the mouse escapes
- **Noticing the cat:** when a cat notices it within **15 studs**, or starts chasing, the mouse:
  - does a **startle hop** (a tiny 0.4-stud jump, ears up, tail straight up) with a startled squeak
  - freezes for 0.25 s
  - **then runs**
- **Run speed:** **sprint at 18–20 studs/s** (a bit slower than the cat in a straight line), but it **turns much
  sharper**. The cat drifts wide on sharp turns (limit the cat's turn rate while sprinting), so zig-zags and corners
  are the mouse's advantage.
- **Escape routes** (scored each re-path, every 0.3 s): prefer paths **away from the cat**, through **grass**,
  **between buildings**, behind objects that break line of sight, and **across the road if needed**. Roads are
  allowed while fleeing: the mouse darts straight across, looking both ways if there's no immediate danger.
- **Shelter:** if a **mouse hole, bush or gap under a bench** is within about 25 studs and not behind the cat, the
  mouse heads for it.
  - **Reaching a hole:** it dives in (shrinks into the hole with a dust puff and a "pop") and is safe. The cat
    arrives, **sniffs the hole**, paws at it once, then gives up (a cute moment).
  - The mouse comes back out of the same or a nearby hole 15–40 s later.
- **Juke moves:** every 2–4 s while chased, there's a 40% chance of a sharp **juke** (a quick 60–100° turn), to make
  the chase fun to watch.
- **Stamina:** when the chase ends, the mouse stops somewhere hidden and **pants** (fast breathing, ears down)
  for 3 s, then goes back to normal wandering.
- **Balance target:** watched over many chases, about **1 in 4 chases ends in a "catch"** (which the mouse always
  escapes) and the rest end with the mouse in a hole or the cat giving up. Put the result counts in your report.

---

## 4. Animations (they must look really good)
Animate with the **Bones**, procedurally like `CatGait` (or authored `Animation`s if that fits the rig better).
Everything blends smoothly (0.1–0.2 s), with no sliding feet, snapping or T-poses. The feet must match the ground
speed.

**Mouse layers that always run:**
- **Breathing:** a tiny fast chest pulse (2.5 Hz idle, 5 Hz after running).
- **Nose sniff:** the `nose` bone twitches ±6° at 6–8 Hz in bursts, and `whiskers.L/R` flick a few degrees with it.
- **Ears:**

  | State | Ears |
  |---|---|
  | Calm | up and swivelling |
  | Alert | straight up |
  | Running | pinned back |
  | Random | small flicks |

- **Tail:** spring physics through its 6 bones, so it trails and whips naturally. Idle: a slow gentle curl and sway.
- **Head look-at:** it looks toward sounds, players and cats (clamped and smoothed).

**Mouse actions:**

| Animation | How it should look |
|---|---|
| Scurry | very quick small steps (high step frequency, short stride), body low with a small up-down bob and a slight side-to-side spine wave, tail trailing |
| Flee sprint | a bounding gallop: back legs push together, the body stretches and bunches, ears flat, tail straight out behind, small dust puffs from the feet |
| Sharp turn / juke | it leans hard into the turn, the tail swings wide, a tiny skid |
| Sniff | head forward and down, nose twitching fast, whiskers flicking |
| Look around | head turns left, then right, ears swivelling separately |
| Rear up | it sits back on its hind legs, body upright, front paws held to its chest, nose twitching, looking around |
| Groom | sitting up, front paws rub its face in small circles, head bobbing with them |
| Wash ears | a paw pulls one ear down and rubs it |
| Nibble | hunched, front paws to its mouth holding a crumb, quick small head bobs, tiny crumbs falling |
| Freeze | completely still except the breathing, ears up, eyes on the threat |
| Startle hop | a tiny jump straight up, legs splayed, tail shoots up, ears up |
| Caught wriggle | squashed under the cat's paws, legs and tail flailing, then it squirts out forward |
| Dive into hole | quick dash, the body stretches, then shrinks into the hole with a little tail flick last |
| Pant | ears down, fast breathing, sitting still |

**Cat chase animations** (add to the cat system):
- **Notice:** ears forward, head locked, pupils wide if the cat has pupils, tail tip twitching
- **Stalk:** a low crouch walk, shoulder blades rolling, slow steps, freezes mid-step
- **Butt wiggle:** hips sway left and right, back feet paddling
- **Pounce:** a leap arc, front paws reaching, body stretched
- **Land:** paws together, body squashes
- **Miss skid:** it slides and shakes its head
- **Sprint chase:** the existing gallop, sped up, ears forward
- **Proud sit:** sits tall, tail curled up
- **Sniff hole:** nose to the ground, paws at the hole
- **Give up ("I meant to do that"):** sits, licks a paw, flicks its tail, looks away

---

## 5. Sounds (cute, quiet, positional)
Find good sounds on the Creator Store that are public and usable, and check each one plays. Tell me every asset ID.
- All mouse sounds are **3D and quiet** (`RollOffMaxDistance` about 35 studs), with **random pitch ±10%**
  (mostly high, 1.1–1.3 playback speed) and 2–3 variants each, so they never sound repetitive.

**Mouse:**

| Sound | When |
|---|---|
| Soft squeaks | now and then while idle (every 6–15 s) |
| Tiny pitter-patter footsteps | a loop while scurrying, faster while fleeing |
| Sniff | short sniffs during sniff idles |
| Nibble crunch | a tiny crunch while nibbling |
| Startled squeak | a louder, sharp squeak when it spots a cat or a player gets close |
| Panicked squeaks | quick squeaks during the chase |
| Indignant squeak | when caught |
| Pop | diving into a hole |

**Cat:**

| Sound | When |
|---|---|
| Chatter (the clicking sound cats make at birds) | noticing a mouse |
| Soft paw thump | landing a pounce |
| Whoosh | the leap |
| Short annoyed "mrrp" / meow | giving up |
| Purr | the proud sit |

---

## 6. Effects (small, clean and cute)
If the VFX pack from my wolf prompts is set up, reuse its textures (`fb_smoke_4x4`, `p_leaf`, `p_star`,
`p_sparkle`, `p_debris_2x2`). Otherwise make simple versions. Keep everything **small** (the mouse is tiny).

| Moment | Effect |
|---|---|
| Fleeing / dashing | tiny beige dust puffs from the feet, 2–3 per stride (tint `fb_smoke` beige, very small) |
| Running through grass | little grass/leaf bits flicking up (`p_leaf` tinted grass green, tiny) |
| Startle hop | a tiny burst of 3 sparkles above its head (`p_sparkle`, white), **no text** |
| Pounce landing | a cartoon dust cloud (`fb_smoke`) |
| Catch | the dust cloud + 3 little `p_star`s circling over the cat's paws for 1 s |
| Nibbling | tiny crumbs falling (`p_debris_2x2`, very small) |
| Mouse hole dive / pop out | a small dust puff at the hole |
| Give up | a tiny "huff" puff from the cat's nose |

Effects only render for players within about 80 studs.

---

## 7. More touches that make it feel alive (please add)
1. **Mouse holes with personality:** a couple of holes get a tiny doormat or a crumb pile outside, and one has a
   little cheese wedge next to it.
2. **Cheese crumbs:** a few crumb spots around food stalls, bins and benches (and near the treat shop if there is
   one). Wandering mice like to go to them to nibble.
3. **Cats watching from afar:** a cat that sees a mouse but is on cooldown sits and watches it, tail twitching, then
   goes back to its routine.
4. **Players can watch the show:** the chase should be readable and fun from a distance. Cats and mice never run
   into players; they dodge around them.
5. **Rare white mouse moments:** the white mouse is rarer, so give it a faint sparkle (2 `p_sparkle` per second,
   very subtle) so players notice it.
6. **Day and night:** at night mice are a little more active (+1 to the target count, never more than 4 in the
   city) and stay closer to walls; by day they nap more often (curled up, tail wrapped around, slow breathing).
7. **Optional, ask me first:** a Collection Book entry for each mouse coat the player has seen, or a tiny coin
   reward for spotting a white mouse.

---

## 8. Performance and bug-proofing
- The **server** owns mouse and cat AI state, positions and pathing (the network owner is the server, so players
  can't fling them).
- **Clients** do the bone animation, sounds and effects, driven by replicated attributes (`MouseState`, `Speed`,
  `Target`).
- Run pathfinding at a low rate (re-path every 0.3–1 s, not every frame). Stop animating mice farther than 100
  studs from the camera.
- **Clean up** mice when they despawn, when players leave the area and on shutdown. No leftover sounds, effects or
  stuck cats in chase mode.
- A cat whose mouse despawns mid-chase goes straight to "give up". A mouse whose cat despawns calms down after 3 s.

---

## 9. Admin panel
Add these to my owner-only admin panel, with the same style and permission checks:

| Command | What it does |
|---|---|
| **Spawn mouse** | choose the coat; spawns near me |
| **Make nearest cat chase** | forces the nearest stray cat to notice and chase the nearest mouse |
| **Clear mice** | removes every mouse |
| **Mouse debug** | shows paths, states, cat sight cones and chase timers |

---

## 10. Test before you tell me it's done
- [ ] There are never more than 4 mice in the city and park together; about 3 out of 4 spawn in the city.
- [ ] Every spawn picks a random coat (brown/grey/white by weight), with no wrong-coat flash.
- [ ] Mice wander slowly in scurry-and-stop bursts with varied idle actions, hug walls, use grass and alleys, avoid
      sidewalks and roads, and never get stuck for 10+ minutes.
- [ ] A stray cat that sees a mouse goes through Notice → Stalk → Chase → butt-wiggle Pounce. The mouse startles,
      flees through grass, between buildings and across roads, jukes, and uses holes.
- [ ] Catches always end with the mouse wriggling free. No harm is ever shown.
- [ ] A cat stops chasing after at most **60 s**, does its give-up animation, goes back to its routine, and respects
      the 2-minute cooldown.
- [ ] All animations blend smoothly with no foot sliding; the sounds play quietly and positionally; the effects are
      small and clean.
- [ ] No errors in the output, and the frame rate stays smooth.

**Report:**
- what you built and changed, and what you backed up
- the scale you used for the mouse
- the asset IDs you used
- the chase result counts from testing
