package main

import "core:math"

Matrix4x4 :: [4][4]f32

Mat4MulVec3 :: proc(mat: Matrix4x4, vec: Vector3) -> Vector3 {
    x := mat[0][0]*vec.x + mat[1][0]*vec.y + mat[2][0]*vec.z + mat[3][0] + mat[0][3]
    y := mat[0][1]*vec.x + mat[1][1]*vec.y + mat[2][1]*vec.z + mat[3][1] + mat[1][3]
    z := mat[0][2]*vec.x + mat[1][2]*vec.y + mat[2][2]*vec.z + mat[3][2] + mat[2][3]

    return Vector3{x, y, z}
}

Mat4MulVec4 :: proc(mat: Matrix4x4, vec: Vector4) -> Vector4 {
    x := mat[0][0]*vec.x + mat[0][1]*vec.y + mat[0][2]*vec.z + mat[0][3]*vec.w
    y := mat[1][0]*vec.x + mat[1][1]*vec.y + mat[1][2]*vec.z + mat[1][3]*vec.w
    z := mat[2][0]*vec.x + mat[2][1]*vec.y + mat[2][2]*vec.z + mat[2][3]*vec.w
    w := mat[3][0]*vec.x + mat[3][1]*vec.y + mat[3][2]*vec.z + mat[3][3]*vec.w

    return Vector4{x, y, z, w}
}

Mat4Mul :: proc(a, b: Matrix4x4) -> Matrix4x4 {
    result: Matrix4x4
    for i in 0..<4 {
        for j in 0..<4 {
            result[i][j] = a[i][0] * b[0][j] +
                           a[i][1] * b[1][j] +
                           a[i][2] * b[2][j] +
                           a[i][3] * b[3][j]
        }
    }
    return result
}

MakeTranslationMatrix :: proc(x: f32, y: f32, z: f32) -> Matrix4x4 {
    return Matrix4x4{
        {1.0,  0.0,  0.0,    x},
        {0.0,  1.0,  0.0,    y},
        {0.0,  0.0,  1.0,    z},
        {0.0,  0.0,  0.0,  1.0}    
    }
}

MakeScaleMatrix :: proc(sx: f32, sy: f32, sz: f32) -> Matrix4x4 {
    return Matrix4x4{
        {sx,   0.0,  0.0,  0.0},
        {0.0,   sy,  0.0,  0.0},
        {0.0,  0.0,   sz,  0.0},
        {0.0,  0.0,  0.0,  1.0}
    }
}

MakeRotationMatrixX :: proc(angle: f32) -> Matrix4x4 {
    angleDeg := angle * DEG_TO_RAD
    c := math.cos(angleDeg)
    s := math.sin(angleDeg)

    return Matrix4x4{
        {1.0,  0.0,  0.0,  0.0},
        {0.0,    c,   -s,  0.0},
        {0.0,    s,    c,  0.0},
        {0.0,  0.0,  0.0,  1.0}    
    }
}

MakeRotationMatrixY :: proc(angle: f32) -> Matrix4x4 {
    angleDeg := angle * DEG_TO_RAD
    c := math.cos(angleDeg)
    s := math.sin(angleDeg)

    return Matrix4x4{
        {  c,  0.0,    s,  0.0},
        {0.0,  1.0,  0.0,  0.0},
        { -s,  0.0,    c,  0.0},
        {0.0,  0.0,  0.0,  1.0}
    }
}

MakeRotationMatrixZ :: proc(angle: f32) -> Matrix4x4 {
    angleDeg := angle * DEG_TO_RAD
    c := math.cos(angleDeg)
    s := math.sin(angleDeg)

    return Matrix4x4{
        {c,     -s,  0.0,  0.0},
        {s,      c,  0.0,  0.0},
        {0.0,  0.0,  1.0,  0.0},
        {0.0,  0.0,  0.0,  1.0}
    }
}

MakeViewMatrix :: proc(eye: Vector3, target: Vector3) -> Matrix4x4 {
    forward := Vector3Normalize(eye - target)
    right   := Vector3CrossProduct(Vector3{0.0, 1.0, 0.0}, forward)
    up      := Vector3CrossProduct(forward, right)

    return Matrix4x4{
        {   right.x,   right.y,   right.z,  -Vector3DotProduct(right, eye)},
        {      up.x,      up.y,      up.z,  -Vector3DotProduct(up, eye)},
        { forward.x, forward.y, forward.z,  -Vector3DotProduct(forward, eye)},
        {       0.0,       0.0,       0.0,   1.0}
    }
}

MakeProjectionMatrix :: proc(fov: f32, screenWidth: i32, screenHeight: i32, near: f32, far: f32) -> Matrix4x4 {
    f := 1.0 / math.tan_f32(fov * 0.5 * DEG_TO_RAD)
    aspect := f32(screenWidth) / f32(screenHeight)

    return Matrix4x4{
        { f / aspect, 0.0,                        0.0,  0.0},
        {        0.0,   f,                        0.0,  0.0},
        {        0.0, 0.0,        -far / (far - near), -1.0},
        {        0.0, 0.0, -far * near / (far - near),  0.0},
    }
}