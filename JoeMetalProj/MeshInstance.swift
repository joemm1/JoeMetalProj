//
//  MeshInstance.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 17/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import simd

class MeshInstanceUniforms : Uniforms
{
	var world =				float4x4()
	var id =				int4()

	static var nextId:		Int32 = 0

	init(device: MTLDevice)
	{
		let sizeInBytes =	MemoryLayout<float4x4>.stride
			+ 	MemoryLayout<int4>.stride
		self.id.x = MeshInstanceUniforms.nextId
		MeshInstanceUniforms.nextId = MeshInstanceUniforms.nextId + 1
		super.init(device: device, binding: BindingSlots.kMeshInstance.rawValue, sizeInBytes: sizeInBytes)
	}

	override func copyIn(buffer: MTLBuffer)
	{
		var dest = buffer.contents()

		memcpy(dest, &world, MemoryLayout<float4x4>.stride)
		dest = dest.advanced(by: MemoryLayout<float4x4>.stride)

		memcpy(dest, &id, MemoryLayout<Int>.stride)
		dest = dest.advanced(by: MemoryLayout<Int>.stride)
	}
}

class MeshInstance
{
	let mesh:						Mesh
	var meshInstUniforms:			MeshInstanceUniforms
	var overrideMaterial:			Material?
	
	init(mesh: Mesh, world: float4x4, overrideMaterial: Material? = nil)
	{
		meshInstUniforms = MeshInstanceUniforms(device: gKernel.device)
		meshInstUniforms.world = world

		self.overrideMaterial = overrideMaterial
		self.mesh = mesh
	}
	
	func render(renderEncoder: MTLRenderCommandEncoder)
	{
		meshInstUniforms.bind(renderEncoder: renderEncoder)
		mesh.render(renderEncoder: renderEncoder, materialOverride: overrideMaterial)
	}
	
	func DoesWorldAabbIntersectAllHalfSpaces(_ planes: [float4]) -> Bool
	{
		let points = mesh.getWorldAabbPoints(world: meshInstUniforms.world)
		if points.count == 0
		{
			return true
		}
		
		return Utils.DoesPointCloudIntersectAllHalfSpaces(points, planes: planes)
	}
};
