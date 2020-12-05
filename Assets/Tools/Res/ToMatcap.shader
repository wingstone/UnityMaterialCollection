﻿Shader "Unlit/ToMatcap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cubemap ("Texture", Cube) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "To Matcap"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * 2.0 - 1.0;
                float3 N = normalize(float3(uv, sqrt(1-dot(uv, uv))));

                float4 color = 1;
                float3 V = float3(0,0,-1);
                float3 R = reflect(V, N);
                color.rgb = texCUBE(_Cubemap, R);

                color.rgb *= step(dot(uv, uv), 1);

                return color;
            }
            ENDCG
        }

        Pass
        {
            Name "To Cylindrical"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float theta = (i.uv.y-0.5)*UNITY_PI;
                float phi = i.uv.x*UNITY_TWO_PI;

                float4 color = 1;
                float3 R = float3(cos(phi)*cos(theta), sin(theta), sin(phi)*cos(theta));
                color.rgb = texCUBE(_Cubemap, R);

                return color;
            }
            ENDCG
        }

        Pass
        {
            Name "To CrossLayout"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv*2.0 - 1.0;
                float theta = length(uv)*UNITY_PI - UNITY_HALF_PI;
                float phi = atan2(uv.x, uv.y);

                float4 color = 1;
                float3 R = float3(cos(phi)*cos(theta), sin(theta), sin(phi)*cos(theta));
                color.rgb = texCUBE(_Cubemap, R);

                color.rgb *= step(dot(uv, uv), 1);
                return color;
            }
            ENDCG
        }
    }
}