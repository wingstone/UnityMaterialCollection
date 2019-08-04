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

fixed4 Optimizedfrag(v2f i, half vFace : FACE) : SV_Target
{
	// sample the texture
	float3 color = 0;
	SurfaceTexData surfaceTexData = GetSurfaceTexData(i.uv);

	SurfaceOtherData surfaceOtherData = GetSurfaceOtherData(i, surfaceTexData.texNormal, vFace);

	//shadow
	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
	surfaceOtherData.lightCol *= atten * UNITY_PI;

	//surface data
	float LDotN = saturate(dot(surfaceOtherData.lightDir, surfaceOtherData.normal));
	float VDotN = saturate(dot(surfaceOtherData.viewDir, surfaceOtherData.normal));
	float VDotH = saturate(dot(surfaceOtherData.viewDir, surfaceOtherData.halfDir));
	float NDotH = saturate(dot(surfaceOtherData.normal, surfaceOtherData.halfDir));


	//indirect light
#if UNITY_SHOULD_SAMPLE_SH
	color += ShadeSHPerPixel(surfaceOtherData.normal, i.vLight, i.worldPos)* surfaceTexData.diffColor* surfaceTexData.occlusion * _EnviromentIntensity;
#endif

	//diffuse data
	float3 diffuseBRDF = DesineyDiffuseBRDF(surfaceTexData.diffColor, surfaceTexData.roughness, VDotH, LDotN, VDotN);
	color += LDotN * surfaceOtherData.lightCol*diffuseBRDF;

	//Specular data
	float3 SpecularBRDF = OptimizedSpecularBRDF(surfaceTexData.specularColor, surfaceTexData.roughness, NDotH, VDotH, LDotN, VDotN);
	color += LDotN * surfaceOtherData.lightCol*SpecularBRDF*_SpecularFactor;

	//IBL reflection
	half3 IBLColor = GetIBLColor(surfaceTexData, surfaceOtherData);
	float3 enviromentBRDF = OptimizedEnviromentBRDF(surfaceTexData.specularColor, surfaceTexData.roughness, VDotN);
	color += IBLColor * enviromentBRDF* _EnviromentSpecularIntensity;

	color += surfaceTexData.emission;

	#ifdef UNITY_COLORSPACE_GAMMA
	color = LinearToGammaSpace(color);
	#endif
	return fixed4(color, 1);
}

#endif