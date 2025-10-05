package main

import "core:math"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

DrawWireframe :: proc(
    verticesWorld: []Vector3,
    verticesModel: []Vector3,
    triangles: []Triangle, 
    color: rl.Color,
    image: ^rl.Image, 
    projMat: Matrix4x4,
    projType: ProjectionType,
    drawCoords: bool,
    cullBackFace: bool = true
) {
    for &tri in triangles {
        v1 := verticesWorld[tri[0]]
        v2 := verticesWorld[tri[1]]
        v3 := verticesWorld[tri[2]]

        if cullBackFace && IsBackFace(projType, v1, v2, v3) {
            continue
        }

        p1 := ProjectToScreen(projType, projMat, v1)
        p2 := ProjectToScreen(projType, projMat, v2)
        p3 := ProjectToScreen(projType, projMat, v3)

        if (IsFaceOutsideFrustum(p1, p2, p3)) {
            continue
        }

        DrawLine({p1.x, p1.y}, {p2.x, p2.y}, color, image)
        DrawLine({p2.x, p2.y}, {p3.x, p3.y}, color, image)
        DrawLine({p3.x, p3.y}, {p1.x, p1.y}, color, image)

        if (drawCoords) {
            
            vm1 := verticesModel[tri[0]]
            vm2 := verticesModel[tri[1]]
            vm3 := verticesModel[tri[2]]

            DrawCoords(v1, vm1, {p1.x, p1.y}, image)
            DrawCoords(v2, vm2, {p2.x, p2.y}, image)
            DrawCoords(v3, vm3, {p3.x, p3.y}, image)
        }
    }
}

DrawCoords :: proc(v: Vector3, vm: Vector3, p: Vector2, image: ^rl.Image) {
    buf: [32]byte
    bitSize := 64
    precision := 2

    // Model Space
    str := strings.concatenate({
        "[",
        strings.clone(strconv.ftoa(buf[:], f64(vm.x), 'f', precision, bitSize)),
        ",",
        strings.clone(strconv.ftoa(buf[:], f64(vm.y), 'f', precision, bitSize)),
        ",",
        strings.clone(strconv.ftoa(buf[:], f64(vm.z), 'f', precision, bitSize)),
        "]"
    })
    rl.ImageDrawText(image, strings.clone_to_cstring(str), i32(p.x), i32(p.y), 10, rl.BLUE)

    // World Space
    str = strings.concatenate({
        "[",
        strings.clone(strconv.ftoa(buf[:], f64(v.x), 'f', precision, bitSize)),
        ",",
        strings.clone(strconv.ftoa(buf[:], f64(v.y), 'f', precision, bitSize)),
        ",",
        strings.clone(strconv.ftoa(buf[:], f64(v.z), 'f', precision, bitSize)),
        "]"
    })
    rl.ImageDrawText(image, strings.clone_to_cstring(str), i32(p.x), i32(p.y + 10), 10, rl.YELLOW)

    // Screen Space
    precision = 0
    str = strings.concatenate({
        "[",
        strings.clone(strconv.ftoa(buf[:], f64(p.x), 'f', precision, bitSize)),
        ",",
        strings.clone(strconv.ftoa(buf[:], f64(p.y), 'f', precision, bitSize)),
        "]"
    })
    rl.ImageDrawText(image, strings.clone_to_cstring(str), i32(p.x), i32(p.y + 20), 10, rl.GREEN)
}

DrawLine :: proc(a, b: Vector2, color: rl.Color, image: ^rl.Image) {
    dX := b.x - a.x
    dY := b.y - a.y

    longerDelta := math.abs(dX) >= math.abs(dY) ? math.abs(dX) : math.abs(dY)

    incX := dX / longerDelta
    incY := dY / longerDelta

    x := a.x
    y := a.y

    for i := 0; i <= int(longerDelta); i += 1 {
        rl.ImageDrawPixel(image, i32(x), i32(y), color)
        x += incX
        y += incY
    }
}

