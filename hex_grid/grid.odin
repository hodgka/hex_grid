package hex_grid
import "core:fmt"
import "core:math"
import "core:os"

GridErrno :: distinct int
GRID_NO_ERROR: GridErrno : 0
GRID_VALUE_ERROR: GridErrno : 1

EVEN :: 1
ODD :: -1

HEX_DIRECTIONS := [6]Hex {
	Hex_init(1, 0, -1),
	Hex_init(1, -1, 0),
	Hex_init(0, -1, 1),
	Hex_init(-1, 0, 1),
	Hex_init(-1, 1, 0),
	Hex_init(0, 1, -1),
}

HEX_DIAGONALS := [6]Hex {
	Hex_init(2, -1, -1),
	Hex_init(1, -2, 1),
	Hex_init(-1, -1, 2),
	Hex_init(-2, 1, 1),
	Hex_init(-1, 2, -1),
	Hex_init(1, 1, -2),
}

POINTY_ORIENTATION := Orientation {
	math.sqrt_f64(3.0),
	math.sqrt_f64(3.0) / 2.0,
	0.0,
	3.0 / 2.0,
	math.sqrt_f64(3.0) / 3.0,
	-1.0 / 3.0,
	0.0,
	2.0 / 3.0,
	0.5,
}

FLAT_ORIENTATION := Orientation {
	3.0 / 2.0,
	0.0,
	math.sqrt_f64(3.0) / 2.0,
	math.sqrt_f64(3.0),
	2.0 / 3.0,
	0.0,
	-1.0 / 3.0,
	math.sqrt_f64(3.0) / 3.0,
	0.0,
}

Point :: struct {
	x: f64,
	y: f64,
}

Hex :: struct {
	q: int,
	r: int,
	s: int,
}

FractionalHex :: struct {
	q: f64,
	r: f64,
	s: f64,
}

OffsetCoord :: struct {
	col: int,
	row: int,
}

DoubledCoord :: struct {
	col: int,
	row: int,
}

Orientation :: struct {
	f0:          f64,
	f1:          f64,
	f2:          f64,
	f3:          f64,
	b0:          f64,
	b1:          f64,
	b2:          f64,
	b3:          f64,
	start_angle: f64,
}

Layout :: struct {
	orientation: Orientation,
	size:        Point,
	origin:      Point,
}

Hex_init_cubic :: proc(q, r, s: int) -> Hex {
	fmt.assertf(
		q + r + s == 0,
		"Could not initialize Hex with values, q: {0}, r: {1}, s: {2}. q+r+s= {3} != 0",
		q,
		r,
		s,
		q + r + s,
	)
	// if !(q + r + s == 0) {
	// 	fmt.println("FAILED HEX SUM CHECK")
	// }
	return Hex{q, r, s}
}

Hex_init_axial :: proc(q, r: int) -> Hex {
	return Hex{q, r, -q - r}
}

Hex_init :: proc {
	Hex_init_cubic,
	Hex_init_axial,
}

FractionalHex_init_cubic :: proc(q, r, s: f64) -> FractionalHex {
	fmt.assertf(
		q + r + s <= 1e-06,
		"Could not initialize Fractional Hex with values, q: {0}, r: {1}, s: {2}. q+r+s= {3} != 0",
		q,
		r,
		s,
		q + r + s,
	)
	// if !(q + r + s <= 1e-06) {
	// 	fmt.println("FAILED FRACTIONAL HEX SUM CHECK")
	// }
	return FractionalHex{q, r, s}
}

FractionalHex_init_axial :: proc(q, r: f64) -> FractionalHex {
	return FractionalHex{q, r, -q - r}
}

FractionalHex_init :: proc {
	FractionalHex_init_cubic,
	FractionalHex_init_axial,
}


Hex_add :: proc(a, b: Hex) -> Hex {
	return Hex_init(a.q + b.q, a.r + b.r, a.s + b.s)
}

FractionHex_add :: proc(a, b: FractionalHex) -> FractionalHex {
	return FractionalHex_init(a.q + b.q, a.r + b.r, a.s + b.s)
}

Hex_subtract :: proc(a, b: Hex) -> Hex {
	return Hex_init(a.q - b.q, a.r - b.r, a.s - b.s)
}

Hex_scale :: proc(a: Hex, k: int) -> Hex {
	return Hex_init(a.q * k, a.r * k, a.s * k)
}

