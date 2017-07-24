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
	
	var touchMgr =			TouchMgr()
	
	var gameObjects =		Array<GameObject>()
	
	var player =			Player()
	
	let kNumEnemies =		100
	
	init(view: UIView)
	{
		self.view = view
		
		kernel = Kernel(view)
		
		projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(view.bounds.size.width / view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
		
		for _ in 0..<kNumEnemies
		{
			let obj = Enemy(device: kernel.device)
			gameObjects.append(obj)
		}
	}
	
	func update(delta: CFTimeInterval)
	{
		let dt = Float(delta)
		
		player.update(dt, touchMgr: touchMgr)
		for obj in gameObjects
		{
			obj.update(dt)
		}
		
		touchMgr.frame()
	}
	
	func render()
	{
		var subMeshes = Array<SubMesh>()
		for obj in gameObjects
		{
			subMeshes.append(obj.subMesh)
		}
		
		let clearColour = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
		let perPassUniforms = PerPassUniforms(binding: 1, view: player.viewMatrix, proj: projectionMatrix)
		
		let renderPass = RenderPass()
		renderPass.render(kernel: kernel, clearColour: clearColour, perPassUniforms: perPassUniforms, subMeshes: subMeshes)
	}
}
