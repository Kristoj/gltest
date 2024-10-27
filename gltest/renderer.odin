package gltest

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:strings"

import "vendor:glfw"

import gl "vendor:opengl"
import stbi "vendor:stb/image"

Mesh :: struct
{
	vertices:   []Vertex,
	indices:    []u16,
	vao:        u32,
	vbo:        u32,
	ebo:        u32,
	attribSize: i32,
}

Primitive :: enum
{
	Cube,
	Plane,	
}

RenderBatch :: struct
{
	mesh:   MeshHandle,
	shader: ShaderHandle,
}

Shader :: struct
{
	id: u32,
}

Texture :: struct
{
	id: u32
}

ShaderHandle  :: distinct u32
MeshHandle    :: distinct u32
TextureHandle :: distinct u32

RenderStorage :: struct
{
	shaders:  [dynamic]Shader,
	meshes:   [dynamic]Mesh,
	textures: [dynamic]Texture
}

renderStorage: RenderStorage
renderBatches: [dynamic]RenderBatch
myCubePositions: [10]Vec3
proj: Mat4


get_mesh :: proc { get_mesh_by_handle, get_mesh_primitive }

get_mesh_by_handle :: proc(handle: MeshHandle) -> ^Mesh
{
	return &renderStorage.meshes[handle]
}

get_mesh_primitive :: proc(primitive: Primitive) -> ^Mesh
{
	return &renderStorage.meshes[primitive]
}

get_shader :: proc { get_shader_by_handle }
get_shader_by_handle :: proc(handle: ShaderHandle) -> ^Shader
{
	return &renderStorage.shaders[handle]
}

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

init_renderer :: proc()
{
	// Load meshes
	load_mesh("res/models/cube.gltf")
	load_mesh("res/models/plane.gltf")
	load_mesh("res/models/spitter.gltf")
	load_mesh("res/models/sphere.gltf")
	
	// Create Shaders
	create_shader("res/shaders/test.vs", "res/shaders/test.fs")
	create_shader("res/shaders/light_source.vs", "res/shaders/light_source.fs")

	// Lighting
	create_directional_light({1, 0}, {0, 0, 0}, 1)

	proj = linalg.matrix4_perspective_f32(camera.fov, f32(window.width) / f32(window.height), 0.1, 100, true)
	for shader in renderStorage.shaders
	{
		gl.UseProgram(shader.id)
		loc := gl.GetUniformLocation(shader.id, "proj")
		gl.UniformMatrix4fv(loc, 1, gl.FALSE, &proj[0][0])
	}
	gl.UseProgram(0)

	create_texture("res/tex/wood_col.png", gl.RGB)
	create_texture("res/tex/mud_col.png", gl.RGB)
	
	gl.ClearColor(0.1, 0.1, 0.1, 1)
	gl.Enable(gl.DEPTH_TEST)
}

