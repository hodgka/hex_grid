package hex_grid

import "core:container/queue"
import "core:fmt"

Hex_get_colinear_fractional_hexes :: proc(
	A, B: Hex,
) -> (
	fractional_hexes: [dynamic]FractionalHex,
) {
	offset := FractionalHex_init(1e-6, 2e-6, -3e-6)
	N := f64(Hex_length(Hex_subtract(A, B)))
	for i: f64 = 0; i <= N; i += 1 {
		append(
			&fractional_hexes,
			FractionHex_add(Hex_lerp(A, B, i / max(1.0, N)), offset),
		)
	}
	return fractional_hexes
}

Hex_get_colinear_integer_hexes :: proc(A, B: Hex) -> (hexes: [dynamic]Hex) {

	offset := FractionalHex_init(1e-6, 2e-6, -3e-6)
	N := f64(Hex_length(Hex_subtract(A, B)))
	for i: f64 = 0; i <= N; i += 1 {
		append(
			&hexes,
			Hex_round(
				FractionHex_add(Hex_lerp(A, B, i / max(1.0, N)), offset),
			),
		)
	}
	return hexes
}


// bfs :: proc(start: Hex, blocked: []Hex) ->  () {
// 	queue := Queue(Hex)
// }
