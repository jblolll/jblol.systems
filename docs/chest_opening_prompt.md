# Prompt: chest opening experience (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. I'm adding **treasure chests** (one per rarity: Common, Uncommon,
Rare, Epic, Legendary, Mythic, Secret). Build a **chest opening experience just like my crate opening**: the same 3D
stage feel, polish and quality, but with chest-specific animations and effects that get bigger with the
**chest's rarity**. It must feel like a front-page Roblox game.

## 0. Before you build anything
1. **Read my crate opening system first:** the `CrateOpening` controller, the crate stage, the intro, the spinner, the
   reward effects, the results modules and the crate shop. **Reuse its stage, camera, lighting, effect and sound
   modules** so chests and crates feel like the same game. Don't duplicate them.
   - Check the shared modules (camera move, screen shake, rays, banners, confetti, coin burst, sounds) for anything
     crate-specific. If you find any, make it generic in a backwards-compatible way, then re-test crate opening so
     nothing breaks.
2. **The chest models:**
   - One `.fbx` per rarity. I'll import them into `ReplicatedStorage.Chests.<Rarity>`.
   - Each is a Model with **`Base`**, **`Lid`** and **`Loot`** parts. Use a SurfaceAppearance on each part with the
     4 maps for that rarity (colour, normal, roughness, metalness).
   - The **lid opens on a hinge** along its back top edge. The hinge offset from the `Lid` centre (Roblox axes):
     - Common and Uncommon: (0, -0.50, 1.36)
     - Rare: (0, -0.50, 1.40)
     - Epic: (0, -0.50, 1.40)
     - Legendary: (0, -0.50, 1.41)
     - Mythic: (0, -0.74, 1.41)
     - Secret: (0, -0.78, 1.42)

     Store these as an attribute (`HingeOffset`) on each Lid. Rotate the Lid around the hinge's X axis by a **positive** angle
     (about 105°) to open it: `hinge * CFrame.Angles(math.rad(angle), 0, 0) * closedOffset`.
   - `Loot` is the coin pile inside. It starts hidden (or dark) and lights up as the lid opens.
   - If the models aren't in the place yet, tell me exactly where to put them, and build everything so it works
     as soon as they're there.
3. Show me a short plan (modules, flow, reward table, rarity effects table). Then build it.

## 1. Where chests come from
- A **`ChestCatalog`** config: per rarity, a display name, colour (from `CatCatalog.Colors`) and a **reward table**.
- **Rewards:**
  - **Coins:** scaled to the player's economy, using the same earnings tracker as the Stray Patrol rewards, with a
    per-rarity multiplier (e.g. Common ×1 … Secret ×25). Put every number in the config.
  - **Bonus drops:** a chance at treats, crates or hats from the existing catalogs, more likely at higher rarities.
- **The server rolls everything.** The client only animates the result it receives. The reward is granted through
  the existing data and economy paths (`data.Coins`, `leaderstats`, inventories), and is saved and logged.
- **Ways to open a chest:**
  1. A chest the player owns in their inventory: add a **Chests** section to the inventory, with **Open**, **Open x3**
     and **Open All** buttons, the same as crates.
  2. A chest **in the world** (the quest reward chest or any world chest): walking up and using its ProximityPrompt
     plays a short open in the world, then the same reveal UI.

## 2. The flow (one chest)
`Open` → fade → **chest stage** (the crate stage, re-dressed) → the chest drops onto the pedestal → build-up → **the
lid bursts open** → the loot glows and **coins fountain out** → **reward cards** pop out of the chest one by one →
**rarity reveal effect** → **results panel** (`Open Another`, `Back`).

The server call starts when the player clicks, hidden behind the intro, exactly like crates.

## 3. Chest animation (about 2.5 s; Skip available)