DrawUnlit :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    color: rl.Color, 
    zBuffer: ^ZBuffer,
    image: ^rl.Image,
    projMat: Matrix4x4,
    projType: ProjectionType,
) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        if IsBackFace(projType, v1, v2, v3) {
            continue
        }

        p1 := ProjectToScreen(projType, projMat, v1)
        p2 := ProjectToScreen(projType, projMat, v2)
        p3 := ProjectToScreen(projType, projMat, v3)

        if IsFaceOutsideFrustum(p1, p2, p3) {
            continue
        }

        DrawFilledTriangle(&p1, &p2, &p3, color, zBuffer, image)
    }
}

DrawFlatShaded :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    lights: []Light, 
    baseColor: rl.Color, 
    zBuffer: ^ZBuffer, 
    image: ^rl.Image,
    projMat: Matrix4x4,
    projType: ProjectionType,
    ambient:f32 = 0.2
) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        cross := Vector3CrossProduct(v2 - v1, v3 - v1)
        crossNorm := Vector3Normalize(cross)

        toCamera: Vector3
        switch projType {
            case .Perspective: toCamera = Vector3Normalize(v1)
            case .Orthographic: toCamera = Vector3{0, 0, -1}
        }
    
        if (Vector3DotProduct(crossNorm, toCamera) >= 0.0) {
            continue
        }

        p1 := ProjectToScreen(projType, projMat, v1)
        p2 := ProjectToScreen(projType, projMat, v2)
        p3 := ProjectToScreen(projType, projMat, v3)

        if IsFaceOutsideFrustum(p1, p2, p3) {
            continue
        }
        
        intensity: f32 = ambient
        for &light in lights {
            intensity += math.max(0.0, Vector3DotProduct(crossNorm, light.direction))
        }
        intensity = math.min(intensity, 1.0)

        shadedColor := rl.Color{
            u8(f32(baseColor.r) * intensity),
            u8(f32(baseColor.g) * intensity),
            u8(f32(baseColor.b) * intensity),
            baseColor.a
        }

        DrawFilledTriangle(&p1, &p2, &p3, shadedColor, zBuffer, image)
    }
}

DrawFilledTriangle :: proc(
    p1, p2, p3: ^Vector3,
    color: rl.Color,
    zBuffer: ^ZBuffer,
    image: ^rl.Image
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
                DrawPixel(x, y, p1, p2, p3, color, zBuffer, image)
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
                DrawPixel(x, y, p1, p2, p3, color, zBuffer, image)
            }
        }
    }
}

DrawPixel :: proc(
    x, y: f32, 
    p1, p2, p3: ^Vector3,
    color: rl.Color,
    zBuffer: ^ZBuffer,
    image: ^rl.Image
) {
    ix := i32(x)
    iy := i32(y)
    if IsPointOutsideViewport(ix, iy) {
        return
    }

    p       := Vector2{x, y}
    weights := BarycentricWeights(p1.xy, p2.xy, p3.xy, p)
    alpha   := weights.x
    beta    := weights.y
    gamma   := weights.z

    denom  := alpha*p1.z + beta*p2.z + gamma*p3.z
    depth := 1.0 / denom

    zIndex := SCREEN_WIDTH*iy + ix
    if (depth < zBuffer[zIndex]) {
        rl.ImageDrawPixel(image, ix, iy, color)
        zBuffer[zIndex] = depth
    }
}

DrawTexturedUnlit :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    uvs: []Vector2, 
    texture: Texture, 
    zBuffer: ^ZBuffer,
    image: ^rl.Image,
    projMat: Matrix4x4,
    projType: ProjectionType,
) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        uv1 := uvs[tri[3]]
        uv2 := uvs[tri[4]]
        uv3 := uvs[tri[5]]

        if IsBackFace(projType, v1, v2, v3) {
            continue
        }

        p1 := ProjectToScreen(projType, projMat, v1)
        p2 := ProjectToScreen(projType, projMat, v2)
        p3 := ProjectToScreen(projType, projMat, v3)

        if (IsFaceOutsideFrustum(p1, p2, p3)) {
            continue
        }

        DrawTexturedTriangleFlatShaded(
            &p1, &p2, &p3,
            &uv1, &uv2, &uv3,
            texture, 
            1.0, // Unlit
            zBuffer,
            image
        )
    }
}

