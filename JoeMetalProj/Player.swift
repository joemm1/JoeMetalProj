//
//  Player.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 24/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation

class Player
{
	let viewMatrix =		Matrix4()
	var xSwipeVelocity =	0.0 as Float

	func update(_ dt: Float, touchMgr: TouchMgr)
	{
		if touchMgr.status == .swiping
		{
			xSwipeVelocity = touchMgr.lastDir.0
		}
		else
		{
			xSwipeVelocity *= 0.9
		}
		
		if abs(xSwipeVelocity) > 0.01
		{
			viewMatrix.rotate(dt * xSwipeVelocity * 0.2, x: 0, y: 1, z: 0.0)
		}
	}
}
