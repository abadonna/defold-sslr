varying mediump vec2 var_texcoord0;
varying mediump vec4 var_position;
uniform highp mat4 mtx_viewproj;
varying highp mat4 var_mtx_invproj;

uniform mediump sampler2D tex0;
uniform mediump sampler2D tex1;
uniform mediump sampler2D tex2;
uniform mediump sampler2D tex3;

const vec3 light = vec3(2., 1., 2.);

vec3 get_position(vec2 uv, float depth)
{
	vec4 position = vec4(1.0); 
	position.xy = uv.xy * 2.0 - 1.0; 
	position.z = depth * 2.0 - 1.0; 
	position = var_mtx_invproj * position; 
	position /= position.w;
	return position.xyz;
}


float rgba_to_float(vec4 rgba)
{
	return dot(rgba, vec4(1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0));
}

void main()
{
	vec4 color = texture(tex0, var_texcoord0);
	vec3 normal = texture(tex1, var_texcoord0).xyz * 2.0 - 1.0;
	float depth = rgba_to_float(texture(tex2, var_texcoord0));
	vec3 pos = get_position(var_texcoord0, depth);
	vec4 reflection = texture(tex3, var_texcoord0);

	vec3 ambient_light = vec3(0.2);
	
	// diffuse
	vec3 diff_light = normalize(light - pos);
	diff_light = max(dot(normal, diff_light), 0.0) + ambient_light;
	diff_light = clamp(diff_light, 0.0, 1.0);

	gl_FragColor = vec4(mix(diff_light * color.xyz, reflection.xyz, reflection.w), 1);
	//gl_FragColor = reflection;
}