package hex_grid

import "core:fmt"
import "core:log"
import "core:math"
import "core:mem"
import "core:runtime"
import rl "vendor:raylib"


point_to_vec :: proc(point: Point) -> rl.Vector2 {
	return rl.Vector2{f32(point.x), f32(point.y)}
}

Hex_get_color :: proc(hex: Hex) -> rl.Color {
	if hex.q == 0 && hex.r == 0 && hex.s == 0 {
		return rl.Color{0, 0, 0, 255}
	} else if hex.q == 0 {
		return rl.Color{9, 76, 170, 255}
	} else if hex.r == 0 {
		return rl.Color{0, 119, 179, 255}
	} else if hex.s == 0 {
		return rl.Color{179, 77, 178, 255}
	} else {
		return rl.Color{128, 128, 128, 255}
	}
}

Hex_draw :: proc(layout: Layout, hex: Hex, fill: rl.Color) {
	corners := polygon_corners(layout, hex)
	defer delete(corners)
	// thickness: f32 = 4
	// color := Hex_get_color(hex)
	prev := point_to_vec(corners[0])
	coords := Hex_to_pixel(layout, hex)
	coord_vec := point_to_vec(coords)
	rl.DrawPoly(
		coord_vec,
		6,
		f32(layout.size.x),
		f32(math.round(math.asin(layout.orientation.start_angle) * 57.2958)),
		// thickness,
		fill,
	)
}

Hex_draw_outline :: proc(
	layout: Layout,
	hex: Hex,
	color: rl.Color,
	thickness: f32,
) {
	corners := polygon_corners(layout, hex)
	defer delete(corners)
	prev := point_to_vec(corners[0])
	coords := Hex_to_pixel(layout, hex)
	coord_vec := point_to_vec(coords)
	rl.DrawPolyLinesEx(
		coord_vec,
		6,
		f32(layout.size.x),
		f32(math.round(math.asin(layout.orientation.start_angle) * 57.2958)),
		thickness,
		color,
	)
}

Hex_draw_label :: proc(layout: Layout, hex: Hex, color: rl.Color) {
	font_size := i32(
		math.round(
			0.4 * math.min(math.abs(layout.size.x), math.abs(layout.size.y)),
		),
	)
	default_font_size: i32 = 10
	center := Hex_to_pixel(layout, hex)
	label := fmt.ctprintf("{0}, {1}, {2}", hex.q, hex.r, hex.s)
	default_font := rl.GetFontDefault()
	spacing := font_size / default_font_size
	size := rl.MeasureTextEx(default_font, label, f32(font_size), f32(spacing))
	x_pos := i32(center.x) - (i32(size.x) / 2)
	y_pos := i32(center.y) - (i32(size.y) / 2)
	rl.DrawText(label, x_pos, y_pos, font_size, color)
}


Hex_draw_grid :: proc(layout: Layout, hexes: [dynamic]Hex) {
	for hex in hexes {
		color := Hex_get_color(hex)
		Hex_draw(layout, hex, color)
		Hex_draw_outline(layout, hex, rl.BLACK, 2)
		Hex_draw_label(layout, hex, rl.WHITE)
	}
}

Hex_draw_line :: proc(layout: Layout, hex_set: map[Hex]bool, a, b: Hex) {
	colinear_hexes := Hex_get_colinear_integer_hexes(a, b)
	defer delete(colinear_hexes)
	colinear_hex_fractions := Hex_get_colinear_fractional_hexes(a, b)
	defer delete(colinear_hex_fractions)
	a_center := Hex_to_pixel(layout, a)
	b_center := Hex_to_pixel(layout, b)

	rl.DrawLineEx(
		rl.Vector2{f32(a_center.x), f32(a_center.y)},
		rl.Vector2{f32(b_center.x), f32(b_center.y)},
		2,
		rl.BLUE,
	)
	coord: Point
	for hex_fraction in colinear_hex_fractions {
		coord = FractionalHex_to_pixel(layout, hex_fraction)
		rl.DrawCircle(i32(coord.x), i32(coord.y), 5, rl.DARKBLUE)
	}
	rl.DrawCircle(i32(a_center.x), i32(a_center.y), 10, rl.YELLOW)
	rl.DrawCircle(i32(b_center.x), i32(b_center.y), 10, rl.YELLOW)
}

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
	context.allocator = mem.tracking_allocator(&track)


	screenWidth: i32 = 800
	screenHeight: i32 = 450
	HEX_SIZE :: 50
	// LAYOUT_SIZE := Point{HEX_SIZE, HEX_SIZE}
	LAYOUT_SIZE := Point{50, 50}
	ORIGIN := Point{f64(screenWidth) / 2.0, f64(screenHeight) / 2.0}
	// ORIGIN := Point{100, 100}
	layout := Layout{FLAT_ORIENTATION, LAYOUT_SIZE, ORIGIN}
	// layout := Layout{POINTY_ORIENTATION, LAYOUT_SIZE, ORIGIN}
	hexes := make_parallelogram(-10, -10, 10, 10)
	hex_set := make_hex_map(hexes)
	a := Hex_init(0, 1, -1)
	b := Hex_init(8, -2, -6)


	rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.InitWindow(screenWidth, screenHeight, "raylib hex grid")


	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {
		// Update
		//----------------------------------------------------------------------------------

		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)
		Hex_draw_grid(layout, hexes)
		Hex_draw_line(layout, hex_set, a, b)

		rl.EndDrawing()
	}

	rl.CloseWindow()

	delete(hexes)
	delete(hex_set)
	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %m\n", leak.location, leak.size)
	}
	for bad_free in track.bad_free_array {
		fmt.printf(
			"%v allocation %p was freed badly\n",
			bad_free.location,
			bad_free.memory,
		)
	}
}
