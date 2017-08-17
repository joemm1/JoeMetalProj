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
	let mesh:				Mesh
	var perMesh:			PerMeshUniforms
	
	init(kernel: Kernel, mesh: Mesh, world: float4x4)
	{
		perMesh = PerMeshUniforms(device: kernel.device)
		perMesh.world = world
		
		self.mesh = mesh
	}
	
	func render(kernel: Kernel, renderEncoder: MTLRenderCommandEncoder)
	{
		perMesh.bind(renderEncoder: renderEncoder)
		mesh.render(kernel: kernel, renderEncoder: renderEncoder)
	}
};
