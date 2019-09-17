shader_type particles;
render_mode keep_data,disable_velocity;

uniform int line_size;
uniform float iTime;

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void vertex() {
	if((CUSTOM.w<100.)) 
	{
		uint base_number = NUMBER;
		uint alt_seed = hash(base_number + uint(1+INDEX) + RANDOM_SEED);
		float angle_rand = floor(rand_from_seed(alt_seed)*4.);
		float pi = 3.14159;
		float degree_to_rad = pi / 180.0;
		CUSTOM=vec4(vec3(0),110.);
		TRANSFORM = EMISSION_TRANSFORM;
		vec2 pos=vec2(0.);
		if(line_size>0)pos=vec2(float((INDEX%line_size)),float(INDEX/line_size))-vec2(float(line_size/2)-.5,float(line_size/2)-0.5);
		TRANSFORM[3].xyz=vec3(pos.x*2.,0.,pos.y*2.);
		TRANSFORM[0].xyz *= 1.;
		TRANSFORM[1].xyz *= 1.;
		TRANSFORM[2].xyz *= 1.;
		float rot_v=2.*pi*(angle_rand/4.);
		TRANSFORM = TRANSFORM * mat4(vec4(cos(rot_v), 0.0, -sin(rot_v), 0.0),
		vec4(0.0, 1.0, 0.0, 0.0), vec4(sin(rot_v), 0.0, cos(rot_v), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz);
		TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz);
		TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz);
		//CUSTOM.xyz=TRANSFORM[3].xyz;
	}else{
		//TRANSFORM[3].xyz=CUSTOM.xyz;
	}
}

