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
	let aabbMin:			float3
	let aabbMax:			float3
	
	init(kernel: Kernel, shaderSet: ShaderSet, vertexDescriptor: MTLVertexDescriptor?, aabbMin: float3, aabbMax: float3, name: String)
	{
		self.shaderSet = shaderSet
		
		let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
		pipelineStateDescriptor.vertexFunction = shaderSet.vertexProgram
		pipelineStateDescriptor.fragmentFunction = shaderSet.fragmentProgram
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
		pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
		pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
		
		self.pipelineState = try! kernel.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
		
		self.aabbMin = aabbMin
		self.aabbMax = aabbMax
		
		self.name = name
	}
	
	func render(kernel: Kernel, renderEncoder: MTLRenderCommandEncoder)
	{
		renderEncoder.setRenderPipelineState(pipelineState)
	}
	
	func getWorldAabbPoints(world: float4x4) -> [float4]
	{
		let aabbMinWorld = world * float4(aabbMin, 1.0)
		let aabbMaxWorld = world * float4(aabbMax, 1.0)
		let aabb: [float4] = [ aabbMinWorld, aabbMaxWorld ]
		
		var worldPoints = [float4]()
		for i in 0..<8
		{
			worldPoints.append( float4( aabb[i>>2].x, aabb[(i>>1)&1].y, aabb[i&1].z, 1.0) )
		}
		
		return worldPoints
	}
}
