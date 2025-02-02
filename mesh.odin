package main

Mesh :: struct {
    transformedVertices: []Vector3,
    vertices: []Vector3,
    uvs: []Vector2,
    triangles: []([6]int), 
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

    uvs := make([]Vector2, 6)
    // 1st triangle
    uvs[0] =  Vector2{0.0, 0.0}
    uvs[1] =  Vector2{0.0, 1.0}
    uvs[2] =  Vector2{1.0, 1.0}
    // 2nd triangle
    uvs[3] =  Vector2{0.0, 0.0}
    uvs[4] =  Vector2{1.0, 1.0}
    uvs[5] =  Vector2{1.0, 0.0}

    triangles := make([][6]int, 12)

    // Front                <-vert.  uvs->
    triangles[0] =  [6]int{0, 1, 2,  0, 1, 2}
    triangles[1] =  [6]int{0, 2, 3,  3, 4, 5}
    // Right
    triangles[2] =  [6]int{3, 2, 4,  0, 1, 2}
    triangles[3] =  [6]int{3, 4, 5,  3, 4, 5}
    // Back
    triangles[4] =  [6]int{5, 4, 6,  0, 1, 2}
    triangles[5] =  [6]int{5, 6, 7,  3, 4, 5}
    // Left
    triangles[6] =  [6]int{7, 6, 1,  0, 1, 2}
    triangles[7] =  [6]int{7, 1, 0,  3, 4, 5}
    // Top
    triangles[8] =  [6]int{1, 6, 4,  0, 1, 2}
    triangles[9] =  [6]int{1, 4, 2,  3, 4, 5}
    // Bottom
    triangles[10] = [6]int{5, 7, 0,  0, 1, 2}
    triangles[11] = [6]int{5, 0, 3,  3, 4, 5}

    return Mesh{
        transformedVertices = transformedVertices,
        vertices = vertices,
        triangles = triangles,
        uvs = uvs
    }
}

DeleteMesh :: proc(mesh: ^Mesh) {
    delete(mesh.transformedVertices)
    delete(mesh.vertices)
    delete(mesh.triangles)
    delete(mesh.uvs)
}