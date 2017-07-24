#include <metal_stdlib>
using namespace metal;

struct VertexIn
{
    packed_float3 position;
    packed_float3 normal;
};

struct VertexOut
{
    float4 position [[position]];
    float3 normal;
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

    return VertexOut;
}

fragment half4 basic_fragment(VertexOut interpolated						[[stage_in]],
							  const device PerSubMeshUniforms& perSubMesh   [[ buffer(2) ]])
{
	const float3 kLightDir = float3(-0.7f, 0.7f, 0.7f);
	const float3 kAmbientLightColour = float3(0.2, 0.2, 0.2);
	
	float3 diffuse = saturate(dot(interpolated.normal, kLightDir));
	float3 ambient = kAmbientLightColour;
	float4 col((diffuse + ambient) * perSubMesh.colour, 1);
	return (half4)col;
}
