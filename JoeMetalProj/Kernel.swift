//
//  Kernel.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import UIKit

class Kernel
{
	var device:             MTLDevice
	var metalLayer:         CAMetalLayer
	var commandQueue:       MTLCommandQueue
	let textureLoader:		MTKTextureLoader
	let defaultLibrary:		MTLLibrary

	init(view: UIView)
	{
		device = MTLCreateSystemDefaultDevice()!
		
		metalLayer = CAMetalLayer()
		metalLayer.device = device
		metalLayer.pixelFormat = .bgra8Unorm
		metalLayer.framebufferOnly = true
		view.layer.addSublayer(metalLayer)
		
		commandQueue = device.makeCommandQueue()!
		defaultLibrary = device.makeDefaultLibrary()!
		
		textureLoader = MTKTextureLoader(device: device)
	}
	
	func updateSubViews(view: UIView)
	{
		if let window = view.window
		{
			let scale = window.screen.nativeScale
			let layerSize = view.bounds.size
		
			view.contentScaleFactor = scale
			metalLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
			metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)
		}
	}
}
