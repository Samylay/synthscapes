## Builds Kaï's apartment backdrop (Level 1 cutscene).
## 40×22 tiles at 16×16 px = 640×360 viewport (top-down ortho).
## Atlas: pixel-cyberpunk-interior.png (42×22 grid, 16×16 px each).
@tool
class_name ApartmentBuilder
extends RefCounted

const FLOOR     := 0
const WALL_N    := 1
const WALL_S    := 2
const WALL_E    := 3
const WALL_W    := 4
const CORNER_NW := 5
const CORNER_NE := 6
const CORNER_SE := 7
const CORNER_SW := 8
const WINDOW    := 9
const BLOCK     := 10
const FENCE     := 11

const TILE_ATLAS := {
	FLOOR:     Vector2i(0, 4),
	WALL_N:    Vector2i(1, 0),
	WALL_S:    Vector2i(1, 2),
	WALL_E:    Vector2i(1, 1),
	WALL_W:    Vector2i(2, 1),
	CORNER_NW: Vector2i(0, 0),
	CORNER_NE: Vector2i(3, 0),
	CORNER_SE: Vector2i(3, 3),
	CORNER_SW: Vector2i(0, 3),
	WINDOW:    Vector2i(3, 2),
	BLOCK:     Vector2i(2, 2),
	FENCE:     Vector2i(3, 1),
}

# Apartment room: 40 cols × 22 rows.
# Doorway (broken by Scrubbers) on left wall, rows 10-12.
# Neon-backlit windows on north wall at cols 8-10 and 25-27.
# Vent ducts (fence tiles) on south wall at cols 5-7 and 32-34.
# Immersion chair + terminal are Sprite2D nodes in the scene (not tilemap tiles).

const COLS := 40
const ROWS := 22

# Left-wall doorway rows (Scrubbers break through here)
const DOOR_ROWS  := [10, 11, 12]
# Window cols on north wall
const WIN_COLS   := [8, 9, 10, 25, 26, 27]
# Vent / aeration duct tiles on south interior wall
const VENT_CELLS := [
	Vector2i(5, 20), Vector2i(6, 20), Vector2i(7, 20),
	Vector2i(32, 20), Vector2i(33, 20), Vector2i(34, 20),
]
# Storage crates scattered across room
const CRATE_CELLS := [
	Vector2i(3, 5), Vector2i(4, 5),
	Vector2i(3, 6), Vector2i(4, 6),
	Vector2i(36, 14), Vector2i(37, 14),
	Vector2i(36, 15), Vector2i(37, 15),
	Vector2i(10, 17), Vector2i(11, 17),
	Vector2i(24, 3), Vector2i(25, 3),
]


static func build(ground: TileMapLayer, walls: TileMapLayer) -> void:
	ground.clear()
	walls.clear()

	# --- Ground layer: fill interior with floor ---
	for row in range(1, ROWS - 1):
		for col in range(1, COLS - 1):
			ground.set_cell(Vector2i(col, row), 0, TILE_ATLAS[FLOOR])

	# --- Walls layer ---

	# Corners
	walls.set_cell(Vector2i(0, 0),          0, TILE_ATLAS[CORNER_NW])
	walls.set_cell(Vector2i(COLS - 1, 0),   0, TILE_ATLAS[CORNER_NE])
	walls.set_cell(Vector2i(0, ROWS - 1),   0, TILE_ATLAS[CORNER_SW])
	walls.set_cell(Vector2i(COLS-1, ROWS-1),0, TILE_ATLAS[CORNER_SE])

	# North wall (top): windows at WIN_COLS, walls elsewhere
	for col in range(1, COLS - 1):
		var t := WINDOW if col in WIN_COLS else WALL_N
		walls.set_cell(Vector2i(col, 0), 0, TILE_ATLAS[t])

	# South wall (bottom)
	for col in range(1, COLS - 1):
		walls.set_cell(Vector2i(col, ROWS - 1), 0, TILE_ATLAS[WALL_S])

	# West wall (left): doorway gap at DOOR_ROWS
	for row in range(1, ROWS - 1):
		if row not in DOOR_ROWS:
			walls.set_cell(Vector2i(0, row), 0, TILE_ATLAS[WALL_E])

	# East wall (right)
	for row in range(1, ROWS - 1):
		walls.set_cell(Vector2i(COLS - 1, row), 0, TILE_ATLAS[WALL_W])

	# Vent ducts (FENCE = grated look)
	for cell in VENT_CELLS:
		walls.set_cell(cell, 0, TILE_ATLAS[FENCE])

	# Storage crates
	for cell in CRATE_CELLS:
		walls.set_cell(cell, 0, TILE_ATLAS[BLOCK])
