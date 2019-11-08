Shader "Custom/VelocityMapShader"
{
	Properties
	{
		_X("X", Range(0, 1.0)) = 0.5
		_Y("Y", Range(0, 1.0)) = 0.5
		_time("time", Range(0, 1.0)) = 0.0
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

			float _X;
			float _Y;
			float _time;

			// ノイズの生成
			fixed2 random2(float2 st) {
				st = float2(dot(st, fixed2(127.1, 311.7)), dot(st, fixed2(269.5, 183.3)));
				return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
			}

			float Noise(float2 st)
			{
				float2 p = floor(st);
				float2 f = frac(st);
				float2 u = f * f * (3.0 - 2.0 * f);

				float2 v00 = random2(p + fixed2(0, 0));
				float2 v10 = random2(p + fixed2(1, 0));
				float2 v01 = random2(p + fixed2(0, 1));
				float2 v11 = random2(p + fixed2(1, 1));

				return lerp(
					lerp(dot(random2(p + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
						 dot(random2(p + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
					lerp(dot(random2(p + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
						 dot(random2(p + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
			}

			float Fbm(float2 tc)
			{
				float noise
					= Noise(tc * 1.0)
					+ Noise(tc * 2.0) * 0.5
					+ Noise(tc * 4.0) * 0.25;
				noise = noise / (1.0 + 0.5 + 0.25); // 正規化

				return noise;
			}

			half2 frag(v2f_customrendertexture i) : SV_Target
			{
				float2 uv = i.globalTexcoord;
				float2 shoot_pos = float2(_X, _Y);

				float2 d = (uv - shoot_pos) * float2(1920, 1080);
				float l = length(d);

				float noise = Fbm(float2(30.0 * atan2(d.x, d.y) / (2.0 * 3.1415926535), 0.0));

				float t = _time * 3000.0 - l - noise * 1000.0;

				if (t < 0.0) return half2(0.0, 0.0);// 届いていないところは変化なし

				float p = 300.0 * exp(-t * 0.003) * pow(0.001 * t, 2.0);
				float2 v = normalize(d) * p;

				float k = 40.0;
				float lv = length(v);
				return v * max(0.5, min(lv, k)) / (lv + 0.00001);
			}


			ENDCG
		}
	}
}
