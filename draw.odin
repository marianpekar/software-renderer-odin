package main

import "core:math"
import rl "vendor:raylib"

DrawWireframe :: proc(vertices: ^[]Vector3, triangles: ^[][9]int, color: rl.Color, cullBackFace: bool = true) {
    for tri in triangles {
        v1 := &vertices[tri[0]]
        v2 := &vertices[tri[1]]
        v3 := &vertices[tri[2]]

        if (cullBackFace && IsBackFace(v1, v2, v3)) {
            continue
        }

        p1 := ProjectToScreen(v1)
        p2 := ProjectToScreen(v2)
        p3 := ProjectToScreen(v3)

        if (IsFaceOutsideFrustum(&p1, &p2, &p3)) {
            continue
        }

        DrawLine(i32(p1.x), i32(p1.y), i32(p2.x), i32(p2.y), color)
        DrawLine(i32(p2.x), i32(p2.y), i32(p3.x), i32(p3.y), color)
        DrawLine(i32(p3.x), i32(p3.y), i32(p1.x), i32(p1.y), color)
    }
}

DrawLine :: proc(x1, y1, x2, y2: i32, color: rl.Color) {
    dX := f32(x2 - x1)
    dY := f32(y2 - y1)

    longerDelta := math.abs(dX) >= math.abs(dY) ? math.abs(dX) : math.abs(dY)

    incX := dX / longerDelta
    incY := dY / longerDelta

    x := f32(x1)
    y := f32(y1)

    for i := 0; i <= int(longerDelta); i += 1 {
        rl.DrawPixel(i32(x), i32(y), color)
        x += incX
        y += incY
    }
}

DrawUnlit :: proc(vertices: ^[]Vector3, triangles: ^[][9]int, color: rl.Color, zBuffer: ^ZBuffer) {
    for tri in triangles {
        v1 := &vertices[tri[0]]
        v2 := &vertices[tri[1]]
        v3 := &vertices[tri[2]]

        if (IsBackFace(v1, v2, v3)) {
            continue
        }

        p1 := ProjectToScreen(v1)
        p2 := ProjectToScreen(v2)
        p3 := ProjectToScreen(v3)

        if (IsFaceOutsideFrustum(&p1, &p2, &p3)) {
            continue
        }

        DrawFilledTriangle(
            i32(p1.x), i32(p1.y), p1.z, p1.w,
            i32(p2.x), i32(p2.y), p2.z, p2.w,
            i32(p3.x), i32(p3.y), p3.z, p3.w,
            color,
            zBuffer
        )
    }
}

DrawFlatShaded :: proc(vertices: ^[]Vector3, triangles: ^[][9]int, light: Light, baseColor: rl.Color, zBuffer: ^ZBuffer, ambient:f32 = 0.2) {
    for tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        edge1 := v2 - v1
        edge2 := v3 - v1
    
        normal := Vector3Normalize(Vector3CrossProduct(edge1, edge2))
        toCamera := Vector3Normalize(v1)
    
        if (Vector3DotProduct(normal, toCamera) >= 0.0) {
            continue
        }

        intensity := Vector3DotProduct(normal, light.direction)
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

        if (IsFaceOutsideFrustum(&p1, &p2, &p3)) {
            continue
        }

        DrawFilledTriangle(
            i32(p1.x), i32(p1.y), p1.z, p1.w,
            i32(p2.x), i32(p2.y), p2.z, p2.w,
            i32(p3.x), i32(p3.y), p3.z, p3.w,
            shadedColor,
            zBuffer
        )
    }
}

