shader_type particles;
render_mode keep_data,disable_velocity;

uniform float iTime;
uniform vec3 h_pos;
uniform vec3 ppos;
uniform bool rest;
uniform float r_speed;
uniform float ftime;

mat2 MD(float a){
	return mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)));
}

float linearstep(float begin, float end, float t) {
    return clamp((t - begin) / (end - begin), 0.0, 1.0);
}

void vertex() {
	float sp_r=1.3;
	float psz=0.12;
	float ppl=60.;
	vec3 spos=vec3(0.,0.972,-6.792);
	vec2 vect=vec2(sp_r-0.27*CUSTOM.w,0.);
	float angle=0.;
	float a=1.;
	float ea=1.;
	//if((CUSTOM.w<100.)) 
	{
		float pi = 3.14159;
		float degree_to_rad = pi / 180.0;
		//CUSTOM=vec4(vec4(0));
		TRANSFORM = EMISSION_TRANSFORM;
		vec2 pos=vec2(0.);
		int idx=INDEX;
		float idxf_g=float(idx/int(ppl));
		ea*=clamp(idxf_g-floor(22.*linearstep(2.5,.0,ftime)),0.,1.);
		float idxf_l=float(idx-int(ppl)*(idx/int(ppl)))+CUSTOM.z*(1.-2.*float(int(idxf_g)%2));
		angle=2.*pi*(idxf_l/ppl);
		vect*=MD(angle);
		pos=vect;
		float pz=idxf_g*psz-sp_r/2.;
		//pos.x=(float(idx))*0.2;
		//pos.y=0.;
		TRANSFORM[3].xyz=vec3(pos.x,pos.y+-psz/2.,pz-psz*2.);
		TRANSFORM[0].xyz *= 1.;
		TRANSFORM[1].xyz *= 1.;
		TRANSFORM[2].xyz *= 1.;
		//TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
		//TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
		//TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
		
		float rot_v=pi*0.5-2.*pi*(idxf_l/ppl);
		TRANSFORM = TRANSFORM * mat4(vec4(0.0, 0.0, 1.0, 0.0),vec4(cos(rot_v), 0.0, -sin(rot_v), 0.0).xzyw,
		vec4(sin(rot_v), 0.0, cos(rot_v), 0.0).xzyw,
		vec4(0.0, 0.0, 0.0, 1.0));
		
	//}else{
		
	}
	CUSTOM.z+=r_speed*1./ppl*(linearstep(2.5,4.,ftime));
	//CUSTOM.z=fract(CUSTOM.z);
	
	float e=smoothstep(0.65,0.1,length((TRANSFORM[3].xyz*vec3(1.,-1.,1.)+spos.xzy)-ppos.xzy));
	CUSTOM.w+=0.23*e;
	CUSTOM.r+=0.4*e;
	float ttv=smoothstep(0.18,0.1,iTime);
	e=smoothstep(0.55,0.3,length((TRANSFORM[3].xyz*vec3(1.,-1.,1.)+spos.xzy)-h_pos.xzy))*ttv;
	CUSTOM.w+=0.35*e;
	CUSTOM.g+=0.5*e;
	a*=max(CUSTOM.w,0.25);
	
	CUSTOM.rg*=0.996;
	CUSTOM.w*=0.984+0.014*min(r_speed/3.0,1.);
	CUSTOM.xyw=clamp(CUSTOM.xyw,0.,1.);
	
	if(rest)CUSTOM=vec4(0.);
	
	COLOR.rgba=vec4(0.65*(0.2+0.8*(1.-max(CUSTOM.r,CUSTOM.g)))+8.*vec3(CUSTOM.g,CUSTOM.r,0.),a*ea);
}

