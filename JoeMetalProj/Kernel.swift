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

var gKernel: Kernel!

class Kernel
{
	var device:             MTLDevice
	var metalLayer:         CAMetalLayer
	//let metalGpuHeap:		MTLHeap
	//let metalSharedHeap:	MTLHeap
	var commandQueue:       MTLCommandQueue
	let textureLoader:		MTKTextureLoader
	let defaultLibrary:		MTLLibrary
	let mtkBufAllocator: 	MTKMeshBufferAllocator
	var depthTex:			MTLTexture?
	var textLayer:			TextLayer
	var frameCount = 		0
	
	let kGpuHeapSize = 		20<<20
	let kSharedHeapSize =	1<<20

	init(view: UIView)
	{
		device = MTLCreateSystemDefaultDevice()!
		
		metalLayer = CAMetalLayer()
		metalLayer.device = device
		metalLayer.pixelFormat = .bgra8Unorm
		metalLayer.framebufferOnly = true
		metalLayer.transform = CATransform3DMakeTranslation(0, 0, 0)
		view.layer.addSublayer(metalLayer)
		
		/*
		let gpuHeapDesc = MTLHeapDescriptor()
		gpuHeapDesc.size = kGpuHeapSize
		gpuHeapDesc.storageMode = .private
		metalGpuHeap = device.makeHeap(descriptor: gpuHeapDesc)!
		
		let sharedHeapDesc = MTLHeapDescriptor()
		sharedHeapDesc.size = kSharedHeapSize
		sharedHeapDesc.storageMode = .shared
		metalSharedHeap = device.makeHeap(descriptor: sharedHeapDesc)!
		*/
		
		textLayer = TextLayer()
		textLayer.transform = CATransform3DMakeTranslation(0, 0, 10)
		textLayer.setNeedsDisplay()
		textLayer.frame = view.bounds
		view.layer.addSublayer(textLayer)
		
		commandQueue = device.makeCommandQueue()!
		defaultLibrary = device.makeDefaultLibrary()!
		textureLoader = MTKTextureLoader(device: device)
		mtkBufAllocator = MTKMeshBufferAllocator(device: device)
		
		if gKernel != nil
		{
			fatalError("Attempting to have two Kernel objects")
		}
		gKernel = self
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
			
			textLayer.frame = view.bounds
			
			let depthTexDesc = MTLTextureDescriptor()
			depthTexDesc.pixelFormat = .depth32Float
			depthTexDesc.width = Int(metalLayer.drawableSize.width)
			depthTexDesc.height = Int(metalLayer.drawableSize.height)
			depthTexDesc.mipmapLevelCount = 1
			depthTexDesc.storageMode = .private
			depthTexDesc.usage = .renderTarget
			depthTex = device.makeTexture(descriptor: depthTexDesc)!
		}
	}
	
	func update()
	{
		frameCount += 1
		textLayer.setNeedsDisplay()
	}
}
