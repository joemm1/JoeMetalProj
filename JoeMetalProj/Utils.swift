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
	static let kSeedRand 			= true
	
	//MARK: private
	private static var firstTime = true
	private static func SeedRand()
	{
		if firstTime && kSeedRand
		{
			firstTime = false
			srand48(Int(Date().timeIntervalSince1970))
		}
	}
	
	//MARK: helpers
	static func ToRads(degs: Float) -> Float
	{
		return degs * .pi / 180.0;
	}
	
	//MARK: random
	static func RandomInt(min: Int, max: Int) -> Int
	{
		SeedRand()
		
		let r = Int(drand48() * Double(max - min))
		let randInt = min + Int(r)
		return randInt
	}
	
	static func RandomFloat(min: Float, max: Float) -> Float
	{
		SeedRand()
		
		let r = min + Float(drand48() * Double(max - min))
		return r
	}
	
	static func RandomColour() -> float3
	{
		let colour = float3( Utils.RandomFloat(min: 0.0, max: 1.0),
		                     Utils.RandomFloat(min: 0.0, max: 1.0),
		                     Utils.RandomFloat(min: 0.0, max: 1.0))
		return colour
	}
	
	//MARK: culling
	static func NormalizePlaneEquation(_ plane: float4) -> float4
	{
		let normalLength: Float = length(plane.xyz)
		return plane * ( 1.0 / ( normalLength + 0.000001 ) )
	}
	
	static func ApplyMatrixToPlaneEquation(plane: float4, mat: float4x4) -> float4
	{
		let mInv = mat.inverse
		let mInvTr = mInv.transpose
	
		let transformedPlaneEq = mInvTr * plane
		return transformedPlaneEq;
	}
	
	static func ExtractFrustumPlanesFromMatrix(_ mat: float4x4) -> [float4]
	{
		var planes = [float4]()
		
		planes.append( NormalizePlaneEquation( float4( mat[0][3] - mat[0][0], mat[1][3] - mat[1][0], mat[2][3] - mat[2][0], mat[3][3] - mat[3][0] ) ) )// Right
		planes.append( NormalizePlaneEquation( float4( mat[0][3] + mat[0][0], mat[1][3] + mat[1][0], mat[2][3] + mat[2][0], mat[3][3] + mat[3][0] ) ) ) // Left
		planes.append( NormalizePlaneEquation( float4( mat[0][3] - mat[0][1], mat[1][3] - mat[1][1], mat[2][3] - mat[2][1], mat[3][3] - mat[3][1] ) ) ) // Top
		planes.append( NormalizePlaneEquation( float4( mat[0][3] + mat[0][1], mat[1][3] + mat[1][1], mat[2][3] + mat[2][1], mat[3][3] + mat[3][1] ) ) ) // Bottom
		planes.append( NormalizePlaneEquation( float4( mat[0][3] + mat[0][2], mat[1][3] + mat[1][2], mat[2][3] + mat[2][2], mat[3][3] + mat[3][2] ) ) ) // Near
		planes.append( NormalizePlaneEquation( float4( mat[0][3] - mat[0][2], mat[1][3] - mat[1][2], mat[2][3] - mat[2][2], mat[3][3] - mat[3][2] ) ) ) // Far
		
		return planes;
	}
	
	static func TransformPlane(plane: float4, matrix: float4x4) -> float4
	{
		return NormalizePlaneEquation( ApplyMatrixToPlaneEquation(plane: plane, mat: matrix) );
	}
	
	static func PlaneTestWorldAABB(cubeMin: float3, cubeMax: float3, numPlanes: Int, pPlanes: [float4]) -> Bool
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
		
		return true;
	}
	
	static func DoesPointCloudIntersectAllHalfSpaces(_ points: [float4], planes: [float4]) -> Bool
	{		
		outer: for planeIndex in 0..<planes.count
		{
			let cullingPlane = planes[planeIndex]
			
			for point in points
			{
				if dot(point, cullingPlane) >= 0.0
				{
					//this point is inside this halfspace
					// => this pointcloud intersects the halfspace
					continue outer
				}
			}
			
			//if we got here then none of the points were inside this halfspace
			return false
		}
		
		return true;
	}

	static func sphereSphereIntersect(bs1: float4, bs2: float4) -> Bool
	{
		let dist = length(bs1.xyz - bs2.xyz)
		return dist < (bs1.w + bs2.w)
	}
}
