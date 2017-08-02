//
//  SubMesh.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import simd

class SubMesh
{
    let name:               String
	let shaderSet:			ShaderSet
    let pipelineState:      MTLRenderPipelineState
    var uniforms:           PerSubMeshUniforms
    
	init(kernel: Kernel, shaderSet: ShaderSet, world: float4x4, name: String)
    {
		self.shaderSet = shaderSet
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = shaderSet.vertexProgram
        pipelineStateDescriptor.fragmentFunction = shaderSet.fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        self.pipelineState = try! kernel.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        self.uniforms = PerSubMeshUniforms(binding: 2, world: world)
        self.name = name
    }
    
	func render(kernel: Kernel, renderEncoder: MTLRenderCommandEncoder)
    {
        renderEncoder.setRenderPipelineState(pipelineState)
		uniforms.bind(device: kernel.device, renderEncoder: renderEncoder)
    }
}

class SubMeshPrimitive: SubMesh
{
	let vertexCount:        Int
	let vertexBuffer:       MTLBuffer
	
	init(kernel: Kernel, shaderSet: ShaderSet, world: float4x4, vertices: Array<Vertex>, name: String)
	{
		var vertexData = Array<Float>()
		for vertex in vertices
		{
			vertexData += vertex.floatBuffer()
		}
		
		let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
		vertexBuffer = kernel.device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
		
		self.vertexCount = vertices.count
		
		super.init(kernel: kernel, shaderSet: shaderSet, world: world, name: name)
	}
	
	override func render(kernel: Kernel, renderEncoder: MTLRenderCommandEncoder)
	{
		super.render(kernel: kernel, renderEncoder: renderEncoder)
		
		renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
		renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
	}
}
