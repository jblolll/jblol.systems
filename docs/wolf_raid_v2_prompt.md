# Prompt: Wolf Raids 2.0 + day/night cycle (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. Wolves currently raid factories (they replaced the old dogs), but
they're too easy. A wolf walks in, an alert pops up, and **one normal hit or one charged hit knocks it out** before it
runs away. I want wolves to be a real threat that's exciting to fight. This update has these parts:

- a **day/night cycle** that controls when and how wolves raid
- **6 wolf types** with their own personalities, attacks and special abilities
- a **multi-hit fight** with a "Resolve" bar: you win by making the wolf give up and retreat
- a **reworked charged hit**: strong, but no longer an instant win
- **professional animations, VFX, sounds and UI**, matching a front-page Roblox game

The quality bar is a front-page Roblox game. Every action needs clear wind-up, impact and follow-through. Hits must
feel punchy (hit-stop, shake, sparks, sound). Wolves must feel alive (breathing, ears, tail, head tracking) and scary
but fair: every attack is telegraphed so a skilled player can always dodge it. Nothing should look floaty, slide,
clip, T-pose or pop.

**Tone rule:** wolves are **never killed, never ragdolled and never shown hurt badly**. You win by making the wolf give
up: it yelps, tucks its tail and runs back into the woods. Keep it cartoony and family-friendly.

---