DrawTexturedFlatShaded :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    uvs: []Vector2, 
    lights: []Light, 
    texture: Texture, 
    zBuffer: ^ZBuffer,
    image: ^rl.Image,
    projMat: Matrix4x4,
    projType: ProjectionType,
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

        toCamera: Vector3
        switch projType {
            case .Perspective: toCamera = Vector3Normalize(v1)
            case .Orthographic: toCamera = Vector3{0, 0, -1}
        }
    
        if (Vector3DotProduct(crossNorm, toCamera) >= 0.0) {
            continue
        }

        p1 := ProjectToScreen(projType, projMat, v1)
        p2 := ProjectToScreen(projType, projMat, v2)
        p3 := ProjectToScreen(projType, projMat, v3)

        if (IsFaceOutsideFrustum(p1, p2, p3)) {
            continue
        }
        
        intensity: f32 = ambient
        for &light in lights {
            intensity += math.max(0.0, Vector3DotProduct(crossNorm, light.direction))
        }
        intensity = math.min(intensity, 1.0)

        DrawTexturedTriangleFlatShaded(
            &p1, &p2, &p3,
            &uv1, &uv2, &uv3,
            texture,
            intensity,
            zBuffer,
            image
        )
    }
}

DrawTexturedTriangleFlatShaded :: proc(
    p1, p2, p3: ^Vector3,
    uv1, uv2, uv3: ^Vector2,
    texture: Texture,
    intensity: f32,
    zBuffer: ^ZBuffer,
    image: ^rl.Image
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
                    texture, intensity, zBuffer, image
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
                    texture, intensity, zBuffer, image
                )
            }
        }
    }
}

DrawTexelFlatShaded :: proc(
    x, y: f32,
    p1, p2, p3: ^Vector3,
    uv1, uv2, uv3: ^Vector2,
    texture: Texture,
    intensity: f32,
    zBuffer: ^ZBuffer,
    image: ^rl.Image
) {
    ix := i32(x)
    iy := i32(y)
    if IsPointOutsideViewport(ix, iy) {
        return
    }

    p       := Vector2{x, y}
    weights := BarycentricWeights(p1.xy, p2.xy, p3.xy, p)
    alpha   := weights.x
    beta    := weights.y
    gamma   := weights.z

    denom  := alpha*p1.z + beta*p2.z + gamma*p3.z
    depth := 1.0 / denom

    zIndex := SCREEN_WIDTH*iy + ix
    if depth <= zBuffer[zIndex] {
        
        interpU := ((uv1.x*p1.z)*alpha + (uv2.x*p2.z)*beta + (uv3.x*p3.z)*gamma) * depth
        interpV := ((uv1.y*p1.z)*alpha + (uv2.y*p2.z)*beta + (uv3.y*p3.z)*gamma) * depth

        texX := i32(interpU * f32(texture.width )) & (texture.width  - 1)
        texY := i32(interpV * f32(texture.height)) & (texture.height - 1)
        tex  := texture.pixels[texY*texture.width + texX]
    
        shadedTex := rl.Color{
            u8(f32(tex.r) * intensity),
            u8(f32(tex.g) * intensity),
            u8(f32(tex.b) * intensity),
            tex.a,
        }

        rl.ImageDrawPixel(image, i32(x), i32(y), shadedTex)
        zBuffer[zIndex] = depth
    }
}

DrawPhongShaded :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    normals: []Vector3, 
    lights: []Light, 
    color: rl.Color, 
    zBuffer: ^ZBuffer, 
    image: ^rl.Image,
    projMat: Matrix4x4,
    projType: ProjectionType,
    ambient: f32 = 0.1
) {
    for &tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]
 
        n1 := normals[tri[6]]
        n2 := normals[tri[7]]
        n3 := normals[tri[8]]
 
        if IsBackFace(projType, v1, v2, v3) {
            continue
        }
 
        p1 := ProjectToScreen(projType, projMat, v1)
        p2 := ProjectToScreen(projType, projMat, v2)
        p3 := ProjectToScreen(projType, projMat, v3)
 
        if IsFaceOutsideFrustum(p1, p2, p3) {
            continue
        }
 
        DrawTrianglePhongShaded(
            &v1, &v2, &v3, 
            &p1, &p2, &p3,
            &n1, &n2, &n3,
            color, lights, ambient, zBuffer, image
        )
    }
}
 
