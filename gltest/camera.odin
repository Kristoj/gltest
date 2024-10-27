package gltest

import "core:log"
import "core:math"
import "core:math/linalg"

import gl "vendor:opengl"
import "vendor:glfw"

// Aligment bugi fixi sit joskus tanne
Camera :: struct #align(16)
{
	position:    Vec3,
	right:       Vec3,
	up:          Vec3,
	forward:     Vec3,
	
	yaw:         f32,
	pitch:       f32,
	
	moveSpeed:   f32,
	rotateSpeed: f32,
	fov:         f32,
}
camera: Camera

init_camera :: proc()
{
	// Setup camera
	camera.fov = math.PI / 2
	camera.position = {0, 3, 3}
	camera.moveSpeed = 5
	camera.rotateSpeed = 1
}

tick_camera :: proc()
{
	move_camera()
	rotate_camera()
}

get_camera_view_matrix :: proc() -> Mat4
{
	camPos := Vec3{camera.position.x, camera.position.y, camera.position.z}
	view := linalg.matrix4_look_at_f32(camPos, camPos + camera.forward, camera.up, true)
	return view
}

cleanup_camera :: proc()
{
	
}

rotate_camera :: proc()
{
	camera.pitch -= input.mouseDelta.y * camera.rotateSpeed * frame.dt
	camera.yaw   += input.mouseDelta.x * camera.rotateSpeed * frame.dt
	pitch := camera.pitch
	yaw := camera.yaw + (math.PI * -0.0)
	
	camera.forward.x = math.cos(yaw) * math.cos(pitch)
	camera.forward.y = math.sin(pitch)  
	camera.forward.z = math.sin(yaw) * math.cos(pitch)
	camera.forward = linalg.normalize0(camera.forward)

	camera.right = linalg.normalize0(linalg.cross(camera.forward, Vec3{0, 1, 0}))
	camera.up    = linalg.normalize0(linalg.cross(camera.right, camera.forward))
}

move_camera :: proc()
{
	// camera.position += input.move * camera.moveSpeed * frame.dt
	velocity := camera.moveSpeed * frame.dt
	camera.position += camera.right   * input.move.x * velocity
	camera.position += camera.up      * input.move.y * velocity
	camera.position += camera.forward * input.move.z * velocity

}
