#ifndef ZELDA_TEST
#define ZELDA_TEST

#include "UnityCG.cginc"		//���ú������꣬�ṹ��
#include "Lighting.cginc"		//��Դ��ر���
#include "AutoLight.cginc"		//���գ���Ӱ��غ꣬����

#include "CommenVertex.cginc"

sampler2D _DiffuseAoTex;
float4 _DiffuseTint;
float _DiffuseSmooth;
sampler2D _SpecularGlossnessTex;
float _SpecularSmooth;
sampler2D _EmissionTex;
float4 _Ambient;	//����Ԫ��Ҫ�ļ򵥻�����ģ��
float4 _Rim;
float _RimPos;
float _RimOffsetDiff;

//������+����3��
fixed4 frag(v2f i, half vFace : FACE) : SV_Target
{
	//vector
	float3 N = normalize(i.normal);
	float3 T = normalize(i.tangent);
	float3 B = normalize(i.binormal);
	float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
	float3 L = normalize(_WorldSpaceLightPos0.xyz);
	float3 H = normalize(L + V);

	//color,����Ԫ����Ҫ����,Alpha������Ԫ��ҪSpecular  �Լ�AO,��Щ����Ҫ�ǿ�ͨ�������ɫ��
#ifdef UNITY_COLORSPACE_GAMMA
	float3 lightCol = GammaToLinearSpace(_LightColor0.rgb);		//��Դ��ɫΪgamma�ռ�
	float4 val = 0;

	float3 diffTint = GammaToLinearSpace(_DiffuseTint.rgb);
	val = tex2D(_DiffuseAoTex, i.uv);
	float3 diffColor = GammaToLinearSpace(val.rgb) * diffTint;
	float ao = val.a;

	val = tex2D(_SpecularGlossnessTex, i.uv);
	float3 specColor = GammaToLinearSpace(val.rgb);
	float smoothness = val.a;

	val = tex2D(_EmissionTex, i.uv);
	float3 emission = GammaToLinearSpace(val.rgb);

	float3 ambient = GammaToLinearSpace(_Ambient.rgb);
	float3 rim = GammaToLinearSpace(_Rim.rgb);
#else
	float3 lightCol = _LightColor0.rgb;
	float4 val = 0;

	float3 diffTint = _DiffuseTint.rgb;
	val = tex2D(_DiffuseAoTex, i.uv);
	float3 diffColor = val.rgb * diffuseTint;
	float ao = val.a;

	val = tex2D(_SpecularGlossnessTex, i.uv);
	float3 specColor = val.rgb;
	float smoothness = val.a;

	val = tex2D(_EmissionTex, i.uv);
	float3 emission = val.rgb;

	float3 ambient = _Ambient.rgb;
	float3 rim = _Rim.rgb;
#endif

	//����Ԫ��ɫ����Ҫ��Ӱ����Ϊ��Ӱ����������Ԫ�����Ҿ����������У����������������Ӱ��==
	//���ˣ����Ǽ�����Ӱ��==
	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

	//����Ԫ����Ҫ���Ӽ�ӹ⣬�Լ���������
	fixed3 color = ambient * diffColor;

	//diffuse data	//�ɽ�AO��diffͬʱ���������������䴦����ɫ���Ӷ����Ӷ���Ԫ�����
	float diffFactor = smoothstep(0.5 - _DiffuseSmooth, 0.5 + _DiffuseSmooth, (dot(L, N)*0.5 + 0.5)*ao*atten);
	color += diffFactor * diffColor * lightCol;

	//specular��ɫ����̫��ҪҪ��һ������ɫ�͹���
	float specFactor1 = smoothstep(0.4 - _SpecularSmooth, 0.4 + _SpecularSmooth, pow(dot(N, H), smoothness * 100));
	float specFactor2 = smoothstep(0.6 - _SpecularSmooth, 0.6 + _SpecularSmooth, pow(dot(N, H), smoothness * 100));
	float specFactor = (specFactor1 + specFactor2) * 0.5;
	color += specFactor * diffColor * lightCol;

	//����Ԫ��Ե��
	float rimFactor = diffFactor + 1.0 - smoothstep(0.5 - _DiffuseSmooth - _RimOffsetDiff, 0.5 - _DiffuseSmooth, (dot(L, N)*0.5 + 0.5)*ao);	//���������
	rimFactor *= smoothstep(_RimPos - 0.01, _RimPos, 1.0 - dot(V, N));	//��Ե��
	color += rimFactor * diffColor * rim;

	//����Ԫ��Ҫ�Է���
	color += emission;

	#ifdef UNITY_COLORSPACE_GAMMA
	color = LinearToGammaSpace(color);
	#endif

	return fixed4(color, 1);
}


#endif