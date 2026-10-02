# Prompt: stray dogs in the city, more stray cats at Whisker Park (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. Add a living **city wildlife** layer: stray dogs that wander the city,
stray cats that react to them, and more cats lounging at Whisker Park. Players can chase dogs off with the bat for
coins. It has to look and feel like a **front-page Roblox game**: lively, readable, juicy effects, polished UI, smooth
animations, good sounds and no jank.

## 0. Before you build anything
1. **Read the existing systems first:**
   - the stray cat system that already wanders the sidewalks (find it: how cats are spawned, pathed, animated and
     culled)
   - `CatGait`, `CatIdles`, `PetCats`
   - the dog model, `DogGait` and the dog raid system (factory dogs)
   - the bat tool and its charge mechanic
   - the quest/job system (`questJobId` etc.)
   - the economy (`DataService`, `data.Coins`, `leaderstats`, the `CoinCollect` effect)
   - Whisker Park in Workspace (benches, paths, grass)

   **Reuse them.** Stray dogs should share code with the factory-raid dogs and with the stray cats (navigation,
   culling, animation), not be a third separate system.
2. Show me a short plan: modules, the config, how dogs and cats share navigation, and the coin formula with example
   numbers. Then build it.

## 1. Stray dogs in the city
- **Wandering:**
  - Dogs wander the **city sidewalks** the same way the stray cats do: the same sidewalk waypoints/navmesh, never
    walking in the road except at crossings, never through buildings.
  - Natural behaviour: walk, stop to sniff lamp posts and bins, look around, sit for a moment, scratch an ear, then
    carry on.
  - Each dog gets a **random coat** (golden, beagle, dalmatian, using the weights already in the dog config) and a
    slightly random speed and size so they don't look cloned.
- **How many:**
  - Normally only a few: **2–3 for the whole server** (config).
  - When a player has an active **"clear the dogs from the city" quest**, extra dogs spawn for that player's quest
    (e.g. +4–6 spread around the city, config).
  - The extra dogs despawn naturally (they walk off somewhere out of sight) once the quest is finished.
- **Spawning out of sight:** dogs appear and disappear only out of every nearby player's view (behind buildings or far
  away). They never pop in or out in front of anyone.
- **Performance:**
  - Server-owned and lightweight.
  - Animation runs on the clients, and only for dogs within about 150 studs of that client.
  - Far-away dogs just move along their path without animating.
  - Works on mobile.

## 2. How dogs react to players
- **The player is just walking or not holding the bat:**
  - When the player comes within about 25 studs, the dog **notices**: it turns its head to look at them, its ears
    perk, its tail wags slowly.
  - It **keeps walking** on its route, glancing at them as it passes.
  - No fleeing.
