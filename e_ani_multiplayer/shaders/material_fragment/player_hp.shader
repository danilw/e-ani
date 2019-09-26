shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_back,unshaded;

uniform float HP_val;

vec4 mi(in vec2 uv_i )
{
	float PI=3.1415926;
    vec2 p = (uv_i-0.5)*2.;
	p=-p;
    float a = atan(p.x,p.y);
    float r = length(p)*0.75;
    vec2 uv = vec2(2.*(a/PI),r);
    
 	uv = (2.0 * uv) - 1.0;
    float segm=mod((abs(uv.x-20.5))*6.,2.)*(mod((uv.x+20.5)*6.,2.));
	vec3 hc = vec3(0.125, 0.125, 0.125);
	float segm2=mod((uv.x+.5)*1.,24.); 
    float val=floor(HP_val);
    //segm2=floor(((segm2>4.)?((segm2<19.)?4.:segm2-16.):segm2)*3.); //godot bug
	
	if(segm2>4.){
    if(segm2<19.){
            segm2=4.;
        }
        else segm2=segm2-16.;
    }else segm2=segm2;
    segm2*=3.;
	 
    if(segm2<val+1.)
    {
        hc=vec3(1.-segm2/20.,segm2/20.,0.);
    }
   	float bw = min(15.8,(1.2) * abs(1.0 / (25.0 * uv.y)));

    vec3 col=bw*hc*vec3(smoothstep(-0.215,-0.1,uv.y-0.15)*smoothstep(0.315,-0.1,uv.y-0.15)*segm);
    
	//col=vec3(sin(uv),0.);
    return vec4(1.*col,1.0);
}

void fragment() {
	ALBEDO = vec3(0.);
	ALBEDO=mi(UV).rgb;
	ALPHA=1.;

}