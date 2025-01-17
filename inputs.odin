package main

import rl "vendor:raylib"

HandleInputs :: proc(translation, rotation: ^rl.Vector3, scale: ^f32, renderMode: ^i8, renderModesCount: i8) {
    step: f32 = 0.05
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
        renderMode^ = (renderMode^ + renderModesCount - 1) % renderModesCount
    } else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        renderMode^ = (renderMode^ + 1) % renderModesCount
    }
}