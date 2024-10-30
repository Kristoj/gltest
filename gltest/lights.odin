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

PointLights :: struct(N: int)
{
	positions:   [N]Vec3,
	colors:      [N]Vec3,
	intensities: [N]f32,
	
	falloffSettings: LightFalloffSettings,
}


SpotLights :: struct(N: int)
{
	positions:   [N]Vec3,
	directions:  [N]Vec3,
	colors:      [N]Vec3,
	intensitys:  [N]f32,

	falloffSettings: LightFalloffSettings,
}

Scene :: struct
{
	directionalLight: DirectionalLight,
	pointLights:      PointLights(128),
	pointLightCount:  int,
	// spotLights:       [dynamic]SpotLight,
}
scene: Scene

LightFalloffSettings :: struct
{
	constant:  f32,
	linear:    f32,
	quadratic: f32,
}

LFOS_DEFAULT :: LightFalloffSettings {
	constant  = 1,
	linear    = 0.09,
	quadratic = 0.832,
}

create_directional_light :: proc(rotation: Vec2, color: Vec3, intensity: f32)
{
	dir: Vec3 
	dir.x = math.cos(rotation.y + math.PI / 2) * math.cos(rotation.x)
	dir.y = math.sin(rotation.x)
	dir.y = math.sin(rotation.y + math.PI / 2) * math.cos(rotation.x)
	dir = linalg.normalize0(dir)
	
	scene.directionalLight = DirectionalLight {
		direction = dir,
		color = color,
		intensity = intensity,
	}
}

create_point_light :: proc(pos: Vec3, color: Vec3, intensity: f32, lfs: LightFalloffSettings)
{
	index := scene.pointLightCount
	lights := &scene.pointLights
	lights.positions[index] = pos
	lights.colors[index] = color
	lights.intensities[index] = intensity
	lights.falloffSettings = lfs
	
	scene.pointLightCount += 1
}
