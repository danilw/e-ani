shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
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
uniform sampler2D texture_emission : hint_black_albedo;
uniform vec4 emission : hint_color;
uniform float emission_energy;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16);
uniform float rim : hint_range(0,1);
uniform float rim_tint : hint_range(0,1);
uniform sampler2D texture_rim : hint_white;
uniform sampler2D texture_ambient_occlusion : hint_white;
uniform vec4 ao_texture_channel;
uniform float ao_light_affect;
uniform sampler2D texture_depth : hint_black;
uniform float depth_scale;
uniform int depth_min_layers;
uniform int depth_max_layers;
uniform vec2 depth_flip;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform sampler2D iChannel0:hint_albedo;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}


void fragment() {
	vec2 base_uv = UV;
	float tcol_depth_oo=texture(iChannel0,((base_uv)*0.2)).z;
	float tcol_depth_o=tcol_depth_oo;
	tcol_depth_oo=min(pow(4.*tcol_depth_oo,2.),1.);
	{
		vec3 view_dir = normalize(normalize(-VERTEX)*mat3(TANGENT*depth_flip.x,-BINORMAL*depth_flip.y,NORMAL));
		float num_layers = mix(float(depth_max_layers),float(depth_min_layers), abs(dot(vec3(0.0, 0.0, 1.0), view_dir)));
		if(tcol_depth_oo>0.75)
		{
			float layer_depth = 1.0 / num_layers;
			float current_layer_depth = 0.0;
			vec2 P = view_dir.xy * depth_scale;
			vec2 delta = P / num_layers;
			vec2  ofs = base_uv;
			float depth = textureLod(texture_depth, ofs,0.0).r;
			float current_depth = 0.0;
			while(current_depth < depth){
				ofs -= delta;
				depth = textureLod(texture_depth, ofs,0.0).r;
				current_depth += layer_depth;
			}
			vec2 prev_ofs = ofs + delta;
			float after_depth  = depth - current_depth;
			float before_depth = textureLod(texture_depth, prev_ofs, 0.0).r - current_depth + layer_depth;
			float weight = after_depth / (after_depth - before_depth);
			ofs = mix(ofs,prev_ofs,weight);
			base_uv=ofs;
			base_uv=mix(UV,base_uv,min(pow(4.*tcol_depth_oo,2.),1.));
		}
	}
	float tcol_depth_oo2=tcol_depth_o;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	//vec4 albedo_tex_o = texture(texture_albedo,UV);
	//albedo_tex=mix(albedo_tex_o,albedo_tex,tcol_depth_oo);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * (metallic+tcol_depth_oo);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMALMAP = texture(texture_normal,base_uv).rgb;
	NORMALMAP_DEPTH = normal_scale;
	vec3 emission_tex = texture(texture_emission,base_uv).rgb;
	EMISSION = (emission.rgb+emission_tex)*(emission_energy*(1.-0.65*tcol_depth_oo));
	
	if(tcol_depth_oo>0.){
		vec2 rim_tex = texture(texture_rim,base_uv).yz;
		float tcol_depth=texture(iChannel0,((base_uv)*0.2)).z;
		float otcd=tcol_depth;
		tcol_depth=pow(4.5*tcol_depth,2.);
		tcol_depth=max(1.-tcol_depth,0.);
		if(any(greaterThan((base_uv)*0.2,vec2(1.))))tcol_depth=1.;
		if(any(lessThan((base_uv)*0.2,vec2(0.))))tcol_depth=1.;
		vec3 ec = vec3(02.39,0.52,0.205);
		float tv=smoothstep(0.,5.,mod(TIME,100.))*smoothstep(75.,70.,mod(TIME,100.));
	    ec=mix(ec,vec3(0.2,0.52,01.5),0.1+0.9*tv);
		ec=mix(ec,vec3(0.05,0.1,02.98),0.+0.25*tcol_depth);
		float ttv=smoothstep(1.,4.,base_uv.x*0.2+mod(TIME,10.))*smoothstep(10,6.,base_uv.x*0.2+mod(TIME,10.));
		EMISSION+=(tcol_depth_o)*(vec3(0.85,0.81,0.58)*ttv+(otcd))*6.*pow(rim_tex.y,0.5+8.*(tcol_depth+2.5*(1.-pow(rim_tex.y,2.))))*ec;
		//RIM = rim*rim_tex.x;
		//RIM_TINT = rim_tint*rim_tex.y;
		
		//AO = dot(texture(texture_ambient_occlusion,base_uv),ao_texture_channel);
		//AO_LIGHT_AFFECT = ao_light_affect; //-100
	}
}
