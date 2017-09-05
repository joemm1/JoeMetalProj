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
	let shaderDict: 		ShaderDict
	let modelName: 			String
	let modelExt: 			String
	let calcNormals:		Bool
}

class ModelBase : Mesh
{
	let mdlMesh:			MDLMesh
	let mtkMesh: 			MTKMesh
	
	init(mdlMesh: MDLMesh, shaderDict: ShaderDict, name: String, overrideBaseColourMap: Texture? = nil)
	{
		self.mdlMesh = mdlMesh
		mtkMesh = try! MTKMesh(mesh: mdlMesh, device: gKernel.device)
		
		let mn = mdlMesh.boundingBox.minBounds
		let aabbMin = float3(mn.x, mn.y, mn.z)
		let mx = mdlMesh.boundingBox.maxBounds
		let aabbMax = float3(mx.x, mx.y, mx.z)

		//#todo handle multiple vb streams via vertex descriptors
		if mtkMesh.vertexBuffers.count > 1
		{
			fatalError("Mesh \(name) has >1 buffer => ignoring")
		}
		let vb = mtkMesh.vertexBuffers[0]

		var subMeshes = [SubMesh]()
		for sm in 0..<mdlMesh.submeshes!.count
		{
			let mdlSm = mdlMesh.submeshes![sm] as! MDLSubmesh
			let mtkSm = mtkMesh.submeshes[sm]

			let maps = MaterialMaps()
			let uniforms = MaterialUniforms()

			if let baseColourMap = overrideBaseColourMap
			{
				maps[TextureInputTypes.kBaseColour.rawValue] = baseColourMap}
			else
			{
				ModelBase.setUpMaterialProperty(mdlMaterial: mdlSm.material!, semantic: MDLMaterialSemantic.baseColor, texture: &maps[TextureInputTypes.kBaseColour.rawValue], uniform: &uniforms.baseColour)
			}

			ModelBase.setUpMaterialProperty(mdlMaterial: mdlSm.material!, semantic: MDLMaterialSemantic.metallic, texture: &maps[TextureInputTypes.kMetallic.rawValue], uniform: &uniforms.metalness)

			ModelBase.setUpMaterialProperty(mdlMaterial: mdlSm.material!, semantic: MDLMaterialSemantic.roughness, texture: &maps[TextureInputTypes.kRoughness.rawValue], uniform: &uniforms.roughness)

			ModelBase.setUpMaterialProperty(mdlMaterial: mdlSm.material!, semantic: MDLMaterialSemantic.tangentSpaceNormal, texture: &maps[TextureInputTypes.kNormal.rawValue], uniform: nil)

			ModelBase.setUpMaterialProperty(mdlMaterial: mdlSm.material!, semantic: MDLMaterialSemantic.ambientOcclusion, texture: &maps[TextureInputTypes.kAmbientOcclusion.rawValue], uniform: &uniforms.ambientOcclusion)

			//#todo
			//ModelBase.setUpMaterialProperty(mdlMaterial: mdlSm.material!, semantic: MDLMaterialSemantic.irradiatedColor, texture: &maps[TextureInputTypes.kIrradianceMap.rawValue], uniform: &uniforms.irradiatedColor)

			let material = Material(shaderDict: shaderDict, maps: maps, uniforms: uniforms)

			let sm = SubMesh(material: material, primType: mtkSm.primitiveType, vertexBuffer: vb.buffer, vertexBufferOffset: vb.offset, vertexCount: mtkMesh.vertexCount, indexBuffer: mtkSm.indexBuffer.buffer, indexCount: mtkSm.indexCount, indexType: mtkSm.indexType, indexOffset: mtkSm.indexBuffer.offset)
			subMeshes.append(sm)

			//jmmtemp
			for p in 0..<mdlSm.material!.count
			{
				let prop = mdlSm.material![p]
				print("Semantic: \(String(describing: prop!.semantic))")
			}
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
		
		super.init(subMeshes: subMeshes, aabbMin: aabbMin, aabbMax: aabbMax, name: name)
	}

	static func setUpMaterialProperty(mdlMaterial: MDLMaterial,
	                                  semantic: MDLMaterialSemantic,
	                                  texture: inout Texture?,
	                                  uniform: UnsafeMutableRawPointer?)
	{
		let prop = mdlMaterial.property(with: semantic)
		if let prop = prop
		{
			if prop.type == MDLMaterialPropertyType.string
			{
				texture = Texture(url: URL(string: prop.stringValue!)!)
			}
			else if let uniform = uniform
			{
				if prop.type == MDLMaterialPropertyType.float
				{
					memcpy(uniform, &prop.floatValue, MemoryLayout<Float>.stride)
				}
				else if prop.type == MDLMaterialPropertyType.float3
				{
					memcpy(uniform, &prop.float3Value, MemoryLayout<Float>.stride * 3)
				}
			}
		}
	}
}

class Model : ModelBase
{
	let modelDesc:			ModelDesc
	
	init(modelDesc: ModelDesc, overrideBaseColourMap: Texture? = nil, modelIndex: Int = 0)
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
		
		let asset = MDLAsset(url:url, vertexDescriptor: desc, bufferAllocator: gKernel.mtkBufAllocator)

		guard let mdlMesh = asset.object(at: modelIndex) as? MDLMesh
		else
		{
			fatalError("Failed to get model index \(modelIndex) from asset \(modelDesc.modelName)")
		}

		//#todo - auto-detect when this needs to be done
		if modelDesc.calcNormals
		{
			let start = Date()
			
			mdlMesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 0.0)
			
			print(String(format: "CalcNormals for \(modelDesc.modelName): %.1f s", (Date().timeIntervalSince1970 - start.timeIntervalSince1970)))
		}
		
		self.modelDesc = modelDesc
		
		super.init(mdlMesh: mdlMesh, shaderDict: modelDesc.shaderDict, name: modelDesc.modelName, overrideBaseColourMap: overrideBaseColourMap)
	}
}

