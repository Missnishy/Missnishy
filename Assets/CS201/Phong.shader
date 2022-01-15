Shader "ShaderCustom/Phong"
{
    Properties
    {
        _BaseColor("物体纹理", 2d) = "white"{}
        _NormalMap("法线贴图", 2d) = "bump"{}
        _NormalIntensity("法线强度", range(0.0,5.0)) = 1.0
        _SpecIntensity("高光强度", range(0.01, 5)) = 1
        _SpecPow("高光次幂", range(0.01, 200)) = 20
        _AmbientColor("环境光颜色", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            //受光标签
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //告诉渲染管线这个pass以forwardbase渲染
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            //Unity光照函数库
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal_Dir :TEXCOORD1;
                float3 pos_WS : TEXCOORD2;
                float4 uv : TEXCOORD0;
                float3 tangent_Dir : TEXCOORD3;
                float3 binormal_Dir : TEXCOORD4;

            };


            float _SpecPow;
            sampler2D _BaseColor;
            sampler2D _NormalMap;
            float _NormalIntensity;
            float4 _LightColor0;
            float _SpecIntensity;
            float3 _AmbientColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.normal_Dir = UnityObjectToWorldNormal(v.normal);
                o.normal_Dir = normalize(mul(float4(v.normal,0.0), unity_ObjectToWorld).xyz);
                o.tangent_Dir = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
                //v.tangent.w：tangent的第四个分量，为了处理不同平台下的兼容性问题
                o.binormal_Dir = cross(o.normal_Dir, o.tangent_Dir) * v.tangent.w;
                o.pos_WS = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 base_color = tex2D(_BaseColor, i.uv);
                float4 normal_Map = tex2D(_NormalMap, i.uv);
                //对法线数据进行解码，将压缩的法线数据从[0,1]恢复成[-1,1]
                float3 normal_data = UnpackNormal(normal_Map);

                //NormalMap
                float3 nDir = normalize(i.normal_Dir);
                float3 tDir = normalize(i.tangent_Dir);
                float3 bDir = normalize(i.binormal_Dir);
                //得到新的法线
                //nDir = normalize(tDir * normal_data.x * _NormalIntensity + bDir * normal_data.y * _NormalIntensity + nDir * normal_data.z);
                float3x3 TBN = float3x3(tDir, bDir, nDir);
                nDir = normalize(mul(normal_data.xyz, TBN));

                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 vDir = normalize(_WorldSpaceLightPos0.xyz - i.pos_WS);
                float3 lrDir = normalize(reflect(-lDir, nDir));

                float3 Diffuse = max(0.0, dot(nDir, lDir)) * base_color * _LightColor0;
                float3 Specular = pow(max(0.0, dot(lrDir, vDir)), _SpecPow) * _SpecIntensity * _LightColor0;
                float3 finalRGB = Diffuse + Specular + _AmbientColor.xyz;

                return float4(finalRGB, 1.0);
            }
            ENDCG
        }

        Pass
        {
            //受光标签
            Tags{"LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //告诉渲染管线这个pass以forwardadd渲染
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            //Unity光照函数库
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal_Dir :TEXCOORD1;
                float3 pos_WS : TEXCOORD2;
                float4 uv : TEXCOORD0;
                float3 tangent_Dir : TEXCOORD3;
                float3 binormal_Dir : TEXCOORD4;

            };


            float _SpecPow;
            sampler2D _BaseColor;
            sampler2D _NormalMap;
            float _NormalIntensity;
            float4 _LightColor0;
            float _SpecIntensity;
            float3 _AmbientColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.normal_Dir = UnityObjectToWorldNormal(v.normal);
                o.normal_Dir = normalize(mul(float4(v.normal,0.0), unity_ObjectToWorld).xyz);
                o.tangent_Dir = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
                //v.tangent.w：tangent的第四个分量，为了处理不同平台下的兼容性问题
                o.binormal_Dir = cross(o.normal_Dir, o.tangent_Dir) * v.tangent.w;
                o.pos_WS = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 base_color = tex2D(_BaseColor, i.uv);
                float4 normal_Map = tex2D(_NormalMap, i.uv);
                //对法线数据进行解码，将压缩的法线数据从[0,1]恢复成[-1,1]
                float3 normal_data = UnpackNormal(normal_Map);

                //NormalMap
                float3 nDir = normalize(i.normal_Dir);
                float3 tDir = normalize(i.tangent_Dir);
                float3 bDir = normalize(i.binormal_Dir);
                //得到新的法线
                //nDir = normalize(tDir * normal_data.x * _NormalIntensity + bDir * normal_data.y * _NormalIntensity + nDir * normal_data.z);
                float3x3 TBN = float3x3(tDir, bDir, nDir);
                nDir = normalize(mul(normal_data.xyz, TBN));

                #if defined(DIRECTIONAL)
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);
                float attenuation = 1.0;
                #elif defined(POINT)
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz - i.pos_WS);
                float distance = length(_WorldSpaceLightPos0.xyz - i.pos_WS);
                float range = 1.0 / unity_WorldToLight[0][0];
                float attenuation = saturate((range - distance) / range);
                #endif

                float3 vDir = normalize(_WorldSpaceLightPos0.xyz - i.pos_WS);
                float3 lrDir = normalize(reflect(-lDir, nDir));

                float3 Diffuse = max(0.0, dot(nDir, lDir)) * base_color * _LightColor0 * attenuation;
                float3 Specular = pow(max(0.0, dot(lrDir, vDir)), _SpecPow) * _SpecIntensity * _LightColor0 * attenuation;
                float3 finalRGB = Diffuse + Specular;

                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
}
