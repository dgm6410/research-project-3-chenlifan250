Shader "Shader/BurningShader"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        // Normal Map
        _BumpMap ("Bump Map", 2D) = "bump" {}
        // Noise Map (Perlin Noise)
        _BurnMap ("Burn Map", 2D) = "white" {}
        // Threshold
        _BurnAmount ("Burn Amount", Range(0, 1)) = 0
        // The width of the edge
        _LineWidth ("Burn Line Width", Range(0.0, 0.2)) = 0.1
        // The color of the fire
        _BurnColor ("Burn Color", Color) = (1, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            
            // Keep both front and back surface, because when the object burning, the inside of the object should also be seen 
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // this compile line means to get the correct light setting
            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            sampler2D _BumpMap;
            sampler2D _BurnMap;
            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            float4 _BurnMap_ST;
            fixed _BurnAmount;
            fixed _LineWidth;
            fixed4 _BurnColor;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                fixed4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvMainTex : TEXCOORD0;
                float2 uvBumpMap : TEXCOORD1;
                float2 uvBurnMap : TEXCOORD2;
                // Direction of the light
                float3 lightDir : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                // Shader macro：The coord of shadow sampling
                // 5 means world position (worldPos)
                SHADOW_COORDS(5)
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.worldPos = UnityObjectToWorldDir(v.vertex);

                // Shader macro：calculate the shadow coord in vertex shader
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sampling noise map 
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap);
                // cut off the point which (value on noise map - threshold > 0) 
                clip(burn.r - _BurnAmount);

                fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentLightDir, tangentNormal));

                // Shader macro：calculate the shadow，and add with diffuse
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                // smoothsetp(e1,e2,x)平滑过度函数
                // if (x < e1) return = 0
                // if (x > e2) return = 1
                // if (e1 < x < e2) return = 3 * pow(x, 2) - 2 * pow(x, 3)
                // t = 0时，this point is the color of the original model
				// t = 1时，this point is on the edge
                fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);

                // Final color
                fixed3 finalColor = lerp(ambient + diffuse * atten, _BurnColor, t);

                return fixed4(finalColor, 1);
            }
            ENDCG
        }

        // This pass is for shadow. When the object is buring, the shadow of the object should be broke accordingly.
        Pass
        {
            // Set the lighting mode as shadow caster
            Tags { "LightMode"="ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // this compile line means to process shadow
            #pragma multi_compile_shadowcaster
            
            #include "UnityCG.cginc"

            fixed _BurnAmount;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent: TANGENT;
            };

            struct v2f
            {
                // Define the variable of shadow caster
                V2F_SHADOW_CASTER;
                float2 uvBurnMap : TEXCOORD0;
            };
            
            v2f vert (a2v v)
            {
                v2f o;

                // Set the variabe of V2F_SHADOW_CASTER
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap);
                
                clip(burn - _BurnAmount);

                // Let Unity do cast shadow
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}