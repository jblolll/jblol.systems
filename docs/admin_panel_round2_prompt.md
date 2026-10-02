# Prompt: admin panel round 2 (fixes, cat morph, chat commands, more commands)

Great work on the admin panel. Below are fixes and additions. Work through every section, test each item in a Play
test, and give me a summary at the end of what changed and what you tested. Keep the existing security model:
owners only, everything validated on the server, everything logged.

## 1. Fix: Ragdoll doesn't ragdoll
**What happens now:** clicking Ragdoll on myself just flings me backwards. I land on my back and my running animation
plays while I lie on the ground.

**What I want:** a real, floppy physics ragdoll.

**Find the root cause first.** Most likely the Humanoid is never put into the `Physics` state on the client that owns
the character. The character keeps its stiff joints, so the Humanoid gets back up into Running. Humanoid state changes
have to happen on the owning client, not just the server.

**Proper implementation:**
- **Joints:**
  - On the server, swap each limb's `Motor6D` for a `BallSocketConstraint` between matching attachments (create them
    if missing), with sensible `UpperAngle`/`TwistLimits` so limbs bend naturally instead of spinning.
  - Keep `HumanoidRootPart` and the torso connected.
  - Enable collisions between limbs (`NoCollisionConstraint` only where parts overlap).
- **Humanoid state:**
  - Set `BreakJointsOnDeath = false` and `RequiresNeck = false` while ragdolled.
  - On the **owning client**, call `Humanoid:ChangeState(Enum.HumanoidStateType.Physics)` and disable the
    `GettingUp`, `Running` and `Jumping` states for as long as the ragdoll lasts.
  - Stop all playing animation tracks.
  - The camera follows the head.
- **Getting up:**
  - Restore the original Motor6Ds exactly (C0/C1 included).
  - Re-enable the states and switch to `GettingUp`.
  - Animations resume. Nothing is left broken.
- **R6 and R15:** works on both.
- **Options:** a duration (default 4 s), plus a toggle so the player stays ragdolled until undone. The "Fling" troll
  should ragdoll the player while they fly through the air, then they get up.

## 2. Cat morph: turn a player into a cat
- **Options:**
  - **cat type picker** (random by default) using the real cat models from `CatCatalog`
  - **duration:** a number of seconds, **until undone**, or **until respawn** (stays a cat through everything until
    the character resets)
- **The swap:**
  - Hide the character and everything it's wearing (accessories, tools, name tag) from **all** players.
  - Attach the cat rig to the `HumanoidRootPart`, sized so the cat sits on the ground.
  - Shrink the HumanoidRootPart/HipHeight so the hitbox and camera height fit a cat.
  - The camera stays smooth.
  - The player keeps their normal controls.
- **Animations:** use **my cat animations and my procedural `CatGait`** (the same system my pet cats use) on the
  morphed player, so it looks exactly like my cats:
  - **Idle:** the cat idle and sit idles (`CatIdles`, `CatSitIdle`) after standing still a few seconds.
  - **Walk:** the cat walk gait, driven by real movement speed so paws don't slide.
  - **Run:** a **new cat run/gallop gait** for when the player **sprints** (hook into the existing `Sprinting` script).
    It's longer and lower, with a bounding stride. `CatGait` already has walk and run parameter sets; extend them
    if needed so the run looks great.
  - **Jump and fall:** crouch, spring with the legs stretched, a tucked fall, a soft landing squash.
  - **Driving and riding:** when the cat sits in **any** vehicle seat (bike, wagon, caddy, pickup, truck), it sits
    upright on its haunches with its **front paws on the steering wheel or handlebars**. Its head turns slightly with
    steering, and its tail hangs or sways. Work out the steering wheel or handlebar position for each vehicle so the
    paws actually touch it.
  - **Swimming/climbing:** sensible fallbacks, if the game has them.
  - The cat can still use the bat and other tools: the tool attaches to the cat's mouth or front paw.
- **Sounds:** meow when they jump or emote, cat footsteps instead of human footsteps.
- **Undo:** restores the exact original character, appearance and HipHeight.

## 3. Toggle commands: buttons that turn into "Undo"
- Every command that has an on/off state is a toggle, including:
  - Fly, Noclip, God, Invisible, Freeze, Ragdoll (until undone), Cat morph, Speed/Jump changes, Mute, Bat always
    charged
  - every troll that has a duration
- **Undo button:** when it's active for the selected player, the button turns into a highlighted **"Undo <name>"**
  button with a different colour and an "active" dot. Clicking it undoes it.
- **Several players selected:** show "Undo (2/3 active)" and undo it for those players only.
- **State tracking:** the server is the source of truth for who has what active. The panel refreshes when that changes.
  States clear correctly on respawn and on leave.
