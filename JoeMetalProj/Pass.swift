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

class PassUniforms : Uniforms
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
		super.init(device: device, binding: BindingSlots.kPass.rawValue, sizeInBytes: sizeInBytes)
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

		memcpy(dest, &cameraPos, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)

		memcpy(dest, &lightDir, MemoryLayout<float3>.stride)
		dest = dest.advanced(by: MemoryLayout<float3>.stride)
	}
}

class RenderPass
{
	var meshInstances =				[MeshInstance]()
	var passBuffers =			[Buffer]()
	let renderPassDescriptor: 		MTLRenderPassDescriptor
	let depthStencilState:			MTLDepthStencilState
	var lastFrameGpuTime = 			0.0
	var timeAtPresent =				Date()
	
	private var passUniforms =	[PassUniforms]()
	
	init(clearColour: MTLClearColor)
	{
		passUniforms.append(PassUniforms(device: gKernel.device))
		passUniforms.append(PassUniforms(device: gKernel.device))
		
		renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.colorAttachments[0].clearColor = clearColour
		renderPassDescriptor.colorAttachments[0].storeAction = .store
		renderPassDescriptor.depthAttachment.loadAction = .clear
		renderPassDescriptor.depthAttachment.clearDepth = 1.0
		
		let depthDesc = MTLDepthStencilDescriptor()
		depthDesc.isDepthWriteEnabled = true
		depthDesc.depthCompareFunction = .less
		depthStencilState = gKernel.device.makeDepthStencilState(descriptor: depthDesc)!
	}
	
	func getPassUniforms() -> PassUniforms
	{
		return passUniforms[gKernel.frameCount & 1]
	}
	
	func frame()
	{
		meshInstances = [MeshInstance]()
	}
	
	func doCulling(_ gameObjects: [GameObject])
	{
		let invView = getPassUniforms().view.inverse
		
		var planes = Utils.ExtractFrustumPlanesFromMatrix(getPassUniforms().proj)
		
		for n in 0..<planes.count
		{
			planes[n] = Utils.TransformPlane(plane: planes[n], matrix: invView)
			planes[n] = Utils.NormalizePlaneEquation(planes[n])
		}
		
		for obj in gameObjects
		{
			if obj.meshInstance.isVisible(planes)
			{
				meshInstances.append(obj.meshInstance)
			}
		}
		
		gKernel.textLayer.addEntry(TextEntry("\(meshInstances.count) of \(gameObjects.count) passed culling"))
	}
	
	func render(depthTex: MTLTexture)
    {
		let drawable = gKernel.metalLayer.nextDrawable()!
		
        //render pass
		renderPassDescriptor.colorAttachments[0].texture = drawable.texture
		renderPassDescriptor.depthAttachment.texture = depthTex
		
		//cmd buffer
		let commandBuffer = gKernel.commandQueue.makeCommandBuffer()!
		commandBuffer.addCompletedHandler() { (cb: MTLCommandBuffer) in
			self.lastFrameGpuTime = cb.gpuEndTime - cb.gpuStartTime
		}
		
        //cmd encoder
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        //pass uniforms
        getPassUniforms().bind(renderEncoder: renderEncoder)
		
		//pass buffers
		for buffer in passBuffers
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
