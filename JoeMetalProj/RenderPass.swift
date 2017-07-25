//
//  RenderPass.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import QuartzCore

class MetalObjects
{
    let device :        MTLDevice
    let commandQueue:   MTLCommandQueue
    let drawable:       CAMetalDrawable
    
    init(device: MTLDevice, commandQueue: MTLCommandQueue, drawable: CAMetalDrawable)
    {
        self.device = device
        self.commandQueue = commandQueue
        self.drawable = drawable
    }
}

class RenderPass
{
	func render(kernel: Kernel, clearColour: MTLClearColor, perPassUniforms: PerPassUniforms, subMeshes: [SubMesh])
    {
		let drawable = kernel.metalLayer.nextDrawable()!
		
        //render pass
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = clearColour
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        //cmd encoder
        let commandBuffer = kernel.commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

        //per-pass uniforms
        perPassUniforms.bind(device: kernel.device, renderEncoder: renderEncoder)
        
        //pass state
        renderEncoder.setCullMode(MTLCullMode.front)
		
		
		let depthDesc = MTLDepthStencilDescriptor()
		depthDesc.isDepthWriteEnabled = true
		depthDesc.depthCompareFunction = .less
		let depthStencilState = kernel.device.makeDepthStencilState(descriptor: depthDesc)
		renderEncoder.setDepthStencilState(depthStencilState)

        //iterate over submeshes
        for subMesh in subMeshes
        {
			subMesh.render(kernel: kernel, renderEncoder: renderEncoder)
        }
        
        //end encoding
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
