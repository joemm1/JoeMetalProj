//
//  Uniforms.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import simd

class Uniforms : Buffer
{
	let sizeInBytes:			Int
	
	enum BindingSlots : Int
	{
		case kVertices
		case kPerPass
		case kPerMesh
		case kMaterial
	}

	init(device: MTLDevice, binding: Int, sizeInBytes: Int)
    {
		self.sizeInBytes = sizeInBytes
		super.init(device: device, sizeInBytes: sizeInBytes, slot: binding)
    }
    
	override func bind(renderEncoder: MTLRenderCommandEncoder)
    {
        copyIn(buffer: super.mtlBuffer)
		super.bind(renderEncoder: renderEncoder)
    }
    
    func copyIn(buffer: MTLBuffer)
    {
        assert(false, "This method must be overridden")
    }
}

class PerPassUniforms : Uniforms
{
    var view =   			float4x4()
    var proj =   			float4x4()
	var pickRect =			float4()
	var cameraPos =			float3()
	var lightDir = 			float3(0.7, -0.7, -0.7)
	
	init(device: MTLDevice)
	{
		let sizeInBytes =	MemoryLayout<float4x4>.stride
						+ 	MemoryLayout<float4x4>.stride
						+	MemoryLayout<float4>.stride
						+	MemoryLayout<float3>.stride
						+	MemoryLayout<float3>.stride
		super.init(device: device, binding: BindingSlots.kPerPass.rawValue, sizeInBytes: sizeInBytes)
	}
    
    override func copyIn(buffer: MTLBuffer)
    {
        var dest = buffer.contents()
        
        memcpy(dest, &view, MemoryLayout<float4x4>.stride)
		dest = dest.advanced(by: MemoryLayout<float4x4>.stride)
		
        memcpy(dest, &proj, MemoryLayout<float4x4>.stride)
		dest = dest.advanced(by: MemoryLayout<float4x4>.stride)
		
		memcpy(dest, &pickRect, MemoryLayout<float4>.stride)
		dest = dest.advanced(by: MemoryLayout<float4>.stride)
    }
}

class PerMeshUniforms : Uniforms
{
	var world =				float4x4()
	var id =				int4()

	static var nextId:		Int32 = 0
	
	init(device: MTLDevice)
    {
		let sizeInBytes =	MemoryLayout<float4x4>.stride
						+ 	MemoryLayout<int4>.stride
		self.id.x = PerMeshUniforms.nextId
		PerMeshUniforms.nextId = PerMeshUniforms.nextId + 1
		super.init(device: device, binding: BindingSlots.kPerMesh.rawValue, sizeInBytes: sizeInBytes)
    }
    
    override func copyIn(buffer: MTLBuffer)
    {
        var dest = buffer.contents()
        
		memcpy(dest, &world, MemoryLayout<float4x4>.stride)
		dest = dest.advanced(by: MemoryLayout<float4x4>.stride)
		
		memcpy(dest, &id, MemoryLayout<Int>.stride)
		dest = dest.advanced(by: MemoryLayout<Int>.stride)
    }
}

class MaterialUniforms : Uniforms
{
	var baseColour = 				float3(1.0, 1.0, 1.0)
	var roughness = 				float3(0.2, 0.2, 0.2)
	var metalness = 				float3(0.0, 0.0, 0.0)
	var irradiatedColor = 			float3(1.0, 1.0, 1.0)
	var ambientOcclusion = 			Float(0.5)

	init(device: MTLDevice)
	{
		let sizeInBytes = (MemoryLayout<float3>.stride * 4) + MemoryLayout<Float>.stride
		super.init(device: device, binding: BindingSlots.kMaterial.rawValue, sizeInBytes: sizeInBytes)
	}

	override func copyIn(buffer: MTLBuffer)
	{
		var dest = buffer.contents()

		memcpy(dest, &baseColour, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)

		memcpy(dest, &roughness, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)

		memcpy(dest, &metalness, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)

		memcpy(dest, &irradiatedColor, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)

		memcpy(dest, &ambientOcclusion, MemoryLayout<Float>.stride)
		dest = dest.advanced(by: MemoryLayout<Float>.stride)
	}
}
