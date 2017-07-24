//
//  GameObject.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation

class GameObject
{
	var subMesh:		SubMesh
	
	init(subMesh: SubMesh)
	{
		self.subMesh = subMesh
	}
	
	func update(_ dt: Float) {}
}
