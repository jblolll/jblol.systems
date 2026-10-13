# Prompt: fix the dealership customising + a GTA-style "drive into the garage" cutscene (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. Two things are broken at the **car dealership**, and I want the second
one rebuilt properly, like **Los Santos Customs in GTA V**:

1. **The customise UI doesn't work.** I opened the customise menu for my truck at the dealership and **couldn't click
   anything**. Nothing reacted, and there was no error in the output.
2. **The service door doesn't work.** You're supposed to be able to **drive up to the dealership's service door**.
   The door opens, you drive in, it shuts behind you, and you customise the car inside. I drove up to it and
   **nothing happened**: the door never opened and I couldn't drive in.

What I want (the full flow):

> I drive up to the service door → **the door rolls open** → as I start to drive in, **a cutscene** plays of my
> vehicle rolling into the garage and the door shutting behind it → the **upgrade menu** opens with the camera on my
> car → I click **Done** → **another cutscene**: the door opens back up and my car drives out → the door closes and
> I get my controls back.

It must feel like a polished front-page Roblox game: smooth cameras, no snapping, no flicker, no getting stuck,
and it works on PC, mobile and gamepad.

---

## 0. Before you change anything
1. **Read the existing code first** and reuse it. Don't build a second system next to the old one. Find:
   - the dealership: its model, the service door (and any trigger part, `ProximityPrompt`, `Touched` handler or
     zone script on it), and the customise/upgrade UI and its scripts
   - how vehicles work: spawning, ownership, seats and the driver, `VehicleUpgrades` (including `Paints`),
     how upgrades are bought, saved and applied, and the remotes for all of it
   - every vehicle type (scooter, bike, caddy, pickup/truck, …) and which upgrades each one allows. The scooter is
     **paint only**.
   - the systems that take over the camera or the controls: the wolf death cutscene, the paw-print transition,
     ragdoll, the day/night clock UI, and the vehicle camera. The new cutscenes must not fight with them.
2. **Back up** every script, UI and model you change (an `_OLD` copy, disabled).
3. Tell me **what you found was wrong for each bug** (the actual cause) before you fix it. Then show me a short plan
   and build it.
4. Put every number in this prompt (distances, timings, camera positions, speeds) in a `CustomsConfig` module.

---

## 1. Bug 1: the customise UI can't be clicked
Find the **real cause**. Don't paper over it. Things that silently cause "nothing is clickable, no error" in Roblox,
roughly most likely first:

| Cause | How to check |
|---|---|
| **An invisible frame on top eats the clicks.** A full-screen `Frame`/`ImageLabel`/`TextButton` with `BackgroundTransparency = 1` but `Active = true`, or any button, sitting above the menu (higher `ZIndex`, or a ScreenGui with a higher `DisplayOrder`, e.g. the transition, letterbox, notification or HUD guis) | Playtest, open the menu, then for the mouse position call `PlayerGui:GetGuiObjectsAtPosition(x, y)` and print the list. The first object is what gets the click. |
| **The mouse is locked or hidden** while in a vehicle: `UserInputService.MouseBehavior = LockCenter` (vehicle camera or shift-lock), or `MouseIconEnabled = false`. The cursor is stuck in the middle, so clicks never reach the buttons. | Print `MouseBehavior` and `MouseIconEnabled` while the menu is open. While the menu is open, set `MouseBehavior = Default` and show the icon, every frame if a camera script keeps re-locking it. Restore both when the menu closes. |
| **`GuiObject.Interactable = false`**, or `Active = false` on a `TextButton`/`ImageButton`, or a button inside a `CanvasGroup` / a parent with `Visible = false` | Check the properties on the buttons and their ancestors. |
| **The click handlers were never connected.** The LocalScript lives in `StarterGui` and the ScreenGui has `ResetOnSpawn = true`, so the script runs before or against a GUI that gets replaced. Or it `WaitForChild`s something that never arrives (infinite yield, so no error). Or it's a `Script` instead of a `LocalScript`. | Add temporary prints in the button handlers. Look for "Infinite yield possible" warnings. |
| **A `ContextActionService` action sinks mouse input** (a vehicle or combat binding returning `Sink` for `MouseButton1`), or `GuiService.SelectedObject`/gamepad selection traps input | List the bound actions while the menu is open. |
| **The server silently refuses.** The buttons work, but the remote returns false or nothing (the ownership check fails because the truck is a "spawned vehicle" rather than an "owned vehicle", the wrong vehicle ID is sent, or there's not enough money), and the UI shows no feedback, so it *looks* broken | Print what the remote sends and gets back. |

- Fix the cause, then **check every button** in the menu works with **mouse, touch and gamepad**, for **every vehicle
  type**, both from the dealership and inside the garage.
- Always give feedback for a refused action: a short shake of the price plus a soft "nope" sound when you can't afford
  it, and a lock icon when it's not available for that vehicle. Never a dead click.
- **The garage (section 3) and the dealership menu must use the same upgrade menu module**, so this never breaks in
  one place but not the other.

---

## 2. Bug 2: the service door doesn't react
- Find out why: the trigger may be missing, too small or not `CanQuery`/`CanTouch`; it may only detect the character
  and not a seated player in a vehicle; it may check the wrong vehicle owner attribute; it may be server-only with
  no client part; or the door model may have been moved or renamed.
- Rebuild it the way section 3 describes, using the existing door model if it's good. If there isn't a proper door,
  build a **roll-up garage shutter** that fits the dealership's style: a slatted metal shutter that rolls up into a
  box at the top, painted frame, a striped bumper strip, and two small amber lights.

---

## 3. The garage flow (GTA Los Santos Customs style)

### 3a. Driving up
- An **entry zone** sits in front of the service door: a box about the door's width, 14 studs deep, using
  `GetPartBoundsInBox` or a zone check on Heartbeat. **Don't rely on `Touched`**: it misses seated players and fast
  cars.
- It triggers when **all** of these are true:
  - the player is the **driver** of a vehicle **they own**
  - the vehicle is facing the door (within about 60°) and moving slower than about 25 studs/s
  - the player isn't in a wolf fight, being chased, dead or ragdolled, and isn't in another cutscene
- **When they get close (about 25 studs):** the door's amber lights blink, and the **door rolls up** (1.2 s, ease out,
  with a motor rumble and a clank when it stops). If the player drives away, it rolls back down after 3 s.
- **If they can't enter** (they're on foot, it's not their vehicle, or they're in a fight), the door doesn't open.
  Show one small icon above the door (a wrench with a slash) when they're within 15 studs. No text.
- **When the front of the vehicle crosses the door line, the entry cutscene starts.** The player never has to
  press anything.

### 3b. Entry cutscene (about 4 s, skippable)
1. **Take control smoothly.** The player's inputs stop and the vehicle is driven by script (keep its current speed,
   then ease down to a crawl). Letterbox bars slide in (0.3 s). Hide the HUD, the day/night clock and the wolf
   arrow. The mouse is freed.
2. **Shot 1 (outside, about 1.8 s):** a low camera beside the door, angled so we see the car roll inside. **The
   shutter comes down behind it** (rumble, then a heavy clang when it hits the bottom, and a small dust puff along the
   bottom edge).
3. **Shot 2 (inside, about 2 s):** the camera is inside the bay, low and in front. The car rolls onto the **lift
   platform** and stops. The brake lights flash, the suspension dips a little, and the overhead lights clunk on one
   row at a time.
4. The camera glides to the **menu camera** (3c) and the menu slides in.
- **Skip:** a small skip button in the corner (the same style as the death cutscene skip), and tapping/clicking or
  pressing gamepad B skips to the menu, using the paw-print transition.
- Use `Camera.CameraType = Scriptable` and `TweenService` or a spline for each shot. **No hard cuts mid-move.** A
  cut between shots is fine, but cover it with a quick 0.15 s fade or the paw-print transition.

### 3c. Where the garage actually is (so it works with many players at once)
- Use a **private garage bay for each player**. Build **one garage interior** (see 3e). The server keeps **8 copies**
  far away from the map (for example 2,000 studs below it, spaced 200 studs apart) and **reserves one** for each
  player entering.
- **During the cut between shot 1 and shot 2**, the server moves the vehicle (and the player in it) to the reserved
  bay's entry point:
  - use `PivotTo`, with the vehicle anchored for the move and then unanchored
  - keep the velocity at a crawl
  - keep network ownership with the driver
- Players outside just see the car drive in and the shutter close. Any number of players can customise at the same
  time.
- If all 8 bays are full, the door stays shut and shows the wrench icon with a little clock. That should basically
  never happen.