Hex_rotate_left :: proc(a: Hex) -> Hex {
	return Hex_init(-a.s, -a.q, -a.r)
}

Hex_rotate_right :: proc(a: Hex) -> Hex {
	return Hex_init(-a.r, -a.s, -a.q)
}

Hex_init_direction :: proc(direction: int) -> Hex {
	return HEX_DIRECTIONS[direction]
}

Hex_permute_QRS :: proc(h: Hex) -> Hex {
	return Hex_init(h.q, h.r, h.s)
}
Hex_permute_QSR :: proc(h: Hex) -> Hex {
	return Hex_init(h.q, h.s, h.r)
}
Hex_permute_SQR :: proc(h: Hex) -> Hex {
	return Hex_init(h.s, h.q, h.r)
}
Hex_permute_SRQ :: proc(h: Hex) -> Hex {
	return Hex_init(h.s, h.r, h.q)
}
Hex_permute_RQS :: proc(h: Hex) -> Hex {
	return Hex_init(h.r, h.q, h.s)
}
Hex_permute_RSQ :: proc(h: Hex) -> Hex {
	return Hex_init(h.r, h.s, h.q)
}

Hex_neighbor :: proc(hex: Hex, direction: int) -> Hex {
	return Hex_add(hex, Hex_init_direction(direction))
}

Hex_diagonal_neighbor :: proc(hex: Hex, direction: int) -> Hex {
	return Hex_add(hex, HEX_DIAGONALS[direction])
}

Hex_length :: proc(hex: Hex) -> int {
	return (math.abs(hex.q) + math.abs(hex.r) + math.abs(hex.s)) / 2
}

Hex_distance :: proc(a, b: Hex) -> int {
	return Hex_length(Hex_subtract(a, b))
}

Hex_round :: proc(h: FractionalHex) -> Hex {
	qi := int(math.round(h.q))
	ri := int(math.round(h.r))
	si := int(math.round(h.s))
	q_diff := math.abs(f64(qi) - h.q)
	r_diff := math.abs(f64(ri) - h.r)
	s_diff := math.abs(f64(si) - h.s)
	if q_diff > r_diff && q_diff > s_diff {
		qi = -ri - si
	} else {
		if r_diff > s_diff {
			ri = -qi - si
		} else {
			si = -qi - ri
		}
	}
	return Hex_init(qi, ri, si)
}

Hex_lerp :: proc(a, b: Hex, t: f64) -> FractionalHex {
	return FractionalHex_init(
		f64(a.q) * (1.0 - t) + f64(b.q) * t,
		f64(a.r) * (1.0 - t) + f64(b.r) * t,
		f64(a.s) * (1.0 - t) + f64(b.s) * t,
	)
}

FractionalHex_lerp :: proc(a, b: FractionalHex, t: f64) -> FractionalHex {
	return FractionalHex_init(
		a.q * (1.0 - t) + b.q * t,
		a.r * (1.0 - t) + b.r * t,
		a.s * (1.0 - t) + b.s * t,
	)
}

Hex_linedraw :: proc(a, b: Hex) -> [dynamic]Hex {
	N := Hex_distance(a, b)
	a_nudge := FractionalHex_init(
		f64(a.q) + 1e-06,
		f64(a.r) + 1e-06,
		f64(a.s) - 2e-06,
	)
	b_nudge := FractionalHex_init(
		f64(b.q) + 1e-06,
		f64(b.r) + 1e-06,
		f64(b.s) - 2e-06,
	)
	results := [dynamic]Hex{}
	step := 1.0 / f64(max(N, 1))
	for i in 0 ..< N + 1 {
		append(
			&results,
			Hex_round(FractionalHex_lerp(a_nudge, b_nudge, step * f64(i))),
		)
	}
	return results
}

qoffset_from_cube :: proc(
	offset: int,
	h: Hex,
) -> (
	offset_coord: OffsetCoord,
	err: GridErrno,
) {
	col := h.q
	row := h.r + int(h.q + offset * (h.q & 1)) / 2
	if offset != EVEN && offset != ODD {
		err = GRID_VALUE_ERROR
		return
		// return nil, GRID_VALUE_ERROR
	}
	offset_coord = OffsetCoord{col, row}
	err = GRID_NO_ERROR
	return
}