DrawTrianglePhongShaded :: proc(
    v1, v2, v3: ^Vector3,
    p1, p2, p3: ^Vector3,
    n1, n2, n3: ^Vector3,
    color: rl.Color,
    lights: []Light,
    ambient: f32,
    zBuffer: ^ZBuffer,
    image: ^rl.Image
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
                    color, lights, ambient, zBuffer, image
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
                    color, lights, ambient, zBuffer, image
                )
            }
        }
    }
}

DrawPixelPhongShaded :: proc(
    x, y: f32,
    v1, v2, v3: ^Vector3,
    n1, n2, n3: ^Vector3,
    p1, p2, p3: ^Vector3,
    color: rl.Color,
    lights: []Light,
    ambient: f32,
    zBuffer: ^ZBuffer,
    image: ^rl.Image
) {
    ix := i32(x)
    iy := i32(y)
    if IsPointOutsideViewport(ix, iy) {
        return
    }

    p       := Vector2{x, y}
    weights := BarycentricWeights(p1.xy, p2.xy, p3.xy, p)
    alpha   := weights.x
    beta    := weights.y
    gamma   := weights.z

    denom  := alpha*p1.z + beta*p2.z + gamma*p3.z
    depth := 1.0 / denom

    zIndex := SCREEN_WIDTH*iy + ix
    if depth <= zBuffer[zIndex] {
        interpNormal := Vector3Normalize(n1^ * alpha + n2^ * beta + n3^ * gamma)
        interpPos    := ((v1^*p1.z) * alpha + (v2^*p2.z) * beta + (v3^*p3.z) * gamma) * depth

        intensity: f32 = ambient
        for &light in lights {
            lightVec := Vector3Normalize(light.position - interpPos)
            diffuse  := math.max(Vector3DotProduct(interpNormal, lightVec), 0.0)
            intensity += diffuse * light.strength
        }
        intensity = math.min(intensity, 1.0)

        shadedColor := rl.Color{
            u8(f32(color.r) * intensity),
            u8(f32(color.g) * intensity),
            u8(f32(color.b) * intensity),
            color.a,
        }

        rl.ImageDrawPixel(image, ix, iy, shadedColor)
        zBuffer[zIndex] = depth
    }
}

DrawTexturedPhongShaded :: proc(
    vertices: []Vector3, 
    triangles: []Triangle, 
    uvs: []Vector2, 
    normals: []Vector3, 
    lights: []Light,
    texture: Texture, 
    zBuffer: ^ZBuffer,
    image: ^rl.Image,
    projMat: Matrix4x4,
    projType: ProjectionType,
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
 
        if IsBackFace(projType, v1, v2, v3) {
            continue
        }
 
        p1 := ProjectToScreen(projType, projMat, v1)
        p2 := ProjectToScreen(projType, projMat, v2)
        p3 := ProjectToScreen(projType, projMat, v3)
 
        if IsFaceOutsideFrustum(p1, p2, p3) {
            continue
        }
 
        DrawTexturedTrianglePhongShaded(
            &v1, &v2, &v3, 
            &p1, &p2, &p3,
            &uv1, &uv2, &uv3,
            &n1, &n2, &n3,
            texture, lights, ambient, zBuffer, image
        )
    }
}
 
DrawTexturedTrianglePhongShaded :: proc(
    v1, v2, v3: ^Vector3,
    p1, p2, p3: ^Vector3,
    uv1, uv2, uv3: ^Vector2,
    n1, n2, n3: ^Vector3,
    texture: Texture,
    lights: []Light,
    ambient: f32,
    zBuffer: ^ZBuffer,
    image: ^rl.Image
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
                    texture, lights, ambient, zBuffer, image
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
                    texture, lights, ambient, zBuffer, image
                )
            }
        }
    }
}

