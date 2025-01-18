package main 

ZBuffer :: []f32

ClearZBuffer :: proc(zBuffer: ^ZBuffer) {
    for i in 0..<len(zBuffer) {
        zBuffer[i] = Z_BUFFER_MAX;
    }
}

MakeZBuffer :: proc(screenWidth, screenHeight: i32) -> ZBuffer {
    return make([]f32, screenWidth * screenHeight)
}