shader_type spatial;
render_mode blend_add,depth_draw_alpha_prepass,cull_disabled,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : hint_color;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);

uniform float value;


void vertex() {
	float pi=3.1415926;
	VERTEX.y=1.5-atan(max(((VERTEX.z/2.5)+1.)*pi*8.,0.001));
	VERTEX.y+=-0.25*sin(((VERTEX.z/2.5)+1.)*pi/2.);
	
}




void fragment() {
	vec2 base_uv = UV;
	ALBEDO = albedo.rgb*3.;
	ALBEDO.g+=texture(SCREEN_TEXTURE,SCREEN_UV).b*0.25;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	ALPHA = 0.9*albedo.a*smoothstep(0.05,0.0,UV.y-0.95*(value)-0.05);
}
