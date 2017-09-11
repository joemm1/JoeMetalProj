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
		let meshInstance = MeshInstance(mesh: mesh, world: transform, scale: 1.0)

		super.init(meshInstance: meshInstance)
	}

	override func update(_ dt: Float, player: Player?) -> State
	{
		if touchMgr.status == .swiping
		{
			meshInstance.meshInstUniforms.world[3].x += touchMgr.lastDir.0 * 0.03
			meshInstance.meshInstUniforms.world[3].z += touchMgr.lastDir.1 * 0.03
		}

		meshInstance.meshInstUniforms.world[3].z -= dt

		return .kRunning
	}
}
