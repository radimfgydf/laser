// http://wiki.unity3d.com/index.php?title=UnlitAlphaWithFade
Shader "Unlit/UnlitAlphaWithFade_2Side"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)   
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white"
    }

    Category
    {
        Lighting Off
        ZWrite On
        Cull off
        Blend SrcAlpha OneMinusSrcAlpha
        Tags {Queue=Transparent}

        SubShader
        {
            Pass
            {
                SetTexture [_MainTex]
                {
                   ConstantColor [_Color]
                   Combine Texture * constant
                }
            }
        }
    }
}