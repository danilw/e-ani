shader_type canvas_item;
//render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform vec3 iMouse;

//v2
vec4 px(vec2 p){return texture(iChannel0,p);}

void mainImage( out vec4 fragColor, in vec2 fragCoord, vec2 iResolution )
{
    float dx = 1.0/iResolution.x;
    float dy = 1.0/iResolution.y;
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 vel = px(uv).xy;
    vel=(vel-0.5)*100.;
    if(iFrame<=3){
		fragColor=vec4(0.5,0.5,0.,1.);
        return;
    }
    
    float d = px(uv-vel/100.).z;
    d*=3.;
    vec4 ux=px(vec2(uv.x+dx, uv.y));
    vec4 umx=px(vec2(uv.x-dx, uv.y));
    vec4 uy=px(vec2(uv.x, uv.y+dy));
    vec4 umy=px(vec2(uv.x, uv.y-dy));
    ux.xy=(ux.xy-0.5)*2.*100.;ux.z*=3.;umx.xy=(umx.xy-0.5)*2.*100.;umx.z*=3.;
    uy.xy=(uy.xy-0.5)*2.*100.;uy.z*=3.;umy.xy=(umy.xy-0.5)*2.*100.;umy.z*=3.;
    
    //vec2 tv = 0.5-texture(iChannel2,uv*2.).xy;
    //vel += 0.35*tv;

    float pa = -0.6+0.04*d;
    vel.x += -(umx.b-d)*pa;
    vel.x += (ux.b-d)*pa;
    vel.y += -(umy.b-d)*pa;
    vel.y += (uy.b-d)*pa;
    

    //d *= 0.98;//+(0.01*texture(iChannel2,uv).x)*clamp(d,0.0,3.0);
    
	d+=0.53*texture(iChannel1,uv).x;
    
    vel=vel*0.497;
    d=d*0.983;
    d=d/3.;
    vel=(vel/100.)*0.5+0.5;
    fragColor.rg=vel;
    fragColor.b = d;
    fragColor.rgb=clamp(fragColor.rgb,vec3(0.),vec3(1.));
	fragColor.b=max(fragColor.b-0.0015*(1.-smoothstep(0.,0.05,fragColor.b)),0.);
    fragColor.a = 1.;
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}