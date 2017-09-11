//
//  Enemy.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import simd

struct EnemyDesc
{
	let prob:			Float
	let mesh:			Mesh
	let scale:			Float
	let fullRotate:		Bool
	let randomColour:	Bool
	
	init(prob: Float, mesh: Mesh, scale: Float, fullRotate: Bool, randomColour: Bool)
	{
		self.prob = prob
		self.mesh = mesh
		self.scale = scale
		self.fullRotate = fullRotate
		self.randomColour = randomColour
	}
}

class Enemy : GameObject
{
	let translation:		float4
	var rotAxis:			float3
	var rads =				0.0 as Float
	
	init(enemyDescs: [EnemyDesc], verticalScroller: Bool)
	{
		let rx = Utils.RandomFloat(min: -1.0, max: 1.0)
		let ry = Utils.RandomFloat(min: -1.0, max: 1.0)
		let rz = Utils.RandomFloat(min: -1.0, max: 1.0)
		let startRot = Utils.RandomFloat(min: 0.0, max: .pi)

		if verticalScroller
		{
			let x = Utils.RandomFloat(min: -7.0, max: 7.0)
			let z = -Utils.RandomFloat(min: 0.0, max: 100.0)
			translation = float4(x, 0, z, 1)
		}
		else
		{
			let theta = Utils.RandomFloat(min: 0.0, max: 2.0 * .pi)
			let r = Utils.RandomFloat(min: 2.0, max: 20.0)
			let y = Utils.RandomFloat(min: -4.0, max: 4.0)
			translation = float4(r * cos(theta), y, r * sin(theta), 1)
		}
		
		let p = Utils.RandomFloat(min: 0.0, max: 1.0)
		var cumProb = 0.0 as Float
		var selectedDesc = enemyDescs[0]
		
		for desc in enemyDescs
		{
			cumProb += desc.prob
			if p < cumProb
			{
				selectedDesc = desc
				break
			}
		}
		
		var world = float4x4()
		world[3] = translation
		rotAxis = (selectedDesc.fullRotate) ? float3(rx, ry, rz) : float3(0, ry, 0)
		world.rotate(startRot, axis: rotAxis)

		var material: Material?
		if selectedDesc.randomColour
		{
			material = Material(shaderDict: selectedDesc.mesh.subMeshes[0].material.shaderDict)
			material!.uniforms.baseColour = Utils.RandomColour()
		}

		let meshInstance = MeshInstance(mesh: selectedDesc.mesh, world: world, scale: selectedDesc.scale, overrideMaterial: material)
		
		super.init(meshInstance: meshInstance)
	}

	//returns false to get itself deleted
	override func update(_ dt: Float, player: Player?) -> State
	{
		if let player = player
		{
			if Utils.sphereSphereIntersect(bs1: meshInstance.getWorldBoundingSphere(), bs2: player.meshInstance.getWorldBoundingSphere())
			{
				meshInstance.isAlwaysHidden = true
				return .kAwaitingTermination
			}
		}

		rads += dt
		meshInstance.meshInstUniforms.world.rotate(dt, axis: rotAxis)
		meshInstance.meshInstUniforms.world[3] = translation

		return .kRunning
	}
}
