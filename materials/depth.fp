varying mediump vec4 var_position;
vec4 float_to_rgba(float v)
{
    vec4 enc = vec4(1.0, 255.0, 65025.0, 16581375.0) * v;
    enc      = fract(enc);
    enc     -= enc.yzww * vec4(1.0/255.0,1.0/255.0,1.0/255.0,0.0);
    return enc;
}

void main()
{
    //normalized view-space z as depth, since it’s view-space it’s linear
    //divide by distance to far-clip plane
    //float_to_rgba gives higher precision?
    float far = 20.;
    gl_FragColor = float_to_rgba(var_position.z / far);
}