- **"Undo all":** a button in the player info panel that removes every active effect from the selected players.

## 4. Chat commands
- **Prefix and examples:** commands start with `/`, for example:
  - `/fly`, `/fly me`, `/fly all`
  - `/speed jb 50`
  - `/cat others random`
  - `/tp me caddy`
  - `/unfly jb` (or `/fly jb` again to toggle)
- **Player matching:** partial name or display name (`jb` matches the first player whose name starts with it),
  `me`, `all`, `others`, and comma lists (`jb,alex`).
- **`/cmds`:** opens a clean, scrollable list of every chat command (name, aliases, arguments, short description),
  grouped like the panel tabs, with a search box. Only the owner sees it.
- **One command list:** chat commands use the **same command definitions** as the panel, so every panel command also
  works from chat automatically. Add short aliases (`/tp`, `/to`, `/bring`, `/ff`, `/inv`).
- **Hidden from chat:** owner commands **never appear in chat** for anyone. Block delivery on the server with
  `TextChannel.ShouldDeliverCallback`, or use `TextChatCommand` instances only the owner can trigger.
  Non-owners typing `/fly` get nothing.
- **Results:** shown to the owner only, as a small system message or toast ("Fly enabled on jb"), including errors
  ("No player matches 'xx'").
- **Also:** `/admin` opens the panel, and `/cmds` works on mobile.

## 5. Bat: "always charged" command
- Add a toggle command **Bat always charged**: every swing of the selected player's bat is a full-charge hit
  (with the full-charge effects and sounds), with no charge-up time.
- Read the bat's charge mechanic first and use its real full-charge path. Don't fake the effects.
- It shows as a toggle with "Undo", as in section 3.

## 6. Fix: my character shows while driving the delivery truck
- When anyone sits in the **delivery truck's driver seat**, their character (body, accessories, hats, held tools, name
  tag) must be **invisible to everyone**, including themselves in first and third person. They should look as if
  they're inside the cab.
- Restore everything exactly when they get out, including if they're killed or the truck is destroyed while seated.
- Check the other vehicles too, and tell me if any of them show the character where it shouldn't.

## 7. More commands (add these, plus any good ideas of your own)
Put each in the right tab. Every one has a chat alias, toggles where it makes sense, and everything is reversible.

**Player**
- Sit, jump, set walk speed / jump power / gravity per player, infinite sprint stamina.
- Shrink or grow (choose a size), headless, invisible with a ghost trail.
- Force field, heal, refresh (respawn in the same place), kill (just a respawn, no penalty).
- Give or remove tools, clear backpack.
- Goto and bring, spectate.
- Force an emote or dance, set the name tag text.
- Freeze camera, reset camera.

**Gameplay**
- Give all cats, max all workers, finish every workstation now, fill every shelf.
- Rain coins on the player (coins drop around them and they collect them).
- **Server events:** temporary double coins for the whole server, a crate luck boost, a happy hour that speeds up
  cats.
- Spawn a box buyer/customer, force a shop restock, reset every cooldown.
- Complete or replay the tutorial.
- Give each vehicle with all upgrades.
- Start a dog raid with a chosen coat, spawn a dog that follows a player as a pet.
- Make it day or night, change weather (if the game has weather).

**Troll** (harmless, timed, never touch saved data)
- Spin, flip upside down, moon jump, banana slip (trip and ragdoll), sticky floor (very slow), inverted controls.
- Drunk camera (wobble), screen shake, blind (screen fades to black for 3 s).
- Giant head, noodle arms, tiny legs, rainbow body, make them sparkle.
- Make them dance non-stop, make them say something in a chat bubble above their head (bubble only, not real
  chat), a cat army follows them, a dog chases them.
- Trap them in a glass cage, launch them like a rocket with a confetti trail, sky drop (teleport high up then
  parachute down).
- Swap their footstep sound for squeaky toy sounds.
- Fake "Legendary!" crate popup (grants nothing), a fake "+1,000,000 coins" popup (grants nothing).
- A jumpscare cat (a quick, cute cat face pop with a meow, not scary-gross).

**Moderation**
- Server message (big banner), private message to one player.
- Chat slow mode, freeze chat for everyone, kick with a reason, ban/unban (as before).
- Show a player's info card (account age, join time, playtime, coins earned this session).

## 8. Quality bar
- Every new command works in Play mode with no errors or warnings.
- Effects and undos leave nothing behind: no leftover parts, constraints, connections or changed properties.
- Panel buttons show the right on/off state immediately.
- Chat commands and panel buttons give identical results.
- Test ragdoll, cat morph (walking, sprinting, jumping, driving every vehicle), the delivery truck fix and the chat
  commands with screenshots, and list anything you couldn't test.
