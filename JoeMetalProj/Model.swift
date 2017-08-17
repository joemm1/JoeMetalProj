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

struct ModelDesc
{
	let shaderSet: 			ShaderSet
	let modelName: 			String
	let modelExt: 			String
	let albedoMapName:		String
	let albedoMapExt: 		String
	
	init(shaderSet: ShaderSet, modelName: String, modelExt: String, albedoMapName: String, albedoMapExt: String)
	{
		self.shaderSet = shaderSet
		self.modelName = modelName
		self.modelExt = modelExt
		self.albedoMapName = albedoMapName
		self.albedoMapExt = albedoMapExt
	}
}

class Model : Mesh
{
	let mtkMesh: 			MTKMesh
	let texture:			MTLTexture
	let sampler:			MTLSamplerState
	let modelDesc:			ModelDesc
	
	init(kernel: Kernel, modelDesc: ModelDesc)
	{
		guard let url = Bundle.main.url(forResource: modelDesc.modelName, withExtension: modelDesc.modelExt)
			else
		{
			fatalError("Failed to find model file \(modelDesc.modelName)")
		}
		
		let desc = MDLVertexDescriptor()
		var attribute = desc.attributes[0] as! MDLVertexAttribute
		attribute.name = MDLVertexAttributePosition
		attribute.format = MDLVertexFormat.float3
		attribute.offset = 0
		attribute = desc.attributes[1] as! MDLVertexAttribute
		attribute.name = MDLVertexAttributeNormal
		attribute.format = MDLVertexFormat.float3
		attribute.offset = 12
		attribute = desc.attributes[2] as! MDLVertexAttribute
		attribute.name = MDLVertexAttributeTextureCoordinate
		attribute.format = MDLVertexFormat.float2
		attribute.offset = 24
		
		let layout = desc.layouts[0] as! MDLVertexBufferLayout
		layout.stride = 32
		
		let asset = MDLAsset(url:url, vertexDescriptor: desc, bufferAllocator: kernel.mtkBufAllocator)
		guard let mdlMesh = asset.object(at: 0) as? MDLMesh
			else
		{
			fatalError("Failed to get mesh \(modelDesc.modelName) from asset.")
		}
		
		//mdlMesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 0.0)
		mtkMesh = try! MTKMesh(mesh: mdlMesh, device: kernel.device)
		
		let path = Bundle.main.path(forResource: modelDesc.albedoMapName, ofType: modelDesc.albedoMapExt)!
		let data = try! NSData(contentsOfFile: path) as Data
		texture = try! kernel.textureLoader.newTexture(with: data, options: [MTKTextureLoader.Option.SRGB : (false as NSNumber)])
		
		let samplerDesc = MTLSamplerDescriptor()
		sampler = kernel.device.makeSamplerState(descriptor: samplerDesc)!
		
		self.modelDesc = modelDesc
		
		#if DEBUG
			print("Loaded Model \(modelDesc.modelName)\(modelDesc.modelExt)")
			
			let mn = mdlMesh.boundingBox.minBounds
			let mx = mdlMesh.boundingBox.maxBounds
			print("AABB: (\(mn.x), \(mn.y), \(mn.z)) --> (\(mx.x), \(mx.y), \(mx.z))")
			
			print("  Submeshes:")
			var count = 0
			var cumIndexCount = 0
			for subMesh in mtkMesh.submeshes
			{
				let div = ((subMesh.indexType == .uint16) ? 2 : 4)
				count += 1
				let indexCount = subMesh.indexBuffer.length / div
				print("    Submesh \(count) has name '\(subMesh.name)' and index count \(indexCount)")
				cumIndexCount += subMesh.indexBuffer.length / div
			}
			print("  Total index count: \(cumIndexCount)")
		#endif
		
		super.init(kernel: kernel, shaderSet: modelDesc.shaderSet, vertexDescriptor: nil, name: modelDesc.modelName)
	}
	
	override func render(kernel: Kernel, renderEncoder: MTLRenderCommandEncoder)
	{
		super.render(kernel: kernel, renderEncoder: renderEncoder)
		
		for vb in mtkMesh.vertexBuffers
		{
			renderEncoder.setVertexBuffer(vb.buffer, offset: vb.offset, index: 0)
		}
		
		renderEncoder.setFragmentSamplerState(sampler, index: 0)
		renderEncoder.setFragmentTexture(texture, index: 0)
		
		for subMesh in mtkMesh.submeshes
		{
			renderEncoder.drawIndexedPrimitives(type: subMesh.primitiveType, indexCount: subMesh.indexCount, indexType: subMesh.indexType, indexBuffer: subMesh.indexBuffer.buffer, indexBufferOffset: subMesh.indexBuffer.offset, instanceCount: 1)
		}
	}
}
