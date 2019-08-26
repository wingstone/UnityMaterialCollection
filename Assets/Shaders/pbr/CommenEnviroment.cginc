#ifndef _COMMEN_ENVIROMENT_
#define _COMMEN_ENVIROMENT_

#include "CommenSurface.cginc"

half3 GetAmbientColor(half3 normal,
	half3 wPos, half4 ambientOrLightmapUV, inout half atten, inout half3 lightCol)
{
	//indirect light
	half3 ambient = 0;
	half2 lightmapUV = 0;
#if defined(LIGHTMAP_ON)
	ambient = 0;
	lightmapUV = ambientOrLightmapUV.xy;
#else
	ambient = ambientOrLightmapUV.rgb;
	lightmapUV = 0;
#endif

	// handling ShadowMask / blending here for performance reason
#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
	half bakedAtten = UnitySampleBakedOcclusion(lightmapUV.xy, i.worldPos);
	float zDist = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
	float fadeDist = UnityComputeShadowFadeDistance(i.worldPos, zDist);
	atten = UnityMixRealtimeAndBakedShadows(atten, bakedAtten, UnityComputeShadowFade(fadeDist));
#endif

#if UNITY_SHOULD_SAMPLE_SH
	ambient = ShadeSHPerPixel(normal, ambient, wPos);
#endif

#if defined(LIGHTMAP_ON)
	// Baked lightmaps
	half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, lightmapUV.xy);
	half3 bakedColor = DecodeLightmap(bakedColorTex);

#ifdef DIRLIGHTMAP_COMBINED
	fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lightmapUV.xy);
	ambient += DecodeDirectionalLightmap(bakedColor, bakedDirTex, normalWorld);

#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
	lightCol = 0;
	ambient = SubtractMainLightWithRealtimeAttenuationFromLightmap(ambient, atten, bakedColorTex, surfaceOtherData.normal);
#endif

#else // not directional lightmap
	ambient += bakedColor;
#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
	lightCol = 0;
	ambient = SubtractMainLightWithRealtimeAttenuationFromLightmap(ambient, atten, bakedColorTex, surfaceOtherData.normal);
#endif

#endif

#endif

#ifdef UNITY_COLORSPACE_GAMMA
	ambient = GammaToLinearSpace(ambient);
#endif

	return ambient;
}

half3 GetIBLColor(SurfaceTexData surfaceTexData, SurfaceOtherData surfaceOtherData)
{
	half3 IBLColor;
#ifdef _GLOSSYREFLECTIONS_OFF
	IBLColor = unity_IndirectSpecColor.rgb;

#else
	half mip = surfaceTexData.roughness * (1.7 - 0.7*surfaceTexData.roughness)*UNITY_SPECCUBE_LOD_STEPS;
	half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, surfaceOtherData.reflectDir, mip);
	IBLColor = DecodeHDR(rgbm, unity_SpecCube0_HDR)*surfaceTexData.occlusion;
#endif

	//�Ѿ���֤����ȡ��IBLColorȷʵ��Gamma�ռ�ģ����ʹ��gamma�ռ�Ļ�
	//ע�����ʹ���Զ����skybox����Ҫ�ֶ����skybox�Ƿ���gamma�ռ�
	//gamma�ռ��skybox��ʾ����ɫ���ǣ�������ȷ������������ɫ

	//����и����⣬���ʹ�����Կռ��box���ͱ���ʹ�����Կռ����̣�
	//��ʹ��gamma�ռ����̾�ֻ�ܸĴ��벻���������ת���ˣ��������Ͳ���ʹ��gamm�ռ��box�ˣ�����˵���ʹ��gamma�ռ��box

#ifdef UNITY_COLORSPACE_GAMMA
	return GammaToLinearSpace(IBLColor)*surfaceTexData.occlusion;
#else
	return IBLColor * surfaceTexData.occlusion;
#endif
}


#endif