## 0. Before you build anything
1. **Read the existing code first** and reuse its patterns, remotes, data and helpers. Don't build parallel systems.
   Read at least:
   - the current wolf/dog raid system (spawner, AI, hit handling, rewards, alert UI)
   - the bat Tool and **its charge mechanic** (how charge time, charged swing, effects and the hit remote work)
   - `ServerScriptService.Modules.BoxService` (boxes, shelf slots, carrying, destroying boxes)
   - `ServerScriptService.Core.FactoryClaiming`, the factory door, `ServerScriptService.Economy.BoxStealing`
   - `DataService`, coins/leaderstats, the `CoinCollect` effect
   - `ReplicatedStorage.Shared.Sfx`, `ReplicatedStorage.Shared.CatGait` / `DogGait`
   - the admin panel (I'll want new commands, see section 13)
   - anything that already touches `Lighting` or time of day
2. **Inspect the wolf model.**
   - It's a skinned MeshPart rigged with Bones, using the same bone names as the dog/cat, plus a `jaw` bone and ears:
     - `RootPart` → `spine.014` → `spine.004` (hips) → `spine.010` / `spine.011` (chest) → `spine.012` (neck) → `spine.013` (head)
     - head children: `jaw` (open the mouth with a **negative X rotation**: about -30° full open, -10° pant,
       -40° big snarl), `ear.L`/`ear.L.001`, `ear.R`/`ear.R.001`
     - tail: `spine.003` → `spine.005`…`spine.009`
     - legs: `thigh.L/.R` and `front_thigh.L/.R` (+ `.001`–`.004`)
   - Tell me which version is in Workspace: `Wolf.fbx` (paws children of the legs) or `Wolf_CatGait.fbx` (paws hang off
     `spine.014` for the procedural gait).
   - The wolf is 2.82 studs tall to the ear tips and 3.63 long. It's bigger than the old dog but smaller than a player.
3. **Six coats, one mesh.** Every wolf type is the same mesh with a different `TextureID` (same UVs):

   | Wolf type | Texture file | Eye glow colour |
   |---|---|---|
   | Timber | `wolf_timber.png` | yellow `#FFC428` |
   | Shadow | `wolf_shadow.png` | red `#FF2E1E` |
   | Frost | `wolf_frost.png` | icy cyan `#50E6FF` |
   | Ember | `wolf_ember.png` | orange `#FF9614` |
   | Celestial | `wolf_celestial.png` | gold `#FFD750` |
   | Golden | `wolf_golden.png` | emerald `#28EB82` |

   - I'll upload these and give you the asset IDs. **Ask me for them. Don't use placeholder IDs.**
   - Set `TextureID` and all type effects **before** parenting the wolf to Workspace, so it never shows the wrong
     coat for a frame.
   - Store `WolfType` as an attribute.
4. **Back up** everything you change (duplicate it with an `_OLD` suffix and disable the copy).
5. Tell me your plan in a short list, then build it. Put **every number in this prompt in one config module**
   (`ReplicatedStorage.Shared.WolfConfig`) so I can tune it without touching code.

---

## 1. Day and night cycle
The world runs on a server-controlled clock. Night is when the dangerous wolves come out.

### 1a. Timing (config)
One full day is **12 real minutes**:

| Phase | Length | `ClockTime` | Feel |
|---|---|---|---|
| **Day** | 6 min | 7:00 → 17:00 | bright, warm, safe-ish: only Thief wolves |
| **Dusk** | 1 min | 17:00 → 19:30 | orange-pink sky, long shadows, **a distant howl** warns night is coming |
| **Night** | 4 min | 19:30 → 4:30 | dark blue, moon and stars: Hunters and packs appear |
| **Dawn** | 1 min | 4:30 → 7:00 | pale purple-gold sunrise, wolves retreat, a rooster/birds sound |

- The **server** owns the time and replicates it with a `NumberValue` or attribute (`WorldTime`, `Phase`). Each
  client tweens `Lighting.ClockTime` smoothly every frame from that value, with no stepping.
- New players joining mid-night see the correct time immediately.
- **Every 3rd night is a Full Moon night** (config): a huge glowing moon, a silver tint, more raids, rare wolves are
  much more likely, and rewards are **×1.5**. Announce it at dusk with a banner: "🌕 FULL MOON TONIGHT, the wolves
  are restless…"

### 1b. How it looks (it must look beautiful, not just darker)
Tween all of these between phase presets over 20–40 s, never snapping:
- **Lighting:**
  - `Technology = Future` (if not already set; check performance)
  - `Ambient`, `OutdoorAmbient`, `Brightness`, `ColorShift_Top`, `EnvironmentDiffuseScale`, `EnvironmentSpecularScale`
- **Atmosphere:**
  - day: light haze
  - dusk: warm orange haze
  - night: deep blue with a little `Glare` near the moon and higher `Density` for a misty look
- **ColorCorrection:**
  - day: slight warmth and saturation
  - dusk: orange tint
  - night: cool blue tint, a little lower saturation, slightly higher contrast
- **Sky:** a custom `Sky` with stars visible at night (`StarCount`), a large `MoonTextureId`, and
  `MoonAngularSize` bigger on Full Moon nights.
- **Bloom and SunRays:** soft bloom at night so glowing wolf eyes and lamps bloom nicely.
- **World lights:**
  - Factory lamps, street lights and windows **turn on at dusk with a little flicker**, each a fraction of a second
    apart, so they don't all pop at once.
  - Use the existing lights if there are any. Otherwise add warm `PointLight`s / `SurfaceLight`s on lamp parts,
    tagged with CollectionService (`NightLight`).
- **Ambient sound beds** (looping, crossfaded over 5 s):
  - day: birds and light wind
  - dusk: crickets start and the birds fade out
  - night: crickets, an owl now and then, wind through trees, and a very distant howl every 40–90 s
  - dawn: birds return

### 1c. Day/night UI
- A small **sun/moon clock** at the top of the screen. It's an arc with a sun or moon icon moving along it and shows
  the phase name.
- On Full Moon nights it glows silver.
- 20 s before night it pulses orange, with the text "Night falls soon…".

---

## 2. Raid flow
A raid is an **event** with a clear beginning, middle and end.

1. **Warning (5–8 s before the wolf arrives).**
   - A **howl** plays from the direction the wolf is coming from (3D sound, audible to the owner).
   - An **edge-of-screen indicator** points to it: a pulsing paw-print arrow in the wolf's eye colour.
   - A banner says, for example, "🐺 A **Frost Wolf** is coming!", with the type name in its colour.
   - Hunters at night give **less** warning (3 s) and only a vague direction.
2. **Approach.** The wolf comes in from the treeline or map edge, out of the owner's line of sight, using its type's
   movement style (section 4).
3. **Objective.** Each type has a goal:
   - steal a box/pastry from a workstation or shelf slot (bite timer, then carry it in its mouth)
   - sabotage a machine (Ember)
   - hunt a player (Hunter types)
4. **Fight.** Players hit the wolf to drain its **Resolve** (section 3). The wolf fights back depending on its
   temperament.
5. **End.** One of three endings:
   - **Driven off (players win):** Resolve hits 0 → the retreat sequence (section 3d) and rewards.
   - **Escaped with loot (wolf wins):** it reaches the treeline holding a box → the box is lost (through `BoxService`,
     so data stays correct) and a "Stolen!" banner shows. The wolf can still be hit while escaping. If Resolve
     reaches 0 before it leaves, it **drops the loot** and the box is returned ("RECOVERED!").
   - **Gave up:** after the type's max raid time (config, about 60–90 s) a wolf with no target leaves on its own.

### 2a. Spawn pacing (config, per factory)
- Keep the old fairness rules:
  - only claimed factories whose owner is online
  - a **3 min grace period** after joining
  - no raids on AFK/away owners (not near the factory for 2 min)
  - at least one box worth stealing
- **Raid interval:**

  | Phase | Interval |
  |---|---|
  | Day | one raid every **4–6 min** |
  | Night | every **2–3.5 min** |
  | Full Moon | every **1.5–2.5 min** |
  | Dawn | no new raids |

  Minimum 90 s after the previous raid ends.
- **Packs (night only):**
  - From factory level / rebirth tier X (config; use whatever progression stat exists, and tell me which), night
    raids can be a **pack of 2**: a main wolf plus one weaker Timber companion.
  - Full Moon packs can be up to **3**.
  - Never more than 3 wolves per factory and never more than **8 wolves on the server**.
- **Dawn:** all remaining wolves finish their current action, then retreat to the woods.
- **Sanity check:** in your report, tell me the expected raids per 12-minute day for a mid-game player. It should be
  about 4–6, more on Full Moon nights.

### 2b. Which wolf spawns (weights, config)

| Type | Temperament | Day weight | Night weight | Full Moon weight | Unlock |
|---|---|---|---|---|---|
| Timber | Thief | 80 | 35 | 20 | always |
| Golden | Thief (runner) | 4 | 4 | 10 | always (rare) |
| Frost | Guard | 16 | 20 | 18 | after 10 min played |
| Celestial | Guard (trickster) | 0 | 12 | 18 | after the 1st night survived |
| Shadow | Hunter | 0 | 17 | 18 | after 20 min played / progression tier |
| Ember | Hunter | 0 | 12 | 16 | after 20 min played / progression tier |

- **New-player protection:** before a player unlocks a type, re-roll it to Timber.
- The first time a new type can appear, show a one-time tip card: "⚠️ New threat: **Shadow Wolves** hunt at night.
  Watch for glowing red eyes!"

---

## 3. The fight: Resolve, hits and the new charged hit

### 3a. Resolve (how many hits a wolf takes)
Wolves don't have "health". They have **Resolve**, their will to keep raiding. Hits drain it, and at **0** the wolf
gives up and retreats. Show it as a **segmented bar** (one segment per Resolve point) over the wolf's head.

| Type | Resolve | Normal hits to drive off | Charged hits to drive off | Notes |
|---|---|---|---|---|
| Timber | 4 | 4 | 2 (3 + 1 normal) | the "basic" wolf |
| Golden | 3 | 3 | 1 | the hard part is **catching** it |
| Frost | 6 (+2 Ice Armour) | 8 | 3 | armour absorbs the first 2 normal hits; a charged hit shatters all armour at once |
| Celestial | 5 | 5 | 2 | teleports and makes decoys |
| Shadow | 6 | 6 | 2 | hard to see at night |
| Ember | 6 | 6 | 2 | burns attackers who stay too close |
| Pack companion | 2 | 2 | 1 | weaker Timber that tags along |

- **Damage:**

  | Hit | Resolve damage |
  |---|---|
  | Normal hit | **1** |
  | **Counter hit** (see 3c) | **2**, and it always staggers |
  | **Charged hit** | **3** (see 3b) |

- **Multiplayer scaling:** for each extra player who has hit this wolf, its max Resolve is ×1.35 (rounded up, config).
  This stops 5 players instantly erasing it. The bar re-segments smoothly when this happens.
- **Bats:** if the bats (Common…Legendary) already have damage stats or perks, use them on top of these numbers and
  tell me what they are. Otherwise all bats do the same base damage and keep their current perks and effects.
- **Hit immunity:** each wolf ignores the same attacker for **0.35 s** after a hit, so one swing can't hit twice.
- **Server validation** for every hit:
  - the attacker is within range (about 7 studs, a little more on a lunging wolf)
  - roughly facing the wolf
  - the swing cooldown and charge time are respected
  - the wolf is hittable (not mid-teleport or already retreating)

### 3b. The charged hit (rework)
**Before:** a charged hit instantly knocked the wolf out. **Now** it's the player's power move, strong but not an
instant win:
- deals **3 Resolve** (a Golden Wolf and pack companions are driven off in one charged hit)
- causes a **Stagger**:
  - the wolf is launched back 8–10 studs in a short arc and lands rolling to its feet
  - it's stunned for **1.5 s** (dizzy stars, wobbly head), and its current attack or bite is **cancelled**
- **shatters Frost Ice Armour** instantly
- **cancels a Celestial teleport wind-up**, and a charged hit on a decoy pops **all** decoys
- **knocks a stolen box out of the wolf's mouth** if it's carrying one. The box drops and can be picked back up
  (through `BoxService`).
- **Trade-off:** keep the existing charge time. While charging, the player moves **30% slower** and the wolf can
  see it: Hunters and Guards that notice a player charging try to **lunge before the swing lands**. So charging in a
  wolf's face is risky, and charging while it's busy or after a dodged lunge is the smart play.
- **Charge-level feedback** (if the bat has partial charge levels, map them as follows; otherwise use full only):

  | Charge | Resolve damage |
  |---|---|
  | under 50% | 1 (normal hit) |
  | 50–99% | 2, with a small stagger (0.6 s) |
  | 100% | 3, full stagger |

- The admin "Bat always charged" toggle must still work: every swing is a full charged hit.

### 3c. Counter hits (the skill reward)
- If a wolf's **lunge or pounce misses**, it's **Exposed** for **1.2 s**. It skids, stumbles and shows a yellow "!"
  flash.
- Hitting it while Exposed is a **COUNTER**: 2 Resolve (or 3 + stagger if charged), a stronger hit-stop, a gold spark
  burst and a "COUNTER!" text pop.
- This is the main skill trick. Mention it in the first-encounter tip.

### 3d. Driving it off (winning)
When Resolve hits 0:
1. **Defeat beat (0.6 s).**
   - A big hit-stop (0.08 s) and the camera nudges toward the wolf.
   - The bar shatters into pieces.
   - "DRIVEN OFF!" text in the wolf's colour.
2. **The wolf gives up.**
   - It yelps, its ears flatten, its tail tucks between its legs and its head drops.
   - It **drops anything it's carrying**.
   - It stops being hittable (no beating it while it leaves).
   - Its eye glow fades.
3. **Retreat.**
   - It turns and runs (fast, a slightly limping cartoony gallop) to the nearest treeline/map edge.
   - At the edge it fades out in a puff of leaves/dust. Golden leaves a sparkle puff, Celestial a star puff.
   - It never just vanishes on the spot.
4. **Reward** (section 9): a coin burst at the defeat spot, a "+X" pop-up, and the coin counter ticks up.

---

## 4. Wolf temperaments and the AI
Build the AI as a **server-side state machine** with clear states:
- Spawn → Approach → Objective (Steal/Sabotage/Hunt) → Escape
- plus combat states: Alert → Warn → WindUp → Attack → Recover → Exposed/Staggered → Retreat → Despawn

Movement uses `PathfindingService` with re-pathing every 0.5–1 s, smooth steering (no jittery turns) and a
**stuck-safety** (stuck 3 s → re-path; stuck 8 s → retreat). Wolves never clip through walls or slide. Doors work as
before: a wolf only enters if the factory door is open, otherwise it scratches and sniffs at it, then gives up.

### 4a. Perception
- **Sight:** a 120° cone in front, 35 studs by day and 25 by night (Shadow sees 40 at night). A raycast line-of-sight
  check stops it seeing through walls.
- **Hearing:** a bat swing or charge within 15 studs makes a wolf turn its head toward it, even from behind.
- **Target lock:** a wolf attacking a player locks onto **one** player at a time. That player sees a small **red
  paw marker** over their own head ("You're being hunted!").
- **Leash:** a wolf never chases a player more than **60 studs** from the raided factory. Past that it gives up the
  chase and goes back to its objective.

### 4b. The three temperaments

| Temperament | Types | Behaviour |
|---|---|---|
| **Thief** (fights back only if attacked) | Timber, Golden | Goes straight for loot and ignores players. If hit, it turns on the attacker for **4 s** (snap, then lunge), then returns to stealing. If carrying loot, it runs instead of fighting. |
| **Guard** (attacks if you get too close) | Frost, Celestial | Ignores players outside **12 studs**. Inside 12 studs: **Warn** (snarl, jaw open, ears back, head low, for 1 s). Inside **6 studs**, or if hit: attacks. Stays aggressive for 6 s after the last hit. |
| **Hunter** (attacks first) | Shadow, Ember | Its first goal is the nearest player who can see the factory. It **stalks** (low crouch, slow, quiet), circles, then attacks. After knocking a player down, or after 25 s, it switches to stealing. |

### 4c. Attacks every fighting wolf has
Every attack has a readable **telegraph** (with its sound) and a **recovery** window.

| Attack | Range | Telegraph (wind-up) | Effect on the player | Recovery |
|---|---|---|---|---|
| **Snap** (quick bite) | 4.5 studs, 70° in front | 0.35 s: head pulls back, jaw opens to -25°, ears back, short growl | 10 damage, small knockback (8 studs/s), 0.4 s flinch | 0.5 s |
| **Lunge** (leap) | from 8–16 studs, a straight arc to the player's position at the end of the wind-up | 0.6 s: crouch low, back legs bunch, tail stiff, jaw open, rising snarl, eyes flare brighter | 18 damage, big knockback (25 studs/s up and back), **Dazed 1 s** (can't swing; stars over head) | miss → **Exposed 1.2 s**; hit → 0.6 s |
| **Howl** (once, at 50% Resolve; Hunters and Guards) | everyone within 40 studs | 0.8 s: sits back, head up, jaw open -35°, ears up | +20% move/attack speed for 8 s. Hunters at night call **1 pack companion** (max 1 per raid). Hitting it during the wind-up cancels the howl. | — |

