#include <metal_stdlib>
using namespace metal;

struct VertexIn
{
    packed_float3 position;
    packed_float3 normal;
	packed_float2 uv;
};

struct VertexOut
{
    float4 position [[position]];
    float3 normal;
	float2 uv;
};

struct PerPassUniforms
{
    float4x4 view;
    float4x4 proj;
};

struct PerSubMeshUniforms
{
    float4x4 world;
	float3 colour;
};

vertex VertexOut basic_vertex(
                              const device VertexIn* vertex_array           [[ buffer(0) ]],
                              const device PerPassUniforms& perPass         [[ buffer(1) ]],
                              const device PerSubMeshUniforms& perSubMesh   [[ buffer(2) ]],
                              unsigned int vid                              [[ vertex_id ]])
{
    VertexIn VertexIn = vertex_array[vid];

    VertexOut VertexOut;
    VertexOut.position = perPass.proj * perPass.view * perSubMesh.world * float4(VertexIn.position,1);
	float3x3 world3x3(perSubMesh.world[0].xyz, perSubMesh.world[1].xyz, perSubMesh.world[2].xyz);
    VertexOut.normal = world3x3 * float3(VertexIn.normal);
	VertexOut.uv = VertexIn.uv;

    return VertexOut;
}

fragment half4 basic_fragment(VertexOut 		interpolated					[[ stage_in ]],
							  const device 		PerPassUniforms& perPass		[[ buffer(1) ]],
							  const device		PerSubMeshUniforms& perSubMesh  [[ buffer(2) ]],
							  texture2d<float>  tex2D     						[[ texture(0) ]],
							  sampler           sampler2D 						[[ sampler(0) ]])
{
	const float3 kLightDir = float3(-0.7f, 0.7f, 0.7f);
	const float3 kAmbientLightColour = float3(0.2, 0.2, 0.2);
	
	float3 eye = -perPass.view[3].xyz;
	float3 albedo = tex2D.sample(sampler2D, interpolated.uv).xyz;
	
	float3 diffuse = saturate(dot(interpolated.normal, kLightDir)) * albedo;
	float3 specular = saturate(dot(reflect(kLightDir, interpolated.normal), eye));
	float3 ambient = kAmbientLightColour * albedo;
	
	float4 col((diffuse + /*specular +*/ ambient) * perSubMesh.colour, 1);
	return (half4)col;
}
