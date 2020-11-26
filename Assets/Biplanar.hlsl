// Biplanar mapping shader originally written by Inigo Quilez
// https://iquilezles.org/www/articles/biplanar/biplanar.htm

// Biplanar mapping for color textures
void Biplanar_float
  (Texture2D tex, SamplerState samp,
   float3 wpos, float3 wnrm, out float4 output)
{
    // Coordinate derivatives for texturing
    float3 p = wpos;
    float3 n = abs(wnrm);
    float3 dpdx = ddx(p);
    float3 dpdy = ddy(p);

    // Major axis (in x; yz are following axis)
    uint3 ma = (n.x > n.y && n.x > n.z) ? uint3(0, 1, 2) :
               (n.y > n.z             ) ? uint3(1, 2, 0) :
                                          uint3(2, 0, 1) ;

    // Minor axis (in x; yz are following axis)
    uint3 mi = (n.x < n.y && n.x < n.z) ? uint3(0, 1, 2) :
               (n.y < n.z             ) ? uint3(1, 2, 0) :
                                          uint3(2, 0, 1) ;

    // Median axis (in x; yz are following axis)
    uint3 me = 3 - mi - ma;

    // Project + fetch
    float4 x = SAMPLE_TEXTURE2D_GRAD(tex, samp,
                                     float2(   p[ma.y],    p[ma.z]), 
                                     float2(dpdx[ma.y], dpdx[ma.z]), 
                                     float2(dpdy[ma.y], dpdy[ma.z]));

    float4 y = SAMPLE_TEXTURE2D_GRAD(tex, samp,
                                     float2(   p[me.y],    p[me.z]), 
                                     float2(dpdx[me.y], dpdx[me.z]),
                                     float2(dpdy[me.y], dpdy[me.z]));

    // Blend factors
    float2 w = float2(n[ma.x], n[me.x]);

    // Make local support
    w = saturate((w - 0.5773) / (1 - 0.5773));

    // Blending
    output = (x * w.x + y * w.y) / (w.x + w.y);
}

// Biplanar mapping for normal maps
void BiplanarNormal_float
  (Texture2D tex, SamplerState samp,
   float3 wpos, float3 wtan, float3 wbtn, float3 wnrm, out float3 output)
{
    // Coordinate derivatives for texturing
    float3 p = wpos;
    float3 n = abs(wnrm);
    float3 dpdx = ddx(p);
    float3 dpdy = ddy(p);

    // Major axis (in x; yz are following axis)
    uint3 ma = (n.x > n.y && n.x > n.z) ? uint3(0, 1, 2) :
               (n.y > n.z             ) ? uint3(1, 2, 0) :
                                          uint3(2, 0, 1) ;

    // Minor axis (in x; yz are following axis)
    uint3 mi = (n.x < n.y && n.x < n.z) ? uint3(0, 1, 2) :
               (n.y < n.z             ) ? uint3(1, 2, 0) :
                                          uint3(2, 0, 1) ;

    // Median axis (in x; yz are following axis)
    uint3 me = 3 - mi - ma;

    // Project + fetch
    float4 x = SAMPLE_TEXTURE2D_GRAD(tex, samp,
                                     float2(   p[ma.y],    p[ma.z]), 
                                     float2(dpdx[ma.y], dpdx[ma.z]), 
                                     float2(dpdy[ma.y], dpdy[ma.z]));

    float4 y = SAMPLE_TEXTURE2D_GRAD(tex, samp,
                                     float2(   p[me.y],    p[me.z]), 
                                     float2(dpdx[me.y], dpdx[me.z]),
                                     float2(dpdy[me.y], dpdy[me.z]));

    // Normal vector extraction
    float3 n1 = UnpackNormalmapRGorAG(x);
    float3 n2 = UnpackNormalmapRGorAG(y);

    // Do UDN-style normal blending in the tangent space then bring the result
    // back to the world space. To make the space conversion simpler, we use
    // reverse-order swizzling, which brings us back to the original space by
    // applying twice.
    n1 = normalize(float3(n1.y + wnrm[ma.z], n1.x + wnrm[ma.y], wnrm[ma.x]));
    n2 = normalize(float3(n2.y + wnrm[me.z], n2.x + wnrm[me.y], wnrm[me.x]));
    n1 = float3(n1[ma.z], n1[ma.y], n1[ma.x]);
    n2 = float3(n2[me.z], n2[me.y], n2[me.x]);

    // Blend factors
    float2 w = float2(n[ma.x], n[me.x]);

    // Make local support
    w = saturate((w - 0.5773) / (1 - 0.5773));

    // Blending
    output = normalize((n1 * w.x + n2 * w.y) / (w.x + w.y));

    // Back to the tangent space
    output = TransformWorldToTangent(output, float3x3(wtan, wbtn, wnrm));
}
