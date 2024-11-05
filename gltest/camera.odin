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
	camera.position = {0, 2, 3}
	camera.moveSpeed = 5
	camera.rotateSpeed = 0.0009
}

tick_camera :: proc()
{
	rotate_camera()
	update_camera_vectors()
	move_camera()
}

get_camera_view_matrix :: proc() -> Mat4
{
	return linalg.matrix4_look_at_f32(camera.position, camera.position + camera.forward, camera.up, true)
}

cleanup_camera :: proc()
{
	
}

update_camera_vectors :: proc()
{
	yaw := camera.yaw - (math.PI * 0.5)
	forward: Vec3
	forward.x = math.cos(yaw)  * math.cos(camera.pitch) 
	forward.y = math.sin(camera.pitch)
	forward.z = math.sin(yaw)  * math.cos(camera.pitch) 
	camera.forward = linalg.normalize0(forward)

	camera.right = linalg.normalize0(linalg.cross(camera.forward, Vec3{0, 1, 0}))
	camera.up    = linalg.normalize0(linalg.cross(camera.right, camera.forward))
}

rotate_camera :: proc()
{
	speed := camera.rotateSpeed   
	camera.yaw   += input.mouseDelta.x * speed
	camera.pitch -= input.mouseDelta.y * speed  

	// Clamp camera rotation
	maxAngle := f32(math.PI * 0.49)
	camera.pitch = math.clamp(camera.pitch, -maxAngle, maxAngle)
}

move_camera :: proc()
{
	velocity := camera.moveSpeed * frame.dt
	camera.position += camera.right   * input.move.x * velocity
	camera.position += camera.up      * input.move.y * velocity
	camera.position += camera.forward * input.move.z * velocity
}
