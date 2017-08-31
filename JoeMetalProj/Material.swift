//
//  Material.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 30/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal

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
	case kMetallic
	case kRoughness
	case kNormal
	case kAmbientOcclusion
	case kIrradianceMap

	case kNum
}

class Material
{
	var uniforms =			MaterialUniforms(device: gKernel!.device)
	var maps:				[Texture?]
	var shaderSet:			ShaderSet?
	let sampler:			MTLSamplerState

	init()
	{
		maps = [Texture?](repeating: nil, count: TextureInputTypes.kNum.rawValue)

		//#todo
		let desc = MTLSamplerDescriptor()
		sampler = gKernel!.device.makeSamplerState(descriptor: desc)!
	}

	func calcShaderSet(shaderDict: ShaderDict)
	{
		var permFlags = ShaderPermFlags(indexCount: FunctionConstants.kNum.rawValue)
		permFlags.add(index: FunctionConstants.kBaseColour.rawValue, value: (maps[TextureInputTypes.kBaseColour.rawValue] != nil))
		shaderSet = shaderDict.get(perms: permFlags)
	}

	func bind(renderEncoder: MTLRenderCommandEncoder)
	{
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
