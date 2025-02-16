package main

import "core:math"
import rl "vendor:raylib"

DrawWireframe :: proc(vertices: []Vector3, triangles: []Triangle, color: rl.Color, cullBackFace: bool = true) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        if cullBackFace && IsBackFace(v1, v2, v3) {
            continue
        }

        p1 := ProjectToScreen(&v1)
        p2 := ProjectToScreen(&v2)
        p3 := ProjectToScreen(&v3)

        if (IsFaceOutsideFrustum(p1, p2, p3)) {
            continue
        }

        DrawLine({p1.x, p1.y}, {p2.x, p2.y}, color)
        DrawLine({p2.x, p2.y}, {p3.x, p3.y}, color)
        DrawLine({p3.x, p3.y}, {p1.x, p1.y}, color)
    }
}

DrawLine :: proc(a, b: Vector2, color: rl.Color) {
    dX := b.x - a.x
    dY := b.y - a.y

    longerDelta := math.abs(dX) >= math.abs(dY) ? math.abs(dX) : math.abs(dY)

    incX := dX / longerDelta
    incY := dY / longerDelta

    x := a.x
    y := a.y

    for i := 0; i <= int(longerDelta); i += 1 {
        rl.DrawPixel(i32(x), i32(y), color)
        x += incX
        y += incY
    }
}

DrawUnlit :: proc(vertices: []Vector3, triangles: []Triangle, color: rl.Color, zBuffer: ^ZBuffer) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        if IsBackFace(v1, v2, v3) {
            continue
        }

        p1 := ProjectToScreen(&v1)
        p2 := ProjectToScreen(&v2)
        p3 := ProjectToScreen(&v3)

        if IsFaceOutsideFrustum(p1, p2, p3) {
            continue
        }

        DrawFilledTriangle(&p1, &p2, &p3, color, zBuffer)
    }
}

DrawFlatShaded :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    light: Light, 
    baseColor: rl.Color, 
    zBuffer: ^ZBuffer, 
    ambient:f32 = 0.2
) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        cross := Vector3CrossProduct(v2 - v1, v3 - v1)
        crossNorm := Vector3Normalize(cross)
        toCamera := Vector3Normalize(v1)
    
        if (Vector3DotProduct(crossNorm, toCamera) >= 0.0) {
            continue
        }

        intensity := Vector3DotProduct(crossNorm, light.direction)
        intensity = math.clamp(intensity, 0.0, 1.0)
        intensity = math.clamp(ambient + intensity * light.strength, 0.0, 1.0)

        shadedColor := rl.Color{
            u8(f32(baseColor.r) * intensity),
            u8(f32(baseColor.g) * intensity),
            u8(f32(baseColor.b) * intensity),
            baseColor.a
        }

        p1 := ProjectToScreen(&v1)
        p2 := ProjectToScreen(&v2)
        p3 := ProjectToScreen(&v3)

        if IsFaceOutsideFrustum(p1, p2, p3) {
            continue
        }

        DrawFilledTriangle(&p1, &p2, &p3, shadedColor, zBuffer)
    }
}

DrawFilledTriangle :: proc(
    p1, p2, p3: ^Vector4,
    color: rl.Color,
    zBuffer: ^ZBuffer
) {
    Sort(p1, p2, p3)

    FloorXY(p1)
    FloorXY(p2)
    FloorXY(p3)

    // Draw flat-bottom triangle
    if p2.y != p1.y {
        invSlope1 := (p2.x - p1.x) / (p2.y - p1.y)
        invSlope2 := (p3.x - p1.x) / (p3.y - p1.y)

        for y := p1.y; y <= p2.y; y += 1 {
            xStart := p1.x + (y - p1.y) * invSlope1
            xEnd := p1.x + (y - p1.y) * invSlope2

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawPixel(x, y, p1, p2, p3, color, zBuffer)
            }
        }
    }

    // Draw flat-top triangle
    if p3.y != p1.y {
        invSlope1 := (p3.x - p2.x) / (p3.y - p2.y)
        invSlope2 := (p3.x - p1.x) / (p3.y - p1.y)

        for y := p2.y; y <= p3.y; y += 1 {
            xStart := p2.x + (y - p2.y) * invSlope1
            xEnd := p1.x + (y - p1.y) * invSlope2

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawPixel(x, y, p1, p2, p3, color, zBuffer)
            }
        }
    }
}

