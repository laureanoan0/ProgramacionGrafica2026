// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MAT_Marker_Light"
{
	Properties
	{
		_FadeScale("FadeScale", Float) = 2
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float3 worldPos;
		};

		uniform float _FadeScale;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float temp_output_24_0 = ( 1.0 - saturate( ( ( ase_vertex3Pos.y - (-1.18 + (sin( _Time.y ) - -1.0) * (-1.0 - -1.18) / (1.0 - -1.0)) ) / _FadeScale ) ) );
			float4 color8 = IsGammaSpace() ? float4(1,0,0,1) : float4(1,0,0,1);
			o.Emission = ( temp_output_24_0 * color8 ).rgb;
			o.Alpha = temp_output_24_0;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
100;73;1381;655;2307.258;784.3315;2.059754;True;False
Node;AmplifyShaderEditor.CommentaryNode;39;-1233.296,27.6077;Inherit;False;793.2001;375.6;Sin para generar ondas, Remap para limitar longitud de onda, Vertex Pos para usar solo la Y del Obj.;5;2;6;1;21;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1187.93,205.3595;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;21;-1009.691,205.1949;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;1;-875.1927,60.25457;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;6;-870.061,205.4936;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;-1.18;False;4;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-435.0188,29.02334;Inherit;False;1192.811;485.995;Divide Regula intensidad de luz, Saturate acomoda valores, OneMinus invierte valores, Multiply x Color lo pone rojo, Emission para darle brillo ;7;0;7;24;8;38;36;37;;1,1,1,0.4901961;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;2;-657.6304,108.5249;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-418.4766,204.2748;Inherit;False;Property;_FadeScale;FadeScale;0;0;Create;True;0;0;0;False;0;False;2;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;36;-400.1925,109.4368;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;38;-270.4766,109.2748;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;24;-111.6814,110.5231;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;8;150.6128,323.1802;Inherit;False;Constant;_Color0;Color 0;0;0;Create;True;0;0;0;False;0;False;1,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;150.0127,111.1803;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;525.1952,64.47588;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MAT_Marker_Light;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;0;3;0
WireConnection;6;0;21;0
WireConnection;2;0;1;2
WireConnection;2;1;6;0
WireConnection;36;0;2;0
WireConnection;36;1;37;0
WireConnection;38;0;36;0
WireConnection;24;0;38;0
WireConnection;7;0;24;0
WireConnection;7;1;8;0
WireConnection;0;2;7;0
WireConnection;0;9;24;0
ASEEND*/
//CHKSM=FA88B130586CB9DE737A77AB4BAC83A80EC0ED52