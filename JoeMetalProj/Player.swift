//
//  Player.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 05/09/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import simd

class Player : GameObject
{
	let touchMgr:					TouchMgr

	init(transform: float4x4, mesh: Mesh, touchMgr: TouchMgr)
	{
		self.touchMgr = touchMgr
		let meshInstance = MeshInstance(mesh: mesh, world: transform)

		super.init(meshInstance: meshInstance)
	}

	override func update(_ dt: Float)
	{
		meshInstance.meshInstUniforms.world[3] += float4(0, 0, -dt, 1)
	}
}