| Time | Animation | Sound / effect |
|---|---|---|
| 0.00 | Fade in. The camera moves to the pedestal. | whoosh |
| 0.25 | The chest drops in with weight: a squash on landing, a dust ring, a small camera shake | heavy wooden thud (metallic clank for Rare+) |
| 0.6–1.8 | Build-up. The chest **rattles and hops**, harder and harder. Light **leaks out of the lid seam** in the chest's rarity colour, getting brighter (a thin glowing plane or Beam along the seam). On the lock, the gem pulses (Rare+). Coins clink inside. | rising rattle, coin jingles, a magical charge for Epic+ |
| 1.8 | The **lock pops off** (the hasp flips up with a spark) | lock click / snap |
| 1.9 | **The lid flings open** on its hinge (fast, overshoots to about 115°, settles at 105° with a bounce). A **light burst shoots up** out of the chest (a vertical beam plus god rays in the rarity colour). A flash. The `Loot` part lights up and its PointLight fades in. | big open sound plus a chord whose size matches the rarity |
| 2.0 | **Coins fountain** out and rain down (physics coin parts, or a coin particle burst that arcs and bounces, then flies toward the coin counter). Gems pop out too for Rare+. | coin shower that scales with the amount |

**Common and Uncommon** chests skip the heavy build-up: they get a quicker rattle and a pop open, so they feel snappy.
**Epic and above** get the full sequence.

## 4. Reward reveal UI (match my crate UI style)
- Each reward is a card that **flies out of the chest** in an arc and lands in a row on the screen:
  - a **coin card** showing the amount counting up quickly ("+12,450" with an easing count and a coin-stack icon)
  - one card per bonus item, with its rarity header, colour, ViewportFrame preview and name, using the crate card
    style
- **Card animation:** the cards are dealt one at a time, about 0.25 s apart. The best item is always dealt last.
- **Rare cards:** an Epic or better item card first lands face down, does a teasing shake, then flips.
- **Results panel:** the total coins, every item (NEW! tags), **Open Another** (disabled if the player has none left;
  shows how many are left), **Open All**, and **Back**.
- Keyboard, gamepad and mobile all work. Skip fast-forwards to the results panel.

## 5. Effects by chest rarity (each tier clearly bigger than the last)

| Chest | Stage | Lid open | Screen | Sound |
|---|---|---|---|---|
| Common | normal lights | small dust puff, soft golden glow | small sparkle | wooden creak, coin clink |
| Uncommon | green pedestal ring | green glow and sparkles | light ring pulse | creak, chime |
| Rare | blue lights | blue light beam, small god rays | flash 0.15, shake 2 px | metallic clank, chime chord |
| Epic | purple lights, dust motes | purple beam + spinning rays + gem sparkles | flash 0.3, shake 5 px, confetti | magical whoosh, big chord |
| Legendary | gold lights, spotlights sweep | gold pillar of light, rays, falling gold coins, camera push-in | gold flash 0.5, shake 10 px, "LEGENDARY CHEST!" banner | fanfare |
| Mythic | lights dip, then return pink | pink crystal shards burst, rainbow rays, a shockwave ring | pink flash, screen-edge glow, "MYTHIC CHEST!" | epic fanfare + bass drop |
| Secret | blackout, then aqua runes light up around the pedestal one by one | aqua lightning arcs between the crystals, rune circle on the floor, huge beam | glitch flash, "SECRET CHEST!!" | distorted riser + boom + choir |

Item cards also get their **own** rarity effect from the crate system when they flip. Reuse that code.

## 6. Opening several chests (x3 / All)
- **x3:** three chests drop side by side and open one after another, 0.4 s apart. The rewards from all three are
  dealt into one combined row, and the coin total counts up.
- **All (more than 3):** quick mode. A stack of chests pops open in rapid succession with mini effects, then a
  summary shows the total coins and every item, sorted by rarity.
- The full rarity effect plays once, for the **best** chest or item.

## 7. World chests (quest rewards)
- The chest **rises out of the ground** with dirt particles and a glow in its rarity colour, and floats a tiny bit with
  a soft bob and a sparkle loop until it's opened.
- A ProximityPrompt says "Open". The local player's camera does a short cinematic move to the chest, the lid opens in
  the world with the same tier effects, and coins fountain and fly into the coin counter. Then the reward UI shows.
- Other players see a lighter version of the effects. After opening, the chest sinks and disappears.
- Only the owner can open their quest chest. Everyone else sees a lock icon.

