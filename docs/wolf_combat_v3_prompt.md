# Prompt: Wolf combat 3.0, make it a real fight (paste into Claude with Roblox Studio MCP)

You built Wolf Raids 2.0. I've playtested it, and the fight is **far too easy and too bare**:
- Wolves take so long to attack that you can just walk out of the way.
- The only attack I ever see is a slow lunge.
- **The special abilities never happen.** The Celestial wolf never teleports, the Frost wolf never uses Frost
  Breath, and the Ember wolf never sets me on fire.
- Attacks have almost no effects. There are no slashes, impact flashes, screen shake or sounds that sell the hit.
- There's no real consequence for losing.

This update makes the wolf fight **hard, fast, flashy and dangerous**, like a boss fight in a front-page Roblox
game. A wolf should be able to **beat a careless player**. A good player should win by reading attacks, dodging at
the right moment and punishing openings, and should feel proud of winning.

This prompt **overrides** these parts of the 2.0 prompt:
- the "players can never die" rule, the 15 HP floor, the knock-down and the help-up (section 4d): **removed**
- the slow telegraph timings (section 4c): replaced by the faster ones below
- the Resolve numbers (section 3a): replaced by the table below

Everything else from 2.0 (day/night, wolf types, coats, rewards, admin commands, config module) stays. Wolves
themselves are still never killed: when their Resolve hits 0 they give up and run off, as before.

---

## 0. First: find out why the abilities never fire (do this before anything else)
Don't just tweak numbers. Find the actual cause and tell me what it was. Common causes to check:
1. The AI's decision code only has a path to `Lunge`. Abilities exist as functions but are never chosen.
2. The ability conditions are too strict or never true at the same time. Example: Frost Breath needs the player
   within 7 studs, but the wolf always lunges from 8–16 studs and never gets that close.
3. Cooldowns start "used" (for example `lastUsed = os.clock()` at spawn), or are never reset, or every ability shares
   one cooldown that the lunge keeps using.
