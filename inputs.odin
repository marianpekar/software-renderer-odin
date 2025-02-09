package main

import rl "vendor:raylib"

HandleInputs :: proc(translation, rotation: ^Vector3, scale: ^f32, renderMode: ^i8, renderModesCount: i8) {
    step: f32 = 0.05
    if rl.IsKeyDown(rl.KeyboardKey.W) do translation.z += step
    if rl.IsKeyDown(rl.KeyboardKey.S) do translation.z -= step
    if rl.IsKeyDown(rl.KeyboardKey.A) do translation.x -= step
    if rl.IsKeyDown(rl.KeyboardKey.D) do translation.x += step
    if rl.IsKeyDown(rl.KeyboardKey.Q) do translation.y += step
    if rl.IsKeyDown(rl.KeyboardKey.E) do translation.y -= step

    if rl.IsKeyDown(rl.KeyboardKey.I) do rotation.x += step
    if rl.IsKeyDown(rl.KeyboardKey.K) do rotation.x -= step
    if rl.IsKeyDown(rl.KeyboardKey.J) do rotation.y -= step
    if rl.IsKeyDown(rl.KeyboardKey.L) do rotation.y += step
    if rl.IsKeyDown(rl.KeyboardKey.U) do rotation.z += step 
    if rl.IsKeyDown(rl.KeyboardKey.O) do rotation.z -= step

    if rl.IsKeyDown(rl.KeyboardKey.KP_ADD) do scale^ += step 
    if rl.IsKeyDown(rl.KeyboardKey.KP_SUBTRACT) do scale^ -= step

    if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
        renderMode^ = (renderMode^ + renderModesCount - 1) % renderModesCount
    } else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
        renderMode^ = (renderMode^ + 1) % renderModesCount
    }
}