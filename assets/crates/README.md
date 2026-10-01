# Mystery crates

16 pixel-art "?" crates in the layout of the reference picture (top-left to bottom-right):
Lava, Galaxy, Ice, Toxic / Redstone, Rainbow, Emerald, Void / Wood, Stone, Gold, Glitch / Lime, Diamond, Amethyst, Celestial.

- `fbx/Crate_<Name>.fbx` - one crate per file, its texture built in. Import with **Home > Import 3D**.
- `textures/crate_<name>.png` - the 16 textures. **All crates share the exact same mesh**, so you can import one crate
  and switch its look by changing `TextureID` to any of the 16 textures.
- Each crate is a 2 x 2 x 2 stud cube, 252 triangles.
