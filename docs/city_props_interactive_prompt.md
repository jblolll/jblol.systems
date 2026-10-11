# Prompt: place my new props around the city and make the strays use them (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. I put some new props in **Workspace**. Look inside Workspace and find
them, then:
1. **Place them around the city** so it feels fuller, cosier and more alive.
2. **Make the stray animals interact with them**, with proper animations, effects and sounds:
   - **dogs** sniff and pee on the **fire hydrants** and the **mailboxes**
   - **cats** come up one at a time to eat and drink at the **cat bowls**
   - **mice** (if the mouse feature exists) nibble the **cheese crumbs**

Only use the props below. Some other props were removed on purpose, so ignore anything else you find that I didn't
list here.

| Prop (look for this name or similar) | Size at scale 1 (studs, X × Y × Z) | Job |
|---|---|---|
| `FlowerPot` | 1.44 × 1.72 × 1.44 | decoration |
| `FlowerPlanter` | 3.7 × 1.81 × 1.3 | decoration |
| `Barrel` | 1.44 × 1.8 × 1.44 | decoration |
| `FireHydrant` | 1.18 × 1.9 × 1.02 | **dogs pee on it** |
| `Mailbox` | 1.5 × 3.06 × 1.54 | decoration + **dogs pee on it** |
| `CheeseBits` (also `Cheese`/`Crumbs` if they're in Workspace) | 0.65 × 0.14 × 0.49 | **mouse food** and variety for my old crumb model |
| `CatBowls` | 2.0 × 0.36 × 1.1 | **cats eat and drink here** |

Quality bar: a front-page Roblox game. Smooth animations, clean small effects, good sounds, nothing floating,
clipping or stuck. **Keep everything cartoony and family-friendly** (see 3).

---

## 0. Before you build anything
1. **Read the existing code first** and reuse its patterns. Check in particular:
   - the **stray cat system**: the server plans timed routes (`StrayCatPlan`) from configs in
     `ReplicatedStorage.StrayCats`, and **each client builds and animates the cats**
   - the **stray dog system** (built the same way), `DogGait`/`CatGait`, `CatPlayPoses` and the existing poses
     (`notice`, `stalk`, `wiggle`, `chase`, `pounce`, `huh`, `meant`)
   - how `CatFights` and the park's butterfly hunting insert **acts** into a route. **Interacting with a prop must
     be a new kind of act in the same system**, not a parallel AI.
   - the `Sfx` module, `CatSounds`, the city sidewalks/`PathfindingModifier`s, Whisker Park, the day/night cycle
     (if built) and the VFX pack (`assets/vfx`, `VFXAssets`) if it's set up
2. **Find my props in Workspace.** Tell me which ones you found, their names, and anything missing. For each,
   check its size against the table. Tell me if one is a different scale.
3. **Back up** the map (a disabled `_OLD` copy).
4. Show me a short plan (counts per prop and the new act types), then build it. Put every number in a
   `PropInteractConfig` module.

---

## 1. Placing the props
Place the **real props from Workspace** (clone them, don't move my originals; keep them as templates in
`ServerStorage.CityProps`). Put everything in `workspace.City.Decor`.

**Rules for every prop**
- `Anchored = true`. The prop sits on the ground (raycast down to find the floor).
- Never block a **sidewalk route, a door, a road, a crossing or a car's path**. After placing, walk the stray cat
  and dog routes to make sure nothing got blocked.
- Props that animals walk up to (hydrants, mailboxes, bowls) go **beside** the sidewalk or at its edge, with at
  least **3 studs** of clear space on the walking side so an animal can stand next to them.
- Give each copy a **random rotation and scale 0.95–1.05** so nothing looks copy-pasted (not the mailbox, which
  faces the road).
- **Collision:**
  - `CanCollide = true` with `CollisionFidelity = Box` for the pot, planter, barrel, hydrant and mailbox
  - `CanCollide = false`, `CanQuery = false` for the cheese crumbs and the cat bowls, so nothing snags on them
- Keep each prop's texture and material as imported.

**Where each one goes (and rough counts, tune to the city's size)**

| Prop | Count | Natural spots |
|---|---|---|
| `FlowerPot` | 8–12 | in pairs either side of building doors, on each side of the bakery stand, next to benches, at the park entrance and along park paths |
| `FlowerPlanter` | 5–7 | along building fronts under windows, between shop doors, along the edge of the park paths, in front of the bakery |
| `Barrel` | 4–6 | in alleys and between buildings, beside the back of shops, by the bakery's back door. Some stacked 2 high on a side-by-side pair (only if stable). |
| `FireHydrant` | 4–5 | at the curb next to the sidewalk, near street corners and roughly every 60–80 studs along the main streets. About 1 stud from the curb edge, never on the walking line. |
| `Mailbox` | 2–3 | at the curb on main streets and one near the park entrance. Facing the road, the label side toward the sidewalk. |
| `CheeseBits` (+ `Cheese`/`Crumbs` variants) | 8–12 spots | near the bakery stand and benches, in alleys by barrels and wall bases, near mouse holes, and a few in the park. Use the cheese props as variants and **replace some of my old crumb models** with them. Keep a mix. |
| `CatBowls` | **park 4–5**, city 2–3 | in Whisker Park near the benches, along the park paths, and by shady spots. In the city put a set at a quiet back door or in an alley where strays hang out. |

**Make it look natural.** Group things in small clusters (a barrel and a pot by the same door, a planter with a pot
beside it) instead of an even grid. Leave some blocks quieter.

---

## 2. The interaction system (applies to all three kinds)
Interactions are **new act types** inserted into the existing stray routes (the server plans them, the clients play
them).

Every interactive prop gets:
- a CollectionService **tag** (`PeeSpot` for hydrants and mailboxes, `CatBowl` for bowls, `MouseFood` for cheese
  crumbs)
- one or more **interaction points**: invisible attachments or parts, named `Approach`, giving the exact spot and
  facing the animal should use (see each section)
- a **reservation**: only **one animal uses an interaction point at a time**. If it's taken, the animal skips it
  (or waits, for bowls). Release the reservation if the animal despawns or the plan is cancelled.
- a **cooldown** (per prop and per animal) so the same thing isn't used constantly

**The act flow** (server plans, client plays):
1. While planning a route, the server finds free interaction points near the route (within a short detour of about
   12 studs) and, by a configured chance, adds an **interact act**: walk to `Approach` → align (a smooth turn, 0.3 s)
   → play the animation sequence → release → carry on.
2. The animal **leaves the sidewalk** for the detour only if the point is off the walking line, using the same
   pathing/waypoint rules the strays already follow. It never clips through the prop, never walks on roads and
   never gets stuck.
3. Both server and client use the same act timings, so the effects and sounds line up for everyone.
4. If a player gets within **4 studs** or the animal gets spooked (chased by a wolf, a fight, a mouse chase), the
   interaction **cancels cleanly**: effects stop, the reservation is released, the animal moves on.
5. Interaction acts never run on animals that are busy (fighting, being chased, in a mouse chase, sleeping, etc.).

---

## 3. Dogs and fire hydrants / mailboxes (peeing)
Keep it **light, cartoony and tasteful**. Roblox is for all ages, so:
- Show it from a distance and from the side. The dog just **lifts a hind leg** and a **small stylised stream**
  of pale-yellow water droplets arcs out below and behind the leg onto the prop. No anatomy detail anywhere.
- Don't zoom in with the camera. The stream is thin and short.
- Add a `PropInteractConfig.PeeEnabled = true` flag so I can switch the whole thing off in one place if I ever need
  to.

**When it happens**
- When a stray dog's route passes within about **12 studs** of a free hydrant or mailbox, there's a **35%** chance
  (config) it adds the act. Cooldowns: the same dog can't use any prop again for **90 s**, the same prop can't be
  used again for **45 s**.
- Hydrants are used more often than mailboxes (70/30 when both are in range).

**Where the dog stands**
- Each hydrant/mailbox has **two `Approach` points**, on its left and right (so the dog's hip is toward the prop).
  Pick the free one on the side the dog is coming from.
- The dog stands **parallel** to the prop, its hind leg on the prop side, with its hips about **0.9 studs** from the
  surface. Raycast so it's right on the ground.
- **Hydrant:** the stream hits the **body of the hydrant at about 0.7 studs above the ground**.
- **Mailbox:** the stream hits the **nearest leg of the mailbox at about 0.6 studs above the ground** (the mailbox
  has four short legs; use the one closest to the dog).

**The sequence** (about 6–8 s total, with random timing variation of ±15%)

| Step | Time | Animation |
|---|---|---|
| Notice and approach | — | head turns toward the prop, the dog slows to a walk and heads to `Approach` |
| **Sniff** | 1.2–2 s | nose down at the prop, small nose twitches, tail gently wagging, body slightly forward, one sniff-step around the prop |
| **Position** | 0.4 s | the dog steps parallel, ears relaxed, head turns to look away "innocently" |
| **Leg lift** | 0.35 s | the **hind leg on the prop side lifts out to the side and back** (rotate the thigh bones about 55° outward and about 35° up; the lower leg tucks back), the weight shifts onto the other three legs, the body leans slightly away, the tail goes up and out |
| **Pee** | 2–2.8 s | the leg holds with a tiny quiver, the stream flows (see effects), head turns back and looks relieved with half-closed eyes (if the dog has them) |
| **Leg down** | 0.3 s | the leg lowers with a little shake |
| **Finish** | 0.8–1.2 s | a happy **body shake** (a quick left-right shudder, ears flapping) and sometimes (35%) a **back-paw scratch**: two quick kicks of the hind legs sending small dust/grass puffs backward. Then the tail wags and the dog trots off. |

Use the dog's existing bones (`thigh.*` + `.001`–`.004`, `spine.*`, head and ears). Blend everything over
0.1–0.2 s so there are no snaps or sliding feet.

**Effects**
- **Stream:** a `ParticleEmitter` (or a `Beam` with a texture plus a few particles) from just behind the lifted leg to the target point. Pale
  yellow-white droplets (about 0.08 studs) in a short arc with gravity, 40–60 particles per second, `LightEmission`
  0.2. The stream lasts only as long as the Pee step.
- **Impact on the prop:** tiny splash droplets bouncing off at the target point, and a slightly darker, glossy wet
  patch: add a small **wet decal** (dark, slightly shiny, soft edges) on the lower part of the prop that **fades
  away over about 20 s** (the hydrant or the mailbox leg).
- **Puddle:** a small, flat, pale-yellow, shiny **puddle decal** on the ground by the prop that grows a little
  during the pee and **fades out over about 15 s**. Project it onto the real floor with a raycast.
- If the VFX pack is set up, reuse `p_glow`, `p_spark` (as droplets), `fb_smoke_4x4` (a tiny dust puff for the
  scratch) and `p_leaf`.

**Sounds** (quiet, positional, about 25 studs range, random pitch ±8%)
- soft sniffing
- a small liquid trickle loop for the pee (kept gentle)
- a paper-rustle-like body shake
- scratching paws on ground, tiny dirt puffs
- a happy little pant or "huff" at the end

**Optional (do it if it fits):** now and then a **second dog** that arrives after the first has left sniffs the same
prop for 1.5 s ("who's been here?") with a curious head tilt, and doesn't pee (it just checks it out).

---

## 4. Cats and the cat bowls (eating and drinking)
Each `CatBowls` is one flat mat with **two bowls**:
- the **food bowl** (pink, with kibble) on the **-X side** of the mat
- the **water bowl** (blue, with water) on the **+X side** (check both visually and fix if mixed up)

**Where the cat stands:** each bowl has an `Approach` point at the front rim of the bowl (about 0.7 studs out from
the bowl's edge, on the mat), facing the bowl.

**One cat at a time**
- **Each set of bowls is used by one cat at a time.** The cat reserves the whole set until it's done.
- Other cats that want to use it **wait**: a cat arriving at a busy bowl **sits 5–8 studs away and watches**
  (tail curled, head turning to follow the other cat), up to **12 s**, then goes on its way. When the bowl frees up,
  a waiting cat can step in.
- A cat can't use the same bowl set again for **3 minutes** (per cat) and a set rests for **20 s** between cats.

**When it happens**
- In the **park**, a stray or park cat that passes within about **15 studs** of a free bowl has a **50%** chance
  to go over (config). In the **city**, 30%.
- It chooses: **eat** (40%), **drink** (30%), or **eat then drink** (30%).

**The sequence** (eating 6–9 s, drinking 5–7 s, with ±15% variation)

| Step | Animation |
|---|---|
| Approach | the cat walks over with its tail up (a happy "I see food" walk), slowing as it gets close |
| **Settle** | lowers itself into a **loaf-like crouch** in front of the bowl (front paws forward, hips slightly raised, tail swaying slowly), then a quick sniff of the bowl |
| **Eat** | the head dips into the bowl and bobs up and down in a rhythm (about 2 bobs per second, with small pauses), jaw chomping, ears flicking, tail tip twitching, and now and then a happy little **wiggle** of the hips. Every 3–4 bites the cat **lifts its head and chews**, looking around for a second. |
| **Drink** | the head lowers to the water and the tongue **laps** quickly (a small fast head bob, about 4 per second, with rhythmic tongue flicks if the cat model has a tongue, otherwise tiny jaw movements), ears relaxed, eyes half-closed, tail gently curling |
| Between | a quick head shake or a lick of the nose |
| **Finish** | sits up, **licks its lips and a paw** and wipes its face (2 quick wipes), a happy stretch (front-paws-out stretch, 1 s), then walks off with its tail up and a little purr |

Use the cat's existing bones and `CatPlayPoses`-style poses. Add the missing ones as new poses (`eat`,
`drink`, `lick`, `waitSit`). Blend smoothly. Feet planted, no sliding.

**Effects**
- **Eating:** small **kibble crumbs** (tiny brown pieces) that **hop out** of the bowl with each bite (2–3 per bite, small arcs,
  landing on the mat and fading after 2 s), a tiny "crunch" spark, and now and then a **sparkle** above the cat's
  head for a happy bite (`p_sparkle`, 1–2 per few seconds).
- **Drinking:** **water ripples** (a thin expanding ring on the water surface, 4–5 per second, a flat `p_ring`
  sprite or beam), **splash droplets** (2–4 per lap, small, bright blue-white, short arcs), and the odd droplet
  falling from the cat's chin when it lifts its head.
- **Finish:** a few small **hearts or sparkles** (config toggle) when the cat purrs.
- **Bowls:** the bowl visibly "rocks" a tiny bit (1–2°) on each munch, using a client-side CFrame wobble of the mat.
  (The kibble is part of the mesh and can't shrink, so use the flying crumbs for the feeling of eating.)

**Sounds** (quiet, positional, about 25 studs, random pitch ±8%)
- **Crunching kibble** loop, 2–3 variants
- **Lapping water** loop with small splashes
- soft licking sound at the finish
- the cat's existing purr (`CatSounds`) and a small happy "mrrp"
- a gentle "tink" of the bowl against the mat (tiny)

**Dogs and bowls:** dogs **ignore** the bowls (they only sniff and walk past).

---

## 5. Cheese crumbs
- Place the `CheeseBits` props (and `Cheese`/`Crumbs` variants) at the spots in section 1. Tag every one
  `MouseFood`.
- **If the city mice feature exists:** mice treat these as **nibble spots**:
  - a mouse approaches, sits upright and nibbles (the existing nibble idle), with tiny crumbs falling
  - while one is nibbling the spot shrinks slightly (the prop scales to about 60% over the nibble), then **grows
    back** after about 60 s
  - one mouse per spot at a time
- **If the mice aren't built yet,** just place and tag them. Make a note for me.
- Effects (small): a couple of tiny crumb particles when a mouse nibbles, and a tiny sparkle when the spot refills.
- **Sounds:** a tiny crunch while a mouse nibbles.

---

## 6. Decoration touches (no animals needed)
- **FlowerPot / FlowerPlanter:** a very subtle **sway**: tiny rotation oscillations on the flowers can't be
  done (the flowers are part of the mesh), so instead add an occasional **butterfly or petal** drifting by. If the
  butterfly system from Whisker Park exists, spawn 1 butterfly near a few planters in the park. In the city,
  spawn a few falling **petals** now and then (rare, tiny, `p_leaf`/petal tint) when a player is within about 40
  studs.
- **Barrel:** nothing needed. Cats may rarely **hop up on a barrel** to sit (only if the stray act system makes
  that easy; skip if not).
- **Mailbox:** the flag/lid doesn't move. Nothing else needed.

---

## 7. Performance and safety
- Clone from shared templates (same `MeshId`/`TextureID`) so memory stays low.
- Interaction **planning on the server is cheap** (one lookup per route, using `CollectionService` tags and a
  spatial grid). Clients animate and play effects only for animals within about **80 studs** of the camera.
- Decals (puddles, wet patches) are created from small pools, and removed with a `Debris` timer.
- If an animal leaves the game or despawns during an interaction, **everything cleans up** (effects, sounds,
  decals, reservations).
- Dogs and cats must still follow the safety rules from the stray systems (never on roads, never through props).

## 8. Admin panel
Add to my owner-only admin panel (same style and permission checks):

| Command | What it does |
|---|---|
| **Dog pee test** | makes the nearest stray dog walk to the nearest hydrant/mailbox and do the full sequence |
| **Cat eat test** | makes the nearest stray cat walk to the nearest bowl set and eat, then drink |
| **Show prop points** | draws the `Approach` points and reservations (debug) |
| **Toggle pee** | flips `PeeEnabled` live |

---

## 9. Test and report
- [ ] All the listed props are placed. Walk the city: nothing blocks a path, door, road or car route; nothing
      floats or sinks.
- [ ] A stray dog walks up to a hydrant, sniffs, lifts a leg, pees (stream, splash, wet patch, puddle, sounds),
      shakes and scratches, then walks on. Same for a mailbox leg. One dog per prop at a time; cooldowns work.
- [ ] A cat walks to a park bowl set, eats and/or drinks with all the effects and sounds. A second cat waits at a
      distance and takes its turn. Never two cats at one set.
- [ ] Interactions cancel cleanly when a player gets close or the animal is spooked.
- [ ] Cheese crumbs are placed and tagged. Mice nibble them (if built).
- [ ] No errors in the output. The frame rate stays smooth with 3+ interactions at once.

**Report:**
- the counts of each prop you placed and a rough map of where
- which props you found in Workspace and anything that was missing or a different size
- every sound/texture asset ID you used, and what each is for
- anything you couldn't do