DrawFilledTriangle :: proc(
    x0, y0: i32, z0, w0: f32, 
    x1, y1: i32, z1, w1: f32,
    x2, y2: i32, z2, w2: f32,
    color: rl.Color,
    zBuffer: ^ZBuffer
) {
    x0_, y0_, z0_, w0_:= x0, y0, z0, w0
    x1_, y1_, z1_, w1_:= x1, y1, z1, w1
    x2_, y2_, z2_, w2_:= x2, y2, z2, w2

    // Sort vertices by y-coordinate (y0 <= y1 <= y2)
    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
        z0_, z1_ = z1_, z0_
        w0_, w1_ = w1_, w0_
    }
    if y1_ > y2_ {
        x1_, x2_ = x2_, x1_
        y1_, y2_ = y2_, y1_
        z1_, z2_ = z2_, z1_
        w1_, w2_ = w2_, w1_
    }
    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
        z0_, z1_ = z1_, z0_
        w0_, w1_ = w1_, w0_
    }

    pointA := Vector4{ f32(x0_), f32(y0_), z0_, w0_ }
    pointB := Vector4{ f32(x1_), f32(y1_), z1_, w1_ }
    pointC := Vector4{ f32(x2_), f32(y2_), z2_, w2_ }

    // Draw flat-bottom triangle
    if y1_ != y0_ {
        invSlope1 := f32(x1_ - x0_) / f32(y1_ - y0_)
        invSlope2 := f32(x2_ - x0_) / f32(y2_ - y0_)

        for y := y0_; y <= y1_; y += 1 {
            xStart := i32(f32(x0_) + f32(y - y0_) * invSlope1)
            xEnd := i32(f32(x0_) + f32(y - y0_) * invSlope2)

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawPixel(x, y, &pointA, &pointB, &pointC, color, zBuffer)
            }
        }
    }

    // Draw flat-top triangle
    if y2_ != y1_ {
        invSlope1 := f32(x2_ - x1_) / f32(y2_ - y1_)
        invSlope2 := f32(x2_ - x0_) / f32(y2_ - y0_)

        for y := y1_; y <= y2_; y += 1 {
            xStart := i32(f32(x1_) + f32(y - y1_) * invSlope1)
            xEnd := i32(f32(x0_) + f32(y - y0_) * invSlope2)

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawPixel(x, y, &pointA, &pointB, &pointC, color, zBuffer)
            }
        }
    }
}

DrawPhongShaded :: proc(vertices: ^[]Vector3, triangles: ^[][9]int, normals: ^[]Vector3, light: Light, color: rl.Color, zBuffer: ^ZBuffer, ambient: f32 = 0.1) {
    for i in 0..<len(triangles) {
        tri := triangles[i]
 
        v1 := &vertices[tri[0]]
        v2 := &vertices[tri[1]]
        v3 := &vertices[tri[2]]
 
        n1 := normals[tri[6]]
        n2 := normals[tri[7]]
        n3 := normals[tri[8]]
 
        if IsBackFace(v1, v2, v3) {
            continue
        }
 
        p1 := ProjectToScreen(v1)
        p2 := ProjectToScreen(v2)
        p3 := ProjectToScreen(v3)
 
        if IsFaceOutsideFrustum(&p1, &p2, &p3) {
            continue
        }
 
        DrawTrianglePhongShaded(
            v1^, v2^, v3^, 
            i32(p1.x), i32(p1.y), p1.z, p1.w, n1,
            i32(p2.x), i32(p2.y), p2.z, p2.w, n2,
            i32(p3.x), i32(p3.y), p3.z, p3.w, n3,
            color, light, ambient, zBuffer
        )
    }
}
 