- **Passengers** come along and watch the same cutscenes, but **only the owner gets the menu**. Passengers see the
  car and the changes live.
- **Boxes the player is carrying** stay exactly as they are and come back out with them.

### 3d. The upgrade menu (like LS Customs)
- **Layout:**
  - **left side:** a vertical list in the game's UI style
  - **top of the list:** a banner with the dealership's logo and the vehicle's name
  - **the list:** categories, then items
  - **right edge of each row:** the price, a tick on what's installed, and a lock on what's not available
  - the selected row is highlighted, with a small slide-in animation
  - the player's money at the top right
- **Categories come from the vehicle's allowed upgrades** in `VehicleUpgrades`, for example Paint, Engine/Speed,
  Capacity, Wheels, Horn and whatever exists. **The scooter shows only Paint.** Never show an empty category.
- **The camera follows the category**, smoothly (0.6 s glide):
  - **Paint:** a slow orbit of the whole car (3/4 view)
  - **Wheels:** a low close-up on the front wheel, which spins slowly
  - **Engine/Speed:** the front, with the hood or engine area lit and a small rev sound
  - **Capacity/bed/basket:** a high back 3/4 view of the cargo area
  - **Horn:** a front close-up, and the horn plays when you select an item
  - **Main list:** a slow 360° turntable orbit (the lift platform turns slowly, like a showroom)
  - The player can **drag to orbit** and **scroll/pinch to zoom** within limits (right stick on gamepad). It returns
    to the category's shot after 3 s of no input.
- **Live preview:** hovering or selecting an item shows it on the car right away, with a little tool sound and a
  sparkle for paint. **It's only a preview on the client** until it's bought. Leaving the item without buying reverts
  it.
- **Buying:**
  - press the item again, or "Buy"
  - the server checks ownership, the vehicle type, the price and the money, then charges, saves and applies it
  - the UI plays a short cha-ching, the money counter ticks down, and the tick moves to the new item
  - there's a short work animation on the car: a spray mist for paint, sparks and a wrench clank for engine parts,
    an air-gun "brrt" for wheels
- **The server is authoritative.** The client never decides the price or applies a real upgrade by itself. Rate-limit
  the remotes.
- **Controls:**
  - **PC:** mouse, plus arrows/WASD to move, Enter to buy, Backspace/Esc to go back
  - **Gamepad:** D-pad and A/B, with proper `GuiService.SelectedObject` selection and a visible selection highlight
  - **Mobile:** big tap targets (at least 44 px), and the list scrolls
- **Done** is at the bottom of the main list, and Back/Esc on the main list also means Done. A confirm prompt only
  appears if a preview hasn't been bought ("Leave without buying?").

### 3e. The garage interior (build it to match the game's style)
A cosy, cartoon **workshop bay**:
- **Lift and walls:** a round lift platform with yellow-black chevron edges, set into the floor, that can rotate.
  Brick or painted block walls.
- **Tools and storage:**
  - a tool wall with a pegboard, spanners and a cat-paw logo
  - tyre stacks and a red rolling tool chest
  - paint cans on a shelf
  - a workbench with a vice
  - a hanging work lamp over the car
- **Decor:** a "Purr Autos"-style sign or the dealership logo, oil stains on the floor, and a little cat bed in the
  corner with a sleeping cat (just a static model, or a simple idle loop).
- **The shutter:** the back of the same roll-up door, seen from inside.
- **Lighting:** warm overhead strip lights. Use `PointLight`s/`SurfaceLight`s and keep the count small for
  performance. Ambient garage sounds: a radio playing quietly (low volume), the occasional air compressor hiss.
- Keep it **compact** (about 40 × 30 studs) so the cameras always frame the car well. Make sure the **biggest
  vehicle** (the truck) fits with room around it, and the scooter doesn't look lost (zoom the cameras by vehicle size).

### 3f. Exit cutscene (about 4 s, skippable)
1. The menu slides out. Lights flash amber, and the **shutter rolls up** from inside: a bright daylight (or
   streetlight at night) rectangle opens on the car, with the motor rumble.
2. **During a quick fade or paw transition**, the server moves the vehicle back to the **exit point just inside the real
   dealership door**, facing out, with the real door already open.
3. **Shot (outside, about 2.5 s):** a camera on the forecourt, 3/4 in front. The car **drives out** of the real door
   (scripted throttle, the new paint gleaming), with a little exhaust puff for vehicles that have engines (none for the
   scooter or bike), and the **door rolls down behind it**.
