﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/LiftMachineCover"
{
	Properties
	{
		_DiffuseTint("Diffuse Tint", Color) = (1, 1, 1, 1)
	}

		SubShader
	{
		Tags{ "RenderType" = "Opaque" }

		GrabPass
	{
		Name "BASE"
		"_ReflectTexture"
	}
		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM

#pragma target 3.0
#pragma fragmentoption ARB_precision_hint_fastest

#pragma vertex vertShadow
#pragma fragment fragShadow
#pragma multi_compile_fwdbase

#include "UnityCG.cginc"
#include "AutoLight.cginc"

		float4 _DiffuseTint;
	sampler2D _ReflectTexture;
	float4 _ReflectTexture_TexelSize;

	struct v2f
	{
		float4 pos : SV_POSITION;
		float3 lightDir : TEXCOORD0;
		float3 normal : TEXCOORD1;
		float4 uvgrab : TEXCOORD2;
		LIGHTING_COORDS(3, 4)
	};

	v2f vertShadow(appdata_base v)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(v.vertex);
		o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
		o.normal = normalize(v.normal).xyz;

		TRANSFER_VERTEX_TO_FRAGMENT(o);

#if UNITY_UV_STARTS_AT_TOP
		float scale = -1.0;
#else
		float scale = 1.0;
#endif	
		o.uvgrab.xy = (float2(o.pos.x, o.pos.y*scale) + o.pos.w) * 0.5;
		o.uvgrab.zw = o.pos.zw;

		return o;
	}

	float4 fragShadow(v2f i) : COLOR
	{
		float3 L = normalize(i.lightDir);
		float3 N = normalize(i.normal);

		float attenuation = LIGHT_ATTENUATION(i);
		float4 ambient = UNITY_LIGHTMODEL_AMBIENT;

		float NdotL = saturate(dot(N, L));
		float4 diffuseTerm = NdotL * _DiffuseTint * attenuation;

		half4 col = tex2Dproj(_ReflectTexture, UNITY_PROJ_COORD(i.uvgrab));

		float4 finalColor = (attenuation) * col + (1- attenuation) * (ambient * 0.5 + col *0.5);
		//float4 finalColor = (ambient + diffuseTerm) * col;

		return finalColor;
	}

		ENDCG
	}

	}
		FallBack "Diffuse"
}