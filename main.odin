package main

import rl "vendor:raylib"

ProjectionType :: enum {
    Perspective,
    Orthographic,
}

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

    renderImage := rl.GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, rl.LIGHTGRAY)
    defer rl.UnloadImage(renderImage)
    
    renderTexture := rl.LoadTextureFromImage(renderImage)
    defer rl.UnloadTexture(renderTexture)

    zBuffer := MakeZBuffer()
    defer DeleteZBuffer(zBuffer)

    cube := LoadModel("assets/cube.obj", "assets/box.png")
    monkey := LoadModel("assets/monkey.obj", "assets/uv_checker.png")

    monkey.wireColor = rl.RED
    
    models := []Model{cube, monkey}
    defer {
        for &model in models {
            DeleteModel(&model)
        }
    }

    camera := MakeCamera({0.0, 0.0, -3.0})

    light  := MakeLight({-4.0,  0.0, -3.0}, { 1.0,  1.0, 0.0}, {1.0, 0.0, 0.0, 1.0})
    light2 := MakeLight({ 4.0,  0.0, -3.0}, {-1.0, -1.0, 0.0}, {0.0, 1.0, 0.0, 1.0})
    lights := []Light{light, light2}

    ambient := Vector3{0.2, 0.2, 0.2}
    ambient2 := Vector3{0.1, 0.1, 0.2}

    renderModesCount :: 8
    renderMode: i8 = renderModesCount - 1
    drawCoordsInWireframe := false
    projType : ProjectionType = .Perspective

    perspMatrix := MakePerspectiveMatrix(FOV, SCREEN_WIDTH, SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)
    orthoMatrix := MakeOrthographicMatrix(SCREEN_WIDTH, SCREEN_HEIGHT, NEAR_PLANE, FAR_PLANE)

    selectedModelIdx := 0
    modelCount := len(models)
    selectedModel := &models[selectedModelIdx]

    for &model in models {
        ApplyTransformations(&model, camera)
    }

    for !rl.WindowShouldClose() {
        deltaTime := rl.GetFrameTime()

        selectedModel := &models[selectedModelIdx]

        HandleInputs(selectedModel, &renderMode, &drawCoordsInWireframe, &projType, renderModesCount, &selectedModelIdx, modelCount, deltaTime)

        ApplyTransformations(selectedModel, camera)
        
        projMatrix: Matrix4x4
        switch projType {
            case .Perspective: projMatrix = perspMatrix
            case .Orthographic: projMatrix = orthoMatrix
        }

        rl.BeginDrawing()

        ClearZBuffer(zBuffer)
        
        for &model in models {
            switch renderMode {
                case 7: DrawTexturedPhongShaded(model.mesh.transformedVertices, model.mesh.triangles, model.mesh.uvs, model.mesh.transformedNormals, lights, model.texture, zBuffer, &renderImage, projMatrix, projType, ambient2)
                case 6: DrawTexturedFlatShaded(model.mesh.transformedVertices, model.mesh.triangles, model.mesh.uvs, lights, model.texture, zBuffer, &renderImage, projMatrix, projType, ambient)
                case 5: DrawTexturedUnlit(model.mesh.transformedVertices, model.mesh.triangles, model.mesh.uvs, model.texture, zBuffer, &renderImage, projMatrix, projType)
                case 4: DrawPhongShaded(model.mesh.transformedVertices, model.mesh.triangles, model.mesh.transformedNormals, lights, model.color, zBuffer, &renderImage, projMatrix, projType, ambient2)
                case 3: DrawFlatShaded(model.mesh.transformedVertices, model.mesh.triangles, lights, model.color, zBuffer, &renderImage, projMatrix, projType, ambient)
                case 2: DrawUnlit(model.mesh.transformedVertices, model.mesh.triangles, model.color, zBuffer, &renderImage, projMatrix, projType)
                case 1: DrawWireframe(model.mesh.transformedVertices, model.mesh.vertices, model.mesh.triangles, model.wireColor, &renderImage, projMatrix, projType, drawCoordsInWireframe)
                case 0: DrawWireframe(model.mesh.transformedVertices, model.mesh.vertices, model.mesh.triangles, model.wireColor, &renderImage, projMatrix, projType, drawCoordsInWireframe, false)
            }
        }

        rl.UpdateTexture(renderTexture, renderImage.data)
        rl.DrawTexture(renderTexture, 0, 0, rl.WHITE)
	    rl.DrawFPS(10, 10)

        rl.EndDrawing()

        rl.ImageClearBackground(&renderImage, rl.BLACK)
    }

    rl.CloseWindow()
}