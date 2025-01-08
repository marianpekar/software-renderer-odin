package main

import "core:math"
import rl "vendor:raylib"

DrawFlat :: proc(vertices: ^[]rl.Vector3, triangles: ^[][3]int, color: rl.Color) {
    for tri in triangles {
        v1 := ProjectToScreen(&vertices[tri[0]])
        v2 := ProjectToScreen(&vertices[tri[1]])
        v3 := ProjectToScreen(&vertices[tri[2]])

        DrawFilledTriangle(
            i32(v1.x), i32(v1.y),
            i32(v2.x), i32(v2.y),
            i32(v3.x), i32(v3.y),
            color
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

DrawWireframe :: proc(vertices: ^[]rl.Vector3, triangles: ^[][3]int, color: rl.Color) {
    for tri in triangles {
        p1 := ProjectToScreen(&vertices[tri[0]])
        p2 := ProjectToScreen(&vertices[tri[1]])
        p3 := ProjectToScreen(&vertices[tri[2]])

        rl.DrawLineV(p1, p2, color)
        rl.DrawLineV(p2, p3, color)
        rl.DrawLineV(p3, p1, color)
    }
}

ProjectToScreen :: proc(point: ^rl.Vector3) -> rl.Vector2 {
    if point.z == 0.0 {
        point.z = 0.0001
    }

    projectedX := point.x / point.z
    projectedY := point.y / point.z

    screenX := projectedX * SCREEN_WIDTH / 2 + SCREEN_WIDTH / 2
    screenY := -projectedY * SCREEN_HEIGHT / 2 + SCREEN_HEIGHT / 2

    return rl.Vector2{screenX, screenY}
}