qoffset_to_cube :: proc(
	offset: int,
	h: OffsetCoord,
) -> (
	hex: Hex,
	err: GridErrno,
) {
	q := h.col
	r := h.row - (h.col + offset * (h.col & 1)) / 2
	s := -q - r
	if offset != EVEN && offset != ODD {
		err = GRID_VALUE_ERROR
		return
	}
	hex = Hex_init(q, r, s)
	err = GRID_NO_ERROR
	return
}

roffset_from_cube :: proc(
	offset: int,
	h: Hex,
) -> (
	offset_coord: OffsetCoord,
	err: GridErrno,
) {
	col := h.q + (h.r + offset * (h.r & 1)) / 2
	row := h.r
	if offset != EVEN && offset != ODD {
		err = GRID_VALUE_ERROR
		return
	}
	offset_coord = OffsetCoord{col, row}
	err = GRID_NO_ERROR
	return
}

roffset_to_cube :: proc(
	offset: int,
	h: OffsetCoord,
) -> (
	hex: Hex,
	err: GridErrno,
) {
	q := h.col - (h.row + offset * (h.row & 1)) / 2
	r := h.row
	s := -q - r
	if offset != EVEN && offset != ODD {
		err = GRID_VALUE_ERROR
		return
	}
	hex = Hex_init(q, r, s)
	err = GRID_NO_ERROR
	return
}


qdoubled_from_cube :: proc(h: Hex) -> DoubledCoord {
	col := h.q
	row := 2 * h.r + h.q
	return DoubledCoord{col, row}

}
qdoubled_to_cube :: proc(h: DoubledCoord) -> Hex {
	q := h.col
	r := (h.row - h.col) / 2
	s := -q - r
	return Hex_init(q, r, s)

}
rdoubled_from_cube :: proc(h: Hex) -> DoubledCoord {
	col := 2 * h.q + h.r
	row := h.r
	return DoubledCoord{col, row}

}
rdoubled_to_cube :: proc(h: DoubledCoord) -> Hex {
	q := (h.col - h.row) / 2
	r := h.row
	s := -q - r
	return Hex_init(q, r, s)
}

Hex_to_pixel :: proc(layout: Layout, h: Hex) -> Point {
	M := layout.orientation
	size := layout.size
	origin := layout.origin
	x := (M.f0 * f64(h.q) + M.f1 * f64(h.r)) * size.x
	y := (M.f2 * f64(h.q) + M.f3 * f64(h.r)) * size.y
	return Point{x + origin.x, y + origin.y}

}

FractionalHex_to_pixel :: proc(layout: Layout, h: FractionalHex) -> Point {
	M := layout.orientation
	size := layout.size
	origin := layout.origin
	x := (M.f0 * h.q + M.f1 * h.r) * size.x
	y := (M.f2 * h.q + M.f3 * h.r) * size.y
	return Point{x + origin.x, y + origin.y}

}

Hex_from_pixel :: proc(layout: Layout, p: Point) -> FractionalHex {
	M := layout.orientation
	size := layout.size
	origin := layout.origin
	pt := Point{(p.x - origin.x) / size.x, (p.y - origin.y) / size.y}
	q := M.b0 * pt.x + M.b1 * pt.y
	r := M.b2 * pt.x + M.b3 * pt.y
	return FractionalHex_init(q, r, -q - r)

}
Hex_corner_offset :: proc(layout: Layout, corner: int) -> Point {
	M := layout.orientation
	size := layout.size
	angle := 2.0 * math.PI * (M.start_angle - f64(corner)) / 6.0
	return Point{size.x * math.cos(angle), size.y * math.sin(angle)}

}
polygon_corners :: proc(layout: Layout, h: Hex) -> [dynamic]Point {
	corners: [dynamic]Point
	center := Hex_to_pixel(layout, h)
	for i in 0 ..< 6 {
		offset := Hex_corner_offset(layout, i)
		append(&corners, Point{center.x + offset.x, center.y + offset.y})
	}
	return corners
}

Hex_to_string :: proc(hex: Hex) -> string {
	return fmt.aprintf("{0},{1},{2}", hex.q, hex.r, hex.s)
}

FractionalHex_to_string :: proc(hex: FractionalHex) -> string {
	return fmt.aprintf("{0},{1},{2}", hex.q, hex.r, hex.s)
}
