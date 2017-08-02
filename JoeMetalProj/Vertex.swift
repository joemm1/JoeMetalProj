struct Vertex
{
	var x, y, z			: Float		//position
	var nx, ny, nz		: Float		//normal
	var u, v			: Float		//uv

	func floatBuffer() -> [Float]
	{
		return [x, y, z, nx, ny, nz, u, v]
	}

}
