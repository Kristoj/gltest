package gltest

import "core:fmt"

import gl   "vendor:opengl"
import stbi "vendor:stb/image"

create_texture :: proc(name: cstring, desiredChannels: i32) -> TextureHandle
{
	// Gen and bind texture
	tex: u32
	gl.GenTextures(1, &tex)
	gl.BindTexture(gl.TEXTURE_2D, tex)

	// Set texture params
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_NEAREST)
	
	// Load texture file
	width, height, channels: i32
	file := stbi.load(name, &width, &height, &channels, 0)
	if file == nil
	{
		fmt.panicf("Could not open texture file: %s", stbi.failure_reason())
	}
	defer stbi.image_free(file)

	gl.TexImage2D(gl.TEXTURE_2D, 0, desiredChannels, width, height, 0, u32(desiredChannels), gl.UNSIGNED_BYTE, file)
	gl.GenerateMipmap(gl.TEXTURE_2D)
	
	append(&renderStorage.textures, Texture {id = tex})

	return TextureHandle(len(renderStorage.textures) - 1)
}

