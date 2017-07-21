//
//  SubMesh.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal

class SubMesh
{
    let device:             MTLDevice
    let name:               String
    let vertexCount:        Int
    let vertexBuffer:       MTLBuffer
    let pipelineState:      MTLRenderPipelineState
    var uniforms:           PerSubMeshUniforms
    
    init(device: MTLDevice, world: Matrix4, vertices: Array<Vertex>, name: String)
    {
        var vertexData = Array<Float>()
        for vertex in vertices
        {
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        //#todo: move to Shader class etc
        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        self.uniforms = PerSubMeshUniforms(device: device, binding: 2, world: world)
        self.device = device
        self.vertexCount = vertices.count
        self.name = name
    }
    
    func update(delta: CFTimeInterval) {}
    
    func render(metalObjects: MetalObjects, renderEncoder: MTLRenderCommandEncoder)
    {
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        
        uniforms.bind(metalObjects: metalObjects, renderEncoder: renderEncoder)
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
    }
}
