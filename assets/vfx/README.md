# Wolf VFX pack

Custom effects for the wolf fights. They're stylised and bright, made to match the game.
`docs/wolf_vfx_assets_prompt.md` explains how to set up each file in Roblox and which pieces make up each wolf
ability. Paste that prompt into Studio Claude.

| Folder | What's inside |
|---|---|
| `meshes/` | 25 FBX effect meshes (rings, slashes, ice block, ice spikes, ice armour, star orbs, starburst, meteor, fireball, fire ring, claw slash, shadow tendrils, aura shell, coin, …) + `mesh_specs.json` (sizes in studs) + `wolf_vfx.blend` (source) |
| `particles/` | 17 particle textures (glow, spark, sparkle, star, snowflake, ice shard, ember, ring, impact, slash, leaf, fur, debris, paw print, rune circle, smoke wisp, sound waves) |
| `flipbooks/` | 9 animated 4×4 flipbooks (fire, smoke, explosion, magic burst, frost mist, impact, shadow smoke, energy, spinning coin) |
| `decals/` | ground decals: crack, frost crack line, frost patch, scorch, telegraph circle, telegraph bar |
| `screen/` | full-screen overlays: burning, frost, shadow, claw marks, speed lines, vignette |
| `trails/` | Trail/Beam textures: energy, fire, smoke, stars, beam core |
| `meshtex/` | textures for the meshes (ring, slash, pillar, fire, fire wall, ice, galaxy, energy, rock, coin) |
| `icons/` | health-bar emblems for the 6 wolf types |
| `previews/` | contact sheets of everything, plus 3 showcase renders (`showcase_frost/celestial/ember.png`) |

Particle textures are white so `ParticleEmitter.Color` can tint them. The fire, explosion, debris, leaf and coin
textures are already coloured. All images are 1024 px or smaller, within Roblox's upload limit.
