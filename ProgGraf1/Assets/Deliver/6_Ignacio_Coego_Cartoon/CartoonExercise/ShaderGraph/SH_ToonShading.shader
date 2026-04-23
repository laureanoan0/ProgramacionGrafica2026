// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "New Amplify Shader"
{
	Properties
	{
		_ShadowForce1("ShadowForce1", Range( 0 , 1)) = 0.3
		_ShadowForce2("ShadowForce2", Range( 0 , 1)) = 0.5
		_ShadowForce3("ShadowForce3", Range( 0 , 1)) = 0.7
		_Basecolor("Base color", Color) = (0.4705882,0.8627451,0.3137255,0)
		_ShadowColor("ShadowColor", Color) = (0.1176471,0.3921569,0.1568628,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _ShadowColor;
		uniform float4 _Basecolor;
		uniform float _ShadowForce1;
		uniform float _ShadowForce2;
		uniform float _ShadowForce3;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult3 = dot( ase_worldlightDir , ase_worldNormal );
			float DotResult6 = dotResult3;
			float Steps16 = ( ( step( _ShadowForce1 , dotResult3 ) + step( _ShadowForce2 , DotResult6 ) + step( _ShadowForce3 , DotResult6 ) ) / 3.0 );
			float4 lerpResult21 = lerp( _ShadowColor , _Basecolor , Steps16);
			c.rgb = ( ( ase_lightAtten * ase_lightColor ) * lerpResult21 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
1232;73;687;641;1713.062;1065.323;3.165026;False;False
Node;AmplifyShaderEditor.CommentaryNode;26;-1081.604,-455.3737;Inherit;False;657.9194;510.0358;Calcula la incidencia de luz mediante Dot Product y define un corte duro con Step;6;1;2;3;6;4;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1;-1031.604,-311.6373;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;2;-997.8041,-128.3379;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;3;-766.6678,-197.2671;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-793.7321,-71.45277;Inherit;False;DotResult;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;27;-1078.179,145.805;Inherit;False;1127.762;545.7599;Replica los steps mediante la variable del dot product para luego guardarlo en una local var de steps, los cuales generan 3 cortes de sombras;10;10;7;8;9;12;11;13;15;14;16;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1028.178,484.6164;Inherit;False;Property;_ShadowForce3;ShadowForce3;2;0;Create;True;0;0;0;False;0;False;0.7;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1026.573,279.0417;Inherit;False;Property;_ShadowForce2;ShadowForce2;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-970.4042,575.5652;Inherit;False;6;DotResult;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-972.6043,375.9649;Inherit;False;6;DotResult;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-945.0137,-405.3737;Inherit;False;Property;_ShadowForce1;ShadowForce1;0;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;5;-575.6849,-212.0442;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;11;-645.7045,241.3654;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;12;-640.6044,411.9656;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-462.4167,324.2245;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-464.1501,195.805;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-302.4163,240.2243;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-174.4159,247.2243;Inherit;False;Steps;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-259.9634,-915.561;Inherit;False;569.27;408.8682;Fuerza de iluminacion;3;23;22;24;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-247.3194,-472.6625;Inherit;False;537.5177;572.6646;combinamos la sombra y el color con la variable de steps como alpha ;4;19;17;20;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-146.4559,-15.99806;Inherit;False;16;Steps;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-181.4593,-216.7713;Inherit;False;Property;_Basecolor;Base color;3;0;Create;True;0;0;0;False;0;False;0.4705882,0.8627451,0.3137255,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;20;-197.3194,-422.6625;Inherit;False;Property;_ShadowColor;ShadowColor;4;0;Create;True;0;0;0;False;0;False;0.1176471,0.3921569,0.1568628,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;23;-180.7431,-766.4955;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;22;-209.9634,-865.561;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;108.1983,-174.3356;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;147.3066,-641.6928;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;411.222,-418.0688;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;592.1183,-597.9022;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;New Amplify Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;6;0;3;0
WireConnection;5;0;4;0
WireConnection;5;1;3;0
WireConnection;11;0;7;0
WireConnection;11;1;9;0
WireConnection;12;0;8;0
WireConnection;12;1;10;0
WireConnection;13;0;5;0
WireConnection;13;1;11;0
WireConnection;13;2;12;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;16;0;14;0
WireConnection;21;0;20;0
WireConnection;21;1;17;0
WireConnection;21;2;19;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;25;0;24;0
WireConnection;25;1;21;0
WireConnection;0;13;25;0
ASEEND*/
//CHKSM=9CE9F92993C5CD7FBB8D464C5EA10F152D992037