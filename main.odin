package main

import "core:math"
import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")
    rl.SetTargetFPS(60)

    cube := MakeCube()

    camera: Camera
    camera.position = rl.Vector3{0.0, 0.0, -3.0}
    camera.target = rl.Vector3{0.0, 0.0, 0.0}

    light := rl.Vector3{0.0, -1.0, 0.0}
    light = rl.Vector3Normalize(light)

    rotation := rl.Vector3{0.0, 0.0, 0.0}
    translation := rl.Vector3{0.0, 0.0, 0.0}
    scale: f32 = 1.0

    renderModesCount :: 6
    renderMode: i8 = renderModesCount - 1

    texture := LoadTextureFromFile("assets/box.png")

    for !rl.WindowShouldClose() {
        
        HandleInputs(&translation, &rotation, &scale, &renderMode, renderModesCount)

        viewMatrix := MakeViewMatrix(camera.position, camera.target)
        projectionMatrix := MakePerspectiveMatrix(FOV, SCREEN_WIDTH / SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        translationMatrix := MakeTranslationMatrix(translation.x, translation.y, translation.z)

        rotationX := MakeRotationMatrixX(rotation.x)
        rotationY := MakeRotationMatrixY(rotation.y)
        rotationZ := MakeRotationMatrixZ(rotation.z)

        scaleMatrix := MakeScaleMatrix(scale, scale, scale)

        modelMatrix := Mat4Mul(&rotationX, &rotationY)
        modelMatrix = Mat4Mul(&modelMatrix, &rotationZ)
        modelMatrix = Mat4Mul(&translationMatrix, &modelMatrix)
        modelMatrix = Mat4Mul(&scaleMatrix, &modelMatrix)

        vpMatrix := Mat4Mul(&projectionMatrix, &viewMatrix)
        mvpMatrix := Mat4Mul(&vpMatrix, &modelMatrix)

        transformedVertices := TransformVertices(&cube.vertices, &mvpMatrix)

        switch renderMode {
            case 5: DrawTexturedShaded(&transformedVertices, &cube.triangles, &cube.uvs, light, &texture)
            case 4: DrawTextured(&transformedVertices, &cube.triangles, &cube.uvs, &texture)
            case 3: DrawFlatShaded(&transformedVertices, &cube.triangles, light, rl.WHITE)
            case 2: DrawLit(&transformedVertices, &cube.triangles, rl.WHITE)
            case 1: DrawWireframe(&transformedVertices, &cube.triangles, rl.RED)
            case 0: DrawWireframe(&transformedVertices, &cube.triangles, rl.RED, false)
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