shader_type canvas_item;
//render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform vec3 player_pos;
uniform vec3 iMouse;


//vec3 windvel = vec3(0.01,0.0,-0.005);
//const float gravity = 0.0022;

vec3 getpos(vec2 uv)
{
	vec2 iResolution=vec2(260.,132.+80.);
	return (texture(iChannel0,min(vec2(uv+0.05)/iResolution,vec2(1.))).xyz);
	return (texelFetch(iChannel0,min(ivec2(uv+0.01),ivec2(vec2(iResolution))),0).xyz);
}
vec3 getvel(vec2 uv)
{
	float SIZX=130.0;
	float SIZY=130.0+80.;
	vec2 iResolution=vec2(260.,132.+80.);
	return (texture(iChannel0,min(vec2(uv+0.5+vec2(SIZX,0.0))/iResolution,vec2(.995))).xyz);
	return (texelFetch(iChannel0,min(ivec2(uv+0.01+vec2(SIZX,0.0)),ivec2(iResolution)),0).xyz);
}

void edge(vec2 dif, vec2 c, vec3 pos, vec3 ovel, inout vec3 vel)
{
	float SIZX=130.0;
	float SIZY=130.0+80.;
    if ( 
        (dif+c).x>=0.0 && (dif+c).x<SIZX &&
        (dif+c).y>=0.0 && (dif+c).y<SIZY
	)
    {
        float edgelen = length(dif);
        vec3 posdif = getpos(dif+c)-pos;
        vec3 veldif = getvel(dif+c)-ovel;
        vel += normalize(posdif)*(clamp(length(posdif)-edgelen,-1.0,1.0)*0.15); // spring
        vel +=normalize(posdif)*( dot(normalize(posdif),veldif)*0.10); // damper
    }
}

vec3 findnormal(vec2 c)
{
    return normalize(cross(  getpos(c-vec2(1.0,0.0))-getpos(c+vec2(1.0,0.0)) ,
	  getpos(c-vec2(0.0,1.0))-getpos(c+vec2(0.0,1.0)) ));
}

vec3 ballpos(int id)
{
	if(id==0)
    return vec3(-3.,40.-106.+212./2.,0.);
	if(id==1)
    return vec3(-3.,245.-106.+212./2.,0.);
	if(id==2)
    return vec3(-3.,140.-106.+212./2.,0.);
	if(id==3)
    return vec3(60.,250.-106.+212./2.,-15.)+player_pos.zyx*vec3(-1.,-1.,1.);//player_pos;
	
	return vec3(1000.);
	
}

void ballcollis(float t, vec3 pos, inout vec3 vel)
{
	int nb=4;
	for(int i=0;i<nb;i++){
    float ballradius = 64.0*0.32;
	if(i==3)ballradius=64.0*0.7;
    vec3 ballpos2 = ballpos(i);
    if ( length(pos-ballpos2)<ballradius)
    {
        vel -= normalize(pos-ballpos2)*dot(normalize(pos-ballpos2),vel);
        vel += (normalize(pos-ballpos2)*ballradius+ballpos2-pos);
    }
	}
	vel=clamp(vel,vec3(-1.),vec3(1.));
                        
}

vec3 windx(){
	vec3 w=vec3(0.);
	w.x=0.0025+0.25*smoothstep(3.,9.,mod(iTime,30.))*smoothstep(9.,12.,mod(iTime,30.))*(0.5-smoothstep(12.,10.,mod(iTime,20.))*smoothstep(2.5,5.,mod(iTime,20.)));
	w.z=0.015+0.36*smoothstep(0.,15.,mod(iTime,30.))*smoothstep(45.,38.,mod(iTime,48.))*(0.5-smoothstep(38.,36.,mod(iTime,48.))*smoothstep(2.5,5.,mod(iTime,48.)));
	//w.xz*=smoothstep(0.,5.,mod(iTime,115.))*smoothstep(75.,70.,mod(iTime,115.));
	w.y=0.108;
	return w*1.2;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord)
{
	vec2 iResolution=vec2(260.,132.+80.);
float gravity = 0.0013;
vec3 windvel = windx();
	float SIZX=130.0;
	float SIZY=130.0+80.;
    float t = iTime;
    
    fragColor=vec4(0.0);
    vec2 fc = fragCoord+0.1;
    fc-=fract(fc);
	
	fragColor=vec4(0.,0.,0.,1.);
    if (fc.y>=SIZY+2.0 || fc.x>=SIZX*2.0) return;
    
    vec2 c = fc;
    c.x = fract(c.x/SIZX)*SIZX;

    vec3 pos = getpos(c);
    vec3 vel = getvel(c);
	vec3 ovel = vel;
    edge(vec2(0.0,1.0),c,pos,ovel,vel);
    edge(vec2(0.0,-1.0),c,pos,ovel,vel);
    edge(vec2(1.0,0.0),c,pos,ovel,vel);
    edge(vec2(-1.0,0.0),c,pos,ovel,vel);
    edge(vec2(1.0,1.0),c,pos,ovel,vel);
    edge(vec2(-1.0,-1.0),c,pos,ovel,vel);

    edge(vec2(0.0,2.0),c,pos,ovel,vel);
    edge(vec2(0.0,-2.0),c,pos,ovel,vel);
    edge(vec2(2.0,0.0),c,pos,ovel,vel);
    edge(vec2(-2.0,0.0),c,pos,ovel,vel);
    edge(vec2(2.0,-2.0),c,pos,ovel,vel);
    edge(vec2(-2.0,2.0),c,pos,ovel,vel);
    ballcollis(t,pos,vel);
    
	pos += vel;
    vel.y += gravity+smoothstep(0.4,0.9,c.y/iResolution.y)*gravity*3.; //grav+mass
	vec3 norm = findnormal(c);
    vel -= norm * (dot(norm,vel-windvel)*0.15 );
    
    if (iFrame<=10 || c.y<=1.0) // init
    {
        pos = vec3(fc.x*0.86,fc.y,fc.y*0.01);
        vel = vec3(0.0,0.0,0.0);
    }
    vel=clamp(vel,vec3(-1.),vec3(1.));
    fragColor = vec4(fc.x>=SIZX ? vel : pos,1.0);
    
}

void fragment(){
	vec2 iResolution=vec2(260.,132.+80.);
	//vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,floor(UV*iResolution));
}