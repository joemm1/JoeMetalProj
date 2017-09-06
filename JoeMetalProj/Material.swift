//
//  Material.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 30/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import simd

enum TextureInputTypes : Int
{
	//must match entries in shader
	case kBaseColour
	case kMetallic
	case kRoughness
	case kNormal
	case kAmbientOcclusion
	case kIrradianceMap

	case kNum
}

enum FunctionConstants: Int
{
	//must match entries in shader
	case kBaseColour
	case kNormal
	case kMetallic
	case kRoughness
	case kAmbientOcclusion
	case kIrradianceMap

	case kNum
}

class MaterialUniforms : Uniforms
{
	var baseColour = 				float3(1.0, 1.0, 1.0)
	var roughness = 				Float(0.2)
	var metalness = 				Float(0.0)
	var ambientOcclusion = 			Float(1.0)
	var padding =					Float(0.0)
	var irradiatedColor = 			float3(1.0, 1.0, 1.0)

	init()
	{
		let sizeInBytes = (MemoryLayout<float3>.stride * 5)
		super.init(device: gKernel.device, binding: BindingSlots.kMaterial.rawValue, sizeInBytes: sizeInBytes)
	}

	override func copyIn(buffer: MTLBuffer)
	{
		var dest = buffer.contents()

		memcpy(dest, &baseColour, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)

		memcpy(dest, &roughness, MemoryLayout<Float>.stride)
		dest = dest.advanced(by: MemoryLayout<Float>.stride)

		memcpy(dest, &metalness, MemoryLayout<Float>.stride)
		dest = dest.advanced(by: MemoryLayout<Float>.stride)

		memcpy(dest, &ambientOcclusion, MemoryLayout<Float>.stride)
		dest = dest.advanced(by: MemoryLayout<Float>.stride)

		dest = dest.advanced(by: MemoryLayout<Float>.stride)

		memcpy(dest, &irradiatedColor, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)
	}
}

class MaterialMaps
{
	var maps:				[Texture?]

	init()
	{
		maps = [Texture?](repeating: nil, count: TextureInputTypes.kNum.rawValue)
	}

	subscript(index: Int) -> Texture?
	{
		get { return maps[index] }
		set(tex) { maps[index] = tex }
	}

	var count: Int { return maps.count }
}

class Material
{
	var uniforms:			MaterialUniforms
	let maps:				MaterialMaps
	let shaderDict:			ShaderDict
	let sampler:			MTLSamplerState
	let pipelineState:      MTLRenderPipelineState

	init(shaderDict: ShaderDict, maps: MaterialMaps = MaterialMaps(), uniforms: MaterialUniforms = MaterialUniforms())
	{
		self.shaderDict = shaderDict
		self.maps = maps
		self.uniforms = uniforms

		//#todo
		let desc = MTLSamplerDescriptor()
		sampler = gKernel.device.makeSamplerState(descriptor: desc)!

		var permFlags = ShaderPermFlags(indexCount: FunctionConstants.kNum.rawValue)
		permFlags.add(index: FunctionConstants.kBaseColour.rawValue, value: (maps[TextureInputTypes.kBaseColour.rawValue] != nil))
		permFlags.add(index: FunctionConstants.kNormal.rawValue, value: (maps[TextureInputTypes.kNormal.rawValue] != nil))
		permFlags.add(index: FunctionConstants.kNormal.rawValue, value: (maps[TextureInputTypes.kNormal.rawValue] != nil))
		permFlags.add(index: FunctionConstants.kMetallic.rawValue, value: (maps[TextureInputTypes.kMetallic.rawValue] != nil))
		permFlags.add(index: FunctionConstants.kRoughness.rawValue, value: (maps[TextureInputTypes.kRoughness.rawValue] != nil))
		permFlags.add(index: FunctionConstants.kAmbientOcclusion.rawValue, value: (maps[TextureInputTypes.kAmbientOcclusion.rawValue] != nil))
		permFlags.add(index: FunctionConstants.kIrradianceMap.rawValue, value: (maps[TextureInputTypes.kIrradianceMap.rawValue] != nil))
		let ss = shaderDict.get(perms: permFlags)

		let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
		pipelineStateDescriptor.vertexFunction = ss.vertexProgram
		pipelineStateDescriptor.fragmentFunction = ss.fragmentProgram
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float

		self.pipelineState = try! gKernel.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
	}

	func bind(renderEncoder: MTLRenderCommandEncoder)
	{
		renderEncoder.setRenderPipelineState(pipelineState)

		uniforms.bind(renderEncoder: renderEncoder)

		for m in 0..<maps.count
		{
			if maps[m] != nil
			{
				renderEncoder.setFragmentTexture(maps[m]!.mtlTex, index: m)
			}
		}

		//#todo per map
		renderEncoder.setFragmentSamplerState(sampler, index: 0)
	}
}
