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

init_renderer :: proc()
{
	// Load meshes
	load_mesh("res/models/cube.gltf")
	load_mesh("res/models/plane.gltf")
	load_mesh("res/models/spitter.gltf")
	load_mesh("res/models/sphere.gltf")
	
	// Create Shaders
	create_shader("res/shaders/base.vs", "res/shaders/base.fs")
	create_shader("res/shaders/light_source.vs", "res/shaders/light_source.fs")

	proj = linalg.matrix4_perspective_f32(camera.fov, f32(window.width) / f32(window.height), 0.1, 100, true)
	for shader in renderStorage.shaders
	{
		gl.UseProgram(shader.id)
		set_uniform(shader.id, "proj", proj)
	}
	gl.UseProgram(0)

	create_texture("res/tex/wood_col.png", gl.RGB)
	create_texture("res/tex/mud_col.png", gl.RGB)
	create_texture("res/tex/spitter_col.png", gl.RGB)

	// Lights
	p0 := Vec3{1, 3, 0}
	create_point_light(p0, {1, 0, 0}, 1, LFOS_DEFAULT)
	
	gl.ClearColor(0.1, 0.1, 0.1, 1)
	gl.Enable(gl.DEPTH_TEST)
}

spitterPos: Vec3
tick_renderer :: proc()
{
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
	
	// camera.position.x = math.sin(f32(glfw.GetTime()))
	// spitterPos = math.sin(f32(glfw.GetTime()))
	spitterPos.y = 1.5
	lightPos := Vec3{0, 1.5, 0}
	lightPos.x = math.sin(f32(glfw.GetTime())) * 1.0
	// lightPos.y = math.sin(f32(glfw.GetTime())) * 2 + 2
	lightDir := Vec3{0, -1, 0}
	lightPos.z = math.cos(f32(glfw.GetTime())) * 1.0
	pcol := Vec3{0, 1, 0}


	spotPos := Vec3{1, 3, 0}
	spotPos.y = math.sin(f32(glfw.GetTime())) + 1
	
	for shader in renderStorage.shaders
	{
		gl.UseProgram(shader.id)
		// view := translate_mat(camera.position)
		view := get_camera_view_matrix()
		set_uniform(shader.id, "view", view)

		// Directional light
		// set_uniform(shader.id, "dirLight.dir", Vec3{math.sin(f32(glfw.GetTime())), -math.cos(f32(glfw.GetTime())), 1})
		set_uniform(shader.id, "dirLight.col", Vec3{1, 0, 0})

		// Point lights
		p0 := Vec3 {
			math.sin(f32(glfw.GetTime())),
			1.5,
			math.cos(f32(glfw.GetTime()))
		}
		
		set_uniform_vec3(shader.id, "ambientLight", 0.05)

		// update lights
		
		// plights := &scene.pointLights
		// for i in 0..<scene.pointLightCount
		// {
		// 	// set_uniform(shader.id, "pointLights[i]")
		// 	set_uniform_vec3_v(shader.id, "pointLights", plights.positions)
		// }
		
		set_uniform(shader.id, "pointLights[0].pos",  lightPos)
		set_uniform(shader.id, "pointLights[0].col",  pcol)
		set_uniform(shader.id, "pointLights[0].constant",  1.0)
		set_uniform(shader.id, "pointLights[0].linear",    0.09)
		set_uniform(shader.id, "pointLights[0].quadratic", 0.832)
		
		// set_uniform(shader.id, "spotLights[0].pos",  spotPos)
		// set_uniform(shader.id, "spotLights[0].col",  Vec3{1, 0, 0})
		// set_uniform(shader.id, "spotLights[0].dir",  Vec3{0, -1, 0})
		// set_uniform(shader.id, "spotLights[0].constant",  1.0)
		// set_uniform(shader.id, "spotLights[0].linear",    0.09)
		// set_uniform(shader.id, "spotLights[0].quadratic", 0.032)
		// set_uniform(shader.id, "spotLights[0].innerCone", math.cos_f32(math.PI * 0.2))
		// set_uniform(shader.id, "spotLights[0].outerCone", math.cos_f32(math.PI * 0.5))
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
	draw_mesh(1, {0, 0, 0}, 0, 5, 1, 0)
	// Draw spitter
	gl.BindTexture(gl.TEXTURE_2D, renderStorage.textures[2].id)
	draw_mesh(2, spitterPos, {0, -f32(glfw.GetTime() / 2), 0}, 1, 1, 0)
	// Draw sphere
	draw_mesh(3, {3, 3, 0}, 0, 0.5, {0, 1, 0}, 0)
	
	// Draw lights
	bind_shader(1)
	draw_mesh(0, lightPos, 0, 0.3, pcol, 1)
	draw_mesh(0, spotPos, 0, 0.3, {1, 0, 0}, 1)
	
	glfw.SwapBuffers(window.handle)
}

draw_mesh :: proc(mHandle: MeshHandle, pos, rot, scale, col: Vec3, sHandle: ShaderHandle)
{
	col := col
	
	model := translate_mat({pos.x, pos.y, pos.z})
	model *= linalg.matrix4_from_euler_angles_xyz_f32(rot.x, rot.y, rot.z)
	model *= scale_mat(scale)
	
	mesh   := get_mesh(mHandle)
	shader := get_shader(sHandle)
		
	set_uniform(shader.id, "tint", col)
	set_uniform(shader.id, "model", model)
	
	gl.BindVertexArray(mesh.vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)
	
	gl.DrawElements(gl.TRIANGLES, i32(len(mesh.indices)), gl.UNSIGNED_SHORT, nil)		
	
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
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
