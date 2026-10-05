# Prompt: Wolf polish round, fixes + full effects revamp (paste into Claude with Roblox Studio MCP)

You built the wolf combat 3.0 update. I've playtested it. The fights are better, but a lot is still broken, too
cluttered with text, or looks basic. This round fixes the bugs, cleans up the UI, adds a proper death cutscene, adds
chest drops, and **revamps every effect** to front-page, boss-battle quality.

Work through the sections **in order** (bugs first, then features, then the effects revamp). For every bug, find
the **real cause** in the code before fixing it, and tell me what it was in your report. Back up anything you change
(`_OLD` copies, disabled). All new numbers go in `WolfConfig`.

---

## 1. Bugs to fix first

### 1a. The KO hit (last hit) has no bat hit sound
- **What happens:** the final hit that drives a wolf off plays no bat impact sound. It feels empty and I can't tell
  if it landed.
- **Likely causes to check:**
  - the hit handler returns early when Resolve reaches 0, before the sound code runs
  - the wolf switches to `Retreat`/non-hittable in the same frame, so the client's "confirmed hit" check fails
  - the sound is parented to the wolf and destroyed or stopped when it starts retreating
- **Fix:** **every confirmed hit plays the bat impact sound, including the last one.**
  - Play hit sounds from a **separate sound part/attachment at the hit position** (not inside the wolf), so they
    survive whatever happens to the wolf.
  - The KO hit gets a **layered KO sound**:
    - the normal bat thwack
    - a deep bass "boom" impact
    - a bright "ding/sparkle" tail
    - the wolf's yelp
  - See section 5c for the KO effect.

### 1b. Celestial Blink doesn't actually teleport
- **What happens:** it does the blink, but it reappears **in the same spot**, and there's no effect.
- **Likely causes to check:**
  - the destination is computed as an offset of 0, or relative to the wolf instead of the player
  - the server moves the wolf with `PivotTo`, but `Humanoid:MoveTo`/pathfinding or a `AlignPosition` /
    `BodyPosition` pulls it straight back
  - the client-side animation code holds a cached root CFrame and snaps it back
  - the destination check fails every time and silently falls back to "stay here"
- **Fix:**
  - Pick a destination **8–20 studs** away from its current position, from these options, weighted by situation:

    | Destination | When | Weight |
    |---|---|---|
    | **Behind the player** (5–7 studs behind) | attacking | 35% |
    | **Flank** (left or right of the player, 6–8 studs) | attacking | 25% |
    | **In front of the player** (6–9 studs), a straight-on surprise lunge | attacking | 15% |
    | **Away / escape** (12–20 studs from the player, toward open space) | when hit hard, low Resolve, or the player is charging | 25% |

  - **Validate each candidate:**
    - raycast down to find the floor
    - check it isn't inside a wall (`GetPartBoundsInBox` at the destination)
    - check it's on the nav mesh / reachable
    - check it's not outside the factory/map limits
  - Try up to 6 candidates. Only skip the blink if all fail, and log it in debug.
  - **After the move:**
    - stop the old path and reset any movers/constraints
    - set the new CFrame on the server
    - immediately re-path from the new spot
    - tell clients to snap the visual model to the new position (no lerping across the map)
  - Debug-log `blink from X to Y (type=Behind, dist=7.2)` so I can see it working.
  - Effects in section 5.

