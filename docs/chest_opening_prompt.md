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

     Store these as an attribute (`HingeOffset`) on each Lid. Rotate the Lid around the hinge's X axis to about 105°
     to open it. Check the direction in a test.
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
