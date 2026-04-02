package main

Light :: struct {
    position: Vector3,
    direction: Vector3,
    color: Vector4,
}

MakeLight :: proc(position, direction: Vector3, color: Vector4, viewMatrix: Matrix4x4) -> Light {
    return { 
        Mat4MulVec3(viewMatrix, position), 
        Vector3Normalize(direction), 
        color
    }
}