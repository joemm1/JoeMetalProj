//
//  TouchMgr.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation

class TouchMgr
{
	enum Status
	{
		case noTouch
		case touchStarting
		case touchHeld
		case swiping
		case touchEnding
		case swipeEnding
	}
	
	var status =			Status.noTouch
	var lastPoint =         (0.0, 0.0) as (Float, Float)
	var lastDir =			(0.0, 0.0) as (Float, Float)
	
	func frame()
	{
		if status == .touchEnding || status == .swipeEnding
		{
			status = .noTouch
		}
		else if status == .touchStarting
		{
			status = .touchHeld
		}
		//else if status == .touchSwiping
		//{
	//		status == .swipeHeld
		//}
		
		lastDir = (0.0, 0.0)
	}
	
	func touchStart(point: CGPoint)
	{
		status = .touchStarting
		lastPoint = ((Float)(point.x), (Float)(point.y))
	}
	
	func touchMove(point: CGPoint)
	{
		status = .swiping
		let currentPoint = ((Float)(point.x), (Float)(point.y))
		lastDir = (currentPoint.0 - lastPoint.0, currentPoint.1 - lastPoint.1)
		lastPoint = currentPoint
	}
	
	func touchEnd(point: CGPoint)
	{
		if status == .touchStarting || status == .touchHeld
		{
			status = .touchEnding
		}
		else
		{
			status = .swipeEnding
		}
	}
}
