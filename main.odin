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

    light := rl.Vector3{0.0,-1.0,0.0}
    light = rl.Vector3Normalize(light)

    rotationAngle: f32 = 0.0

    renderType: i8 = 2

    for !rl.WindowShouldClose() {
        
        HandleInputs(&camera, &renderType)

        viewMatrix := MakeViewMatrix(camera.position, camera.target)
        projectionMatrix := MakePerspectiveMatrix(FOV, SCREEN_WIDTH / SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        rotationAngle += 0.01
        translationMatrix := MakeTranslationMatrix(math.cos_f32(f32(rl.GetTime())), math.sin_f32(f32(rl.GetTime())), 0.0)
        //translationMatrix := MakeTranslationMatrix(0.0, 0.0, 0.0)

        rotationX := MakeRotationMatrixX(rotationAngle)
        rotationY := MakeRotationMatrixY(rotationAngle)
        rotationZ := MakeRotationMatrixZ(rotationAngle)

        scale := math.sin_f32(f32(rl.GetTime())) + 2
        scaleMatrix := MakeScaleMatrix(scale, scale, scale)

        modelMatrix := Mat4Mul(&rotationX, &rotationY)
        modelMatrix = Mat4Mul(&modelMatrix, &rotationZ)
        modelMatrix = Mat4Mul(&translationMatrix, &modelMatrix)
        modelMatrix = Mat4Mul(&scaleMatrix, &modelMatrix)

        vpMatrix := Mat4Mul(&projectionMatrix, &viewMatrix)
        mvpMatrix := Mat4Mul(&vpMatrix, &modelMatrix)

        transformedVertices := TransformVertices(&cube.vertices, &mvpMatrix)

        switch renderType {
            case 2: DrawFlatShaded(&transformedVertices, &cube.triangles, light, rl.WHITE)
            case 1: DrawLit(&transformedVertices, &cube.triangles, rl.WHITE)
            case 0: DrawWireframe(&transformedVertices, &cube.triangles, rl.RED)
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

TransformVertices :: proc(vertices: ^[]rl.Vector3, mat: ^Matrix4x4) -> []rl.Vector3 {
    transformedVertices := make([]rl.Vector3, len(vertices))
    for i in 0..<len(vertices) {
        transformedVertices[i] = Mat4MulVec3(mat, vertices[i])
    }
    return transformedVertices
}

HandleInputs :: proc(camera: ^Camera, renderType: ^i8) {
    step: f32 = 0.1
    if rl.IsKeyDown(rl.KeyboardKey.W) { camera.position += rl.Vector3{0.0, 0.0, step} } 
    if rl.IsKeyDown(rl.KeyboardKey.S) { camera.position += rl.Vector3{0.0, 0.0, -step} } 
    if rl.IsKeyDown(rl.KeyboardKey.A) { camera.target += rl.Vector3{-step, 0.0, 0.0} } 
    if rl.IsKeyDown(rl.KeyboardKey.D) { camera.target += rl.Vector3{step, 0.0, 0.0} }

    if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
        renderType^ = (renderType^ + 2) % 3
    } else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        renderType^ = (renderType^ + 1) % 3
    }
}