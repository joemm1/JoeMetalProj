//
//  Enemy.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation

class Enemy : GameObject
{
	let rx = Utils.RandomFloat(min: -1.0, max: 1.0)
	let ry = Utils.RandomFloat(min: -1.0, max: 1.0)
	let rz = Utils.RandomFloat(min: -1.0, max: 1.0)
	
	init(device: MTLDevice)
	{
		let theta = Utils.RandomFloat(min: 0.0, max: 2.0 * 3.141592654)
		let r = Utils.RandomFloat(min: 5.0, max: 20.0)
		let y = Utils.RandomFloat(min: -4.0, max: 4.0)
		
		let world = Matrix4()
		world.translate(r * cos(theta), y: y, z: r * sin(theta))
		world.scale(0.5, y: 0.5, z: 0.5)
		
		super.init(subMesh: Cube(device: device, world: world))
		subMesh.uniforms.colour =
			(
				Utils.RandomFloat(min: 0.0, max: 1.0),
				Utils.RandomFloat(min: 0.0, max: 1.0),
				Utils.RandomFloat(min: 0.0, max: 1.0)
			);
	}
	
	override func update(_ dt: Float)
	{
		subMesh.uniforms.world.rotate(dt * rx, y: dt * ry, z: dt * rz)
	}
}
