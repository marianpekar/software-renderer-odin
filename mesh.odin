package main

import rl "vendor:raylib"

Mesh :: struct {
    vertices: []rl.Vector3,
    triangles: []([3]int),
    uvs: []rl.Vector2,
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

    uvs := make([]rl.Vector2, 36)

    // TODO: These UVs are incorrect, needs to be fixed
    // Front
    uvs[0] = rl.Vector2{0.0, 0.0}
    uvs[1] = rl.Vector2{1.0, 0.0}
    uvs[2] = rl.Vector2{0.0, 1.0}

    uvs[3] = rl.Vector2{1.0, 1.0}
    uvs[4] = rl.Vector2{0.0, 0.0}
    uvs[5] = rl.Vector2{1.0, 0.0} 
    
    // Right
    uvs[6] = rl.Vector2{0.0, 1.0}
    uvs[7] = rl.Vector2{1.0, 1.0} 
    uvs[8] = rl.Vector2{1.0, 0.0}
    
    uvs[9] = rl.Vector2{0.0, 0.0}
    uvs[10] = rl.Vector2{1.0, 1.0} 
    uvs[11] = rl.Vector2{0.0, 1.0}

    // Back
    uvs[12] = rl.Vector2{0.0, 0.0}
    uvs[13] = rl.Vector2{1.0, 0.0} 
    uvs[14] = rl.Vector2{0.0, 1.0} 
    
    uvs[15] = rl.Vector2{1.0, 1.0}
    uvs[16] = rl.Vector2{1.0, 0.0}
    uvs[17] = rl.Vector2{0.0, 0.0} 
    
    // Left
    uvs[18] = rl.Vector2{1.0, 1.0} 
    uvs[19] = rl.Vector2{0.0, 1.0}  
    uvs[20] = rl.Vector2{1.0, 0.0}
    
    uvs[21] = rl.Vector2{0.0, 0.0}
    uvs[22] = rl.Vector2{1.0, 1.0}  
    uvs[23] = rl.Vector2{0.0, 1.0}
    
    // Top
    uvs[24] = rl.Vector2{1.0, 0.0}
    uvs[25] = rl.Vector2{0.0, 0.0} 
    uvs[26] = rl.Vector2{1.0, 1.0} 
    
    uvs[27] = rl.Vector2{0.0, 1.0}
    uvs[28] = rl.Vector2{1.0, 0.0}
    uvs[29] = rl.Vector2{0.0, 0.0}
    
    // Bottom
    uvs[30] = rl.Vector2{1.0, 1.0}  
    uvs[31] = rl.Vector2{0.0, 1.0}  
    uvs[32] = rl.Vector2{1.0, 0.0}
    
    uvs[33] = rl.Vector2{0.0, 0.0}
    uvs[34] = rl.Vector2{1.0, 1.0}  
    uvs[35] = rl.Vector2{0.0, 1.0} 

    return Mesh{
        vertices = vertices,
        triangles = triangles,
        uvs = uvs,
    }
}



