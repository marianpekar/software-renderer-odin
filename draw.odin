package main

import rl "vendor:raylib"

DrawWireframe :: proc(vertices: []rl.Vector3, triangles: [][3]int, color: rl.Color) {
    for tri in triangles {
        p1 := ProjectToScreen(&vertices[tri[0]])
        p2 := ProjectToScreen(&vertices[tri[1]])
        p3 := ProjectToScreen(&vertices[tri[2]])

        rl.DrawLineV(p1, p2, color)
        rl.DrawLineV(p2, p3, color)
        rl.DrawLineV(p3, p1, color)
    }
}

ProjectToScreen :: proc(point: ^rl.Vector3) -> rl.Vector2 {
    if point.z == 0.0 {
        point.z = 0.0001
    }

    projectedX := point.x / point.z
    projectedY := point.y / point.z

    screenX := projectedX * SCREEN_WIDTH / 2 + SCREEN_WIDTH / 2
    screenY := -projectedY * SCREEN_HEIGHT / 2 + SCREEN_HEIGHT / 2

    return rl.Vector2{screenX, screenY}
}