## 8. Sounds
- **Find real Creator Store sounds that are public or owned by me. Never make up asset IDs.**
- Put every ID in the shared sound config. Pitch-vary repeated sounds (coin clinks).
- The coin shower is several layered clinks scaled to the amount, not one loop.

## 9. Code and quality
- Modules: `ChestCatalog` (config), `ChestService` (server: inventory, roll, grant, validate, rate-limit),
  `ChestOpening` (client controller), `ChestStage` (built on the crate stage), `ChestRewardsUI`.
- One opening at a time, with a busy flag. Skip and cancel work at any point. Clean up everything. Restore the camera,
  HUD and Lighting. Preload chest models, textures and sounds.
- **Admin panel:**
  - give chests (rarity, amount)
  - open a chest with a forced result
  - spawn a world chest
- **Test in Play mode:**
  - every rarity (screenshot each lid-open moment)
  - x1 / x3 / All
  - a world chest
  - inventory counts go down correctly, coins and items are saved
  - no errors or warnings
  - crate opening still works exactly as before

When you're done, send me screenshots of each rarity's open moment and the results panel, plus the sound list.

---

# PART 2: Build a front-page quality opening STAGE (used by BOTH crates and chests)

The opening stage is the most-watched moment in my game, so it should look like a concert or award-show reveal, not a
grey room with a part in it. **Rebuild the shared stage** (the one my crate opening uses) to this standard. Crates and
chests both use it, and nothing else about the crate flow changes.

## A. Art direction
- **Theme:** "cat-show stage at night". A dark, glossy stage with warm accents, a rarity colour that floods in on the
  reveal, and my game's cat and pastry branding (paw-print logos, a neon "PURR" style sign on the back wall). Nothing
  should feel generic.
- **Composition:** the pedestal is centred, slightly below the middle of the screen. Leave the lower third clear for
  the reward cards UI. The background stays darker than the hero object so the crate or chest always pops.
- **Colour:** keep the stage neutral (deep navy and charcoal) until the reveal. Then everything (lights, lasers, rim
  light, particles) **shifts to the rarity colour** from `CatCatalog.Colors`. That colour shift is what tells the
  player the rarity before any text appears.

## B. The set (build it as a real 3D set, anchored, far from the map, with decor collisions off)
1. **Floor:**
   - Glossy dark floor (SmoothPlastic, Reflectance about 0.2, near-black).
   - An **LED grid** inlaid in it: a grid of thin Neon tiles, about 0.1 thick, flush with the floor, colour-controlled
     from code so it can run patterns (chase, ripple outward from the pedestal, pulse to the beat).
   - A subtle radial gradient decal so the centre is brighter.
2. **Pedestal / turntable:**
   - A layered round pedestal: dark base, a metal trim ring, a **neon rim ring** (rarity colour), and a slowly rotating
     top plate.
   - Thin emissive "rune" lines under a frosted glass top (Glass material with Neon parts beneath) for Epic and above.
3. **Back wall:** dark acoustic panels with:
   - a big glowing **paw-print logo / game sign** in Neon outline
   - two vertical **LED strips** at each side that animate
   - an optional big screen (SurfaceGui) behind the pedestal showing the rarity name or animated chevrons during the
     reveal
4. **Truss rig:** a square aluminium truss frame above the stage (Metal material, light grey, with a cross-brace
   pattern), holding the lights below.
5. **Side towers:** two speaker / light towers either side with small Neon accents that pulse to the music.
6. **Smoke / haze:**
   - Low ground fog: a few large flat ParticleEmitters at floor level (very slow, big soft smoke texture, about 0.9
     transparency, light grey). It lights up in the rarity colour on reveal; tween their Color.
   - Light air haze: soft Beams or slow particles so the light beams are visible ("volumetric look").
7. **Crowd silhouettes (optional, cheap):** a few dark cat-ear silhouettes along the bottom of the frame (flat parts
   or an ImageLabel), which bounce up when a Legendary or better is revealed.

