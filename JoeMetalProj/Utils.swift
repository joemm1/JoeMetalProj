//
//  Utils.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation

class Utils
{
	static func RandomInt(min: Int, max: Int) -> Int
	{
		let randInt = min + Int(arc4random_uniform(UInt32(max - min)))
		return randInt
	}
	
	static func RandomFloat(min: Float, max: Float) -> Float
	{
		let randInt = RandomInt(min: (Int)(min * 1000.0), max: (Int)(max * 1000.0))
		let randFloat = (Float)(randInt) / 1000.0
		return randFloat
	}
}
