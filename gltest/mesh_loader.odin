package gltest

import "core:log"
import "core:mem"

import gl "vendor:opengl"
import "vendor:cgltf"

load_mesh :: proc(name: cstring) -> MeshHandle
{
	data, result := cgltf.parse_file({}, name)
	log.assert(result == .success, "Could not load mesh file")
	defer cgltf.free(data)

	result = cgltf.load_buffers({}, data, name)
	log.assert(result == .success, "could not load buffer")

	positions := parse_mesh_data(Vec3, &data.accessors[0])
	normals   := parse_mesh_data(Vec3, &data.accessors[1])
	uvs       := parse_mesh_data(Vec2, &data.accessors[2])
	indices   := parse_mesh_data(u16,  &data.accessors[3])

	mesh: Mesh
	mesh.indices = indices
	mesh.vertices = make([]Vertex, len(positions))
	for &v, i in mesh.vertices
	{
		v.position = positions[i]
		v.normal   = normals[i]
		v.uv       = uvs[i]
	}



	// Generate VAO
	vao, vbo, ebo: u32
	
	mesh.attribSize = 8 // TODO: Hard coded for now
	
	sizeVertices := int(size_of(Vertex) * len(mesh.vertices))
	
	gl.CreateVertexArrays(1, &vao)
	gl.BindVertexArray(vao)
	
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, sizeVertices, &mesh.vertices[0], gl.STATIC_DRAW)

	// Ebo
	if len(mesh.indices) > 0
	{
		gl.GenBuffers(1, &ebo)	
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
		gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(u16) * len(mesh.indices), &mesh.indices[0], gl.STATIC_DRAW)
	}

	// Position
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), uintptr(0))
	
	// Normal
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), uintptr(size_of(f32) * 3))
	
	// UV
	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, size_of(Vertex), uintptr(size_of(f32) * 6))

	// Remember to unbind all NOTE: Onks oikee order
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
	
	mesh.vao = vao
	mesh.vbo = vbo
	mesh.ebo = ebo

	append(&renderStorage.meshes, mesh)
	return MeshHandle(len(renderStorage.meshes) - 1)
}

parse_mesh_data :: proc($T: typeid, accessor: ^cgltf.accessor) -> []T
{
	start      := accessor.buffer_view.buffer.data
	size       := accessor.buffer_view.size
	baseOffset := accessor.buffer_view.offset
	stride     := accessor.stride
	count      := accessor.count

	slice := make([]T, size / stride)
	
	for i in 0..<count
	{
		src := uintptr(start) + uintptr(baseOffset) + uintptr(stride * i)
		mem.copy(&slice[i], rawptr(src), int(stride))
	}

	return slice
}
