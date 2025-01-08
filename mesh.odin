package main

import rl "vendor:raylib"

Mesh :: struct {
    vertices: []rl.Vector3,
    edges: []([2]int),
    triangles: []([3]int)
}

MakeCube :: proc() -> Mesh {
    vertices := make([]rl.Vector3, 8)
    vertices[0] = rl.Vector3{-1.0, -1.0, -1.0}
    vertices[1] = rl.Vector3{ 1.0, -1.0, -1.0}
    vertices[2] = rl.Vector3{ 1.0,  1.0, -1.0}
    vertices[3] = rl.Vector3{-1.0,  1.0, -1.0}
    vertices[4] = rl.Vector3{-1.0, -1.0,  1.0}
    vertices[5] = rl.Vector3{ 1.0, -1.0,  1.0}
    vertices[6] = rl.Vector3{ 1.0,  1.0,  1.0}
    vertices[7] = rl.Vector3{-1.0,  1.0,  1.0}

    edges := make([][2]int, 12)
    edges[0] = [2]int{0, 1}
    edges[1] = [2]int{1, 2}
    edges[2] = [2]int{2, 3}
    edges[3] = [2]int{3, 0}
    edges[4] = [2]int{4, 5}
    edges[5] = [2]int{5, 6}
    edges[6] = [2]int{6, 7}
    edges[7] = [2]int{7, 4}
    edges[8] = [2]int{0, 4}
    edges[9] = [2]int{1, 5}
    edges[10] = [2]int{2, 6}
    edges[11] = [2]int{3, 7}

    triangles := make([][3]int, 12)

    // Front
    triangles[0] = [3]int{0, 1, 2}
    triangles[1] = [3]int{0, 2, 3}

    // Back
    triangles[2] = [3]int{4, 5, 6}
    triangles[3] = [3]int{4, 6, 7}

    // Left
    triangles[4] = [3]int{0, 4, 7}
    triangles[5] = [3]int{0, 7, 3}

    // Right
    triangles[6] = [3]int{1, 5, 6}
    triangles[7] = [3]int{1, 6, 2}

    // Top
    triangles[8] = [3]int{3, 2, 6}
    triangles[9] = [3]int{3, 6, 7}

    // Bottom
    triangles[10] = [3]int{0, 1, 5}
    triangles[11] = [3]int{0, 5, 4}

    return Mesh{
        vertices = vertices,
        edges = edges,
        triangles = triangles
    }
}
