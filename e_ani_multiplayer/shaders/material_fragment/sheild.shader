shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_disabled,unshaded;
uniform vec4 colorx:hint_color;
uniform vec4 colorx2:hint_color;
uniform vec4 colorx3:hint_color;
uniform sampler2D iChannel0;
uniform float iTime;
uniform float hit_time;
uniform float sstime;
uniform vec3 ppos;
uniform vec3 ppos2;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;

mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(vec2(c,-s),vec2(s,c));}

float hash( float n ){return fract(sin(n)*43758.5453);}

float noise( in vec3 x )
{
    x*=0.01;
	float  z = x.z*256.0;
	vec2 offz = vec2(0.317,0.123);
	vec2 uv1 = x.xy + offz*floor(z); 
	vec2 uv2 = uv1  + offz;
	return mix(textureLod( iChannel0, uv1 ,0.0).x,textureLod( iChannel0, uv2 ,0.0).x,fract(z));
}

//https://www.shadertoy.com/view/XdfXRj
float flow(in vec3 p, in float t)
{
	mat3 m3 = mat3(vec3(0.00,  0.80,  0.60),
              vec3(-0.80,  0.36, -0.48),
              vec3(-0.60, -0.48,  0.64));
	float z=2.;
	float rz = 0.;
	vec3 bp = p;
	for (float i= 1.;i < 5.;i++ )
	{
		p += t*.1;
		rz+= (sin(noise(p+t*0.8)*6.)*0.5+0.5) /z;
		p = mix(bp,p,0.6);
		z *= 2.;
		p *= 2.01;
        p*= m3;
	}
	return rz;	
}

vec4 shield(vec3 rf2, vec3 rf, float time,bool ff,float tv, float eea){
    vec4 col=vec4(0.);
    float nz = (-log(abs(flow(rf*1.2,time)-(.1+0.4*tv))));
    float nz2 = (-log(abs(flow(rf2*1.2,-time)-(.25-0.1*tv))));
    col.rgb += ((0.15+0.55*tv)*nz*nz*(colorx.rgb)*3. + (0.215-0.12*tv)*nz2*nz2*colorx2.rgb*1.6);
	col.rgb = mix(col.rgb,col.brg*3.,eea);
	if(ff)
    return pow(col,vec4(3.));
	else
	return col*colorx3;
}

void fragment() {
	
	vec3 selfpos=((WORLD_MATRIX*vec4(1.0)).xyz);
	vec3 nor=-selfpos+1.+((CAMERA_MATRIX*vec4(VERTEX, 1.0)).xyz);
	float eea=smoothstep(0.5,1.5,length(nor-ppos-vec3(0.5,0.,0.5)));
	float eea2=smoothstep(0.5,1.5,length(nor-ppos2-vec3(0.5,0.,0.5)));
	eea=min(eea,eea2);
	/*float o=2.;
	vec3 rd=-selfpos+1.+((CAMERA_MATRIX*vec4(-o*NORMAL, 1.0)).xyz);
	vec3 ref = reflect(normalize(rd),normalize(nor));*/
	float tv=smoothstep(1.,0.,iTime-hit_time);
	vec3 sh=shield(nor*0.725,-nor*0.87,iTime*(0.22-0.2*smoothstep(2.0,0.5,iTime)),FRONT_FACING,tv,1.-eea).rgb;
	float bg=texture(iChannel1,UV*12.2).r;
	float bg2=smoothstep(0.15,0.3,texture(iChannel2,UV*23.).r);
	//bg2=bg;
	float sc=mix(bg2,bg,max(max(tv,smoothstep(2.,0.5,iTime)),1.-eea));
	sh*=2.*sc;
	float intensity = 0.;
	//if(FRONT_FACING)
	intensity=clamp(1.-pow(0.72 + max(dot(NORMAL, normalize(VIEW)),0.), 01.85),0.,1.);
	ALBEDO=2.*colorx2.rgb*intensity*sc+sh*(1.-intensity);
	//ALPHA=min(dot(ALBEDO*1.,vec3(1.)),1.);
	ALPHA=bg2*smoothstep(0.31,0.45,UV.y);
	ALPHA=max(ALPHA,1.-eea);
	ALPHA=max(smoothstep(0.55,0.4,UV.y)*tv,ALPHA);
	ALPHA=max(ALPHA,smoothstep(2.,0.5,iTime));
	ALPHA*=step(UV.y,0.53);
	
	ALPHA*=smoothstep(0.,1.,sstime);

}