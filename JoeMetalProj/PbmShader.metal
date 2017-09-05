#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;
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
	float3 		roughness;
	float3 		irradiatedColor;
	float3 		metalness;
	float       ambientOcclusion;
	packed_int3 padding;
};

//MARK: internal structures
struct VertexOut
{
	float4 	position	[[ position ]];
	float2 	uv 			[[ function_constant(kHasAnyMap) ]];

	float3  worldPos;
	float3  tangent;
	float3  bitangent;
	float3  normal;
};

struct LightingParameters
{
	float3  lightDir;
	float3  viewDir;
	float3  halfVector;
	float3  reflectedVector;
	float3  normal;
	float3  reflectedColor;
	float3  irradiatedColor;
	float4  baseColor;
	float   nDoth;
	float   nDotv;
	float   nDotl;
	float   hDotl;
	float   metalness;
	float   roughness;
	float   ambientOcclusion;
};

//MARK: samplers
constexpr sampler linearSampler (mip_filter::linear,
								 mag_filter::linear,
								 min_filter::linear);

constexpr sampler nearestSampler(min_filter::linear, mag_filter::linear, mip_filter::none);

constexpr sampler mipSampler(address::clamp_to_edge, min_filter::linear, mag_filter::linear, mip_filter::linear);

//MARK: helpers
float Fresnel(float dotProduct)
{
	return pow(clamp(1.0 - dotProduct, 0.0, 1.0), 5.0);
}

float GeometryTerm(float Ndotv, float alphaG)
{
	float a = alphaG * alphaG;
	float b = Ndotv * Ndotv;
	return (float)(1.0 / (Ndotv + sqrt(a + b - a*b)));
}

float3 ComputeNormalMap(VertexOut in, texture2d<float> normalMapTexture)
{
	float4 normalMap = float4(normalize(float4(normalMapTexture.sample(nearestSampler, float2(in.uv)).rgb * 2.0 - 1.0, 0.0)));
	return float3(normalize(in.normal * normalMap.z + in.tangent * normalMap.x - in.bitangent * normalMap.y));
}

float3 ComputeDiffuse(LightingParameters parameters)
{
	float3 diffuseRawValue = float3(((1.0/PI) * parameters.baseColor) * (1.0 - parameters.metalness));
	return diffuseRawValue * parameters.nDotl * parameters.ambientOcclusion;
}

float DistributionTerm(float NdotH, float roughness)
{
	if (roughness >= 1.0)
		return 1.0 / PI;

	float roughnessSqr = roughness * roughness;

	float d = (NdotH * roughnessSqr - NdotH) * NdotH + 1;
	return roughnessSqr / (PI * d * d);
}

float3 ComputeSpecular(LightingParameters parameters)
{
	float specularRoughness = parameters.roughness * (1.0 - parameters.metalness) + parameters.metalness;

	float Ds = DistributionTerm(parameters.nDoth, specularRoughness);

	float3 Cspec0 = float3(1.0f);
	float3 Fs = float3(mix(float3(Cspec0), float3(1), Fresnel(parameters.hDotl)));
	float alphaG = (specularRoughness * 0.5 + 0.5) * (specularRoughness * 0.5 + 0.5);
	float Gs = GeometryTerm(parameters.nDotl, alphaG) * GeometryTerm(parameters.nDotv, alphaG);

	float3 specularOutput = (Ds * Gs * Fs * parameters.irradiatedColor) * (1.0 + parameters.metalness * float3(parameters.baseColor)) + float3(parameters.metalness) * parameters.irradiatedColor * float3(parameters.baseColor);

	return specularOutput * parameters.ambientOcclusion;
}

