varying mediump vec2 var_texcoord0;
varying mediump vec4 var_position;
uniform highp mat4 mtx_viewproj;
uniform highp vec4 righttop; //right, top, near, far

uniform mediump sampler2D tex0;
uniform mediump sampler2D tex1;
uniform mediump sampler2D tex2;
uniform mediump sampler2D tex3;

const vec3 light = vec3(2., 1., 2.);

float rgba_to_float(vec4 rgba)
{
	return dot(rgba, vec4(1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0));
}

vec3 unproject(vec2 uv)
{
	float near = righttop.z;
	float far = righttop.w;
	float d = rgba_to_float(texture2D(tex2, uv));
	vec2 ndc = uv * 2.0 - 1.0;
	vec2 pnear = ndc * righttop.xy;
	float pz = -d * far;
	return vec3(-pz * pnear.x / near, -pz * pnear.y / near, pz);
}

void main()
{
	vec4 color = texture(tex0, var_texcoord0);
	vec3 normal = texture(tex1, var_texcoord0).xyz * 2.0 - 1.0;
	vec3 pos = unproject(var_texcoord0);
	vec4 reflection = texture(tex3, var_texcoord0);

	vec3 ambient_light = vec3(0.2);
	
	// diffuse
	vec3 diff_light = normalize(light - pos);
	diff_light = max(dot(normal, diff_light), 0.0) + ambient_light;
	diff_light = clamp(diff_light, 0.0, 1.0);

	gl_FragColor = vec4(mix(diff_light * color.xyz, reflection.xyz, reflection.w), 1);
	//gl_FragColor = reflection;
}