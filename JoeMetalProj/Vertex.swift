struct Vertex
{
	var x, y, z			: Float		//position
	var nx, ny, nz		: Float		//normal

	func floatBuffer() -> [Float]
	{
		return [x, y, z, nx, ny, nz]
	}

}
