package main

Mesh :: struct {
    transformedVertices: []Vector3,
    vertices: []Vector3,
    triangles: []([3]int),
    uvs: []Vector2,
}

MakeCube :: proc() -> Mesh {
    transformedVertices := make([]Vector3, 8)
    vertices := make([]Vector3, 8)
    vertices[0] = Vector3{-1.0, -1.0, -1.0}
    vertices[1] = Vector3{-1.0,  1.0, -1.0}
    vertices[2] = Vector3{ 1.0,  1.0, -1.0}
    vertices[3] = Vector3{ 1.0, -1.0, -1.0}
    vertices[4] = Vector3{ 1.0,  1.0,  1.0}
    vertices[5] = Vector3{ 1.0, -1.0,  1.0}
    vertices[6] = Vector3{-1.0,  1.0,  1.0}
    vertices[7] = Vector3{-1.0, -1.0,  1.0}

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

    uvs := make([]Vector2, 36)

    // Front
    uvs[0] =  Vector2{0.0, 0.0}
    uvs[1] =  Vector2{0.0, 1.0}
    uvs[2] =  Vector2{1.0, 1.0}

    uvs[3] =  Vector2{0.0, 0.0}
    uvs[4] =  Vector2{1.0, 1.0}
    uvs[5] =  Vector2{1.0, 0.0}
    
    // Right
    uvs[6] =  Vector2{0.0, 0.0}
    uvs[7] =  Vector2{0.0, 1.0}
    uvs[8] =  Vector2{1.0, 1.0}

    uvs[9] =  Vector2{0.0, 0.0}
    uvs[10] = Vector2{1.0, 1.0}
    uvs[11] = Vector2{1.0, 0.0}

    // Back
    uvs[12] = Vector2{0.0, 0.0}
    uvs[13] = Vector2{0.0, 1.0}
    uvs[14] = Vector2{1.0, 1.0}

    uvs[15] = Vector2{0.0, 0.0}
    uvs[16] = Vector2{1.0, 1.0}
    uvs[17] = Vector2{1.0, 0.0}
    
    // Left
    uvs[18] = Vector2{0.0, 0.0}
    uvs[19] = Vector2{0.0, 1.0}
    uvs[20] = Vector2{1.0, 1.0}

    uvs[21] = Vector2{0.0, 0.0}
    uvs[22] = Vector2{1.0, 1.0}
    uvs[23] = Vector2{1.0, 0.0}
    
    // Top
    uvs[24] = Vector2{0.0, 0.0}
    uvs[25] = Vector2{0.0, 1.0}
    uvs[26] = Vector2{1.0, 1.0}

    uvs[27] = Vector2{0.0, 0.0}
    uvs[28] = Vector2{1.0, 1.0}
    uvs[29] = Vector2{1.0, 0.0}
    
    // Bottom
    uvs[30] = Vector2{0.0, 0.0}
    uvs[31] = Vector2{0.0, 1.0}
    uvs[32] = Vector2{1.0, 1.0}

    uvs[33] = Vector2{0.0, 0.0}
    uvs[34] = Vector2{1.0, 1.0}
    uvs[35] = Vector2{1.0, 0.0}

    return Mesh{
        transformedVertices = transformedVertices,
        vertices = vertices,
        triangles = triangles,
        uvs = uvs,
    }
}