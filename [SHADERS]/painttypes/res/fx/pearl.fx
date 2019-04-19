//Created by Quindo
texture cubeSharp;
texture cubeBlurry;
texture gTexture;

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

// Dynamic reflection intensity
// AUTHOR: BartekPL I guess
float calcIntensity(float4 tex, float FactorMin, float FactorMax)
{
	float higherc = max( tex.r, max(tex.g, tex.b) );
	float reflectionIntensityRange = FactorMax - FactorMin;
	float reflectionIntensity = FactorMax - higherc * reflectionIntensityRange;
	return reflectionIntensity;
}

// Iridescence calculations
// AUTHOR: Diego Inácio
float setRange(float value, float oMin, float oMax, float iMin, float iMax){
	return iMin + ((value - oMin)/(oMax - oMin)) * (iMax - iMin);
}

float diNoise(float3 pos){
	//noise function to create irregularity
	float mult = 0.1;
	float oset = 0.3;		//offset
	return	sin(pos.x*mult*2 + 12 + oset) + cos(pos.z*mult + 21 + oset) *
		sin(pos.y*mult*2 + 23 + oset) + cos(pos.y*mult + 32 + oset) *
		sin(pos.z*mult*2 + 34 + oset) + cos(pos.x*mult + 43 + oset);
}

float3 iridescence(float orient, float3 P){
	//this function returns a iridescence value based on orientation
	float3 irid;
	float freq = 10;
	float oset = 2;		//offset
	float noiseMult = 0.6;
	irid.x = abs(cos(orient*freq + diNoise(P)*noiseMult + 1 + oset));
	irid.y = abs(cos(orient*freq + diNoise(P)*noiseMult + 2 + oset));
	irid.z = abs(cos(orient*freq + diNoise(P)*noiseMult + 3 + oset));
	return irid;
}

// lerp between sharp and blurry reflection
float4 calcReflection(float3 R, float val)
{
	float4 reflectionSharp = texCUBE(cubeSamplerSharp,R.xzy);
	float4 reflectionBlurry = texCUBE(cubeSamplerBlurry,R.xzy);
	float4 reflection = lerp(reflectionSharp,reflectionBlurry,val);
	return reflection;
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
	float3 PosIrid : TEXCOORD4;
};

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

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
	PS.PosIrid = PS.Position;

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
	float3 R = reflect(V,N); //Reflection Vector
	float fr = dot(N, V); //Fresnel

//Texture Sampling
	float4 tex = tex2D(Sampler0, PS.TexCoord);
	float3 reflection = calcReflection(R,0.92);

//Dynamic intensity, used for reflection instead of iridance cause better effect. Stolen from server obviously
	float pearlescentIntensity = calcIntensity(tex,0.25,0.45);

//Calculating iridiance color.
	float4 iridColor = float4(iridescence(fr, (PS.PosIrid.rgb + 1)/2),1.0)*setRange(pow(abs(1-fr), 1/0.75), 0, 1, 1, 1);
	iridColor.rgb = iridColor.rgb *  pow(fr,6);

//Mixing iridiance with smooth reflection.
	float4 finalColor = float4(iridColor.rgb+ pow(reflection.rgb,4)*pearlescentIntensity,1);

//Mixing in base texture using server method.
	float4 Color = 1;
    Color = finalColor / 1 + PS.Diffuse * 1.0;
	Color *= tex;
    Color += finalColor * PS.Diffuse * 1;
    Color.a = PS.Diffuse.a;

	return Color;
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
        // Just draw normally
    }
}
