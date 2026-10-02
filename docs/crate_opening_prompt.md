# Prompt: professional crate-opening experience (paste into Claude with Roblox Studio MCP)

You have MCP access to my Roblox Studio place. I want my cosmetic crate opening to look and feel like a
polished, front-page Roblox game. Rebuild it using the spec below. I will also send inspiration screenshots for the UI.
**Match their layout, colours and style wherever they conflict with the details here.** This spec covers the flow,
the scene, the timings and the effects.

## 0. Before you change anything

1. Read these scripts in the live place. They may have changed, so don't trust this summary blindly:
   - `StarterPlayer.StarterPlayerScripts.UI.CrateOpening` (LocalScript, the current opener with an `FX` table per rarity)
   - `ReplicatedStorage.Shared.InventoryCosmetics` (the inventory crate panel with the OpenCrate / Open3 / Open5 / OpenAll buttons)
   - `ReplicatedStorage.Shared.CosmeticCatalog` (`Catalog.Crates`, `Catalog.Hats`, `Catalog.odds(crateId)`, `Catalog.roll`)
   - `ReplicatedStorage.Shared.CatCatalog.Colors` (the rarity colours)
   - `ReplicatedStorage.Shared.CosmeticPreview` (puts a model in a ViewportFrame)
   - `ReplicatedStorage.Shared.Sfx`
   - `ServerScriptService.Cats.Cosmetics` (the server)
   - the `StarterGui.crate_opening` ScreenGui
2. **Keep the existing server API and hand-off exactly as they are.** Do not change server logic or what gets rolled:
   - The inventory fires the BindableEvent `PlayerGui.OpenCosmeticCrate` with `(entry {ID, Type}, inventoryScreenGui, count)`.
   - For one crate the client calls `remotes.functions.cosmetics:InvokeServer("open", crateId)`, which returns `{Winner, Crate, Count, Data}`.
   - For several it calls `InvokeServer("openMany", crateType, count)`, which returns `{Winners = {...}, Crate, Counts, Data}`. The cap is 20 (`MAX_OPEN_AT_ONCE`).
   - Either call can return `{Error = "..."}`.
   - The server decides the reward. The client only animates toward the result it was given.
3. Make a backup first: duplicate the current `CrateOpening` script and the `crate_opening` gui, append `_OLD` to their names
   and disable them. Put all the new code in clear, separate ModuleScripts (see section 8).

## 1. The flow (one crate)

`Open` clicked → fade out → **crate stage** (3D scene) → crate drops in → build-up shake and glow → crate bursts open →
**spinner UI** slides in → cards roll and slow down → land on the reward → **rarity reveal effect** → **result panel** with
`Open Again` and `Back to Inventory`.

Call the server **at the moment the player clicks**, in parallel with the intro animation. This hides the latency.
If the reply is an error, or hasn't arrived 6 seconds after the click, fade back to the inventory and show the error in its footer.

## 2. The scene (a 3D stage, not just UI)

Build a permanent model `Workspace.CrateStage` far from the map (for example at 0, 2000, 0) so it never appears in normal
play. Anchor everything and turn off CanCollide, CanQuery and CastShadow on the decoration. It contains:

- **Room:** a dark showroom about 40 × 24 × 40 studs.
  - Floor: dark polished concrete or metal (Material SmoothPlastic, Color 25, 25, 30, Reflectance 0.15).
  - Back wall: a dark panelled wall with a large, subtle game logo or a "CRATES" sign in neon trim.
  - Side walls: yellow/black hazard-stripe trusses and lighting rigs, like the inspiration image.
- **Pedestal:** a round, two-step turntable in the centre (about 8 studs wide), with a neon ring around its edge. The ring's
  colour changes to match the rarity during the reveal.
- **Lighting rig:** 3 or 4 overhead lamp fixtures aimed at the pedestal.
  - Each has a `SpotLight` (Angle 45, Brightness 4, Range 30, Shadows on).
  - Fake volumetric beams: a `Beam` (or a cone mesh) from the lamp to the floor. White, Transparency 0.85 → 1,
    LightEmission 1.
  - Dust motes: a ParticleEmitter on a big invisible part, Rate 6, tiny, slow and drifting.
- **Camera rig:** invisible anchored parts named `CamStart`, `CamCrate` and `CamWide`.
  - The camera tweens from `CamStart` (high and wide) to `CamCrate` (low, slightly below the crate's eye level, about 10 studs
    away, FieldOfView 50).
  - It drifts slowly the whole time (a small sine wobble on position, 0.15 studs).
- **Crate anchor:** an attachment or part named `CrateSpot` on top of the pedestal.

**While the stage is open (client only; restore everything when it closes):**
- `Camera.CameraType = Scriptable`.
- Hide every other ScreenGui and `StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)`.
- Freeze the character's controls.
- Add `ColorCorrection` (Contrast 0.1, Saturation 0.15), `Bloom` (Intensity 0.6, Size 30, Threshold 0.9) and a light
  `DepthOfField` that focuses on the crate and blurs the background.
- Restore every Lighting and camera property exactly as it was when the stage closes.

