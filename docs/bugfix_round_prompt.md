# Prompt: bug-fix and polish round (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. Below is my list of bugs and changes, **ordered from worst to least
bad**. Work through them **in this order**.

**For every item:**
1. **Reproduce it first** in a Play test, and tell me what you saw.
2. **Find the root cause** in the code. Don't patch the symptom: no `task.wait()` band-aids, no hiding errors with
   `pcall` and moving on.
3. **Fix it**, then **re-test the exact repro steps**, plus anything the fix could affect.
4. Report back in one line: the root cause, what you changed (scripts and functions), how you tested it.

Don't break anything that currently works. If two items touch the same system, fix them together. If something is
unclear or there are two reasonable designs, ask me before building.

---

## PRIORITY 1: game-breaking (players lose progress or can't use core features)

### 1. Inventory sometimes doesn't open
- **Symptom:** clicking the Inventory button sometimes does nothing.
- **Likely causes to check:**
  - a race at join (the button is wired before the inventory GUI or player data exists)
  - an error thrown in the open function partway through
  - a "busy" or "isOpen" flag that never resets after another UI closes
  - another ScreenGui (crate stage, shop, admin) left enabled or blocking input
  - `WaitForChild` timing out
- **Fix requirements:**
  - Opening works on the **first click every time**, including right after joining, after respawning, after a crate
    or chest opening, and after closing any shop.
  - Use one central UI manager that knows which panel is open, so opening one panel closes the others cleanly.
- **Test:** open and close the inventory 20 times in a row, mixed with opening shops and crates. Also test right after
  joining and after a reset.

### 2. Can't open crates or chests from the inventory
- **Symptom:** the Open / Open x3 / Open All buttons for crates and chests in the inventory don't work.
- **To do:**
  - Trace the full path: button → BindableEvent / remote → server `open` / `openMany` → reply → opening stage.
  - Find where it breaks: a renamed remote, a changed event name, wrong arguments, the server rejecting the request,
    the stage failing to start, or the busy flag stuck from an earlier open.
- **Test:** every crate type and every chest rarity, with x1, x3 and All. Inventory counts must go down correctly and
  rewards must be granted and saved.

### 3. Toolbar (hotbar) sometimes doesn't show at all
- **To check:**
  - Is `StarterGui:SetCoreGuiEnabled(Backpack)` or the custom toolbar left disabled by another system (the crate stage,
    the cat morph, an admin effect, a vehicle seat) that didn't restore it?
  - Is the custom toolbar GUI created before the character or tools exist?
  - Is `ResetOnSpawn` set wrong?
- **Fix requirements:**
  - Every system that hides HUD or toolbar must restore the **previous** state through a shared HUD visibility
    manager, using a reference count or a stack, so two systems can't fight over it.
- **Test:** join, respawn, sit in and leave each vehicle, open and close crates and chests, use the admin morph. The
  toolbar is always there when it should be.

### 4. The bike bought from the NPC disappears after purchase and you can't get on it
- **Symptom:** after buying from the NPC (Cate), the vehicle vanishes, so the player paid and got nothing usable.
- **To check:**
  - the spawn location and position (spawned under the map or inside a part and fell away)
  - it got destroyed by a cleanup or anti-exploit script
  - network ownership or anchoring
  - the seat not being enabled
  - the purchase being recorded but the spawn failing
