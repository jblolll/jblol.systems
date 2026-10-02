# Prompt: owner-only admin panel (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. Build me a **professional, owner-only admin panel** that lets me test
every mechanic in my game on **any player in the server**, plus trolling and moderation tools. It should look and feel
like a polished, modern admin panel (clean, fast, organised), not a debug menu.

## 0. Before you build anything
1. **Find every mechanic first.** Read the whole place before designing anything, and make a list of every system and
   what can be tested in each. The ones I know about:
   - **Data and economy:** `DataService`, `DataLoader`, `DataReplication`, `Leaderstats` (coins are `data.Coins` and
     `leaderstats.Coins`), `Shop`/`ShopService`, `SellBoxes`, `BoxStealing`, `BoxBuyers`
   - **Cats:** `CatCatalog`, `CatShopRoster`, `CatXP`/`WorkXP`, `PetCats`, `CatRenaming`, `WorkerService`, `HatService`,
     `Cosmetics` (crates and hats: `CosmeticCatalog`)
   - **Factory:** `TreatCatalog`/`TreatInventory`, `Workstations`, `BoxService` (boxes, shelves, carrying),
     `FactoryClaiming`, `BuildMode` (furniture), `ManagerDesk`/`ManagerUpgrades`, `FactoryCleanup`/`FactoryRepairService`,
     `CartService`/`CartNav`
   - **Vehicles:** `BicycleService`, `WagonService`, `VehicleUpgrades` (paints, speed, capacity), plus any newer vehicles
     in the place (caddy, pickup, delivery truck)
   - **Other:** NPC dialogue (`NPCMeetings`/Jerren intro), the tutorial, teleports, music, and anything added recently,
     such as dog raids and the bat
2. **Reuse what exists.** `ServerScriptService.Modules.DevCommands` already has `GiveCoins`, `GiveTreat`,
   `GiveFurniture`, `GiveCat`, `GiveBox`, `SellBoxes`, `SetBoxValue`, `SetCarryLimit`, `SetGoldenChance`,
   `RestockShop`, `SetStock`, `SetTimerSpeed`, `SetMixTime` and `SetRestTime`.
   - Call these and the real game services directly, so the panel exercises the **real code paths**. Never write
     duplicate logic that could drift from the game, and never edit saved data in ways the game itself wouldn't.
   - Every change must save properly and replicate to the player's UI, just like a normal purchase or reward.
3. **Use Fragment for inspiration only.** `ServerScriptService.FragmentSetup` (FRAGMENTv2, including its
   "Players++ [Client Trolling]" extensions) is the admin I use now. Study its command list and how it does things like
   fling, freeze, fly, teleports and kicks, then build those ideas into the new panel properly. **Don't copy its code
   wholesale**, and don't depend on it.
4. **Plan first.** Show me a short plan with the module structure and the full command list grouped by tab before you
   build.

## 1. Security (most important)
- **Access:** only **my UserId** (put it in an `AdminConfig` module as `Owners = { <my UserId> }`; ask me for it).
  Also allow `game.CreatorId` if the game is owned by my account. Nobody else can see, open or use the panel.
- **The UI isn't in StarterGui.** It lives in `ServerStorage`, and the server clones it into the owner's PlayerGui
  only after checking their UserId. Other players never receive it, so they can't decompile or inspect it.
- **Every action runs on the server:**
  - One `RemoteFunction` in a folder only created for the owner, or a single remote that rejects non-owners.
  - The server re-checks the caller's UserId on **every** request.
  - It validates every argument: player still in the server, numbers within sane limits, item IDs exist in the
    catalogs.
  - It rate-limits requests.
  - It never trusts the client.
- **Logging:** every command is logged (who, what, target, arguments, time) to the Output and to an in-panel Logs tab.
  Moderation actions (bans) are also saved to a DataStore.
- **Studio vs live:** the panel works in Studio Play tests and in live servers. Studio-only test helpers are clearly
  marked.

## 2. Panel layout and UX
- **Opening and moving:** toggle with a keybind (default `F2`, configurable) and a small button only I can see. It
  opens with a smooth animation, can be dragged, and works on mobile, PC and console (sized with Scale and
  UIAspectRatioConstraint).
- **Player picker (always visible on the left):**
  - a list of everyone in the server with avatar headshot, display name, @username and account age
  - a search box
  - multi-select, plus **"Me"**, **"All"** and **"Others"** shortcuts
  - every command runs on the selected player(s)
  - when a player leaves, they're removed from the list and the selection
- **Tabs:** Economy · Cats · Factory · Vehicles · Cosmetics · World/Teleport · Events · Player · Troll ·
  Moderation · Server · Logs.
- **Controls:**
  - dropdowns filled straight from the game's catalog modules (cats, rarities, treats, furniture, hats, crates,
    vehicles, paints, locations), so new content shows up automatically
  - number inputs with +/- steppers and presets
  - toggles for on/off effects
- **Feedback:** every action shows a toast: success (green) or the exact error (red). Dangerous actions (ban,
  shutdown, wipe data) need a confirmation dialog.
- **Live player info:** a small panel showing the selected player's coins, cats, boxes, vehicle levels, factory and
  position, refreshed every second or so.
- **Favourites:** I can star commands to pin them to a "Quick" bar at the top.

