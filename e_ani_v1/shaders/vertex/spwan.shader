shader_type particles;
render_mode keep_data,disable_velocity;

uniform float iTime;
uniform float t_shift;

float linearstep(float begin, float end, float t) {
    return clamp((t - begin) / (end - begin), 0.0, 1.0);
}

void vertex() {
	float sz=1.35;
	float ssz=0.1;
	float t=iTime;
	//t=mod(TIME,8.);
	t=clamp(t,0.,8.);
	float time_slow=2.;
	float timer=mod(t/time_slow-t_shift*0.5,4.); //0-0.5->0.5-1
	float timer2=linearstep(.0,.5,timer-(2.-0.21*t_shift));
	//if((CUSTOM.w<100.)) 
	{
		float pi = 3.14159;
		float degree_to_rad = pi / 180.0;
		TRANSFORM = EMISSION_TRANSFORM;
		vec2 pos=vec2(0.);
		int idx=INDEX;

		float bidx=float(idx%14)-7.;
		float yidx=float(idx/14);
		
		float animy=smoothstep(0.+bidx+7.-(bidx+7.)/1.33,1.+bidx+7.-(+bidx+7.)/1.33,(timer)*6.5)*2.6-2.6;
		
		pos.x=bidx*ssz;
		pos.y=0.+animy;
		TRANSFORM[3].xyz=vec3(pos.x+0.1,pos.y-1.3+0.26+0.26*yidx,0.+sz/2.+0.05);
		TRANSFORM[0].xyz *= 1.;
		TRANSFORM[1].xyz *= 1.;
		TRANSFORM[2].xyz *= 1.;
		CUSTOM.x=TRANSFORM[3].y-0.26*yidx;
		CUSTOM.y=TRANSFORM[3].y+1.3-0.26;
		//TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
		//TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
		//TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
		float tid=float(10-idx/14+int((bidx+7.)));
		COLOR.a=smoothstep(0.,2.,tid-25.*timer2+1.);
		
	//}else{
		
	}
	//COLOR.rgba=vec4(1.);
}

