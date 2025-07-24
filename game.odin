package main

import "core:fmt"
import "core:math"
import m "core:math/noise"
import "core:math/rand"
import rl "vendor:raylib"

TILE_SIZE :: 16
MAX_TILES_WITDH :: 8400
MAX_TILES_HEIGHT :: 2400


TileType :: enum {
	air,
	dirt,
	grass,
	stone,
	plant,
}

Tile :: struct {
	pos:       rl.Vector2,
	type:      TileType,
	is_active: bool,
}

tiles: [MAX_TILES_WITDH][MAX_TILES_HEIGHT]Tile

generate_chunk :: proc(width, height: int) {
	using rl
	if len(tiles) > 0 {
		tiles = {}
	}


	for x in 0 ..< width {
		surface_height := ((300 + i32(rand.float32() * 32)) / TILE_SIZE * TILE_SIZE)
		for y in 0 ..< height {
			target_x := x * TILE_SIZE
			target_y := y * TILE_SIZE
			world_y := y * TILE_SIZE

			tile: Tile
			tile.is_active = true
			tile.pos = {f32(target_x), f32(target_y)}


			if i32(world_y) == surface_height {
				tile.type = .grass
			} else if i32(world_y) > surface_height && i32(world_y) < surface_height + 48 {
				tile.type = .dirt
			} else if i32(world_y) >= surface_height + 2 {
				tile.type = .stone
			} else {
				tile.type = .air
			}

			tiles[x][y] = tile
		}
	}

}

calculate_cam_bounds :: proc(cam: rl.Camera2D) -> (cam_bounding_box: rl.Rectangle) {
	half_w := 800 / 2
	half_h := 600 / 2

	min_x := clamp((i32(cam.target.x) - i32(half_w)) / TILE_SIZE, 0, 600 - 1)
	max_x := clamp(i32(cam.target.x) + i32(half_w) / TILE_SIZE, 0, 600 - 1)
	min_y := clamp((i32(cam.target.y) - i32(half_h)) / TILE_SIZE, 0, 600 - 1)
	max_y := clamp((i32(cam.target.y) + i32(half_h)) / TILE_SIZE, 0, 600 - 1)

	rec: rl.Rectangle = {
		x      = f32(min_x),
		y      = f32(min_y),
		width  = f32(max_x),
		height = f32(max_y),
	}

	return rec
}

main :: proc() {
	using rl


	cam: Camera2D = {
		target   = {400, 300},
		offset   = {400, 300},
		rotation = 0,
		zoom     = 2.0,
	}

	InitWindow(1920, 1080, "Noise Test")

	SetTargetFPS(60)
	atlas := LoadTexture("atlas.png")

	for !WindowShouldClose() {
		if IsKeyPressed(.F5) {
			generate_chunk(MAX_TILES_WITDH, MAX_TILES_HEIGHT)
		}

		if IsKeyDown(.A) {
			cam.target.x -= 10
		}

		if IsKeyDown(.D) {
			cam.target.x += 10
		}

		if IsKeyDown(.W) {
			cam.target.y -= 10
		}

		if IsKeyDown(.S) {
			cam.target.y += 10
		}


		BeginDrawing()
		ClearBackground(BLUE)
		DrawFPS(0, 0)
		BeginMode2D(cam)

		cam_bounds := calculate_cam_bounds(cam)

		DrawRectangleRec(cam_bounds, RED)
		for y := cam_bounds.y; y <= cam_bounds.height; y += 1 {
			for x := cam_bounds.x; x <= cam_bounds.width; x += 1 {
				tile := tiles[i32(x)][i32(y)]
				if tile.type == .air || !tile.is_active {
					continue
				}

				src := rl.Rectangle{}
				switch tile.type {
				case .air:
				case .grass:
					src = {0, 0, TILE_SIZE, TILE_SIZE}
				case .dirt:
					src = {TILE_SIZE, 0, TILE_SIZE, TILE_SIZE}
				case .stone:
					src = {TILE_SIZE * 2, 0, TILE_SIZE, TILE_SIZE}
				case .plant:
					src = {0, TILE_SIZE, TILE_SIZE, TILE_SIZE}
				}
				DrawTextureRec(atlas, src, tile.pos, rl.WHITE)
			}
		}
		EndMode2D()

		// DrawTextureV(texture, {0, 0}, WHITE)
		EndDrawing()
	}
}
