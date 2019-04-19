//Created by Quindo
texture cubeSharp;
texture cubeBlurry;
texture gTexture;

//---------------------------------------------------------------------
// Variables
//---------------------------------------------------------------------
float3 sLightDir = float3(-0.18,-0.18,1);
float roughness = float(0.92);
float fresnelTerm = float(0.08);
float brightnessFactorMin = float(0.25);
float brightnessFactorMax = float(0.45);
//------------------------------------------------------------------------------------------
// Samplers for the textures
//------------------------------------------------------------------------------------------

sampler Sampler0 = sampler_state
{
    Texture         = (gTexture);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Anisotropic;
};

sampler cubeSamplerSharp = sampler_state
{
    Texture         = (cubeSharp);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Anisotropic;
};

sampler cubeSamplerBlurry = sampler_state
{
    Texture         = (cubeBlurry);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Anisotropic;
};

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
float3 gCameraPosition : CAMERAPOSITION;
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 gWorld : WORLD;
float3 MTACalcWorldNormal( float3 InNormal )
{
    return mul(InNormal, (float3x3)gWorld);
}

int gDiffuseMaterialSource         < string renderState="DIFFUSEMATERIALSOURCE"; >;           //  = 145,
int gAmbientMaterialSource         < string renderState="AMBIENTMATERIALSOURCE"; >;           //  = 147,
int gEmissiveMaterialSource        < string renderState="EMISSIVEMATERIALSOURCE"; >;          //  = 148,

float4 gMaterialAmbient     < string materialState="Ambient"; >;
float4 gMaterialDiffuse     < string materialState="Diffuse"; >;
float4 gMaterialEmissive    < string materialState="Emissive"; >;

float4 gGlobalAmbient              < string renderState="AMBIENT"; >;                    //  = 139,
float4 gLightAmbient : LIGHTAMBIENT;
float3 gLightDirection : LIGHTDIRECTION;
float4 gLightDiffuse : LIGHTDIFFUSE;

float4 MTACalcGTAVehicleDiffuse( float3 WorldNormal, float4 InDiffuse )
{
    // Calculate diffuse color by doing what D3D usually does
    float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
    float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
    float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;

    float4 TotalAmbient = ambient * ( gGlobalAmbient + gLightAmbient );

    // Add the strongest light
    float DirectionFactor = max(0,dot(WorldNormal, -gLightDirection ));
    float4 TotalDiffuse = ( diffuse * gLightDiffuse * DirectionFactor );

    float4 OutDiffuse = saturate(TotalDiffuse + TotalAmbient + emissive);
    OutDiffuse.a *= diffuse.a;

    return OutDiffuse;
}

float3 MTACalcWorldPosition( float3 InPosition )
{
    return mul(float4(InPosition,1), gWorld).xyz;
}

// lerp between sharp and blurry reflection
float4 calcReflection(float3 R, float val)
{
	float4 reflectionSharp = texCUBE(cubeSamplerSharp,R.xzy);
	float4 reflectionBlurry = texCUBE(cubeSamplerBlurry,R.xzy);
	float4 reflection = lerp(reflectionSharp,reflectionBlurry,val);
	return reflection;
}

// Specular lighting
// AUTHOR: John Hable
float G1V(float dotNV, float k)
{
	return 1.0f/(dotNV*(1.0f-k)+k);
}

float LightingFuncGGX_OPT1(float3 N, float3 V, float3 L, float roughness, float F0)
{
	float alpha = roughness*roughness;

	float3 H = normalize(V+L);

	float dotNL = saturate(dot(N,L));
	float dotLH = saturate(dot(L,H));
	float dotNH = saturate(dot(N,H));

	float F, D, vis;

	// D
	float alphaSqr = alpha*alpha;
	float pi = 3.14159f;
	float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;
	D = alphaSqr/(pi * denom * denom);

	// F
	float dotLH5 = pow(1.0f-dotLH,5);
	F = F0 + (1.0-F0)*(dotLH5);

	// V
	float k = alpha/2.0f;
	vis = G1V(dotLH,k)*G1V(dotLH,k);

	float specular = dotNL * D * F * vis;
	return specular;
}

// Dynamic reflection intensity
// AUTHOR: BartekPL I guess
float calcIntensity(float4 tex, float FactorMin, float FactorMax)
{
	float higherc = max( tex.r, max(tex.g, tex.b) );
	float reflectionIntensityRange = FactorMax - FactorMin;
	float reflectionIntensity = FactorMax - higherc * reflectionIntensityRange;
	return reflectionIntensity;
}


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
	float3 Position : POSITION0;
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
	float4 Position : POSITION0;
	float3 Normal : TEXCOORD0;
	float4 Diffuse : TEXCOORD1;
	float3 WorldPos : TEXCOORD2;
	float2 TexCoord : TEXCOORD3;
};

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

	 // Transform postion
    PS.Position = mul(float4(VS.Position,1), gWorldViewProjection);
	PS.Normal = MTACalcWorldNormal(VS.Normal);
	PS.Diffuse = MTACalcGTAVehicleDiffuse( PS.Normal, VS.Diffuse );
	PS.WorldPos = MTACalcWorldPosition( VS.Position );
	PS.TexCoord = VS.TexCoord;

	return PS;

}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
//Base Calculations
	float3 N = normalize(PS.Normal); //Normalized Normal
	float3 V = normalize(gCameraPosition - PS.WorldPos); //View Vector
	float3 R = reflect(-V,N); //Reflection Vector

//Calculating specular
	float specular = LightingFuncGGX_OPT1(N,V,sLightDir,roughness,fresnelTerm);

//Texture Sampling
	float4 tex = tex2D(Sampler0, PS.TexCoord);
	float4 reflection = calcReflection(R,1);

//Dynamic reflection intensity
	float reflectionIntensity = calcIntensity(tex,0.25,0.45);

//Combining reflection with specular
	reflection.rgb = pow(reflection.rgb,3);
	reflection.rgb = reflection.rgb * reflectionIntensity;
	reflection += specular;

//Mixing base color
	float4 Color = 1;
    Color = reflection / 1 + PS.Diffuse * 1.0;
	Color *= tex;
    Color += reflection * PS.Diffuse * 1;
    Color.a = PS.Diffuse.a;

return float4(Color);

}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique carpaint
{
    pass P0
    {
		Texture[0] = gTexture;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_a PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        Texture[0] = gTexture;
    }
}