## 3. Crate intro animation (about 2.2 s; `Skip` jumps straight to the spinner)

Clone the crate's model from `ReplicatedStorage.cosmeticcrates[Type]`. Scale it so it fills about 40% of the screen height.
If the model has a `Glyph` part (the new HD crates do), use it for the glow.

| Time | Animation | Sound / FX |
|---|---|---|
| 0.00 | Fade from black (0.35 s). The camera starts moving CamStart → CamCrate (1.2 s, Quint Out). | soft "whoosh" |
| 0.25 | The crate drops from 15 studs above CrateSpot, lands with a squash (scale 1.15, 0.85, 1.15) and bounces back (Back Out). | heavy "thud" |
| 0.55 | Dust ring burst at the base. Small camera shake (0.3 s). | |
| 0.8–1.9 | Build-up. The crate wobbles harder and harder (rotation ±2° → ±10°, getting faster). The Glyph and pedestal ring pulse brighter. A whirl of sparks circles it. | rising "charge" tone |
| 1.9 | Pause for 0.15 s, then a white flash (full-screen Frame, 0 → 1 transparency over 0.4 s). The crate pops: the lid flies up and the sides fall outward. An easy way to do this is unanchoring cloned pieces and giving them impulses, or tweening the scale to 0 with spin. | "pop" / explosion |
| 2.0 | A burst of particles in the crate's theme colour (lava = embers, galaxy = stars, and so on). A light beam shoots upward. The spinner slides up from the bottom. | |

The pre-pop glow uses the **crate's** theme colour. If the result is **Epic or better**, add one extra "tease" pulse in the
**reward's** rarity colour right before the pop (as in CS:GO and Pet Simulator).

## 4. The spinner UI (match my inspiration images; the reference screenshot shows the style)

- **Layout:** a horizontal strip across the lower-middle of the screen, about 85% wide and 26% tall.
  - Dark translucent backing (black, 0.35 transparency) with a UIGradient fading the left and right edges to transparent.
  - A vertical **selector marker** in the centre: a white or gold triangle at the top and bottom, plus a thin glowing line.
- **Cards:** about 150 × 150 at 1080p. Use Scale sizing plus a `UIAspectRatioConstraint` so it works on mobile. Each card has:
  - a rarity name header strip at the top (font FredokaOne or Builder Sans Bold, rarity colour);
  - a background tinted with the rarity colour through a UIGradient (dark → colour);
  - a ViewportFrame of the hat through `CosmeticPreview`;
  - the item name at the bottom;
  - a UIStroke and UICorner of 8 px;
  - for Legendary and up, an animated shine: a diagonal white gradient sweeping across every 2 s.
- **Generating the strip:**
  - Build about 60 cards with weighted random rolls from `Catalog.odds(crateType)`. This is visual filler only.
  - Put the real winner at index 50.
  - Put one or two high-rarity "near miss" cards right next to the winner so it feels exciting.
- **Spin motion:**
  - Tween the strip's X position so the winner card stops under the marker, with a random offset of ±35% of a card width
    so it never looks perfectly centred.
  - Duration 5.5 s for one crate. Use a custom ease: fast start, long slow ending (Quint Out, or a manual
    `1 - (1 - t)^4` on RenderStepped).
  - Play a **tick** sound every time a card passes the marker. Raise the pitch slightly as it slows down.
  - In the last 0.4 s, settle the strip back by a few pixels so it "clicks" into place.
- **After it stops:** the winning card scales up to 1.15 and gets a glowing stroke. Every other card dims to 50%.

## 5. Reward effects by rarity (intensity scales up)

Use `CatCatalog.Colors` for every colour. Expand the existing `FX` table and keep each tier's values in one place so they're
easy to tune.

| Rarity | Screen effect | 3D stage effect | Sound | Banner |
|---|---|---|---|---|
| Common | small sparkle on the card | none | soft "ding" | none |
| Uncommon | sparkle + 1 colour ring pulse | pedestal ring goes green | "ding" up | none |
| Rare | 6 light rays behind the card, flash 0.2, shake 3 px | blue light burst, short particle fountain | chime | "RARE!" (small) |
| Epic | 10 spinning rays, flash 0.35, shake 6 px, confetti | purple beam into the sky, spotlights turn purple | big chime + whoosh | "EPIC!" slams in (scale 2 → 1, Back Out) |
| Legendary | 14 rays, gold flash 0.6, shake 12 px, gold confetti and stars, slow-mo (the spinner's last 0.5 s at half speed) | gold pillar of light, the spotlights sweep, the camera pushes in, falling gold coins | fanfare | "LEGENDARY!" with an animated gold gradient |
| Mythic | everything above + a pink chromatic flash, the screen edges pulse | the lights go dark for 0.3 s, then return in pink/rainbow; a shockwave ring along the floor | epic fanfare + bass drop | "MYTHIC!" with rainbow UIGradient cycling |
| Secret | blackout to 0.9, then a reveal with a glitch effect (offset RGB copies of the card), aqua lightning | stage lights flicker, aqua lightning Beams | distorted riser + boom | "SECRET!!" + a server-wide chat message (optional; ask me first) |

- **Screen shake:** offset the whole UI root and the camera CFrame. Make sure the shake decays.
- **Rays:** a large ImageLabel of light rays (find a good one in the Creator Store), rotating slowly behind the winning card.
- **Accessibility:** add a setting toggle "Reduce flashing" that caps the flash at 0.2 and disables shake.

## 6. Result panel (after the reveal, about 1 s)

A panel slides up from the bottom, containing:
- the won item: a large viewport, its name, a rarity tag, and "You own: x{Count}". Mark it **NEW!** if the count is 1.
- buttons:
  - **Open Again** (same amount). Show it disabled if the player doesn't have enough of that crate left (check the
    `Data` snapshot from the server reply).
  - **Open x1** and **Open All** shortcuts, if they have crates left.
  - **Back to Inventory**: fade out, restore the camera and gui, reopen the inventory on the same crate and refresh its
    count from `Data`.
