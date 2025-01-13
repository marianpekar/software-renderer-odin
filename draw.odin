package main

import "core:math"
import rl "vendor:raylib"

DrawWireframe :: proc(vertices: ^[]rl.Vector3, triangles: ^[][3]int, color: rl.Color) {
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

        rl.DrawLineV({p1.x, p1.y}, {p2.x, p2.y}, color)
        rl.DrawLineV({p2.x, p2.y}, {p3.x, p3.y}, color)
        rl.DrawLineV({p3.x, p3.y}, {p1.x, p1.y}, color)
    }
}

DrawLit :: proc(vertices: ^[]rl.Vector3, triangles: ^[][3]int, color: rl.Color) {
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

        DrawFilledTriangle(
            i32(p1.x), i32(p1.y),
            i32(p2.x), i32(p2.y),
            i32(p3.x), i32(p3.y),
            color
        )
    }
}

DrawFlatShaded :: proc(vertices: ^[]rl.Vector3, triangles: ^[][3]int, lightDir: rl.Vector3, baseColor: rl.Color, ambient:f32 = 0.2) {
    for tri in triangles {
        v1 := vertices[tri[0]]
        v2 := vertices[tri[1]]
        v3 := vertices[tri[2]]

        edge1 := v2 - v1
        edge2 := v3 - v1
    
        normal := rl.Vector3Normalize(rl.Vector3CrossProduct(edge1, edge2))

        toCamera := rl.Vector3Normalize(v1)
    
        if (rl.Vector3DotProduct(normal, toCamera) >= 0.0) {
            continue
        }

        intensity := rl.Vector3DotProduct(normal, lightDir)
        intensity = math.clamp(intensity, 0.0, 1.0)
        intensity = math.clamp(ambient + intensity, 0.0, 1.0)

        shadedColor := rl.Color{
            u8(f32(baseColor.r) * intensity),
            u8(f32(baseColor.g) * intensity),
            u8(f32(baseColor.b) * intensity),
            baseColor.a
        }

        p1 := ProjectToScreen(&v1)
        p2 := ProjectToScreen(&v2)
        p3 := ProjectToScreen(&v3)

        DrawFilledTriangle(
            i32(p1.x), i32(p1.y),
            i32(p2.x), i32(p2.y),
            i32(p3.x), i32(p3.y),
            shadedColor
        )
    }
}

DrawFilledTriangle :: proc(
    x0: i32, y0: i32,
    x1: i32, y1: i32,
    x2: i32, y2: i32,
    color: rl.Color
) {
    x0_, y0_ := x0, y0
    x1_, y1_ := x1, y1
    x2_, y2_ := x2, y2

    // Sort vertices by y-coordinate (y0 <= y1 <= y2)
    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
    }
    if y1_ > y2_ {
        x1_, x2_ = x2_, x1_
        y1_, y2_ = y2_, y1_
    }
    if y0_ > y1_ {
        x0_, x1_ = x1_, x0_
        y0_, y1_ = y1_, y0_
    }

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
                rl.DrawPixel(x, y, color)
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
                rl.DrawPixel(x, y, color)
            }
        }
    }
}

DrawTextured :: proc(vertices: ^[]rl.Vector3, triangles: ^[][3]int, uvs: ^[]rl.Vector2, texture: ^Texture) {
    for tri in triangles {
        v1 := &vertices[tri[0]]
        v2 := &vertices[tri[1]]
        v3 := &vertices[tri[2]]

        uv1 := &uvs[tri[0]]
        uv2 := &uvs[tri[1]]
        uv3 := &uvs[tri[2]]

        if (IsBackFace(v1, v2, v3)) {
            continue
        }

        p1 := ProjectToScreen(v1)
        p2 := ProjectToScreen(v2)
        p3 := ProjectToScreen(v3)

        DrawTexturedTriangle(
            i32(p1.x), i32(p1.y), p1.z, p1.w, uv1.x, uv1.y,
            i32(p2.x), i32(p2.y), p2.z, p2.w, uv2.x, uv2.y,
            i32(p3.x), i32(p3.y), p3.z, p3.w, uv3.x, uv3.y,
            texture,
            1.0
        )
    }
}

DrawTexturedShaded :: proc(vertices: ^[]rl.Vector3, triangles: ^[][3]int, uvs: ^[]rl.Vector2, lightDir: rl.Vector3, texture: ^Texture, ambient:f32 = 0.2) {
    for tri in triangles {
        v1 := &vertices[tri[0]]
        v2 := &vertices[tri[1]]
        v3 := &vertices[tri[2]]

        uv1 := &uvs[tri[0]]
        uv2 := &uvs[tri[1]]
        uv3 := &uvs[tri[2]]

        edge1 := v2^ - v1^
        edge2 := v3^ - v1^
    
        normal := rl.Vector3Normalize(rl.Vector3CrossProduct(edge1, edge2))

        toCamera := rl.Vector3Normalize(v1^)
    
        if (rl.Vector3DotProduct(normal, toCamera) >= 0.0) {
            continue
        }

        intensity := rl.Vector3DotProduct(normal, lightDir)
        intensity = math.clamp(intensity, 0.0, 1.0)
        intensity = math.clamp(ambient + intensity, 0.0, 1.0)

        p1 := ProjectToScreen(v1)
        p2 := ProjectToScreen(v2)
        p3 := ProjectToScreen(v3)

        DrawTexturedTriangle(
            i32(p1.x), i32(p1.y), p1.z, p1.w, uv1.x, uv1.y,
            i32(p2.x), i32(p2.y), p2.z, p2.w, uv2.x, uv2.y,
            i32(p3.x), i32(p3.y), p3.z, p3.w, uv3.x, uv3.y,
            texture,
            intensity
        )
    }
}