DrawPixel :: proc(
    x, y: f32, 
    p1, p2, p3: ^Vector4,
    color: rl.Color,
    zBuffer: ^ZBuffer
) {
    x := i32(x)
    y := i32(y)

    if IsPointOutsideViewport(x,y) {
        return
    }

    interpolatedReciprocalW := (1.0 / p1.w) + (1.0 / p2.w) + (1.0 / p3.w)

    depth := - (1.0 / interpolatedReciprocalW)
    zBufferIndex := (SCREEN_WIDTH * y) + x
    
    if (depth < zBuffer[zBufferIndex]) {
        rl.DrawPixel(x, y, color)
        zBuffer[zBufferIndex] = depth
    }
}

DrawTexturedUnlit :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    uvs: []Vector2, 
    texture: Texture, 
    zBuffer: ^ZBuffer
) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        uv1 := uvs[tri[3]]
        uv2 := uvs[tri[4]]
        uv3 := uvs[tri[5]]

        if IsBackFace(v1, v2, v3) {
            continue
        }

        p1 := ProjectToScreen(&v1)
        p2 := ProjectToScreen(&v2)
        p3 := ProjectToScreen(&v3)

        if (IsFaceOutsideFrustum(p1, p2, p3)) {
            continue
        }

        DrawTexturedTriangleFlatShaded(
            &p1, &p2, &p3,
            &uv1, &uv2, &uv3,
            texture, 
            1.0, // Unlit
            zBuffer
        )
    }
}

DrawTexturedFlatShaded :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    uvs: []Vector2, 
    light: Light, 
    texture: Texture, 
    zBuffer: ^ZBuffer, 
    ambient:f32 = 0.2
) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        uv1 := uvs[tri[3]]
        uv2 := uvs[tri[4]]
        uv3 := uvs[tri[5]]

        cross := Vector3CrossProduct(v2 - v1, v3 - v1)
        crossNorm := Vector3Normalize(cross)

        toCamera := Vector3Normalize(v1)
    
        if (Vector3DotProduct(crossNorm, toCamera) >= 0.0) {
            continue
        }

        intensity := Vector3DotProduct(crossNorm, light.direction)
        intensity = math.clamp(intensity, 0.0, 1.0)
        intensity = math.clamp(ambient + intensity * light.strength, 0.0, 1.0)

        p1 := ProjectToScreen(&v1)
        p2 := ProjectToScreen(&v2)
        p3 := ProjectToScreen(&v3)

        if (IsFaceOutsideFrustum(p1, p2, p3)) {
            continue
        }

        DrawTexturedTriangleFlatShaded(
            &p1, &p2, &p3,
            &uv1, &uv2, &uv3,
            texture,
            intensity,
            zBuffer
        )
    }
}

DrawTexturedTriangleFlatShaded :: proc(
    p1, p2, p3: ^Vector4,
    uv1, uv2, uv3: ^Vector2,
    texture: Texture,
    intensity: f32,
    zBuffer: ^ZBuffer
) {
    Sort(p1, p2, p3, uv1, uv2, uv3)

    FloorXY(p1)
    FloorXY(p2)
    FloorXY(p3)

    // Draw flat-bottom triangle
    if p2.y != p1.y {
        invSlope1 := (p2.x - p1.x) / (p2.y - p1.y)
        invSlope2 := (p3.x - p1.x) / (p3.y - p1.y)

        for y := p1.y; y <= p2.y; y += 1 {
            xStart := p1.x + (y - p1.y) * invSlope1
            xEnd := p1.x + (y - p1.y) * invSlope2

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawTexelFlatShaded(
                    x, y, 
                    p1, p2, p3, 
                    uv1, uv2, uv3, 
                    texture, intensity, zBuffer
                )
            }
        }
    }

    // Draw flat-top triangle
    if p3.y != p1.y {
        invSlope1 := (p3.x - p2.x) / (p3.y - p2.y)
        invSlope2 := (p3.x - p1.x) / (p3.y - p1.y)

        for y := p2.y; y <= p3.y; y += 1 {
            xStart := p2.x + (y - p2.y) * invSlope1
            xEnd := p1.x + (y - p1.y) * invSlope2

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawTexelFlatShaded(
                    x, y,
                    p1, p2, p3, 
                    uv1, uv2, uv3, 
                    texture, intensity, zBuffer
                )
            }
        }
    }
}

