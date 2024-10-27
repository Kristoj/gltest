package gltest

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:c"
import "core:strings"
import "core:os"
import "base:intrinsics"
import "core:time"
import "base:runtime"
import "base:builtin"

import gl "vendor:opengl"
import "vendor:glfw"
import "vendor:stb/truetype"


/*
triangle_draw :: proc()
{
	program, success := gl.load_shaders_file("res/test.vs", "res/test.fs")
	if !success do panic("Could not load shader")

	vao: u32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)
	defer gl.DeleteVertexArrays(1, &vao)
	
    // setup vbo
    vertex_data := [?]f32 {
        -0.3, -0.3,
         0.3, -0.3,
         0.0,  0.5,
    }

    vbo: u32
    gl.GenBuffers(1, &vbo)
    defer gl.DeleteBuffers(1, &vbo)

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertex_data), &vertex_data, gl.STATIC_DRAW)

    gl.EnableVertexAttribArray(0)
    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 0, uintptr(0))
    
    for !glfw.WindowShouldClose(window.handle)
    {
    	glfw.PollEvents()
    	gl.Clear(gl.COLOR_BUFFER_BIT)
    	
		gl.UseProgram(program)
		gl.BindVertexArray(vao)
		gl.DrawArraysInstanced(gl.TRIANGLES, 0, 3, 1)
		
    	glfw.SwapBuffers(window.handle)
    }
}

cube_draw :: proc()
{
	cube_vertices := [?]Vec3 {
	    {-0.5, -0.5, -0.5}, { 0.5, -0.5, -0.5}, { 0.5, -0.5,  0.5}, {-0.5, -0.5,  0.5},
	    {-0.5, -0.5, -0.5}, {-0.5, -0.5,  0.5}, {-0.5,  0.5,  0.5}, {-0.5,  0.5, -0.5},
	    {-0.5, -0.5,  0.5}, { 0.5, -0.5,  0.5}, { 0.5,  0.5,  0.5}, {-0.5,  0.5,  0.5},
	    {-0.5,  0.5, -0.5}, {-0.5,  0.5,  0.5}, { 0.5,  0.5,  0.5}, { 0.5,  0.5, -0.5},
	    { 0.5, -0.5, -0.5}, { 0.5,  0.5, -0.5}, { 0.5,  0.5,  0.5}, { 0.5, -0.5,  0.5},
	    {-0.5, -0.5, -0.5}, {-0.5,  0.5, -0.5}, { 0.5,  0.5, -0.5}, { 0.5, -0.5, -0.5},
	}

	cube_normals := [?]Vec3 {
	    { 0.0, -1.0,  0.0}, { 0.0, -1.0,  0.0}, { 0.0, -1.0,  0.0}, { 0.0, -1.0,  0.0},
	    {-1.0,  0.0,  0.0}, {-1.0,  0.0,  0.0}, {-1.0,  0.0,  0.0}, {-1.0,  0.0,  0.0},
	    { 0.0,  0.0,  1.0}, { 0.0,  0.0,  1.0}, { 0.0,  0.0,  1.0}, { 0.0,  0.0,  1.0},
	    { 0.0,  1.0,  0.0}, { 0.0,  1.0,  0.0}, { 0.0,  1.0,  0.0}, { 0.0,  1.0,  0.0},
	    { 1.0,  0.0,  0.0}, { 1.0,  0.0,  0.0}, { 1.0,  0.0,  0.0}, { 1.0,  0.0,  0.0},
	    { 0.0,  0.0, -1.0}, { 0.0,  0.0, -1.0}, { 0.0,  0.0, -1.0}, { 0.0,  0.0, -1.0},
	};

	cube_elements := [?]u32 {
	     0,  1,  2,   0,  2,  3,
	     4,  5,  6,   4,  6,  7,
	     8,  9, 10,   8, 10, 11,
	    12, 13, 14,  12, 14, 15,
	    16, 17, 18,  16, 18, 19,
	    20, 21, 22,  20, 22, 23,
	};

	program, success := gl.load_shaders("res/cubes.vs", "res/cubes.fs")
	assert(success != false, "Could not load shader")
	defer gl.DeleteProgram(program)

	uniformInfos := gl.get_uniforms_from_program(program)

	count :: 64
	positions := make([]Vec3, count * count * count)
	defer delete(positions)

	for k in 0..<count
	{
		for j in 0..<count
		{
			for i in 0..<count
			{
				positions[k * count * count + j * count + i] = {f32(i) * 1.5, f32(j) * 1.5, f32(k) * 1.5}
			}
		}
	}

	vao, vboPos, vboNormal, ebo, vboInstanced: u32

	gl.GenVertexArrays(1, &vao)
	gl.GenBuffers(1, &vboPos)
	gl.GenBuffers(1, &vboNormal)
	gl.GenBuffers(1, &vboInstanced)
	gl.GenBuffers(1, &ebo)

	defer  {
		gl.DeleteVertexArrays(1, &vao)
		gl.DeleteBuffers(1, &vboPos)
		gl.DeleteBuffers(1, &vboNormal)
		gl.DeleteBuffers(1, &vboInstanced)
		gl.DeleteBuffers(1, &ebo)
	}
	
	gl.BindVertexArray(vao)

	gl.EnableVertexAttribArray(0)
	gl.EnableVertexAttribArray(1)
	gl.EnableVertexAttribArray(2)
	
	gl.VertexAttribDivisor(0, 0)
	gl.VertexAttribDivisor(1, 0)
	gl.VertexAttribDivisor(2, 1)

	gl.BindBuffer(gl.ARRAY_BUFFER, vboPos)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(cube_vertices), &cube_vertices[0], gl.STATIC_DRAW)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, uintptr(0))

	gl.BindBuffer(gl.ARRAY_BUFFER, vboNormal)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(cube_normals), &cube_normals[0], gl.STATIC_DRAW)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 0, uintptr(0))

	gl.BindBuffer(gl.ARRAY_BUFFER, vboInstanced)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(Vec3) * len(positions), &positions[0], gl.STATIC_DRAW)
	gl.VertexAttribPointer(2, 3, gl.FLOAT, gl.FALSE, 0, uintptr(0))

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(cube_elements), &cube_elements[0], gl.STATIC_DRAW)

	Camera :: struct
	{
		position: Vec3,
		right:    Vec3,
		forward:  Vec3,
		up:       Vec3,
	}

	cam: Camera
	cam.position = {0, 0, -10}
	cam.right   =  {1, 0, 0}
	cam.up      =  {0, 1, 0}
	cam.forward =  {0, 0, 1}

	tPrev := glfw.GetTime()
	gl.Enable(gl.DEPTH_TEST)
	gl.ClearColor(0.1, 0.1, 0.1, 1)
	
	for !glfw.WindowShouldClose(window.handle)
	{
		glfw.PollEvents()

		tNow := glfw.GetTime()
		dt := f32(tNow - tPrev)
		tPrev = tNow

		V := linalg.matrix4_look_at_f32(cam.forward, cam.position, cam.up, true)
		P := linalg.matrix4_perspective_f32(math.to_radians_f32(80), f32(f32(window.width) / f32(window.height)), 0.1, 1000)
		MVP := linalg.mul(P, V)

		gl.Clear(gl.COLOR_BUFFER_BIT)

		gl.UseProgram(program)
		gl.Uniform1f(uniformInfos["time"].location, f32(glfw.GetTime()))
		gl.UniformMatrix4fv(uniformInfos["MVP"].location, 1, gl.FALSE, &MVP[0][0])
		
		gl.BindVertexArray(vao)
		gl.DrawElementsInstanced(gl.TRIANGLES, len(cube_elements), gl.UNSIGNED_INT, nil, count * count * count)

		glfw.SwapBuffers(window.handle)
	}
}
*/
