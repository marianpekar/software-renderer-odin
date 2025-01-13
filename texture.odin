package main 

import rl "vendor:raylib"

Texture :: struct {
    width: i32,
    height: i32,
    pixels: [^]rl.Color
}

LoadTextureFromFile :: proc(filename: cstring) -> Texture {
    image := rl.LoadImage(filename)
    pixels := rl.LoadImageColors(image)

    texture := Texture{
        width = image.width,
        height = image.height,
        pixels = pixels
    }

    rl.UnloadImage(image)
    
    return texture
}