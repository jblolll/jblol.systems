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
