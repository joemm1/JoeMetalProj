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
	let calcNormals:		Bool
}

class ModelBase : Mesh
{
	let mtkMesh: 			MTKMesh
	let texture:			Texture
	let sampler:			MTLSamplerState
	
	init(kernel: Kernel, mdlMesh: MDLMesh, shaderSet: ShaderSet, texture: Texture, name: String)
	{
		mtkMesh = try! MTKMesh(mesh: mdlMesh, device: kernel.device)
		
		self.texture = texture
		
		let samplerDesc = MTLSamplerDescriptor()
		sampler = kernel.device.makeSamplerState(descriptor: samplerDesc)!
		
		let mn = mdlMesh.boundingBox.minBounds
		let aabbMin = float3(mn.x, mn.y, mn.z)
		let mx = mdlMesh.boundingBox.maxBounds
		let aabbMax = float3(mx.x, mx.y, mx.z)

		let material = Material()
		for sm in 0..<mdlMesh.submeshes!.count
		{
			let submesh = mdlMesh.submeshes![sm] as! MDLSubmesh

			ModelBase.setUpMaterialProperty(mdlMaterial: submesh.material!, semantic: MDLMaterialSemantic.baseColor, texture: &material.maps[TextureInputTypes.kBaseColour.rawValue], uniform: &material.uniforms.baseColour)
		}
		
		#if DEBUG
			print("Loaded Model \(name)")
			
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
		
		super.init(material: material, aabbMin: aabbMin, aabbMax: aabbMax, name: name)
	}

	static func setUpMaterialProperty(mdlMaterial: MDLMaterial,
	                           semantic: MDLMaterialSemantic,
	                           texture: inout Texture?,
	                           uniform: UnsafeMutableRawPointer)
	{
		let property = mdlMaterial.property(with: semantic)
		if property != nil
		{
			let prop = property!
			if prop.type == MDLMaterialPropertyType.string
			{
				texture = Texture(url: URL(string: prop.stringValue!)!)
			}
			else if prop.type == MDLMaterialPropertyType.float
			{
				memcpy(uniform, &prop.floatValue, MemoryLayout<Float>.stride)
			}
			else if prop.type == MDLMaterialPropertyType.float3
			{
				memcpy(uniform, &prop.float3Value, MemoryLayout<Float>.stride * 3)
			}
		}
	}
	
	override func render(renderEncoder: MTLRenderCommandEncoder, overrideMaterial: Material?)
	{
		super.render(renderEncoder: renderEncoder, overrideMaterial: overrideMaterial)

		if mtkMesh.vertexBuffers.count > 1
		{
			print("Mesh has >1 buffer => ignoring")
		}

		let vb = mtkMesh.vertexBuffers[0]
		renderEncoder.setVertexBuffer(vb.buffer, offset: vb.offset, index: 0)

		renderEncoder.setFragmentSamplerState(sampler, index: 0)
		renderEncoder.setFragmentTexture(texture.mtlTex, index: 0)
		
		for subMesh in mtkMesh.submeshes
		{
			renderEncoder.drawIndexedPrimitives(type: subMesh.primitiveType, indexCount: subMesh.indexCount, indexType: subMesh.indexType, indexBuffer: subMesh.indexBuffer.buffer, indexBufferOffset: subMesh.indexBuffer.offset, instanceCount: 1)
		}
	}
}

class Model : ModelBase
{
	let modelDesc:			ModelDesc
	
	init(kernel: Kernel, modelDesc: ModelDesc, texture: Texture)
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
		attribute.name = MDLVertexAttributeTextureCoordinate
		attribute.format = MDLVertexFormat.float2
		attribute.offset = 12
		attribute = desc.attributes[2] as! MDLVertexAttribute
		attribute.name = MDLVertexAttributeNormal
		attribute.format = MDLVertexFormat.float3
		attribute.offset = 20
		attribute = desc.attributes[3] as! MDLVertexAttribute
		attribute.name = MDLVertexAttributeTangent
		attribute.format = MDLVertexFormat.float3
		attribute.offset = 32
		attribute = desc.attributes[4] as! MDLVertexAttribute
		attribute.name = MDLVertexAttributeBitangent
		attribute.format = MDLVertexFormat.float3
		attribute.offset = 44
		
		let layout = desc.layouts[0] as! MDLVertexBufferLayout
		layout.stride = 56
		
		let asset = MDLAsset(url:url, vertexDescriptor: desc, bufferAllocator: kernel.mtkBufAllocator)

		//#todo: iterate over MDLMesh objects in MDLAsset
		guard let mdlMesh = asset.object(at: 0) as? MDLMesh
			else
		{
			fatalError("Failed to get mesh \(modelDesc.modelName) from asset.")
		}
		
		if modelDesc.calcNormals
		{
			let start = Date()
			
			mdlMesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 0.0)
			
			print(String(format: "CalcNormals for \(modelDesc.modelName): %.1f s", (Date().timeIntervalSince1970 - start.timeIntervalSince1970)))
		}
		
		self.modelDesc = modelDesc
		
		super.init(kernel: kernel, mdlMesh: mdlMesh, shaderSet: modelDesc.shaderSet, texture: texture, name: modelDesc.modelName)
	}
}

