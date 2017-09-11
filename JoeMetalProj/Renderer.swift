//
//  Renderer.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 11/09/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import simd

class Renderer
{
	let mainPass: 			RenderPass
	var proj =				float4x4()

	init()
	{
		mainPass = RenderPass(clearColour: MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0))
	}

	func render(camera: Camera, objs: [GameObject])
	{
		mainPass.frame()
		mainPass.getPassUniforms().proj = proj
		mainPass.getPassUniforms().view = camera.viewMatrix
		mainPass.getPassUniforms().cameraPos = camera.cameraTransform[3].xyz
		mainPass.doCulling(objs)
		mainPass.render(depthTex: gKernel.depthTex!)
	}
}

