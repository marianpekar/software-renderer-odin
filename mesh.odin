package main

import "core:strings"
import "core:strconv"
import "core:log"
import "core:os"

Mesh :: struct {
    transformedVertices: []Vector3,
    vertices: []Vector3,
    uvs: []Vector2,
    triangles: []([6]int), 
}

LoadMeshFromObjFile :: proc(filepath: string) -> Mesh {
    data, ok := os.read_entire_file(filepath)
    if !ok {
        log.panic("Failed to read file %v", filepath)
    }
    defer delete(data)

    vertices: [dynamic]Vector3
    triangles: [dynamic][6]int
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
            append(&vertices, Vector3{x,y,z})
        } 
        else if split[0] == "vt" {
            u := ParseCoord(split[:], 1)
            v := ParseCoord(split[:], 2)
            append(&uvs, Vector2{u,v})
        } else if split[0] == "f" {
            // f v1/vt1 v2/vt2 v3/vt3
            v1, vt1 := ParseIndices(split[:], 1)
            v2, vt2 := ParseIndices(split[:], 2)
            v3, vt3 := ParseIndices(split[:], 3)
            append(&triangles, [6]int{v1, v2, v3, vt1, vt2, vt3})
        }
    }

    transformedVertices := make([]Vector3, len(vertices))

    return Mesh {
        transformedVertices = transformedVertices[:],
        vertices = vertices[:],
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

    ParseIndices :: proc(split: []string, idx: int) -> (int, int) {
        vvt := strings.split(split[idx], "/")
        
        v, okv := strconv.parse_int(vvt[0])
        if !okv {
            log.panic("Failed to parse index of a vertex")
        }
        
        vt, okvt := strconv.parse_int(vvt[1])
        if !okvt {
            log.panic("Failed to parse index of a UV")
        }
        
        return v - 1, vt - 1
    }
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