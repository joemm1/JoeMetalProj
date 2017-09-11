//
//  Mesh.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 15/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import ModelIO
import MetalKit

class Mesh
{
	let name:               String
	let aabbMin:			float3
	let aabbMax:			float3
	let boundingSphere:		float4
	var subMeshes:			[SubMesh]
	
	init(subMeshes: [SubMesh], aabbMin: float3, aabbMax: float3, name: String)
	{
		self.subMeshes = subMeshes
		self.aabbMin = aabbMin
		self.aabbMax = aabbMax

		let centre = (aabbMin + aabbMax) / 2
		let dist1 = length(aabbMin - centre)
		let dist2 = length(aabbMax - centre)
		let radius = max(dist1, dist2)
		boundingSphere = float4(centre, radius)

		self.name = name
	}
	
	func render(renderEncoder: MTLRenderCommandEncoder, materialOverride: Material?)
	{
		for sm in subMeshes
		{
			sm.render(renderEncoder: renderEncoder, materialOverride: materialOverride)
		}
	}
}