### 1c. Shadow Wolf doesn't turn invisible at night
- **Likely causes to check:**
  - the code reads `Lighting.ClockTime` on the server (where it doesn't change if the client tweens it) instead of
    the replicated `Phase`
  - it only sets `Transparency` on a part that isn't the skinned mesh
  - a `SurfaceAppearance`, `Highlight`, decals, eye parts, the health bar or aura particles stay fully visible
  - something resets `Transparency` every frame
- **Fix:** do the invisibility **on each client**, per wolf:
  - **Condition:** `Phase == Night or Dusk` and the wolf is **more than 18 studs** from the local player and not in
    an attack/reveal.
  - **Then:**
    - tween the wolf MeshPart `Transparency` to **0.92** over 0.5 s and set `CastShadow = false`
    - hide the health bar and fade the aura to faint smoke only
    - keep **only the two red eyes** glowing (eye parts/lights stay visible), plus faint footstep sounds
  - **Reveal** (getting close, attacking, being hit, day time): a smoke burst, the body fades back in over 0.3 s, and
    a low "reveal" sting.
  - The server doesn't need to know. Combat logic is unchanged.
  - Test it at night with the admin "Set time: Night" command, standing 25 studs away.

### 1d. Wolves get stuck at a closed factory door
- **What happens:** a wolf inside my factory trying to get out (or outside trying to get in) just sits at the closed
  door.
- **Fix:** if the path is blocked by a **closed** factory door for more than **1.5 s**, the wolf **teleports through
  the door**:
  - **Look:** the wolf crouches and shakes for 0.3 s, then vanishes in a **puff effect**: a burst of dark smoke plus
    small leaves/fur tufts, its type-colour sparks and a quick flash. It reappears **3 studs on the other side** with
    the same puff, and keeps going.
  - **Sound:** a cartoony "poof" with a short magical whoosh.
  - The landing spot is found with a raycast to the floor and a check that it isn't inside anything.
  - This works in both directions: leaving the factory with loot, and entering.
  - Keep the old "scratch at the door" behaviour **only** for wolves outside that haven't started their raid yet
    (they scratch for 2 s, then poof through).

### 1e. Telegraph decals float above the ground
- **What happens:** the red lunge trajectory bar and the yellow Snap circle sometimes float in the air.
- **Cause:** they're placed at the wolf's height or at a fixed Y, not on the actual floor.
- **Fix:** all ground indicators are **projected onto the ground**:
  - raycast straight down (from 3 studs above, 12 studs long) **ignoring wolves, players, boxes, effects and
    invisible parts**
  - place the indicator at the hit position + normal × 0.05 and **align it to the surface normal**
  - for the **lunge path**, sample 5–8 points along the path, raycast each one, and build the bar from segments (or a
    `Beam` between ground attachments), so it follows floors, ramps and steps
  - if no ground is found under part of it, hide that part
- **Look:**
  - use a soft-edged texture (not a flat neon block)
  - the bar fills from the wolf toward the target during the wind-up, flashes white at the end and fades
  - the Snap circle shrinks inward to show timing
- Re-check every other ground effect (ice spikes line, meteor circle, fire patches, frost patches, ember ring) with
  the same projection.

---

## 2. UI cleanup: almost no text
My rule: **during raids and fights there is no text on the screen and no text above the wolf**, except:
- the wolf's **health bar** (Resolve bar), without a name label if it has one
- a **"DODGED"** pop above the wolf when the player dodges one of its attacks (see below)

**Remove these:**
- the "A Frost Wolf is coming!" banner and **any** raid announcement text, including the server-wide Golden Wolf
  text and the Full Moon banner text (replace them with sound and effects only)
- every attack name on screen or over the wolf ("Lunge", "Frost Breath", "Blink", and so on)
- "COUNTER!", "ENRAGED!", "Fake!", "DRIVEN OFF!", "STOLEN!", "RECOVERED!", "SAVED!", damage numbers, "You're being
  hunted!", the first-encounter tip cards, and the death caption ("The Shadow Wolf stole…")
- the **custom player health bar** I asked for before. **Delete it** and use Roblox's built-in health bar
  (re-enable `Enum.CoreGuiType.Health` if something disabled it)
- the **"X to roll"** prompt and the whole stop-drop-roll mechanic (see 4c)

**Keep:**
- the **howl warning**: the wolf's howl sound from its direction. That's the only "a wolf is coming" signal, plus
  the indicator below.
- the **off-screen direction indicator**: a paw-print arrow at the screen edge pointing toward an incoming or nearby
  wolf when it's **not on screen** (behind you or to the side). Pulsing, in the wolf's colour, hidden when the wolf
  is on screen.
  - It shows for the incoming wolf from the howl until it arrives, and for any wolf within 40 studs that you can't
    see.
- the **day/night clock** (it's an icon, no text needed; remove its phase label text if it has one)

**"DODGED" pop:**
- **When:** a wolf's attack (Snap, Lunge, ability hit) misses a player who was its target and was **within 8 studs
  when the attack started** (so a wolf attacking at a distance doesn't spam it).
- **Look:**
  - white text with a dark outline and a light blue glow, in my game's UI font
  - pops up over the wolf's head: scales 0 → 1.2 → 1 in 0.15 s, floats up 2 studs and fades out over 0.7 s
  - a small swoosh sound
- At most one at a time per wolf. It only shows for the dodging player.

Since the text is gone, **effects and sound must carry all the information**: the wind-up poses, eye flares, ground
indicators, distinct telegraph sounds, the enrage aura, and so on (section 5).

---

## 3. Death cutscene (replaces the 2.0/3.0 death cam)
**Don't hide the character.** When a wolf kills the player, play a short cinematic for the dying player only.

### 3a. Sequence
1. **Killing blow and slow motion (about 2 s).**
   - At the moment of the killing hit:
     - a quick white flash and a heavy impact sound
     - **everything slows down** on the dying player's screen (see 3b)
     - the camera switches to a **third-person cinematic shot**: a slow orbit (20–30°) around the player, 8–10 studs
       away, slightly low and looking up, with both the player and the wolf in the frame
   - The character **ragdolls** in slow motion from the hit (pushed away from the wolf as in 3.0), arms and legs
     flopping naturally.
   - A **clean death/fail sound** plays: a soft descending "fail" sting plus a muffled thud, with the music cutting
     out (no cartoon scream).
   - Vignette, slight desaturation and muffled game audio.
2. **Ground impact.** When the body hits the ground (or after 2 s of slow-mo max):
   - normal speed returns with a soft "whump" and a small dust puff on the ground
   - **the ragdoll stays on the ground** (don't hide or delete it) until the respawn
3. **Pan to the wolf (about 1 s).** The camera smoothly pans and pulls back to frame the wolf in a 3/4 view.
4. **The wolf steals your pastry.**
   - It does a short victory howl, then walks or trots to the **most valuable box** in the factory.
   - It **eats it**:
     - a 1.5 s bite loop, head shaking side to side
     - cardboard bits and crumbs flying
     - the box shrinks and breaks apart (destroyed through `BoxService`, so the data stays correct)
   - It **picks up a pastry** in its mouth (a pastry model welded to the `jaw` bone; use the pastry model that
     matches the box if there is one).
   - It **runs out of the factory**, through the door (poofing through if it's closed, see 1d).
   - The camera follows it smoothly, always keeping it in frame.
5. **Paw-print transition.** The moment the wolf **leaves the factory**:
   - play **my existing paw-print transition** (the same one the crates use)
   - while the screen is covered, **respawn the player** at their factory spawn and reset the camera
   - when the transition opens, the player is already standing there, ready
   - 3 s of spawn protection as before (soft shimmer, wolves ignore them)
6. **Skip button.**
   - **When it shows:** from 1 s into the cutscene.
   - **Where and how:** bottom-right, a clean rounded button with a paw icon and "Skip" (this is the one text
     exception), with a gamepad button hint and a keyboard shortcut (`Space` or `Enter`).
   - **What it does:** pressing it plays the paw-print transition straight away and respawns the player.
   - The theft still happens on the server (the box is lost); the player just doesn't watch it.
7. **Safety:**
   - the whole cutscene has a **12 s hard maximum**, then it transitions and respawns no matter what
   - if the wolf is driven off by another player during the cutscene, the box is **not** stolen, the camera shows
     the wolf retreating, then the transition plays
   - leaving the game mid-cutscene must not break the wolf
   - other players see a normal ragdoll and the wolf stealing (no slow-mo for them)

### 3b. How to do slow motion in Roblox
There's no global time scale, so fake it **on the dying player's client** for the ~2 s:
- The ragdoll is owned by the dying player. Lower `workspace.Gravity` **locally** (about 25% of normal) and scale
  the ragdoll parts' velocities down (about 35%) at the start. Restore both when slow-mo ends.
- Set `ParticleEmitter.TimeScale` to about 0.3 on nearby effects.
- Slow the wolf's client-side animations (`AnimationTrack:AdjustSpeed(0.3)` / the procedural gait time scale).
- Pitch the sounds down: a `PitchShiftSoundEffect` or a lower `PlaybackSpeed` on a SoundGroup.
- Ease into and out of slow-mo over 0.2 s so it doesn't snap.
- Make sure gravity and time scales **always** get restored, even if something errors (use `pcall`/cleanup).

---

## 4. Gameplay changes

### 4a. Chest drops from wolves (rarer wolf = rarer chest)
Use my existing **chest system** (Common, Uncommon, Rare, Epic, Legendary, Mythic, Secret) and the chest opening I
already have. Read how chests are granted first, and reuse that.
- When a wolf is **driven off**, roll once for a chest drop (only for natural spawns, never admin-spawned wolves
  unless the admin rewards flag is on):

  | Wolf | Drop chance | Chest rarity odds |
  |---|---|---|
  | Timber | 8% | Common 70%, Uncommon 25%, Rare 5% |
  | Frost | 12% | Uncommon 55%, Rare 35%, Epic 10% |
  | Celestial | 15% | Rare 50%, Epic 38%, Legendary 12% |
  | Shadow | 15% | Rare 50%, Epic 38%, Legendary 12% |
  | Ember | 15% | Rare 50%, Epic 38%, Legendary 12% |
  | Golden | 35% | Epic 55%, Legendary 35%, Mythic 9%, Secret 1% |
  | Pack companion | 3% | Common 80%, Uncommon 20% |

  - **Full Moon:** +5% drop chance and the result is bumped up one rarity tier (Secret stays Secret).
- **Who gets it:** the player who dealt the most Resolve damage (the factory owner wins ties).
- **The drop:**
  - the chest model of that rarity pops out of the wolf as it starts retreating, arcs out and lands with a bounce
  - a **light pillar** in the rarity colour shoots up from it (taller for rarer chests)
  - sparkles
  - a rarity-scaled sound (the same rising chord idea as the chest opening)
  - Epic+ also gets a short ground shockwave
  - Only the winner sees the claimable chest glow; others see a dimmer version.
- **Claiming:** walk into it, or press E, within 30 s (it auto-claims after 30 s if the winner is still in the
  server). It then goes into the existing chest flow or inventory, the same way chests are normally given to the
  player.
- All server-side; one roll per wolf.

### 4b. Coin reward effect (new, custom)
Don't use the box-selling effect (it shows a box). Make a **custom coin reward effect** for driving off a wolf and
for hitting the Golden Wolf:
1. **Burst:** coins (real 3D coin meshes, gold with a shine, spinning) **explode out** of the wolf's position in a
   fountain. The number scales with the reward (8–30 coins).
   - Each coin arcs out, spins, bounces once on the ground with a tiny sparkle, and has a short glint trail.
2. **Magnet:** after 0.4–0.6 s (staggered per coin) the coins **lift and fly to the player** with an accelerating
   curve. Each one that reaches the player plays a **rising chime** (pitch goes up with each coin) and a tiny flash
   on the player.
3. **To the counter:** as each coin hits the player, a **2D coin icon** spawns at the player's screen position and
   flies along a curve into the sidebar **coin counter**.
   - The counter **bumps** (scale 1.15 → 1 with a bounce), glows gold and **rolls up** to the new total.
   - A satisfying final **"cha-ching"** plays when the last coin lands.
4. **Golden Wolf hits:** each hit makes a **smaller coin shower** (5–8 coins) that bursts from the wolf and magnets
   to the hitting player the same way, with gold sparkles and a "jingle".
- **Performance:**
  - pool the coin parts (no `Instance.new` per coin)
  - client-side only (the server just sends the amount and position)
  - fewer coins on low graphics quality
- If a chest also dropped (4a), the chest pops out **after** the coins, so they don't overlap.

### 4c. Burning (Ember): simpler and much better looking
- **Remove** the roll-to-extinguish mechanic and its prompt completely. Burning lasts **3 s** and goes out naturally
  (hits refresh it, as before).
- **On the character:**
  - real-looking **flames on the body**: flipbook flame `ParticleEmitter`s attached to the torso, arms and legs
    (not the old `Fire` instance), licking upward
  - embers drifting off, a little dark smoke, and a flickering orange `PointLight` on the character
  - the body gets a subtle orange glow (a `Highlight` with low fill)
- **On the screen** (the burning player only):
  - an animated **flame border**: flames licking up from the bottom and side edges, an orange heat vignette and
    a subtle heat-shimmer overlay
  - it pulses with each burn tick, with a small red flash per tick
- **Sounds:**
  - an ignite "fwoomp"
  - a crackling fire loop while burning
  - a soft hiss and steam puff when it goes out
- **Going out:** the flames shrink, turn to smoke and the screen border fades over 0.4 s.

---

## 5. Full effects revamp (front-page, boss-battle quality)
All the effects currently look basic: flat neon parts, a few plain particles. Rebuild them as **layered,
professional VFX**. Build a reusable **`WolfVFX` module** (client-side, pooled) that every ability and hit calls.

### 5a. How to build good effects (apply to everything)
Every effect is made of **layers**, timed as **anticipation → impact → dissipation**:
1. **Core flash:** a very short (0.05–0.1 s), very bright burst (a Neon sphere or flare that scales up and fades,
   plus a `PointLight` spike).
2. **Shape:** a readable form that shows what happened: slash arcs, shockwave rings, beams, cones, pillars. Use
   **meshes** (rings, half-spheres, crescent slash meshes) with gradient/flipbook textures, scaled and faded with
   tweens.
3. **Particles:**
   - sparks (fast, small, `LightEmission` 1)
   - debris (fur tufts, ice shards, embers, stars, dust)
   - lingering motes
   - use `ParticleEmitter:Emit(n)` for bursts and **flipbook textures** (`FlipbookLayout`) for fire, smoke, magic
     and impacts
   - use `Size`/`Transparency` NumberSequences, `Squash`, `RotSpeed`, `Drag`, `Acceleration`, `ZOffset`
4. **Light:** coloured `PointLight`s that flash and fade; `Beam`s with scrolling textures for streaks and tethers.
5. **Ground:** impact decals (cracks, scorch marks, frost) **projected onto the ground** (as in 1e) that fade over
   2–4 s, plus a dust ring.
6. **Screen:** camera shake scaled to the impact, a quick FOV punch on big hits, colour-correction flashes (tint in
   the effect colour), and a screen-edge effect for status effects.
7. **Sound:** layered sounds for every effect (section 6).

**Style:**
- crisp, bright, high-contrast and colourful (stylised like the rest of the game), not muddy grey smoke
- each wolf type has a **colour palette** (core + accent + dark), and every one of its effects uses it:

  | Wolf | Core | Accent | Dark |
  |---|---|---|---|
  | Timber | warm white | amber | grey dust |
  | Frost | white | cyan | deep blue |
  | Celestial | white | gold | violet / indigo |
  | Shadow | red | crimson | black smoke |
  | Ember | yellow-white | orange | deep red / black smoke |
  | Golden | white | gold | emerald sparkles |

**Quality bar:** look at front-page Roblox fighting and boss games for reference. Effects should feel **punchy and
satisfying**, readable from a distance, and never cover the player's view for long.

**Assets:**
- Use good particle textures from the Creator Store (flames, smoke flipbooks, sparks, stars, slash arcs, shockwave
  rings), and check that each one loads.
- If a needed texture doesn't exist, tell me and describe it; I can make it.
- List every asset ID in your report.

### 5b. Wolf attack and ability effects

| Ability | Telegraph | Action | Impact / aftermath |
|---|---|---|---|
| **Snap** | eyes flare (a light spike + glint), jaw opens, a **ground circle that shrinks** under the target (soft texture, type colour) | two **crescent slash meshes** snap shut in front of the jaws like a bite, plus a white flash and spark spray | hit: an impact star burst on the player, fur/sparks, a red screen-edge flash, a camera shake. Miss: the slashes close on air with a whiff of sparks, and "DODGED" shows |
| **Lunge** | back paws kick up a dust cloud, a **ground trajectory bar** fills toward the target, eyes leave light streaks | a body **motion trail** (a ribbon Trail along the spine) with speed-line particles and an air-whoosh distortion ring at launch | landing: a dust shockwave ring, ground cracks, debris. Hit: a big impact burst, a knockback dust trail behind the player, a camera punch |
| **Enrage** (50% Resolve) | the wolf stops and roars, jaw wide | an **aura explosion**: a shockwave ring + a column of type-coloured energy + sparks, and a screen tint pulse in the type colour for nearby players | for the rest of the fight: a doubled aura, flickering energy around the body, brighter eyes with trails |
| **Howl** | sits back, head up, jaw open | visible **sound-wave rings** pulsing out from the mouth, dust lifting off the ground around it | if it calls a companion: the companion bursts out of the treeline with its own entrance puff |
| **Stagger** (charged hit on the wolf) | — | the wolf flies back with speed lines | dizzy **stars spinning** over its head, a dust skid line on the ground |
| **Exposed** (missed lunge) | — | a skid dust spray | a small **gold glint** pulses over the wolf to show the opening |
| **Door poof** | crouch + shake | a smoke burst, leaves, type-colour sparks, a flash | the same puff on the other side |

**Frost Wolf:**
- **Frost Breath:**
  - **Telegraph:** cold mist gathers into its mouth (particles pulled inward) and ice crystals grow on the muzzle.
  - **Breath:** a thick white-cyan **cone of swirling mist** (flipbook smoke, `LightEmission` 0.3), with ice shards
    shooting through it and a cyan `Beam` core. A **frost decal spreads across the ground** along the cone.
  - **Players hit:** frost crystals form on their body, the screen edges freeze over (an animated ice border) and
    their breath puffs.
- **Freeze:** a clear **ice block** forms around the player (a crystalline mesh, slightly transparent, with an inner
  glow).
  - Breaking out: it cracks in stages, then shatters into shards with a glassy burst.
- **Ice Spikes:**
  - **Telegraph:** a frost crack line runs along the ground toward the player.
  - **Eruption:** spikes **burst up** one after another with snow puffs and a ground ring each, then crumble into
    shards after 1.5 s.
- **Ice Armour:**
  - The ice crust has a shiny refractive look (`Glass`/`ForceField`-like material, light blue).
  - Each hit **cracks** it (crack decals + a chip burst).
  - A charged hit **shatters** it: a big shard explosion, a frost shockwave and a cyan flash.

**Celestial Wolf:**
- **Blink:**
  - **Out:** a star implosion (particles rushing inward), the body stretches into a streak of light and vanishes in
    a **star burst** with a shockwave ring.
  - A glowing **light streak** traces the path to the destination for 0.2 s.
  - **In:** a reverse burst, a small cosmic shockwave on the ground and lingering star motes.
  - Make it **flashy**. This is its signature move.
- **Star Orbs:** glowing orbs (a Neon core + sparkle aura + a star trail) orbit above its back, then fire one by one
  with homing trails. On impact: a star explosion with sparkles. When popped by the bat: a bright pop and a ring.
- **Decoys:**
  - **Split:** a flash with the decoys sliding out sideways.
  - **Look:** the decoys have a faint violet shimmer and no shadow.
  - **Popping one:** a star poof.
- **Meteor:**
  - **Warning:** a glowing **rune circle** projected on the ground (rotating and pulsing) for 1 s, and the sky above
    brightens.
  - **Strike:** a star **meteor streaks down** with a long trail and **explodes**: a column of light, a big shockwave
    ring, sparkles raining down and camera shake.

**Ember Wolf:**
- **Fire Bite:** fire slash arcs from the jaws, an ember spray, and the target ignites (4c).
- **Flame Dash:**
  - **Telegraph:** the body glows hotter and embers spiral around it.
  - **Dash:** it becomes a **streak of fire**, with a fire trail and a heat-distortion ribbon.
  - **Aftermath:** a line of **burning ground** (flipbook fire on scorch decals) that stays for 4 s, then smokes out.
- **Fireball Spit:** a flame builds in the jaw. The fireball is a **rolling fire sphere** with a smoke trail, flying
  in an arc. On impact: a fire explosion, a fire ring, scorch marks and debris.
- **Ember Burst:**
  - **Telegraph:** the wolf glows white-hot and cracks of light spread across its body.
  - **Burst:** a **ring of fire expands** along the ground, tall flames at its edge, embers thrown up, with a heat
    shockwave and a screen flash.
- **Flame aura (enraged):** constant flames rising off its back and paws, burning footprints and a strong flickering
  light.

**Shadow Wolf:**
- **Vanish:** the body **dissolves into black smoke** from the tail to the head, leaving only the red eyes, which
  then fade too. Smoke tendrils drift away.
- **Ambush:**
  - **Telegraph:** two red eyes **flare open** out of the darkness with a red light spike.
  - **Pounce:** it bursts out of a smoke explosion, with a red-black trail.
  - **On hit:** a dark impact burst, and red claw marks across the screen edges.
- **Shadow Clones:**
  - **Telegraph:** smoky afterimages peel off its body.
  - **Attack:** all three lunge with smoke trails. The fake ones burst into smoke on contact.
- **Darkness (enraged):**
  - The area darkens: a local colour-correction fade and fog particles at ground level.
  - The screen edges are filled with creeping shadow tendrils.
  - Only the wolves' eyes glow brightly.

**Timber Wolf:**
- **Combos:** each Snap in a chain leaves a slash afterimage, and the final lunge gets an amber motion trail.
- **Frenzy (enraged):** an amber energy flicker around the body, faster slash trails and dust kicked up on every
  turn.

**Golden Wolf:**
- **Running:** a constant gold sparkle trail with coin glints.
- **Dodge:** a gold afterimage left behind.
- **Gold Flash:**
  - **Burst:** a radial white-gold burst with god rays and a short screen flash (reduced with the "Reduce flashing"
    setting).
  - **Escape:** the wolf streaks away, leaving a glittering trail.
- **Every hit on it:** a coin shower (4b) plus gold sparks.

### 5c. Bat hit effects (the player's side)

| Hit | Effect |
|---|---|
| **Normal hit** | white impact flash at the contact point, a **slash smear** in the bat's direction, a spark spray, fur tufts in the coat colour, a shockwave ring, a 0.05 s hit-stop and a small camera shake |
| **Counter hit** (on an Exposed wolf) | everything above, plus a **gold starburst**, a radial line flash, a bigger shake and a 0.08 s hit-stop |
| **Charged hit** | a big layered impact: a white core flash, two expanding rings, a radial spark explosion, a dust burst at the wolf's feet, a **0.1 s hit-stop + FOV punch**; the wolf flies back with speed lines and dizzy stars |
| **KO hit** (last hit) | the best hit in the game: a **0.12 s freeze-frame**, a big white-gold flash, the Resolve bar **shatters into glowing shards**, a huge shockwave ring and a ground dust burst, a camera punch, the layered KO sound (1a). Then the wolf yelps and the retreat starts, the coin reward (4b) bursts out and a chest pops if one dropped (4a) |
| **Bat rarity** | keep the rarity trails (Rare blue, Epic purple sparkle, Legendary gold with paw-print particles) and **add the rarity colour to the impact effects** |

### 5d. Wolf presence
These run all the time, so keep them cheap:
- Eyes always glow in the type colour, with a soft bloom-friendly light, and leave **light trails** when the wolf
  moves fast.
- **Ambient auras per type:**

  | Type | Aura |
  |---|---|
  | Frost | mist + snowflakes |
  | Celestial | star motes + a violet ground glow |
  | Shadow | smoke wisps |
  | Ember | embers + heat shimmer + flame footprints |
  | Golden | sparkles |
  | Timber | a subtle dust trail when running |

- Footstep effects: small dust puffs on hard floors, plus type extras (frost prints, fire prints).
- The Resolve bar:
  - a clean segmented bar with a coloured edge glow in the type colour
  - segments break off with a small shard effect when hit
  - Frost armour shows as icy segments
  - hidden while Shadow is invisible

---

## 6. Sound pass
- Every telegraph has its **own sound** (now more important, since there's no text): growl (Snap), rising snarl
  (Lunge), crystal hum (Frost Breath), shimmer whoom (Blink), fire build-up (Fireball/Burst), sharp growl (Ambush),
  roar (Enrage), falling whistle (Meteor), howl (Howl).
- Every impact is layered (a transient + a body + a tail) and every repeated sound has 2–3 variants with ±8% pitch.
- **Bat hits:** normal thwack, heavier counter, big charged bonk, layered KO hit (1a). **Every confirmed hit plays
  a sound.**
- **New sounds:**
  - door poof
  - DODGED swoosh
  - coin chimes and the "cha-ching"
  - chest drop chord
  - burning loop and extinguish hiss
  - death fail sting and thud
  - slow-mo whoosh in and out
  - paw-print transition sound (reuse the crate one)
- Mix check: wolf telegraphs must cut through the factory machine noise.

---

## 7. Test before you tell me it's done
Use the admin "Wolf test arena" and "Set time" commands:
- [ ] The KO hit always plays the bat sound + KO sound and the full KO effect.
- [ ] Celestial blinks to **behind, flank, in front and away** (the debug log shows the destinations and distances)
      with the full effect, and never into walls.
- [ ] Shadow is invisible at night beyond 18 studs (only the eyes show) and reveals properly; visible by day.
- [ ] A wolf inside a factory with the door closed poofs through it with the effect and sound, both ways.
- [ ] Lunge bars, Snap circles and every other ground effect sit on the floor on flat ground, ramps and stairs.
- [ ] No raid text, no attack names, no damage numbers, no custom health bar. The Roblox health bar shows.
      "DODGED" appears only on real dodges. The off-screen paw arrow works.
- [ ] The death cutscene:
  - [ ] slow-mo ragdoll in third person, with the death sound
  - [ ] pan to the wolf, which eats the best box and runs off with a pastry in its mouth
  - [ ] paw-print transition into an already respawned player
  - [ ] the skip button works
  - [ ] gravity and time scales are restored
  - [ ] the 12 s max works
- [ ] Chest drops happen at about the right rates (run a quick simulated roll of 1,000 wolves per type in Studio and
      put the results in your report), and claiming gives the chest through the existing system.
- [ ] The new coin effect plays for driving off wolves and for Golden hits. The box-selling effect is no longer used
      for wolves.
- [ ] Burning shows body flames + the screen flame border and goes out by itself after 3 s; there's no roll prompt.
- [ ] Every ability in section 5b has its full telegraph → action → impact effects and sounds.
- [ ] No errors in the output, and frame rate stays smooth with 3 wolves fighting at night on a mid-range device.
      Lower the particle counts on low graphics settings.

**Report:**
- the root cause of each bug in section 1
- what you changed
- the chest drop simulation results
- every asset ID used
- anything you couldn't do
