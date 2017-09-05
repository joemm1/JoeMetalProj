//
//  ModelAsteroid.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import ModelIO

class ModelAsteroid : ModelBase
{
	init(shaderDict: ShaderDict)
	{
		let sphere = MDLMesh.newEllipsoid(withRadii: float3(1, 1, 1), radialSegments: 10, verticalSegments: 10, geometryType: .triangles, inwardNormals: false, hemisphere: false, allocator: gKernel.mtkBufAllocator)
		
		for vb in sphere.vertexBuffers
		{
			let stride = 4 * (3 + 3 + 2)
			let map = vb.map()
			var dest = map.bytes
			
			struct Float3
			{
				var x = Float(0)
				var y = Float(0)
				var z = Float(0)
			}
			
			for _ in 0..<sphere.vertexCount
			{
				var p = dest.load(as: Float3.self)
				var pos = float3(p.x, p.y, p.z)
				pos *= Utils.RandomFloat(min: 0.9, max: 1.1)
				
				p.x = pos.x
				p.y = pos.y
				p.z = pos.z
				dest.storeBytes(of: p, as: Float3.self)
				dest = dest.advanced(by: stride)
			}
		}
		
		sphere.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 0.0)
		
		super.init(mdlMesh: sphere, shaderDict: shaderDict, name: "ModelSphere")
	}
	
}
