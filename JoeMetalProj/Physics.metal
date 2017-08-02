//
//  Physics.metal
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 02/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct ParticleCore
{
	float4x4		world;
	float3			col;
};

struct ParticleEx
{
	float3			vel;
};

struct Env
{
	float		dt;
	float		restitution;
	float		planeY;
};

kernel void Evolve(device 		ParticleCore* 	particlesCore 	[[ buffer(0) ]],
				   device 		ParticleEx* 	particlesEx 	[[ buffer(1) ]],
				   const device Env& 			env 			[[ buffer(2) ]],
							   uint2			gridId			[[ thread_position_in_grid ]]
				   )
{
	ParticleCore p = particlesCore[gridId.x];
	ParticleEx px = particlesEx[gridId.x];
	p.world[3].xyz += px.vel * env.dt;
	px.vel += 9.81f * env.dt;
	if (p.world[3].y < env.planeY)
	{
		px.vel *= -env.restitution;
	}
}
