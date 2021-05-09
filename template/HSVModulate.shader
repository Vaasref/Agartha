shader_type canvas_item;

uniform vec4 hsva_color: hint_color = vec4(1.0);
uniform vec4 modulate: hint_color = vec4(1.0);
uniform vec2 alpha;
uniform mat4 change_matrix = mat4(vec4(0., 0., 0., 1.), vec4(0. , 0., 0., 1.), vec4(0. , 0., 0., 1.), vec4(0. , 0., 0., 1.));

 

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment(){
	COLOR = texture(TEXTURE, UV) * COLOR;
	vec4 hsva_c1 = vec4(rgb2hsv(COLOR.rgb), COLOR.a);
	vec4 hsva_c2 = vec4(rgb2hsv(hsva_color.rgb), hsva_color.a);
	vec4 hsva_c3 = mix(hsva_c1, hsva_c2, vec4(change_matrix[0].xyz, alpha.x));
	hsva_c3 *= mix(vec4(1.0), hsva_c2, vec4(change_matrix[1].xyz, alpha.y));
	
	vec4 rgba_c3 = vec4(hsv2rgb(hsva_c3.xyz), hsva_c3.a);
	
	rgba_c3.rgb = mix(rgba_c3.rgb, modulate.rgb, change_matrix[2].rgb);
	rgba_c3.rgb *= mix(vec3(1.0), modulate.rgb, change_matrix[3].rgb);
	
	COLOR = rgba_c3;
}