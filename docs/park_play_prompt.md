# Prompt: butterflies and cat toys at Whisker Park (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. I'm adding **butterflies** for the park cats to chase and **cat toys**
scattered around Whisker Park for cats to play with. It must look and feel like a polished front-page Roblox game:
lively, cute, smooth animations, good effects and sounds, and no jank.

## 0. Before you build anything
1. **Read my existing cat systems first:**
   - `CatGait` (procedural walk/run, paws planted with IK)
   - `CatIdles`
   - `PetCats`
   - the stray / park cat behaviour (including the Whisker Park cats and the cat-hisses-at-dog logic if it exists)

   Build cat play as **new behaviour states for the same park cats**, using the same bone-driven animation approach.
   Don't create a separate cat system.
2. **The models** (FBX; I'll import them, or tell me exactly where to put them):
   - **Butterflies:** `Butterfly_Monarch`, `Butterfly_Morpho`, `Butterfly_Kitty`.
     - Each is a Model with `Body`, `WingR` and `WingL`. Wingspan about 0.7 studs.
     - The wing hinge runs front to back at the wing root: (-0.16, 0, 0) from the `WingR` centre and (0.16, 0, 0) from
       the `WingL` centre. Flap by rotating each wing around that hinge's Z axis, in opposite directions for the two
       wings (check which sign lifts the wing).
   - **Toys** (one MeshPart each):
     - `Toy_YarnBall`
     - `Toy_ToyMouse`
     - `Toy_JingleBall`
     - `Toy_CatnipFish`
     - `Toy_FeatherWand` (a wand lying on the ground with feathers on a string)
3. Show me a short plan (modules, state machine, how many butterflies and toys, the performance approach), then build it.

## 1. Butterflies
- **How many:** 4–6 in the park at once (config), with a random colourway each.
- **Flight (procedural, client-side so it's smooth):**
  - **Flapping:** about 6–9 flaps per second, with eased motion (fast down-stroke, slower up-stroke).
  - **Gliding:** now and then the wings stay up in a V for 0.3–0.6 s.
  - **Path:** smooth, fluttery wander with layered noise: gentle up/down bobbing, small zig-zags, slow turns. It flies
    between flowers, bushes and benches about 1–4 studs above the ground. The body banks into turns and pitches
    slightly with the flap.
  - **Landing:** sometimes lands on a flower, bench, toy or even a **sleeping cat's head**, then slowly opens and
    closes its wings while resting, then takes off.
- **Server and client split:**
  - The server only decides where each butterfly is heading (waypoints) and its state.
  - Clients do all the motion and animation, smoothly following that state.
  - Only animate butterflies within about 120 studs of the player.
- **Effects:** a very faint sparkle trail (Kitty: tiny pink hearts, Morpho: blue glints), and a soft pollen puff when
  it takes off from a flower.

## 2. Cats chasing butterflies
When a butterfly flutters low (under about 2.5 studs) within about 15 studs of an idle or wandering park cat, the cat
may (with a chance and a cooldown) start a **hunt**:

1. **Notice:** the cat freezes, its head snaps to track the butterfly, its ears perk forward, its pupils go big (if
   the face texture allows), and its tail tip twitches.
2. **Stalk:** it crouches low and creeps with slow, careful steps, body close to the ground. The classic **butt
   wiggle** before pouncing (hips shimmy side to side for about 0.6 s).
3. **Chase:** if the butterfly drifts off, the cat trots or runs after it (the existing run gait), weaving to follow.
   It never leaves the park.
4. **Pounce:** a big leap:
   - hind legs push, the body stretches out, front paws reach up and forward
   - it lands with both front paws clapping together where the butterfly was
   - a squash on landing, a dust puff, a "fwump" sound
5. **Result:** the butterfly **always escapes** (flutters up out of reach at the last moment). The cat then does
   one of:
   - sits and swats at the air (paw bats), or
   - looks around confused (head tilt, "mrrp?"), or
   - does a little "I meant to do that" grooming lick.

   Then it goes back to normal.

- Sometimes two cats chase the same butterfly and bump into each other (a comedic pause, a shake-off).
- **Rare jump:** now and then (about 1 in 10 pounces) the cat does a big vertical **jump-swat** with both front paws
  clapping overhead.

## 3. Cat toys around the park
- **Placement:**
  - Scatter 8–12 toys around Whisker Park (config): on the grass, by the benches, near the fountain.
  - Never inside paths players walk through, never floating or clipping. Put them exactly on the ground using a
    raycast.
  - A mix of all 5 types.
- **Toys react to physics-like animation** (client-side tweens, with the server owning the position): they roll,
  slide and bounce when cats play with them, and **end up in a new place**, so the park changes over time. They stay
  inside the park bounds.
- **Who plays:** idle park cats look for a nearby toy (with a chance and a cooldown) and play with it. One cat per toy,
  except the yarn ball, where two cats can sometimes play tug.

**Play behaviour for each toy** (each with its own animations):

| Toy | What the cat does |
|---|---|
| **Yarn ball** | Bats the ball with alternating front paws so it rolls away, chases it, flops on its side and **bunny-kicks** it with its back legs while holding it. The loose strand jiggles. Sometimes the cat ends up with the strand draped over it (tangled moment, then shakes it off). |
| **Toy mouse** | Stalks it like real prey, pounces, **tosses it in the air** with its mouth or paw and catches it, then proudly carries it around in its mouth (weld to the head bone) and drops it somewhere else. |
| **Jingle ball** | Swats it hard so it rolls fast with a jingle each bounce, then a zoomies-style sprint after it. The bell jingles with every roll. |
| **Catnip fish** | Rubs its cheek on it, rolls on its back holding it, **bunny-kicks** it, then goes loopy: slow blinks, a happy flop, little floating hearts. Afterwards it naps next to it for a while. |
| **Feather wand** | The feathers twitch in the wind on their own. The cat crouches, wiggles, and **leaps to swat the feathers**; the string and feathers flip around. It sometimes sits and paws at the feathers repeatedly (bap-bap-bap). |

**Afterwards:** the cat walks away, or naps next to the toy (curl up, breathing, an occasional ear twitch).

## 4. Animation quality bar
- **Approach:** extend `CatGait`/`CatIdles` with these new poses. Keep paws planted and never sliding, and keep the
  overlapping motion on the tail and ears.
- **Blends:** smooth between every state, 0.15–0.3 s, no pops.
- **Key poses:**
  - **Crouch / stalk:** low belly, shoulders up, head level.
  - **Butt wiggle:** hips shimmy side to side, tail low and twitching.
  - **Pounce:** anticipation crouch → explosive extension → airborne stretch → front paws together → landing squash.
  - **Paw bat:** quick alternating swipes from a sitting or crouched pose.
  - **Bunny kick:** cat on its side, front legs hugging the toy, back legs kicking quickly.
  - **Toss and catch, carry in mouth.**
  - **Roll on back:** belly up, paws curled, wiggle.
  - **Loopy catnip:** slow head roll, half-closed eyes, happy flop.
  - **Jump-swat:** vertical leap with both front paws clapping overhead.
  - **Sit and watch:** head tracking a butterfly.
  - **Confused head tilt.**
- **Timing:** vary each animation (speed ±10%, random pauses) so the cats don't look robotic.

## 5. Effects and sounds
- **Effects:**
  - small dust puffs on pounces and landings
  - yarn fluff bits when batting yarn
  - jingle sparkles on the jingle ball
  - floating hearts and a soft green catnip haze for the catnip fish
  - "zzz" while napping
  - a "!" pop when a cat notices a butterfly
  - a "?" when it misses
  - a sweat drop or "hmph" puff for the grooming "I meant to do that"
- **Sounds** (3D, short range, with slight pitch variation):
  - **Cats:** chirps and chatters while watching butterflies, a happy "mrrp", purring, soft paw thumps, a pounce
    "fwump", playful growls while bunny-kicking, a contented sigh when napping.
  - **Toys:** a jingle bell (jingle ball and wand), a squeak (mouse), a soft fabric rustle (fish, yarn), a light wooden
    tap (wand).
  - **Park ambience:** birds and a light breeze, if not already there.
  - **Use real public Creator Store audio (or audio I own). Never make up asset IDs.** Keep all IDs in one sound
    config.
- **Performance:**
  - Particles stay short and small.
  - Nothing animates for players farther away than about 120 studs.
  - Toys and butterflies stream in and out with the park.

## 6. Player interaction
- **Click to play:** players can click or tap a toy to **toss it** (a short arc in the direction they're facing). The
  nearest idle park cat gets excited and chases it, so players can play with the cats.
- **Butterflies:** they flutter away from players who run at them (a gentle avoid), but can sometimes land on a
  player's shoulder if they stand still nearby for a while (a cute moment, with sparkles).
- Optional: if there's a petting system, petting a cat after it played gives a happy reaction.

## 7. Admin panel hooks
Add these to my admin panel and chat commands:
- spawn a butterfly (choose a colourway) here
- make the nearest cat chase a butterfly
- make the nearest cat play with a chosen toy
- reset toys to their starting spots
- toggle park play on or off

## 8. Test before you tell me it's done
1. Butterflies fly smoothly for several minutes. The flapping looks natural, they land and take off cleanly, and they
   never get stuck inside objects or leave the park.
2. Cats notice, stalk, wiggle, chase and pounce. The butterfly always escapes, and the follow-up reactions play. Paws
   don't slide.
3. Every toy's play routine works, and toys end up somewhere new but still in the park, on the ground.
4. The tug-of-war and nap-after-play moments happen.
5. Player toss and the butterfly-on-shoulder moment work.
6. Effects and sounds play, with no leftover particles.
7. Performance is fine on the phone emulator, and there are no errors or warnings.

Send me screenshots of: a stalk + butt wiggle, a pounce mid-air, the yarn bunny-kick, the mouse toss, the catnip
loopy moment, and a butterfly landed on a cat. Also send the list of sound IDs used.

---

# PART 2: Implementation guide (how to build it, step by step)

Follow these steps in order, and test each step in Play mode before moving to the next.

## Step 1: Import and set up the models
1. **Import:**
   - Import `Butterfly_Monarch.fbx`, `Butterfly_Morpho.fbx` and `Butterfly_Kitty.fbx` (Avatar → 3D Importer, or
     Home → Import 3D). Each becomes a Model with `Body`, `WingR` and `WingL`.
   - Import the 5 toys: `Toy_YarnBall`, `Toy_ToyMouse`, `Toy_JingleBall`, `Toy_CatnipFish`, `Toy_FeatherWand`.
2. **Folders and properties:**
   - Put them in `ReplicatedStorage.ParkProps.Butterflies` and `ReplicatedStorage.ParkProps.Toys`.
   - On every part: `Anchored = true`, `CanCollide = false`, `CanQuery = false` (toys keep `CanQuery = true` so the
     ground raycast can ignore them and players can click them), `CastShadow = true` (toys) / `false` (wings).
   - Set each model's `PrimaryPart` (butterfly → `Body`; each toy is a single MeshPart).
3. **Wing hinges:** add an `Attachment` named `Hinge` inside each wing at its root:
   - `WingR.Hinge.Position = Vector3.new(-0.16, 0, 0)`
   - `WingL.Hinge.Position = Vector3.new(0.16, 0, 0)`

   Then store each wing's rest offset from the body as an attribute or in code (`RestOffset = Body.CFrame:ToObjectSpace(Wing.CFrame)`).
4. **Toy attachments:** on each toy, add `Grab` (where a cat's mouth or paw holds it) and `Ground` (bottom centre).
   The **yarn ball** and **feather wand** come as multi-part models (`Ball` + `Strand`; `Stick` + `String` + `Feathers`)
   so the strand, string and feathers can really move. Add pivot attachments:
   - `Strand.Root`: (-0.264, 0.031, -0.174)
   - `String.Root`: (-0.201, 0.008, 0.209)
   - `Feathers.Knot`: (0, 0, 0.25)
5. **Uploads and maps:** upload the textures if the FBX didn't keep them (`assets/park/textures`). Swap a butterfly's
   colourway by setting `TextureID` on all three of its parts.
6. **Park markup:** in Whisker Park, add a folder `Workspace.WhiskerPark.Markers` with:
   - `Bounds`: a big invisible, non-colliding part covering the play area
   - `ToySpawns`: 10–15 small invisible parts on the grass
   - `ButterflyPoints`: 15–20 waypoints at flowers, bushes and benches, 1–4 studs up
   - `LandingSpots`: flower tops, bench backs and fence posts, each with an Attachment facing up

## Step 2: Modules and architecture

```
ReplicatedStorage/ParkPlay/
  ParkConfig        -- every number: counts, chances, cooldowns, ranges, speeds, sound IDs
  ParkShared        -- state enums, helpers (ground raycast, inside-bounds check, easing)
ServerScriptService/ParkPlay/
  ParkPlayService   -- spawns butterflies & toys, owns their state, schedules cat play, validates player tosses
StarterPlayerScripts/ParkPlay/
  ButterflyClient   -- renders/animates every butterfly near the player (flight, flap, landing)
  ToyClient         -- animates toy rolls/tosses/bounces and their FX
  CatPlayClient     -- plays the new cat play poses on top of the existing cat animation system
  ParkFX            -- particles, pops ("!", "?", hearts, zzz), sounds
```

- **The server is the source of truth** for *state*, never per-frame motion. It writes compact state to attributes:
  - **Butterfly:**
    - `State` (Fly / Land / Rest / Flee)
    - `Target` (a Vector3 waypoint)
    - `Seed`
    - `StateStart` (`workspace:GetServerTimeNow()`)
  - **Toy:**
    - `Owner` (cat ID or player)
    - `Action` (Idle / Roll / Toss / Carried)
    - `From`, `To`, `ActionStart`
    - the final resting `CFrame`
  - **Cat:**
    - a new `PlayState` (None / Notice / Stalk / Wiggle / Chase / Pounce / Swat / Confused / Groom / ToyPlay / Nap)
    - `PlayTarget` (butterfly or toy ID)
    - `PlayStart`
- **Clients do all the motion** from these attributes, using `GetServerTimeNow()` so every player sees the same thing
  at the same time. Nothing per-frame goes over remotes.
- **Distance culling:** every client only animates objects within `ParkConfig.AnimateRange` (about 120 studs). Farther
  ones are parked at their last state, or hidden.

## Step 3: Butterfly flight (client)
Each butterfly runs on one shared `RenderStepped` loop. Don't use a loop per butterfly.

**Path:** the server picks the next waypoint (a random `ButterflyPoint`, with a chance to pick a `LandingSpot`). The
client flies a smooth curve between the current position and `Target`:
```lua
-- smooth fluttery path: ease toward target + layered noise wobble
local t = math.clamp((now - stateStart) / travelTime, 0, 1)
local e = t * t * (3 - 2 * t)                                   -- smoothstep
local base = startPos:Lerp(target, e)
local n1 = math.noise(seed, now * 1.3) * 0.6                    -- side-to-side drift
local n2 = math.noise(seed + 10, now * 2.1) * 0.35              -- up/down bob
local pos = base + right * n1 + Vector3.yAxis * (n2 + math.sin(now * 9) * 0.08)  -- small bob per flap
local vel = (pos - lastPos) / dt
local look = CFrame.lookAt(pos, pos + vel)                      -- face direction of travel
local bank = CFrame.Angles(0, 0, -math.clamp(turnRate * 0.6, -0.6, 0.6))  -- bank into turns
body.CFrame = look * bank * CFrame.Angles(math.sin(now * 9) * 0.08, 0, 0) -- slight pitch with flap
```
- **Travel time:** distance ÷ about 3.5 studs/s, ±20%.
- **Turning:** limit how fast it turns (slerp the look direction) so it never snaps around.

**Flapping:** rotate each wing around its `Hinge` with a wing angle `a`:
```lua
local phase = (now * flapHz + seed) % 1
-- fast down-stroke (0..0.4), slower up-stroke (0.4..1)
local a = phase < 0.4 and lerp(70, -10, easeOut(phase / 0.4)) or lerp(-10, 70, easeInOut((phase - 0.4) / 0.6))
if gliding then a = 55 + math.sin(now * 2) * 4 end              -- hold wings up in a V
local function place(wing, hingeLocal, rest, sign)
    local hinge = body.CFrame * rest * CFrame.new(hingeLocal)
    wing.CFrame = hinge * CFrame.Angles(0, 0, math.rad(a) * sign) * CFrame.new(-hingeLocal)
end
place(wingR, Vector3.new(-0.16, 0, 0), restR, 1)
place(wingL, Vector3.new( 0.16, 0, 0), restL, -1)
```
- **Rates:** `flapHz` is 7 while flying, 3 when slowly opening and closing at rest, and 10 when fleeing. Glide
  randomly for 0.3–0.6 s every 2–4 s.
- **Landing:**
  - Slow down over the last 1.5 studs and flare (pitch up, wings spread).
  - Settle onto the landing attachment.
  - Fold the wings to about 80°, then slowly open and close them (0–60° every 1.5–3 s).
  - Rest for 3–8 s.
  - Take off with a pollen puff (flowers only) and a quick climb.
- **Avoiding players:** if a player moves fast within 4 studs, switch to `Flee`: climb 2 studs, flap faster, curve
  away.
- **Landing on a player's shoulder:** if a player has stood still for about 6 s within 6 studs, the server may (rare
  chance) set the target to the player's shoulder attachment. The butterfly lands there with sparkles and leaves as
  soon as the player moves.
- **Effects:** a faint trail (an attachment-based Trail on the body, Lifetime 0.25, very transparent) in the
  colourway's tint.

## Step 4: Cat play state machine
- Add a `CatPlay` module that the existing park cat brain calls when a cat is idle or wandering. It **never overrides**
  existing important states (being petted, fleeing or hissing at a dog, or sleeping if the cat is asleep).
- **Server: choosing what to do** (every 1–2 s per idle cat, staggered):
  1. **Butterfly check:** is a butterfly low (< 2.5 studs) within 15 studs, with line of sight, and the cat's
     butterfly cooldown over? Then roll the chance → `Notice`.
  2. **Toy check:** is a toy within 20 studs, not owned, and the toy cooldown over? Then roll the chance → walk to it
     → `ToyPlay(type)`.
  3. Otherwise, continue the normal idle or wander.
- **Hunt sequence** (the server sets states and timings; the client animates):

| State | Duration | What happens |
|---|---|---|
| Notice | 0.6–1.0 s | head tracks the butterfly, ears forward, tail-tip twitch, "!" pop, chirp sound |
| Stalk | 1.5–3 s | crouched creep toward the butterfly's ground position, speed 1.2 studs/s |
| Wiggle | 0.5–0.8 s | butt wiggle in place |
| Chase (optional) | until within 3 studs, max 4 s | if the butterfly moved away: trot/run after it |
| Pounce | 0.55 s | leap arc to the predicted butterfly position (it escapes upward at t = 0.35) |
| Outcome | 1–2 s | Swat / Confused / Groom (random) |

- **Pounce arc:**
  - Root position = lerp(start, landing, t) + up × 4 × h × t × (1 − t), with peak height h = 0.9 studs.
  - The body pitches nose-up on take-off and nose-down on landing.
  - Front legs stretch forward during the flight, then a squash on landing (the root drops 0.08, the spine compresses).
  - A dust puff and a "fwump" exactly on landing.
- **Toy play:** each toy type has a short script of beats, e.g. yarn = [bat, bat, roll-chase, flop, bunny-kick 2 s,
  get up]. The server picks the beats and their durations and moves the toy (`Action = Roll`, `To` = a new ground
  point). The client plays the matching pose and animates the toy.
- **Cooldowns, so it doesn't look busy:**
  - each cat: 25–45 s between plays
  - each toy: 15 s
  - at most 3 cats playing at once in the park (config)

## Step 5: Cat poses (client, on top of CatGait)
- **Approach:** build the new poses as **bone pose functions** that use the same bone names and approach as
  `CatGait`/`CatIdles` (e.g. `Poses.Crouch(t)`, `Poses.Wiggle(t)`, `Poses.PounceAir(t)`, `Poses.BunnyKick(t)`,
  `Poses.MouthCarry()`). Return bone transforms and blend them with the current gait using a 0.15–0.3 s weight crossfade.
- **Keep paws planted:**
  - Use CatGait's IK for any pose where paws touch the ground (crouch, stalk, sit-swat).
  - Feet only leave the ground in pounce, jump-swat and bunny-kick.
- **Secondary motion:**
  - The tail and ears follow with a spring (`target → current` with damping), so they lag and overshoot naturally.
  - The tail lashes faster while stalking.
- **Carrying in the mouth:** weld the toy's `Grab` attachment to the head bone (spine.013) with an offset. Update its
  CFrame from the bone each frame on the client (Bones can't hold welds), and clear it when the cat drops the toy.
- **Variation:** randomise speed by ±10%, insert small idle pauses, and mirror swipes left and right randomly.

## Step 6: Toys moving (client animation, server-decided)
- **Roll:** the server picks `To` (a random ground point 2–6 studs away inside `Bounds`, raycast to the ground). The
  client:
  - moves the toy along the ground with ease-out
  - rotates it by distance ÷ radius around the axis perpendicular to the motion (the yarn ball and jingle ball really
    roll)
  - adds 1–2 small decreasing bounces
- **Toss** (a player clicks a toy):
  1. A ClickDetector or ProximityPrompt fires the server.
  2. The server checks the distance (< 12 studs) and a cooldown, then picks a landing spot 6–10 studs ahead of the
     player, clamped to the park.
  3. The client animates a parabolic arc with spin, a bounce on landing, and dust.
  4. The nearest idle cat gets `Chase` → `ToyPlay` on that toy.
- **The feather wand stays put.** Only its moving parts animate:
  - **Feathers:** swing around `Feathers.Knot` with a spring (a gentle breeze sway at rest, a fast flick and flutter
    when a cat swats).
  - **String:** re-aim it every frame from `String.Root` toward the knot, so it always connects the stick tip to the
    feathers.
- **Yarn strand:** wiggles around `Strand.Root` with a spring while the ball is batted, and trails behind as the ball
  rolls (rotate it so it points opposite to the roll direction).
- **Settle:** after any move, the server stores the final CFrame (exactly on the ground, upright for the mouse and fish
  and the stick, random yaw), so new players joining see toys in the right place.
- **Stuck check:** if a toy ever ends outside `Bounds` or isn't resting on the ground, the server moves it back to a
  `ToySpawn`.

## Step 7: Effects and sounds wiring
- `ParkFX` exposes calls such as `FX.Pop(part, "!")`, `FX.Hearts(part)`, `FX.Zzz(part, on)`, `FX.Dust(pos)`,
  `FX.Sparkle(part)` and `FX.Sound(name, part)`.
- Pops are BillboardGuis that scale in (Back Out) and fade out, AlwaysOnTop off, max distance 60 studs.
- Particles are pre-made emitters in `ReplicatedStorage.ParkPlay.FX`. Clone them, `Emit()`, and delete them after
  their lifetime.
- **Sound triggers:** sounds are triggered by the animation beats themselves (the pounce landing frame, each jingle
  bounce), not by timers, so they always line up.
- Every sound ID goes in `ParkConfig.Sounds`. They must be real public Creator Store sounds.

## Step 8: Performance checklist
- One `RenderStepped` loop each for butterflies, toys and cat poses. No per-object loops or `while true` threads.
- Skip anything outside `AnimateRange`. Update butterflies 30 times a second if they're more than 60 studs away.
- No new Instances per frame. Reuse BillboardGuis and particle clones from a small pool.
- Server state changes are rare events (a few per second for the whole park), not per-frame updates.

## Step 9: Order of work
1. Import, set up and mark up the park (Step 1). Spawn static butterflies and toys and screenshot them.
2. Butterfly flight + flap + landing (Step 3). Make it look great before moving on.
3. Toy roll and toss animations (Step 6) with the player toss.
4. Cat play states (Step 4) + poses (Step 5): the butterfly hunt first, then each toy one by one.
5. Effects and sounds (Step 7), then the admin panel commands, then the performance pass (Step 8).
6. Run the full test list from Part 1, section 8.
