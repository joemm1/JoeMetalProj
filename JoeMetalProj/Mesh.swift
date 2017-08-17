//
//  Mesh.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 15/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import ModelIO
import MetalKit

class Mesh
{
	let name:               String
	let shaderSet:			ShaderSet
	let pipelineState:      MTLRenderPipelineState
	
	init(kernel: Kernel, shaderSet: ShaderSet, vertexDescriptor: MTLVertexDescriptor?, name: String)
	{
		self.shaderSet = shaderSet
		
		let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
		pipelineStateDescriptor.vertexFunction = shaderSet.vertexProgram
		pipelineStateDescriptor.fragmentFunction = shaderSet.fragmentProgram
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
		pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
		
		self.pipelineState = try! kernel.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
		self.name = name
	}
	
	func render(kernel: Kernel, renderEncoder: MTLRenderCommandEncoder)
	{
		renderEncoder.setRenderPipelineState(pipelineState)
	}
}
