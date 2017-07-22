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
	var swiping =           false
	var lastPoint =         CGPoint()
	
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
	}
	
	func touchStart(point: CGPoint)
	{
		status = .touchStarting
		lastPoint = point
	}
	
	func touchMove(point: CGPoint)
	{
		status = .swiping
		let currentPoint = point
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
