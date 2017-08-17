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
	enum BindingSlots : Int
	{
		case kPerPass = 1
		case kPerMesh
	}

	init(device: MTLDevice, binding: Int)
    {
		super.init(device: device, sizeInBytes: getSizeInBytes(), slot: binding)
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
    
    func getSizeInBytes() -> Int
    {
        assert(false, "This method must be overridden")
        return 0
    }
}

class PerPassUniforms : Uniforms
{
    var view =   			float4x4()
    var proj =   			float4x4()
	var pickRect =			float4()
	
	init(device: MTLDevice)
	{
		super.init(device: device, binding: BindingSlots.kPerPass.rawValue)
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
    
    override func getSizeInBytes() -> Int
    {
		return MemoryLayout<float4x4>.stride + MemoryLayout<float4x4>.stride + MemoryLayout<float4>.stride
    }
}

class PerMeshUniforms : Uniforms
{
	var world =				float4x4()
	var colour =			float3(1.0, 1.0, 1.0)
	var id =				int4()
	static var nextId:		Int32 = 0
	
	init(device: MTLDevice)
    {
		self.id.x = PerMeshUniforms.nextId
		PerMeshUniforms.nextId = PerMeshUniforms.nextId + 1
		super.init(device: device, binding: BindingSlots.kPerMesh.rawValue)
    }
    
    override func copyIn(buffer: MTLBuffer)
    {
        var dest = buffer.contents()
        
		memcpy(dest, &world, MemoryLayout<float4x4>.stride)
		dest = dest.advanced(by: MemoryLayout<float4x4>.stride)
		
		memcpy(dest, &colour, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)
		
		memcpy(dest, &id, MemoryLayout<Int>.stride)
		dest = dest.advanced(by: MemoryLayout<Int>.stride)
    }
    
    override func getSizeInBytes() -> Int
    {
        return MemoryLayout<float4x4>.stride + MemoryLayout<float3>.stride + MemoryLayout<int4>.stride
    }
}
