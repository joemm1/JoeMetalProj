#include <metal_stdlib>
using namespace metal;

enum FunctionConstants
{
	kFunctionConstantDoesPicking,
	kFunctionConstantAlbedoMap,
	kFunctionConstantNormalMap,
};

constant bool kDoesPicking [[ function_constant(kFunctionConstantDoesPicking) ]];
constant bool kHasAlbedoMap [[ function_constant(kFunctionConstantAlbedoMap) ]];
constant bool kHasNormalMap [[ function_constant(kFunctionConstantNormalMap) ]];
constant bool kHasAnyTextureMap = kHasAlbedoMap || kHasNormalMap;

struct VertexIn
{
    packed_float3 position;
	packed_float2 uv;
    packed_float3 normal;
};

struct VertexOut
{
    float4 position [[position]];
    float3 normal;
	float2 uv;
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
	float3 		colour;
	int			id;
	packed_int3 padding;
};

vertex VertexOut basic_vertex(
                              const device VertexIn* vertex_array           [[ buffer(0) ]],
                              const device PassUniforms& perPass       		[[ buffer(1) ]],
                              const device MeshInstanceUniforms& meshInst	[[ buffer(2) ]],
                              unsigned int vid                              [[ vertex_id ]])
{
    VertexIn VertexIn = vertex_array[vid];

    VertexOut VertexOut;
    VertexOut.position = perPass.proj * perPass.view * meshInst.world * float4(VertexIn.position,1);
	float3x3 world3x3(meshInst.world[0].xyz, meshInst.world[1].xyz, meshInst.world[2].xyz);
    VertexOut.normal = world3x3 * float3(VertexIn.normal);
	if (kHasAnyTextureMap)
		VertexOut.uv = VertexIn.uv;

    return VertexOut;
}

fragment half4 basic_fragment(VertexOut 		interpolated					[[ stage_in ]],
							  const device 		PassUniforms& perPass			[[ buffer(1) ]],
							  const device		MeshInstanceUniforms& meshInst	[[ buffer(2) ]],
							  device			int* pickedBuffer				[[ buffer(3),	function_constant(kDoesPicking)  ]],
							  texture2d<float>  albedoMap  						[[ texture(0),	function_constant(kHasAlbedoMap) ]],
							  texture2d<float>  normalMap  						[[ texture(1),	function_constant(kHasNormalMap) ]],
							  sampler           sampler2D 						[[ sampler(0) ]])
{
	const float3 kAmbientLightColour = float3(0.2, 0.2, 0.2);
	
	//float3 eye = -perPass.view[3].xyz;
	
	float3 albedo = float3(1.0f, 1.0f, 1.0f);
	if (kHasAlbedoMap)
		albedo = albedoMap.sample(sampler2D, interpolated.uv).xyz;
	
	float3 vertexNormal = normalize(interpolated.normal);
	float3 pixelNormal = vertexNormal;
	if (kHasNormalMap)
		pixelNormal = normalMap.sample(sampler2D, interpolated.uv).xyz; //jmmtodo TBN
	
	float3 diffuse = saturate(dot(vertexNormal, -perPass.lightDir)) * albedo;
	float3 specular = float3(0.0, 0.0f, 0.0f); //saturate(dot(reflect(kLightDir, interpolated.normal), eye));
	float3 ambient = kAmbientLightColour * albedo;
	
	if (kDoesPicking)
	{
		float2 pixelPos = interpolated.position.xy;
		if ( (pixelPos.x > perPass.pickRect.x) && (pixelPos.y > perPass.pickRect.y) && (pixelPos.x < perPass.pickRect.z) && (pixelPos.y < perPass.pickRect.w) )
			pickedBuffer[0] = meshInst.id;
	}
	
	float4 col((diffuse + specular + ambient) * meshInst.colour, 1);
	return (half4)col;
}