DrawTexelFlatShaded :: proc(
    x, y: f32,
    p1, p2, p3: ^Vector4,
    uv1, uv2, uv3: ^Vector2,
    texture: Texture,
    intensity: f32,
    zBuffer: ^ZBuffer
) {
    p := Vector2{x, y}
    a := p1.xy
    b := p2.xy
    c := p3.xy

    x := i32(x)
    y := i32(y)

    if IsPointOutsideViewport(x,y) {
        return
    }

    weights := BarycentricWeights(a, b, c, p)

    alpha := weights.x
    beta := weights.y
    gamma := weights.z

    interpolatedU := (uv1.x / p1.w) * alpha + (uv2.x / p2.w) * beta + (uv3.x / p3.w) * gamma
    interpolatedV := (uv1.y / p1.w) * alpha + (uv2.y / p2.w) * beta + (uv3.y / p3.w) * gamma

    interpolatedReciprocalW := (1.0 / p1.w) * alpha + (1.0 / p2.w) * beta + (1.0 / p3.w) * gamma

    if interpolatedReciprocalW == 0.0 {
        return
    }

    interpolatedU /= interpolatedReciprocalW
    interpolatedV /= interpolatedReciprocalW

    depth := - (1.0 / interpolatedReciprocalW)
    zBufferIndex := (SCREEN_WIDTH * y) + x
    
    if (depth < zBuffer[zBufferIndex]) {
        texX := (i32(interpolatedU * f32(texture.width)) % texture.width + texture.width) % texture.width
        texY := (i32(interpolatedV * f32(texture.height)) % texture.height + texture.height) % texture.height
    
        color := texture.pixels[texY * texture.width + texX]
    
        shadedColor := rl.Color{
            u8(f32(color.r) * intensity),
            u8(f32(color.g) * intensity),
            u8(f32(color.b) * intensity),
            color.a
        }

        rl.DrawPixel(x, y, shadedColor)

        zBuffer[zBufferIndex] = depth
    }
}

DrawPhongShaded :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    normals: []Vector3, 
    light: Light, 
    color: rl.Color, 
    zBuffer: ^ZBuffer, 
    ambient: f32 = 0.1
) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]
 
        n1 := normals[tri[6]]
        n2 := normals[tri[7]]
        n3 := normals[tri[8]]
 
        if IsBackFace(v1, v2, v3) {
            continue
        }
 
        p1 := ProjectToScreen(&v1)
        p2 := ProjectToScreen(&v2)
        p3 := ProjectToScreen(&v3)
 
        if IsFaceOutsideFrustum(p1, p2, p3) {
            continue
        }
 
        DrawTrianglePhongShaded(
            &v1, &v2, &v3, 
            &p1, &p2, &p3,
            &n1, &n2, &n3,
            color, light, ambient, zBuffer
        )
    }
}
 
DrawTrianglePhongShaded :: proc(
    v1, v2, v3: ^Vector3,
    p1, p2, p3: ^Vector4,
    n1, n2, n3: ^Vector3,
    color: rl.Color,
    light: Light,
    ambient: f32,
    zBuffer: ^ZBuffer
) {
    Sort(p1, p2, p3, v1, v2, v3)

    FloorXY(p1)
    FloorXY(p2)
    FloorXY(p3)

    // Draw flat-bottom triangle
    if p2.y != p1.y {
        invSlope1 := (p2.x - p1.x) / (p2.y - p1.y)
        invSlope2 := (p3.x - p1.x) / (p3.y - p1.y)

        for y := p1.y; y <= p2.y; y += 1 {
            xStart := p1.x + (y - p1.y) * invSlope1
            xEnd := p1.x + (y - p1.y) * invSlope2

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawPixelPhongShaded(
                    x, y,
                    v1, v2, v3, 
                    n1, n2, n3,
                    p1, p2, p3,
                    color, light, ambient, zBuffer
                )
            }
        }
    }

    // Draw flat-top triangle
    if p3.y != p1.y {
        invSlope1 := (p3.x - p2.x) / (p3.y - p2.y)
        invSlope2 := (p3.x - p1.x) / (p3.y - p1.y)

        for y := p2.y; y <= p3.y; y += 1 {
            xStart := p2.x + (y - p2.y) * invSlope1
            xEnd := p1.x + (y - p1.y) * invSlope2

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawPixelPhongShaded(
                    x, y,
                    v1, v2, v3, 
                    n1, n2, n3,
                    p1, p2, p3,
                    color, light, ambient, zBuffer
                )
            }
        }
    }
}