- `Equip` (optional): a shortcut into the existing equip flow.

The keyboard and gamepad also work: Space/Enter = Open Again, Esc/B = Back. Clicking during the spin does nothing, but the
`Skip` button (bottom right, visible after 1 s) fast-forwards the whole sequence to the reveal.

## 7. Opening x3, x5 and All

The same stage and intro, with one pop. Show **one crate**, but stack small copies behind it showing the count ("x5").
Then:

- **x3 and x5:** **stack 3 or 5 spinner strips vertically**, each shorter (cards about 70% of the size).
  - All of them start together and stop **staggered** from top to bottom, 0.35 s apart, so each landing gets its own tick
    and flash.
  - Each strip's reveal plays a **reduced** version of its own rarity effect: card glow and a small burst only.
  - After the last strip stops, play the **full** stage effect once for the **best rarity** won.
- **All (up to 20; also use this when the count is over 5):** skip the strips and use a **card-flip grid**.
  - A grid of face-down cards deals in.
  - The cards flip one at a time, quickly (0.12 s apart), **sorted so the rarest flip last**.
  - Each flip glows in its rarity colour.
  - The best one ends with the full effect.
  - After that a summary appears: "You got: 9 Common, 6 Uncommon, 4 Rare, 1 Legendary", with the new items marked NEW!.
- In all these modes the result panel shows **every** item won as a scrollable row, plus the same buttons.
  "Open Again" repeats the same count.

## 8. Code structure and quality

- **Modules** (in ReplicatedStorage.Shared or StarterPlayerScripts):
  - `CrateStage`: entering and leaving the 3D scene, the camera, lighting and gui hiding, and the 3D effects.
  - `CrateIntro`: the drop, build-up and pop.
  - `CrateSpinner`: building the strips and the spin math.
  - `RewardFX`: the rarity effects table, plus the screen and stage effects.
  - `CrateResults`: the result panel.
  - The existing `CrateOpening` LocalScript stays the controller. It listens to `OpenCosmeticCrate`, calls the server and
    runs the phases in order.
- Every phase must be **cancellable** and clean up everything it made. Use a Trove/Maid-style cleanup list so the effects
  don't leak particles, connections or tweens.
- Only one opening runs at a time (a `busy` flag). Ignore double clicks.
- If the character dies, the player resets, or the server errors, close the stage cleanly and restore everything.
- **Preload** the crate model, every hat in that crate and every sound with `ContentProvider:PreloadAsync` when the
  inventory opens, so nothing pops in.
- **Performance:**
  - Animate the strip with one RenderStepped connection, not 60 tweens.
  - Reuse cards from a pool.
  - Limit particle counts on mobile (check `UserInputService.TouchEnabled`).
- **Sounds:**
  - Use real, free audio from the Creator Store (search for "ui tick", "whoosh", "fanfare" and so on). Make sure every
    sound is public or owned by me. **Never invent asset IDs.**
  - Put them all in `ReplicatedStorage.Shared.Sfx` (or a `CrateSounds` folder) so I can swap them later.
- Visual consistency: one font family, rarity colours only from `CatCatalog.Colors`, rounded corners, UIStroke outlines,
  and no default grey Roblox buttons.

## 9. Test before you say it's done

Playtest in Studio (Play Solo) and confirm each of these:
1. x1 opens. The reward matches what the server returned. The inventory count goes down by 1. "Open Again" works, and
   is disabled when none are left.
2. x3 and x5 show stacked spinners with staggered stops, and the best-rarity effect fires once.
3. "All" with 20 crates runs the flip grid and the summary is correct.
4. "Back to Inventory" fully restores the camera, the HUD, the CoreGui, Lighting and character control.
5. Skip works at every point in the sequence.
6. Spam-clicking can't start two openings.
7. Testing each rarity effect: temporarily force a result on the **client side only** (a debug flag), screenshot each
   tier and show me. Remove the debug flag afterwards.
8. Check the layout at phone size with the Device Emulator (iPhone and iPad) and at 1080p.
9. The output window has no errors or warnings.

Send me screenshots or a short description of each phase when you're done, plus a list of anything you couldn't do.
