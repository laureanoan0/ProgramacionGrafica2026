// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ghost"
{
	Properties
	{
		_BaseCOlor("BaseCOlor", Color) = (0.1817818,0.8250467,0.8962264,0)
		_Bias("Bias", Float) = 0
		_Power("Power", Float) = 1
		_Scale("Scale", Float) = 1.66
		_CenterColor("CenterColor", Color) = (1,1,1,0)
		_FadeScale("FadeScale", Float) = 6
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf Unlit alpha:fade keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float4 _CenterColor;
		uniform float4 _BaseCOlor;
		uniform float _Bias;
		uniform float _Power;
		uniform float _Scale;
		uniform float _FadeScale;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV3 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode3 = ( _Bias + _Power * pow( 1.0 - fresnelNdotV3, _Scale ) );
			float4 lerpResult4 = lerp( _CenterColor , _BaseCOlor , fresnelNode3);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float Transparency25 = ( 1.0 - saturate( ( ( ase_vertex3Pos.y - sin( _Time.y ) ) / _FadeScale ) ) );
			float4 Color29 = ( lerpResult4 * Transparency25 );
			o.Emission = Color29.rgb;
			o.Alpha = Transparency25;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
278;73;1346;687;1821.846;412.3407;1.948232;True;False
Node;AmplifyShaderEditor.CommentaryNode;24;-2470.016,763.6343;Inherit;False;2073.071;593.4011;Comment;9;25;23;22;20;18;21;13;31;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;31;-2418.078,1124.382;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;34;-2217.938,1094.419;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;13;-2420.015,842.0142;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-1705.338,1042.176;Inherit;False;Property;_FadeScale;FadeScale;10;0;Create;True;0;0;0;False;0;False;6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-1801.377,820.9965;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;20;-1521.992,845.7336;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;28;-2419.485,-372.0081;Inherit;False;1681.022;961.932;Comment;10;17;7;8;5;4;2;6;26;3;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;22;-1309.544,816.6312;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2327.885,336.7234;Inherit;False;Property;_Power;Power;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;23;-1069.533,823.4301;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-2333.085,468.024;Inherit;False;Property;_Scale;Scale;8;0;Create;True;0;0;0;False;0;False;1.66;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2369.485,217.1234;Inherit;False;Property;_Bias;Bias;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;3;-2006.059,121.8247;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-1963.106,-134.6301;Inherit;False;Property;_BaseCOlor;BaseCOlor;5;0;Create;True;0;0;0;False;0;False;0.1817818,0.8250467,0.8962264,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-880.8163,820.5446;Inherit;False;Transparency;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;8;-1891.786,-322.0081;Inherit;False;Property;_CenterColor;CenterColor;9;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1477.22,31.75965;Inherit;False;25;Transparency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;4;-1515.552,-120.042;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1241.909,-131.0914;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-981.4258,-132.8913;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-507.767,87.56259;Inherit;False;25;Transparency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-472.8627,-60.51728;Inherit;False;29;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;39.06837,-92.80436;Float;False;True;-1;6;ASEMaterialInspector;0;0;Unlit;Ghost;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;1,1,1,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;34;0;31;0
WireConnection;18;0;13;2
WireConnection;18;1;34;0
WireConnection;20;0;18;0
WireConnection;20;1;21;0
WireConnection;22;0;20;0
WireConnection;23;0;22;0
WireConnection;3;1;5;0
WireConnection;3;2;6;0
WireConnection;3;3;7;0
WireConnection;25;0;23;0
WireConnection;4;0;8;0
WireConnection;4;1;2;0
WireConnection;4;2;3;0
WireConnection;17;0;4;0
WireConnection;17;1;26;0
WireConnection;29;0;17;0
WireConnection;0;2;30;0
WireConnection;0;9;27;0
ASEEND*/
//CHKSM=0568F5794B01193E645181DE0FAFAB5900774EF0