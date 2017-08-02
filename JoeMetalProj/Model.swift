//
//  Model.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 02/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import ModelIO
import MetalKit

class Model: SubMesh
{
	let mtkMesh: MTKMesh
	
	init(kernel: Kernel, shaderSet: ShaderSet, world: float4x4, name: String, ext: String)
	{
		guard let url = Bundle.main.url(forResource: name, withExtension: ext)
		else
		{
			fatalError("Failed to find model file \("name")")
		}

		let asset = MDLAsset(url:url)
		guard let mdlMesh = asset.object(at: 0) as? MDLMesh
		else
		{
			fatalError("Failed to get mesh \("name") from asset.")
		}
		
		mtkMesh = try! MTKMesh(mesh: mdlMesh, device: kernel.device)
		
		super.init(kernel: kernel, shaderSet: shaderSet, world: world, name: name)
	}
	
	override func render(kernel: Kernel, renderEncoder: MTLRenderCommandEncoder)
	{
		for vb in mtkMesh.vertexBuffers
		{
			renderEncoder.setVertexBuffer(vb.buffer, offset: 0, index: 0)
			print("Name: \("vb.name")");
		}
		
		for subMesh in mtkMesh.submeshes
		{
			renderEncoder.setVertexBuffer(subMesh.indexBuffer.buffer, offset: 0, index: 0)
			renderEncoder.drawIndexedPrimitives(type: subMesh.primitiveType, indexCount: subMesh.indexCount, indexType: subMesh.indexType, indexBuffer: subMesh.indexBuffer.buffer, indexBufferOffset: 0, instanceCount: 1)
		}
	}
}
