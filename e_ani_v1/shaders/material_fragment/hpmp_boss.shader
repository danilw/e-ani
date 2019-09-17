shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform int value;
uniform int len;
uniform bool mm;
uniform sampler2D iChannel3;
uniform vec4 ex_col:hint_color;


void vertex() {
	UV=UV;
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],WORLD_MATRIX[1],vec4(normalize(cross(CAMERA_MATRIX[0].xyz,WORLD_MATRIX[1].xyz)), 0.0),WORLD_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0),vec4(0.0, 1.0/length(WORLD_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0 ,1.0));
}

//https://www.shadertoy.com/view/tsdGzN

void C(inout vec2 U, inout vec4 T, in int c){
    U.x+=.5;
    if(U.x<.0||U.x>1.||U.y<0.||U.y>1. ){
        T+= vec4(0);
    }
    else{
		vec2 tu=U/16. + fract( vec2(float(c), float(15-c/16)) / 16.);
		tu.y=1.-tu.y;
        T+= textureGrad( iChannel3,tu, dFdx(tu/16.),dFdy(tu/16.));
    }
}

// X dig max
float print_int(vec2 U, int val) {
    vec4 T = vec4(0);
    int cval=val;
    int X=7;
	if(mm)C(U,T,77);
    for(int i=0;i<X;i++){
    if(cval>0){
        int tv=cval%10;
        C(U,T,48+tv);
        cval=cval/10;
    }
    else{
        if(length(T.yz)==0.)
            return -1.;
        else return T.x;
    }
    }
    if(length(T.yz)==0.)
        return -1.;
    else return T.x;
}

void mainImage( out vec4 fragColor, in vec2 p ) {
    vec2 res=vec2(4.,1.);
	vec2 uv=p;
	uv.y=1.-uv.y;
	int a=0;
	if(mm)a=-1;
	vec2 epos=vec2(-0.12*float(len+a),0.25);
    float c=print_int((uv*res-res/2.+epos)*2.,value);
	c=clamp(c,0.,1.);
    fragColor=vec4(c)*ex_col*3.;

}		


void fragment() {
	vec4 c=vec4(0.);
	mainImage(c,UV);
	ALBEDO =c.rgb;
	ALPHA=c.a;
}
