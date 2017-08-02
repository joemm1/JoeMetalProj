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
		case perSubMesh
	}
	
	init(kernel: Kernel, vsName: String, fsName: String)
	{
		vertexProgram = kernel.defaultLibrary.makeFunction(name: vsName)!
		fragmentProgram = kernel.defaultLibrary.makeFunction(name: fsName)!
		
		//let argEncoder = vertexProgram.makeArgumentEncoder(bufferIndex: ArgBufType.perPass.rawValue)
	}
}
