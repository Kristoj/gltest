package gltest

import "core:math"
import "core:math/linalg"

import gl "vendor:opengl"

DirectionalLight :: struct
{
	direction: Vec3,
	color:     Vec3,
	intensity: f32,
}

Lights :: struct
{
	directional: DirectionalLight,
}

Scene :: struct
{
	lights: Lights,
}
scene: Scene

create_directional_light :: proc(rotation: Vec2, color: Vec3, intensity: f32)
{
	dir: Vec3 
	dir.x = math.cos(rotation.y + math.PI / 2) * math.cos(rotation.x)
	dir.y = math.sin(rotation.x)
	dir.y = math.sin(rotation.y + math.PI / 2) * math.cos(rotation.x)
	dir = linalg.normalize0(dir)
	
	scene.lights.directional = DirectionalLight {
		direction = dir,
		color = color,
		intensity = intensity,
	}
}
