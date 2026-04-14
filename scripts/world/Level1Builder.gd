## Builds Level 1 (office + alley) by calling set_cell() at runtime.
## Top-down 2D orthogonal layout. Tile size: 16x16.
## Atlas: pixel-cyberpunk-interior.png (42x22 tiles at 16x16px)
##   Rows 0-3, cols 0-3: wall tiles (dark gray section, top-left of sheet)
##   Rows 4-7, cols 0-9: floor tiles (blue-gray section)
@tool
class_name Level1Builder
extends RefCounted

# Logical tile type constants
const FLOOR      := 0
const WALL_E     := 1
const WALL_S     := 2
const WALL_N     := 3
const WALL_W     := 4
const CORNER_NW  := 5
const CORNER_NE  := 6
const CORNER_SE  := 7
const CORNER_SW  := 8
const CRATE      := 9
const DOORWAY_E  := 10
const BLOCK      := 11
const STAIRS     := 12
const FENCE      := 13
const WINDOW     := 14
const DOORWAY_S  := 15

# Maps each logical tile constant to its (atlas_col, atlas_row) in the sheet.
# Wall grid (cols 0-3, rows 0-3): corners at the four edges, filled center.
# Floor: (0, 4) — any tile in the consistent blue-gray band.
const TILE_ATLAS := {
	FLOOR:     Vector2i(0, 4),  # floor
	WALL_E:    Vector2i(1, 1),  # solid wall fill
	WALL_S:    Vector2i(1, 2),  # solid wall fill (variant)
	WALL_N:    Vector2i(1, 0),  # top wall edge
	WALL_W:    Vector2i(2, 1),  # wall fill (variant)
	CORNER_NW: Vector2i(0, 0),  # top-left corner
	CORNER_NE: Vector2i(3, 0),  # top-right corner
	CORNER_SE: Vector2i(3, 3),  # bottom-right corner
	CORNER_SW: Vector2i(0, 3),  # bottom-left corner
	CRATE:     Vector2i(1, 1),  # reuse wall for now
	DOORWAY_E: Vector2i(0, 4),  # open gap (floor tile)
	BLOCK:     Vector2i(2, 2),  # solid block
	STAIRS:    Vector2i(2, 3),
	FENCE:     Vector2i(3, 1),
	WINDOW:    Vector2i(3, 2),
	DOORWAY_S: Vector2i(0, 4),  # open gap (floor tile)
}

# -1 = empty cell
const G := -1  # shorthand for "no tile"
const F :=  0  # floor shorthand

# Ground layer: office left (cols 1-11) + corridor (rows 5-8) + alley right (cols 14-18)
const GROUND_MAP := [
	#  0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19
	[ G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G],  # 0
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G,  G,  F,  F,  F,  F,  F,  G],  # 1
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G,  G,  F,  F,  F,  F,  F,  G],  # 2
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G,  G,  F,  F,  F,  F,  F,  G],  # 3
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G,  G,  F,  F,  F,  F,  F,  G],  # 4
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G],  # 5 corridor
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G],  # 6 corridor
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G],  # 7 corridor
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G],  # 8 corridor
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G,  G,  F,  F,  F,  F,  F,  G],  # 9
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G,  G,  F,  F,  F,  F,  F,  G],  # 10
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G,  G,  F,  F,  F,  F,  F,  G],  # 11
	[ G,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  F,  G,  G,  F,  F,  F,  F,  F,  G],  # 12
	[ G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G,  G],  # 13
]

# Walls layer: border walls + corridor walls
const WALLS_MAP := [
	#  0          1          2          3          4          5          6          7          8          9         10         11         12         13         14         15         16         17         18         19
	[  G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G],
	[  G, CORNER_NW,     WALL_N,     WALL_N,     WALL_N,     WALL_N,     WALL_N,     WALL_N,     WALL_N,     WALL_N,     WALL_N, CORNER_NE,          G,          G, CORNER_NW,     WALL_N,     WALL_N,     WALL_N, CORNER_NE,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G,          G,     WALL_E,          G,          G,          G,     WALL_S,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G,          G,     WALL_E,          G,          G,          G,     WALL_S,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G,          G,     WALL_E,          G,          G,          G,     WALL_S,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G,          G,     WALL_E,          G,          G,          G,     WALL_S,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G,          G,     WALL_E,          G,          G,          G,     WALL_S,          G],
	[  G,     WALL_E,          G,          G,          G,          G,          G,          G,          G,          G,          G,     WALL_S,          G,          G,     WALL_E,          G,          G,          G,     WALL_S,          G],
	[  G, CORNER_SW,     WALL_W,     WALL_W,     WALL_W,     WALL_W,     WALL_W,     WALL_W,     WALL_W,     WALL_W,     WALL_W, CORNER_SE,          G,          G, CORNER_SW,     WALL_W,     WALL_W,     WALL_W, CORNER_SE,          G],
	[  G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G,          G],
]


static func build(ground: TileMapLayer, walls: TileMapLayer) -> void:
	ground.clear()
	walls.clear()

	for row in GROUND_MAP.size():
		for col in GROUND_MAP[row].size():
			var t: int = GROUND_MAP[row][col]
			if t >= 0:
				ground.set_cell(Vector2i(col, row), 0, TILE_ATLAS[t])

	for row in WALLS_MAP.size():
		for col in WALLS_MAP[row].size():
			var t: int = WALLS_MAP[row][col]
			if t >= 0:
				walls.set_cell(Vector2i(col, row), 0, TILE_ATLAS[t])
