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
	let scale:						Float
	var overrideMaterial:			Material?
	var isAlwaysHidden =			false
	
	init(mesh: Mesh, world: float4x4, scale: Float, overrideMaterial: Material? = nil)
	{
		meshInstUniforms = MeshInstanceUniforms(device: gKernel.device)

		let scaleMat = float4x4.makeScale(scale, scale, scale)
		meshInstUniforms.world = world * scaleMat

		self.scale = scale
		self.overrideMaterial = overrideMaterial
		self.mesh = mesh
	}
	
	func render(renderEncoder: MTLRenderCommandEncoder)
	{
		meshInstUniforms.bind(renderEncoder: renderEncoder)
		mesh.render(renderEncoder: renderEncoder, materialOverride: overrideMaterial)
	}
	
	func doesWorldAabbIntersectAllHalfSpaces(_ planes: [float4]) -> Bool
	{
		let points = getWorldAabbPoints()
		if points.count == 0
		{
			return true
		}
		
		return Utils.DoesPointCloudIntersectAllHalfSpaces(points, planes: planes)
	}

	func isVisible(_ planes: [float4]) -> Bool
	{
		return !isAlwaysHidden && doesWorldAabbIntersectAllHalfSpaces(planes)
	}

	func getWorldAabbPoints() -> [float4]
	{
		let aabbMinWorld = meshInstUniforms.world * float4(mesh.aabbMin, 1.0)
		let aabbMaxWorld = meshInstUniforms.world * float4(mesh.aabbMax, 1.0)
		let aabb: [float4] = [ aabbMinWorld, aabbMaxWorld ]

		var worldPoints = [float4]()
		for i in 0..<8
		{
			worldPoints.append( float4( aabb[i>>2].x, aabb[(i>>1)&1].y, aabb[i&1].z, 1.0) )
		}

		return worldPoints
	}

	func getWorldBoundingSphere() -> float4
	{
		let worldPos = meshInstUniforms.world * float4(mesh.boundingSphere.xyz, 1)
		let radius = mesh.boundingSphere.w * scale
		return float4(worldPos.xyz, radius)
	}
}
