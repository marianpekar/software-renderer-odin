package main

Light :: Vector3

MakeLight :: proc(direction: Vector3) -> Light {
    light := direction
    light = Vector3Normalize(light)
    return light
}