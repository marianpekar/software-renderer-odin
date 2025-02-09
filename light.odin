package main

Light :: struct {
    position: Vector3,
    direction: Vector3,
    strength: f32,
}

MakeLight :: proc(position, direction: Vector3, strength: f32) -> Light {
    return { 
        position, 
        direction, 
        strength 
    }
}

NormalizeLight :: proc(light: ^Light) {
    light.direction = Vector3Normalize(light.direction)
}