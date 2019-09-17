shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_disabled,diffuse_lambert_wrap,specular_schlick_ggx;

uniform vec4 ex_color : hint_color;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1:hint_albedo;
uniform float iTime;

vec3 getpos(vec2 uv)
{
	vec2 iResolution=vec2(130.,130.+80.);
	//uv.x=max(uv.x,2./iResolution.x);
	
	return ((texture(iChannel0,vec2(uv+0.001)*vec2(0.495,1.)).xyz-vec3(50.45,iResolution.y/2.,0.5))*vec3(2.,-2.6,2.))/vec3(iResolution.xy,iResolution.y);
	//return ((texelFetch(iChannel0,ivec2(uv*iResolution.xy+0.1),0).xyz-vec3(50.45,iResolution.y/2.,0.5))*vec3(2.,-2.6,2.))/vec3(iResolution.xy,iResolution.y);

	
    //return ((texelFetch(iChannel0,ivec2(uv*iResolution.xy+0.1),0).xyz-vec3(0.45,0.6-0.25,0.5))*vec3(4.,-2.6,2.)*2.);
}

void vertex() {
	
	//vec2 uv=(VERTEX.xz+01.)*.5;
	//uv=clamp(uv,vec2(0.),vec2(1.));
	vec2 uv=UV;
	VERTEX.xyz=0.6*getpos(uv).yzx;
}
/*
float glow(float x, float str, float dist){
    return dist / pow(x, str);
}

float sinSDF(vec2 st, float A, float offset, float f, float phi){
    return abs((st.y - offset) + sin(st.x * f + phi) * A);
}

vec4 mainImage(in vec2 uv, vec3 color)
{
	//float a=(3.14159/20.-.85*uv.y*uv.x);
    //vec2 st = (uv-0.5)*mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)))+0.5;
	vec2 st=(uv-vec2(0.25,0.))*vec2(2.,1.);
    float col = 0.0;
    float time = iTime/5.0;
    float str = 0.6;
    float dist = 0.02;
    float nSin = 4.0;
  
    
    float timeHalfInv = -time * sign(st.x-0.5);
    float am = cos(st.x*3.0);
    float offset = 0.5+sin(st.x*12.0+time)*am*0.05;
    for(float i = 0.0; i<nSin ; i++){
        col += glow(sinSDF(st, am*(0.1+0.3*max(sin(iTime*0.05),0.)), offset, 6.0, timeHalfInv+i*2.0*3.14159/nSin), str, dist);
    }
    
    vec3 s = 0.05*cos( 6.*st.y*vec3(1,2,3) - iTime*0.25*vec3(1,-1,1) ) * 0.5;
    float cut = (01.5+1.*sin(iTime*0.05))*st.x+ (s.x+s.y+s.z) / .50;
	float ct=smoothstep(-0.01,-0.03,0.5-cut);
    col = abs(ct - clamp(col,0.0,1.0));
	col+=5.*pow(col*(1.-ct),3.);
	col+=col*2.5*pow(ct,3.);
	//float al=smoothstep(0.5,0.47,(uv.x-0.5))*smoothstep(0.5,0.47,abs(uv.y-0.5));
	float al=1.;
    return vec4(vec3(col)*color,al);

}
*/
void fragment() {
	METALLIC = 0.;
	ROUGHNESS = 1.;
	SPECULAR = 0.;
	//vec4 col=mainImage(UV.yx,ex_color.rgb);
	//ALBEDO=col.rgb;
	ALBEDO=texture(iChannel1,UV.yx).rgb*ex_color.rgb*5.;
	ALPHA=1.;
}