4. The camera blends back to the normal vehicle camera behind the car (0.5 s). The letterbox slides out, the HUD comes
   back, and **control returns while the car is still rolling**, so it feels seamless. Free the bay reservation.
- The exit point must be clear. If something is blocking it (another car or a player), shift the exit point
  sideways, or wait up to 1 s, then go.

---

## 4. Safety and edge cases (nothing can get stuck)
- **Use one state machine**, kept on the server with a client copy: `Outside → DoorOpening → EntryCutscene → InMenu
  → ExitCutscene → Outside`. Every state has a **timeout** (cutscenes 8 s, menu 10 min) that falls back to a safe
  exit.
- **If the player leaves, dies, resets, gets kicked off the vehicle, or the vehicle despawns** at any point:
  - free the bay
  - put the vehicle (if it still exists) and the player back outside the dealership door
  - restore the camera, mouse, HUD, controls and letterbox
  - revert any unbought preview
- **Teleports and admin commands** (bring, teleport) while inside cleanly end the garage session first.
- **Wolf raids:** a raid doesn't interrupt someone who is already in the menu. Wolves can't reach the private bays. If
  the player was the target of a wolf, the wolf picks a new target.
- Players can't fall out of the hidden bays: give them invisible walls and a floor, and keep them out of reach of
  other systems (strays, mice, dogs and the day/night lights must ignore that area).
- `Workspace.StreamingEnabled`: if it's on, call `Player:RequestStreamAroundAsync` for the bay before moving the
  vehicle there, and for the exit point before moving it back. **No falling through unloaded floors.**
- The cutscenes and menu restore **exactly** what they changed: `CameraType`, `CameraSubject`, FOV,
  `MouseBehavior`, `MouseIconEnabled`, `CoreGui` toggles, HUD visibility and control bindings.

---

## 5. Sounds
Find good, public, usable sounds on the Creator Store and check that each one plays. Tell me every asset ID. Use 3D
sounds at the door, and 2D sounds for the menu UI.

| Event | Sound |
|---|---|
| Door rolling up/down | a roll-up shutter motor rumble, then a heavy clang at the bottom and a softer clank at the top |
| Door lights | a soft alarm beep while it moves (quiet) |
| Lights turning on | fluorescent clunk-buzz, one per row |
| Menu move / select / back | soft clicks (different pitches) |
| Buy | a cash register cha-ching |
| Can't afford | a soft "nope" buzz |
| Paint | a spray-can hiss |
| Engine/speed upgrade | an air ratchet + engine rev (no rev for the scooter or bike) |
| Wheels | an impact-wrench "brrt" |
| Ambient | quiet garage radio + occasional compressor hiss |

---

## 6. Admin panel
Add these to my owner-only admin panel (same style and permission checks):

| Command | What it does |
|---|---|
| **Open customs for player** | starts the garage flow for the selected player's current vehicle (skips the drive-up) |
| **Force exit customs** | safely ends their garage session and returns them outside |
| **Customs debug** | shows the entry zone, the bay reservations, the state machine state per player, and the camera path points |

---

## 7. Test before you tell me it's done
- [ ] The customise menu at the dealership is clickable with **mouse, touch and gamepad**, for the truck **and every
      other vehicle**. Tell me what the actual cause was.
- [ ] Driving the truck up to the service door opens it, and driving in plays the entry cutscene, with the door
      closing behind me.
- [ ] Each category moves the camera to the right shot. Previews show live and revert if not bought. Buying charges
      the right money, saves, and survives a rejoin.
- [ ] Done → the exit cutscene: the door opens, the car drives out, the door closes, and controls come back
      smoothly while still rolling.
- [ ] The skip button works on both cutscenes.
- [ ] The scooter only shows Paint. The truck, the biggest vehicle, fits in the bay and the cameras frame it well.
- [ ] Two players can customise at the same time, and a third can still drive in.
- [ ] Resetting, leaving, dying and admin-teleporting mid-cutscene and mid-menu all recover cleanly. I never get
      stuck with no controls, a locked camera or a hidden HUD.
- [ ] No errors or warnings in the output, and no infinite yields.

**Report:**
- the cause of both bugs and how you fixed them
- what you built and changed, and what you backed up
- every asset ID you used
- anything you couldn't do or want me to decide
