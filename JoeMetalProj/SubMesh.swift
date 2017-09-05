//
//  SubMesh.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 01/09/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import ModelIO
import MetalKit

class SubMesh
{
	let material:			Material
	let primType:			MTLPrimitiveType
	let vertexBuffer:		MTLBuffer
	let vertexBufferOffset:	Int
	let vertexCount:		Int
	let indexCount:			Int
	let indexOffset:		Int
	let indexType:			MTLIndexType
	let indexBuffer:		MTLBuffer?

	init(material: Material, primType: MTLPrimitiveType, vertexBuffer: MTLBuffer, vertexBufferOffset: Int, vertexCount: Int, indexBuffer: MTLBuffer? = nil, indexCount: Int = 0, indexType: MTLIndexType = .uint16, indexOffset: Int = 0)
	{
		self.material = material

		self.primType = primType
		self.vertexBuffer = vertexBuffer
		self.vertexBufferOffset = vertexBufferOffset
		self.vertexCount = vertexCount

		self.indexCount = indexCount
		self.indexType = indexType
		self.indexOffset = indexOffset
		self.indexBuffer = indexBuffer
	}

	func render(renderEncoder: MTLRenderCommandEncoder, materialOverride: Material?)
	{
		let mat = materialOverride ?? material
		mat.bind(renderEncoder: renderEncoder)

		//#todo other vertex streams - currently always binding to index 0
		renderEncoder.setVertexBuffer(vertexBuffer, offset: vertexBufferOffset, index: 0)

		if indexBuffer != nil
		{
			renderEncoder.drawIndexedPrimitives(type: primType, indexCount: indexCount, indexType: indexType, indexBuffer: indexBuffer!, indexBufferOffset: indexOffset, instanceCount: 1)
		}
		else
		{
			renderEncoder.drawPrimitives(type: primType, vertexStart: vertexBufferOffset, vertexCount: vertexCount, instanceCount: 1)
		}
	}
}
