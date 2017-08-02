//
//  Particle.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 02/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import simd

struct Particle
{
	var pos:			float3
	var vel:			float3
	
	init(at pos: float3, withVel vel: float3)
	{
		self.pos = pos
		self.vel = vel
	}
}

struct World
{
	var dt:				Float = 1.0 / 60.0
	var restitution:	Float = 0.5
	var planeY:			Float = 0.0
};
