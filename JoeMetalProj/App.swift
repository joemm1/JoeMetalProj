//
//  App.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import GLKit

class App
{
	let view:				UIView
	let kernel:				Kernel
	
	let mainPass: 			RenderPass
	
	var touchMgr =			TouchMgr()
	
	var gameObjects =		Array<GameObject>()
	var player =			Player()
	let kNumEnemies =		250
	
	enum FunctionConstants: Int
	{
		case kDoesPicking
		case kHasAlbedoMap
		case kHasNormalMap
	}
	
	init(view: UIView)
	{
		self.view = view
		
		kernel = Kernel(view: view)
		
		//shader set
		let fnConstantValues = MTLFunctionConstantValues()
		var doesPicking = false
		fnConstantValues.setConstantValue(&doesPicking, type: .bool, index: FunctionConstants.kDoesPicking.rawValue)
		var hasAlbedoMap = true
		fnConstantValues.setConstantValue(&hasAlbedoMap, type: .bool, index: FunctionConstants.kHasAlbedoMap.rawValue)
		var hasNormalMap = false
		fnConstantValues.setConstantValue(&hasNormalMap, type: .bool, index: FunctionConstants.kHasNormalMap.rawValue)
		let shaderSet = ShaderSet(kernel: kernel, vsName: "basic_vertex", fsName: "basic_fragment", fnConstantValues: fnConstantValues)
		
		//enemies
		let r2 = true
		let xwing = false
		let bb = false
		let rocket = false
		
		var enemyDescs = Array<EnemyDesc>()
		if xwing
		{
			let xDesc = ModelDesc(shaderSet: shaderSet, modelName: "Data/X-Fighter", modelExt: "obj", albedoMapName: "Data/XWing_Diffuse_01", albedoMapExt: "jpg")
			let xModel = Model(kernel: kernel, modelDesc: xDesc)
			enemyDescs.append(EnemyDesc(prob: 0.01, mesh: xModel, colour: float3(1.0, 1.0, 1.0), scale: 0.01, fullRotate: false))
		}
		if r2
		{
			let r2Desc = ModelDesc(shaderSet: shaderSet, modelName: "Data/R2-Unit", modelExt: "obj", albedoMapName: "Data/R2D2_Diffuse", albedoMapExt: "jpg")
			let r2Model = Model(kernel: kernel, modelDesc: r2Desc)
			enemyDescs.append(EnemyDesc(prob: 0.05, mesh: r2Model, colour: float3(1.0, 1.0, 1.0), scale: 0.01, fullRotate: false))
		}
		if bb
		{
			let bbDesc = ModelDesc(shaderSet: shaderSet, modelName: "Data/BB-Unit", modelExt: "obj", albedoMapName: "Data/Body_Diffuse", albedoMapExt: "jpg")
			let bbModel = Model(kernel: kernel, modelDesc: bbDesc)
			enemyDescs.append(EnemyDesc(prob: 0.01, mesh: bbModel, colour: float3(1.0, 1.0, 1.0), scale: 0.01, fullRotate: false))
		}
		if rocket
		{
			let rocketDesc = ModelDesc(shaderSet: shaderSet, modelName: "Data/retro_rocket", modelExt: "obj", albedoMapName: "Data/cube", albedoMapExt: "png")
			let rocketModel = Model(kernel: kernel, modelDesc: rocketDesc)
			enemyDescs.append(EnemyDesc(prob: 0.1, mesh: rocketModel, colour: float3(1.0, 1.0, 1.0), scale: 0.01, fullRotate: false))
		}
		let cube = Cube(kernel: kernel, shaderSet: shaderSet)
		enemyDescs.append(EnemyDesc(prob: 1, mesh: cube, colour: Utils.RandomColour(), scale: 0.5, fullRotate: true))
		
		for _ in 0..<kNumEnemies
		{
			let obj = Enemy(kernel: kernel, enemyDescs: enemyDescs)
			gameObjects.append(obj)
		}
		
		//main pass
		mainPass = RenderPass(kernel: kernel, clearColour: MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0))
	}
	
	func updateSubViews()
	{
		kernel.updateSubViews(view: view)
		
		mainPass.perPassUniforms.proj = float4x4.makePerspectiveViewAngle(Utils.ToRads(degs: 85.0), aspectRatio: Float(view.bounds.size.width / view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
	}
	
	func update(delta: CFTimeInterval)
	{
		var dt = Float(delta)
		if dt > 0.33
		{
			dt = 0.33
		}
		
		player.update(dt, touchMgr: touchMgr)
		for obj in gameObjects
		{
			obj.update(dt)
		}
		
		touchMgr.frame()
	}
	
	func render()
	{
		mainPass.frame()
		mainPass.perPassUniforms.view = player.viewMatrix
		mainPass.doCulling(gameObjects)
		mainPass.render(kernel: kernel, depthTex: kernel.depthTex!)
	}
}
