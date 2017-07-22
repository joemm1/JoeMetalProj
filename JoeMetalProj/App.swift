//
//  App.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal

class App
{
	let view:				UIView
	let kernel:				Kernel
	
	let projectionMatrix:   Matrix4
	var subMeshes =         Array<SubMesh>()
	var touchMgr =			TouchMgr()
	
	init(view: UIView)
	{
		self.view = view
		
		kernel = Kernel(view)
		
		projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(view.bounds.size.width / view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
		
		let cubeWorld = Matrix4()
		cubeWorld.translate(0.0, y: 0.0, z: -7.0)
		let cube = Cube(device: kernel.device, world: cubeWorld)
		subMeshes.append(cube)
	}
	
	func update(delta: CFTimeInterval)
	{
		touchMgr.frame()
		if touchMgr.status == .touchHeld
		{
			subMeshes[0].uniforms.world.scale(0.99, y: 0.99, z: 0.99)
		}

		let dt = Float(delta)
		subMeshes[0].uniforms.world.rotateAroundX(dt, y: dt, z: dt)
	}
	
	func render()
	{
		let viewMatrix = Matrix4()
		viewMatrix.translate(0.0, y: 0.0, z: 0.0)
		//viewMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
		
		let clearColour = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
		let perPassUniforms = PerPassUniforms(binding: 1, view: viewMatrix, proj: projectionMatrix)
		
		let renderPass = RenderPass()
		renderPass.render(kernel: kernel, clearColour: clearColour, perPassUniforms: perPassUniforms, subMeshes: subMeshes)
	}
}
