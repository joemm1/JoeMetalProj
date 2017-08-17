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
	
	enum ArgBufType: Int
	{
		case perPass = 1
		case perMesh
	}
	
	init(kernel: Kernel, vsName: String, fsName: String, fnConstantValues: MTLFunctionConstantValues)
	{
		vertexProgram = try! kernel.defaultLibrary.makeFunction(name: vsName, constantValues: fnConstantValues)
		fragmentProgram = try! kernel.defaultLibrary.makeFunction(name: fsName, constantValues: fnConstantValues)
		
		//let argEncoder = vertexProgram.makeArgumentEncoder(bufferIndex: ArgBufType.perPass.rawValue)
	}
}
