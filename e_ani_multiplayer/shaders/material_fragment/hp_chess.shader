shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform float value:hint_range(0,1);
uniform sampler2D hp_bar:hint_albedo;


void vertex() {
	UV=UV;
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],WORLD_MATRIX[1],vec4(normalize(cross(CAMERA_MATRIX[0].xyz,WORLD_MATRIX[1].xyz)), 0.0),WORLD_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0),vec4(0.0, 1.0/length(WORLD_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0 ,1.0));
}

vec4 mainImage(vec2 p){
	vec4 col=vec4(vec3(0.),1.);
	vec2 uv=p;
	float il=(32./256.);
	uv.x+=-0.5;
	if(abs(uv.x)>il/2.)return vec4(0.);
	
	vec4 col_b=texture(hp_bar,vec2(uv.x+il/2.,uv.y));
	col=texture(hp_bar,vec2(uv.x+il+il/2.,uv.y));
	col*=smoothstep(value+0.01,value-0.01,1.-uv.y);
	col.rgb*=5.;
	col=mix(col,col_b,col_b.a);
	col.rgb=vec3(col.r);
	return col;
}


void fragment() {
	vec4 c=mainImage(UV);
	ALBEDO =c.rgb;
	ALPHA=c.a;
}
