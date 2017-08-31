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

class MeshInstance
{
	let mesh:						Mesh
	var perMesh:					PerMeshUniforms
	var overrideMaterial:			Material?
	
	init(kernel: Kernel, mesh: Mesh, world: float4x4, overrideMaterial: Material?)
	{
		perMesh = PerMeshUniforms(device: kernel.device)
		perMesh.world = world

		self.overrideMaterial = overrideMaterial
		self.mesh = mesh
	}
	
	func render(renderEncoder: MTLRenderCommandEncoder)
	{
		perMesh.bind(renderEncoder: renderEncoder)
		mesh.render(renderEncoder: renderEncoder, overrideMaterial: overrideMaterial)
	}
	
	func DoesWorldAabbIntersectAllHalfSpaces(_ planes: [float4]) -> Bool
	{
		let points = mesh.getWorldAabbPoints(world: perMesh.world)
		if points.count == 0
		{
			return true
		}
		
		return Utils.DoesPointCloudIntersectAllHalfSpaces(points, planes: planes)
	}
};