4. Random chances are rolled every frame or never rolled at all (for example the 30% blink-on-hit chance is never
   evaluated because the hit handler doesn't call the AI).
5. The ability runs on the server, but nothing tells the clients, so it happens with no VFX or animation and looks
   like nothing happened. Or it's the other way round: VFX play but the server logic never runs.
6. A state bug: the wolf is stuck in `Chase`/`Lunge` and never returns to the state where abilities are chosen.
7. Config flags are off, or the type lookup fails (for example `WolfType` is "Frost" but the config key is "FrostWolf").

**Add a debug log** (only when the admin "Wolf debug" toggle is on) that prints every decision:
`[Wolf Frost#3] state=Engage choose=FrostBreath (dist 6.2, cd ready) → WindUp`. Run a fight against each type and
confirm in the log that every ability fires. Include the log summary in your report.

---

## 1. Player health, death and the "the wolf got you" sequence
Players can now lose. This is what makes the fight matter.

### 1a. Health
- Players have **100 HP** (normal Roblox Humanoid health).
- **No health regen during combat.** Regen only starts 6 s after the player last took or dealt wolf damage, at
  5 HP/s.
- Show a clean **health bar** (bottom centre or near the hotbar, in my UI style) that appears when damaged:
  - smooth drain with a white "recent damage" chunk that catches up after 0.4 s
  - red pulse and heartbeat sound under 25 HP
  - hidden again 5 s after full health

### 1b. Death (health reaches 0)
1. **Ragdoll.** The player's character goes limp and falls naturally.
   - Set `Humanoid.BreakJointsOnDeath = false`.
   - On death, replace each `Motor6D` with a `BallSocketConstraint` (+ `Attachment`s at the joint positions), with
     sensible `LimitsEnabled`/`UpperAngle`/`TwistLimits`, so limbs don't bend backwards or spin.
   - Apply a push in the direction of the killing hit (for example 40 studs/s away from the wolf plus a little
     upward), so it reads as "the wolf knocked me down".
   - Do the ragdoll so it looks the same on every client (server-side constraints, physics owned by the dead player or
     the server, whichever is smoothest; test it).
   - The bat drops from the hand (or is hidden). Nothing must fling wildly or fall through the floor.
2. **Death camera on the wolf.**
   - The camera smoothly leaves the player (0.6 s ease) and switches to a cinematic shot of the wolf:
     `Camera.CameraType = Scriptable`, positioned about 10–14 studs behind and above the wolf at a 3/4 angle,
     following with smooth damping (no jitter) and always keeping the wolf centred.
   - Add **letterbox bars** (black bars sliding in top and bottom), a slight desaturation and vignette, and muffle the
     game audio.
   - Show a caption, for example: "**The Shadow Wolf** stole your **Choco Pastry Box!**" (wolf name in its colour).
3. **The wolf steals and runs.**
   - The wolf **howls in victory** (short, 1 s, the howl animation).
   - It goes to the raided factory, grabs the **most valuable box** (through `BoxService`, so the data stays correct),
     carries it in its jaws and runs to the treeline.
   - The camera follows it the whole way.
   - **If there's no box,** the wolf grabs nothing, howls again and runs off.
   - **Other living players can still stop it.** If someone drives it off before it escapes, the box drops and is
     recovered, and the dead player's camera shows this ("RECOVERED by [name]!").
4. **Respawn.**
   - When the wolf leaves the map (or after **8 s max**), fade to black (0.4 s), respawn the player at their factory
     spawn, and fade in.
   - Use `Players.CharacterAutoLoads = false` (or a long `RespawnTime`) and call `LoadCharacter` yourself, so the
     respawn happens only after the death cam.
   - Make sure this doesn't break anything else that relies on respawning (check for other systems first, such as
     falling off the map or resetting).
   - Give **3 s of spawn protection** (a soft shield shimmer; wolves won't target that player).
   - A small message: "You were defeated by the Shadow Wolf. Watch for the red eyes!"
5. **Edge cases:**
   - Deaths from other causes (falling, resetting) use the normal respawn with no wolf cam.
   - A player leaving during the death cam must not break the wolf.
   - The wolf that killed someone ends its raid after the steal. It doesn't stay to farm more kills.
   - Two players dying to the same wolf both watch it.

---

## 2. What makes a fight hard (the design rules)
Apply these rules to every wolf. The goal is **constant pressure, fast attacks, variety, and small but fair
openings**.

1. **Wolves are faster than players.** Player `WalkSpeed` is 16 (check the real value). Wolves move at **20–28**, so
   you can't just walk away. You have to dodge sideways at the right time.
2. **Fast telegraphs.** Every attack still has a wind-up, but it's short (0.2–0.45 s). That's enough for an alert
   player to react, not enough to stroll away. Never longer than 0.5 s except for big special moves.
3. **Tracking.** During the wind-up the wolf **keeps turning to face the player** and aims where the player is
   going (lead the target by their velocity × 0.25 s). The direction only **locks for the last 0.12 s**. Running in
   a straight line gets you hit. Sidestepping at the last moment is the dodge.
4. **No idle time.** In combat, a wolf is never standing still for more than 0.6 s. Between attacks it **circles**
   the player at 6–10 studs (strafing left or right, switching direction randomly), darts in and out, and feints.
5. **Combos.** Wolves chain attacks: Snap → Snap, or Snap → Lunge, or Lunge → Snap on landing. A dodge on the first
   hit doesn't mean you're safe.
6. **Feints.** About 20% of the time a wolf starts a lunge wind-up and **cancels it** after 0.2 s (it hops back
   instead), to bait swings. Players who swing at nothing get punished with a quick Snap.
7. **Dodging your swings.** When a player starts a swing within 7 studs, the wolf may **hop sideways or back**
   (3.5 studs, 0.25 s). Chance by type: Timber 15%, Frost 5%, Shadow 25%, Ember 20%, Celestial 30% (it blinks
   instead), Golden 40%. Cooldown 2 s, so it can't dodge everything.
8. **Poise (it doesn't flinch from every hit).** Each wolf has **Poise**. Normal hits drain Poise, and the wolf only
   flinches (and its attack is cancelled) when Poise breaks:

   | Type | Poise (normal hits before a flinch) |
   |---|---|
   | Timber | 2 |
   | Golden | 1 |
   | Celestial | 2 |
   | Shadow | 3 |
   | Ember | 3 |
   | Frost | 4 |

   - Poise refills after 2 s without being hit.
   - **Charged hits and Counter hits always break Poise.**
   - During **special abilities** the wolf has **super armour**: normal hits do Resolve damage but don't interrupt
     it. Only a charged hit (and for Celestial, a hit during the blink shimmer) interrupts.
   - So you can't just spam-click a wolf to death while it's helpless.
9. **Small punish windows.** After a missed lunge the wolf is **Exposed for 0.8 s** (was 1.2). After a big ability
   it recovers for 0.6–1 s. These are the moments to hit it. The skill is waiting for them.
10. **Aggression ramps up.** Each wolf has an Aggression value that rises over the fight. At 50% Resolve it
    becomes **Enraged**:
    - eyes blaze brighter and its aura doubles
    - attacks 20% faster and cooldowns 25% shorter
    - it gets its "phase 2" ability (section 4)

    The second half of a fight must feel harder than the first.
11. **Bat reach.** Check the bat's hit range against the wolf hitbox so hits feel fair. Hits should register when
    the swing visibly connects, not only point-blank.

### 2a. Resolve and damage (replaces the 2.0 table)
A normal hit still does 1 Resolve, a Counter does 2 and a charged hit does 3.

| Type | Resolve | Damage per bite (Snap) | Lunge damage | Speed (circle / chase) | A careless player dies in about |
|---|---|---|---|---|---|
| Timber | 8 | 12 | 20 | 20 / 24 | 8 bites / 15 s |
| Golden | 4 | — (never attacks) | — | 28 / 30 | — |
| Frost | 12 (+3 Ice Armour) | 14 | 24 | 17 / 20 | 12 s (slows you first) |
| Celestial | 10 | 12 | 22 | 22 / 26 | 12 s |
| Shadow | 10 | 16 | 30 | 22 / 28 | 10 s |
| Ember | 10 | 12 (+ burning) | 22 (+ burning) | 21 / 25 | 10 s |
| Pack companion | 4 | 8 | 14 | 20 / 24 | — |

- Multiplayer scaling stays (×1.35 max Resolve per extra attacker).
- **Day vs night:** at night all wolves get +15% damage. On Full Moon nights, +25% damage and +2 Resolve.
- **New players** (first 10 min of playtime) only meet Timber, which deals **60% damage** during that time, so the
  first fights teach rather than punish.
- **Target feel:** a skilled player beats a Timber wolf in about 20–30 s while taking 20–40 damage. A Shadow or
  Ember wolf at night should be genuinely dangerous: about half of new players should lose their first fight
  against one.

### 2b. Attack timings (replaces the slow ones)

| Attack | Wind-up (telegraph) | Active | Recovery | Range | Cooldown |
|---|---|---|---|---|---|
| Snap (bite) | **0.25 s** | 0.1 s | 0.35 s | 4.5 studs, 80° cone | 0.9 s |
| Double Snap | 0.25 s, then 0.15 s | 0.1 s ×2 | 0.45 s | 4.5 studs | 2.5 s |
| Lunge | **0.4 s** | ~0.45 s air time | 0.3 s on hit / **0.8 s Exposed** on miss | 6–18 studs | 2.5 s |
| Pounce-turn (Lunge → Snap) | — | after landing, a 0.15 s wind-up Snap if the player is within 5 studs | — | — | — |
| Feint | 0.2 s of lunge wind-up, then a hop back | — | — | — | — |

- **Lunge path:** an arc to the predicted position. Its hitbox is a capsule along the wolf's body (radius about
  1.5 studs) that is active the whole flight, so it isn't one tiny point check.
- **Hit registration:** server-side with lag forgiveness (use the player's position as of their ping/2 ago, capped
  at 0.15 s). Fast, but fair.

---

## 3. Every attack needs real effects
Right now attacks look like nothing. Each attack needs **telegraph → action → impact** effects, with sound.
Colours use the wolf's type colour.

| Attack | Telegraph effect | Action effect | Impact effect (on the player) |
|---|---|---|---|
| Snap | eyes flare (brightness up and a small glint), jaw opens, short growl, a small red "!" spark above the head (0.25 s) | white **bite slash** effect: two curved arc meshes/beams closing like jaws in front of the mouth, plus a jaw "clack" | red hit flash on the player (`Highlight` 0.1 s), a small blood-free **impact star burst** in the type colour, 2 thin claw-scratch streaks across the screen edge, camera shake (small), damage number in red |
| Lunge | crouch, ground **dust kick** at the back paws, rising snarl, eyes leave a short **light streak**, a faint red arrow decal on the ground in the lunge direction (fainter at night for Hunters) | body **motion trail** (Trail on the spine in the type colour), air whoosh, speed lines | big impact burst with a shock ring, the player is knocked back with a **dust trail**, camera shake (medium), a short red vignette pulse, heavy thud |
| Double Snap | as Snap, but two quick red sparks | two slashes | two impacts |
| Feint | half the lunge telegraph | a hop back with a small dust puff and a growl | — |
| Dodge hop | — | a quick dash smear trail and dust puff | — |
| Enrage (at 50%) | the wolf stops for 0.5 s and roars with jaw wide | an aura burst ring in the type colour, the eye glow doubles, a permanent extra aura | a screen tint pulse in the type colour, "ENRAGED!" over the wolf |

**Player-side hit feel:**
- hit-stop on the **wolf's** hits too (0.04 s), so getting bitten feels heavy
- the camera shakes and nudges away from the hit direction
- a directional damage indicator shows where the hit came from (a red arc at the screen edge)
- under 25 HP: a heartbeat sound, a red vignette and a slight desaturation

All of these respect the "Reduce screen shake" and "Reduce flashing effects" settings.

---

## 4. Special abilities: they must actually fire, often, and look amazing
**Ability scheduler (fixes "they never use abilities"):**
- Each wolf has its **signature ability**. It **must** use it within the **first 5 s of combat**, and again every
  time it comes off cooldown when its condition is met.
- Don't use pure random chance for signature abilities. Use **cooldown + condition**, with a **"pity timer"**: if a
  signature ability hasn't fired for 10 s, the wolf **moves to make the condition true**. For example, Frost closes
  to breath range, and Celestial forces a blink.
- Abilities have their **own cooldowns**, separate from Snap and Lunge.
- **Decision order each think tick (every 0.1–0.15 s while engaged):**
  1. If Enraged and the phase-2 ability is ready → use it.
  2. If the signature ability is ready and its condition is met (or the pity timer fired) → use it.
  3. If the player is in Snap range → Snap / Double Snap.
  4. If the player is in Lunge range and the lunge is ready → Lunge (20% Feint).
  5. Otherwise circle and close the distance.
- Every ability: the server decides it and runs the hitboxes, damage and effects; it fires a remote to all nearby
  clients with `{wolf, ability, params, startTime}`; clients play the animation + VFX + sound, synced to
  `startTime`.

### ❄️ Frost Wolf
- **Signature: Frost Breath** (cooldown **6 s**)
  - **Condition:** the player within **9 studs** in front. If not, it advances while circling.
  - **Telegraph (0.45 s):** rears its head, jaw opens, **cold mist swirls into its mouth**, ice crystals form around
    the muzzle, a rising crystal hum.
  - **Action (1.2 s):** a **cone of freezing breath**: 10 studs, 45°, and it **sweeps** 30° toward the player while
    breathing, so you have to move out of it, not just stand to one side.
    - Visuals: thick white-blue mist particles, ice shards, a frost ground decal spreading along the cone.
  - **Effect:**
    - 6 damage per 0.3 s inside the cone
    - **Chilled** (-45% speed, slower swings) for 3 s
    - if you stay in the cone for 1 s or more you're **Frozen solid for 1.2 s**: an ice block mesh around the player,
      no movement or swinging, the wolf gets a free bite
    - mash space or click to break out 30% faster
- **Ice Armour** (from 2.0) stays: a charged hit shatters all of it.
- **Phase 2 (Enraged): Ice Spikes.**
  - Slams its front paws, sending a line of 5 ice spikes along the ground toward the player (telegraph: a frost
    crack line on the ground, 0.5 s).
  - Each spike erupts 0.08 s after the previous one: 18 damage and knock-up.
- **Passive:** a frost aura. Players within 4 studs are slowed 15%.

### 🌌 Celestial Wolf
- **Signature: Blink** (cooldown **4 s**). It must blink a lot. This is its identity.
  - **When it blinks:**
    - **always** when hit and the blink is off cooldown (not a 30% chance)
    - when the player starts charging
    - at least once every 6 s in combat (pity)
  - **Telegraph (0.25 s):** shimmer, stars swirl into its body, a high "whoom".
  - **Action:** it vanishes in a **star burst** and reappears **behind the player** (or beside them if behind is
    blocked), 5–7 studs away, with a reverse burst and a "shhing". A thin glowing line between the two points fades
    in 0.2 s.
  - **Follow-up:** 60% of the time it attacks **immediately** after reappearing (a 0.2 s wind-up Snap or Lunge). This
    is the danger: turn around fast.
  - Check the destination with a raycast and the nav mesh. Never teleport into walls or off the map.
  - **Counter:** a charged hit during the 0.25 s shimmer cancels the blink and staggers it.
- **Second ability: Star Orbs** (cooldown 7 s)
  - **Telegraph (0.4 s):** its head lifts and 3 glowing orbs form above its back.
  - **Action:** they fire one after another at the player as slow **homing** stars (speed 22, turning 90°/s, lasting
    3 s).
  - **Effect:** 10 damage each. They can be dodged by strafing, and hitting an orb with the bat pops it.
- **Phase 2 (Enraged): Starfall Decoys + Meteor.**
  - It splits into itself + 2 decoys (as in 2.0, but the **decoys also attack**, with Snap only, for 50% damage).
  - Once, it calls a **star meteor**: a glowing circle on the ground under the player, 1 s warning, then a star
    crashes down for 30 damage in a 6-stud radius.

### 🔥 Ember Wolf
- **Signature: Fire Bite** (every Snap and Lunge)
  - Hits set the player **Burning**: flames on the body, an orange screen vignette and a crackle; **4 damage every
    0.5 s for 3 s**. More hits refresh it. It doesn't stack.
  - Jumping into water, or **stop-drop-roll** (the roll/crouch key, 0.8 s), puts it out early.
- **Signature 2: Flame Dash** (cooldown **5 s**)
  - **Telegraph (0.35 s):** the body glows brighter, embers swirl, a whoosh charges up.
  - **Action:** a straight **fire dash** 14 studs through the player's position, leaving a **burning trail** (fire
    patches for 4 s).
  - **Effect:** 20 damage + burning on contact. Standing in a fire patch burns you.
