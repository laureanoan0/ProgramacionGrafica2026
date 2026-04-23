// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SH_Edificios"
{
	Properties
	{
		_Tiling("Tiling", Float) = 1
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_HeightMap("HeightMap", 2D) = "white" {}
		_Texture0("Texture 0", 2D) = "white" {}
		_ParallaxScale("ParallaxScale", Float) = 0.02
		_Float0("Float 0", Float) = 0.02
		_Texture1("Texture 1", 2D) = "white" {}
		_Texture2("Texture 2", 2D) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float3 viewDir;
		};

		uniform sampler2D _Texture2;
		uniform float _Tiling;
		uniform sampler2D _Texture1;
		uniform sampler2D _TextureSample1;
		uniform sampler2D _Texture0;
		uniform float _Float0;
		uniform float4 _Texture0_ST;
		uniform sampler2D _TextureSample0;
		uniform sampler2D _HeightMap;
		uniform float _ParallaxScale;
		uniform float4 _HeightMap_ST;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs.xy += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
			 	currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).r;
			 	if ( currHeight > currRayZ )
			 	{
			 	 	stepIndex = numSteps + 1;
			 	}
			 	else
			 	{
			 	 	stepIndex++;
			 	 	prevTexOffset = currTexOffset;
			 	 	prevRayZ = currRayZ;
			 	 	prevHeight = currHeight;
			 	 	currTexOffset += deltaTex;
			 	 	currRayZ -= layerHeight;
			 	}
			}
			int sectionSteps = 2;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
			 	intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
			 	finalTexOffset = prevTexOffset + intersection * deltaTex;
			 	newZ = prevRayZ - intersection * layerHeight;
			 	newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).r;
			 	if ( newHeight > newZ )
			 	{
			 	 	currTexOffset = finalTexOffset;
			 	 	currHeight = newHeight;
			 	 	currRayZ = newZ;
			 	 	deltaTex = intersection * deltaTex;
			 	 	layerHeight = intersection * layerHeight;
			 	}
			 	else
			 	{
			 	 	prevTexOffset = finalTexOffset;
			 	 	prevHeight = newHeight;
			 	 	prevRayZ = newZ;
			 	 	deltaTex = ( 1 - intersection ) * deltaTex;
			 	 	layerHeight = ( 1 - intersection ) * layerHeight;
			 	}
			 	sectionIndex++;
			}
			return uvs.xy + finalTexOffset;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult19 = (float4(ase_worldPos.z , ase_worldPos.y , 0.0 , 0.0));
			float4 SideUV70 = ( _Tiling * appendResult19 );
			float4 appendResult15 = (float4(ase_worldPos.x , ase_worldPos.y , 0.0 , 0.0));
			float4 FrontUV29 = ( appendResult15 * _Tiling );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float temp_output_24_0 = abs( ase_worldNormal.z );
			float4 lerpResult87 = lerp( tex2D( _Texture2, SideUV70.xy ) , tex2D( _Texture1, FrontUV29.xy ) , temp_output_24_0);
			o.Normal = lerpResult87.rgb;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 OffsetPOM71 = POM( _Texture0, SideUV70.xy, ddx(SideUV70.xy), ddy(SideUV70.xy), ase_worldNormal, ase_worldViewDir, i.viewDir, 8, 8, _Float0, 0.5, _Texture0_ST.xy, float2(0,0), 0 );
			float2 POMSIDE77 = OffsetPOM71;
			float2 OffsetPOM68 = POM( _HeightMap, FrontUV29.xy, ddx(FrontUV29.xy), ddy(FrontUV29.xy), ase_worldNormal, ase_worldViewDir, i.viewDir, 8, 8, _ParallaxScale, 0.5, _HeightMap_ST.xy, float2(0,0), 0 );
			float2 POM37 = OffsetPOM68;
			float4 lerpResult26 = lerp( tex2D( _TextureSample1, POMSIDE77 ) , tex2D( _TextureSample0, POM37 ) , temp_output_24_0);
			float4 Tiling27 = lerpResult26;
			o.Albedo = Tiling27.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
