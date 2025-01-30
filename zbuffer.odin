package main 

ZBuffer :: [SCREEN_WIDTH * SCREEN_HEIGHT]f32

ClearZBuffer :: proc(zBuffer: ^ZBuffer) {
    for i in 0..<len(zBuffer) {
        zBuffer[i] = Z_BUFFER_MAX;
    }
}

MakeZBuffer :: proc() -> ^ZBuffer {
    zBuffer := new(ZBuffer)
    return zBuffer
}

DeleteZBuffer :: proc(zBuffer: ^ZBuffer) {
    free(zBuffer)
}