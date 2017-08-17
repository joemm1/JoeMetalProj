//
//  Buffer.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 10/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal

class Buffer
{
	let mtlBuffer: MTLBuffer
	let slot: Int
	
	init(device: MTLDevice, sizeInBytes: Int, slot: Int)
	{
		mtlBuffer = device.makeBuffer(length: sizeInBytes, options: [])!
		self.slot = slot
	}
	
	func bind(renderEncoder: MTLRenderCommandEncoder)
	{
		renderEncoder.setVertexBuffer(mtlBuffer, offset: 0, index: slot)
		renderEncoder.setFragmentBuffer(mtlBuffer, offset: 0, index: slot)
	}
	
	func bind(computeEncoder: MTLComputeCommandEncoder)
	{
		computeEncoder.setBuffer(mtlBuffer, offset: 0, index: slot)
	}
}

