Shader "Custom/NeighborMaxShader"
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
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"

			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			half2 frag(v2f_customrendertexture i) : SV_Target
			{
				// 1ピクセル分周辺から最大の大きさを持つものを算出する
				half2 v_max = 0;
				float l2_max = 0;
				for (int x = -1; x <= +1; x++) {
					float2 uv = i.globalTexcoord + float2(x * _MainTex_TexelSize.x, -_MainTex_TexelSize.y);
					for (int y = -1; y <= +1; y++) {
						half2 v = tex2D(_MainTex, uv);
						float l2 = dot(v, v);
						if (l2_max < l2) {
							v_max = v;
							l2_max = l2;
						}
						uv.y += _MainTex_TexelSize.y;
					}
				}

				return v_max;
			}

			ENDCG
		}
	}
}