DrawTexelPhongShaded :: proc(
    x, y: f32,
    v1, v2, v3: ^Vector3,
    n1, n2, n3: ^Vector3,
    p1, p2, p3: ^Vector3,
    uv1, uv2, uv3: ^Vector2,
    texture: Texture,
    lights: []Light,
    ambient: f32,
    zBuffer: ^ZBuffer,
    image: ^rl.Image
) {
    ix := i32(x)
    iy := i32(y)
    if IsPointOutsideViewport(ix, iy) {
        return
    }

    p       := Vector2{x, y}
    weights := BarycentricWeights(p1.xy, p2.xy, p3.xy, p)
    alpha   := weights.x
    beta    := weights.y
    gamma   := weights.z

    denom  := alpha*p1.z + beta*p2.z + gamma*p3.z
    depth := 1.0 / denom

    zIndex := SCREEN_WIDTH*iy + ix
    if depth <= zBuffer[zIndex] {
        interpU := ((uv1.x*p1.z)*alpha + (uv2.x*p2.z)*beta + (uv3.x*p3.z)*gamma) * depth
        interpV := ((uv1.y*p1.z)*alpha + (uv2.y*p2.z)*beta + (uv3.y*p3.z)*gamma) * depth

        interpPos := ((v1^*p1.z)*alpha + (v2^*p2.z)*beta + (v3^*p3.z)*gamma) * depth

        interpNormal := Vector3Normalize(n1^*alpha + n2^*beta + n3^*gamma)

        intensity: f32 = ambient
        for &light in lights {
            lightVec := Vector3Normalize(light.position - interpPos)
            diffuse  := math.max(Vector3DotProduct(interpNormal, lightVec), 0.0)
            intensity += diffuse * light.strength
        }
        intensity = math.min(intensity, 1.0)

        texX := i32(interpU * f32(texture.width )) & (texture.width  - 1)
        texY := i32(interpV * f32(texture.height)) & (texture.height - 1)
        tex  := texture.pixels[texY*texture.width + texX]

        shadedTex := rl.Color{
            u8(f32(tex.r) * intensity),
            u8(f32(tex.g) * intensity),
            u8(f32(tex.b) * intensity),
            tex.a,
        }

        rl.ImageDrawPixel(image, ix, iy, shadedTex)
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

    alpha := (pc.x * pb.y - pc.y * pb.x) / area
    beta := (ac.x * ap.y - ac.y * ap.x) / area
    gamma := 1.0 - alpha - beta

    return Vector3{alpha, beta, gamma}
}

ProjectToScreen :: proc(projType: ProjectionType, mat: Matrix4x4, p: Vector3) -> Vector3 {
    clip := Mat4MulVec4(mat, Vector4{p.x, p.y, p.z, 1.0})

    invW : f32 = 1.0 / clip.w

    ndcX := clip.x * invW
    ndcY := clip.y * invW

    screenX := ( ndcX * 0.5 + 0.5 ) * SCREEN_WIDTH
    screenY := (-ndcY * 0.5 + 0.5 ) * SCREEN_HEIGHT

    switch projType {
        case .Perspective: return Vector3{screenX, screenY, invW}
        case .Orthographic: return Vector3{screenX, screenY, -clip.z}
    }

    return Vector3{}
}

IsBackFace :: proc(projType: ProjectionType, v1, v2, v3: Vector3) -> bool {
    edge1 := v2 - v1
    edge2 := v3 - v1

    cross := Vector3CrossProduct(edge1, edge2)
    crossNorm := Vector3Normalize(cross)

    toCamera: Vector3
    switch projType {
        case .Perspective: toCamera = Vector3Normalize(v1)
        case .Orthographic: toCamera = Vector3{0, 0, -1}
    }
    
    return Vector3DotProduct(crossNorm, toCamera) >= 0.0 
}

IsFaceOutsideFrustum :: proc(p1, p2, p3: Vector3) -> bool {
    if (p1.z > 1.0 || p2.z > 1.0 || p3.z > 1.0) ||
       (p1.z < -1.0 || p2.z < -1.0 || p3.z < -1.0) {
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
