# Prompt: pastry-stealing dogs + bat (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. I've put a **dog model** and a **bat** in Workspace. Build a complete
"dog raid" feature. Dogs sneak into my factory and steal pastries from boxes, and players chase them off with the bat.
It must look, sound and feel like a polished front-page Roblox game: smooth animations, punchy hit feedback, clean
VFX, good sounds, and no bugs.

## 0. Before you build anything
1. **Read the existing code first.** Check these, and anything else that touches boxes, shelves, factories and doors:
   - `ServerScriptService.Modules.BoxService` (boxes, shelf slots, `stackFrame`, carrying)
   - `ServerScriptService.Factory.Workstations`
   - `ServerScriptService.Core.FactoryClaiming` (who owns which factory)
   - `ServerScriptService.Economy.BoxStealing` (an existing stealing mechanic, so don't conflict with it)
   - `ReplicatedStorage.Shared.Sfx`, `ReplicatedStorage.Shared.CatGait`, `StarterPlayer...Cats.PetCats`
   - the factory door
   Reuse the existing patterns, remotes, data and helpers instead of building parallel systems.
2. **Inspect the dog model.** It's a skinned MeshPart rigged with Bones, with the same bone names as my cat:
   - `RootPart` → `spine.014` → `spine.004` (hips) → `spine.010`/`.011` (chest) → `spine.012` (neck) → `spine.013` (head)
   - ears: `ear.L`/`ear.L.001` and `ear.R`/`ear.R.001`
   - tail: `spine.003` → `spine.005`…`spine.009`
   - legs: `thigh.L/.R` (+ `.001`–`.004`) and `front_thigh.L/.R` (+ `.001`–`.004`)
   - a `hatpoint` bone on top of the head

   Check whether the paw bones (`*.003`) are children of the leg bones (the hand-animation version) or of `spine.014`
   (the CatGait version), and tell me which one is in Workspace.

   **Random coat on every spawn.** The dog has 3 coat textures that all share the same UVs, so changing the coat is just
   a matter of setting the dog MeshPart's `TextureID`:

   | Coat | File | Spawn weight |
   |---|---|---|
   | Golden Retriever | `dog_golden.png` | 45 |
   | Beagle | `dog_beagle.png` | 40 |
   | Dalmatian | `dog_dalmatian.png` | 15 (rarer) |

   I will upload these 3 images and give you their asset IDs. Put them in the config as
   `Coats = { {Name, TextureId, Weight}, ... }`.
   - Every time a dog spawns, the server picks a coat by weight and sets `TextureID` **before** the dog is parented
     to Workspace, so it never shows the wrong coat for a frame.
   - Store the coat name as an attribute (`Coat`) so effects and messages can use it, for example
     "A Dalmatian is sneaking in!".
   - If I haven't given you the IDs yet, ask me for them. Don't use placeholder IDs.
3. **Inspect the bat.** It's a 3.6-stud MeshPart with its length along its Y axis. The middle of the grip is 1.2 studs
   below its centre, so start with `Tool.Grip = CFrame.new(0, -1.2, 0)`. Then check in a playtest that the bat sits
   naturally in the hand and points the right way, and fix the rotation if needed.
4. Back up anything you change: duplicate it with a `_OLD` suffix and disable the copy. Tell me your plan in a few lines,
   then build it.

## 1. Gameplay rules
**Spawning: a fun challenge, never annoying**

Dogs should feel like an occasional "oh no, a dog!" event that's exciting to deal with, not a constant chore.
Put every number below in the config.
- **Who gets dogs:** only claimed factories whose owner is in the game, has been playing for at least **3 minutes**
  (a grace period for new joins), and has at least one finished box worth stealing.
- **How often:** about **one raid every 4–7 minutes** per factory, at a random time in that window.
  - After a raid ends (saved, stolen or given up), the next one is at least **4 minutes** away.
  - Never more than **1 dog** per factory at a time.
- **Gentle on new and idle players:**
  - Players with very few boxes get raids less often (scale the timer up for low box counts).
  - Players who haven't been near their factory for 2 minutes (AFK or away delivering) get no raids, so they don't
    come back to losses they never saw coming.
- **Fair warning:** about 5 s before the dog reaches the door, give the owner a short bark and an edge-of-screen
  indicator, so there's always a chance to react.
- **Escalation, but capped:** if the owner saved the last box, the next dog can be slightly faster
  (+10% speed, max +30%). Reset this when a box is stolen, so the challenge rises a little but never becomes
  impossible.
- **Sanity check:** in your report, tell me the expected number of raids per 30 minutes of play with these settings.
  It should be about 4–6.
- A dog spawns at a random point outside the factory, out of the owner's sight, and trots in from there.
- Dogs only go inside if the factory door is **open**. If the door is closed, the dog circles near it, sniffs and
  scratches at it for a few seconds, gives up and leaves.

**Targets and biting**
- Valid targets are a **workstation holding a finished box** or a **shelf slot with a box** in that factory. Pick the
  nearest valid one and re-check it is still valid on the way. If it's gone, pick another target or leave.
- Movement uses `PathfindingService` with re-pathing, walking through the door and around machines. The dog must
  never clip through walls, get stuck or slide. Add a "stuck for 3 s → re-path / teleport home" safety.
- At the box, the dog plays the bite loop for **4 s** (config). A small progress ring over the box shows the damage.
- If the timer finishes, the box is destroyed through `BoxService`, so the data stays correct and nothing duplicates.
  The dog then **runs away with a pastry in its mouth** and despawns when it's out of sight.

**Hitting the dog**
- **While it's approaching or biting:**
  - the dog is stunned and knocked back,
  - the bite is cancelled and **the box is saved** ("SAVED!" pop-up),
  - the dog flees with an empty mouth and despawns.
- **While it's running away with the pastry:** hitting it is just for revenge. The box stays gone, but the dog drops
  the pastry with a big "REVENGE!" effect, yelps and runs off faster. Ask me before adding any money or XP reward
  for this.
- **Coin rewards** (see section 1b) for saving a box and for revenge hits.
- **One hit is enough** to send any dog running. Give it a short hit-immunity window so one swing can't hit it twice.

## 1b. Coin rewards
Protecting your boxes should feel worth it. Give the coins on the **server**, using the existing economy:
- add to `data.Coins` from `DataService`,
- update `player.leaderstats.Coins`,
- play the existing `remotes.events.CoinCollect` coin effect, the same way `BoxService:SellBoxes` does.

| Event | Reward (config values) |
|---|---|
| **Box saved** (hit the dog while it's approaching or biting) | **35% of the target box's `Value`** (minimum 25 coins), shown as "+X SAVED!" over the box |
| **Revenge hit** (hit the dog while it's running off with the pastry) | **15% of the stolen box's `Value`** (minimum 10 coins), shown as "+X REVENGE!" |
| **Quick save bonus** (hit before the dog starts biting) | +10 coins extra, shown as "QUICK SAVE!" |

- **Who gets paid:** the coins go to the player who landed the hit, even if it isn't the factory owner. If the owner
  saved their own box, the owner gets it.
- **Only once per dog:** one reward per dog. Only the first valid hit pays.
- **No farming:** dogs only come from the natural spawn timer, so rewards can't be farmed. Never award coins for dogs
  spawned any other way, and keep the spawn pacing from section 1 so this stays a bonus, not a money machine.
- **Feedback:** play a bright "cha-ching" coin sound and the coin burst at the hit point. The coin counter in the
  sidebar should tick up as usual.

**Server rules**
- The **server is the authority** for dog state, targets, the bite timer, box destruction and hit validation:
  - the hitting player must be within range (about 7 studs) and roughly facing the dog,
  - the swing cooldown is respected,
  - the dog is in a hittable state.
- Clients only play visuals and sounds.
- Dogs must never damage players, and the dog's network ownership must not let clients move it.

## 2. Dog animations (they must look really good)
Make these, readable from a distance and in a cute, bouncy cartoon style that matches the cat:

| Animation | What it should look like |
|---|---|
| **Walk** | relaxed 4-beat gait, gentle head bob, ears swinging, tail wagging slowly |
| **Run** | bounding gallop: body stretches and bunches, ears flop back, tail streaming, paws clearly lift |
| **Sneak** (optional, for approaching) | low body, slow careful steps, ears forward |
| **Sniff / idle** | nose to the ground, quick sniffs, a look around, tail wags |
| **Bite loop** | front paws planted, rump up, head jerks side to side tugging at the box, ears flapping, tail wagging fast |
| **Hit reaction** | a sharp flinch back, squash and stretch, head and ears snap, a short stagger before fleeing |
| **Flee with pastry** | the run, but head held higher to carry the pastry, ears pinned back |
| **Spawn / despawn** | trots in from out of sight; leaves by running out of sight (never pops in or out in view) |

**How to make them:**
- My cat uses **procedural bone animation** (`CatGait`): paws are planted with 2-bone IK, and the phase is advanced by
  distance travelled, so feet never slide. Build a matching **`DogGait`** module so dogs need no uploaded animation
  assets and work in live servers straight away.
- Walk and run must blend smoothly by speed. Add overlapping secondary motion (ears and tail lag behind the body).
- Other actions crossfade in 0.15–0.25 s, with no pops.
- If you'd rather use KeyframeSequences for the one-off actions (bite and hit), create them in `AnimSaves`. Then give me
  step-by-step instructions to publish them and paste the IDs into a config. Keep a procedural fallback so everything
  works before I publish.

## 3. Player bat swing (must feel great)
- **Tool:** the bat as a Tool. Swing on click/tap, gamepad R2, and an on-screen button on mobile. Cooldown about 0.6 s.
- **Swing animation:** works for R15 and R6, uses both arms and turns the torso, with clear key poses:
  - **anticipation** (0.12 s): bat cocked back over the shoulder, torso twisted away
  - **strike** (0.10–0.12 s, very fast): wide horizontal arc, hips leading
  - **follow-through** (0.2 s): bat wraps past the body
  - **recover** (0.25 s)

  Add a separate idle hold pose so the bat rests on the shoulder instead of sticking straight out. Publish these the
  same way (instructions + config IDs), with a procedural `Motor6D.Transform` fallback.
- **Hit detection:** on the server, at the strike frame, use a shapecast or box sweep in front of the player
  (about 6 studs, 120° arc). On the client, play the swing instantly so it feels responsive.
- **Hit feel:**
  - hit-stop: freeze the swinger's animation for about 0.06 s
  - camera shake for the hitter only (small, decaying)
  - the dog gets an impulse away from the hitter
  - quick white flash on the dog (a Highlight that fades in about 0.15 s)
- **Swing trail:** a `Trail` between two attachments on the bat's barrel, white to transparent, about 0.15 s long, only
  visible during the strike.

## 4. VFX (every event needs clear, high-quality feedback)
Use ParticleEmitters with `:Emit()` bursts, Beams, BillboardGuis and tweens. Clean everything up afterwards. Keep it
light enough for mobile (particle counts capped, and nothing permanent left behind).

| Event | VFX |
|---|---|
| Dog spawns or is spotted | small "!" pop over its head, bouncing in. A red ping on the factory owner's screen edge pointing to the dog |
| Approaching a box | dust puffs from the paws while running |
| Biting | cardboard scraps and crumbs flying (Emit every bite), the box shaking, a circular damage ring over the box going from white to red, warning icon pulsing |
| Box saved | green "+X SAVED!" pop (scale 1.4 → 1, Back Out), sparkle burst around the box, coins flying into the counter, ring disappears |
| Box destroyed | cardboard "poof" burst + crumbs + small smoke puff; the box scales down and fades rather than vanishing |
| Running off with the pastry | the pastry model held in the mouth (welded to `spine.013`), crumb trail, a "!" over the box spot |
| Bat hits the dog | big impact star burst + white flash, a "BONK!" comic text pop at the hit point (random tilt), stars and birds circling the dog's head while it's stunned, a dust ring under it |
| Revenge hit | the dropped pastry bounces on the ground then poofs, gold "+X REVENGE!" text, coin burst, a bigger burst |
| Bat whiff (miss) | swoosh trail only, no impact |
| Dog leaves | the dog runs off with a dust trail; no visible despawn |

## 5. Sounds (good, layered, positional)
- **Use real, free audio from the Creator Store.** Search for it with the MCP tools, and make sure every sound is public
  or owned by me. **Never make up asset IDs.**
- Put every ID in one `DogRaidSounds` config (or `Sfx`) so I can swap them later. If you can't find a good match for
  something, tell me what you searched for so I can pick one.
- Most sounds are 3D: parented to the dog, box or bat, with sensible RollOffMinDistance/MaxDistance. Vary the pitch
  slightly (±8%) so repeats don't sound robotic.

Needed:
- **Dog:**
  - paw steps for walk and run, synced to the gait
  - panting
  - sniffing
  - a playful bark when it spawns or is spotted
  - a growl while biting
  - a yelp when hit
  - happy barks running off with the pastry
- **Box:**
  - cardboard tearing and chewing, looped while biting
  - a "poof"/rip when it's destroyed
  - a cheerful chime when it's saved
- **Bat:**
  - a whoosh on every swing
  - a cartoon "bonk" on a hit, layered with a punchy thud
  - a sparkle sting for revenge
  - a coin "cha-ching" for every reward
- **Warning:** a short alert sting for the factory owner when a dog gets inside, played locally only for them.

## 6. Polish and edge cases
- **Multiple players:** several players can hit the same dog, but only the first hit counts.
- **Server cleanup:** dogs despawn cleanly if:
  - the factory owner leaves
  - the factory is unclaimed
  - the target box is picked up, sold or moved while the dog is biting (the dog looks confused and leaves)
- **Config module:** put every timing, range, cooldown and spawn rate in one module so I can tune it.

## 7. Test before you tell me it's done
Run a Play test (Start Server with 2 players) and confirm:
1. Door closed: the dog gives up at the door.
2. Door open: the dog paths in without getting stuck and goes for a valid box.
3. Hitting while approaching or biting saves the box, with every effect and sound.
4. Not hitting: the box is destroyed through BoxService, the counts and save data stay correct, and the dog runs off
   with the pastry.
5. Hitting while it's running off gives the revenge effects and the revenge coins, and the box stays gone.
   Saving a box pays the save reward once. Check `leaderstats.Coins` and the saved data both go up by the right amount.
   The coat is random across 10 spawns and never flashes the wrong texture.
6. A cooldown or spam click never double-hits. A player out of range can't hit.
7. Feet don't slide in the dog's walk and run, and every transition is smooth.
8. The swing looks right in R15 and R6, and on mobile with the touch button.
9. With the timers temporarily sped up, raids follow the pacing rules: the cooldown is respected, there are no raids
   while AFK, and the grace period after joining works. Put the real timers back afterwards.
10. No errors or warnings in the output, and no leftover parts or particles after 10 raids.

When you're done, show me screenshots of each stage, the list of sound IDs you picked (with names), and anything you
couldn't do or want me to decide.
