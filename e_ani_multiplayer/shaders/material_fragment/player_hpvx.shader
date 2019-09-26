shader_type canvas_item;
//render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform float hp_val;
uniform float a_timer;
uniform float b_timer;
uniform float hit_time;
uniform float heal_time;

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
}

float grid(vec2 p){
    float g = 0.5-max(abs(mod(p.x*64.0,1.0)-0.5), abs(mod(p.y*64.0,1.0)-0.5));
    g=0.05+smoothstep(0.0,64.0 / 600.,g)*0.65;
    return g;
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float pp_noise(vec2 p){
    float rnd = rand(p);
    return 0.6+0.5*rnd;
}

vec2 p_bar(vec2 p,float idx){
    p.x+=-0.5*p.y;
    
    p*=30.;
    float id=floor(p.x)+6.;
    p.x=fract(p.x)-0.5;
    
    float d=sdBox(p,vec2(0.3,0.8));
    d=smoothstep(0.1,0.01,d);
    float td=d*step(0.,id)*step(id,11.);
    d*=step(idx,id)*step(id,11.);
    return vec2(d,td);
}

float line_xx(vec2 p, float v){
	p.x=-p.x;
    float idx=floor(p.x*28.+0.5);
	idx+=6.;
    float bx=step(abs(idx-6.),6.);
    p.x=fract(p.x*28.+0.5);
    float d=step(abs(p.y),0.005);
    d*=step(p.x,0.9)*step(idx,v);
    d*=bx;
    return d;
}

vec4 holder_bg(vec2 p){
    //p+=vec2(-0.45,-0.25);
	vec2 op=p;
	p*=.14;
    vec3 bc=vec3(0.,0.,0.);
    vec3 bc2=vec3(0.8,0.964705,0.972549);
	bc2=mix(bc2,vec3(1.2,0.2,0.2),smoothstep(0.6,0.,iTime-hit_time));
	bc2=mix(bc2,vec3(0.2,1.2,0.2),smoothstep(0.8,0.,iTime-heal_time));
    vec3 col=vec3(0.);
    float d=0.;
    float gridx=grid(p);
    float td=sdBox(p,vec2(0.2,0.005));
    d=max(d,smoothstep(0.05,-0.01,td-0.0085));
    d*=gridx*0.85;
    col=bc*d;
    td=sdBox(p,vec2(0.2,0.015));
    float d2=smoothstep(0.015,0.01,td)*smoothstep(0.005,0.01,td);
    //d*=pp_noise(op);
    d=max(d,d2);
    col+=d2*bc2;
    vec2 dx=p_bar(p,12.-hp_val);
    td=dx.x*smoothstep(0.015,0.01,td);
    col=max(td*bc2,col);
    d=max(d+(1.-d2)*dx.y*0.2,td);
	d=clamp(d,0.,1.);
	float bg=line_xx(p+vec2(0.,0.05),12.)*0.35;
	vec3 hc=1.5*vec3(0.8,0.3,0.1)*line_xx(p+vec2(0.,0.05),12.*a_timer);
    d=max(d,bg);
	bg=line_xx(p+vec2(0.,0.062),12.)*0.35;
	vec3 mc=1.5*vec3(0.1,0.5,0.8)*line_xx(p+vec2(0.,0.062),12.*b_timer);
    d=max(d,bg);
    return vec4(col+hc+mc,d*0.6);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord , vec2 iResolution)
{
    vec2 uv = (fragCoord.xy) / iResolution.y - (iResolution/iResolution.y)/2.0;
	uv.y=-uv.y;
    
    vec4 col = holder_bg(uv);
    
    //col*=pp_noise(uv);
    
    fragColor = vec4(col);
}

void fragment(){
	vec2 iResolution=vec2(411.,77.);
	mainImage(COLOR,UV*iResolution,iResolution);
}