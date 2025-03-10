package main

import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")
    rl.SetTargetFPS(60)

    renderImage := rl.GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, rl.LIGHTGRAY)
    renderTexture := rl.LoadTextureFromImage(renderImage)
    zBuffer := MakeZBuffer()
    defer DeleteZBuffer(zBuffer)

    //mesh := Makemesh()
    mesh := LoadMeshFromObjFile("assets/monkey.obj")
    defer DeleteMesh(&mesh)

    texture := LoadTextureFromFile("assets/uv_checker.png")
    camera := MakeCamera({0.0, 0.0, -5.0})
    light := MakeLight({0.0, 0.0, -5.0}, {0.0, -1.0, 0.0}, 1.0)

    rotation := Vector3{0.0, 0.0, 0.0}
    translation := Vector3{0.0, 0.0, 0.0}
    scale: f32 = 1.0

    renderModesCount :: 8
    renderMode: i8 = renderModesCount - 1

    for !rl.WindowShouldClose() {
        deltaTime := rl.GetFrameTime()
        HandleInputs(&translation, &rotation, &scale, &renderMode, renderModesCount, deltaTime)

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
        modelMatrix := Mat4Mul(rotationX, rotationY)
        modelMatrix  = Mat4Mul(modelMatrix, rotationZ)
        modelMatrix  = Mat4Mul(translationMatrix, modelMatrix)
        modelMatrix  = Mat4Mul(scaleMatrix, modelMatrix)
        finalMatrix := Mat4Mul(viewMatrix, modelMatrix)

        TransformVectors(&mesh.transformedVertices, mesh.vertices, finalMatrix)
        TransformVectors(&mesh.transformedNormals, mesh.normals, finalMatrix)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        ClearZBuffer(zBuffer)

        switch renderMode {
            case 7: DrawTexturedPhongShaded(mesh.transformedVertices, mesh.triangles, mesh.uvs, mesh.transformedNormals, light, texture, zBuffer, &renderImage)
            case 6: DrawTexturedFlatShaded(mesh.transformedVertices, mesh.triangles, mesh.uvs, light, texture, zBuffer)
            case 5: DrawTexturedUnlit(mesh.transformedVertices, mesh.triangles, mesh.uvs, texture, zBuffer)
            case 4: DrawPhongShaded(mesh.transformedVertices, mesh.triangles, mesh.transformedNormals, light, rl.WHITE, zBuffer)
            case 3: DrawFlatShaded(mesh.transformedVertices, mesh.triangles, light, rl.WHITE, zBuffer)
            case 2: DrawUnlit(mesh.transformedVertices, mesh.triangles, rl.WHITE, zBuffer)
            case 1: DrawWireframe(mesh.transformedVertices, mesh.triangles, rl.RED)
            case 0: DrawWireframe(mesh.transformedVertices, mesh.triangles, rl.RED, false)
        }

        rl.UpdateTexture(renderTexture, renderImage.data)
        rl.DrawTexture(renderTexture, 0, 0, rl.WHITE)
	rl.DrawFPS(10, 10)

        rl.EndDrawing()

        rl.ImageClearBackground(&renderImage, rl.BLACK)

    }

    rl.UnloadTexture(renderTexture)
    rl.UnloadImage(renderImage)

    rl.CloseWindow()
}

TransformVectors :: proc(transformedVectors: ^[]Vector3, originalVectors: []Vector3, mat: Matrix4x4) {
    for i in 0..<len(originalVectors) {
        transformedVectors[i] = Mat4MulVec3(mat, originalVectors[i])
    }
}
