# Bat (shoo-the-dogs tool)

A wooden baseball bat with a maple handle, black spiral grip tape, a dark-cherry lacquered barrel, gold pinstripes and
a gold paw-print logo on both sides.

- `Bat.fbx`: the mesh, with its texture built in. 1,840 triangles.
- `bat_texture.png`: the texture, in case you want to re-upload or recolour it.
- `bat.blend`: the source file.
- Size: 3.6 studs long, 0.4 studs across the barrel. The length runs along the part's **Y** axis, with the knob at -Y.

## Making it a Tool
1. Import `Bat.fbx` (**Home → Import 3D**). Rename the MeshPart to `Handle`, set CanCollide off and Massless on.
2. Put it in a `Tool` (name it "Bat") in StarterPack, or wherever you hand out tools.
3. The middle of the grip tape is 1.2 studs below the part's centre, so set:
   ```lua
   Tool.Grip = CFrame.new(0, -1.2, 0)
   ```
   If the bat points the wrong way in the hand, keep the same position but add a rotation, such as
   `CFrame.new(0, -1.2, 0) * CFrame.Angles(math.rad(90), 0, 0)`, or line it up with a Tool Grip Editor plugin.
