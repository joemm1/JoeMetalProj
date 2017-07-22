//
//  Uniforms.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal

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
    var view:   Matrix4
    var proj:   Matrix4
    
	init(binding: Int, view: Matrix4, proj: Matrix4)
    {
        self.view = view
        self.proj = proj
        super.init(binding: binding)
    }
    
    override func copyIn(buffer: MTLBuffer)
    {
        let dest = buffer.contents()
        
        memcpy(dest, view.raw(), 64)
        memcpy(dest + 64, proj.raw(), 64)
    }
    
    override func getSizeInBytes() -> Int
    {
        return 64 * 2
    }
}

class PerSubMeshUniforms : Uniforms
{
    var world:   Matrix4
    
    init(binding: Int, world: Matrix4)
    {
        self.world = world
        super.init(binding: binding)
    }
    
    override func copyIn(buffer: MTLBuffer)
    {
        let dest = buffer.contents()
        
        memcpy(dest, world.raw(), 64)
    }
    
    override func getSizeInBytes() -> Int
    {
        return 64
    }
}
