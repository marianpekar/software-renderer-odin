package main

import "core:math"

Vector2 :: [2]f32
Vector3 :: [3]f32
Vector4 :: [4]f32

Vector3Normalize :: proc(v: Vector3) -> Vector3 {
    length_sq := v[0]*v[0] + v[1]*v[1] + v[2]*v[2];

    if length_sq == 0.0 {
        return {0.0, 0.0, 0.0};
    }

    inv_length := FastInverseSqrt(length_sq);

    return {
        v[0] * inv_length,
        v[1] * inv_length,
        v[2] * inv_length,
    }
}

FastInverseSqrt :: proc(x: f32) -> f32 {
    i := transmute(i32)x;
    i = 0x5f3759df - (i >> 1);
    y := transmute(f32)i;
    return y * (1.5 - 0.5 * x * y * y);
}

Vector3CrossProduct :: proc(v1, v2: Vector3) -> Vector3 {
    return {
        v1[1]*v2[2] - v1[2]*v2[1],
        v1[2]*v2[0] - v1[0]*v2[2],
        v1[0]*v2[1] - v1[1]*v2[0],
    }
}

Vector3DotProduct :: proc(v1, v2: Vector3) -> f32 {
    return v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2];
}

FloorXY :: proc (v: ^Vector3) {
    v.x = math.floor(v.x)
    v.y = math.floor(v.y)
}