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


Window :: struct
{
	width : i32,	
	height: i32,
	aspectRatio: f32,
	handle: glfw.WindowHandle,
}
window: Window

init_window :: proc()
{
	window.width  = 1600
	window.height = 900
	window.aspectRatio = f32(1600) / f32(900)
	
	if glfw.Init() == false do panic("Could not init GLFW")
	
	window.handle = glfw.CreateWindow(window.width, window.height, "OpenGL Test", nil, nil)	
	if window.handle == nil do panic("Could not create window")
	
	glfw.WindowHint(glfw.VERSION_MAJOR, 4)
	glfw.WindowHint(glfw.VERSION_MINOR, 6)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	glfw.SetKeyCallback(window.handle, key_callback)
	glfw.SetCursorPosCallback(window.handle, cursor_pos_callback)
	glfw.SetFramebufferSizeCallback(window.handle, framebuffer_size_callback)

	glfw.MakeContextCurrent(window.handle)
	gl.load_up_to(4, 6, glfw.gl_set_proc_address)

	gl.ClearColor(0.1, 0.1, 0.1, 1)
	gl.Viewport(0, 0, window.width, window.height)
	glfw.SetInputMode(window.handle, glfw.CURSOR, glfw.CURSOR_DISABLED)

	// Target fps
	glfw.SwapInterval(0)
	frame.targetFps = 144
	
	
	// Inits here
	init_camera()
	init_renderer()
	
	main_loop()
}

main_loop :: proc()
{
	for !glfw.WindowShouldClose(window.handle)
	{
		glfw.PollEvents()

		if frame.lastFrametime + (1 / f64(frame.targetFps)) > glfw.GetTime()
		{
			continue
		}
		// print_fps()
		
		// Update frame times
		frame.dt = f32(glfw.GetTime() - frame.lastFrametime)
		frame.lastFrametime = glfw.GetTime()
				
		tick_input()
		tick_camera()
		tick_renderer()

		reset_input()
	}

	cleanup_window()
}

print_fps :: proc()
{
	frame.fps += 1
	now := glfw.GetTime()
	if now >= frame.nextFpsUpdateTime
	{
		fmt.println("FPS:", frame.fps)
		frame.fps = 0
		frame.nextFpsUpdateTime = now + 1 
	}
}

cleanup_window :: proc()
{
	cleanup_renderer()
	cleanup_camera()
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: c.int)
{
	gl.Viewport(0, 0, width, height)
}