- **The player is holding the bat** (equipped, within about 35 studs and in the dog's line of sight):
  - The dog freezes for a split second, and a **bouncing red "!"** pops over its head (scale-in with Back Out, plus a
    small shake).
  - A **warning sound** plays (a sharp alert sting plus a startled yip).
  - The dog **runs away** at full gallop, picking routes **away from the player** around the city: sidewalks,
    alleys, crossing the street if needed, cutting around corners.
  - It glances back over its shoulder as it runs.
  - It must never get stuck, and must re-path if blocked.
  - Once it's far enough away (about 80 studs) and out of sight, it calms down: slows, pants, and goes back to
    wandering.
  - If the player unequips the bat, the dog calms down faster.
  - Several dogs near each other all panic in a chain reaction.
- **Hit with the bat:**
  - Same hit feel as the factory raid: hit-stop, a "BONK!" pop, an impact star burst, the white flash, stars circling
    its head, a yelp.
  - The dog does a short dizzy stagger, then runs off out of sight and despawns (it counts as "chased away").
  - It pays out coins (section 4).
  - One reward per dog, and only one player gets it (the first valid hit).
  - The server validates range, line of sight, the swing cooldown and the dog's state.

## 3. Stray cats react to dogs
- When a stray cat sees a stray dog within about 18 studs:
  - it **hisses**: puffed-up fur pose (arched back, tail up and bushy), ears flat, a hiss sound, a small "!" or
    angry-squiggle effect
  - it **backs away** out of the dog's path, onto the grass, behind a bench or up against a wall
  - it waits, watching the dog, until the dog has passed and walked away
  - then it relaxes (a shake-off animation) and goes back to what it was doing
- Cats never walk through the dog. Dogs ignore cats (or glance at them curiously) and keep walking.
- If a cat is sitting on a bench in the park when a dog passes, it stays on the bench, hisses and watches. It doesn't
  run.
- This must look natural, not twitchy. Use a little reaction delay and smooth turns.

## 4. Coins scale with the player's economy level
- The reward for chasing off a dog should feel **good for wherever the player is in the economy**: worth it for a new
  player, and still meaningful for a rich one.
- **Base it on what the player actually earns**, not their coin balance, so spending doesn't cut the reward. For
  example:
  - the average value of the player's recent box sales, or
  - their best box value or factory income per minute, from data the game already tracks.

  Pick the most reliable measure that exists and explain your choice.
- **Suggested formula** (all numbers in the config):
  `reward = clamp(earnRate * ~45 seconds-worth, minReward, maxReward) * random(0.9–1.1)`
  - A brand new player gets at least ~25–50 coins.
  - A late-game player gets proportionally more.
  - Quest dogs give a small bonus.
  - Show me example numbers for a new, mid-game and late-game player.
- **Rewards are server-side only.** Use the existing coin path (`data.Coins`, `leaderstats`, the `CoinCollect`
  effect), add the anti-farm cap from the config (e.g. max dogs rewarded per 10 minutes), and log large rewards.
- **Feedback:** coins burst out of the dog and fly into the coin counter, a floating "+X" pops at the hit point, and a
  cha-ching plays.

## 5. "Clear the dogs" quest
- Add it to the existing quest system: **"Stray Patrol: chase X dogs out of the city"**, with X scaled to level
  (for example 5).
- Accepting it spawns the extra quest dogs for that player and shows a **quest tracker** in the HUD:
  "Dogs chased off 2/5", with a progress bar.
- **Finding the dogs:** an optional compass arrow or subtle paw-print trail on the ground leading to the nearest quest
  dog, so players don't wander aimlessly.
- **Completion:**
  - a big "QUEST COMPLETE!" banner with confetti
  - a reward chest or coin explosion, scaled with the same economy formula (bigger than single dogs)
  - a fanfare sound
- The quest has a cooldown before it can be taken again.
- Other players can still hit quest dogs but get the normal reward. Only the quest owner's counter goes up.

## 6. More stray cats at Whisker Park
- Add **6–10 extra stray cats** that live at Whisker Park, using the real cat models with random cat types.
- **Behaviour:**
  - They **lie and loaf on the benches**: curled up sleeping, loafing, lying on their side, stretching, grooming,
    sitting upright watching people.
  - Some wander the park paths and grass, chase a butterfly or leaf, roll in the grass, sit by the fountain or trees.
  - They swap between benches and spots over time, so the park always looks alive.
- **Exact bench placement:** find each bench's seat surface and position cats exactly on it, facing a natural
  direction. Never floating, clipping or half off the edge.
- **Player interaction:** park cats glance at nearby players. Use the existing petting system if it supports strays.
- **Cats don't stack:** two cats never take the same bench spot.

## 7. Animations (they must look really good)
**Dogs** (extend `DogGait`):
- walk, trot, run/gallop and a panicked flee run
- sniff the ground, sniff a lamp post, look around
- sit, lie down, scratch an ear, shake off
- head turn and track the player when noticing them
- startled jump with the "!"
- glance back while fleeing
- hit stagger / dizzy, pant
- **Rules:**
  - smooth blends between all of them (0.15–0.25 s), no pops
  - paws planted, never sliding
  - ears and tail with overlapping secondary motion

**Cats** (extend `CatGait`/`CatIdles`):
- **new:** hiss and puff-up, back away (careful backwards steps), watching, relax and shake off
- **bench idles:** loaf, curled sleep with slow breathing, side lie, stretch, groom, tail flicks
- **park extras:** pounce, roll in the grass
- **Rules:** smooth transitions in and out of the bench, a proper hop up and hop down (no teleporting)

## 8. Effects, sounds and UI (front-page quality)
- **"!" alert:** a crisp red exclamation in a white rounded bubble with a drop shadow, a bounce-in and a shake. Visible
  through clutter (AlwaysOnTop) but scaled with distance. It fades out when the dog calms down.
- **Hiss effect:** small angry squiggle lines and a puff of fur particles around the cat.
- **Dog running:** dust puffs from the paws, a speed-line streak in panic mode.
- **Hit:** the full raid hit package (see the factory raid). Reuse those modules.
- **Sounds:** paw steps on pavement and grass, panting, sniffing, a curious "boof", a startled yip, a yelp on hit, a
  cat hiss and growl, purring and snoring at the park, ambient park birds.
  - Use real Creator Store audio that is public or mine. **Never make up asset IDs.**
  - All IDs in one config.
  - 3D positional, with slight pitch variation.
- **HUD:**
  - the quest tracker
  - a small on-screen tip the first time a player sees a dog: "Equip your bat to chase stray dogs for coins!"
    (shown once, saved)
  - matches my game's existing UI colours, fonts and button style

## 9. Admin panel hooks
Add these to my admin panel (and chat commands):
- spawn a stray dog here (choose a coat)
- set the stray dog count
- start or complete the Stray Patrol quest for a player
- clear all stray dogs
- spawn a park cat
- show the coin reward a player would get from a dog

## 10. Test before you tell me it's done
1. Dogs wander the sidewalks for 10+ minutes without getting stuck, entering roads wrongly or popping in or out in
   view.
2. Walking past a dog makes it look at you and keep walking. Equipping the bat makes the "!" and sound appear, and the
   dog flees around the city and calms down later.
3. Hitting a dog pays the right economy-scaled amount once. Check it with a new-player save and a rich save on test
   players, not my real save. The anti-farm cap works.
4. The quest spawns extra dogs, the tracker counts, completion pays out, the extra dogs despawn, and the cooldown works.
5. Cats hiss, back away and resume correctly, including on benches.
6. The park has 6–10 cats on benches and paths with no floating or clipping. They hop on and off benches smoothly.
7. Performance holds up with every dog and cat active (check the MicroProfiler / client FPS on a phone emulator).
8. No errors or warnings in the output.

Send me screenshots of: a dog noticing a player, the "!" flee, the hit payout, a cat hissing, the park cats on
benches, and the quest tracker. Also send the list of sound IDs you used, and anything you want me to decide.
