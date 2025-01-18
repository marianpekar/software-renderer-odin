package main

Camera :: struct {
    position: Vector3,
    target: Vector3
}

MakeCamera :: proc(position: Vector3) -> Camera {
    camera: Camera
    camera.position = position
    camera.target = Vector3{0.0, 0.0, -1.0}
    return camera
}