- Attacks are **server-authoritative**. The hit check runs at the active frame using the player's server position,
  with a little forgiveness for lag: dodges that clearly worked on the client screen should count. Use a 0.1 s grace
  window and a slightly smaller hitbox.
- **Cooldowns:** Snap 1.2 s, Lunge 3.5 s. A wolf never chains attacks without a gap. There's always a window to hit
  back.

### 4d. Players can't die from wolves (non-lethal knock-down)
- Wolves deal real Humanoid damage, but they **can never take a player below 15 HP**.
- If a wolf hit would go below 15:
  - the player is **Knocked Down** instead: a 2.5 s fall-and-get-up animation, a dizzy screen and muffled audio
  - they stand back up at **50 HP**
  - any box they were carrying is dropped
  - the wolf loses interest in them for 8 s and goes for the loot
- A teammate can press E near a knocked-down player to **help them up instantly**: a "Helped!" pop and a small
  coin bonus for the helper.
- Health regenerates normally out of combat. If the game has no health bar visible now, add a clean small one that
  only appears when damaged.

---

## 5. The six wolf types (style, abilities, counterplay)
Each type must be **recognisable in under a second** from colour, eyes, aura and movement.

### 🐺 Timber Wolf (Thief, common)
- **Style:** a grey timber wolf, yellow eyes. A confident, steady trot, nose down sniffing the trail.
- **Stats:** Resolve 4, speed 16 studs/s (sprint 22), bite timer 4 s.
- **Ability: Grab & Dash.** When it finishes biting a box, it grabs it in its jaws and gets a **1.4× speed burst
  for 3 s** toward the treeline.
  - **Tell:** a quick head toss with the box and a cheeky yip.
  - **Counter:** hit it before the bite finishes, or charged-hit it to knock the box free.
