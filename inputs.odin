package main

import rl "vendor:raylib"

HandleInputs :: proc(translation, rotation: ^rl.Vector3, scale: ^f32, renderType: ^i8, renderTypesCount: i8) {
    step: f32 = 0.1
    if rl.IsKeyDown(rl.KeyboardKey.W) { translation.z += step } 
    if rl.IsKeyDown(rl.KeyboardKey.S) { translation.z -= step } 
    if rl.IsKeyDown(rl.KeyboardKey.A) { translation.x -= step } 
    if rl.IsKeyDown(rl.KeyboardKey.D) { translation.x += step }
    if rl.IsKeyDown(rl.KeyboardKey.Q) { translation.y += step } 
    if rl.IsKeyDown(rl.KeyboardKey.E) { translation.y -= step }

    if rl.IsKeyDown(rl.KeyboardKey.I) { rotation.x += step } 
    if rl.IsKeyDown(rl.KeyboardKey.K) { rotation.x -= step } 
    if rl.IsKeyDown(rl.KeyboardKey.J) { rotation.y -= step } 
    if rl.IsKeyDown(rl.KeyboardKey.L) { rotation.y += step }
    if rl.IsKeyDown(rl.KeyboardKey.U) { rotation.z += step } 
    if rl.IsKeyDown(rl.KeyboardKey.O) { rotation.z -= step }

    if rl.IsKeyDown(rl.KeyboardKey.KP_ADD) { scale^ += step }
    if rl.IsKeyDown(rl.KeyboardKey.KP_SUBTRACT) { scale^ -= step }

    if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
        renderType^ = (renderType^ + renderTypesCount - 1) % renderTypesCount
    } else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        renderType^ = (renderType^ + 1) % renderTypesCount
    }
}