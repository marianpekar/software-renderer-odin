package main

import "core:math"

Matrix4x4 :: struct {
    m: [4][4]f32
}

Mat4MulVec3 :: proc(mat: ^Matrix4x4, vec: ^Vector3) -> Vector3 {
    x := mat.m[0][0]*vec.x + mat.m[1][0]*vec.y + mat.m[2][0]*vec.z + mat.m[3][0]
    y := mat.m[0][1]*vec.x + mat.m[1][1]*vec.y + mat.m[2][1]*vec.z + mat.m[3][1]
    z := mat.m[0][2]*vec.x + mat.m[1][2]*vec.y + mat.m[2][2]*vec.z + mat.m[3][2]
    
    x += mat.m[0][3]
    y += mat.m[1][3]
    z += mat.m[2][3]

    return Vector3{x, y, z}
}


Mat4Mul :: proc(a: ^Matrix4x4, b: ^Matrix4x4) -> Matrix4x4 {
    result: Matrix4x4
    for i in 0..<4 {
        for j in 0..<4 {
            result.m[i][j] = a.m[i][0] * b.m[0][j] +
                             a.m[i][1] * b.m[1][j] +
                             a.m[i][2] * b.m[2][j] +
                             a.m[i][3] * b.m[3][j]
        }
    }
    return result
}

MakeTranslationMatrix :: proc(x: f32, y: f32, z: f32) -> Matrix4x4 {
    return Matrix4x4{
        m = [4][4]f32{
            {1.0,  0.0,  0.0,    x},
            {0.0,  1.0,  0.0,    y},
            {0.0,  0.0,  1.0,    z},
            {0.0,  0.0,  0.0,  1.0}
        }
    }
}

MakeScaleMatrix :: proc(sx: f32, sy: f32, sz: f32) -> Matrix4x4 {
    return Matrix4x4{
        m = [4][4]f32{
            {sx,   0.0,  0.0,  0.0},
            {0.0,   sy,  0.0,  0.0},
            {0.0,  0.0,   sz,  0.0},
            {0.0,  0.0,  0.0,  1.0}
        }
    }
}

MakeRotationMatrixX :: proc(angle: f32) -> Matrix4x4 {
    c := math.cos(angle)
    s := math.sin(angle)

    return Matrix4x4{
        m = [4][4]f32{
            {1.0,  0.0,  0.0,  0.0},
            {0.0,    c,   -s,  0.0},
            {0.0,    s,    c,  0.0},
            {0.0,  0.0,  0.0,  1.0}
        }
    }
}

MakeRotationMatrixY :: proc(angle: f32) -> Matrix4x4 {
    c := math.cos(angle)
    s := math.sin(angle)

    return Matrix4x4{
        m = [4][4]f32{
            {  c,  0.0,    s,  0.0},
            {0.0,  1.0,  0.0,  0.0},
            { -s,  0.0,    c,  0.0},
            {0.0,  0.0,  0.0,  1.0}
        }
    }
}

MakeRotationMatrixZ :: proc(angle: f32) -> Matrix4x4 {
    c := math.cos(angle)
    s := math.sin(angle)

    return Matrix4x4{
        m = [4][4]f32{
            {c,     -s,  0.0,  0.0},
            {s,      c,  0.0,  0.0},
            {0.0,  0.0,  1.0,  0.0},
            {0.0,  0.0,  0.0,  1.0}
        }
    }
}

MakeViewMatrix :: proc(eye: Vector3, target: Vector3) -> Matrix4x4 {
    forward := Vector3Normalize(eye - target)
    right   := Vector3Normalize(Vector3CrossProduct(Vector3{0.0, 1.0, 0.0}, forward))
    up      := Vector3CrossProduct(forward, right)

    return Matrix4x4{
        m = [4][4]f32{
            {   right.x,   right.y,   right.z,  -Vector3DotProduct(right, eye)},
            {      up.x,      up.y,      up.z,  -Vector3DotProduct(up, eye)},
            { forward.x, forward.y, forward.z,  -Vector3DotProduct(forward, eye)},
            {       0.0,       0.0,       0.0,   1.0}
        }
    }
}