- **Fights back** with Snap and Lunge only after being hit.

### ✨ Golden Wolf (Thief, rare runner)
- **Style:** polished gold with emerald eyes, a sparkle trail and a soft gold `PointLight`. It prances proudly with
  a bouncy, light-footed gallop.
- **Stats:** Resolve 3, speed **1.6× Timber** (about 26 studs/s), **never attacks**. It leaves after **25 s** no
  matter what.
- **Ability: Gold Rush.**
  - It **zig-zags** (sharp 40–60° cuts every 1–1.5 s) and dodges: when a player starts a swing within 6 studs, it has
    a 35% chance to hop sideways 6 studs (0.5 s cooldown).
  - Every hit makes it **drop a burst of gold coins** that anyone can grab.
- **Announcement:** a server-wide banner, "✨ A **GOLDEN WOLF** appeared at [owner]'s factory!", and a chime.
- **Reward:** big (section 9). It's a chase event, not a fight.
- **Counter:** cut it off and predict its turns. A charged hit drives it off in one go if you can land it.

### ❄️ Frost Wolf (Guard, tank)
- **Style:** white with blue-grey markings and icy cyan eyes. Frost mist drifts off its fur, and footprints leave
  little frost patches that fade in 3 s. It moves slowly and heavily.
- **Stats:** Resolve 6 + **Ice Armour 2**, speed 13 studs/s.
- **Ability 1: Ice Armour.**
  - Ice crystals cover its back and shoulders (a slightly transparent ice shell or ice-shard parts welded to bones).
  - Each normal hit **cracks** a layer (crack VFX and an ice "tink") without draining Resolve.
  - A **charged hit shatters all armour** in a big satisfying ice explosion, plus 3 Resolve damage.
  - The armour regrows once, 12 s after it breaks.
