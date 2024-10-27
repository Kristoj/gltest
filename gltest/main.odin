package gltest

import "core:log"
import "core:fmt"
import "core:math/linalg"

Vec2 :: linalg.Vector2f32
Vec3 :: linalg.Vector3f32
Mat4 :: linalg.Matrix4x4f32

translate_mat :: linalg.matrix4_translate_f32
scale_mat     :: linalg.matrix4_scale_f32
rotate_mat    :: linalg.matrix4_rotate_f32

OPENGL_VERSION_MAJOR :: 4
OPENGL_VERSION_MINOR :: 6

IDENTITY :: linalg.MATRIX4F32_IDENTITY



FrameData :: struct
{
	dt: f32,
	lastFrametime: f64,
	fps: int,
	targetFps: int,
	nextFpsUpdateTime: f64,
}
frame: FrameData

main :: proc()
{
	context.logger = log.create_console_logger(
		log.Level.Debug, 
	{
		log.Option.Short_File_Path, 
		log.Option.Line, 
		log.Option.Level
 	})

	fmt.println("")
	init_window()
}










/*
draw_new :: proc()
{

    // Load, compile and link shader
	shaderProgram, success := gl.load_shaders("res/test.vs", "res/test.fs")
	assert(success == true, "Could not load shader")
	defer gl.DeleteProgram(shaderProgram)
	uniformInfos := gl.get_uniforms_from_program(shaderProgram)

    vbo, vao: u32
    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)
    defer gl.DeleteVertexArrays(1, &vao)
    
    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)
    defer gl.DeleteBuffers(1, &vbo)

    gl.EnableVertexAttribArray(0)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(f32) * 5, uintptr(0))

	gl.Enable(gl.DEPTH_TEST)
	// glfw.SwapInterval(0)



	
	vaoPlane, vboPlane, eboPlane: u32
	gl.GenVertexArrays(1, &vaoPlane)
	gl.BindVertexArray(vaoPlane)
	defer gl.DeleteVertexArrays(1, &vaoPlane)

	gl.GenBuffers(1, &vboPlane)
	gl.BindBuffer(gl.ARRAY_BUFFER, vboPlane)
	// gl.BufferData(gl.ARRAY_BUFFER, size_of(planeVertices), &planeVertices, gl.STATIC_DRAW)
	defer gl.DeleteBuffers(1, &vboPlane)

	gl.GenBuffers(1, &vboPlane)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, eboPlane)
	// gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(planeIndices), &planeIndices, gl.STATIC_DRAW)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(f32) * 3, uintptr(0))
	
	
	view := IDENTITY
	proj := IDENTITY
	proj  = linalg.matrix4_perspective_f32(math.to_radians_f32(90), f32(window.width) / f32(window.height), 0.1, 1000, true)
	camera.position = {0, 5, -3}
	camera.moveSpeed = 10
	camera.forward = {0, -1, 0}
	
	for !glfw.WindowShouldClose(window.handle)
	{
		glfw.PollEvents()
		check_input()
		frame.dt = f32(glfw.GetTime() - frame.lastFrametime)
		frame.lastFrametime = glfw.GetTime()

		//view = linalg.matrix4_look_at_f32(camera.position, camera.position + camera.forward, {0, 1, 0})
		fmt.printf("camera pos: %f \n", camera.position)
		camPos :=  Vec3{-camera.position.x, -camera.position.y, camera.position.z}
		view = linalg.matrix4_translate_f32(camPos)
		//view = linalg.matrix4_look_at_f32(camPos, camPos + camera.forward, {0, 0, 1}) // NOTE: RELIIKKI
		
		gl.UniformMatrix4fv(uniformInfos["projection"].location, 1, gl.FALSE, &proj[0][0])
		gl.UniformMatrix4fv(uniformInfos["view"].location, 1, gl.FALSE, &view[0][0])

		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		// draw cubes
		for i in 0..<10
		{
			model := IDENTITY
			model = linalg.matrix4_translate_f32(cubePositions[i])
			gl.UniformMatrix4fv(uniformInfos["model"].location, 1, gl.FALSE, &model[0][0])
		    gl.UseProgram(shaderProgram)
		    gl.BindVertexArray(vao)
			// gl.DrawArrays(gl.TRIANGLES, 0, 36)
		}

		for i in 0..<1
		{
			model := IDENTITY
			//model *= linalg.matrix4_rotate_f32(1, {0, 1, 0})
						
			gl.UniformMatrix4fv(uniformInfos["model"].location, 1, gl.FALSE, &model[0][0])
			gl.BindVertexArray(vaoPlane)
			// gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, &planeIndices)
		}

		reset_input()
		glfw.SwapBuffers(window.handle)
	}
}


draw_double :: proc()
{
	// Load shader
	shader, ok := gl.load_shaders_file("res/test.vs", "res/test.fs")
	assert(ok == true, "Could not load shader")
	gl.UseProgram(shader)
	info := gl.get_uniforms_from_program(shader)

	vao1, vbo1, vao2, vbo2: u32

	// Generate vao 1
	gl.GenVertexArrays(1, &vao1)
	gl.BindVertexArray(vao1)

	// Gen vbo 1
	gl.GenBuffers(1, &vbo1)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo1)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

	// Vertex attrib
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(f32) * 5, uintptr(0))
	
	// Gen VAO 2
	gl.GenVertexArrays(1, &vao2)
	gl.BindVertexArray(vao2)

	// Gen vbo 2
	gl.GenBuffers(1, &vbo2)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo2)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(planeVertices), &planeVertices, gl.STATIC_DRAW)
	
	ebo: u32
	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(planeIndices), &planeIndices, gl.STATIC_DRAW)

	// Vertex attrib 2
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), uintptr(0))


	gl.ClearColor(0.1, 0.1, 0.1, 1)
	gl.Enable(gl.DEPTH_TEST)

	camera.position = {0, 2, -3}
	camera.fov = math.to_radians_f32(90)

	proj := linalg.matrix4_perspective_f32(camera.fov, f32(window.width) / f32(window.height), 0.1, 100, true)
	gl.UniformMatrix4fv(info["projection"].location, 1, false, &proj[0][0])
	
	for !glfw.WindowShouldClose(window.handle)
	{
		glfw.PollEvents()
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)


		view := IDENTITY		
		sin := f32(math.sin(glfw.GetTime()))
		camera.position.x = sin
		// camera.position.y = sin
		// camera.position.z = sin
		view *= translate_mat({-camera.position.x, -camera.position.y, camera.position.z})
		fmt.println("camera pos:", camera.position)
		gl.UniformMatrix4fv(info["view"].location, 1, gl.FALSE, &view[0][0])		
		gl.Uniform3f(info["colTest"].location, 0, 0, 1)
		gl.BindVertexArray(vao1)
		
		for i in 0..<10
		{
			model := IDENTITY
			model *= translate_mat(cubePositions[i])
			gl.UniformMatrix4fv(info["model"].location, 1, gl.FALSE, &model[0][0])		
			gl.DrawArrays(gl.TRIANGLES, 0, 36)
		}
		


		
		model := IDENTITY
		// model *= translate({0, -1, 0})
		gl.Uniform3f(info["colTest"].location, 0, 1, 0)
		gl.UniformMatrix4fv(info["model"].location, 1, gl.FALSE, &model[0][0])		
		gl.BindVertexArray(vao2)
		gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
		
		glfw.SwapBuffers(window.handle)
	}
}
*/


