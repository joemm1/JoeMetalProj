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
	let kNumEnemies =		10 //jmmtemp 150
	
	let r2 = 				false//true
	let xwing = 			false
	let bb = 				false
	let rocket = 			false
	let mill =				true
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

		shaderDict = ShaderDict(vsName: "PbmVertexShader", fsName: "PbmFragmentShader")

		//default tex
		let defaultTex = Texture(path: "Data/cube", ext: "jpg")
		
		//enemies
		var enemyDescs = Array<EnemyDesc>()
		var cumProb = 0.0 as Float
		if xwing
		{
			let prob = 0.01 as Float
			cumProb += prob
			let xDesc = ModelDesc(shaderDict: shaderDict, modelName: "Data/X-Fighter", modelExt: "obj", calcNormals: false)
			let tex = Texture(path: "Data/XWing_Diffuse_01", ext: "jpg")
			let xModel = Model(modelDesc: xDesc, overrideBaseColourMap: tex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: xModel, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if r2
		{
			let prob = 0.05 as Float
			cumProb += prob
			let r2Desc = ModelDesc(shaderDict: shaderDict, modelName: "Data/R2-Unit", modelExt: "obj", calcNormals: false)
			let tex = Texture(path: "Data/R2D2_Diffuse", ext: "jpg")
			let r2Model = Model(modelDesc: r2Desc, overrideBaseColourMap: tex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: r2Model, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if bb
		{
			let prob = 0.05 as Float
			cumProb += prob
			let bbDesc = ModelDesc(shaderDict: shaderDict, modelName: "Data/BB-Unit", modelExt: "obj", calcNormals: false)
			let tex = Texture(path: "Data/Body_Diffuse", ext: "jpg")
			let bbModel = Model(modelDesc: bbDesc, overrideBaseColourMap: tex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: bbModel, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if rocket
		{
			let prob = 0.1 as Float
			cumProb += prob
			let rocketDesc = ModelDesc(shaderDict: shaderDict, modelName: "Data/retro_rocket", modelExt: "obj", calcNormals: true)
			let rocketModel = Model(modelDesc: rocketDesc, overrideBaseColourMap: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: rocketModel, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if mill
		{
			let prob = 10 as Float //jmmtemp 0.1 as Float
			cumProb += prob
			let millDesc = ModelDesc(shaderDict: shaderDict, modelName: "Data/low-poly-mill", modelExt: "obj", calcNormals: true)
			let millModel = Model(modelDesc: millDesc)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: millModel, scale: 0.01, fullRotate: false, randomColour: false))
		}
		if tree
		{
			let prob = 0.1 as Float
			cumProb += prob
			let desc = ModelDesc(shaderDict: shaderDict, modelName: "Data/lowpolytree", modelExt: "obj", calcNormals: false)
			let model = Model(modelDesc: desc, overrideBaseColourMap: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: model, scale: 0.1, fullRotate: false, randomColour: false))
		}
		if house
		{
			let prob = 0.1 as Float
			cumProb += prob
			let desc = ModelDesc(shaderDict: shaderDict, modelName: "Data/house_10", modelExt: "obj", calcNormals: false)
			let model = Model(modelDesc: desc, overrideBaseColourMap: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: model, scale: 0.1, fullRotate: false, randomColour: false))
		}
		if car
		{
			let prob = 0.1 as Float
			cumProb += prob
			let desc = ModelDesc(shaderDict: shaderDict, modelName: "Data/Car_Obj", modelExt: "obj", calcNormals: true)
			let model = Model(modelDesc: desc, overrideBaseColourMap: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: model, scale: 0.1, fullRotate: false, randomColour: false))
		}
		
		//other
		for _ in 0..<5
		{
			let model = Cube(shaderDict: shaderDict, texture: defaultTex)
			//let model = ModelAsteroid(shaderDict: shaderDict)
			enemyDescs.append(EnemyDesc(prob: (1 - cumProb) * 0.2, mesh: model, scale: 0.5, fullRotate: true, randomColour: true))
		}
		
		for _ in 0..<kNumEnemies
		{
			let obj = Enemy(enemyDescs: enemyDescs)
			gameObjects.append(obj)
		}
		
		//main pass
		mainPass = RenderPass(clearColour: MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0))
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
		
		gKernel.update()
	}
	
	func render()
	{
		mainPass.frame()
		mainPass.getPassUniforms().proj = proj
		mainPass.getPassUniforms().view = player.viewMatrix
		mainPass.getPassUniforms().cameraPos = player.cameraTransform[3].xyz
		mainPass.doCulling(gameObjects)
		mainPass.render(depthTex: gKernel.depthTex!)
	}
}
