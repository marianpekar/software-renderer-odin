package main

import "core:math"
import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")
    rl.SetTargetFPS(60)

    cube := MakeCube()

    camera: Camera
    camera.position = Vector3{0.0, 0.0, -5.0}
    camera.target = Vector3{0.0, 0.0, 0.0}

    light := Vector3{0.0, -1.0, 0.0}
    light = Vector3Normalize(light)

    rotation := Vector3{0.0, 0.0, 0.0}
    translation := Vector3{0.0, 0.0, 0.0}
    scale: f32 = 1.0

    renderModesCount :: 6
    renderMode: i8 = renderModesCount - 1

    texture := LoadTextureFromFile("assets/uv_checker.png")

    for !rl.WindowShouldClose() {
        
        HandleInputs(&translation, &rotation, &scale, &renderMode, renderModesCount)

        // Translation
        translationMatrix := MakeTranslationMatrix(translation.x, translation.y, translation.z)

        // Rotation
        rotationX := MakeRotationMatrixX(rotation.x)
        rotationY := MakeRotationMatrixY(rotation.y)
        rotationZ := MakeRotationMatrixZ(rotation.z)

        // Scale
        scaleMatrix := MakeScaleMatrix(scale, scale, scale)

        // Transformations
        viewMatrix  := MakeViewMatrix(camera.position, camera.target)
        modelMatrix := Mat4Mul(&rotationX, &rotationY)
        modelMatrix  = Mat4Mul(&modelMatrix, &rotationZ)
        modelMatrix  = Mat4Mul(&translationMatrix, &modelMatrix)
        modelMatrix  = Mat4Mul(&scaleMatrix, &modelMatrix)
        finalMatrix := Mat4Mul(&viewMatrix, &modelMatrix)

        TransformVertices(&cube.transformedVertices, &cube.vertices, &finalMatrix)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        switch renderMode {
            case 5: DrawTexturedShaded(&cube.transformedVertices, &cube.triangles, &cube.uvs, light, &texture)
            case 4: DrawTextured(&cube.transformedVertices, &cube.triangles, &cube.uvs, &texture)
            case 3: DrawFlatShaded(&cube.transformedVertices, &cube.triangles, light, rl.WHITE)
            case 2: DrawLit(&cube.transformedVertices, &cube.triangles, rl.WHITE)
            case 1: DrawWireframe(&cube.transformedVertices, &cube.triangles, rl.RED)
            case 0: DrawWireframe(&cube.transformedVertices, &cube.triangles, rl.RED, false)
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

TransformVertices :: proc(transformedVertices, vertices: ^[]Vector3, mat: ^Matrix4x4) {
    for i in 0..<len(vertices) {
        transformedVertices[i] = Mat4MulVec3(mat, &vertices[i])
    }
}