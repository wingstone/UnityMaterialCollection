#ifndef _COMMEN_ENVIROMENT_
#define _COMMEN_ENVIROMENT_

#include "CommenSurface.cginc"

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