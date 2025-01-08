package main

import "core:math"
import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")
    rl.SetTargetFPS(60)

    cube := MakeCube()

    camera: Camera
    camera.position = rl.Vector3{0.0, 0.0, -10.0}
    camera.target = rl.Vector3{0.0, 0.0, 0.0}

    rotationAngle: f32 = 0.0

    for !rl.WindowShouldClose() {
        
        HandleInputs(&camera)

        viewMatrix := MakeViewMatrix(camera.position, camera.target)
        projectionMatrix := MakePerspectiveMatrix(FOV, SCREEN_WIDTH / SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        rotationAngle += 0.01
        //translationMatrix := MakeTranslationMatrix(math.cos_f32(f32(rl.GetTime())) * 5.0, math.sin_f32(f32(rl.GetTime())) * 5.0, 0.0)
        translationMatrix := MakeTranslationMatrix(0.0, 0.0, 0.0)

        rotationX := MakeRotationMatrixX(rotationAngle)
        rotationY := MakeRotationMatrixY(rotationAngle)
        rotationZ := MakeRotationMatrixZ(rotationAngle)

        scale := math.sin_f32(f32(rl.GetTime())) + 3
        scaleMatrix := MakeScaleMatrix(scale, scale, scale)

        modelMatrix := Mat4Mul(Mat4Mul(rotationX, rotationY), rotationZ)
        modelMatrix = Mat4Mul(translationMatrix, modelMatrix)
        modelMatrix = Mat4Mul(scaleMatrix, modelMatrix)

        mvpMatrix := Mat4Mul(Mat4Mul(projectionMatrix, viewMatrix), modelMatrix)

        transformedVertices := ApplyMatrix(&cube, mvpMatrix)

        DrawWireframe(transformedVertices, cube.edges)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

ApplyMatrix :: proc(mesh: ^Mesh, mat: Matrix4x4) -> []rl.Vector3 {
    transformedVertices := make([]rl.Vector3, len(mesh.vertices))
    for i in 0..<len(mesh.vertices) {
        transformedVertices[i] = Mat4MulVec3(mat, mesh.vertices[i])
    }
    return transformedVertices
}

DrawWireframe :: proc(vertices: []rl.Vector3, edges: [][2]int) {
    for edge in edges {
        start := ProjectToScreen(vertices[edge[0]])
        end := ProjectToScreen(vertices[edge[1]])
        rl.DrawLineV(start, end, rl.GREEN)
    }
}

ProjectToScreen :: proc(point: rl.Vector3) -> rl.Vector2 {
    projectedX := point.x / point.z
    projectedY := point.y / point.z

    screenX := projectedX * SCREEN_WIDTH / 2 + SCREEN_WIDTH / 2
    screenY := -projectedY * SCREEN_HEIGHT / 2 + SCREEN_HEIGHT / 2

    return rl.Vector2{screenX, screenY}
}

HandleInputs :: proc(camera: ^Camera) {
    step: f32 = 0.1
    if rl.IsKeyDown(rl.KeyboardKey.W) { camera.position += rl.Vector3{0.0, 0.0, step} } 
    if rl.IsKeyDown(rl.KeyboardKey.S) { camera.position += rl.Vector3{0.0, 0.0, -step} } 
    if rl.IsKeyDown(rl.KeyboardKey.A) { camera.target += rl.Vector3{-step, 0.0, 0.0} } 
    if rl.IsKeyDown(rl.KeyboardKey.D) { camera.target += rl.Vector3{step, 0.0, 0.0} }
}