1232;73;687;641;2795.031;1264.294;4.221504;False;False
Node;AmplifyShaderEditor.CommentaryNode;90;-2637.214,-905.621;Inherit;False;943.3369;447.0369;Crea coordenadas UV basadas en la posición de mundo (X,Y,Z) para el frente y el lateral del cubo;8;13;19;14;15;21;16;70;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;13;-2587.214,-764.3549;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;15;-2336.877,-853.6215;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2188.984,-733.2303;Inherit;False;Property;_Tiling;Tiling;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-2328.928,-641.5841;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-2042.035,-655.4191;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-2052.13,-851.8842;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-1917.876,-659.1506;Inherit;False;SideUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;91;-2630.379,-410.2358;Inherit;False;946.5569;487.9748;Parallax Lateral: Aplica el efecto de profundidad específicamente en las proyecciones de los costados.;7;75;76;72;73;74;71;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;89;-2601.365,129.7517;Inherit;False;911.7881;436.614;Parallax Frontal: Genera profundidad visual en el frente usando el HeightMap y la dirección de cámara.;7;36;69;32;31;30;68;37;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-1921.348,-855.621;Inherit;False;FrontUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;30;-2533.066,378.3659;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;31;-2551.365,179.7517;Inherit;True;Property;_HeightMap;HeightMap;3;0;Create;True;0;0;0;False;0;False;7e1ce9143f82ef74d95a931b2902706f;7e1ce9143f82ef74d95a931b2902706f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;32;-2320.219,288.0898;Inherit;False;Property;_ParallaxScale;ParallaxScale;5;0;Create;True;0;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2319.531,411.5033;Inherit;False;Constant;_RefPlane;RefPlane;11;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2332.492,-100.9914;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2343.257,-219.2761;Inherit;False;Property;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-2359.543,-360.2358;Inherit;False;70;SideUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;73;-2580.379,-300.2483;Inherit;True;Property;_Texture0;Texture 0;4;0;Create;True;0;0;0;False;0;False;b244943b7556a3b4bb132d9ec158397e;b244943b7556a3b4bb132d9ec158397e;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;74;-2543.093,-110.261;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;36;-2317.168,183.3069;Inherit;False;29;FrontUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;68;-2133.1,217.3395;Inherit;False;0;8;False;-1;16;False;-1;2;0.02;0;False;1,1;False;0,0;8;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;7;SAMPLERSTATE;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;71;-2160.416,-300.3334;Inherit;False;0;8;False;-1;16;False;-1;2;0.02;0;False;1,1;False;0,0;8;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;7;SAMPLERSTATE;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1907.822,-305.9127;Inherit;False;POMSIDE;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;88;-1356.804,-788.6828;Inherit;False;1033.34;650.9795;Blending por Normal: Selecciona entre UVs frontales o laterales según la inclinación de la cara (Normal Z).;8;23;78;61;18;22;24;26;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1913.578,209.4152;Inherit;False;POM;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-1306.804,-710.0993;Inherit;False;37;POM;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-1277.88,-501.5406;Inherit;False;77;POMSIDE;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;23;-1056.777,-320.7033;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;92;-489.3849,-105.8412;Inherit;False;895.9923;692.6819;Normales de la textura;7;81;83;84;86;82;85;87;;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;24;-858.3942,-250.297;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;-1079.961,-536.4916;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;07d87df54ba1d9347b1ee3e70ab8776f;07d87df54ba1d9347b1ee3e70ab8776f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;18;-1080.18,-738.6828;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;ee9f27bef2e9710459fec9a7686854d7;ee9f27bef2e9710459fec9a7686854d7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;26;-703.2762,-607.3336;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;81;-439.3849,276.3026;Inherit;True;Property;_Texture1;Texture 1;7;0;Create;True;0;0;0;False;0;False;07d87df54ba1d9347b1ee3e70ab8776f;07d87df54ba1d9347b1ee3e70ab8776f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;83;-424.3245,470.8407;Inherit;False;29;FrontUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;84;-430.2585,-55.84117;Inherit;True;Property;_Texture2;Texture 2;8;0;Create;True;0;0;0;False;0;False;07d87df54ba1d9347b1ee3e70ab8776f;07d87df54ba1d9347b1ee3e70ab8776f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;86;-403.1788,179.5819;Inherit;False;70;SideUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-547.4638,-612.1394;Inherit;False;Tiling;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;82;-189.8447,327.6067;Inherit;True;Property;_TextureSample2;Texture Sample 2;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;85;-131.9555,-7.560789;Inherit;True;Property;_TextureSample3;Texture Sample 3;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;28;90.28677,-598.1136;Inherit;False;27;Tiling;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;87;224.6074,80.77273;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;293.2966,-542.7382;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;SH_Edificios;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;13;1
WireConnection;15;1;13;2
WireConnection;19;0;13;3
WireConnection;19;1;13;2
WireConnection;21;0;14;0
WireConnection;21;1;19;0
WireConnection;16;0;15;0
WireConnection;16;1;14;0
WireConnection;70;0;21;0
WireConnection;29;0;16;0
WireConnection;68;0;36;0
WireConnection;68;1;31;0
WireConnection;68;2;32;0
WireConnection;68;3;30;0
WireConnection;68;4;69;0
WireConnection;71;0;72;0
WireConnection;71;1;73;0
WireConnection;71;2;76;0
WireConnection;71;3;74;0
WireConnection;71;4;75;0
WireConnection;77;0;71;0
WireConnection;37;0;68;0
WireConnection;24;0;23;3
WireConnection;22;1;78;0
WireConnection;18;1;61;0
WireConnection;26;0;22;0
WireConnection;26;1;18;0
WireConnection;26;2;24;0
WireConnection;27;0;26;0
WireConnection;82;0;81;0
WireConnection;82;1;83;0
WireConnection;85;0;84;0
WireConnection;85;1;86;0
WireConnection;87;0;85;0
WireConnection;87;1;82;0
WireConnection;87;2;24;0
WireConnection;0;0;28;0
WireConnection;0;1;87;0
ASEEND*/
//CHKSM=654416C063835DFF66E5124D99EF71075365A512