DrawTrianglePhongShaded :: proc(
    p0, p1, p2: Vector3,
    x0, y0: i32, z0, w0: f32, n0: Vector3,
    x1, y1: i32, z1, w1: f32, n1: Vector3,
    x2, y2: i32, z2, w2: f32, n2: Vector3,
    color: rl.Color,
    light: Light,
    ambient: f32,
    zBuffer: ^ZBuffer
) {
    x0_, y0_, z0_, w0_, n0_, p0_ := x0, y0, z0, w0, n0, p0
    x1_, y1_, z1_, w1_, n1_, p1_ := x1, y1, z1, w1, n1, p1
    x2_, y2_, z2_, w2_, n2_, p2_ := x2, y2, z2, w2, n2, p2
 
    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
        z0_, z1_ = z1_, z0_
        w0_, w1_ = w1_, w0_
        n0_, n1_ = n1_, n0_
        p0_, p1_ = p1_, p0_
    }
    if y1_ > y2_ {
        x1_, x2_ = x2_, x1_
        y1_, y2_ = y2_, y1_
        z1_, z2_ = z2_, z1_
        w1_, w2_ = w2_, w1_
        n1_, n2_ = n2_, n1_
        p1_, p2_ = p2_, p1_
    }
    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
        z0_, z1_ = z1_, z0_
        w0_, w1_ = w1_, w0_
        n0_, n1_ = n1_, n0_
        p0_, p1_ = p1_, p0_
    }
 
    pointA := Vector4{ f32(x0_), f32(y0_), z0_, w0_ }
    pointB := Vector4{ f32(x1_), f32(y1_), z1_, w1_ }
    pointC := Vector4{ f32(x2_), f32(y2_), z2_, w2_ }
 
    // Draw flat-bottom triangle
    if y1_ != y0_ {
        invSlope1 := f32(x1_ - x0_) / f32(y1_ - y0_)
        invSlope2 := f32(x2_ - x0_) / f32(y2_ - y0_)
 
        for y := y0_; y <= y1_; y += 1 {
            xStart := i32(f32(x0_) + f32(y - y0_) * invSlope1)
            xEnd   := i32(f32(x0_) + f32(y - y0_) * invSlope2)
 
            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }
 
            for x := xStart; x <= xEnd; x += 1 {
                DrawPixelPhongShaded(
                    x, y, 
                    p0_, p1_, p2_, 
                    n0_, n1_, n2_, 
                    &pointA, &pointB, &pointC, 
                    color, light, ambient, zBuffer
                )
            }
        }
    }

    // Draw flat-top triangle
    if y2_ != y1_ {
        invSlope1 := f32(x2_ - x1_) / f32(y2_ - y1_)
        invSlope2 := f32(x2_ - x0_) / f32(y2_ - y0_)
 
        for y := y1_; y <= y2_; y += 1 {
            xStart := i32(f32(x1_) + f32(y - y1_) * invSlope1)
            xEnd   := i32(f32(x0_) + f32(y - y0_) * invSlope2)
 
            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }
 
            for x := xStart; x <= xEnd; x += 1 {
                DrawPixelPhongShaded(
                    x, y,
                    p0_, p1_, p2_, 
                    n0_, n1_, n2_,
                    &pointA, &pointB, &pointC,
                    color, light, ambient, zBuffer
                )
            }
        }
    }
}

