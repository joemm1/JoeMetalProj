//
//  Shader.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 01/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal

class ShaderSet
{
	let fragmentProgram: 		MTLFunction
	let vertexProgram: 			MTLFunction
	
	init(vsName: String, fsName: String, fnConstantValues: MTLFunctionConstantValues)
	{
		vertexProgram = try! gKernel!.defaultLibrary.makeFunction(name: vsName, constantValues: fnConstantValues)
		fragmentProgram = try! gKernel!.defaultLibrary.makeFunction(name: fsName, constantValues: fnConstantValues)
	}
}

struct ShaderPermFlags: Hashable
{
	let fnConstantValues = 	MTLFunctionConstantValues()
	var flags =				Int(0)
	var values = 			[Bool]()

	init(indexCount: Int)
	{
		for _ in 0..<indexCount
		{
			values.append(false)
		}
	}

	mutating func add(index: Int, value: Bool)
	{
		values[index] = value
		flags &= ~(1 << index)
		flags |= (1 << index)
		fnConstantValues.setConstantValue(&values[index], type: .bool, index: index)
	}

	var hashValue: Int
	{
		return flags
	}

	static func == (lhs: ShaderPermFlags, rhs: ShaderPermFlags) -> Bool
	{
		return lhs.flags == rhs.flags
	}
}

class ShaderDict
{
	var dict =					Dictionary<ShaderPermFlags, ShaderSet>()

	let vsName:					String
	let fsName:					String

	init(vsName: String, fsName: String)
	{
		self.vsName = vsName
		self.fsName = fsName
	}

	func get(perms: ShaderPermFlags) -> ShaderSet
	{
		if dict[perms] != nil
		{
			return dict[perms]!
		}
		else
		{
			dict[perms] = ShaderSet(vsName: vsName, fsName: fsName, fnConstantValues: perms.fnConstantValues)
			return dict[perms]!
		}
	}
}
