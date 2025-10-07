package main

import rl "vendor:raylib"

Model :: struct {
    mesh: Mesh,
    texture: Texture,
    color: rl.Color,
    wireColor: rl.Color,
    translation: Vector3,
    rotation: Vector3,
    scale: f32,
}

LoadModel :: proc(meshPath: string, texturePath: cstring, color: rl.Color = rl.WHITE, wireColor: rl.Color = rl.GREEN) -> Model {
    return Model{
        mesh = LoadMeshFromObjFile(meshPath),
        texture = LoadTextureFromFile(texturePath),
        color = color,
        wireColor = wireColor,
        translation = Vector3{0.0, 0.0, 0.0},
        rotation = Vector3{0.0, 0.0, 0.0},
        scale = 1.0
    }
}

ApplyTransformations :: proc(model: ^Model, camera: Camera) {
    translationMatrix := MakeTranslationMatrix(model.translation.x, model.translation.y, model.translation.z)
    rotationMatrix := MakeRotationMatrix(model.rotation.x, model.rotation.y, model.rotation.z)
    scaleMatrix := MakeScaleMatrix(model.scale, model.scale, model.scale)
    modelMatrix := Mat4Mul(translationMatrix, Mat4Mul(rotationMatrix, scaleMatrix))
    viewMatrix  := MakeViewMatrix(camera.position, camera.target)
    viewMatrix  = Mat4Mul(viewMatrix, modelMatrix)

    TransformVertices(&model.mesh.transformedVertices, model.mesh.vertices, viewMatrix)
    TransformVertices(&model.mesh.transformedNormals, model.mesh.normals, viewMatrix)
}

TransformVertices:: proc(transformed: ^[]Vector3, original: []Vector3, mat: Matrix4x4) {
    for i in 0..<len(original) {
        transformed[i] = Mat4MulVec3(mat, original[i])
    }
}

DeleteModel :: proc(model: ^Model) {
    DeleteMesh(&model.mesh)
}