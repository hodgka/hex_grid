package hex_grid_tests
import hg "../hex_grid"
import "core:fmt"

complain :: proc(name: string) {
	fmt.printf("FAIL {0}", name)
}

equal_hex :: proc(name: string, a, b: hg.Hex) {
	if !(a.q == b.q && a.s == b.s && a.r == b.r) {
		complain(name)
	}
}


equal_offsetcoord :: proc(name: string, a, b: hg.OffsetCoord) {
	if !(a.col == b.col && a.row == b.row) {
		complain(name)
	}

}
equal_doubledcoord :: proc(name: string, a, b: hg.DoubledCoord) {
	if !(a.col == b.col && a.row == b.row) {
		complain(name)
	}
}

equal_int :: proc(name: string, a, b: int) {
	if !(a == b) {
		complain(name)
	}
}

equal_hex_array :: proc(name: string, a, b: [dynamic]hg.Hex) {
	equal_int(name, len(a), len(b))
	for i in 0 ..< len(a) {
		equal_hex(name, a[i], b[i])
	}
}

test_hex_arithmetic :: proc() -> int {
	equal_hex(
		"Hex_add",
		hg.Hex_init(4, -10, 6),
		hg.Hex_add(hg.Hex_init(1, -3, 2), hg.Hex_init(3, -7, 4)),
	)
	equal_hex(
		"hex_subtract",
		hg.Hex_init(-2, 4, -2),
		hg.Hex_subtract(hg.Hex_init(1, -3, 2), hg.Hex_init(3, -7, 4)),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_hex_direction :: proc() -> int {
	equal_hex("hex_direction", hg.Hex_init(0, -1, 1), hg.Hex_init_direction(2))
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_hex_neighbor :: proc() -> int {
	equal_hex(
		"hex_neighbor",
		hg.Hex_init(1, -3, 2),
		hg.Hex_neighbor(hg.Hex_init(1, -2, 1), 2),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_hex_diagonal :: proc() -> int {
	equal_hex(
		"hex_diagonal",
		hg.Hex_init(-1, -1, 2),
		hg.Hex_diagonal_neighbor(hg.Hex_init(1, -2, 1), 3),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_hex_distance :: proc() -> int {
	equal_int(
		"hex_distance",
		7,
		hg.Hex_distance(hg.Hex_init(3, -7, 4), hg.Hex_init(0, 0, 0)),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_hex_rotate_right :: proc() -> int {
	equal_hex(
		"hex_rotate_right",
		hg.Hex_rotate_right(hg.Hex_init(1, -3, 2)),
		hg.Hex_init(3, -2, -1),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_hex_rotate_left :: proc() -> int {
	equal_hex(
		"hex_rotate_left",
		hg.Hex_rotate_left(hg.Hex_init(1, -3, 2)),
		hg.Hex_init(-2, -1, 3),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_hex_round :: proc() -> int {
	a := hg.FractionalHex_init(0.0, 0.0, 0.0)
	b := hg.FractionalHex_init(1.0, -1.0, 0.0)
	c := hg.FractionalHex_init(0.0, -1.0, 1.0)
	equal_hex(
		"hex_round 1",
		hg.Hex_init(5, -10, 5),
		hg.Hex_round(
			hg.Hex_lerp(
				hg.FractionalHex_init(0.0, 0.0, 0.0),
				hg.FractionalHex_init(10.0, -20.0, 10.0),
				0.5,
			),
		),
	)
	equal_hex(
		"hex_round 2",
		hg.Hex_round(a),
		hg.Hex_round(hg.Hex_lerp(a, b, 0.499)),
	)
	equal_hex(
		"hex_round 3",
		hg.Hex_round(b),
		hg.Hex_round(hg.Hex_lerp(a, b, 0.501)),
	)
	equal_hex(
		"hex_round 4",
		hg.Hex_round(a),
		hg.Hex_round(
			hg.FractionalHex_init(
				a.q * 0.4 + b.q * 0.3 + c.q * 0.3,
				a.r * 0.4 + b.r * 0.3 + c.r * 0.3,
				a.s * 0.4 + b.s * 0.3 + c.s * 0.3,
			),
		),
	)
	equal_hex(
		"hex_round 5\n\n",
		hg.Hex_round(c),
		hg.Hex_round(
			hg.FractionalHex_init(
				a.q * 0.3 + b.q * 0.3 + c.q * 0.4,
				a.r * 0.3 + b.r * 0.3 + c.r * 0.4,
				a.s * 0.3 + b.s * 0.3 + c.s * 0.4,
			),
		),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_hex_linedraw :: proc() -> int {
	equal_hex_array(
		"hex_linedraw",
		[dynamic]hg.Hex {
			hg.Hex_init(0, 0, 0),
			hg.Hex_init(0, -1, 1),
			hg.Hex_init(0, -2, 2),
			hg.Hex_init(1, -3, 2),
			hg.Hex_init(1, -4, 3),
			hg.Hex_init(1, -5, 4),
		},
		hg.Hex_linedraw(hg.Hex_init(0, 0, 0), hg.Hex_init(1, -5, 4)),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_layout :: proc() -> int {
	h := hg.Hex_init(3, 4, -7)
	flat := hg.Layout {
		hg.FLAT_ORIENTATION,
		hg.Point{10.0, 15.0},
		hg.Point{35.0, 71.0},
	}
	equal_hex(
		"layout",
		h,
		hg.Hex_round(hg.Hex_from_pixel(flat, hg.Hex_to_pixel(flat, h))),
	)
	pointy := hg.Layout {
		hg.POINTY_ORIENTATION,
		hg.Point{10.0, 15.0},
		hg.Point{35.0, 71.0},
	}
	equal_hex(
		"layout",
		h,
		hg.Hex_round(hg.Hex_from_pixel(pointy, hg.Hex_to_pixel(pointy, h))),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_offset_roundtrip :: proc() -> int {
	a := hg.Hex_init(3, 4, -7)
	b := hg.OffsetCoord{1, -3}
	offset, offset_err := hg.qoffset_from_cube(hg.EVEN, a)
	if offset_err != hg.GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	cube, cube_err := hg.qoffset_to_cube(hg.EVEN, offset)
	if cube_err != hg.GRID_NO_ERROR {
		complain("Convert to cube")
	}
	equal_hex("conversion_roundtrip even-q 1", a, cube)

	cube, cube_err = hg.qoffset_to_cube(hg.EVEN, b)
	if cube_err != hg.GRID_NO_ERROR {
		complain("Convert to cube")
	}
	offset, offset_err = hg.qoffset_from_cube(hg.EVEN, cube)
	if offset_err != hg.GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	equal_offsetcoord("conversion_roundtrip even-q 2\n\n", b, offset)

	offset, offset_err = hg.qoffset_from_cube(hg.ODD, a)
	if offset_err != hg.GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	cube, cube_err = hg.qoffset_to_cube(hg.ODD, offset)
	if cube_err != hg.GRID_NO_ERROR {
		complain("Convert to cube")
	}
	equal_hex("conversion_roundtrip even-q 3", a, cube)

	cube, cube_err = hg.qoffset_to_cube(hg.ODD, b)
	if cube_err != hg.GRID_NO_ERROR {
		complain("Convert to cube")
	}
	offset, offset_err = hg.qoffset_from_cube(hg.ODD, cube)
	if offset_err != hg.GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	equal_offsetcoord("conversion_roundtrip even-q 4", b, offset)
	//

	offset, offset_err = hg.roffset_from_cube(hg.EVEN, a)
	if offset_err != hg.GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	cube, cube_err = hg.roffset_to_cube(hg.EVEN, offset)
	if cube_err != hg.GRID_NO_ERROR {
		complain("Convert to cube")
	}
	equal_hex("conversion_roundtrip even-q 5", a, cube)

	cube, cube_err = hg.roffset_to_cube(hg.EVEN, b)
	if cube_err != hg.GRID_NO_ERROR {
		complain("Convert to cube")
	}
	offset, offset_err = hg.roffset_from_cube(hg.EVEN, cube)
	if offset_err != hg.GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	equal_offsetcoord("conversion_roundtrip even-q 6", b, offset)

	offset, offset_err = hg.roffset_from_cube(hg.ODD, a)
	if offset_err != hg.GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	cube, cube_err = hg.roffset_to_cube(hg.ODD, offset)
	if cube_err != hg.GRID_NO_ERROR {
		complain("Convert to cube")
	}
	equal_hex("conversion_roundtrip even-q 7", a, cube)

	cube, cube_err = hg.qoffset_to_cube(hg.ODD, b)
	if cube_err != hg.GRID_NO_ERROR {
		complain("Convert to cube")
	}
	offset, offset_err = hg.qoffset_from_cube(hg.ODD, cube)
	if offset_err != hg.GRID_NO_ERROR {
		complain("Conversion to offset")
	}
	equal_offsetcoord("conversion_roundtrip even-q 8", b, offset)


	// equal_hex(
	// 	"conversion_roundtrip even-q",
	// 	a,
	// 	hg.qoffset_to_cube(hg.EVEN, hg.qoffset_from_cube(hg.EVEN, a)),
	// )
	// equal_offsetcoord(
	// 	"conversion_roundtrip even-q",
	// 	b,
	// 	hg.qoffset_from_cube(hg.EVEN, hg.qoffset_to_cube(hg.EVEN, b)),
	// )
	// equal_hex(
	// 	"conversion_roundtrip odd-q",
	// 	a,
	// 	hg.qoffset_to_cube(hg.ODD, hg.qoffset_from_cube(hg.ODD, a)),
	// )
	// equal_offsetcoord(
	// 	"conversion_roundtrip odd-q",
	// 	b,
	// 	hg.qoffset_from_cube(hg.ODD, hg.qoffset_to_cube(hg.ODD, b)),
	// )
	// equal_hex(
	// 	"conversion_roundtrip even-r",
	// 	a,
	// 	hg.roffset_to_cube(hg.EVEN, hg.roffset_from_cube(hg.EVEN, a)),
	// )
	// equal_offsetcoord(
	// 	"conversion_roundtrip even-r",
	// 	b,
	// 	hg.roffset_from_cube(hg.EVEN, hg.roffset_to_cube(hg.EVEN, b)),
	// )
	// equal_hex(
	// 	"conversion_roundtrip odd-r",
	// 	a,
	// 	hg.roffset_to_cube(hg.ODD, hg.roffset_from_cube(hg.ODD, a)),
	// )
	// equal_offsetcoord(
	// 	"conversion_roundtrip odd-r",
	// 	b,
	// 	hg.roffset_from_cube(hg.ODD, hg.roffset_to_cube(hg.ODD, b)),
	// )
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_offset_from_cube :: proc() -> int {
	offset, offset_err := hg.qoffset_from_cube(hg.EVEN, hg.Hex_init(1, 2, -3))
	if offset_err != hg.GRID_NO_ERROR {
		complain("test_offset_from_cube 1")
	}
	equal_offsetcoord("offset_from_cube even-q", hg.OffsetCoord{1, 3}, offset)

	offset, offset_err = hg.qoffset_from_cube(hg.ODD, hg.Hex_init(1, 2, -3))
	if offset_err != hg.GRID_NO_ERROR {
		complain("test_offset_from_cube 2")
	}
	equal_offsetcoord("offset_from_cube odd-q", hg.OffsetCoord{1, 2}, offset)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_offset_to_cube :: proc() -> int {
	cube, cube_err := hg.qoffset_to_cube(hg.EVEN, hg.OffsetCoord{1, 3})
	if cube_err != hg.GRID_NO_ERROR {
		complain("offset_to_cube even")
	}
	equal_hex("offset_to_cube even-", hg.Hex_init(1, 2, -3), cube)

	cube, cube_err = hg.qoffset_to_cube(hg.ODD, hg.OffsetCoord{1, 2})
	if cube_err != hg.GRID_NO_ERROR {
		complain("offset_to_cube odd")
	}
	equal_hex("offset_to_cube odd-q", hg.Hex_init(1, 2, -3), cube)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_doubled_roundtrip :: proc() -> int {
	a := hg.Hex_init(3, 4, -7)
	b := hg.DoubledCoord{1, -3}
	equal_hex(
		"conversion_roundtrip doubled-q",
		a,
		hg.qdoubled_to_cube(hg.qdoubled_from_cube(a)),
	)
	equal_doubledcoord(
		"conversion_roundtrip doubled-q",
		b,
		hg.qdoubled_from_cube(hg.qdoubled_to_cube(b)),
	)
	equal_hex(
		"conversion_roundtrip doubled-r",
		a,
		hg.rdoubled_to_cube(hg.rdoubled_from_cube(a)),
	)
	equal_doubledcoord(
		"conversion_roundtrip doubled-r",
		b,
		hg.rdoubled_from_cube(hg.rdoubled_to_cube(b)),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}
test_doubled_from_cube :: proc() -> int {
	equal_doubledcoord(
		"doubled_from_cube doubled-q",
		hg.DoubledCoord{1, 5},
		hg.qdoubled_from_cube(hg.Hex_init(1, 2, -3)),
	)
	equal_doubledcoord(
		"doubled_from_cube doubled-r",
		hg.DoubledCoord{4, 2},
		hg.rdoubled_from_cube(hg.Hex_init(1, 2, -3)),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1

}

test_doubled_to_cube :: proc() -> int {
	equal_hex(
		"doubled_to_cube doubled-q",
		hg.Hex_init(1, 2, -3),
		hg.qdoubled_to_cube(hg.DoubledCoord{1, 5}),
	)
	equal_hex(
		"doubled_to_cube doubled-r",
		hg.Hex_init(1, 2, -3),
		hg.rdoubled_to_cube(hg.DoubledCoord{4, 2}),
	)
	fmt.printf("{0} test passed!\n", #procedure)
	return 1
}

test_all :: proc() {
	num_tests :: 16
	num_passed := 0
	num_passed += test_hex_arithmetic()
	num_passed += test_hex_direction()
	num_passed += test_hex_neighbor()
	num_passed += test_hex_diagonal()
	num_passed += test_hex_distance()
	num_passed += test_hex_rotate_right()
	num_passed += test_hex_rotate_left()
	num_passed += test_hex_round()
	num_passed += test_hex_linedraw()
	num_passed += test_layout()
	num_passed += test_offset_roundtrip()
	num_passed += test_offset_from_cube()
	num_passed += test_offset_to_cube()
	num_passed += test_doubled_roundtrip()
	num_passed += test_doubled_from_cube()
	num_passed += test_doubled_to_cube()
	fmt.printfln("NUM TESTS PASSED: {0}/{1}", num_passed, num_tests)
}


main :: proc() {
	// fmt.println("Hello")
	test_all()
}
