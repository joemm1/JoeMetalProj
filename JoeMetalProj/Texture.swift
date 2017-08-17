//
//  Texture.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 17/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import Metal
import MetalKit

class Texture
{
	let mtlTex:				MTLTexture
	
	init(kernel: Kernel, path: String, ext: String)
	{
		let path = Bundle.main.path(forResource: path, ofType: ext)!
		let data = try! NSData(contentsOfFile: path) as Data
		mtlTex = try! kernel.textureLoader.newTexture(with: data, options: [MTKTextureLoader.Option.SRGB : (false as NSNumber)])
	}
}