- **Ability 2: Frost Breath.**
  - **Range and timing:** a 7-stud cone, 1 s long, 6 s cooldown.
  - **Telegraph:** 0.7 s: rears its head back, cold mist gathers in the jaw, a crystal-hum sound rises.
  - **Effect:** players in the cone are **Chilled**: **-40% move speed and slower swing for 2.5 s**, with blue frost on
    the screen edges, a frosted body and breath puffs.
- **Counter:** step out of the cone sideways, then charged-hit it to strip the armour.

### 🌌 Celestial Wolf (Guard, trickster)
- **Style:** night-sky fur with stars and nebula, gold eyes. Faint star particles float off it, and a soft violet
  aura glows under it. Its movement is graceful, almost floating, with stretched strides.
- **Stats:** Resolve 5, speed 17 studs/s.
- **Ability 1: Blink (teleport).**
  - **Telegraph:** 0.4 s: its body shimmers, stars swirl inward, a rising "whoom".
  - **Effect:** it vanishes in a burst of stars and reappears **8–12 studs away**, usually behind or beside the
    attacker, with a reverse burst and a "shhing".
  - **Triggers:** when hit (30% chance) or when a player charges near it. Cooldown 6 s.
  - It can't be hit during the blink.
  - **Counter:** a charged hit **during the 0.4 s shimmer cancels** the blink and staggers it.
- **Ability 2: Starfall Decoys (at 50% Resolve, once).**
  - It splits into **itself + 2 decoys** in a flash, and they spread out.
  - Decoys copy its movement, but they're **slightly see-through, have no shadow and no eye glow**. That's the tell
    for sharp players.
  - Hitting a decoy pops it into stars ("Fake!") with no damage. A charged hit on any decoy pops **all** decoys.
  - Decoys fade after 10 s.
- **Ability 3: Star Pounce.** Its lunge leaves a trail of stars, and landing drops a small star ring (3 studs) that
  dazes for 0.5 s.

### 🌑 Shadow Wolf (Hunter, night stalker)
- **Style:** near-black with glowing red eyes, a battle scar and wisps of dark smoke rising from the fur. It moves
  low and stalking, then explodes into fast bursts.
- **Stats:** Resolve 6, speed 15 studs/s stalking, 24 sprint.
- **Ability 1: Night Stealth.**
  - At night, farther than **20 studs** from any player, its body is almost invisible (`Transparency` about 0.85,
    smoke only). Only its **two red eyes** glow clearly, plus soft footstep sounds.
  - Inside 20 studs or once hit, it fades in over 0.4 s with a low "reveal" sting.
  - By day it's fully visible (and it rarely spawns by day).
- **Ability 2: Ambush Pounce.**
  - From stealth, a lunge with a **shorter telegraph (0.45 s)** but a clear one: eyes flare, a sharp growl and a
    smoke burst at its feet.
  - If it lands: 22 damage and **Dazed 1.5 s**.
  - **Counter:** listen and look for the eye flare, then sidestep for a counter hit.
- **Ability 3: Pack Howl.** At 50% Resolve at night, it calls one Shadow pack companion: a 0.7-scale wolf with
  Resolve 2 that leaves when the main wolf is driven off.

### 🔥 Ember Wolf (Hunter, saboteur)
- **Style:** charcoal with glowing molten cracks, orange eyes and ember fur tips. Floating embers and heat shimmer
  rise from its back, it gives a warm orange `PointLight`, and each footstep leaves a tiny short-lived flame. Its
  movement is aggressive and bouncy, like a coiled spring.
- **Stats:** Resolve 6, speed 18 studs/s.
- **Ability 1: Fire Bite.** Its Snap and Lunge set the player **on fire (Burning)**:
  - the player has flames on their body, an orange vignette on the screen edges, and a crackle sound
  - **5 damage per second for 3 s** (it still respects the 15 HP floor)
  - **put it out early** by jumping into water, standing under a factory sprinkler (if I add one later), or pressing
    a short "stop, drop & roll" (crouch/roll key, 0.8 s, then the fire is out) — tell me which one fits the controls
- **Ability 2: Flame Trail.** While sprinting, it leaves fire patches (2-stud circles, 4 s) that **ignite** players
  who step in.
- **Ability 3: Scorch.**
  - Instead of stealing, an Ember Wolf can target a **machine/workstation** and scorch it.
  - **If it finishes the 5 s bite:** the station is **Scorched** (blackened, smoking, stopped) until a player
    **repairs it (hold E for 3 s)**.
  - **Interrupting it:** any hit during the scorch cancels it.
- **Ability 4: Ember Burst (at 50% Resolve, once).**
  - **Telegraph:** 1 s: crouches, glows brighter, a rising roar.
  - **Effect:** a fire ring explodes outward (8 studs). Players hit take 15 damage and catch fire.
  - **Counter:** jump over the ring or run out.

---

## 6. Animations (must look professional)
The wolf is driven by **Bones**. Use a mix of authored `Animation`s (if the rig supports them) and **procedural
layers**, the way the existing `CatGait`/`DogGait` works. Re-tune the gait for the wolf's longer legs. Everything
blends smoothly (0.1–0.25 s cross-fades), with no snapping, no T-pose and no sliding feet (gait speed matches the
movement speed).

**Always-on procedural layers (all states):**
- **Breathing:** chest and spine rise and fall (0.6 Hz idle, 1.5 Hz after running), with mouth panting (jaw -8° to
  -12°) after sprints.
- **Head look-at:** the neck and head turn toward the current target (player or loot), clamped to ±60° yaw and
  ±25° pitch, with smoothing.
