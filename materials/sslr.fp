varying mediump vec2 var_texcoord0;
varying mediump vec4 var_position;
uniform mediump mat4 mtx_viewproj;
varying mediump mat4 var_mtx_invproj;

uniform highp sampler2D tex0;
uniform highp sampler2D tex1;
uniform highp sampler2D tex2;
uniform mediump mat4 mtx_proj;

float rgba_to_float(vec4 rgba)
{
	return dot(rgba, vec4(1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0));
}

vec3 get_position(vec2 uv, float depth)
{
	vec4 position = vec4(1.0); 
	position.xy = uv.xy * 2.0 - 1.0; 
	position.z = depth; 
	position = var_mtx_invproj * position; 
	position /= position.w;
	return position.xyz;
}

vec3 get_uv(vec3 position)
{
	vec4 p = vec4(position, 1.0);
	p = mtx_proj * p;
	p.xy /= p.w; // perspective divide
	p.xy  = p.xy * 0.5 + 0.5; // transform to range 0.0 - 1.0  
	return p.xyz;
}

float get_depth(vec2 uv)
{
	return rgba_to_float(texture(tex2, uv));
}

void main()
{
	vec4 data = texture(tex1, var_texcoord0);
	vec3 normal = (data.xyz * 2.0 - 1.0);
	float depth = get_depth(var_texcoord0);

	vec3 pos = get_position(var_texcoord0, depth);
	vec3 view_dir = normalize(pos);// - camera.xyz);
	float fresnel = clamp(1 - dot(-view_dir, normal), 0., 1.);
	
	if (fresnel < 0.002) {
		gl_FragColor = vec4(0); 
		return;
	}

	vec3 reflect_dir = normalize(reflect(view_dir, normal));

	vec3 ray = vec3(0.);
	vec3 nuv = vec3(0.);
	float L = 0.01;
	for(int i = 0; i < 6; i++)
	{
		ray = pos + reflect_dir * L;
		nuv = get_uv(ray); // проецирование позиции на экран
		depth = get_depth(nuv.xy);
		vec3 p = get_position(nuv.xy, depth);
		L = length(pos - p);
	}

	L = clamp(L * 4., 0, 1);

	float error = (1. - L);
	float factor = error * fresnel;
	vec4 color =  vec4(texture(tex0, nuv.xy).xyz * factor, factor);

	gl_FragColor = color;
	//vec4(fresnel,fresnel,fresnel, 1);
	
}