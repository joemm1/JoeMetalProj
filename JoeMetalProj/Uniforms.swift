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

class Uniforms
{
    let binding: Int

	init(binding: Int)
    {
        self.binding = binding;
    }
    
	func bind(device: MTLDevice, renderEncoder: MTLRenderCommandEncoder)
    {
        let uniformBuffer = device.makeBuffer(length: getSizeInBytes(), options: [])
        
        copyIn(buffer: uniformBuffer)
		
		renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: binding)
		renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, at: binding)
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
    var view:   float4x4
    var proj:   float4x4
    
	init(binding: Int, view: float4x4, proj: float4x4)
    {
        self.view = view
        self.proj = proj
        super.init(binding: binding)
    }
    
    override func copyIn(buffer: MTLBuffer)
    {
        let dest = buffer.contents()
        
        memcpy(dest, &view, 64)
        memcpy(dest + 64, &proj, 64)
    }
    
    override func getSizeInBytes() -> Int
    {
        return 64 * 2
    }
}

class PerSubMeshUniforms : Uniforms
{
	var world :		float4x4
	var colour =	float3(1.0, 1.0, 1.0)
	
    init(binding: Int, world: float4x4)
    {
        self.world = world
        super.init(binding: binding)
    }
    
    override func copyIn(buffer: MTLBuffer)
    {
        var dest = buffer.contents()
        
		memcpy(dest, &world, MemoryLayout<float4x4>.stride)
		dest = dest.advanced(by: MemoryLayout<float4x4>.stride)
		
		memcpy(dest, &colour, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)
    }
    
    override func getSizeInBytes() -> Int
    {
        return MemoryLayout<float4x4>.stride + MemoryLayout<float3>.stride
    }
}
