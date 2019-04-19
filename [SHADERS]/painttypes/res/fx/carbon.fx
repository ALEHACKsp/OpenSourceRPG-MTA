texture gTexture;
int gMMultipler;

sampler Sampler0 = sampler_state
{
    Texture = (gTexture);
};

struct PSInput
{
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
	float4 texel = tex2D(Sampler0, PS.TexCoord*gMMultipler);
    float4 finalColor = texel * PS.Diffuse;;
    return finalColor;
}

technique TexReplace
{
	pass P0
	{
		// PixelShader  = compile ps_2_0 PixelShaderFunction();
		Texture[0] = gTexture;
	}
}