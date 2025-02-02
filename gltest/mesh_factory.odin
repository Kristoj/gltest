package gltest

vertices := [?]f32 {
    -0.5, -0.5, -0.5,  0.0, 0.0,
     0.5, -0.5, -0.5,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
    -0.5,  0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 0.0,

    -0.5, -0.5,  0.5,  0.0, 0.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 1.0,
     0.5,  0.5,  0.5,  1.0, 1.0,
    -0.5,  0.5,  0.5,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,

    -0.5,  0.5,  0.5,  1.0, 0.0,
    -0.5,  0.5, -0.5,  1.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,
    -0.5,  0.5,  0.5,  1.0, 0.0,

     0.5,  0.5,  0.5,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5,  0.5,  0.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 0.0,

    -0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5, -0.5,  1.0, 1.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,

    -0.5,  0.5, -0.5,  0.0, 1.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5,  0.5,  0.5,  1.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 0.0,
    -0.5,  0.5,  0.5,  0.0, 0.0,
    -0.5,  0.5, -0.5,  0.0, 1.0
}

cubeVertices: []Vertex = {
    Vertex{position = {-0.5, -0.5, -0.5}, uv = {0.0, 0.0}}, 
    Vertex{position = { 0.5, -0.5, -0.5}, uv = {1.0, 0.0}}, 
    Vertex{position = { 0.5,  0.5, -0.5}, uv = {1.0, 1.0}}, 
    Vertex{position = { 0.5,  0.5, -0.5}, uv = {1.0, 1.0}}, 
    Vertex{position = {-0.5,  0.5, -0.5}, uv = {0.0, 1.0}}, 
    Vertex{position = {-0.5, -0.5, -0.5}, uv = {0.0, 0.0}}, 

    Vertex{position = {-0.5, -0.5,  0.5}, uv = {0.0, 0.0}}, 
    Vertex{position = { 0.5, -0.5,  0.5}, uv = {1.0, 0.0}}, 
    Vertex{position = { 0.5,  0.5,  0.5}, uv = {1.0, 1.0}}, 
    Vertex{position = { 0.5,  0.5,  0.5}, uv = {1.0, 1.0}}, 
    Vertex{position = {-0.5,  0.5,  0.5}, uv = {0.0, 1.0}}, 
    Vertex{position = {-0.5, -0.5,  0.5}, uv = {0.0, 0.0}}, 

    Vertex{position = {-0.5,  0.5,  0.5}, uv = {1.0, 0.0}}, 
    Vertex{position = {-0.5,  0.5, -0.5}, uv = {1.0, 1.0}}, 
    Vertex{position = {-0.5, -0.5, -0.5}, uv = {0.0, 1.0}}, 
    Vertex{position = {-0.5, -0.5, -0.5}, uv = {0.0, 1.0}}, 
    Vertex{position = {-0.5, -0.5,  0.5}, uv = {0.0, 0.0}}, 
    Vertex{position = {-0.5,  0.5,  0.5}, uv = {1.0, 0.0}}, 

    Vertex{position = { 0.5,  0.5,  0.5}, uv = {1.0, 0.0}}, 
    Vertex{position = { 0.5,  0.5, -0.5}, uv = {1.0, 1.0}}, 
    Vertex{position = { 0.5, -0.5, -0.5}, uv = {0.0, 1.0}}, 
    Vertex{position = { 0.5, -0.5, -0.5}, uv = {0.0, 1.0}}, 
    Vertex{position = { 0.5, -0.5,  0.5}, uv = {0.0, 0.0}}, 
    Vertex{position = { 0.5,  0.5,  0.5}, uv = {1.0, 0.0}}, 

    Vertex{position = {-0.5, -0.5, -0.5}, uv = {0.0, 1.0}}, 
    Vertex{position = { 0.5, -0.5, -0.5}, uv = {1.0, 1.0}}, 
    Vertex{position = { 0.5, -0.5,  0.5}, uv = {1.0, 0.0}}, 
    Vertex{position = { 0.5, -0.5,  0.5}, uv = {1.0, 0.0}}, 
    Vertex{position = {-0.5, -0.5,  0.5}, uv = {0.0, 0.0}}, 
    Vertex{position = {-0.5, -0.5, -0.5}, uv = {0.0, 1.0}}, 

    Vertex{position = {-0.5,  0.5, -0.5}, uv = {0.0, 1.0}}, 
    Vertex{position = { 0.5,  0.5, -0.5}, uv = {1.0, 1.0}}, 
    Vertex{position = { 0.5,  0.5,  0.5}, uv = {1.0, 0.0}}, 
    Vertex{position = { 0.5,  0.5,  0.5}, uv = {1.0, 0.0}}, 
    Vertex{position = {-0.5,  0.5,  0.5}, uv = {0.0, 0.0}}, 
    Vertex{position = {-0.5,  0.5, -0.5}, uv =  {0.0, 1.0}},
}

    // world space positions of our cubes
cubePositions := [?]Vec3 {
    Vec3{ 3.0,  1.0,  8.0},
    Vec3{ 2.0,  5.0, -15.0},
    Vec3{-1.5, -2.2, -2.5},
    Vec3{-3.8, -2.0, -12.3},
    Vec3{ 2.4, -0.4, -3.5},
    Vec3{-1.7,  3.0, -7.5},
    Vec3{ 1.3, -2.0, -2.5},
    Vec3{ 1.5,  2.0, -2.5},
    Vec3{ 1.5,  0.2, -1.5},
    Vec3{-1.3,  1.0, -1.5}
};	

/*
planeVertices := [?]f32 {
    -0.5,  0.0, -0.5,
     0.5,  0.0, -0.5,
     0.5,  0.0, -0.5,
     0.5,  0.0, -0.5,
    -0.5,  0.0, -0.5,
    -0.5,  0.0, -0.5,
}
*/
wallVertices := [?]f32  {
     0.5,  0.5, 0.0,  // top right
     0.5, -0.5, 0.0,  // bottom right
    -0.5, -0.5, 0.0,  // bottom left
    -0.5,  0.5, 0.0   // top left 
};

Vertex :: struct
{
	position: Vec3,
	normal:   Vec3,
	uv:       Vec2,
}

planeVertices := []Vertex {
	{ 
		position = {-0.5, 0,  0.5},
		uv       = {0.0, 1.0},
	},
	{ 
		position = { 0.5, 0,  0.5},
		uv       = {1.0, 1.0},
	},
	{ 
		position = { 0.5, 0, -0.5},
		uv       = {1.0, 0.0},
	},
	{ 
		position = {-0.5, 0, -0.5},
		uv       = {0.0, 0.0},
	},
}

planeIndices := []u32  {  // note that we start from 0!
    0, 1, 3,  // first Triangle
    1, 2, 3   // second Triangle
};