## 3. Commands (cover everything; add any mechanic I've missed)

**Economy**
- Give, take or set coins.
- Give boxes (choose value and count).
- Set box value, sell all boxes, set carry limit, set golden chance.
- Restock shops, set item stock.

**Cats**
- Give a cat: pick type, rarity, name and level from `CatCatalog`.
- Remove a cat, set a cat's level/XP, rename it.
- Max out every cat, give one of every cat type.
- Make cats work faster, set mix and rest times for a worker.
- Spawn a cat for petting tests.

**Factory**
- Give treats (any from `TreatCatalog`, with amount) and furniture.
- Claim or unclaim a factory for a player.
- Fill shelves with boxes, finish all workstations instantly.
- Make the factory dirty or broken (to test cleanup and repair), then repair or clean it.
- Upgrade the manager desk.
- Reset the factory layout (with confirmation).

**Vehicles**
- Give or unlock each vehicle (bike, wagon, caddy, pickup, truck, whatever exists).
- Set speed, basket and wagon capacity levels.
- Set paint.
- Give or remove upgrades like nitro.
- Spawn the vehicle next to the player.
- Despawn all vehicles.

**Cosmetics**
- Give crates (any type and amount), give a specific hat, give all hats.
- Open a crate with a forced result, to test every rarity's reveal effect.
- Clear cosmetics.

**World and teleport**
- Teleport the player to any location, filled automatically from the map: each tycoon, the shops (adoption centre,
  bakery, car dealership, furniture store, treat shop), NPCs and spawn.
- Teleport them to me, me to them, or bring all players.
- Save and load custom teleport points.
- Set time of day.

**Events**
- Start a dog raid on the selected player's factory now, with a choice of coat.
- Force the dog to target a specific box, end all raids.
- Toggle dog spawning on or off for the server.
- Speed up spawn timers (test mode).
- Trigger any other timed or random events the game has.

**Player**
- Fly, noclip, speed, jump power, god mode.
- Heal, respawn, reset character.
- Invisible, freeze/unfreeze.
- Give tools (bat, treat tools).
- View the player's camera (spectate).
- Replay the tutorial or the Jerren intro.
- Reset NPC "met" flags.

**Troll** (harmless and reversible; never touches saved data or progress)
- Fling, spin, launch into the sky, tiny/giant size.
- Ragdoll, slippery floor, upside-down camera.
- Make a dog chase them.
- Fake "you got a Legendary!" crate popup, confetti explosion.
- Turn them into a cat.
- Rainbow character, swap their walk with a silly animation.
- Play a sound for only them.
- Every troll has an "undo" and expires automatically after a set time.

**Moderation**
- Kick with a reason.
- **Ban** (temporary or permanent, with a reason) using `Players:BanAsync`, with `UnbanAsync` support, and a ban list
  in the panel.
- Mute and unmute chat (TextChatService).
- Warn (a big on-screen message).
- View a player's join time and account age.
- Server-wide announcement (a banner on everyone's screen).

**Server**
- Lock or unlock the server, shut down the server (with confirmation).
- Show server info: uptime, player count, memory, FPS, script errors.
- Toggle test mode, which speeds up every timer (workstations, dog raids, restocks) for quick testing.

**Data** (careful, everything confirmed)
- View a player's saved data as a readable tree.
- Reset a single field.
- Wipe a player's data (double confirmation).
- Give "start-of-game" or "end-game" preset profiles to test early and late game quickly.

## 4. Code structure
- `ServerScriptService.Admin.AdminService`: the auth check, the remote, validation, rate limiting and logging.
- `ServerScriptService.Admin.Commands/<Tab>.luau`: one module per tab. Each command is an entry with:
  - name, tab, description
  - argument schema (type, options source, min/max)
  - `run(caller, targets, args)`
  
  The **UI is generated from these definitions**, so adding a command means adding one table entry.
- `ServerStorage.AdminPanelGui` + a client controller module that's handed only to the owner.
- `ReplicatedStorage` holds nothing about the admin system, except what the owner's client actually receives.

## 5. After the new panel works: remove Fragment
Before deleting anything:
- Confirm that every Fragment feature I use is now in the new panel, with a checklist.
- Back up Fragment by moving it to `ServerStorage.FragmentBackup` with everything disabled.
- Make sure no other script references it.

Then **delete Fragment completely**, including its remotes, GUIs and anything it created in ReplicatedStorage,
StarterGui or StarterPlayer, and any loader script. Tell me exactly what you removed. Only delete the backup once I
say so.

## 6. Test before you tell me it's done
1. Start Server with 2 test players. The non-owner can't see the panel. Firing the remote from that player (try it
   from their client in the command bar) is rejected and logged.
2. Run **every** command at least once on myself and on the other player. Check that the effect happens, the data
   saves (rejoin to confirm) and the UI updates.
3. Multi-select and "All" work. A player leaving mid-command doesn't error.
4. Trolls undo cleanly. Ban, unban and kick work (test the ban on an alt or a Studio test player).
5. Dog raid, crate and vehicle commands trigger the real systems, with their real effects.
6. Check the layout on phone and PC in the Device Emulator.
7. No errors or warnings in the output.

When it's done, give me:
- the full command list
- the keybind
- how to add my alt or another admin later
- the Fragment removal checklist
