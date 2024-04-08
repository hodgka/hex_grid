package hex_grid
import "core:math"

make_parallelogram_qrqr :: proc(q1, r1, q2, r2: int) -> (hexes: [dynamic]Hex) {
	for q := q1; q <= q2; q += 1 {
		for r := r1; r <= r2; r += 1 {
			append(&hexes, Hex_init(q, r, -q - r))
		}
	}
	return hexes
}


make_parallelogram_w_h :: proc(w, h: int) -> (hexes: [dynamic]Hex) {
	for r := 0; r < h; r += 1 {
		for q := 0; q < w; q += 1 {
			append(&hexes, Hex_init(q, r, -q - r))
		}
	}
	return hexes
}

make_parallelogram :: proc {
	make_parallelogram_qrqr,
	make_parallelogram_w_h,
}


make_triangle_down :: proc(size: int) -> (hexes: [dynamic]Hex) {
	for q := 0; q <= size; q += 1 {
		for r := 0; r <= size - q; r += 1 {
			append(&hexes, Hex_init(q, r, -q - r))
		}
	}
	return hexes
}


make_triangle_up :: proc(size: int) -> (hexes: [dynamic]Hex) {
	for q := 0; q <= size; q += 1 {
		for r := size - q; r <= size; r += 1 {
			append(&hexes, Hex_init(q, r, -q - r))
		}
	}
	return hexes
}


make_hexagon :: proc(size: int) -> (hexes: [dynamic]Hex) {
	for q := -size; q <= size; q += 1 {
		r1 := max(-size, -q - size)
		r2 := min(size, -q + size)
		for r := r1; r <= r2; r += 1 {
			append(&hexes, Hex_init(q, r, -q - r))
		}
	}
	return hexes
}


make_rectangle_pointy :: proc(
	left, top, right, bottom: int,
) -> (
	hexes: [dynamic]Hex,
) {
	for r := top; r <= bottom; r += 1 {
		r_offset := int(math.floor(f64(r / 2.0))) // or r>>1
		for q := left - r_offset; q <= right - r_offset; q += 1 {
			append(&hexes, Hex_init(q, r, -q - r))
		}
	}
	return hexes
}

make_rectangle_flat :: proc(
	left, top, right, bottom: int,
) -> (
	hexes: [dynamic]Hex,
) {
	for q := left; q <= right; q += 1 {
		q_offset := int(math.floor(f64(q / 2.0))) // or q>>1
		for r := top - q_offset; r <= bottom - q_offset; r += 1 {
			append(&hexes, Hex_init(q, r, -q - r))
		}
	}
	return hexes
}

make_rectangle_arbitrary :: proc(w, h: int) -> (hexes: [dynamic]Hex) {
	i1 := -int(math.floor(f64(w / 2)))
	i2 := i1 + w
	j1 := -int(math.floor(f64(h / 2)))
	j2 := j1 + h
	for j := j1; j < j2; j += 1 {
		jOffset := -int(math.floor(f64(j / 2)))
		for i := i1 + jOffset; i < i2 + jOffset; i += 1 {
			append(&hexes, Hex_init(i, j, -i - j))
		}
	}
	return hexes
}

make_ring :: proc(radius: int) -> (hexes: [dynamic]Hex) {
	h := Hex_scale(Hex_init_direction(4), radius)
	for side := 0; side < 6; side += 1 {
		for step := 0; step < radius; step += 1 {
			append(&hexes, h)
			h = Hex_neighbor(h, side)
		}
	}
	return hexes
}


make_hex_map :: proc(hexes: [dynamic]Hex) -> (hex_map: map[Hex]bool) {
	for hex in hexes {
		hex_map[hex] = true
	}

	return hex_map
}