- **Ears:** they react to state:

  | State | Ears |
  |---|---|
  | Calm | up |
  | Alert | forward and twitching |
  | Angry or attacking | pinned back |
  | Defeated | flat |
  | Random | small flicks |

- **Tail:** spring-physics follow-through on the 6 tail bones:

  | State | Tail |
  |---|---|
  | Calm | low sway |
  | Alert | stiff, out straight |
  | Running | streams behind |
  | Defeated | tucked between the legs |

- **Jaw:** the jaw bone matches every snarl, bite, howl and pant. **Stolen boxes/pastries are welded to the jaw**, so
  they move with the mouth.

**State animations:**

| Animation | How it must look |
|---|---|
| Idle | weight shifts between legs, sniffs the air (head up, small nose twitches), looks around |
| Trot / Run / Sprint | 3 gaits matched to speed. Spine flexes, head bobs, and the body leans into turns (roll 5–10° on curves). The sprint is a real gallop: front and back legs bunch and extend. |
| Stalk (Hunters) | body low (hips and chest lowered about 25%), slow deliberate steps, head level and forward, tail low and still |
| Sniff and bite (stealing) | nose down, quick sniffs, then the bite loop: head pulls and shakes side to side, jaw open and closing, small body jerks backward |
| Carry loot | head higher, box in jaws, proud prance (Golden) or sneaky low run (Timber) |
| Warn / snarl | head low, shoulders up, jaw open -30° with a lip-curl shake (small fast jaw jitter), ears pinned, slow sideways circling steps |
| Snap | quick forward head strike (0.15 s), jaw snaps shut on the active frame |
| Lunge wind-up | crouches over 0.6 s, back legs coil, front paws dig in, body trembles slightly |
| Lunge | leaps forward in an arc, front legs reaching, jaw wide (-40°), body stretched; lands on the front paws with a squash |
| Exposed (missed lunge) | skids, front legs splay, stumbles and shakes its head (1.2 s) |
| Hit react | a flinch **away from the hit direction**: a quick body twist, head turns, one step back. Different hits use slightly different reactions so it doesn't look repetitive (at least 2 variants). |
| Stagger (charged hit) | launched back in an arc, rolls once, scrambles up, head wobbles with dizzy stars (1.5 s) |
| Howl | sits back on its hind legs, chest up, head tilted back, jaw opens slowly, ears up, tail still |
| Frost Breath | rears back, then thrusts its head forward with the jaw wide for the 1 s breath |
| Blink | body stretches and shrinks into the star burst, and reverses on arrival |
| Ember Burst | crouch with the body glowing brighter, then explodes up into a rearing pose |
| Scratch door / scorch machine | paws at the door or machine, head tilts, impatient huffs |
| Defeated / retreat | yelp (head jerks up), ears flat, tail tucked, head low, quick look back over the shoulder, then a fast slightly limping cartoon gallop away |

**Player animations:**
- **Bat swing:** keep the existing swing, but add a short **hit-stop** (freeze 0.05 s on contact, 0.08 s on
  counters and charged hits).
- **Charging:** the bat glows brighter with charge, the character crouches slightly, and the pose shakes a little at
  full charge.
- **Reactions:**
  - flinch (small hits)
  - knockback stumble (lunge)
  - dizzy (dazed)
  - **knocked down** fall and get-up
  - **stop-drop-roll** (Ember fire)
  - chilled (shivering, breath puffs, slower walk)
- **Help-up animation:** reach down and pull up.

---

## 7. VFX (clean, readable, satisfying)
Use `ParticleEmitter`s, `Beam`s, `Trail`s, `Highlight`s and small meshes. Keep particle counts sensible (see
section 11). Effects should be **crisp and stylised** like the rest of the game, not muddy smoke everywhere. Colours
always match the wolf type's eye colour so players learn them.

**Per-wolf ambient aura (always on while it exists):**

