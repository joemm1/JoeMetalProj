//
//  Primitive.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import simd

struct Vertex
{
	var x, y, z			: Float		//position
	var nx, ny, nz		: Float		//normal
	var u, v			: Float		//uv
	
	func floatBuffer() -> [Float]
	{
		return [x, y, z, u, v, nx, ny, nz, 0, 0, 0, 0, 0, 0]
	}
	
}

class PrimitiveMesh: Mesh
{
	let vertexCount:        Int
	let vertexBuffer:       MTLBuffer
	
	init(material: Material, vertices: Array<Vertex>, name: String)
	{
		var vertexData = Array<Float>()
		for vertex in vertices
		{
			vertexData += vertex.floatBuffer()
		}
		
		let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
		vertexBuffer = gKernel!.device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
		
		self.vertexCount = vertices.count
		
		let fmin = Float.leastNormalMagnitude
		let fmax = Float.greatestFiniteMagnitude
		
		var aabbMin = float3(fmax, fmax, fmax)
		var aabbMax = float3(fmin, fmin, fmin)
		
		for v in vertices
		{
			aabbMin.x = min(v.x, aabbMin.x)
			aabbMin.y = min(v.y, aabbMin.y)
			aabbMin.z = min(v.z, aabbMin.z)
			
			aabbMax.x = min(v.x, aabbMax.x)
			aabbMax.y = min(v.y, aabbMax.y)
			aabbMax.z = min(v.z, aabbMax.z)
		}
		
		super.init(material: material, aabbMin: aabbMin, aabbMax: aabbMax, name: name)
	}
	
	override func render(renderEncoder: MTLRenderCommandEncoder, overrideMaterial: Material?)
	{
		super.render(renderEncoder: renderEncoder, overrideMaterial: overrideMaterial)
		
		renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
		renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
	}
}

class Cube: PrimitiveMesh
{
	init(kernel: Kernel, shaderDict: ShaderDict, texture: Texture)
	{
		//top
		let top0 = Vertex(x: -1.0, y:   1.0, z:  -1.0, nx:  0.0, ny:  1.0, nz:  0.0, u:	0.0, v:	0.0)
		let top1 = Vertex(x:  1.0, y:   1.0, z:  -1.0, nx:  0.0, ny:  1.0, nz:  0.0, u:	1.0, v:	0.0)
		let top2 = Vertex(x:  1.0, y:   1.0, z:   1.0, nx:  0.0, ny:  1.0, nz:  0.0, u:	1.0, v:	1.0)
		let top3 = Vertex(x: -1.0, y:   1.0, z:   1.0, nx:  0.0, ny:  1.0, nz:  0.0, u:	0.0, v:	1.0)
		
		//bottom
		let bot0 = Vertex(x: -1.0, y:  -1.0, z:   1.0, nx:  0.0, ny:  -1.0, nz:  0.0, u: 0.0, v: 0.0)
		let bot1 = Vertex(x:  1.0, y:  -1.0, z:   1.0, nx:  0.0, ny:  -1.0, nz:  0.0, u: 1.0, v: 0.0)
		let bot2 = Vertex(x:  1.0, y:  -1.0, z:  -1.0, nx:  0.0, ny:  -1.0, nz:  0.0, u: 1.0, v: 1.0)
		let bot3 = Vertex(x: -1.0, y:  -1.0, z:  -1.0, nx:  0.0, ny:  -1.0, nz:  0.0, u: 0.0, v: 1.0)
		
		//left
		let lef0 = Vertex(x: -1.0, y:   1.0, z:  -1.0, nx: -1.0, ny:   0.0, nz:  0.0, u: 0.0, v: 0.0)
		let lef1 = Vertex(x: -1.0, y:   1.0, z:   1.0, nx: -1.0, ny:   0.0, nz:  0.0, u: 1.0, v: 0.0)
		let lef2 = Vertex(x: -1.0, y:  -1.0, z:   1.0, nx: -1.0, ny:   0.0, nz:  0.0, u: 1.0, v: 1.0)
		let lef3 = Vertex(x: -1.0, y:  -1.0, z:  -1.0, nx: -1.0, ny:   0.0, nz:  0.0, u: 0.0, v: 1.0)
		
		//right
		let rht0 = Vertex(x:  1.0, y:   1.0, z:   1.0, nx:  1.0, ny:   0.0, nz:  0.0, u: 0.0, v: 0.0)
		let rht1 = Vertex(x:  1.0, y:   1.0, z:  -1.0, nx:  1.0, ny:   0.0, nz:  0.0, u: 1.0, v: 0.0)
		let rht2 = Vertex(x:  1.0, y:  -1.0, z:  -1.0, nx:  1.0, ny:   0.0, nz:  0.0, u: 1.0, v: 1.0)
		let rht3 = Vertex(x:  1.0, y:  -1.0, z:   1.0, nx:  1.0, ny:   0.0, nz:  0.0, u: 0.0, v: 1.0)
		
		//back
		let bck0 = Vertex(x:  1.0, y:   1.0, z:  -1.0, nx:  0.0, ny:   0.0, nz: -1.0, u: 0.0, v: 0.0)
		let bck1 = Vertex(x: -1.0, y:   1.0, z:  -1.0, nx:  0.0, ny:   0.0, nz: -1.0, u: 1.0, v: 0.0)
		let bck2 = Vertex(x: -1.0, y:  -1.0, z:  -1.0, nx:  0.0, ny:   0.0, nz: -1.0, u: 1.0, v: 1.0)
		let bck3 = Vertex(x:  1.0, y:  -1.0, z:  -1.0, nx:  0.0, ny:   0.0, nz: -1.0, u: 0.0, v: 1.0)
		
		//front
		let frn0 = Vertex(x: -1.0, y:   1.0, z:   1.0, nx:  0.0, ny:   0.0, nz:  1.0, u: 0.0, v: 0.0)
		let frn1 = Vertex(x:  1.0, y:   1.0, z:   1.0, nx:  0.0, ny:   0.0, nz:  1.0, u: 1.0, v: 0.0)
		let frn2 = Vertex(x:  1.0, y:  -1.0, z:   1.0, nx:  0.0, ny:   0.0, nz:  1.0, u: 1.0, v: 1.0)
		let frn3 = Vertex(x: -1.0, y:  -1.0, z:   1.0, nx:  0.0, ny:   0.0, nz:  1.0, u: 0.0, v: 1.0)
		
		let verticesArray:Array<Vertex> = [
			top0, top2, top1, top0, top3, top2,
			bot0, bot2, bot1, bot0, bot3, bot2,
			lef0, lef2, lef1, lef0, lef3, lef2,
			rht0, rht2, rht1, rht0, rht3, rht2,
			bck0, bck2, bck1, bck0, bck3, bck2,
			frn0, frn2, frn1, frn0, frn3, frn2
		]

		let material = Material()
		material.maps[TextureInputTypes.kBaseColour.rawValue] = texture
		
		super.init(material: material, vertices: verticesArray, name: "Cube")
	}
}


