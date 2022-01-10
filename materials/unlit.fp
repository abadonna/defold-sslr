varying mediump vec2 var_texcoord0;
uniform lowp sampler2D tex0;

uniform lowp vec4 tint;

void main()
{
    gl_FragColor = vec4(texture2D(tex0, var_texcoord0.xy).xyz, 1.);
}

