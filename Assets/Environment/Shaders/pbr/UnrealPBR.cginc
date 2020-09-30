#ifndef _COMMENPBR_
#define _COMMENPBR_

#include "UnityCG.cginc"		//���ú������꣬�ṹ��
#include "Lighting.cginc"		//��Դ��ر���
#include "AutoLight.cginc"		//���գ���Ӱ��غ꣬����

#include "BRDF.cginc"
#include "CommenVertex.cginc"
#include "CommenSurface.cginc"
#include "CommenEnviroment.cginc"

float _SpecularFactor;
float _EnviromentIntensity;
float _EnviromentSpecularIntensity;

fixed4 Unrealfrag(v2f i, half vFace : FACE) : SV_Target
{
	// sample the texture
	float3 color = 0;
	SurfaceTexData surfaceTexData = GetSurfaceTexData(i.uv);

	SurfaceOtherData surfaceOtherData = GetSurfaceOtherData(i, surfaceTexData.texNormal, vFace);

	//shadow light
	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
	surfaceOtherData.lightCol *= UNITY_PI;

	//surface data
	float LDotN = saturate(dot(surfaceOtherData.lightDir, surfaceOtherData.normal));
	float VDotN = saturate(dot(surfaceOtherData.viewDir, surfaceOtherData.normal));
	float VDotH = saturate(dot(surfaceOtherData.viewDir, surfaceOtherData.halfDir));
	float NDotH = saturate(dot(surfaceOtherData.normal, surfaceOtherData.halfDir));


	//indirect light
	half3 ambient = GetAmbientColor(surfaceOtherData.normal,
		i.worldPos, i.ambientOrLightmapUV, atten, surfaceOtherData.lightCol);
	color += ambient * surfaceTexData.diffColor * surfaceTexData.occlusion * _EnviromentIntensity;

	//shadow light
	surfaceOtherData.lightCol *= atten;

	//diffuse data
	float3 diffuseBRDF = UnrealDiffuseBRDF(surfaceTexData.diffColor);
	color += LDotN * surfaceOtherData.lightCol*diffuseBRDF;

	//Specular data
	float3 SpecularBRDF = UnrealSpecularBRDF(surfaceTexData.specularColor, surfaceTexData.roughness, NDotH, VDotH, LDotN, VDotN);
	color += LDotN * surfaceOtherData.lightCol*SpecularBRDF;

	//IBL reflection
	half3 IBLColor = GetIBLColor(surfaceTexData, surfaceOtherData);
#ifdef ENABLE_PREINTEGRATED
	float3 enviromentBRDF = UnrealEnviromentBRDF(surfaceTexData.specularColor, surfaceTexData.roughness, VDotN);
#else
	float3 enviromentBRDF = UnrealEnviromentBRDFApprox(surfaceTexData.specularColor, surfaceTexData.roughness, VDotN);
#endif
	color += IBLColor * enviromentBRDF* _EnviromentIntensity;

	color += surfaceTexData.emission;

	#ifdef UNITY_COLORSPACE_GAMMA
	color = LinearToGammaSpace(color);
	#endif
	return fixed4(color, 1);
}


#endif