import Foundation
import Metal
import simd

class Cube: SubMesh
{
    init(device: MTLDevice, world: float4x4)
	{
		//top
		let top0 = Vertex(x: -1.0, y:   1.0, z:  -1.0, nx:  0.0, ny:  1.0, nz:  0.0)
		let top1 = Vertex(x:  1.0, y:   1.0, z:  -1.0, nx:  0.0, ny:  1.0, nz:  0.0)
		let top2 = Vertex(x:  1.0, y:   1.0, z:   1.0, nx:  0.0, ny:  1.0, nz:  0.0)
		let top3 = Vertex(x: -1.0, y:   1.0, z:   1.0, nx:  0.0, ny:  1.0, nz:  0.0)
		
		//bottom
		let bot0 = Vertex(x: -1.0, y:  -1.0, z:   1.0, nx:  0.0, ny:  -1.0, nz:  0.0)
		let bot1 = Vertex(x:  1.0, y:  -1.0, z:   1.0, nx:  0.0, ny:  -1.0, nz:  0.0)
		let bot2 = Vertex(x:  1.0, y:  -1.0, z:  -1.0, nx:  0.0, ny:  -1.0, nz:  0.0)
		let bot3 = Vertex(x: -1.0, y:  -1.0, z:  -1.0, nx:  0.0, ny:  -1.0, nz:  0.0)
		
		//left
		let lef0 = Vertex(x: -1.0, y:   1.0, z:  -1.0, nx: -1.0, ny:   0.0, nz:  0.0)
		let lef1 = Vertex(x: -1.0, y:   1.0, z:   1.0, nx: -1.0, ny:   0.0, nz:  0.0)
		let lef2 = Vertex(x: -1.0, y:  -1.0, z:   1.0, nx: -1.0, ny:   0.0, nz:  0.0)
		let lef3 = Vertex(x: -1.0, y:  -1.0, z:  -1.0, nx: -1.0, ny:   0.0, nz:  0.0)
		
		//right
		let rht0 = Vertex(x:  1.0, y:   1.0, z:   1.0, nx:  1.0, ny:   0.0, nz:  0.0)
		let rht1 = Vertex(x:  1.0, y:   1.0, z:  -1.0, nx:  1.0, ny:   0.0, nz:  0.0)
		let rht2 = Vertex(x:  1.0, y:  -1.0, z:  -1.0, nx:  1.0, ny:   0.0, nz:  0.0)
		let rht3 = Vertex(x:  1.0, y:  -1.0, z:   1.0, nx:  1.0, ny:   0.0, nz:  0.0)
		
		//back
		let bck0 = Vertex(x:  1.0, y:   1.0, z:  -1.0, nx:  0.0, ny:   0.0, nz: -1.0)
		let bck1 = Vertex(x: -1.0, y:   1.0, z:  -1.0, nx:  0.0, ny:   0.0, nz: -1.0)
		let bck2 = Vertex(x: -1.0, y:  -1.0, z:  -1.0, nx:  0.0, ny:   0.0, nz: -1.0)
		let bck3 = Vertex(x:  1.0, y:  -1.0, z:  -1.0, nx:  0.0, ny:   0.0, nz: -1.0)
		
		//front
		let frn0 = Vertex(x: -1.0, y:   1.0, z:   1.0, nx:  0.0, ny:   0.0, nz:  1.0)
		let frn1 = Vertex(x:  1.0, y:   1.0, z:   1.0, nx:  0.0, ny:   0.0, nz:  1.0)
		let frn2 = Vertex(x:  1.0, y:  -1.0, z:   1.0, nx:  0.0, ny:   0.0, nz:  1.0)
		let frn3 = Vertex(x: -1.0, y:  -1.0, z:   1.0, nx:  0.0, ny:   0.0, nz:  1.0)

		let verticesArray:Array<Vertex> = [
			top0, top2, top1, top0, top3, top2,
			bot0, bot2, bot1, bot0, bot3, bot2,
			lef0, lef2, lef1, lef0, lef3, lef2,
			rht0, rht2, rht1, rht0, rht3, rht2,
			bck0, bck2, bck1, bck0, bck3, bck2,
			frn0, frn2, frn1, frn0, frn3, frn2
        ]

        super.init(device: device, world: world, vertices: verticesArray, name: "Cube")
    }
}