DrawTexturedTriangle :: proc(
    x0, y0: i32, z0, w0, u0, v0: f32, 
    x1, y1: i32, z1, w1, u1, v1: f32,
    x2, y2: i32, z2, w2, u2, v2: f32,
    texture: ^Texture,
    intensity: f32
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

    v0_ = 1.0 - v0_;
    v1_ = 1.0 - v1_;
    v2_ = 1.0 - v2_;

    pointA := rl.Vector4{ f32(x0_), f32(y0_), z0_, w0_ }
    pointB := rl.Vector4{ f32(x1_), f32(y1_), z1_, w1_ }
    pointC := rl.Vector4{ f32(x2_), f32(y2_), z2_, w2_ }

    uvA := rl.Vector2{ u0_, v0_ };
    uvB := rl.Vector2{ u1_, v1_ };
    uvC := rl.Vector2{ u2_, v2_ };

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
                DrawTexel(x, y, &pointA, &pointB, &pointC, &uvA, &uvB, &uvC, texture, intensity)
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
                DrawTexel(x, y, &pointA, &pointB, &pointC, &uvA, &uvB, &uvC, texture, intensity)
            }
        }
    }
}

DrawTexel :: proc(
    x, y: i32,
    pointA, pointB, pointC: ^rl.Vector4,
    uvA, uvB, uvC: ^rl.Vector2,
    texture: ^Texture,
    intensity: f32
) {
    p := rl.Vector2{f32(x), f32(y)}
    a := rl.Vector2{pointA.x, pointA.y}
    b := rl.Vector2{pointB.x, pointB.y}
    c := rl.Vector2{pointC.x, pointC.y}

    weights := BarycentricWeights(a, b, c, p)

    alpha := weights.x
    beta := weights.y
    gamma := weights.z

    interpolatedU := (uvA.x / pointA.w) * alpha + (uvB.x / pointB.w) * beta + (uvC.x / pointC.w) * gamma
    interpolatedV := (uvA.y / pointA.w) * alpha + (uvB.y / pointB.w) * beta + (uvC.y / pointC.w) * gamma
    interpolatedReciprocalW := (1.0 / pointA.w) * alpha + (1.0 / pointB.w) * beta + (1.0 / pointC.w) * gamma

    interpolatedU /= interpolatedReciprocalW
    interpolatedV /= interpolatedReciprocalW

    texX := i32(math.abs(interpolatedU * f32(texture.width))) % texture.width
    texY := i32(math.abs(interpolatedV * f32(texture.height))) % texture.height

    color := texture.pixels[texY * texture.width + texX]

    shadedColor := rl.Color{
        u8(f32(color.r) * intensity),
        u8(f32(color.g) * intensity),
        u8(f32(color.b) * intensity),
        color.a
    }

    rl.DrawPixel(x, y, shadedColor)
}


BarycentricWeights :: proc(a, b, c, p: rl.Vector2) -> rl.Vector3 {
    ab := rl.Vector2{b.x - a.x, b.y - a.y}
    ac := rl.Vector2{c.x - a.x, c.y - a.y}
    ap := rl.Vector2{p.x - a.x, p.y - a.y}

    areaABC := ab.x * ac.y - ab.y * ac.x
    areaPBC := (b.x - p.x) * (c.y - p.y) - (b.y - p.y) * (c.x - p.x)
    areaPCA := (c.x - p.x) * (a.y - p.y) - (c.y - p.y) * (a.x - p.x)

    alpha := areaPBC / areaABC
    beta := areaPCA / areaABC
    gamma := 1.0 - alpha - beta

    return rl.Vector3{alpha, beta, gamma}
}


ProjectToScreen :: proc(point: ^rl.Vector3) -> rl.Vector4 {
    if point.z == 0.0 {
        point.z = 0.0001
    }

    projectedX := point.x / point.z
    projectedY := point.y / point.z

    screenX := projectedX * SCREEN_WIDTH / 2 + SCREEN_WIDTH / 2
    screenY := -projectedY * SCREEN_HEIGHT / 2 + SCREEN_HEIGHT / 2

    return rl.Vector4{screenX, screenY, point.z, point.z}
}

IsBackFace :: proc(v1, v2, v3: ^rl.Vector3) -> bool {
    edge1 := v2^ - v1^
    edge2 := v3^ - v1^

    normal := rl.Vector3Normalize(rl.Vector3CrossProduct(edge1, edge2))
    
    toCamera := rl.Vector3Normalize(v1^)
    
    return rl.Vector3DotProduct(normal, toCamera) >= 0.0 
}