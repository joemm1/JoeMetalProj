//
//  RenderPass.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import UIKit
import QuartzCore
import simd

class RenderPass
{
	var meshInstances =				[MeshInstance]()
	var perPassBuffers =			[Buffer]()
	let renderPassDescriptor: 		MTLRenderPassDescriptor
	let depthStencilState:			MTLDepthStencilState
	var lastFrameGpuTime = 			0.0
	var timeAtPresent =				Date()
	
	private var perPassUniforms =	[PerPassUniforms]()
	
	init(kernel: Kernel, clearColour: MTLClearColor)
	{
		perPassUniforms.append(PerPassUniforms(device: kernel.device))
		perPassUniforms.append(PerPassUniforms(device: kernel.device))
		
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
	
	func getPerPassUniforms() -> PerPassUniforms
	{
		return perPassUniforms[gKernel!.frameCount & 1]
	}
	
	func frame()
	{
		meshInstances = [MeshInstance]()
	}
	
	func doCulling(_ gameObjects: [GameObject])
	{
		let invView = getPerPassUniforms().view.inverse
		
		var planes = Utils.ExtractFrustumPlanesFromMatrix(getPerPassUniforms().proj)
		
		for n in 0..<planes.count
		{
			planes[n] = Utils.TransformPlane(plane: planes[n], matrix: invView)
			planes[n] = Utils.NormalizePlaneEquation(planes[n])
		}
		
		for obj in gameObjects
		{
			if obj.meshInstance.DoesWorldAabbIntersectAllHalfSpaces(planes)
			{
				meshInstances.append(obj.meshInstance)
			}
		}
		
		gKernel!.textLayer.addEntry(TextEntry("\(meshInstances.count) of \(gameObjects.count) passed culling"))
	}
	
	func render(depthTex: MTLTexture)
    {
		let drawable = gKernel!.metalLayer.nextDrawable()!
		
        //render pass
		renderPassDescriptor.colorAttachments[0].texture = drawable.texture
		renderPassDescriptor.depthAttachment.texture = depthTex
		
		//cmd buffer
		let commandBuffer = gKernel!.commandQueue.makeCommandBuffer()!
		commandBuffer.addCompletedHandler() { (cb: MTLCommandBuffer) in
			self.lastFrameGpuTime = cb.gpuEndTime - cb.gpuStartTime
		}
		
        //cmd encoder
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        //per-pass uniforms
        getPerPassUniforms().bind(renderEncoder: renderEncoder)
		
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
			mi.render(renderEncoder: renderEncoder)
        }
        
        //end encoding
        renderEncoder.endEncoding()
		
		timeAtPresent = Date()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
