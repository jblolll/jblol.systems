# Prompt: the starter scooter (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. I've put a **scooter model** in Workspace. Build it as the **first
vehicle** in the game: **every player gets it at the start**. It's slower than my bike, it has the same paint colours,
and it has **no upgrades except changing its colour**. The player rides it standing up, can **steer with a moving
handlebar**, and can **ride while holding boxes**. The wheels spin and the handlebar turns, like a real scooter.

It must look and feel like a polished front-page Roblox game: smooth riding animation, believable steering, tidy
effects, good sounds and no bugs.

---

## 0. Before you build anything
1. **Read how my existing vehicles work first** and copy their patterns instead of making a parallel system. In
   particular my **bike** (it's the closest one):
   - how it is built (seat, wheel parts + constraints, collision parts, `BasketSlot`)
   - how it is **spawned and owned**: saved data, the vehicle shop/garage, how a player "has" a vehicle
   - how **paint jobs** work (`VehicleUpgrades.Paints`, the 5 paints, how the colour is saved and applied)
   - how the player **rides** it (the seated/riding animation) and how **carrying boxes while riding** works
   - the controls on PC, mobile and gamepad
   - the speed/acceleration numbers, and the sounds and effects it uses
   - the caddy/pickup README texture note: `assets/caddy/README.md`
2. **Inspect the scooter in Workspace.** It should have 5 MeshParts:

   | Part | Notes |
   |---|---|
   | `Body` | deck, head tube, rear fork and fender |
   | `Steering` | fork, front fender, stem, handlebar, grips, bell, headlight housing. **This turns.** |
   | `Headlight` | the lens (make it Neon + a light) |
   | `WheelF`, `WheelR` | pivot is the axle centre, axle along X, radius 0.75 |

   Tell me which version of the textures is on it and check the sizes against `assets/scooter/README.md`
   (about 1.6 studs wide deck, 6.2 long, 3.8 tall, handlebar 2.7 wide).
3. Tell me **which rig my players use** (R15 or R6) and whether the bike's riding animation is an uploaded Animation
   asset or procedural.
4. **Back up** anything you change (an `_OLD` copy, disabled) and show me a short plan, then build it.
5. Put every number below in a `ScooterConfig` module.

---

## 1. The vehicle rules
- **Starter vehicle:** every player **owns it from the first join**. Give it to **existing players too**, once, when
  they next join (an "owned vehicles" check, not a one-time flag that new saves skip). It can't be sold, lost or
  removed.
- **It spawns/despawns like my other vehicles** (garage button, the same remotes, same cooldowns, and one per
  player). Reuse how the bike does it.
- **Speed (slower than the bike):** read the bike's top speed and use **about 65% of it**, but never less than
  **1.35× the player's WalkSpeed** (so it's still worth riding). Gentle acceleration (about 1.2 s to top speed) and a
  quick but not instant brake. Report the numbers you chose.
- **No upgrades.** The vehicle upgrade UI for the scooter shows **only the colour/paint option**. Hide or skip
  every other upgrade (engine, nitro, capacity, and so on).
- **Paint:** the same 5 paints as the caddy and pickup, **red, blue, green, yellow, pink**. The scooter has
  one texture per paint (`scooter_<paint>.png`, all the parts share the same UVs), so a paint job is setting
  `TextureID` on **all 5 MeshParts**. Use the same save/apply code as the bike's paint. The default paint is
  the player's saved paint, or red.
  - I'll upload the 5 textures and give you the asset IDs. **Ask me for them. Don't use placeholder IDs.**
  - Don't change `Material`/`Color` on the parts (the colours are in the texture).
- **Boxes:** the player **can carry boxes while riding** (see section 4). Don't add a basket to the scooter.
- It must work in the **factory, the city and the park**, on slopes and over small bumps, without flipping or
  getting stuck.

---

## 2. Physics and setup
- Follow what the bike does for driving: invisible simple collision parts, the MeshParts non-colliding
  (`CanCollide = false`, `CanQuery = false`, `Massless`), and the same network ownership (the rider's client
  drives it).
- **Wheels:** the visual wheels follow the real ground contact (or the physics wheels). Don't let the visible wheels
  sink into or float above the ground.
- The scooter must **not tip over** when the rider moves their body or when carrying boxes. Keep the centre of mass
  low and the stability the bike has.

---

## 3. Moving parts (this is the important bit)
All positions are in Roblox axes, **relative to the `Body` MeshPart's centre**, and the front of the scooter is -Z.

### Wheels
- `WheelF` at (0, -0.843, -2.741), `WheelR` at (0, -0.843, 1.709). Axle along X, radius 0.75.
- Spin each wheel around **its own X axis** by **`-speed / 0.75` radians per second** when rolling forward (reverse
  the sign when going backward). Do it on the client from the vehicle's real speed.
- Slight wobble on rough ground is welcome but optional.

