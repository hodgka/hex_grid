package hex_grid
import "core:math"

shapeParallelogram :: proc(q1: int, r1, q2, r2) -> (hexes: [dynamic]Hex){
    for q := q1; q <= q2; q+=1 {
        for r := r1; r <= r2; r+=1 {
            append(&hexes, Hex_init(q, r, -q-r))
        }
    }
    return hexes
}


shapeTriangle1 :: proc(size: int) -> (hexes: [dynamic]Hex){
    for (q := 0; q <= size; q += 1) {
        for (r := 0; r <= size-q; r += 1) {
            append(&hexes, Hex_init(q, r, -q-r))
        }
    }
    return hexes;
}


shapeTriangle2 :: proc(size: int) -> (hexes: [dynamic]Hex){
    for (q := 0; q <= size; q += 1) {
        for (r := size-q; r <= size; r += 1) {
            append(&hexes, Hex_init(q, r, -q-r))
        }
    }
    return hexes;
}


shapeHexagon :: proc(size: int) -> (hexes: [dynamic]Hex){
    for (q := -size; q <= size; q += 1) {
        r1 = max(-size, -q-size);
        r2 = min(size, -q+size);
        for (r := r1; r <= r2; r += 1) {
            append(&hexes, Hex_init(q, r, -q-r))
        }
    }
    return hexes;
}


shapeRectanglePointy :: proc(left, top, right, bottom: int) -> (hexes: [dynamic]Hex){
    for (r := top; r <= bottom; r += 1) {
        r_offset := math.floor(r/2.0); // or r>>1
        for (q := left - r_offset; q <= right - r_offset; q += 1) {
            append(&hexes, Hex_init(q, r, -q-r))
        }
    }
    return hexes;
}

shapeRectangleFlat :: proc(left, top, right, bottom: int) -> (hexes: [dynamic]Hex){
    for (q := left; q <= right; q += 1) {
        q_offset := math.floor(q/2.0); // or q>>1
        for (r := top - q_offset; r <= bottom - q_offset; r += 1) {
            append(&hexes, Hex_init(q, r, -q-r))
        }
    }
    return hexes;
}

shapeRectangleArbitrary :: proc(w, h: int) -> (hexes: [dynamic]Hex){
    i1 := -math.floor(w/2), i2 = i1 + w;
    j1 := -math.floor(h/2), j2 = j1 + h;
    for (j = j1; j < j2; j += 1) {
        jOffset := -math.floor(j/2);
        for (i = i1 + jOffset; i < i2 + jOffset; i += 1) {
            append(&hexes, Hex_init(i, j, -i-j))
        }
    }
    return hexes;
}
