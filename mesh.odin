package main

import rl "vendor:raylib"

Mesh :: struct {
    vertices: []rl.Vector3,
    triangles: []([3]int)
}

MakeCube :: proc() -> Mesh {
    vertices := make([]rl.Vector3, 8)
    vertices[0] = rl.Vector3{-1.0, -1.0, -1.0}
    vertices[1] = rl.Vector3{-1.0,  1.0, -1.0}
    vertices[2] = rl.Vector3{ 1.0,  1.0, -1.0}
    vertices[3] = rl.Vector3{ 1.0, -1.0, -1.0}
    vertices[4] = rl.Vector3{ 1.0,  1.0,  1.0}
    vertices[5] = rl.Vector3{ 1.0, -1.0,  1.0}
    vertices[6] = rl.Vector3{-1.0,  1.0,  1.0}
    vertices[7] = rl.Vector3{-1.0, -1.0,  1.0}

    triangles := make([][3]int, 12)

    // Front
    triangles[0] = [3]int{0, 1, 2}
    triangles[1] = [3]int{0, 2, 3}

    // Right
    triangles[2] = [3]int{3, 2, 4}
    triangles[3] = [3]int{3, 4, 5}

    // Back
    triangles[4] = [3]int{5, 4, 6}
    triangles[5] = [3]int{5, 6, 7}

    // Left
    triangles[6] = [3]int{7, 6, 1}
    triangles[7] = [3]int{7, 1, 0}

    // Top
    triangles[8] = [3]int{1, 6, 4}
    triangles[9] = [3]int{1, 4, 2}

    // Bottom 
    triangles[10] = [3]int{5, 7, 0}
    triangles[11] = [3]int{5, 0, 3}

    return Mesh{
        vertices = vertices,
        triangles = triangles
    }
}
