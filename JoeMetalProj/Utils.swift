//
//  Utils.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 22/07/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import simd

class Utils
{
	//MARK: helpers
	static func ToRads(degs: Float) -> Float
	{
		return degs * .pi / 180.0;
	}
	
	//MARK: random
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
	
	static func RandomColour() -> float3
	{
		let colour = float3( Utils.RandomFloat(min: 0.0, max: 1.0),
		                     Utils.RandomFloat(min: 0.0, max: 1.0),
		                     Utils.RandomFloat(min: 0.0, max: 1.0))
		return colour
	}
	
	//MARK: culling
	func NormalizePlaneEquation(_ plane: float4) -> float4
	{
		let normalLength: Float = length(plane.xyz)
		return plane * ( 1.0 / ( normalLength + 0.000001 ) )
	}
	
	func ApplyMatrixToPlaneEquation(plane: float4, mat: float4x4) -> float4
	{
		let mInv = mat.inverse
		let mInvTr = mInv.transpose
	
		let transformedPlaneEq = mInvTr * plane
		return transformedPlaneEq;
	}
	
	func ExtractFrustumPlanesFromMatrix(from mat: float4x4, to pPlanes: inout [float4])
	{
		pPlanes[0] = NormalizePlaneEquation( float4( mat[0][3] - mat[0][0], mat[1][3] - mat[1][0], mat[2][3] - mat[2][0], mat[3][3] - mat[3][0] ) ) // Right
		pPlanes[1] = NormalizePlaneEquation( float4( mat[0][3] + mat[0][0], mat[1][3] + mat[1][0], mat[2][3] + mat[2][0], mat[3][3] + mat[3][0] ) ) // Left
		pPlanes[2] = NormalizePlaneEquation( float4( mat[0][3] - mat[0][1], mat[1][3] - mat[1][1], mat[2][3] - mat[2][1], mat[3][3] - mat[3][1] ) ) // Top
		pPlanes[3] = NormalizePlaneEquation( float4( mat[0][3] + mat[0][1], mat[1][3] + mat[1][1], mat[2][3] + mat[2][1], mat[3][3] + mat[3][1] ) ) // Bottom
		pPlanes[4] = NormalizePlaneEquation( float4( mat[0][3] + mat[0][2], mat[1][3] + mat[1][2], mat[2][3] + mat[2][2], mat[3][3] + mat[3][2] ) ) // Near
		pPlanes[5] = NormalizePlaneEquation( float4( mat[0][3] - mat[0][2], mat[1][3] - mat[1][2], mat[2][3] - mat[2][2], mat[3][3] - mat[3][2] ) ) // Far
	}
	
	func TransformPlane(plane: float4, matrix: float4x4) -> float4
	{
		return NormalizePlaneEquation( ApplyMatrixToPlaneEquation(plane: plane, mat: matrix) );
	}
	
	func PlaneTestWorldAABB(cubeMin: float3, cubeMax: float3, numPlanes: Int, pPlanes: [float4]) -> Bool
	{
		let aabbPoints: [float3] = [ cubeMin, cubeMax ]
		
		var worldCube = [float4]()
		for i in 0..<8
		{
			worldCube.append( float4( aabbPoints[i>>2].x, aabbPoints[(i>>1)&1].y, aabbPoints[i&1].z, 1.0) )
		}
		
		for planeIndex in 0..<numPlanes
		{
			let cullingPlane = pPlanes[planeIndex]
			
			var culledPoints = 0;
			for i in 0..<8
			{
				if dot( worldCube[i], cullingPlane ) < 0.0
				{
					culledPoints += 1
				}
			}
			
			if culledPoints == 8
			{
				return false; // all points are behind one of the planes
			}
		}
		
		// could also count if all points passed all planes and return as an "all in" state, right now that doesn't matter
		// but later on it would be useful to determine which user planes should be passed on to the shader
		return true;
	}
}