DrawPixelPhongShaded :: proc(
    x, y: i32,
    p0, p1, p2: Vector3,
    n0, n1, n2: Vector3,
    pointA, pointB, pointC: ^Vector4,
    color: rl.Color,
    light: Light,
    ambient: f32,
    zBuffer: ^ZBuffer
) {
    if IsPointOutsideViewport(x, y) {
        return
    }

    p := Vector2{ f32(x), f32(y) }
    a := Vector2{ pointA.x, pointA.y }
    b := Vector2{ pointB.x, pointB.y }
    c := Vector2{ pointC.x, pointC.y }

    weights := BarycentricWeights(a, b, c, p)
    alpha := weights.x
    beta  := weights.y
    gamma := weights.z

    denominator := (alpha / pointA.w) + (beta / pointB.w) + (gamma / pointC.w)
    if denominator == 0.0 {
        return
    }

    depth := -(1.0 / denominator)
    zIndex := (SCREEN_WIDTH * y) + x
    if depth < zBuffer[zIndex] {
        interpNormal := Vector3Normalize(n0*alpha + n1*beta + n2*gamma)

        position := ((p0 * (alpha / pointA.w)) + (p1 * (beta  / pointB.w)) +(p2 * (gamma / pointC.w)) ) / denominator

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

DrawPixel :: proc(
    x, y: i32, 
    pointA, pointB, pointC: ^Vector4,
    color: rl.Color,
    zBuffer: ^ZBuffer
) {
    if IsPointOutsideViewport(x,y) {
        return
    }

    interpolatedReciprocalW := (1.0 / pointA.w) + (1.0 / pointB.w) + (1.0 / pointC.w)

    depth := - (1.0 / interpolatedReciprocalW)
    zBufferIndex := (SCREEN_WIDTH * y) + x
    
    if (depth < zBuffer[zBufferIndex]) {
        rl.DrawPixel(x, y, color)
        zBuffer[zBufferIndex] = depth
    }
}

DrawTexturedUnlit :: proc(vertices: ^[]Vector3, triangles: ^[][9]int, uvs: ^[]Vector2, texture: ^Texture, zBuffer: ^ZBuffer) {
    for i in 0..<len(triangles) {
        tri := triangles[i]

        v1 := &vertices[tri[0]]
        v2 := &vertices[tri[1]]
        v3 := &vertices[tri[2]]

        uv1 := &uvs[tri[3]]
        uv2 := &uvs[tri[4]]
        uv3 := &uvs[tri[5]]

        if IsBackFace(v1, v2, v3) {
            continue
        }

        p1 := ProjectToScreen(v1)
        p2 := ProjectToScreen(v2)
        p3 := ProjectToScreen(v3)

        if (IsFaceOutsideFrustum(&p1, &p2, &p3)) {
            continue
        }

        DrawTexturedTriangleFlatShaded(
            i32(p1.x), i32(p1.y), p1.z, p1.w, uv1.x, uv1.y,
            i32(p2.x), i32(p2.y), p2.z, p2.w, uv2.x, uv2.y,
            i32(p3.x), i32(p3.y), p3.z, p3.w, uv3.x, uv3.y,
            texture, 
            1.0, // Unlit
            zBuffer
        )
    }
}

DrawTexturedFlatShaded :: proc(vertices: ^[]Vector3, triangles: ^[][9]int, uvs: ^[]Vector2, light: Light, texture: ^Texture, zBuffer: ^ZBuffer, ambient:f32 = 0.2) {
    for i in 0..<len(triangles) {
        tri := triangles[i]

        v1 := &vertices[tri[0]]
        v2 := &vertices[tri[1]]
        v3 := &vertices[tri[2]]

        uv1 := &uvs[tri[3]]
        uv2 := &uvs[tri[4]]
        uv3 := &uvs[tri[5]]

        edge1 := v2^ - v1^
        edge2 := v3^ - v1^
    
        normal := Vector3Normalize(Vector3CrossProduct(edge1, edge2))

        toCamera := Vector3Normalize(v1^)
    
        if (Vector3DotProduct(normal, toCamera) >= 0.0) {
            continue
        }

        intensity := Vector3DotProduct(normal, light.direction)
        intensity = math.clamp(intensity, 0.0, 1.0)
        intensity = math.clamp(ambient + intensity * light.strength, 0.0, 1.0)

        p1 := ProjectToScreen(v1)
        p2 := ProjectToScreen(v2)
        p3 := ProjectToScreen(v3)

        if (IsFaceOutsideFrustum(&p1, &p2, &p3)) {
            continue
        }

        DrawTexturedTriangleFlatShaded(
            i32(p1.x), i32(p1.y), p1.z, p1.w, uv1.x, uv1.y,
            i32(p2.x), i32(p2.y), p2.z, p2.w, uv2.x, uv2.y,
            i32(p3.x), i32(p3.y), p3.z, p3.w, uv3.x, uv3.y,
            texture,
            intensity,
            zBuffer
        )
    }
}

DrawTexturedTriangleFlatShaded :: proc(
    x0, y0: i32, z0, w0, u0, v0: f32, 
    x1, y1: i32, z1, w1, u1, v1: f32,
    x2, y2: i32, z2, w2, u2, v2: f32,
    texture: ^Texture,
    intensity: f32,
    zBuffer: ^ZBuffer
) {
    x0_, y0_, z0_, w0_, u0_, v0_ := x0, y0, z0, w0, u0, v0
    x1_, y1_, z1_, w1_, u1_, v1_ := x1, y1, z1, w1, u1, v1
    x2_, y2_, z2_, w2_, u2_, v2_ := x2, y2, z2, w2, u2, v2

    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
        z0_, z1_ = z1_, z0_
        w0_, w1_ = w1_, w0_
        u0_, u1_ = u1_, u0_
        v0_, v1_ = v1_, v0_
    }
    if y1_ > y2_ {
        x1_, x2_ = x2_, x1_
        y1_, y2_ = y2_, y1_
        z1_, z2_ = z2_, z1_
        w1_, w2_ = w2_, w1_
        u1_, u2_ = u2_, u1_
        v1_, v2_ = v2_, v1_
    }
    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
        z0_, z1_ = z1_, z0_
        w0_, w1_ = w1_, w0_
        u0_, u1_ = u1_, u0_
        v0_, v1_ = v1_, v0_
    }

    pointA := Vector4{ f32(x0_), f32(y0_), z0_, w0_ }
    pointB := Vector4{ f32(x1_), f32(y1_), z1_, w1_ }
    pointC := Vector4{ f32(x2_), f32(y2_), z2_, w2_ }

    uvA := Vector2{ u0_, v0_ };
    uvB := Vector2{ u1_, v1_ };
    uvC := Vector2{ u2_, v2_ };

    // Draw flat-bottom triangle
    if y1_ != y0_ {
        invSlope1 := f32(x1_ - x0_) / f32(y1_ - y0_)
        invSlope2 := f32(x2_ - x0_) / f32(y2_ - y0_)

        for y := y0_; y <= y1_; y += 1 {
            xStart := i32(f32(x0_) + f32(y - y0_) * invSlope1)
            xEnd := i32(f32(x0_) + f32(y - y0_) * invSlope2)

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawTexelFlatShaded(x, y, &pointA, &pointB, &pointC, &uvA, &uvB, &uvC, texture, intensity, zBuffer)
            }
        }
    }

    // Draw flat-top triangle
    if y2_ != y1_ {
        invSlope1 := f32(x2_ - x1_) / f32(y2_ - y1_)
        invSlope2 := f32(x2_ - x0_) / f32(y2_ - y0_)

        for y := y1_; y <= y2_; y += 1 {
            xStart := i32(f32(x1_) + f32(y - y1_) * invSlope1)
            xEnd := i32(f32(x0_) + f32(y - y0_) * invSlope2)

            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }

            for x := xStart; x <= xEnd; x += 1 {
                DrawTexelFlatShaded(x, y, &pointA, &pointB, &pointC, &uvA, &uvB, &uvC, texture, intensity, zBuffer)
            }
        }
    }
}

