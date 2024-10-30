package gltest

import gl "vendor:opengl"

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


get_shader :: proc { get_shader_by_handle }
get_shader_by_handle :: proc(handle: ShaderHandle) -> ^Shader
{
	return &renderStorage.shaders[handle]
}

set_uniform_vec3 :: proc(id: u32, name: cstring, value: Vec3)
{
	loc := gl.GetUniformLocation(id, name) // TODO: Check if the uniform exists 
	gl.Uniform3f(loc, value.x, value.y, value.z)
}

set_uniform_vec3_v :: proc(id: u32, name: cstring, values: []Vec3)
{
	loc := gl.GetUniformLocation(id, name) // TODO: Check if the uniform exists 
	values := values
	gl.Uniform3fv(loc, i32(len(values)) * 3, raw_data(&values[0]))
}

set_uniform_vec2 :: proc(id: u32, name: cstring, value: Vec2)
{
	loc := gl.GetUniformLocation(id, name) // TODO: Check if the uniform exists 
	gl.Uniform2f(loc, value.x, value.y)
}

set_uniform_f32 ::proc(id: u32, name: cstring, value: f32)
{
	loc := gl.GetUniformLocation(id, name) // TODO: Check if the uniform exists 
	gl.Uniform1f(loc, value)
}

set_uniform_mat4 :: proc(id: u32, name: cstring, value: Mat4)
{
	loc := gl.GetUniformLocation(id, name) // TODO: Check if the uniform exists 
	value := value
	gl.UniformMatrix4fv(loc, 1, false, &value[0][0])
}

set_uniform :: proc {set_uniform_vec3, set_uniform_vec2, set_uniform_f32, set_uniform_mat4}
