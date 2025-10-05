package main

Light :: struct {
    position: Vector3,
    direction: Vector3,
    color: Vector4,
}

MakeLight :: proc(position, direction: Vector3, color: Vector4) -> Light {
    return { 
        position, 
        Vector3Normalize(direction), 
        color
    }
}