## C. Real lighting rig
Lighting is temporarily switched for the stage: `Future` technology, darker ambient, and the stage's own lights do the
work. Restore everything afterwards.
1. **Key lights:** 3–4 **moving-head spotlights** on the truss. Each is a fixture model (a base, a yoke, and a head
   that can pan and tilt) with:
   - a `SpotLight` in the head (Shadows on, Range 40, Angle 25–40)
   - a **visible beam**: a `Beam` from the head to the floor, using a soft cone gradient texture, LightEmission 1,
     Transparency about 0.7 → 1 along the length, Width0 small and Width1 wide
   - a glowing lens (a small Neon disc)

   The heads really aim with smooth pan/tilt tweens.
2. **Rim / back light:** 2 lights behind and above the pedestal giving the crate or chest a bright edge so it separates
   from the background.
3. **Fill:** a dim, soft SurfaceLight from the front so the hero object is never too dark.
4. **Practicals:** small PointLights in the neon sign and LED strips so they spill a little light onto the walls.
5. **Pedestal uplight:** a PointLight under the hero object in the rarity colour, off until the reveal.
6. **Light cues** (driven by one `StageLights` module with named cues):
   - `Idle`: a slow lazy sweep, neutral white or warm colour
   - `Focus`: all heads aim at the hero object
   - `BuildUp`: the heads circle faster, the colour pulses, and the strobe intensity rises
   - `Reveal`: a flash, then everything snaps to the rarity colour
   - `Celebrate`: a wild sweep, colour chase, beam fans
   - `Blackout`: everything off for the Mythic and Secret tease

## D. Real laser beams
- **What a laser is:** 6–12 lasers from emitters on the truss and side towers.
  - A **Beam** between two Attachments, very thin (Width 0.05–0.12) and bright (LightEmission 1), with a crisp core
    texture.
  - A second, wider, more transparent Beam on the same attachments as a **glow halo**.
  - A small Neon emitter part with a tiny flare at the source.
  - Where it hits the floor or wall: a small **hit spark** (a tiny glowing part or a short particle burst at the end
    attachment).
- **Movement:** animate the end attachments, not the beams, so the lasers really **sweep**:
  - **fan sweeps:** all lasers from one emitter spread in a fan and rotate together
  - **criss-cross scissors** between the two side towers
  - **tunnel:** lasers point toward the camera, forming a cone around the pedestal
  - **scanning:** a single beam scans across the hero object before it opens (a "scanning…" feel)
- **Texture scrolling:** use `Beam.TextureSpeed` to make the lasers shimmer. Lasers stay off until the build-up and
  only go wild on Rare and above.
- **Laser pattern by rarity:**
  - Common: no lasers
  - Uncommon: 2 lasers that sweep slowly
  - Rare: fans
  - Epic: fans plus criss-cross
  - Legendary: everything, plus a gold tunnel
  - Mythic: rainbow-cycling lasers
  - Secret: aqua lasers that glitch (jitter and flicker), then form a rotating rune pattern on the floor

## E. Camera direction (it should feel like a film)
- **Shots:** use a scripted camera with named shots instead of one static view:
  - **Establishing:** a slow dolly-in from wide while the stage powers on (lights click on one by one, with "thunk"
    sounds).
  - **Hero close-up:** a low angle looking slightly up at the crate or chest, a slow orbit (±12°), a subtle handheld
    drift.
  - **Build-up push:** a slow push-in with a shrinking FieldOfView (from 70 down to 55), building tension.
  - **Reveal punch:** at the moment it opens, an **FOV kick** (55 → 75 in 0.08 s, then easing back) plus a short,
    decaying camera shake.
  - **Celebrate wide:** pull back to show the whole stage with lasers and confetti.
- **Movement and post-processing:**
  - Spline or bezier camera paths with eased movement. Never linear, never snapping.
  - Depth of field focused on the hero object, with a soft blurred background.
  - Bloom up during the reveal.
  - A ColorCorrection tint toward the rarity colour.
- The camera always ends somewhere that leaves room for the reward cards UI.

## F. Juice rules (what makes it feel front page)
1. **Anticipation → action → follow-through** on every motion: things wind up before they move and overshoot before
   they settle.
