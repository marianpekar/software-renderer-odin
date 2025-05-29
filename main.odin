package main

import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

    renderImage := rl.GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, rl.LIGHTGRAY)
    defer rl.UnloadImage(renderImage)
    
    renderTexture := rl.LoadTextureFromImage(renderImage)
    defer rl.UnloadTexture(renderTexture)

    zBuffer := MakeZBuffer()
    defer DeleteZBuffer(zBuffer)

    //mesh := Makemesh()
    mesh := LoadMeshFromObjFile("assets/monkey.obj")
    defer DeleteMesh(&mesh)

    texture := LoadTextureFromFile("assets/uv_checker.png")
    camera := MakeCamera({0.0, 0.0, -3.0})
    light := MakeLight({0.0, 0.0, -3.0}, {0.0, 1.0, 0.0}, 1.0)

    rotation := Vector3{0.0, 180.0, 0.0}
    translation := Vector3{0.0, 0.0, 0.0}
    scale: f32 = 1.0

    renderModesCount :: 8
    renderMode: i8 = renderModesCount - 1

    projMatrix := MakeProjectionMatrix(FOV, SCREEN_WIDTH, SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)

    for !rl.WindowShouldClose() {
        deltaTime := rl.GetFrameTime()
        HandleInputs(&translation, &rotation, &scale, &renderMode, renderModesCount, deltaTime)

        // Translation
        translationMatrix := MakeTranslationMatrix(translation.x, translation.y, translation.z)

        // Rotation
        rotationMatrix := MakeRotationMatrix(rotation.x, rotation.y, rotation.z)

        // Scale
        scaleMatrix := MakeScaleMatrix(scale, scale, scale)

        // Apply Transformations
        modelMatrix := Mat4Mul(translationMatrix, Mat4Mul(rotationMatrix, scaleMatrix))

        viewMatrix  := MakeViewMatrix(camera.position, camera.target)
        viewMatrix  = Mat4Mul(viewMatrix, modelMatrix)
        
        ApplyTransformations(&mesh.transformedVertices, mesh.vertices, viewMatrix)
        ApplyTransformations(&mesh.transformedNormals, mesh.normals, viewMatrix)

        rl.BeginDrawing()

        ClearZBuffer(zBuffer)

        switch renderMode {
            case 7: DrawTexturedPhongShaded(mesh.transformedVertices, mesh.triangles, mesh.uvs, mesh.transformedNormals, light, texture, zBuffer, &renderImage, projMatrix)
            case 6: DrawTexturedFlatShaded(mesh.transformedVertices, mesh.triangles, mesh.uvs, light, texture, zBuffer, &renderImage, projMatrix)
            case 5: DrawTexturedUnlit(mesh.transformedVertices, mesh.triangles, mesh.uvs, texture, zBuffer, &renderImage, projMatrix)
            case 4: DrawPhongShaded(mesh.transformedVertices, mesh.triangles, mesh.transformedNormals, light, rl.WHITE, zBuffer, &renderImage, projMatrix)
            case 3: DrawFlatShaded(mesh.transformedVertices, mesh.triangles, light, rl.WHITE, zBuffer, &renderImage, projMatrix)
            case 2: DrawUnlit(mesh.transformedVertices, mesh.triangles, rl.WHITE, zBuffer, &renderImage, projMatrix)
            case 1: DrawWireframe(mesh.transformedVertices, mesh.triangles, rl.RED, &renderImage, projMatrix)
            case 0: DrawWireframe(mesh.transformedVertices, mesh.triangles, rl.RED, &renderImage, projMatrix, false)
        }

        rl.UpdateTexture(renderTexture, renderImage.data)
        rl.DrawTexture(renderTexture, 0, 0, rl.WHITE)
	    rl.DrawFPS(10, 10)

        rl.EndDrawing()

        rl.ImageClearBackground(&renderImage, rl.BLACK)
    }

    rl.CloseWindow()
}

ApplyTransformations :: proc(transformed: ^[]Vector3, original: []Vector3, mat: Matrix4x4) {
    for i in 0..<len(original) {
        transformed[i] = Mat4MulVec3(mat, original[i])
    }
}