DrawTexelFlatShaded :: proc(
    x, y: i32,
    pointA, pointB, pointC: ^Vector4,
    uvA, uvB, uvC: ^Vector2,
    texture: ^Texture,
    intensity: f32,
    zBuffer: ^ZBuffer
) {
    if IsPointOutsideViewport(x,y) {
        return
    }

    p := Vector2{f32(x), f32(y)}
    a := Vector2{pointA.x, pointA.y}
    b := Vector2{pointB.x, pointB.y}
    c := Vector2{pointC.x, pointC.y}

    weights := BarycentricWeights(a, b, c, p)

    alpha := weights.x
    beta := weights.y
    gamma := weights.z

    interpolatedU := (uvA.x / pointA.w) * alpha + (uvB.x / pointB.w) * beta + (uvC.x / pointC.w) * gamma
    interpolatedV := (uvA.y / pointA.w) * alpha + (uvB.y / pointB.w) * beta + (uvC.y / pointC.w) * gamma

    interpolatedReciprocalW := (1.0 / pointA.w) * alpha + (1.0 / pointB.w) * beta + (1.0 / pointC.w) * gamma

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

DrawTexturedPhongShaded :: proc(vertices: ^[]Vector3, triangles: ^[][9]int, uvs: ^[]Vector2, normals: ^[]Vector3, light: Light, texture: ^Texture, zBuffer: ^ZBuffer, ambient: f32 = 0.1) {
    for i in 0..<len(triangles) {
        tri := triangles[i]
 
        v1 := &vertices[tri[0]]
        v2 := &vertices[tri[1]]
        v3 := &vertices[tri[2]]
 
        uv1 := &uvs[tri[3]]
        uv2 := &uvs[tri[4]]
        uv3 := &uvs[tri[5]]
 
        n1 := normals[tri[6]]
        n2 := normals[tri[7]]
        n3 := normals[tri[8]]
 
        if IsBackFace(v1, v2, v3) {
            continue
        }
 
        p1 := ProjectToScreen(v1)
        p2 := ProjectToScreen(v2)
        p3 := ProjectToScreen(v3)
 
        if IsFaceOutsideFrustum(&p1, &p2, &p3) {
            continue
        }
 
        DrawTexturedTrianglePhongShaded(
            v1^, v2^, v3^, 
            i32(p1.x), i32(p1.y), p1.z, p1.w, uv1.x, uv1.y, n1,
            i32(p2.x), i32(p2.y), p2.z, p2.w, uv2.x, uv2.y, n2,
            i32(p3.x), i32(p3.y), p3.z, p3.w, uv3.x, uv3.y, n3,
            texture, light, ambient, zBuffer
        )
    }
}
 
DrawTexturedTrianglePhongShaded :: proc(
    p0, p1, p2: Vector3,
    x0, y0: i32, z0, w0, u0, v0: f32, n0: Vector3,
    x1, y1: i32, z1, w1, u1, v1: f32, n1: Vector3,
    x2, y2: i32, z2, w2, u2, v2: f32, n2: Vector3,
    texture: ^Texture,
    light: Light,
    ambient: f32,
    zBuffer: ^ZBuffer
) {
    x0_, y0_, z0_, w0_, u0_, v0_, n0_, p0_ := x0, y0, z0, w0, u0, v0, n0, p0
    x1_, y1_, z1_, w1_, u1_, v1_, n1_, p1_ := x1, y1, z1, w1, u1, v1, n1, p1
    x2_, y2_, z2_, w2_, u2_, v2_, n2_, p2_ := x2, y2, z2, w2, u2, v2, n2, p2
 
    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
        z0_, z1_ = z1_, z0_
        w0_, w1_ = w1_, w0_
        u0_, u1_ = u1_, u0_
        v0_, v1_ = v1_, v0_
        n0_, n1_ = n1_, n0_
        p0_, p1_ = p1_, p0_
    }
    if y1_ > y2_ {
        x1_, x2_ = x2_, x1_
        y1_, y2_ = y2_, y1_
        z1_, z2_ = z2_, z1_
        w1_, w2_ = w2_, w1_
        u1_, u2_ = u2_, u1_
        v1_, v2_ = v2_, v1_
        n1_, n2_ = n2_, n1_
        p1_, p2_ = p2_, p1_
    }
    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
        z0_, z1_ = z1_, z0_
        w0_, w1_ = w1_, w0_
        u0_, u1_ = u1_, u0_
        v0_, v1_ = v1_, v0_
        n0_, n1_ = n1_, n0_
        p0_, p1_ = p1_, p0_
    }
 
    pointA := Vector4{ f32(x0_), f32(y0_), z0_, w0_ }
    pointB := Vector4{ f32(x1_), f32(y1_), z1_, w1_ }
    pointC := Vector4{ f32(x2_), f32(y2_), z2_, w2_ }
 
    uvA := Vector2{ u0_, v0_ }
    uvB := Vector2{ u1_, v1_ }
    uvC := Vector2{ u2_, v2_ }
 
    // Draw flat-bottom triangle
    if y1_ != y0_ {
        invSlope1 := f32(x1_ - x0_) / f32(y1_ - y0_)
        invSlope2 := f32(x2_ - x0_) / f32(y2_ - y0_)
 
        for y := y0_; y <= y1_; y += 1 {
            xStart := i32(f32(x0_) + f32(y - y0_) * invSlope1)
            xEnd   := i32(f32(x0_) + f32(y - y0_) * invSlope2)
 
            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }
 
            for x := xStart; x <= xEnd; x += 1 {
                DrawTexelPhongShaded(
                    x, y, 
                    p0_, p1_, p2_, 
                    n0_, n1_, n2_, 
                    &pointA, &pointB, &pointC, 
                    &uvA, &uvB, &uvC, 
                    texture, light, ambient, zBuffer
                )
            }
        }
    }

    // Draw flat-top triangle
    if y2_ != y1_ {
        invSlope1 := f32(x2_ - x1_) / f32(y2_ - y1_)
        invSlope2 := f32(x2_ - x0_) / f32(y2_ - y0_)
 
        for y := y1_; y <= y2_; y += 1 {
            xStart := i32(f32(x1_) + f32(y - y1_) * invSlope1)
            xEnd   := i32(f32(x0_) + f32(y - y0_) * invSlope2)
 
            if xStart > xEnd {
                xStart, xEnd = xEnd, xStart
            }
 
            for x := xStart; x <= xEnd; x += 1 {
                DrawTexelPhongShaded(
                    x, y,
                    p0_, p1_, p2_, 
                    n0_, n1_, n2_,
                    &pointA, &pointB, &pointC,
                    &uvA, &uvB, &uvC, 
                    texture, light, ambient, zBuffer
                )
            }
        }
    }
}