- **Third: Fireball Spit** (cooldown 6 s, only if the player is 10+ studs away, so you can't kite it)
  - **Telegraph (0.4 s):** a flame builds in the jaw.
  - **Action:** it spits a fireball that arcs to the player's predicted position.
  - **Effect:** it explodes in a 4-stud ring of fire: 15 damage + burning.
- **Phase 2 (Enraged): Ember Burst** (as in 2.0, but faster)
  - **Telegraph (0.6 s):** crouch, glow, rising roar.
  - **Action:** an expanding fire ring (10 studs) that you have to **jump over**: 25 damage + burning.
  - After enraging, its whole body has a constant **flame aura**. Players within 3 studs slowly burn, so you can't
    hug it.

### 🌑 Shadow Wolf
- **Signature: Vanish & Ambush** (cooldown **6 s**)
  - It **fades into shadow** (dissolves into smoke, almost invisible except for its red eyes; fully invisible
    eyes-off for 0.5 s at night) and repositions out of the player's view.
  - Then it **ambushes**: a pounce from the side or behind, with a **short but clear telegraph** (0.35 s): its eyes
    reappear with a flare, a sharp growl and a smoke burst.
  - **Effect:** 30 damage + **Dazed 1 s**.
  - **Counter:** listen for the growl, sidestep, then counter-hit it while it's Exposed.
- **Second: Shadow Clones Lunge** (cooldown 8 s)
  - **Telegraph (0.4 s):** 2 smoky afterimages flank it.
  - **Action:** all three lunge at once from different angles. Only the real one deals damage (the smoke ones fade
    on contact), but you don't know which is real until the last moment.
  - **Tell:** the real one has a shadow on the ground.
- **Phase 2 (Enraged): Pack Howl + Darkness.**
  - It calls 1 Shadow pack companion.
  - It shrouds the area: the screen darkens at the edges for 6 s, and only wolf eyes glow brightly.

### 🐺 Timber Wolf (the baseline, but not a pushover)
- **Signature: Pack Tactics** (cooldown 5 s): a **Double Snap → Lunge** combo, with circling and feints. Teaches
  players how to dodge.
- **Grab & Dash** (from 2.0) stays for stealing.
- **Phase 2 (Enraged): Frenzy.** For 5 s its attack speed is +40% and it chains Snap → Snap → Lunge.

### ✨ Golden Wolf (a chase, not a fight)
- It never attacks, but it's hard to catch:
  - speed 28
  - zig-zags
  - dodge hop 40% (cooldown 1.5 s)
  - **Gold Flash** (cooldown 6 s): a blinding sparkle burst (a brief white-gold screen flash, reduced if "Reduce
    flashing" is on), then it sprints away 15 studs
- Every hit drops coins. It leaves after 25 s.

### Pack companions
- Smaller (0.7 scale) and simpler: Snap and Lunge only, and **they flank**. When a main wolf is engaging the player,
  companions circle to the player's back before attacking.

---

## 5. Animations must keep up
Everything is faster now, so animations must be snappy and readable, not floaty:
- Wind-ups use strong **anticipation poses** (crouch, head pulled back) that are clear even when short.
- Actions are fast with **follow-through** (the head overshoots on bites, the body skids on landing).
- Blend times are **0.06–0.1 s** in combat (not 0.25).
- Add the new animations:
  - Double Snap
  - Feint (start the wind-up, then hop back)
  - Dodge hop (left, right, back)
  - Circle strafe (a sideways trot facing the player)
  - Enrage roar
  - plus each new ability: Frost Breath sweep, Ice Spike slam, Blink, Star Orbs, Meteor call, Flame Dash, Fireball
    Spit, Ember Burst, Vanish, Ambush, Shadow Clones, Howl, Frenzy
- **The wolf always faces its target** during circling and wind-ups. Use body yaw plus head look-at, so it reads as
  focused and predatory.
- **Player:**
  - Frozen (stiff, encased in ice)
  - Burning (flailing arms while moving)
  - Stop-drop-roll
  - Dazed (stars, wobbly)
  - Ragdoll death

---

## 6. Sound
Every telegraph has its own sound, so players can **hear** what's coming without looking. This is a big part of
fair difficulty:

| Telegraph | Sound |
|---|---|
| Snap | short growl |
| Lunge | rising snarl |
| Frost Breath | crystal hum |
| Blink | high whoom |
| Fireball | fire build-up |
| Ambush | sharp growl |
| Enrage | roar |
| Meteor | a falling whistle |

- Impact sounds are heavy and punchy (bites, thuds, fire bursts, ice shatter).
- Add a tense **combat music loop** that gets more intense when the wolf is Enraged, and a death-cam sting (low,
  dramatic) when the player dies.
- Random pitch ±8% and 2–3 variants for everything that repeats.

---

## 7. Charged hit (still the answer, but it has to be earned)
Keep the 2.0 charged hit:
- 3 Resolve, a full stagger of 1.5 s
- shatters ice armour, cancels the blink shimmer and any ability wind-up
- knocks loot out of the wolf's mouth

But:
- While charging, the player moves 30% slower, and wolves **react to charging**:
  - Celestial blinks behind you
  - Shadow vanishes
  - Ember Flame Dashes through you
  - Timber feints
- So the charged hit lands best **after you dodge a lunge** (on the Exposed window) or while a wolf is busy with an
  ability's recovery. That's the skill: dodge, then punish with the big hit.

---

## 8. Test properly before you tell me it's done
Add an admin command **"Wolf test arena"**: it spawns the chosen type at a flat test area near me, in combat with me,
with the debug log on. Then for **each** type, fight it for 60 s and confirm:
- [ ] The signature ability fires within the first 5 s and at least **4 times in 60 s**. Every other ability fires
      at least once, including the phase-2 ability after 50% Resolve. Paste the counts from the log into your report.
- [ ] Frost Breath sweeps and can freeze; Celestial blinks behind me and follows up; Ember sets me on fire and Flame
      Dashes; Shadow vanishes and ambushes; Timber does Double Snap → Lunge combos and feints.
- [ ] Every attack and ability has its telegraph effect + sound, action effect and impact effect.
- [ ] Standing still or running in a straight line gets me hit. Sidestepping at the right moment dodges.
- [ ] I can die: ragdoll → wolf cam with letterbox and caption → the wolf howls, steals the best box (`BoxService`
      data correct) and runs → fade → respawn at my factory with 3 s spawn protection. A second player can still
      recover the box.
- [ ] A careless fight (just clicking) against a night Shadow/Ember wolf usually ends with me dead; a careful fight
      (dodging and punishing) wins.
- [ ] Charged and counter hits break poise; normal hits don't interrupt abilities; the stagger and Exposed windows
      work.
- [ ] No errors in the output, and no stuck states (frozen forever, burning forever, camera stuck on the wolf,
      character not respawning).
- [ ] Mobile: telegraphs are visible, the health bar is readable, and the roll button works on touch.

**Report:**
- why the abilities weren't firing before
- what you changed
- the ability counts per type from the test arena
- how long a typical win and loss took against each type
- every new asset ID (sounds, meshes, textures)