2. **Easing:** use Back, Quint and Elastic curves. Nothing moves linearly except a spinner's very first frames.
3. **Squash and stretch** on drops, landings, lid pops and card arrivals.
4. **Hit-stop:** a 0.05–0.1 s freeze at the exact reveal frame, then everything explodes outward.
5. **Layering:** every big moment has at least four layers at once: light change + particles + camera + sound (and UI).
6. **Contrast:** go quiet and dark right before the reveal (a short silence or low drone, the lights dim), so the
   explosion feels bigger.
7. **Sync to sound:** build-up beats, light pulses and laser hits are timed to the music or sound effects. The reveal
   lands exactly on the impact sound.
8. **Rarity escalation:** each tier adds something the tier below doesn't have, so players learn to read the rarity
   from the show alone.
9. **Skippable and fast:** the full show is about 4–6 s. Pressing Skip still shows a 0.5 s mini-reveal of the effect.
   Repeat opens (Open Again) use a shorter version (no establishing shot).

## G. Effects shopping list (build them as reusable modules)
- **Light shafts / god rays:** rotating wedges of Neon or Beams behind the hero object.
- **Shockwave ring:** a flat expanding ring along the floor (tween the Size of a cylinder with a soft texture).
- **Confetti cannons:** two cannons on the side towers fire bursts that flutter down (ParticleEmitter with
  rotation, drag and colour variation). Gold and rarity-colour confetti.
- **Sparks and embers:** short bright particle bursts on impacts, slow rising embers during the build-up.
- **Lens flare / glint:** a quick star-shaped flare sweeping across the screen (ImageLabel) at the reveal.
- **Coin and gem fountain** for chests (physics coins or particle coins that bounce and fly to the coin counter).
- **Screen effects:** a white flash frame, a chromatic edge pulse (Mythic), a glitch slices effect (Secret).

## H. Rarity show table (stage version)

| Rarity | Lights | Lasers | Floor / LED | Camera | Extras |
|---|---|---|---|---|---|
| Common | white sweep, soft | none | a gentle ripple | small push-in | small sparkle |
| Uncommon | green wash | 2 slow sweeps | a green ripple | push-in, small FOV kick | sparkles, soft chime |
| Rare | blue, heads aim and pulse | fans | a blue chase pattern | FOV kick, 2 px shake | god rays, confetti puff |
| Epic | purple, fast circling | fans + criss-cross | purple ripples + strobe | orbit + kick, 5 px shake | shockwave, confetti cannons |
| Legendary | gold, wild sweep, strobes | everything + gold tunnel | a gold checker chase | slow-mo push, big kick | lens flare, coin rain, crowd bounce |
| Mythic | blackout → rainbow chase | rainbow lasers | a rainbow wave | 180° orbit | chromatic pulse, double shockwave |
| Secret | blackout → aqua flicker | glitch lasers → rune ring | runes light up one by one | glitch cuts | glitch slices, lightning arcs, boom + choir |

## I. Performance and polish
- **Budget:** under about 300 active particles, about 12 lasers, and 6 shadow-casting lights at once.
- **Mobile:** detect low graphics quality (`UserGameSettings.SavedQualityLevel` / mobile) and fall back to fewer
  lasers, fewer shadows and lower particle rates, without losing the colour, camera or sound beats.
- **Loading:** preload every stage asset, texture and sound when the inventory or shop opens, so the first open never
  hitches.
- **Cleanup:** reset the stage fully after each open (lights, beams, particles, camera, Lighting), and keep it ready
  for the next open.
- **Sounds:** real Creator Store audio only, in the shared sound config:
  - a power-on thunk for each light
  - a laser zap or sweep
  - a crowd cheer (Legendary and above)
  - a bass drop
  - a whoosh for each camera move
  - a stage music loop that ducks at the reveal

## J. Test
- **Record:** screenshots of the idle stage, the build-up, and the reveal for every rarity, for both a crate and a
  chest.
- **Frame rate:** the stage holds a stable frame rate on the phone emulator.
- **Repeat opens:** 10 opens in a row work, with no leftover parts, lights or beams and no camera drift.
- **Restore:** the Lighting settings are restored exactly afterwards.