- **Fix requirements:**
  - After purchase, the vehicle is **saved to the player**, **spawns in a clear, visible spot next to them** (raycast
    to the ground, check there's room), and the player can sit on it immediately.
  - If spawning fails, the purchase is **not charged**, or it's refunded, and the player gets an error message.
- **Test:** buy it with a fresh test profile. It appears, you can ride it, it survives rejoining (respawn from the
  save), and buying it again isn't possible if it's a one-time purchase.

### 5. Admin panel: most crate and chest opening commands don't work on players
- **To do:**
  - Fix the "open crate/chest" (forced result), "give crates/chests" and "open on player" commands so they run the
    **real** opening flow on the **target player's** client, with the right rarity or result.
  - Fire the target player's client, not the admin's, and make sure arguments are validated and passed correctly.
- **Test:** run every crate and chest admin command on myself and on a test player, via both panel buttons and chat
  commands.

---

## PRIORITY 2: UI that blocks players

### 6. Shop can't be closed: the minimap/map covers the X button
- **Fix:**
  - Close buttons must always be on top and reachable. Raise the shop's `DisplayOrder` above the map, and/or move the
    X button inside the shop frame's safe area.
  - Hide or shrink the minimap while any full-screen shop or menu is open.
  - **Every** menu also closes with **Esc / B (gamepad) / tapping outside the panel**.
- **Test:** open every shop and menu on PC and on phone sizes. The X is always visible and clickable.

### 7. All UIs must work on mobile and small screens
- **Audit every ScreenGui:**
  - shops, inventory, crate/chest opening, admin panel, quest tracker, dialogue, toolbar, notifications, vehicle
    upgrade UI, manager desk
- **Rules:**
  - use **Scale** sizes (not Offset), with `UIAspectRatioConstraint` and `UISizeConstraint` (min/max)
  - use `UIScale` driven by the screen size, so everything shrinks on small phones and nothing grows huge on 4K
  - respect the **safe area**: `ScreenInsets = CoreUISafeInsets`, so nothing goes under the notch, Roblox's top bar,
    the mobile jump button or the thumbstick
  - touch targets at least about 44×44 px, and text set to `TextScaled` with `UITextSizeConstraint` (no text smaller
    than about 11 px)
  - long lists scroll (a ScrollingFrame with `AutomaticCanvasSize`) instead of overflowing
  - no two UIs overlap their clickable areas
- **Test:** in Studio's Device Emulator, check every UI on iPhone SE (small), iPhone 14, iPad, a 1080p laptop and a
  4K monitor, in both landscape orientations. Send me screenshots of the shop, inventory and admin panel on iPhone SE.

---

## PRIORITY 3: vehicle and gameplay behaviour

### 8. Leaving the delivery truck: put the player outside it
- **Problem:** players get stuck in, on top of, or under the truck when exiting.
- **Fix:**
  - On exit, teleport the player to a free spot **beside the driver's door**, about 3 studs out, on the ground.
  - Check it's free with a raycast and an overlap check. If it isn't, try the passenger side, then behind the truck.
  - Restore their visibility (the driving-invisibility fix), camera and controls.
  - Do the same for every vehicle that needs it.

### 9. Remove bat protection
- Find the "bat protection" system: whatever currently stops bat hits (a shield, immunity, a safe-zone or a protection
  upgrade).
- Remove it **completely**: the code, any UI, any shop item or upgrade, and any saved data flag. Clean up references so
  nothing errors.
- **Tell me what it was** and what you removed. If players paid for it, tell me first so I can decide whether to refund.

### 10. Cars can run over players
- **Behaviour:** when a vehicle hits a player above about 12 studs/s:
  - the player is **knocked back and ragdolled** (use the admin ragdoll system: a real physics ragdoll), flung in the
    direction of the hit, scaled by speed
  - they get back up after about 2 s
  - there's an impact sound and a dust puff, and a small camera shake for the driver
- **Rules:**
  - **No death, no coin loss, no item loss.** It's just funny.
  - A short immunity per player (about 3 s) so they can't be chain-hit.
  - The car loses only a little speed.
- **Server validation:** the driver must really be moving at that speed, and must be the vehicle's network owner, so
  exploiters can't fling people.

### 11. Breakable decor (trees, lamp posts and so on) must react naturally
- **What's wrong now:**
  - Decor vanishes or pops unnaturally.
  - The car **slows down hard** on impact, which feels bad.
  - Low-speed hits still break things.
- **What I want:**
  - **Impact strength:** based on speed relative to the object, and the hit direction (where on the object it was
    hit).
  - **Below the break threshold** (config per type: trees, lamp posts, signs, benches, bins): the object **doesn't
    break**. The car bumps it: a short wobble or shake of the object, a thud sound, and the car stops naturally like
    hitting a solid thing. No weird slow-motion drag.
  - **Above the threshold:**
    - The object breaks free and **flies away along the impact direction**, with speed and spin based on how hard and
      where it was hit (a low hit makes a tree topple over the car, a side hit spins it away).
    - It uses real physics: unanchor a copy, apply an impulse and angular impulse at the impact point, and keep it
      collidable with the ground but **not** with the car for 1 s.
    - **On landing:** a dust or leaves burst (leaves for trees, sparks plus glass bits for lamp posts), a landing thud,
      and a small bounce or roll.
    - It fades out after about 6–8 s, and **respawns** at its original spot after about 60 s with a little grow-in
      animation (only when no player is standing in its spot).
  - **Bushes and small plants never break or stop the car.** The car drives straight through. The bush shakes and
    sprays leaves as it passes.
  - **The car must not slow down unnaturally:**
    - Breaking an object costs only a small, believable speed loss, scaled by the object's mass (trees a bit more,
      signs almost none).
    - Remove any code that clamps or hard-drops the car's velocity on hit.
- **Performance:** at most about 10 flying debris pieces at once (oldest removed first). Debris is client-visible but
  server-owned, or simulated client-side with the server deciding the break, so it doesn't lag.
- **Test:** hit every decor type at slow, medium and fast speeds, and from the front, side and corner. Drive through
  bushes. Check the respawns.

---

## PRIORITY 4: polish and features

