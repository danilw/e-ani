shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_back,unshaded;
uniform vec4 colorx:hint_color;

void fragment() {
	ALBEDO = 1.*colorx.rgb;
	
	float intensity = pow(0.122 + max(dot(NORMAL, normalize(VIEW)),0.), 010.85);
	ALPHA=0.0+intensity;

}