### Steering (the handlebar)
- `Steering`, `Headlight` and `WheelF` **all turn together** around the head-tube axis:
  - **axis point:** (0, 0.257, -2.361)
  - **axis direction (up and slightly back):** (0, 0.9703, 0.2419)
- Steering angle **up to ±28°**, following the player's steer input **smoothly** (about 0.1–0.15 s of damping,
  so it never snaps). It centres itself when there's no input.
- CFrame math:
  ```lua
  local axisCF = bodyCF * CFrame.fromMatrix(AXIS_POINT, right, AXIS_UP, back) -- build a frame whose Y axis is AXIS_DIR
  local turn = axisCF * CFrame.Angles(0, steerAngle, 0) * axisCF:Inverse()
  steering.CFrame = turn * steeringRestCF
  headlight.CFrame = turn * headlightRestCF
  wheelF.CFrame  = turn * wheelFRestCF * CFrame.Angles(-spin, 0, 0)   -- also spins around its axle
  ```
  (Use `Motor6D`s, welds, or per-frame CFrames, whichever my bike uses. Do it on the client for smoothness.)
- The rider's **hands stay on the grips** while the handlebar turns (see the animation section).

### Bell and light
- **Bell:** a short "ting" with a small gold sparkle at the bell (position (0.42, 2.107, -1.926)) when the player
  presses the horn key (use the bike's horn key and mobile button if it has one; otherwise `H`). Cooldown 0.4 s.
- **Headlight:** make `Headlight` **Neon** (warm white) with a small `SpotLight` (range 25, angle 60°), and turn it
  **on at night/dusk** only (use the day/night phase if it exists, otherwise `Lighting.ClockTime`).

---

## 4. Riding animation (standing on the deck)
The rider **stands on the deck** facing forward, holding the handlebar. Positions relative to `Body`:

| Point | Position |
|---|---|
| Deck top (sole level) | Y = -0.389 |
| Front foot (left) | (-0.38, -0.393, -0.991) |
| Back foot (right) | (0.38, -0.393, 0.009) |
| Left grip | (-1.03, 2.007, -1.926) |
| Right grip | (1.03, 2.007, -1.926) |

See `assets/scooter/scooter_rider_pose.png` for the stance I want.

**How to build the animation:** reuse whatever the bike does for its rider. If the bike uses an uploaded
Animation asset, **don't try to upload one**; instead pose the rider **procedurally** on the client, like my
`CatGait`: sit the character on a hidden `Seat` (or use the same attach method the bike uses) so it moves with
the scooter, then drive the `Motor6D.Transform` values (hips, knees, ankles, spine, shoulders, elbows, neck) every
frame with **two-bone IK** so the **feet stay planted on the deck** and the **hands stay on the grips**. Blend
between states over 0.1–0.25 s. Nothing should snap, slide, float or clip.

### States

| State | What it looks like |
|---|---|
| **Idle (stopped)** | standing in the staggered stance, knees slightly bent, a little breathing sway, head looking around now and then, one hand on each grip |
| **Push-off** (starting from a stop, or after braking) | the **back foot comes off the deck, kicks the ground behind** (2–3 pushes, about 0.45 s each) while the front leg stays bent and the body leans forward; the scooter accelerates with each kick. The foot touches the ground (raycast) and a small dust puff plays. |
| **Glide (cruising)** | back foot returns to the deck, both knees bent about 20°, a relaxed lean forward, a tiny up-down bob with the speed, hair/clothes steady. Every 6–8 s of cruising at speed, one extra **small kick** for style. |
| **Turning** | the body **leans into the turn** (torso roll up to 10° toward the inside, hips shift slightly), the head looks into the turn, the arms follow the handlebar so **the hands stay glued to the grips** as it rotates |
| **Braking** | the back foot **stomps onto the rear fender** (the foot goes to about (0, 0.55, 2.3) from `Body`), the body leans back about 10°, arms straighten. A short skid sound, and tiny sparks/dust at the rear wheel. |
| **Going over a bump/jump** | knees absorb it (squash down 0.2 studs), arms stay on the bars. In the air, legs tuck slightly. A small landing squash. |
| **Reversing** | slow walk-backward shuffle: the back foot pushes the other way, the body upright |

### Riding while holding boxes
- Use my existing **carry-box pose** (both hands on the box stack in front of the chest), **plus the standing stance
  on the deck**. The **hands hold the boxes, not the grips**. The handlebar still steers visually.
- **The stack must clear the handlebar and the bell:** the bottom of the carried boxes should sit **above Y = 2.4**
  (from `Body`) at the grips. If the existing carry offset puts them lower, raise the stack while riding and
  lower it again when the rider gets off. **Test with the maximum stack the game allows**, so it never clips
  through the bars or hides the whole screen (also check the camera).
- With boxes, the push-off kick is slightly weaker (less speed per kick) and the lean is smaller (about 6°). The
  boxes bob and sway **slightly** with bumps and turns (a few degrees, spring-damped), but never fall off.
- The existing rules for carrying (delivering, dropping, stealing by wolves/dogs) keep working while on the
  scooter. If the rider gets knocked off (wolf, ragdoll, death), they **dismount** cleanly: the scooter stops,
  and the boxes behave as they do for the bike.

### Getting on and off
- **Mount:** the rider walks up, a short hop onto the deck (0.3 s), then settles into the idle stance.
- **Dismount:** a small hop off beside the scooter, which then stops with a little roll. Nothing teleports.

---

## 5. Sounds
Find good sounds on the Creator Store that are public and usable, and check each one plays. Tell me every
asset ID. Keep them **light and cute**, quiet, positional (3D), with random pitch ±8% and 2–3 variants.

| Event | Sound |
|---|---|
| Rolling | a soft **wheel whirr** loop that gets higher in pitch and louder with speed (0.8× → 1.4×), quieter on grass |
| Kick/push | a **scuff** on the ground each push, with a tiny shoe thump |
| Bell | a bright gold **"ting"** (two quick rings if pressed twice) |
| Brake | a short **squeal + scrape** that scales with speed |
| Mount / dismount | a light hop thud and a small metallic rattle |
| Landing | a small thud and a rattle |
| Bump | a soft clunk over bumps |

Reuse sounds from my bike (rolling, bell, ground scuff) where they exist and fit.

---

## 6. Effects (small, clean, front-page quality)
If the VFX pack from my wolf prompts is set up (`VFXAssets`), reuse `fb_smoke_4x4`, `p_spark`, `p_sparkle`,
`p_leaf` and the others. Otherwise make simple versions. Keep everything small and cheap.

| Moment | Effect |
|---|---|
| Push-off | a tiny dust puff at the kicking foot |
| Cruising | very light dust trailing off the rear wheel on dirt/pavement and tiny grass bits on grass (about 3 particles per second at speed) |
| Braking | a small spark + dust at the rear fender/wheel and a short skid-mark decal on pavement (fades in 3 s) |
| Bell | a small gold sparkle ring at the bell (no text) |
| Fast turns | a soft dust puff from the outer wheel |
| Landing | a small dust ring under the wheels |
| Night | the headlight glow (SpotLight + a soft cone), and a small red glow at the rear reflector |
| Mounting/changing paint | a quick sparkle pop on the scooter |

Effects only render for players within about 80 studs.

---

## 7. The garage / vehicle UI
- The scooter appears in the vehicle list as the **default vehicle** ("Scooter"), always owned, with only the
  **colour picker** (5 swatches, same look as the bike's). Use the scooter's red texture as the preview, or a
  ViewportFrame of the model.
- Don't show upgrade prices, stats bars for upgrades, or locked slots for it.
- Selecting a colour changes the model **immediately** (the same sparkle pop) and saves it.

---

## 8. Admin panel
Add to my owner-only admin panel (same style and permission checks):

| Command | What it does |
|---|---|
| **Give scooter** | grants/spawns the scooter for the selected player |
| **Set scooter paint** | picks one of the 5 paints for the selected player |
| **Scooter debug** | draws the steering axis, wheel contact points, foot and hand targets |

---

## 9. Performance and bug-proofing
- Do the visual wheels, steering and the rider IK **on the client**. The server only knows the vehicle's CFrame,
  speed and steer input (replicated as attributes).
- Clean everything up when the player leaves, resets, dies or despawns the scooter. No leftover parts, sounds or
  loops. The rider is never stuck in the riding pose after getting off.
- Check: the scooter works when the player **resets** the character, **respawns**, **teleports** (factory doors,
  the delivery truck), or **joins mid-session** (other players see the steering, wheel spin and animation).

## 10. Test before you tell me it's done
- [ ] A **new player** spawns with the scooter available, and an existing save also gets it.
- [ ] It's clearly slower than the bike but faster than walking. Report the speeds.
- [ ] Wheels spin at the right speed, the handlebar, front wheel and headlight turn together around the tilted axis, and
      the hands stay on the grips at full lock both ways.
- [ ] The feet stay planted on the deck (no sliding or floating) in every state: idle, push, glide, turn, brake,
      bump, reverse.
- [ ] Riding with boxes works with the max stack: nothing clips through the bars or the bell, the camera is
      usable, and delivering/dropping boxes works.
- [ ] All 5 paints apply to all 5 parts, are saved, and the UI shows only the paint option.
- [ ] Sounds and effects play, are quiet and positional, and clean up.
- [ ] Other players see everything correctly. No errors in the output. The frame rate stays smooth with 20 players
      riding.

**Report:**
- what you built and changed, and what you backed up
- the speeds you chose (and the bike's)
- every asset ID you used
- anything you couldn't do or want me to decide