| Type | Aura |
|---|---|
| All | **eye glow**: two small neon parts or attachments with `PointLight`s at the eye positions in the type's colour; brighter in Warn/WindUp, fades out on defeat |
| Timber | none beyond the eye glow (it's the baseline) |
| Golden | sparkle particles, a gold trail from the tail, a soft gold light, and a gold `Highlight` outline on Full Moon nights |
| Frost | drifting snow and mist particles, frost footprints (decals that fade), cold breath puffs from the mouth |
| Celestial | slow star motes rising, a faint violet ground glow (a `Beam` disk or decal), shimmering twinkles on the fur |
| Shadow | dark smoke wisps rising from the back, much stronger at night; the eye glow leaves a short red trail when it moves fast |
| Ember | floating embers, heat shimmer above the back (a subtle refraction-like particle), flame footsteps, a warm flickering light |

**Combat VFX:**
- **Normal hit on a wolf:**
  - a white impact star burst (6–10 particles), a small fur tuft puff in the coat colour, a shock ring
  - the wolf flashes white for 0.06 s (a quick `Highlight`)
  - a short camera shake (small)
  - a damage pop: "-1" in white
- **Counter hit:**
  - a gold impact burst plus a radial line flash
  - "COUNTER!" pop text in gold with a slight scale bounce
  - a bigger camera shake
- **Charged hit:**
  - a big impact with layered rings, sparks and a dust burst at the landing spot
  - a speed-line trail as the wolf flies back
  - dizzy stars over its head while staggered
  - "-3" in the type colour
- **Lunge wind-up:**
  - the eyes flare
  - a **red ground indicator** in front of the wolf grows during the wind-up, showing the lunge path (a thin decal
    arrow). It's subtle but readable; Hunters at night use a fainter one.
- **Lunge landing:** a dust puff, plus type extras (Ember fire puff, Celestial stars, Shadow smoke).
- **Player hit:**
  - the screen edge flashes red briefly
  - a knockback dust trail
  - stars over the head when Dazed
- **Status effects on the player:**

  | Status | Body effect | Screen effect | Icon (top-left, with a timer ring) |
  |---|---|---|---|
  | Burning | flames on the limbs and torso, ember particles, orange light | orange vignette | flame |
  | Chilled | frost overlay (a cyan `Highlight`), breath puffs | ice frost on the screen edges | snowflake |
  | Dazed | stars circling the head | a slight wobble/blur | stars |

- **Ability VFX:**
  - **Ice Armour:** crack decals per hit; shattering throws ice shards, cyan sparkles and a frost ring
  - **Frost Breath:** a cone of cold mist and ice crystals plus a ground frost decal
  - **Blink:** a star implosion, then a star explosion, with a thin trail line between the two points for 0.2 s
  - **Decoys:** a split flash; popping a decoy gives a star poof and "Fake!"
  - **Shadow reveal:** a smoke burst and eyes flare
  - **Ember Burst:** an expanding fire ring along the ground with a heat ripple
  - **Fire patches:** short flame and ember particles on a scorched decal
  - **Scorch:** the station blackens (a darker colour or texture overlay), smoke rises, and small embers stay until
    repaired, with a repair progress ring
- **Resolve bar** (`BillboardGui`, max distance 60):
  - the type icon and name in the type colour, and segments that each crack and fall off when lost
  - Frost armour shows as cyan segments in front
  - the bar shakes a little when hit
  - it's hidden when the wolf is in stealth
- **Defeat:** the bar shatters, a "DRIVEN OFF!" banner over the wolf, then a coin burst. On retreat: a dust trail,
  and at the edge a leaf/dust puff (Golden: sparkle puff; Celestial: star puff).
- **Escape with loot:** a "STOLEN!" red pop and a sad trombone-ish sting for the owner (cartoony, short).
- **Recovered loot:** the box glows green, with a "RECOVERED!" pop.

---

## 8. Sounds (layered, positional, polished)
Find good sounds on the Creator Store that are **public/usable in my experience**. Check that each one actually
plays (no moderated or private assets). Tell me every asset ID you use, in a list.
- **Positional audio:**
  - all wolf sounds are 3D (`RollOffMode = InverseTapered`, max about 80 studs; howls about 250)
  - organise everything in `SoundGroups`: Music, Ambience, SFX, Wolves, UI
- **Variation:** every repeated sound gets **random pitch (±6–10%)** and at least **2–3 variants**, so it never
  sounds robotic.

| Event | Sound |
|---|---|
| Raid warning | a distant howl (type-specific: Shadow deeper, Celestial with a reverb shimmer, Golden with a chime layer), plus a short tense music sting |
| Footsteps | soft paw padding synced to the gait (louder on wood floors if possible); Ember adds a tiny fire crackle |
| Sniff / bite / box tear | sniff snorts, cardboard rip, chomp |
| Growl / Warn | a low rumbling growl that loops while warning and gets louder as you get closer |
| Snap | a sharp jaw click plus a short bark-growl |
| Lunge | a rising snarl in the wind-up, a whoosh in the air, a thud on landing |
| Howl | a full howl with a reverb tail |
| Hit on a wolf | bat **thwack** plus a yelp-grunt (not a pained cry; keep it cartoony) |
| Counter | a heavier thwack plus a bright "ting" accent |
| Charged hit | a big bonk plus a whoosh as the wolf flies, then a dizzy "birdies" tweet loop while staggered |
| Ice armour | "tink" crack per hit and a glass/ice shatter on break |
| Frost breath | a cold whoosh with a crystal hum |
| Blink | a "whoom" in, a "shhing" out; decoy pop = a sparkle pop |
| Shadow reveal | a low whoosh plus a heartbeat-ish thump |
| Fire | ignite "fwoomp", burning crackle loop on the player, extinguish hiss |
| Ember Burst | a rising roar, then a fire explosion |
| Driven off | yelp plus a short victory jingle (bright, about 1.5 s) |
| Stolen | a short "aww" / sad sting |
| Coins | the existing coin collect sound |

- **Combat music:** when a wolf is fighting the local player, crossfade in a **tense, light combat loop** (about
  0.5 volume) over 1 s, and fade it out 4 s after combat ends. Full Moon nights have a slightly more intense
  variant.
- **Mix:** wolves must be audible over the factory machines. Duck the ambience by about 30% during combat.

---

## 9. Rewards
Pay on the **server** through the existing economy (`DataService` coins, leaderstats, the `CoinCollect` effect).

| Type | Base coins for driving it off |
|---|---|
| Timber | 60 |
| Pack companion | 25 |
| Frost | 120 |
| Celestial | 140 |
| Shadow | 150 |
| Ember | 150 |
| Golden | 400 + the coins dropped per hit (15 each, physical pickups) |

- **Multipliers** (config):
  - scale with the player's progression (use whatever income/level stat exists and tell me which)
  - Full Moon ×1.5
  - **Flawless** (driven off without the attackers being hit) +25%
  - each **Counter** +10 coins
- **Who gets paid:**
  - everyone who hit the wolf gets a share by Resolve dealt (minimum 20% of the base each)
  - the **factory owner** always gets at least the base reward if their factory was defended
- **Bonuses:**
  - **Saving a box** before it's stolen: +35% of the box's value (keep the old "SAVED!" reward)
  - **Recovering** a box from an escaping wolf: +20%
- **Rare drop** (optional; ask me first): a 3–5% chance of a **wolf trophy** (a type-coloured fang) for a future
  trophy shelf.
- **No farming:**
  - only naturally spawned wolves pay
  - admin-spawned wolves pay nothing unless I turn on an admin flag
  - one reward per wolf

---

## 10. UI and feedback summary
Make the UI clean, bold and consistent with my existing UI style (look at it first).
- **Raid banner**: wolf type icon, name in colour, a short flavour line, and a slide-in/slide-out animation.
- **Direction indicator**: an edge-of-screen paw arrow in the type colour, pulsing; it hides when the wolf is on
  screen.
- **"You're being hunted!"** indicator (Hunters) with a red paw marker.
- **Resolve bar** (section 7) and **status icons** with timers (Burning, Chilled, Dazed).
- **Result pop-ups:** DRIVEN OFF!, COUNTER!, SAVED!, RECOVERED!, STOLEN!, Fake!
- **First-encounter tip cards** per wolf type: a 1-line description and the main counter, shown once per player
  (saved in data).
- **Day/night clock** (section 1c).
- **Settings toggles:** "Reduce screen shake" and "Reduce flashing effects". Respect them everywhere.
- **Mobile:** every indicator readable on a phone; no UI covering the swing/charge button.

---

## 11. Performance, networking and bug-proofing
- **Server owns** wolf AI, Resolve, abilities, status effects, damage and rewards. Clients do visuals only.
  - Wolves are server-owned (`SetNetworkOwner(nil)`) and can't be pushed or flung by players.
  - Validate every remote (rate limits, distance, state).
- **Animation:** run the bone animation **on the client** for smoothness, driven by a replicated state attribute
  (`WolfState`, `Target`, `Speed`). Don't replicate bone transforms from the server every frame.
- **Budgets:**
  - max 8 wolves on the server
  - per-wolf particle rates kept low (ambient aura under about 30 particles alive)
  - effects and bone animation disabled or simplified for wolves **farther than 120 studs** (LOD: stop the gait
    animation and leave a basic pose, keep the eye glow)
  - no per-frame `Instance.new`: pool VFX parts and particles
- **Cleanup:** wolves, decoys, fire patches, frost patches, welded loot and status effects are always destroyed or
  reset when:
  - the raid ends
  - the owner leaves
  - the factory unclaims
  - a player dies or resets
  - the server shuts down

  No leftover burning players or stuck debuffs.
- **Edge cases:**
  - a wolf whose target box is sold or moved re-targets
  - a player who leaves mid-fight is removed from the reward split
  - a wolf stuck in geometry retreats
  - two wolves don't target the same box
  - Celestial never teleports inside walls or off the map (raycast and nav check the destination; if no valid spot,
    skip the blink)
  - fire and frost status effects don't stack beyond one instance (refresh the timer instead)

---

## 12. Config module (`ReplicatedStorage.Shared.WolfConfig`)
Everything tunable lives here:
- day/night lengths, lighting presets, Full Moon frequency
- spawn intervals and weights, unlock rules, pack rules
- per-type stats (Resolve, speed, armour, abilities, cooldowns, damage, ranges, telegraph times)
- hit damage values (normal/counter/charged and charge thresholds), multiplayer scaling, hit immunity
- player rules (HP floor, knock-down, statuses)
- rewards and multipliers
- VFX and sound IDs, LOD distances

---

## 13. Admin panel additions
Add these to my owner-only admin panel (same style and permission checks as the existing commands):

| Command | What it does |
|---|---|
| **Spawn wolf** | dropdown of the type (+ pack size), spawns it at the selected player's factory; pays no rewards unless the "admin rewards" flag is on |
| **Set time** | Day / Dusk / Night / Dawn |
| **Force Full Moon** | the next night is a Full Moon night |
| **Pause raids** / **Clear all wolves** | — |
| **Wolf debug** | shows each wolf's state, target, Resolve and perception cones (sight radius and line-of-sight rays), for testing |

---

## 14. Test before you tell me it's done
Run playtests (including a 2-player local server test) and check:
- [ ] A full 12-minute day/night cycle runs smoothly. Lighting, sky, moon, lamps, ambience and the clock all
      transition without snapping, and a late joiner sees the correct time.
- [ ] Every wolf type spawns with the right coat, eyes, aura and sounds, and its temperament behaves as described
      (Thief ignores you until hit; Guard warns then attacks; Hunter stalks then attacks).
- [ ] The hit counts match the Resolve table for normal hits, charged hits and counters. A charged hit no longer
      instantly ends the fight; it does 3 Resolve + stagger, shatters Frost armour, cancels a Celestial blink and
      knocks loot free.
- [ ] Every attack has a visible and audible telegraph and can be dodged; a missed lunge leaves the wolf Exposed.
- [ ] Burning, Chilled and Dazed work, show the right VFX and icons, expire correctly and can't stack or get stuck.
- [ ] Players can never die from wolves; knock-down and help-up work.
- [ ] Driving a wolf off plays the full defeat → retreat sequence, the wolf can't be hit while leaving, it never
      vanishes on the spot, and rewards are paid correctly and only once (and split in multiplayer).
- [ ] Stealing, escaping, recovering and Ember scorch/repair all keep box and station data correct
      (no duplicated or lost boxes).
- [ ] New players only see Timber wolves until unlocks; the first-encounter tips show once.
- [ ] No errors or warnings in the output during a full Full Moon night with 3+ wolves; frame rate stays smooth;
      the Wolf debug view shows sensible states.

Then send me a report with:
- what you built and changed, and what you backed up
- every asset ID used (sounds, textures, particles)
- the expected raids per day
- anything you couldn't do or want me to decide
