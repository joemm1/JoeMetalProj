//
//  RenderPass.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal

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
    func render(metalObjects: MetalObjects, clearColour: MTLClearColor, perPassUniforms: PerPassUniforms, subMeshes: [SubMesh])
    {
        //render pass
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = metalObjects.drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = clearColour
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        //cmd encoder
        let commandBuffer = metalObjects.commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

        //per-pass uniforms
        perPassUniforms.bind(metalObjects: metalObjects, renderEncoder: renderEncoder)
        
        //pass state
        renderEncoder.setCullMode(MTLCullMode.front)

        //iterate over submeshes
        for subMesh in subMeshes
        {
            subMesh.render(metalObjects: metalObjects, renderEncoder: renderEncoder)
        }
        
        //end encoding
        renderEncoder.endEncoding()
        
        commandBuffer.present(metalObjects.drawable)
        commandBuffer.commit()
    }
}
