package hex_grid
import "core:fmt"

complain :: proc(name: string) {
	fmt.printf("FAIL {0}", name)
}

equal_hex :: proc(name: string, a, b: Hex) {
	if !(a.q == b.q && a.s == b.s && a.r == b.r) {
		complain(name)
	}
}


equal_offsetcoord :: proc(name: string, a, b: OffsetCoord) {
	if !(a.col == b.col && a.row == b.row) {
		complain(name)
	}

}
equal_doubledcoord :: proc(name: string, a, b: DoubledCoord) {
	if !(a.col == b.col && a.row == b.row) {
		complain(name)
	}
}

equal_int :: proc(name: string, a, b: int) {
	if !(a == b) {
		complain(name)
	}
}

equal_hex_array :: proc(name: string, a, b: [dynamic]Hex) {
	equal_int(name, len(a), len(b))
	for i in 0 ..< len(a) {
		equal_hex(name, a[i], b[i])
	}
}

test_hex_arithmetic :: proc() {
	equal_hex(
		"Hex_add",
		Hex_init(4, -10, 6),
		Hex_add(Hex_init(1, -3, 2), Hex_init(3, -7, 4)),
	)
	equal_hex(
		"hex_subtract",
		Hex_init(-2, 4, -2),
		Hex_subtract(Hex_init(1, -3, 2), Hex_init(3, -7, 4)),
	)
	fmt.printf("{0} test passed!\n", #procedure)
}

test_hex_direction :: proc() {
	equal_hex("hex_direction", Hex_init(0, -1, 1), Hex_direction(2))
	fmt.printf("{0} test passed!\n", #procedure)
}

test_hex_neighbor :: proc() {
	equal_hex(
		"hex_neighbor",
		Hex_init(1, -3, 2),
		Hex_neighbor(Hex_init(1, -2, 1), 2),
	)
	fmt.printf("{0} test passed!\n", #procedure)
}

test_hex_diagonal :: proc() {
	equal_hex(
		"hex_diagonal",
		Hex_init(-1, -1, 2),
		Hex_diagonal_neighbor(Hex_init(1, -2, 1), 3),
	)
	fmt.printf("{0} test passed!\n", #procedure)
}

test_hex_distance :: proc() {
	equal_int(
		"hex_distance",
		7,
		Hex_distance(Hex_init(3, -7, 4), Hex_init(0, 0, 0)),
	)
	fmt.printf("{0} test passed!\n", #procedure)
}

test_hex_rotate_right :: proc() {
	equal_hex(
		"hex_rotate_right",
		Hex_rotate_right(Hex_init(1, -3, 2)),
		Hex_init(3, -2, -1),
	)
	fmt.printf("{0} test passed!\n", #procedure)
}

test_hex_rotate_left :: proc() {
	equal_hex(
		"hex_rotate_left",
		Hex_rotate_left(Hex_init(1, -3, 2)),
		Hex_init(-2, -1, 3),
	)
	fmt.printf("{0} test passed!\n", #procedure)
}

test_hex_round :: proc() {
	a := FractionalHex_init(0.0, 0.0, 0.0)
	b := FractionalHex_init(1.0, -1.0, 0.0)
	c := FractionalHex_init(0.0, -1.0, 1.0)
	equal_hex(
		"hex_round 1",
		Hex_init(5, -10, 5),
		Hex_round(
			Hex_lerp(
				FractionalHex_init(0.0, 0.0, 0.0),
				FractionalHex_init(10.0, -20.0, 10.0),
				0.5,
			),
		),
	)
	equal_hex("hex_round 2", Hex_round(a), Hex_round(Hex_lerp(a, b, 0.499)))
	equal_hex("hex_round 3", Hex_round(b), Hex_round(Hex_lerp(a, b, 0.501)))
	equal_hex(
		"hex_round 4",
		Hex_round(a),
		Hex_round(
			FractionalHex_init(
				a.q * 0.4 + b.q * 0.3 + c.q * 0.3,
				a.r * 0.4 + b.r * 0.3 + c.r * 0.3,
				a.s * 0.4 + b.s * 0.3 + c.s * 0.3,
			),
		),
	)
	equal_hex(
		"hex_round 5\n\n",
		Hex_round(c),
		Hex_round(
			FractionalHex_init(
				a.q * 0.3 + b.q * 0.3 + c.q * 0.4,
				a.r * 0.3 + b.r * 0.3 + c.r * 0.4,
				a.s * 0.3 + b.s * 0.3 + c.s * 0.4,
			),
		),
	)
	fmt.printf("{0} test passed!\n", #procedure)
}

test_hex_linedraw :: proc() {
	equal_hex_array("hex_linedraw", [dynamic]Hex{Hex_init(0, 0, 0), Hex_init(0, -1, 1), Hex_init(0, -2, 2), Hex_init(1, -3, 2), Hex_init(1, -4, 3), Hex_init(1, -5, 4)}, Hex_linedraw(Hex_init(0, 0, 0), Hex_init(1, -5, 4)))
	fmt.printf("{0} test passed!\n", #procedure)
}

test_layout :: proc() {
	h := Hex_init(3, 4, -7)
	flat := Layout{layout_flat, Point{10.0, 15.0}, Point{35.0, 71.0}}
	equal_hex(
		"layout",
		h,
		Hex_round(pixel_to_hex(flat, Hex_to_pixel(flat, h))),
	)
	pointy := Layout{layout_pointy, Point{10.0, 15.0}, Point{35.0, 71.0}}
	equal_hex(
		"layout",
		h,
		Hex_round(pixel_to_hex(pointy, Hex_to_pixel(pointy, h))),
	)
}

test_offset_roundtrip :: proc() {
	a := Hex_init(3, 4, -7)
	b := OffsetCoord{1, -3}
	offset, offset_err := qoffset_from_cube(EVEN, a)
	if offset_err != GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	cube, cube_err := qoffset_to_cube(EVEN, offset)
	if cube_err != GRID_NO_ERROR {
		complain("Convert to cube")
	}
	equal_hex("conversion_roundtrip even-q 1",
		a,
		cube,
	)

	cube, cube_err = qoffset_to_cube(EVEN, b)
	if cube_err != GRID_NO_ERROR {
		complain("Convert to cube")
	}
	offset, offset_err = qoffset_from_cube(EVEN, cube)
	if offset_err != GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	equal_offsetcoord(
		"conversion_roundtrip even-q 2\n\n",
		b,
		offset,
	)

	offset, offset_err = qoffset_from_cube(ODD, a)
	if offset_err != GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	cube, cube_err = qoffset_to_cube(ODD, offset)
	if cube_err != GRID_NO_ERROR {
		complain("Convert to cube")
	}
	equal_hex("conversion_roundtrip even-q 3",
		a,
		cube,
	)

	cube, cube_err = qoffset_to_cube(ODD, b)
	if cube_err != GRID_NO_ERROR {
		complain("Convert to cube")
	}
	offset, offset_err = qoffset_from_cube(ODD, cube)
	if offset_err != GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	equal_offsetcoord(
		"conversion_roundtrip even-q 4",
		b,
		offset,
	)
	//

	offset, offset_err = roffset_from_cube(EVEN, a)
	if offset_err != GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	cube, cube_err = roffset_to_cube(EVEN, offset)
	if cube_err != GRID_NO_ERROR {
		complain("Convert to cube")
	}
	equal_hex("conversion_roundtrip even-q 5",
		a,
		cube,
	)

	cube, cube_err = roffset_to_cube(EVEN, b)
	if cube_err != GRID_NO_ERROR {
		complain("Convert to cube")
	}
	offset, offset_err = roffset_from_cube(EVEN, cube)
	if offset_err != GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	equal_offsetcoord(
		"conversion_roundtrip even-q 6",
		b,
		offset,
	)

	offset, offset_err = roffset_from_cube(ODD, a)
	if offset_err != GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	cube, cube_err = roffset_to_cube(ODD, offset)
	if cube_err != GRID_NO_ERROR {
		complain("Convert to cube")
	}
	equal_hex("conversion_roundtrip even-q 7",
		a,
		cube,
	)

	cube, cube_err = qoffset_to_cube(ODD, b)
	if cube_err != GRID_NO_ERROR {
		complain("Convert to cube")
	}
	offset, offset_err = qoffset_from_cube(ODD, cube)
	if offset_err != GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	equal_offsetcoord(
		"conversion_roundtrip even-q 8",
		b,
		offset,
	)


	// equal_hex(
	// 	"conversion_roundtrip even-q",
	// 	a,
	// 	qoffset_to_cube(EVEN, qoffset_from_cube(EVEN, a)),
	// )
	// equal_offsetcoord(
	// 	"conversion_roundtrip even-q",
	// 	b,
	// 	qoffset_from_cube(EVEN, qoffset_to_cube(EVEN, b)),
	// )
	// equal_hex(
	// 	"conversion_roundtrip odd-q",
	// 	a,
	// 	qoffset_to_cube(ODD, qoffset_from_cube(ODD, a)),
	// )
	// equal_offsetcoord(
	// 	"conversion_roundtrip odd-q",
	// 	b,
	// 	qoffset_from_cube(ODD, qoffset_to_cube(ODD, b)),
	// )
	// equal_hex(
	// 	"conversion_roundtrip even-r",
	// 	a,
	// 	roffset_to_cube(EVEN, roffset_from_cube(EVEN, a)),
	// )
	// equal_offsetcoord(
	// 	"conversion_roundtrip even-r",
	// 	b,
	// 	roffset_from_cube(EVEN, roffset_to_cube(EVEN, b)),
	// )
	// equal_hex(
	// 	"conversion_roundtrip odd-r",
	// 	a,
	// 	roffset_to_cube(ODD, roffset_from_cube(ODD, a)),
	// )
	// equal_offsetcoord(
	// 	"conversion_roundtrip odd-r",
	// 	b,
	// 	roffset_from_cube(ODD, roffset_to_cube(ODD, b)),
	// )
}

test_offset_from_cube :: proc() {
	offset, offset_err := qoffset_from_cube(EVEN, Hex_init(1, 2, -3))
	if offset_err != GRID_NO_ERROR {
		complain("test_offset_from_cube 1")
	}
	equal_offsetcoord(
		"offset_from_cube even-q",
		OffsetCoord{1, 3},
		offset,
	)

	offset, offset_err = qoffset_from_cube(ODD, Hex_init(1, 2, -3))
	if offset_err != GRID_NO_ERROR {
		complain("test_offset_from_cube 2")
	}
	equal_offsetcoord(
		"offset_from_cube odd-q",
		OffsetCoord{1, 2},
		offset,		
	)
}

test_offset_to_cube :: proc() {
	cube, cube_err := qoffset_to_cube(EVEN, OffsetCoord{1, 3})
	if cube_err != GRID_NO_ERROR {
		complain("offset_to_cube even")
	}
	equal_hex(
		"offset_to_cube even-",
		Hex_init(1, 2, -3),
		cube,
	)

	cube, cube_err = qoffset_to_cube(ODD, OffsetCoord{1, 2})
	if cube_err != GRID_NO_ERROR {
		complain("offset_to_cube odd")
	}
	equal_hex(
		"offset_to_cube odd-q",
		Hex_init(1, 2, -3),
		cube,
	)
}

test_doubled_roundtrip :: proc() {
	a := Hex_init(3, 4, -7)
	b := DoubledCoord{1, -3}
	equal_hex(
		"conversion_roundtrip doubled-q",
		a,
		qdoubled_to_cube(qdoubled_from_cube(a)),
	)
	equal_doubledcoord(
		"conversion_roundtrip doubled-q",
		b,
		qdoubled_from_cube(qdoubled_to_cube(b)),
	)
	equal_hex(
		"conversion_roundtrip doubled-r",
		a,
		rdoubled_to_cube(rdoubled_from_cube(a)),
	)
	equal_doubledcoord(
		"conversion_roundtrip doubled-r",
		b,
		rdoubled_from_cube(rdoubled_to_cube(b)),
	)
}
test_doubled_from_cube :: proc() {
	equal_doubledcoord(
		"doubled_from_cube doubled-q",
		DoubledCoord{1, 5},
		qdoubled_from_cube(Hex_init(1, 2, -3)),
	)
	equal_doubledcoord(
		"doubled_from_cube doubled-r",
		DoubledCoord{4, 2},
		rdoubled_from_cube(Hex_init(1, 2, -3)),
	)

}
test_doubled_to_cube :: proc() {
	equal_hex(
		"doubled_to_cube doubled-q",
		Hex_init(1, 2, -3),
		qdoubled_to_cube(DoubledCoord{1, 5}),
	)
	equal_hex(
		"doubled_to_cube doubled-r",
		Hex_init(1, 2, -3),
		rdoubled_to_cube(DoubledCoord{4, 2}),
	)
}
test_all :: proc() {
	test_hex_arithmetic()
	test_hex_direction()
	test_hex_neighbor()
	test_hex_diagonal()
	test_hex_distance()
	test_hex_rotate_right()
	test_hex_rotate_left()
	test_hex_round()
	test_hex_linedraw()
	test_layout()
	test_offset_roundtrip()
	test_offset_from_cube()
	test_offset_to_cube()
	test_doubled_roundtrip()
	test_doubled_from_cube()
	test_doubled_to_cube()
}


main :: proc() {
	// fmt.println("Hello")
	test_all()
}
