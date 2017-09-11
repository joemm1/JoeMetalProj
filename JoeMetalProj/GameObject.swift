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
	enum State : Int
	{
		case kInitialised, kRunning, kAwaitingTermination
	}

	var meshInstance:		MeshInstance
	var state:				State
	
	init(meshInstance: MeshInstance)
	{
		self.meshInstance = meshInstance
		self.state = .kInitialised
	}
	
	func update(_ dt: Float, player: Player?) -> State
	{
		//override me
		return .kRunning
	}
}