tick_renderer :: proc()
{
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	// Update view TODO: Should do this a bit better later
	lightDir := Vec3{-0.5, -0.5, -0.5}
	ambientCol := Vec3{0.03, 0.03, 0.03}
	lightCol := Vec3{0, 0, 1}

	create_directional_light({0, 0}, {1, 0, 0}, 1)
	
	lightPos := Vec3{-3, 2, 0}
	lightPos.x = math.sin(f32(glfw.GetTime())) * 1
	// lightPos.z = math.cos(f32(glfw.GetTime())) * 3
	// lightPos.y *= -1
	fmt.println(lightPos)
	
	for shader in renderStorage.shaders
	{
		gl.UseProgram(shader.id)
		
		// Lighting
		loc := gl.GetUniformLocation(shader.id, "ambientCol")
		gl.Uniform3fv(loc, 1, &ambientCol[0])
		loc = gl.GetUniformLocation(shader.id, "lightDir")
		gl.Uniform3fv(loc, 1, &lightDir[0])
		loc = gl.GetUniformLocation(shader.id, "dirlightDir")
		gl.Uniform3fv(loc, 1, &scene.lights.directional.direction[0])
		loc = gl.GetUniformLocation(shader.id, "dirlightCol")
		gl.Uniform3fv(loc, 1, &scene.lights.directional.color[0])

		// Point light
		loc = gl.GetUniformLocation(shader.id, "lightPos")
		gl.Uniform3fv(loc, 1, &lightPos[0])
		loc = gl.GetUniformLocation(shader.id, "constant")
		gl.Uniform1f(loc, 1.0)
		loc = gl.GetUniformLocation(shader.id, "linear")
		gl.Uniform1f(loc, 0.09)
		loc = gl.GetUniformLocation(shader.id, "quadratic")
		gl.Uniform1f(loc, 0.032)
		loc = gl.GetUniformLocation(shader.id, "lightCol")
		gl.Uniform3fv(loc, 1, &lightCol[0])
		
		loc = gl.GetUniformLocation(shader.id, "view")
		view := get_camera_view_matrix()
		gl.UniformMatrix4fv(loc, 1, gl.FALSE, &view[0][0])
	}
	gl.UseProgram(0)

	// Draw cube
	bind_shader(0)
	gl.BindTexture(gl.TEXTURE_2D, renderStorage.textures[0].id)
	draw_mesh(0, {-2, 0, 0}, 0, 1, {1, 0, 1}, 0)
	draw_mesh(0, {-2, 2, 0}, 0, 1, {1, 0, 1}, 0)
	draw_mesh(0, {-2, 4, 0}, 0, 1, {1, 0, 1}, 0)
	
	// Drawn Plane
	gl.BindTexture(gl.TEXTURE_2D, renderStorage.textures[1].id)
	draw_mesh(1, 0, 0, 1, 1, 0)

	// Draw spitter
	draw_mesh(2, {0, 1.5, 0}, {0, math.PI / 2, 0}, 1, 1, 0)
	// Draw sphere
	draw_mesh(3, {3, 3, 0}, 0, 0.5, {0, 1, 0}, 0)

	// Draw light source
	bind_shader(1)
	draw_mesh(0, {lightPos.x, lightPos.y, lightPos.z}, 0, 0.3, {1, 0, 0}, 1)

	
	
	// Draw ground plane
	// gl.BindTexture(gl.TEXTURE_2D, renderStorage.textures[1].id)
	// draw_primitive(Primitive.Plane, 0, {}, 2, {0.05, 0.05, 0.05}, 0, true)
	
	glfw.SwapBuffers(window.handle)
}

cleanup_renderer :: proc()
{
	for &mesh in renderStorage.meshes
	{
		gl.DeleteVertexArrays(1, &mesh.vao)	
		gl.DeleteBuffers(1, &mesh.vbo)
		gl.DeleteBuffers(1, &mesh.ebo)
	}


	delete(renderStorage.meshes)
	delete(renderStorage.shaders)
}


create_shader :: proc(vsName, fsName: string) -> (handle: ShaderHandle)
{
	id, ok := gl.load_shaders_file(vsName, fsName)
	assert(ok == true, "Could not load shader")
		

	// NOTE: We maybe need to free id 
	append(&renderStorage.shaders, Shader {id = id})
	return ShaderHandle(len(renderStorage.shaders) - 1)
}

bind_shader :: proc(handle: ShaderHandle)
{
	gl.UseProgram(renderStorage.shaders[handle].id)
}


draw_mesh :: proc(mHandle: MeshHandle, pos, rot, scale, col: Vec3, sHandle: ShaderHandle)
{
	col := col
	
	model := IDENTITY
	model *= scale_mat(scale)
	model *= linalg.matrix4_from_euler_angles_xyz_f32(rot.x, rot.y, rot.z)
	model *= translate_mat({pos.x, pos.y, pos.z})
	
	mesh   := get_mesh(mHandle)
	shader := get_shader(sHandle)
		
	loc := gl.GetUniformLocation(renderStorage.shaders[sHandle].id, "model")
	gl.UniformMatrix4fv(loc, 1, gl.FALSE, &model[0][0])
	
	gl.BindVertexArray(mesh.vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)
	
	gl.DrawElements(gl.TRIANGLES, i32(len(mesh.indices)), gl.UNSIGNED_SHORT, nil)		
	
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}
