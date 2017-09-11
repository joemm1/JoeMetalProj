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
	let renderer =			Renderer()
	var touchMgr =			TouchMgr()

	let shaderDict:			ShaderDict
	
	var gameObjects =		Array<GameObject>()
	var camera:				Camera
	var player:				Player?
	let kNumEnemies =		100 //jmmtemp 150

	let verticalScroller =	true
	
	let r2 = 				true
	let xwing = 			false
	let bb = 				false
	let mill =				true
	let tree =				true
	let house = 			false
	let car = 				false
	
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
			enemyDescs.append(EnemyDesc(prob: prob, mesh: xModel, scale: 0.01, fullRotate: verticalScroller, randomColour: false))
		}
		if r2
		{
			let prob = 0.05 as Float
			cumProb += prob
			let r2Desc = ModelDesc(shaderDict: shaderDict, modelName: "Data/R2-Unit", modelExt: "obj", calcNormals: false)
			let tex = Texture(path: "Data/R2D2_Diffuse", ext: "jpg")
			let r2Model = Model(modelDesc: r2Desc, overrideBaseColourMap: tex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: r2Model, scale: 0.01, fullRotate: verticalScroller, randomColour: false))
		}
		if bb
		{
			let prob = 0.05 as Float
			cumProb += prob
			let bbDesc = ModelDesc(shaderDict: shaderDict, modelName: "Data/BB-Unit", modelExt: "obj", calcNormals: false)
			let tex = Texture(path: "Data/Body_Diffuse", ext: "jpg")
			let bbModel = Model(modelDesc: bbDesc, overrideBaseColourMap: tex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: bbModel, scale: 0.01, fullRotate: verticalScroller, randomColour: false))
		}
		if mill
		{
			let prob = 0.1 as Float
			cumProb += prob
			let millDesc = ModelDesc(shaderDict: shaderDict, modelName: "Data/low-poly-mill", modelExt: "obj", calcNormals: true)
			let millModel = Model(modelDesc: millDesc)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: millModel, scale: 0.01, fullRotate: verticalScroller, randomColour: false))
		}
		if tree
		{
			let prob = 0.1 as Float
			cumProb += prob
			let desc = ModelDesc(shaderDict: shaderDict, modelName: "Data/lowpolytree", modelExt: "obj", calcNormals: false)
			let model = Model(modelDesc: desc, overrideBaseColourMap: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: model, scale: 0.1, fullRotate: verticalScroller, randomColour: false))
		}
		if house
		{
			let prob = 0.1 as Float
			cumProb += prob
			let desc = ModelDesc(shaderDict: shaderDict, modelName: "Data/house_10", modelExt: "obj", calcNormals: false)
			let model = Model(modelDesc: desc, overrideBaseColourMap: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: model, scale: 0.1, fullRotate: verticalScroller, randomColour: false))
		}
		if car
		{
			let prob = 0.1 as Float
			cumProb += prob
			let desc = ModelDesc(shaderDict: shaderDict, modelName: "Data/Car_Obj", modelExt: "obj", calcNormals: true)
			let model = Model(modelDesc: desc, overrideBaseColourMap: defaultTex)
			enemyDescs.append(EnemyDesc(prob: prob, mesh: model, scale: 0.1, fullRotate: verticalScroller, randomColour: false))
		}
		
		//other
		for _ in 0..<5
		{
			let model = Cube(shaderDict: shaderDict, texture: defaultTex)
			//let model = ModelAsteroid(shaderDict: shaderDict)
			enemyDescs.append(EnemyDesc(prob: (1 - cumProb) * 0.2, mesh: model, scale: 0.5, fullRotate: true, randomColour: true))
		}

		//game objects list
		for _ in 0..<kNumEnemies
		{
			let obj = Enemy(enemyDescs: enemyDescs, verticalScroller: verticalScroller)
			gameObjects.append(obj)
		}

		//player
		if verticalScroller
		{
			let desc = ModelDesc(shaderDict: shaderDict, modelName: "Data/lowpolytree", modelExt: "obj", calcNormals: true)
			let model = Model(modelDesc: desc, overrideBaseColourMap: defaultTex)
			let world = float4x4.makeTranslation(0, 0, 10)

			player = Player(transform: world, mesh: model, touchMgr: touchMgr)
			gameObjects.append(player!)
		}

		//camera
		if verticalScroller
		{
			var mat = float4x4()
			mat.rotate(-.pi / 2, axis: float3(1, 0, 0))
			mat[3] = float4(0, 15, 0, 1)
			camera = ScrollingCamera(transform: mat)
		}
		else
		{
			camera = FlyCamera(transform: float4x4())
		}
	}
	
	func updateSubViews()
	{
		kernel.updateSubViews(view: view)
		
		renderer.proj = float4x4.makePerspectiveViewAngle(Utils.ToRads(degs: 85.0), aspectRatio: Float(view.bounds.size.width / view.bounds.size.height), nearZ: 0.01, farZ: 500.0)
	}
	
	func update(delta: CFTimeInterval)
	{
		var dt = Float(delta)
		if dt > 0.33
		{
			dt = 0.33
		}

		//update camera
		camera.update(dt, touchMgr: touchMgr)

		//update game objects and take a note of which ones to delete
		var toDelete = [Int]()

		for n in 0..<gameObjects.count
		{
			if gameObjects[n].update(dt, player: player) == .kAwaitingTermination
			{
				toDelete.append(n)
			}
		}

		//delete any game objects awaiting termination
		for d in (toDelete.count - 1) ... 0
		{
			gameObjects.remove(at: d)
		}

		//update touch mgr
		touchMgr.frame()

		//update kernel
		gKernel.update()
	}
	
	func render()
	{
		renderer.render(camera: camera, objs: gameObjects)
	}
}
