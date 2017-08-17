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

class RenderPass
{
	var meshInstances =			[MeshInstance]()
	var perPassUniforms:		PerPassUniforms
	var perPassBuffers =		[Buffer]()
	let renderPassDescriptor: 	MTLRenderPassDescriptor
	let depthStencilState:		MTLDepthStencilState
	
	init(kernel: Kernel, clearColour: MTLClearColor)
	{
		self.perPassUniforms = PerPassUniforms(device: kernel.device)
		
		renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.colorAttachments[0].clearColor = clearColour
		renderPassDescriptor.colorAttachments[0].storeAction = .store
		renderPassDescriptor.depthAttachment.loadAction = .clear
		renderPassDescriptor.depthAttachment.clearDepth = 1.0
		
		let depthDesc = MTLDepthStencilDescriptor()
		depthDesc.isDepthWriteEnabled = true
		depthDesc.depthCompareFunction = .less
		depthStencilState = kernel.device.makeDepthStencilState(descriptor: depthDesc)!
	}
	
	func frame()
	{
		meshInstances = [MeshInstance]()
	}
	
	func doCulling(_ gameObjects: [GameObject])
	{
		for obj in gameObjects
		{
			//#todo culling
			meshInstances.append(obj.meshInstance)
		}
	}
	
	func render(kernel: Kernel, depthTex: MTLTexture)
    {
		let drawable = kernel.metalLayer.nextDrawable()!
		
        //render pass
		renderPassDescriptor.colorAttachments[0].texture = drawable.texture
		renderPassDescriptor.depthAttachment.texture = depthTex
        
        //cmd encoder
        let commandBuffer = kernel.commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        //per-pass uniforms
        perPassUniforms.bind(renderEncoder: renderEncoder)
		
		//per-pass buffers
		for buffer in perPassBuffers
		{
			buffer.bind(renderEncoder: renderEncoder)
		}
        
        //pass state
        renderEncoder.setCullMode(MTLCullMode.front)
		renderEncoder.setDepthStencilState(depthStencilState)

        //iterate over meshes
        for mi in meshInstances
        {
			mi.render(kernel: kernel, renderEncoder: renderEncoder)
        }
        
        //end encoding
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
