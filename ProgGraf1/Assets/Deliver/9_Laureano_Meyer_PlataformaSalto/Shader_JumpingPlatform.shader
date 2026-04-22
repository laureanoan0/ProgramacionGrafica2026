// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Sphere"
{
	Properties
	{
		_Speed("Speed", Float) = 0.001
		_Color("Color", Color) = (0.09251513,0.8313971,0.9339623,0)
		_Frequency("Frequency", Float) = 1
		_FadeScale("FadeScale", Float) = 6
		_Power("Power", Float) = 15
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
		};

		uniform float4 _Color;
		uniform float _Speed;
		uniform float _Frequency;
		uniform float _Power;
		uniform float _FadeScale;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float mulTime35 = _Time.y * _Speed;
			float saferPower70 = max( sin( ( ( ( 1.0 - ase_vertex3Pos.y ) + mulTime35 ) * ( _Frequency * 6.28318548202515 ) ) ) , 0.0001 );
			float temp_output_70_0 = pow( saferPower70 , _Power );
			float Lines67 = temp_output_70_0;
			o.Emission = ( _Color * Lines67 ).rgb;
			float Transparency60 = ( 1.0 - saturate( ( ( ase_vertex3Pos.y - -0.57 ) / _FadeScale ) ) );
			o.Alpha = ( Lines67 * Transparency60 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
320;73;1232;679;5163.525;189.5146;5.007792;True;False
Node;AmplifyShaderEditor.CommentaryNode;66;-2548.522,1746.188;Inherit;False;2054.464;645.2394;Crea las lineas;14;67;48;40;34;39;49;37;38;35;33;36;70;71;72;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2369.79,2024.186;Inherit;False;Property;_Speed;Speed;0;0;Create;True;0;0;0;False;0;False;0.001;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;33;-2498.522,1796.188;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;51;-2547.884,1091.325;Inherit;False;2073.071;593.4011;Mueve la textura hacia arriba;8;60;59;58;57;56;55;54;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;49;-2293.591,1854.088;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;35;-2147.732,2038.329;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1949.714,2162.796;Inherit;False;Property;_Frequency;Frequency;2;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TauNode;37;-1924.255,2251.905;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;54;-2497.883,1169.705;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;61;-2168.411,1470.184;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;-0.57;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1734.722,2192.499;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1783.206,1369.867;Inherit;False;Property;_FadeScale;FadeScale;3;0;Create;True;0;0;0;False;0;False;6;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;56;-1879.245,1148.688;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-1956.018,1846.542;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1699.746,1824.829;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;57;-1599.86,1173.425;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1278.805,2112.636;Inherit;False;Property;_Power;Power;4;0;Create;True;0;0;0;False;0;False;15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;58;-1355.839,1143.059;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;48;-1473.688,1818.732;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;59;-1175.027,1148.052;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;70;-1247.148,1812.252;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-670.5629,1802.314;Inherit;False;Lines;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-958.6843,1148.236;Inherit;True;Transparency;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;-1431.652,-60.60649;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;0.09251513,0.8313971,0.9339623,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;68;-1164.719,45.77717;Inherit;False;67;Lines;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-998.6825,289.1276;Inherit;False;67;Lines;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-1006.522,561.5673;Inherit;False;60;Transparency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-920.0284,-56.31912;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-745.3796,245.6173;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;71;-951.1864,1810.327;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;65;-401.9675,-103.3187;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Sphere;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;49;0;33;2
WireConnection;35;0;36;0
WireConnection;39;0;38;0
WireConnection;39;1;37;0
WireConnection;56;0;54;2
WireConnection;56;1;61;0
WireConnection;34;0;49;0
WireConnection;34;1;35;0
WireConnection;40;0;34;0
WireConnection;40;1;39;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;58;0;57;0
WireConnection;48;0;40;0
WireConnection;59;0;58;0
WireConnection;70;0;48;0
WireConnection;70;1;72;0
WireConnection;67;0;70;0
WireConnection;60;0;59;0
WireConnection;43;0;42;0
WireConnection;43;1;68;0
WireConnection;62;0;69;0
WireConnection;62;1;63;0
WireConnection;71;0;70;0
WireConnection;65;2;43;0
WireConnection;65;9;62;0
ASEEND*/
//CHKSM=59E52A75241B6EA53B353B07CC88BEE848414020