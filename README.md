# SynthScapes

Minimal Unity foundation for an isometric 2D project.

## Current Base

The project now keeps only the systems needed for a clean starting point:

- explicit scene-owned foundation root
- player spawn and isometric movement
- imported animated player prefab driven by project code
- sprint input
- camera follow
- sprite Y-sorting
- imported isometric terrain and collision prefabs

Prototype-only systems were removed:

- interaction props
- event bus
- temporary game state
- runtime UI feedback
- audio manager and ambient/SFX hooks

## Runtime Scripts

- `Assets/Scripts/Core/FoundationRoot.cs`
- `Assets/Scripts/Player/PlayerController.cs`
- `Assets/Scripts/World/CameraFollow.cs`
- `Assets/Scripts/World/YSort.cs`

## Imported Reference Assets

Useful content from the reference is stored under `Assets/Imported/IsometricExample/`:

- animated player prefab and animator controller
- player sprites and directional animations
- isometric terrain sprites and tile assets
- collider visualization material

These assets are support content. The project architecture still lives in `Assets/Scripts/`.

## Controls

- move: `WASD` or arrow keys
- sprint: `Left Shift`
- gamepad move: left stick
- gamepad sprint: left stick press

## Recommended Build Order

Build the project back up in this order:

1. Replace the imported starter terrain with a custom level scene or custom tilemap layout.
2. Add a proper input wrapper if the `PlayerInput` pattern starts to feel limiting.
3. Introduce interaction as a focused system with one simple interactable type first.
4. Add a persistent game/session state only when an actual gameplay loop needs it.
5. Add UI only after interactions or objectives need visible feedback.
6. Add audio last for polish once movement and interaction loops are stable.

## Rule For New Features

Only add a system when at least one current gameplay need cannot be solved cleanly without it.
