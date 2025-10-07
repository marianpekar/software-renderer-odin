package main

import rl "vendor:raylib"

HandleInputs :: proc(model: ^Model, renderMode: ^i8, drawCoordsInWireframe: ^bool, projType: ^ProjectionType, renderModesCount: i8, modelIdx: ^int, modelCount: int, deltaTime: f32) {
    linearStep: f32 = (rl.IsKeyDown(rl.KeyboardKey.LEFT_SHIFT) ? 0.25 : 1) * deltaTime
    angularStep: f32 = (rl.IsKeyDown(rl.KeyboardKey.LEFT_SHIFT) ? 12 : 48) * deltaTime

    if rl.IsKeyDown(rl.KeyboardKey.W) do model.translation.z += linearStep
    if rl.IsKeyDown(rl.KeyboardKey.S) do model.translation.z -= linearStep
    if rl.IsKeyDown(rl.KeyboardKey.A) do model.translation.x += linearStep
    if rl.IsKeyDown(rl.KeyboardKey.D) do model.translation.x -= linearStep
    if rl.IsKeyDown(rl.KeyboardKey.E) do model.translation.y += linearStep
    if rl.IsKeyDown(rl.KeyboardKey.Q) do model.translation.y -= linearStep

    if rl.IsKeyDown(rl.KeyboardKey.J) do model.rotation.x += angularStep
    if rl.IsKeyDown(rl.KeyboardKey.L) do model.rotation.x -= angularStep
    if rl.IsKeyDown(rl.KeyboardKey.O) do model.rotation.y += angularStep
    if rl.IsKeyDown(rl.KeyboardKey.U) do model.rotation.y -= angularStep
    if rl.IsKeyDown(rl.KeyboardKey.I) do model.rotation.z -= angularStep
    if rl.IsKeyDown(rl.KeyboardKey.K) do model.rotation.z += angularStep 

    if rl.IsKeyDown(rl.KeyboardKey.KP_ADD) do model.scale += linearStep
    if rl.IsKeyDown(rl.KeyboardKey.KP_SUBTRACT) do model.scale -= linearStep

    if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
        renderMode^ = (renderMode^ + renderModesCount - 1) % renderModesCount
    } else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        renderMode^ = (renderMode^ + 1) % renderModesCount
    }

    if rl.IsKeyPressed(rl.KeyboardKey.UP) {
        modelIdx^ = (modelIdx^ + modelCount - 1) % modelCount
    } else if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
        modelIdx^ = (modelIdx^ + 1) % modelCount
    }

    if (rl.IsKeyPressed(rl.KeyboardKey.C)) {
        drawCoordsInWireframe^ = !drawCoordsInWireframe^
    }
    
    if rl.IsKeyPressed(rl.KeyboardKey.KP_0) {
        projType^ = .Perspective
    }
    if rl.IsKeyPressed(rl.KeyboardKey.KP_1) {
        projType^ = .Orthographic
    }
}