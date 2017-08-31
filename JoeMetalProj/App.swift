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
	var proj =				float4x4()
	
	var touchMgr =			TouchMgr()

	let shaderDict:			ShaderDict
	
	var gameObjects =		Array<GameObject>()
	var player =			Player()
	let kNumEnemies =		150
	
	let r2 = 				false//true
	let xwing = 			false
	let bb = 				false
	let rocket = 			false
	let mill =				false//true
	let tree =				false//true
	let house = 			false
	let car = 				false//true
	
	enum FunctionConstants: Int
	{
		case kDoesPicking
		case kHasAlbedoMap
		case kHasNormalMap
		case kCount
	}
	
	init(view: UIView)
	{
		self.view = view
		
		kernel = Kernel(view: view)

		shaderDict = ShaderDict(vsName: "basic_vertex", fsName: "basic_fragment")
		
		//shaderset: albedo
		var perms = ShaderPermFlags(indexCount: FunctionConstants.kCount.rawValue)
		perms.add(index: FunctionConstants.kDoesPicking.rawValue, value: false)
		perms.add(index: FunctionConstants.kHasAlbedoMap.rawValue, value: true)
		perms.add(index: FunctionConstants.kHasNormalMap.rawValue, value: false)

		let shaderSet = shaderDict.get(perms: perms)

		//shaderset: no albedo
		var permsNoAlbedo = perms
		permsNoAlbedo.add(index: FunctionConstants.kHasAlbedoMap.rawValue, value: false)

		let shaderSetNoAlbedo = shaderDict.get(perms: permsNoAlbedo)

		/*
		let fnConstantValues = MTLFunctionConstantValues()
		var doesPicking = false
		fnConstantValues.setConstantValue(&doesPicking, type: .bool, index: FunctionConstants.kDoesPicking.rawValue)
		var hasAlbedoMap = true
		fnConstantValues.setConstantValue(&hasAlbedoMap, type: .bool, index: FunctionConstants.kHasAlbedoMap.rawValue)
		var hasNormalMap = false
		fnConstantValues.setConstantValue(&hasNormalMap, type: .bool, index: FunctionConstants.kHasNormalMap.rawValue)
		let shaderSet = ShaderSet(kernel: kernel, vsName: "basic_vertex", fsName: "basic_fragment", fnConstantValues: fnConstantValues)
		
		hasAlbedoMap = false
		fnConstantValues.setConstantValue(&hasAlbedoMap, type: .bool, index: FunctionConstants.kHasAlbedoMap.rawValue)
		let shaderSetNoAlbedo = ShaderSet(kernel: kernel, vsName: "basic_vertex", fsName: "basic_fragment", fnConstantValues: fnConstantValues)
		*/

		//default tex
		let defaultTex = Texture(path: "Data/cube", ext: "jpg")
		
		//enemies
		var enemyDescs = Array<EnemyDesc>()
		var cumProb = 0.0 as Float
		if xwing
		{
			let prob = 0.01 as Float
			cumProb += prob
			let xDesc = ModelDesc(shaderSet: shaderSet, modelName: "Data/X-Fighter", modelExt: "obj", calcNormals: false)
			let tex = Texture(path: "Data/XWing_Diffuse_01", ext: "jpg")
			let xModel = Model(kernel: kernel, modelDesc: xDesc, texture: tex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: xModel, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if r2
		{
			let prob = 0.05 as Float
			cumProb += prob
			let r2Desc = ModelDesc(shaderSet: shaderSet, modelName: "Data/R2-Unit", modelExt: "obj", calcNormals: false)
			let tex = Texture(path: "Data/R2D2_Diffuse", ext: "jpg")
			let r2Model = Model(kernel: kernel, modelDesc: r2Desc, texture: tex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: r2Model, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if bb
		{
			let prob = 0.05 as Float
			cumProb += prob
			let bbDesc = ModelDesc(shaderSet: shaderSet, modelName: "Data/BB-Unit", modelExt: "obj", calcNormals: false)
			let tex = Texture(path: "Data/Body_Diffuse", ext: "jpg")
			let bbModel = Model(kernel: kernel, modelDesc: bbDesc, texture: tex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: bbModel, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if rocket
		{
			let prob = 0.1 as Float
			cumProb += prob
			let rocketDesc = ModelDesc(shaderSet: shaderSet, modelName: "Data/retro_rocket", modelExt: "obj", calcNormals: true)
			let rocketModel = Model(kernel: kernel, modelDesc: rocketDesc, texture: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: rocketModel, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if mill
		{
			let prob = 0.1 as Float
			cumProb += prob
			let millDesc = ModelDesc(shaderSet: shaderSetNoAlbedo, modelName: "Data/low-poly-mill", modelExt: "obj", calcNormals: true)
			let millModel = Model(kernel: kernel, modelDesc: millDesc, texture: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: millModel, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if tree
		{
			let prob = 0.1 as Float
			cumProb += prob
			let desc = ModelDesc(shaderSet: shaderSetNoAlbedo, modelName: "Data/lowpolytree", modelExt: "obj", calcNormals: false)
			let model = Model(kernel: kernel, modelDesc: desc, texture: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: model, scale: 0.1, fullRotate: false, randomColour: false))
		}
		if house
		{
			let prob = 0.1 as Float
			cumProb += prob
			let desc = ModelDesc(shaderSet: shaderSetNoAlbedo, modelName: "Data/house_10", modelExt: "obj", calcNormals: false)
			let model = Model(kernel: kernel, modelDesc: desc, texture: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: model, scale: 0.1, fullRotate: false, randomColour: false))
		}
		if car
		{
			let prob = 0.1 as Float
			cumProb += prob
			let desc = ModelDesc(shaderSet: shaderSetNoAlbedo, modelName: "Data/Car_Obj", modelExt: "obj", calcNormals: true)
			let model = Model(kernel: kernel, modelDesc: desc, texture: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: model, scale: 0.1, fullRotate: false, randomColour: false))
		}
		
		//other
		for _ in 0..<5
		{
			let cube = ModelAsteroid(kernel: kernel, shaderSet: shaderSet, texture: defaultTex)
			enemyDescs.append(EnemyDesc(prob: (1 - cumProb) * 0.2, mesh: cube, scale: 0.5, fullRotate: true, randomColour: true))
		}
		
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
		
		proj = float4x4.makePerspectiveViewAngle(Utils.ToRads(degs: 85.0), aspectRatio: Float(view.bounds.size.width / view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
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
		
		gKernel!.update()
	}
	
	func render()
	{
		mainPass.frame()
		mainPass.getPerPassUniforms().proj = proj
		mainPass.getPerPassUniforms().view = player.viewMatrix
		mainPass.getPerPassUniforms().cameraPos = player.cameraTransform[3].xyz
		mainPass.doCulling(gameObjects)
		mainPass.render(depthTex: gKernel!.depthTex!)
	}
}