DrawTexelPhongShaded :: proc(
    x, y: i32,
    p0, p1, p2: Vector3,
    n0, n1, n2: Vector3,
    pointA, pointB, pointC: ^Vector4,
    uvA, uvB, uvC: ^Vector2,
    texture: ^Texture,
    light: Light,
    ambient: f32,
    zBuffer: ^ZBuffer
) {
    if IsPointOutsideViewport(x, y) {
        return
    }

    p := Vector2{ f32(x), f32(y) }
    a := Vector2{ pointA.x, pointA.y }
    b := Vector2{ pointB.x, pointB.y }
    c := Vector2{ pointC.x, pointC.y }

    weights := BarycentricWeights(a, b, c, p)
    alpha := weights.x
    beta  := weights.y
    gamma := weights.z

    denominator := (alpha / pointA.w) + (beta / pointB.w) + (gamma / pointC.w)
    if denominator == 0.0 {
        return
    }

    depth := -(1.0 / denominator)
    zIndex := (SCREEN_WIDTH * y) + x
    if depth < zBuffer[zIndex] {
        interpU := ((uvA.x/pointA.w)*alpha + (uvB.x/pointB.w)*beta + (uvC.x/pointC.w)*gamma) / denominator
        interpV := ((uvA.y/pointA.w)*alpha + (uvB.y/pointB.w)*beta + (uvC.y/pointC.w)*gamma) / denominator

        interpNormal := Vector3Normalize(n0*alpha + n1*beta + n2*gamma)

        position := ((p0 * (alpha / pointA.w)) + (p1 * (beta  / pointB.w)) +(p2 * (gamma / pointC.w)) ) / denominator

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

        rl.DrawPixel(x, y, shadedColor)
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

IsBackFace :: proc(v1, v2, v3: ^Vector3) -> bool {
    edge1 := v2^ - v1^
    edge2 := v3^ - v1^

    normal := Vector3Normalize(Vector3CrossProduct(edge1, edge2))
    
    toCamera := Vector3Normalize(v1^)
    
    return Vector3DotProduct(normal, toCamera) >= 0.0 
}

IsFaceOutsideFrustum :: proc(p1, p2, p3: ^Vector4) -> bool {
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
