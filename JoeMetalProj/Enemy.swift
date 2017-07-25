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

class Enemy : GameObject
{
	let translation:		float4
	let rotAxis:			float3
	var rads =				0.0 as Float
	
	init(device: MTLDevice)
	{
		let rx = Utils.RandomFloat(min: -1.0, max: 1.0)
		let ry = Utils.RandomFloat(min: -1.0, max: 1.0)
		let rz = Utils.RandomFloat(min: -1.0, max: 1.0)
		rotAxis = float3(rx, ry,rz)
		
		let theta = Utils.RandomFloat(min: 0.0, max: 2.0 * .pi)
		let r = Utils.RandomFloat(min: 2.0, max: 40.0)
		let y = Utils.RandomFloat(min: -4.0, max: 4.0)
		translation = float4(r * cos(theta), y, r * sin(theta), 1)
		
		super.init(subMesh: Cube(device: device, world: float4x4()))
		subMesh.uniforms.colour = float3(Utils.RandomFloat(min: 0.0, max: 1.0),
		                                 Utils.RandomFloat(min: 0.0, max: 1.0),
		                                 Utils.RandomFloat(min: 0.0, max: 1.0));
	}
	
	override func update(_ dt: Float)
	{
		rads += dt
		subMesh.uniforms.world = float4x4.makeScale(0.5, 0.5, 0.5)
		subMesh.uniforms.world.rotate(rads, axis: rotAxis)
		subMesh.uniforms.world[3] = translation
	}
}
