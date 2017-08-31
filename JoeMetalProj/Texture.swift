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
	
	init(path: String, ext: String)
	{
		let options = [
			MTKTextureLoader.Option.SRGB: false,
			MTKTextureLoader.Option.textureStorageMode: MTLStorageMode.private,
			MTKTextureLoader.Option.textureCPUCacheMode: MTLTextureUsage.shaderRead
			] as [MTKTextureLoader.Option : Any]

		let path = Bundle.main.path(forResource: path, ofType: ext)!
		let data = try! NSData(contentsOfFile: path) as Data
		mtlTex = try! gKernel!.textureLoader.newTexture(with: data, options: options)
	}

	init(url: URL)
	{
		let options = [
			MTKTextureLoader.Option.SRGB: false,
			MTKTextureLoader.Option.textureStorageMode: MTLStorageMode.private,
			MTKTextureLoader.Option.textureCPUCacheMode: MTLTextureUsage.shaderRead
			] as [MTKTextureLoader.Option : Any]

		let path = Bundle.main.path(forResource: url.deletingPathExtension().absoluteString, ofType: url.pathExtension)!
		let data = try! NSData(contentsOfFile: path) as Data
		mtlTex = try! gKernel!.textureLoader.newTexture(with: data, options: options)
	}
}
