package main

import "core:strings"
import "core:strconv"
import "core:log"
import "core:os"

Mesh :: struct {
    transformedVertices: []Vector3,
    transformedNormals: []Vector3,
    vertices: []Vector3,
    normals: []Vector3,
    uvs: []Vector2,
    triangles: []([9]int), 
}

LoadMeshFromObjFile :: proc(filepath: string) -> Mesh {
    data, ok := os.read_entire_file(filepath)
    if !ok {
        log.panic("Failed to read file %v", filepath)
    }
    defer delete(data)

    vertices: [dynamic]Vector3
    normals: [dynamic]Vector3
    triangles: [dynamic][9]int
    uvs: [dynamic]Vector2

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        if len(line) <= 0 {
            continue
        }
        
        split := strings.split(line, " ")
        if split[0] == "v" {
            x := ParseCoord(split[:], 1)
            y := ParseCoord(split[:], 2)
            z := ParseCoord(split[:], 3)
            append(&vertices, Vector3{x, y, z})
        } 
        else if split[0] == "vt" {
            u := ParseCoord(split[:], 1)
            v := ParseCoord(split[:], 2)
            append(&uvs, Vector2{u, v})
        } 
        else if split[0] == "vn" {
            nx := ParseCoord(split[:], 1)
            ny := ParseCoord(split[:], 2)
            nz := ParseCoord(split[:], 3)
            append(&normals, Vector3{nx, ny, nz})
        }
        else if split[0] == "f" {
            // f v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3
            v1, vt1, vn1 := ParseIndices(split[:], 1)
            v2, vt2, vn2 := ParseIndices(split[:], 2)
            v3, vt3, vn3 := ParseIndices(split[:], 3)
            append(&triangles, [9]int{v1, v2, v3, vt1, vt2, vt3, vn1, vn2, vn3})
        }
    }

    transformedVertices := make([]Vector3, len(vertices))
    trasformedNormals := make([]Vector3, len(normals))

    return Mesh {
        transformedVertices = transformedVertices[:],
        transformedNormals = trasformedNormals[:],
        vertices = vertices[:],
        normals = normals[:],
        uvs = uvs[:],
        triangles = triangles[:]
    } 

    ParseCoord :: proc(split: []string, idx: int) -> f32 {
        coord, ok := strconv.parse_f32(split[idx])
        if !ok {
            log.panic("Failed to parse coordinate")
        }

        return coord
    }

    ParseIndices :: proc(split: []string, idx: int) -> (int, int, int) {
        indices := strings.split(split[idx], "/")
        
        v, okv := strconv.parse_int(indices[0])
        if !okv {
            log.panic("Failed to parse index of a vertex")
        }
        
        vt, okvt := strconv.parse_int(indices[1])
        if !okvt {
            log.panic("Failed to parse index of a UV")
        }

        vn, okvn := strconv.parse_int(indices[2])
        if !okvn {
            log.panic("Failed to parse index of a normal")
        }
        
        return v - 1, vt - 1, vn - 1
    }
}

MakeCube :: proc() -> Mesh {
    transformedVertices := make([]Vector3, 8)
    transformedNormals := make([]Vector3, 6)

    vertices := make([]Vector3, 8)

    vertices[0] = Vector3{-1.0, -1.0, -1.0}
    vertices[1] = Vector3{-1.0,  1.0, -1.0}
    vertices[2] = Vector3{ 1.0,  1.0, -1.0}
    vertices[3] = Vector3{ 1.0, -1.0, -1.0}
    vertices[4] = Vector3{ 1.0,  1.0,  1.0}
    vertices[5] = Vector3{ 1.0, -1.0,  1.0}
    vertices[6] = Vector3{-1.0,  1.0,  1.0}
    vertices[7] = Vector3{-1.0, -1.0,  1.0}

    normals := make([]Vector3, 6)
    normals[0] = {-0.0, -0.0, -1.0}
    normals[1] = { 1.0, -0.0, -0.0}
    normals[2] = {-0.0, -0.0,  1.0}
    normals[3] = {-1.0, -0.0, -0.0}
    normals[4] = {-0.0,  1.0, -0.0}
    normals[5] = {-0.0, -1.0, -0.0}

    uvs := make([]Vector2, 6)
    // 1st triangle
    uvs[0] =  Vector2{0.0, 0.0}
    uvs[1] =  Vector2{0.0, 1.0}
    uvs[2] =  Vector2{1.0, 1.0}
    // 2nd triangle
    uvs[3] =  Vector2{0.0, 0.0}
    uvs[4] =  Vector2{1.0, 1.0}
    uvs[5] =  Vector2{1.0, 0.0}

    triangles := make([][9]int, 12)

    // Front               vert.     uvs       norm.
    triangles[0] =  [9]int{0, 1, 2,  0, 1, 2,  0, 0, 0}
    triangles[1] =  [9]int{0, 2, 3,  3, 4, 5,  0, 0, 0}
    // Right
    triangles[2] =  [9]int{3, 2, 4,  0, 1, 2,  1, 1, 1}
    triangles[3] =  [9]int{3, 4, 5,  3, 4, 5,  1, 1, 1}
    // Back
    triangles[4] =  [9]int{5, 4, 6,  0, 1, 2,  2, 2, 2}
    triangles[5] =  [9]int{5, 6, 7,  3, 4, 5,  2, 2, 2}
    // Left
    triangles[6] =  [9]int{7, 6, 1,  0, 1, 2,  3, 3, 3}
    triangles[7] =  [9]int{7, 1, 0,  3, 4, 5,  3, 3, 3}
    // Top
    triangles[8] =  [9]int{1, 6, 4,  0, 1, 2,  4, 4, 4}
    triangles[9] =  [9]int{1, 4, 2,  3, 4, 5,  4, 4, 4}
    // Bottom
    triangles[10] = [9]int{5, 7, 0,  0, 1, 2,  5, 5, 5}
    triangles[11] = [9]int{5, 0, 3,  3, 4, 5,  5, 5, 5}

    return Mesh{
        transformedVertices = transformedVertices,
        vertices = vertices,
        normals = normals,
        triangles = triangles,
        uvs = uvs
    }
}

DeleteMesh :: proc(mesh: ^Mesh) {
    delete(mesh.transformedVertices)
    delete(mesh.transformedNormals)
    delete(mesh.vertices)
    delete(mesh.normals)
    delete(mesh.triangles)
    delete(mesh.uvs)
}