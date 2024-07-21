#include <metal_texture>
#include <metal_matrix>

using namespace metal;

vertex float4 vertex_shader(const device packed_float3 *vertices [[buffer(0)]],
                            uint vertixId [[vertex_id]])
{
    return float4(vertices[vertixId], 1.0);
}


fragment half4 fragment_shader()
{
    return half4(0.0, 0.0, 1.0, 1.0);
}