### 12. Admin: give **temporary** vehicles
- A new option on the vehicle commands: **Give temporary** (default) vs **Grant permanently** (saved).
- **Temporary vehicles:**
  - spawn for the target player and work fully
  - are **never written to the save**
  - disappear when the player leaves, or when a set duration ends (choose 5 / 15 / 60 min / until leave)
  - show a small "TEMP" tag in that player's vehicle UI
- The upgrade, paint and nitro commands can apply to the temporary vehicle without touching saved data.

### 13. Admin panel: collapsible folders inside tabs
- **Groups:** inside each tab, group commands into **collapsible folders** with a header row (arrow icon, name and
  count), e.g. Vehicles → Spawn / Upgrades / Paint / Temporary.
- **Behaviour:**
  - the open/closed state is remembered per folder (a saved owner preference)
  - "Expand all / Collapse all" buttons
  - the search box searches inside closed folders and auto-expands a folder with matches
  - smooth expand and collapse animation
- **Structure:** groups come from a `Group` field on each command definition, so new commands slot in automatically.

### 14. World chest: click to open, plus a cinematic
- **Opening:** replace the ProximityPrompt with a **ClickDetector** (and tap on mobile) on the chest, with a hover
  highlight and a cursor icon.
- **Cinematic sequence** (about 3 s, skippable):

| Time | What happens |
|---|---|
| 0.0–0.3 s | Quick cut (use the ScreenTransition module) to a **close-up** of the chest and the player's character. |
| 0.3–1.8 s | The character is **bent over the chest, gripping and struggling with the lid**: knees bent, arms straining, small jolts upward, the lid rattling and lifting slightly then dropping back, strain grunts. The camera slowly pushes in. |
| ~1.8 s | The **lid suddenly bursts open**. The character is **thrown backwards out of frame** (a ragdoll fling or a quick backwards tumble animation). There's a flash and a light beam from the chest. |
| 1.8–3.0 s | The camera holds on the open chest: **coins fountain out** and fly toward the coin counter, gems pop out, the rarity effects play. |
| 3.0 s+ | The **reward cards** UI shows (as in the chest opening system). |

- **Afterwards:** the character gets up next to the chest with a little dizzy-stars effect, and the camera returns.
- Use real animations: R15 and R6 versions of the struggle pose, or a procedural Motor6D animation if the uploads
  aren't ready.

### 15. Better "chest rising out of the ground" animation
- **Sequence:**
  1. **Warning:** the ground at the spot cracks (crack decal scaling in), rumbles (a small camera shake for nearby
     players) and spits dirt particles for about 0.6 s.
  2. **Burst:** the chest **shoots up** out of the ground with dirt and rocks flying, rising past its rest height
     (overshoot) and spinning slightly.
  3. **Settle:** it falls back and **lands** with a squash and bounce, a dust ring and a thud.
  4. **Idle:** it settles into a gentle float or bob with a soft glow in its rarity colour, a sparkle loop and a
     slowly rotating light beam above it.
- Use easing (Back Out for the rise, Bounce for the landing), with no linear motion. Leave a small dirt-hole decal
  where it came out, which fades later.

### 16. Stray cats can rarely fight when they pass each other
- **When:** two stray cats pass within about 4 studs on the sidewalk → a **rare** chance (config, e.g. 3%, with a
  per-cat cooldown of several minutes; never during petting or a hunt).
- **The fight sequence:**
  1. **Stop and face off:** both freeze and turn to face each other. Their backs arch, the fur puffs up, ears flatten,
     tails bush. A "!" pop.
  2. **Hiss off:** alternating hisses with mouths open and leans forward. The circling side-step: they slowly circle
     each other.
  3. **Swat exchange:** quick paw swats at each other (alternating, lunging forward and back). Small fur-tuft particles
     and comic "puff" clouds on contact. Hiss and yowl sounds.
  4. **Optional scuffle:** a short tumble: a cartoon dust cloud with paws and tails poking out, about 1.5 s.
  5. **Resolution:** one cat (random, or the smaller one) **gets scared**: ears back, a jump-startle, and it **runs
     away fast** with a scared "mrrow!", glancing back. The winner sits, does a smug tail flick, and grooms.
  6. Both return to normal wandering afterwards.
- **Rules:**
  - The cats never leave the sidewalk area.
  - Nearby stray cats may watch: heads turn toward the fight.
  - Paws stay planted (CatGait IK), with smooth transitions.
- **Admin command:** "start cat fight" on the nearest two cats.

---

## Final check
After everything, do a full regression pass:
- join → claim factory → work → sell → buy and drive each vehicle → open crates and chests → shops → admin
- on PC and in the phone emulator

Then give me a table of every item: status, root cause, the fix, and how it was tested. Flag anything you couldn't
fully fix.
