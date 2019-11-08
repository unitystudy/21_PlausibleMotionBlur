Shader "Custom/TileMaxMapShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

		Pass
		{
			name "X axis"

			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"

			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag

			#define k  40
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			half2 frag(v2f_customrendertexture i) : SV_Target
			{
				float2 uv = i.globalTexcoord;
				uv.x -= _MainTex_TexelSize.x * k * 0.5;

				half2 v_max = 0;
				float l2_max = 0;
				for (int i = 0; i < k; i++) {
					half2 v = tex2D(_MainTex, uv);
					float l2 = dot(v, v);
					if (l2_max < l2) {
						v_max = v;
						l2_max = l2;
					}
					uv.x += _MainTex_TexelSize.x;
				}

				return v_max;
			}

			ENDCG
		}

		Pass
		{
			name "Y axis"

			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"

			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag

			#define k 40
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			half2 frag(v2f_customrendertexture i) : SV_Target
			{
				float2 uv = i.globalTexcoord;
				uv.y -= _MainTex_TexelSize.y * k * 0.5;

				float2 v_max = 0;
				float l2_max = 0;
				for (int i = 0; i < k; i++) {
					float2 v = tex2D(_MainTex, uv);
					float l2 = dot(v, v);
					if (l2_max < l2) {
						v_max = v;
						l2_max = l2;
					}
					uv.y += _MainTex_TexelSize.y;
				}

				return v_max;
			}

			ENDCG
		}
	}
}
