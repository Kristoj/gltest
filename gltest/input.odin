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

Input :: struct
{
	move:           Vec3,
	mouseDelta:     Vec2,
	lastCursorPos:  Vec2,
}
input: Input


tick_input :: proc()
{
	update_cursor_pos()
    check_input()	
}

reset_input :: proc()
{
	input.move = 0
	input.mouseDelta = 0
}

firstInputFrame := true
check_input :: proc()
{
	if glfw.GetKey(window.handle, glfw.KEY_W) == glfw.PRESS do input.move.z += 1
	if glfw.GetKey(window.handle, glfw.KEY_S) == glfw.PRESS do input.move.z -= 1
	if glfw.GetKey(window.handle, glfw.KEY_D) == glfw.PRESS do input.move.x += 1
	if glfw.GetKey(window.handle, glfw.KEY_A) == glfw.PRESS do input.move.x -= 1
	
	if glfw.GetKey(window.handle, glfw.KEY_E) == glfw.PRESS do input.move.y += 1
	if glfw.GetKey(window.handle, glfw.KEY_Q) == glfw.PRESS do input.move.y -= 1
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: c.int)
{
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS
	{
		glfw.SetWindowShouldClose(window, true)
	}
}

update_cursor_pos :: proc()
{
	// First frame stuff
	if firstInputFrame
	{
		input.lastCursorPos = glfw.GetCursorPosVec(window.handle)
		firstInputFrame = false
	}
	
	cpos := glfw.GetCursorPosVec(window.handle)
	input.mouseDelta = cpos - input.lastCursorPos 
	input.lastCursorPos = cpos
}

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xpos,  ypos: f64)
{
}