DrawPixelPhongShaded :: proc(
    x, y: f32,
    v1, v2, v3: ^Vector3,
    n1, n2, n3: ^Vector3,
    p1, p2, p3: ^Vector4,
    color: rl.Color,
    light: Light,
    ambient: f32,
    zBuffer: ^ZBuffer
) {
    p := Vector2{x, y}
    a := p1.xy
    b := p2.xy
    c := p3.xy

    x := i32(x)
    y := i32(y)

    if IsPointOutsideViewport(x, y) {
        return
    }

    weights := BarycentricWeights(a, b, c, p)
    alpha := weights.x
    beta  := weights.y
    gamma := weights.z

    denominator := (alpha / p1.w) + (beta / p2.w) + (gamma / p3.w)
    if denominator == 0.0 {
        return
    }

    depth := -(1.0 / denominator)
    zIndex := (SCREEN_WIDTH * y) + x
    if depth < zBuffer[zIndex] {
        interpNormal := Vector3Normalize(n1^ * alpha + n2^ *beta + n3^ *gamma)

        position := ((v1^ * (alpha / p1.w)) + (v2^ * (beta  / p2.w)) + (v3^ * (gamma / p3.w)) ) / denominator

        lightVec := Vector3Normalize(light.position - position)
        diffuse := math.clamp(Vector3DotProduct(interpNormal, lightVec), 0.0, 1.0)

        intensity := ambient + diffuse * light.strength
        intensity = math.clamp(intensity, 0.0, 1.0)

        shadedColor := rl.Color{
            u8(f32(color.r) * intensity),
            u8(f32(color.g) * intensity),
            u8(f32(color.b) * intensity),
            color.a,
        }

        rl.DrawPixel(x, y, shadedColor)
        zBuffer[zIndex] = depth
    }
}

DrawTexturedPhongShaded :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    uvs: []Vector2, 
    normals: []Vector3, 
    light: Light, 
    texture: Texture, 
    zBuffer: ^ZBuffer, 
    ambient: f32 = 0.1
) {
    for &tri in triangles { 
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]
 
        uv1 := uvs[tri[3]]
        uv2 := uvs[tri[4]]
        uv3 := uvs[tri[5]]
 
        n1 := normals[tri[6]]
        n2 := normals[tri[7]]
        n3 := normals[tri[8]]
 
        if IsBackFace(v1, v2, v3) {
            continue
        }
 
        p1 := ProjectToScreen(&v1)
        p2 := ProjectToScreen(&v2)
        p3 := ProjectToScreen(&v3)
 
        if IsFaceOutsideFrustum(p1, p2, p3) {
            continue
        }
 
        DrawTexturedTrianglePhongShaded(
            &v1, &v2, &v3, 
            &p1, &p2, &p3,
            &uv1, &uv2, &uv3,
            &n1, &n2, &n3,
            texture, light, ambient, zBuffer
        )
    }
}
 
DrawTexturedTrianglePhongShaded :: proc(
    v1, v2, v3: ^Vector3,
    p1, p2, p3: ^Vector4,
    uv1, uv2, uv3: ^Vector2,
    n1, n2, n3: ^Vector3,
    texture: Texture,
    light: Light,
    ambient: f32,
    zBuffer: ^ZBuffer
) { 
    Sort(p1, p2, p3, uv1, uv2, uv3, v1, v2, v3)

    FloorXY(p1)
    FloorXY(p2)
    FloorXY(p3)

    // Draw flat-bottom triangle
    if p2.y != p1.y {
        invSlope1 := (p2.x - p1.x) / (p2.y - p1.y)
        invSlope2 := (p3.x - p1.x) / (p3.y - p1.y)

        for y := p1.y; y <= p2.y; y += 1 {
            xStart := p1.x + (y - p1.y) * invSlope1
            xEnd := p1.x + (y - p1.y) * invSlope2

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawTexelPhongShaded(
                    x, y,
                    v1, v2, v3, 
                    n1, n2, n3, 
                    p1, p2, p3, 
                    uv1, uv2, uv3, 
                    texture, light, ambient, zBuffer
                )
            }
        }
    }

    // Draw flat-top triangle
    if p3.y != p1.y {
        invSlope1 := (p3.x - p2.x) / (p3.y - p2.y)
        invSlope2 := (p3.x - p1.x) / (p3.y - p1.y)

        for y := p2.y; y <= p3.y; y += 1 {
            xStart := p2.x + (y - p2.y) * invSlope1
            xEnd := p1.x + (y - p1.y) * invSlope2

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawTexelPhongShaded(
                    x, y,
                    v1, v2, v3, 
                    n1, n2, n3, 
                    p1, p2, p3, 
                    uv1, uv2, uv3, 
                    texture, light, ambient, zBuffer
                )
            }
        }
    }
}

