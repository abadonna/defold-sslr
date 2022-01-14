varying mediump vec2 var_texcoord0;
uniform mediump vec4 righttop;

uniform highp sampler2D tex0;
uniform highp sampler2D tex1;
uniform highp sampler2D tex2;
uniform highp mat4 mtx_proj;
uniform highp mat4 mtx_viewproj;

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

vec2 get_uv(vec3 position)
{
	vec4 p = vec4(position, 1.0);
	p = mtx_proj * p;
	p.xy /= p.w; // perspective divide
	p.xy  = p.xy * 0.5 + 0.5; // transform to range 0.0 - 1.0  
	return p.xy;
}

float get_depth(vec2 uv)
{
	return rgba_to_float(texture(tex2, uv));
}

void main()
{
	vec4 data = texture(tex1, var_texcoord0);
	vec3 normal = (data.xyz * 2.0 - 1.0);
	
	vec3 pos = unproject(var_texcoord0);
	vec3 view_dir = normalize(pos);
	float fresnel = clamp(1 - dot(-view_dir, normal), 0., 1.);
	
	if (fresnel < 0.002 || pos.z > -0.001) {
		gl_FragColor = vec4(0); 
		return;
	}

	vec3 reflect_dir = normalize(reflect(view_dir, normal));

	vec3 ray = vec3(0.);
	vec2 nuv = vec2(0.);
	float L = 0.5;
	vec3 p = vec3(0.);
	for(int i = 0; i < 10; i++)
	{
		ray = pos + reflect_dir * L;
		nuv = get_uv(ray);
		p = unproject(nuv.xy);
		L = length(pos - p);
	}

	if (nuv.x > 1. || nuv.x < 0. || nuv.y > 1. || nuv.y < 0. ||
		pos.z < p.z || abs(ray.z - p.z) > 0.2) {
		gl_FragColor = vec4(0);
		return;
	}

	L = clamp(L * 0.3, 0, 1);

	float error = (1. - L);
	float factor = error  * fresnel;
	vec4 color =  vec4(texture(tex0, nuv.xy).xyz * factor, factor);

	gl_FragColor = color;
	//gl_FragColor = vec4(fresnel,fresnel,fresnel, 1);
	//gl_FragColor = vec4(vec3(get_depth(var_texcoord0)), 1);
	
}