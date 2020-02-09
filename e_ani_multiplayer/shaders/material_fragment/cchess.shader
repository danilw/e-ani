shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_back,diffuse_lambert_wrap,specular_schlick_ggx,world_vertex_coords;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;
uniform vec4 transmission : hint_color;
uniform sampler2D texture_transmission : hint_black;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform vec3 bsz;
uniform float g_scale;
uniform float cval;
uniform float timer;
uniform bool act;
uniform float sps;
uniform vec4 emt_col:hint_color;

uniform sampler2D texture_trip:hint_albedo;

varying vec3 uv1_power_normal;
varying vec3 uv1_triplanar_pos;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	float cposy=sps*g_scale;
	vec3 tbsz=bsz*g_scale;
	float vv=(VERTEX.y-cposy);
	COLOR.a=step(vv,cval*tbsz.y-tbsz.y/2.);
	float eval=smoothstep(1.,0.,timer);
	COLOR.r=smoothstep(vv+0.1+tbsz.y*eval/1.15,vv+0.05,cval*tbsz.y-tbsz.y/2.)*(smoothstep(1.,.9,1.-eval));

	/*TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);*/
	uv1_power_normal=pow(abs(NORMAL),vec3(1.));
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset+vec3(0.,-0.*cval,0.);

	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy*2.) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz*2.) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy*2. * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	vec3 transmission_tex = texture(texture_transmission,base_uv).rgb;
	TRANSMISSION = (transmission.rgb+transmission_tex);
	ALPHA=COLOR.a;
	if(act){
	float tt=5.*triplanar_texture(texture_trip,uv1_power_normal,uv1_triplanar_pos).r;
	EMISSION=tt*COLOR.r*emt_col.rgb*2.;
	}
}