DrawTexelPhongShaded :: proc(
    x, y: f32,
    v1, v2, v3: ^Vector3,
    n1, n2, n3: ^Vector3,
    p1, p2, p3: ^Vector4,
    uv1, uv2, uv3: ^Vector2,
    texture: Texture,
    light: Light,
    ambient: f32,
    zBuffer: ^ZBuffer
) {
    p := Vector2{x, y}
    a := p1.xy
    b := p2.xy
    c := p3.xy

    x := i32(x)
    y := i32(y)

    if IsPointOutsideViewport(x, y) {
        return
    }

    weights := BarycentricWeights(a, b, c, p)
    alpha := weights.x
    beta  := weights.y
    gamma := weights.z

    denominator := (alpha / p1.w) + (beta / p2.w) + (gamma / p3.w)
    if denominator == 0.0 {
        return
    }

    depth := -(1.0 / denominator)
    zIndex := (SCREEN_WIDTH * y) + x
    if depth < zBuffer[zIndex] {
        interpU := ((uv1.x / p1.w) * alpha + (uv2.x / p2.w) * beta + (uv3.x / p3.w)*gamma) / denominator
        interpV := ((uv1.y / p1.w) * alpha + (uv2.y / p2.w) * beta + (uv3.y / p3.w)*gamma) / denominator

        interpNormal := Vector3Normalize(n1^ * alpha + n2^ * beta + n3^ *gamma)

        position := ((v1^ * (alpha / p1.w)) + (v2^ * (beta  / p2.w)) +(v3^ * (gamma / p3.w))) / denominator

        lightVec := Vector3Normalize(light.position - position)
        diffuse := math.clamp(Vector3DotProduct(interpNormal, lightVec), 0.0, 1.0)

        intensity := ambient + diffuse * light.strength
        intensity = math.clamp(intensity, 0.0, 1.0)

        texX := (i32(interpU * f32(texture.width))  % texture.width  + texture.width ) % texture.width
        texY := (i32(interpV * f32(texture.height)) % texture.height + texture.height) % texture.height
        color := texture.pixels[texY * texture.width + texX]

        shadedColor := rl.Color{
            u8(f32(color.r) * intensity),
            u8(f32(color.g) * intensity),
            u8(f32(color.b) * intensity),
            color.a,
        }

        rl.DrawPixel(i32(x), i32(y), shadedColor)
        zBuffer[zIndex] = depth
    }
}

BarycentricWeights :: proc(a, b, c, p: Vector2) -> Vector3 {
    ac := c - a 
    ab := b - a
    ap := p - a
    pc := c - p
    pb := b - p

    area := (ac.x * ab.y - ac.y * ab.x)

    if area == 0.0 {
        return Vector3{0.0, 0.0, 0.0}
    }

    alpha := (pc.x * pb.y - pc.y * pb.x) / area
    beta := (ac.x * ap.y - ac.y * ap.x) / area
    gamma := 1.0 - alpha - beta

    return Vector3{alpha, beta, gamma}
}

ProjectToScreen :: proc(point: ^Vector3) -> Vector4 {
    fovRad := math.to_radians_f32(FOV)
    f := 1.0 / math.tan_f32(fovRad / 2.0)
    
    if point.z == 0.0 {
        point.z = 0.0001
    }

    projectedX := (point.x * (f / ASPECT)) / point.z
    projectedY := (point.y * f) / point.z

    screenX := (projectedX * 0.5 + 0.5) * SCREEN_WIDTH
    screenY := (-projectedY * 0.5 + 0.5) * SCREEN_HEIGHT

    return Vector4{screenX, screenY, point.z, point.z}
}

IsBackFace :: proc(v1, v2, v3: Vector3) -> bool {
    edge1 := v2 - v1
    edge2 := v3 - v1

    cross := Vector3CrossProduct(edge1, edge2)
    crossNorm := Vector3Normalize(cross)
    toCamera := Vector3Normalize(v1)
    
    return Vector3DotProduct(crossNorm, toCamera) >= 0.0 
}

IsFaceOutsideFrustum :: proc(p1, p2, p3: Vector4) -> bool {
    if (p1.z > -NEAR_PLANE && p2.z > -NEAR_PLANE && p3.z > -NEAR_PLANE) || 
       (p1.z < -FAR_PLANE  && p2.z < -FAR_PLANE  && p3.z < -FAR_PLANE) {
        return true
    }

    minX := math.min(p1.x, math.min(p2.x, p3.x))
    maxX := math.max(p1.x, math.max(p2.x, p3.x))
    minY := math.min(p1.y, math.min(p2.y, p3.y))
    maxY := math.max(p1.y, math.max(p2.y, p3.y))

    if maxX < 0 || minX > SCREEN_WIDTH || maxY < 0 || minY > SCREEN_HEIGHT {
        return true
    }

    return false
}

IsPointOutsideViewport :: proc(x, y: i32) -> bool {
    return x < 0 || x >= SCREEN_WIDTH || y < 0 || y >= SCREEN_HEIGHT
}