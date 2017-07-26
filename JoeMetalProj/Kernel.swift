//
//  Kernel.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import UIKit

class Kernel
{
	var device:             MTLDevice
	var metalLayer:         CAMetalLayer
	var commandQueue:       MTLCommandQueue

	init(_ view: UIView)
	{
		device = MTLCreateSystemDefaultDevice()!
		
		metalLayer = CAMetalLayer()
		metalLayer.device = device
		metalLayer.pixelFormat = .bgra8Unorm
		metalLayer.framebufferOnly = true
		metalLayer.frame = view.layer.frame
		view.layer.addSublayer(metalLayer)
		
		commandQueue = device.makeCommandQueue()!
	}
}