LightingParameters CalculateParameters(VertexOut					in,
									   constant PassUniforms & 		passUniforms,
									   constant MaterialUniforms & 	materialUniforms,
									   texture2d<float>   			baseColorMap        [[ function_constant(kHasBaseColourMap) ]],
									   texture2d<float>   			normalMap           [[ function_constant(kHasNormalMap) ]],
									   texture2d<float>   			metallicMap         [[ function_constant(kHasMetallicMap) ]],
									   texture2d<float>   			roughnessMap        [[ function_constant(kHasRoughnessMap) ]],
									   texture2d<float>   			ambientOcclusionMap [[ function_constant(kHasAoMap) ]],
									   texturecube<float> 			irradianceMap       [[ function_constant(kHasIrradianceMap) ]])
{
	LightingParameters parameters;

	if(kHasBaseColourMap)
		parameters.baseColor = baseColorMap.sample(linearSampler, in.uv);
	else
		parameters.baseColor = float4(materialUniforms.baseColor, 1.0f);

	if(kHasNormalMap)
		parameters.normal = ComputeNormalMap(in, normalMap);
	else
		parameters.normal = float3(in.normal);

	parameters.viewDir = normalize(passUniforms.cameraPos - float3(in.worldPos));

	if(kHasRoughnessMap)
		parameters.roughness = max(roughnessMap.sample(linearSampler, in.uv).x, 0.001f);
	else
		parameters.roughness = materialUniforms.roughness.x;

	if(kHasMetallicMap)
		parameters.metalness = metallicMap.sample(linearSampler, in.uv).x;
	else
		parameters.metalness =  materialUniforms.metalness.x;

	if(kHasAoMap)
		parameters.ambientOcclusion = ambientOcclusionMap.sample(linearSampler, in.uv).x;
	else
		parameters.ambientOcclusion = materialUniforms.ambientOcclusion;

	if(kHasIrradianceMap)
	{
		parameters.reflectedVector = reflect(-parameters.viewDir, parameters.normal);

		uint8_t mipLevel = parameters.roughness * irradianceMap.get_num_mip_levels();
		parameters.irradiatedColor = irradianceMap.sample(mipSampler, parameters.reflectedVector, level(mipLevel)).xyz;
	}
	else
	{
		parameters.irradiatedColor = materialUniforms.irradiatedColor;
	}

	parameters.lightDir = -passUniforms.lightDir;
	parameters.nDotl = max(0.001f,saturate(dot(normalize(parameters.normal), parameters.lightDir)));

	parameters.halfVector = normalize(parameters.lightDir + parameters.viewDir);
	parameters.nDoth = max(0.001f,saturate(dot(parameters.normal, parameters.halfVector)));
	parameters.nDotv = max(0.001f,saturate(dot(parameters.normal, parameters.viewDir)));
	parameters.hDotl = max(0.001f,saturate(dot(parameters.lightDir, parameters.halfVector)));

	return parameters;
}

//MARK: entry functions
vertex VertexOut PbmVertexShader(//Vertex 							in 		[[stage_in]],
								  const device Vertex* 				pIn     [[ buffer(kBufferIndexVertices) ]],
								  unsigned int 						vid		[[ vertex_id ]],
								  constant MeshInstanceUniforms & 	meshInst [[ buffer(kBufferIndexMeshInstanceUniforms) ]],
								  constant PassUniforms &			passUniforms [[ buffer(kBufferIndexPassUniforms) ]])
{
	VertexOut out;

	Vertex in = pIn[vid];
	out.position = passUniforms.proj * passUniforms.view * meshInst.world * float4(in.position, 1.0);

	if (kHasAnyMap)
		out.uv = in.uv;

	// Rotate our tangents, bitangents, and normals by the normal matrix
	const float3x3 world3x3 = float3x3(meshInst.world[0].xyz, meshInst.world[1].xyz, meshInst.world[2].xyz);
	out.tangent   = world3x3 * float3(in.tangent);
	out.bitangent = world3x3 * float3(in.bitangent);
	out.normal    = world3x3 * float3(in.normal);
	out.worldPos  = (meshInst.world * float4(in.position, 1.0)).xyz;

	return out;
}

fragment float4 PbmFragmentShader(VertexOut						in 					[[ stage_in ]],
								   constant PassUniforms & 		passUniforms    	[[ buffer(kBufferIndexPassUniforms) ]],
								   constant MeshInstanceUniforms & 	meshInst	   	[[ buffer(kBufferIndexMeshInstanceUniforms) ]],
								   constant MaterialUniforms & 	materialUniforms 	[[ buffer(kBufferIndexMaterialUniforms) ]],
								   texture2d<float>   			baseColorMap        [[ texture(kTextureIndexBaseColor),        function_constant(kHasBaseColourMap) ]],
								   texture2d<float>   			normalMap           [[ texture(kTextureIndexNormal),           function_constant(kHasNormalMap) ]],
								   texture2d<float>   			metallicMap         [[ texture(kTextureIndexMetallic),         function_constant(kHasMetallicMap) ]],
								   texture2d<float>   			roughnessMap        [[ texture(kTextureIndexRoughness),        function_constant(kHasRoughnessMap) ]],
								   texture2d<float>   			ambientOcclusionMap [[ texture(kTextureIndexAmbientOcclusion), function_constant(kHasAoMap) ]],
									texturecube<float> 			irradianceMap       [[ texture(kTextureIndexIrradianceMap),    function_constant(kHasIrradianceMap)]])
{
	LightingParameters parameters = CalculateParameters(in,
														passUniforms,
														materialUniforms,
														baseColorMap,
														normalMap,
														metallicMap,
														roughnessMap,
														ambientOcclusionMap,
														irradianceMap);

	float4 col = float4(ComputeSpecular(parameters) + ComputeDiffuse(parameters), 1.0f);
	return col;

}

