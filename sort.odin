package main

Sort :: proc {
    SortPointsUVsAndVertices,
    SortPointsAndVertices,
    SortPointsAndUVs,
    SortPoints,
}

SortPointsUVsAndVertices :: proc(
    p1, p2, p3: ^Vector4, 
    uv1, uv2, uv3: ^Vector2,
    v1, v2, v3: ^Vector3,
) {
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        p1.w, p2.w = p2.w, p1.w
        uv1.x, uv2.x = uv2.x, uv1.x
        uv1.y, uv2.y = uv2.y, uv1.y
        v1.x, v2.x = v2.x, v1.x
        v1.y, v2.y = v2.y, v1.y
        v1.z, v2.z = v2.z, v1.z

    }
    if p2.y > p3.y {
        p2.x, p3.x = p3.x, p2.x
        p2.y, p3.y = p3.y, p2.y
        p2.z, p3.z = p3.z, p2.z
        p2.w, p3.w = p3.w, p2.w
        uv2.x, uv3.x = uv3.x, uv2.x
        uv2.y, uv3.y = uv3.y, uv2.y
        v2.x, v3.x = v3.x, v2.x
        v2.y, v3.y = v3.y, v2.y
        v2.z, v3.z = v3.z, v2.z    
    }
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        p1.w, p2.w = p2.w, p1.w
        uv1.x, uv2.x = uv2.x, uv1.x
        uv1.y, uv2.y = uv2.y, uv1.y
        v1.x, v2.x = v2.x, v1.x
        v1.y, v2.y = v2.y, v1.y
        v1.z, v2.z = v2.z, v1.z
    }
}

SortPointsAndVertices :: proc(
    p1, p2, p3: ^Vector4, 
    v1, v2, v3: ^Vector3,
) {
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        p1.w, p2.w = p2.w, p1.w
        v1.x, v2.x = v2.x, v1.x
        v1.y, v2.y = v2.y, v1.y
        v1.z, v2.z = v2.z, v1.z
    }
    if p2.y > p3.y {
        p2.x, p3.x = p3.x, p2.x
        p2.y, p3.y = p3.y, p2.y
        p2.z, p3.z = p3.z, p2.z
        p2.w, p3.w = p3.w, p2.w
        v2.x, v3.x = v3.x, v2.x
        v2.y, v3.y = v3.y, v2.y
        v2.z, v3.z = v3.z, v2.z    
    }
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        p1.w, p2.w = p2.w, p1.w
        v1.x, v2.x = v2.x, v1.x
        v1.y, v2.y = v2.y, v1.y
        v1.z, v2.z = v2.z, v1.z
    }
}

SortPointsAndUVs :: proc(p1, p2, p3: ^Vector4, uv1, uv2, uv3: ^Vector2) {
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        p1.w, p2.w = p2.w, p1.w
        uv1.x, uv2.x = uv2.x, uv1.x
        uv1.y, uv2.y = uv2.y, uv1.y
    }
    if p2.y > p3.y {
        p2.x, p3.x = p3.x, p2.x
        p2.y, p3.y = p3.y, p2.y
        p2.z, p3.z = p3.z, p2.z
        p2.w, p3.w = p3.w, p2.w
        uv2.x, uv3.x = uv3.x, uv2.x
        uv2.y, uv3.y = uv3.y, uv2.y
    }
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        p1.w, p2.w = p2.w, p1.w
        uv1.x, uv2.x = uv2.x, uv1.x
        uv1.y, uv2.y = uv2.y, uv1.y
    }
}

SortPoints :: proc(p1, p2, p3: ^Vector4) {
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        p1.w, p2.w = p2.w, p1.w
    }
    if p2.y > p3.y {
        p2.x, p3.x = p3.x, p2.x
        p2.y, p3.y = p3.y, p2.y
        p2.z, p3.z = p3.z, p2.z
        p2.w, p3.w = p3.w, p2.w
    }
    if p1.y > p2.y {
        p1.x, p2.x = p2.x, p1.x
        p1.y, p2.y = p2.y, p1.y
        p1.z, p2.z = p2.z, p1.z
        p1.w, p2.w = p2.w, p1.w
    }
}