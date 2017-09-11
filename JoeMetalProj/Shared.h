//
//  Shared.h
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 11/09/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

#ifndef Shared_h
#define Shared_h

constant float PI = 3.1415926535897932384626433832795;

//MARK: function constants
enum FunctionConstantIndices
{
	kFunctionConstantBaseColorMapIndex,
	kFunctionConstantNormalMapIndex,
	kFunctionConstantMetallicMapIndex,
	kFunctionConstantRoughnessMapIndex,
	kFunctionConstantAmbientOcclusionMapIndex,
	kFunctionConstantIrradianceMapIndex
};
constant bool kHasBaseColourMap        	[[ function_constant(kFunctionConstantBaseColorMapIndex) ]];
constant bool kHasNormalMap            	[[ function_constant(kFunctionConstantNormalMapIndex) ]];
constant bool kHasMetallicMap          	[[ function_constant(kFunctionConstantMetallicMapIndex) ]];
constant bool kHasRoughnessMap         	[[ function_constant(kFunctionConstantRoughnessMapIndex) ]];
constant bool kHasAoMap 				[[ function_constant(kFunctionConstantAmbientOcclusionMapIndex) ]];
constant bool kHasIrradianceMap        	[[ function_constant(kFunctionConstantIrradianceMapIndex) ]];
constant bool kHasAnyMap = ( kHasBaseColourMap        	||
							kHasNormalMap            	||
							kHasMetallicMap          	||
							kHasRoughnessMap         	||
							kHasAoMap 					||
							kHasIrradianceMap );

//MARK: enums
enum BufferIndices
{
	kBufferIndexVertices				= 0,
	kBufferIndexPassUniforms	  		= 1,
	kBufferIndexMeshInstanceUniforms  	= 2,
	kBufferIndexMaterialUniforms 		= 3
};

enum VertexAttributes
{
	kVertexAttributePosition  	= 0,
	kVertexAttributeUv		  	= 1,
	kVertexAttributeNormal    	= 2,
	kVertexAttributeTangent   	= 3,
	kVertexAttributeBitangent 	= 4
};

enum TextureIndices
{
	kTextureIndexBaseColor        = 0,
	kTextureIndexMetallic         = 1,
	kTextureIndexRoughness        = 2,
	kTextureIndexNormal           = 3,
	kTextureIndexAmbientOcclusion = 4,
	kTextureIndexIrradianceMap    = 5,
};

//MARK: structures
struct Vertex
{
	//#todo
	/*
	 float3 position  [[ attribute(kVertexAttributePosition) ]];
	 float2 uv		 [[ attribute(kVertexAttributeUv) ]];
	 float3 normal    [[ attribute(kVertexAttributeNormal) ]];
	 float3 tangent   [[ attribute(kVertexAttributeTangent) ]];
	 float3 bitangent [[ attribute(kVertexAttributeBitangent) ]];
	 */
	packed_float3 position;
	packed_float2 uv;
	packed_float3 normal;
	packed_float3 tangent;
	packed_float3 bitangent;
};

struct PassUniforms
{
	float4x4 	view;
	float4x4 	proj;
	float4		pickRect;
	float3		cameraPos;
	float3		lightDir;
};

struct MeshInstanceUniforms
{
	float4x4 	world;
	int			id;
	packed_int3 padding;
};

struct MaterialUniforms
{
	float3 		baseColor;
	float 		roughness;
	float 		metalness;
	float       ambientOcclusion;
	float		padding;
	float3 		irradiatedColor;
};

#endif /* Shared_h */
