//
//  Player.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 24/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import simd

class Camera
{
	var cameraTransform =					float4x4()
	var viewMatrix:							float4x4 { return cameraTransform.inverse }

	init(transform: float4x4)
	{
		cameraTransform = transform
	}

	func update(_ dt: Float, touchMgr: TouchMgr)
	{
	}
}

class FlyCamera : Camera
{
	var swipeVelocity =						float2(0.0, 0.0)

	override init(transform: float4x4)
	{
		super.init(transform: transform)
	}

	override func update(_ dt: Float, touchMgr: TouchMgr)
	{
		var translate = cameraTransform[3]
		cameraTransform[3] = float4(0, 0, 0, 1)

		if touchMgr.status == .swiping
		{
			swipeVelocity = float2(touchMgr.lastDir.0, touchMgr.lastDir.1)
		}
		else
		{
			swipeVelocity *= 0.9
		}

		if abs(swipeVelocity.x) > 0.01
		{
			cameraTransform.rotate(-dt * swipeVelocity.x * 0.2, axis: float3(0, 1, 0))
		}

		var negZ = float4(0.0, 0.0, 1.0, 0.0)
		negZ = cameraTransform * negZ
		translate += negZ * dt * swipeVelocity.y
		translate.w = 1

		cameraTransform[3] = translate
	}
}

class ScrollingCamera : Camera
{
	override init(transform: float4x4)
	{
		super.init(transform: transform)
	}

	override func update(_ dt: Float, touchMgr: TouchMgr)
	{
		cameraTransform[3].z -= dt
	}
}
