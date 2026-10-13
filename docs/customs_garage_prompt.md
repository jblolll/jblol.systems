# Prompt: fix the dealership customise UI and the service door, plus drive-in/out cutscenes (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. There are two bugs at the **car dealership**, and one small feature to
finish. **Keep everything else exactly as it is.**
- **Don't change:** the inside of the dealership, the upgrade UI's look, or the NPC.
- **Don't add:** new rooms, new menus or new systems.

## 1. Bug: the customise UI can't be clicked
I talked to the dealership NPC to customise my truck. The UI opened, but **I couldn't click anything**, and there was
no error.
- Find the **actual cause**. Common silent causes:
  - an invisible frame or button on top taking the clicks (check with `PlayerGui:GetGuiObjectsAtPosition`)
  - the mouse locked to the centre or hidden (`MouseBehavior` / `MouseIconEnabled`)
  - the button handlers never connected (`ResetOnSpawn`, or an infinite `WaitForChild`)
  - `Active` or `Interactable` turned off
  - the server remote silently refusing
- Fix it. Don't change how the UI looks.
- Check it works for every vehicle, with mouse, touch and gamepad.

## 2. Bug: the service door doesn't open
Driving up to the dealership's service door used to make it **slide up like a garage door**. Now nothing happens.
- Find out why it stopped working and fix it, so it opens **the same way it did before** (it moves straight up).
- It opens when a player **drives up to it in a vehicle they own** (as the driver). It closes again if they drive
  away.

## 3. Feature: drive in → cutscene → the same upgrade UI → cutscene out
1. The door slides up, and as the player **starts to drive in**, their controls are taken over and a **short
   cutscene** plays (about 3 s):
   - the camera shows their vehicle driving in through the door
   - the door slides back down behind them
2. Then the player gets the **exact same upgrade UI, and the same inside view**, as when they walk in and talk to
   the NPC. **Reuse that same code path.** Don't make a copy.
3. When they click **Done**, a second short cutscene plays (about 3 s):
   - the door slides up
   - their vehicle drives back out
   - the door slides down behind them
4. Then the normal camera and **controls go back to the player**, still in their vehicle, outside the door.

**Rules:**
- The cutscene camera moves smoothly, with no snapping. Hide the HUD during the cutscenes and bring it back after.
- Whatever the cutscenes change, put it back exactly as it was afterwards:
  - the camera type and subject
  - the mouse behaviour and icon
  - the HUD
  - the controls
- **Nothing can get stuck.** If the player dies, resets, leaves or loses their vehicle during a cutscene or in the
  UI, end it cleanly and give them back normal controls.

## Before you start
- Back up anything you change (an `_OLD` copy, disabled).
- Tell me the cause of both bugs before you fix them.

## Test before you tell me it's done
- [ ] The NPC customise UI is clickable for the truck and every other vehicle.
- [ ] Driving up opens the door the same way as before.
- [ ] Driving in plays the cutscene, then shows the same UI as the NPC. Done plays the drive-out cutscene, and my
      controls come back.
- [ ] Resetting or dying mid-cutscene or in the UI recovers cleanly.
- [ ] No errors in the output.

**Report:** the cause of both bugs, what you changed, and what you backed up.
