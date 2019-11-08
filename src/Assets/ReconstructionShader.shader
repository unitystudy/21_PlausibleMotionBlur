Shader "Custom/Reconstruction" 
{
	Properties{
		_Scale("scale", Range(0.0, 10.0)) = 1.0
		_MainTex("MainTex", 2D) = ""{}
		_VelocityMap("Velocity Map", 2D) = ""{}
		_TileMaxMap("TileMax Map", 2D) = ""{}
		_NeighborMaxMap("NeighborMax Map", 2D) = ""{}
	}

	SubShader{
		Pass {
			CGPROGRAM

			#include "UnityCG.cginc"

			#pragma vertex vert_img
			#pragma fragment frag

			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			sampler2D _VelocityMap;
			sampler2D _TileMaxMap;
			sampler2D _NeighborMaxMap;
			float4 _MainTex_TexelSize;
			float _Scale;

			// -0.5～+0.5の乱数
			float random(float2 st) {
				return -.5 + frac(sin(dot(st, fixed2(12.9898, 78.233))) * 43758.5453);
			}

			float LinearizeDepth(float depth, float near, float far)
			{
				return (2.0 * near) / (far + near - (1.0-depth) * (far - near));
			}

			float cone(float XY, float lv)
			{
				return clamp(1-XY/lv, 0, 1);
			}

			float cylinder(float XY, float lv)
			{
				return 1.0 - smoothstep(0.95 * lv, 1.05 * lv, XY);
			}

			float softDepthCompare(float za, float zb)
			{
				const float SOFT_Z_EXTENT = 0.1;
				return clamp(1 - (za - zb) / SOFT_Z_EXTENT, 0, 1);
			}

			fixed4 frag(v2f_img input) : COLOR
			{
				float2 X = input.uv;
				fixed4 col = tex2D(_MainTex, X);
				half2 v_n = tex2D(_NeighborMaxMap, X);

				#define S 15
				const float near = 0.3;
				const float far = 100.0;

				float len2 = dot(v_n, v_n);

				if (len2 < 0.5 * 0.5) return col;

				half2 v = tex2D(_VelocityMap, X);
				float lx = length(v);
				float weight = 1.0 / (length(v)+0.0001);
				float4 sum = col * weight;

				float j = random(X);
				for (int i = 0; i < S; i++) {
					if (i * 2 == S - 1) continue;
					float t = 2.0 * ((i + j + 1.0)/(S+1.0)) - 1.0;
					float2 Y = X + v_n * _MainTex_TexelSize.xy * t * _Scale;

					float ZX = LinearizeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, X)), near, far);
					float ZY = LinearizeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, Y)), near, far);
					float f = softDepthCompare(ZX, ZY);
					float b = softDepthCompare(ZY, ZX);

					half2 vy = tex2D(_VelocityMap, Y);
					float ly = length(vy);

					float d = length(X - Y);

					float a = 
						f * cone(d, ly) +
						b * cone(d, lx) +
						cylinder(d, ly) * cylinder(d, lx) * 2.0;
					weight += a;
					sum += a * tex2D(_MainTex, Y);
				}

				return sum / weight;
			}

			ENDCG
		}
	}
}