shader_type particles;
render_mode keep_data,disable_velocity;

uniform float iTime;
uniform vec3 h_pos;
uniform vec3 ppos;
uniform vec2 rquad_a;
uniform vec2 rquad_b;

mat2 MD(float a){
	return mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)));
}

float sdPlane(vec3 p, vec4 n) {
    return dot(p, n.xyz) + n.w;
}

void vertex() {
	vec3 spos=vec3(0.,0.972,-6.792);
	float sp_r=1.125;
	float psz=0.12+0.02;
	float ppl=60.;
	float angle=0.;
	float a=1.;
	//if((CUSTOM.w<100.)) 
	{
		float pi = 3.14159;
		float degree_to_rad = pi / 180.0;
		//CUSTOM=vec4(vec3(1),110.);
		TRANSFORM = EMISSION_TRANSFORM;
		vec2 pos=vec2(0.);
		int idx=INDEX;
		float idxf_l=float(idx-int(ppl)*(idx/int(ppl)));
		float idxf_g=float(idx/int(ppl));
		psz*=.55;
		float tsp_r=abs(sin(0.5*pi*((sp_r-abs(idxf_g*psz-sp_r/2.-psz*1.25))/sp_r)));
		vec2 vect=vec2(tsp_r*(sp_r-0.15*CUSTOM.w),0.);
		angle=2.*pi*((idxf_l+.5*float(int(idxf_g)%2))/ppl);
		vect*=MD(angle);
		pos=vect;
		float pz=min(sp_r*sin(0.45*pi*(idxf_g*psz-sp_r/2.)/sp_r),sp_r);
		//idk watizdis(late night)
		float vx=float(int(idxf_l)%2)-float(int(idxf_l)%
		max(max(min(int(0.21*abs(5.5-idxf_g)/3.),1)*3,1),
		max(min(int(0.31*abs(5.5-idxf_g)/5.),1)*5,1)))+10.*(step(.28*abs(5.5-idxf_g),3.));
		a=clamp(vx,0.,1.);
		TRANSFORM[3].xyz=vec3(pos.x-psz/4.,pos.y-1.5*psz,pz+psz*2.);
		TRANSFORM[0].xyz *= 1.;
		TRANSFORM[1].xyz *= 1.;
		TRANSFORM[2].xyz *= 1.;
		//TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
		//TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
		//TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
		
		float rot_v=pi*0.5-2.*pi*((idxf_l+.5*float(int(idxf_g)%2))/ppl);
		TRANSFORM = TRANSFORM * mat4(vec4(0.0, 0.0, 1.0, 0.0),vec4(cos(rot_v), 0.0, -sin(rot_v), 0.0).xzyw,
		vec4(sin(rot_v), 0.0, cos(rot_v), 0.0).xzyw,
		vec4(0.0, 0.0, 0.0, 1.0));
		
		
		rot_v=0.5*pi*(((idxf_g*psz-sp_r/2.-psz*1.25))/sp_r);
		TRANSFORM = TRANSFORM * mat4(vec4(cos(rot_v), 0.0, -sin(rot_v), 0.0),
		vec4(0.0, 1.0, 0.0, 0.0), vec4(sin(rot_v), 0.0, cos(rot_v), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		
	//}else{
		
	}
	float e=smoothstep(0.65,0.1,length((TRANSFORM[3].xyz*vec3(1.,-1.,1.)+spos.xzy)-ppos.xzy));
	CUSTOM.w+=0.23*e;
	CUSTOM.r+=0.4*e;
	float ttv=smoothstep(0.18,0.1,iTime);
	e=smoothstep(0.45,0.3,length((TRANSFORM[3].xyz*vec3(1.,-1.,1.)+spos.xzy)-h_pos.xzy))*ttv;
	CUSTOM.w+=0.35*e;
	CUSTOM.g+=0.5*e;
	a*=max(CUSTOM.w,0.25);
	//a*=smoothstep(0.18,0.2,abs(sdPlane((TRANSFORM[3].xyz*vec3(1.,-1.,1.)),(vec4(rquad_a,rquad_b)-vec4(0.,0.,1.,-0.2)))));
	
	CUSTOM.rg*=0.986;
	CUSTOM.w*=0.984;
	CUSTOM.xyzw=clamp(CUSTOM.xyzw,0.,1.);
	COLOR.rgba=vec4(0.35*(1.-max(CUSTOM.r,CUSTOM.g))+8.*vec3(CUSTOM.g,CUSTOM.r,0.),a);
}

