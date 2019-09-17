extends Camera

onready var global_v=get_tree().get_root().get_node("scene")


var smoothrot=180
var smoothrota=0
var tsa=0
var base_rot=Vector3()
var smoothroty=0
var a_rot=0.0
var e_rot=0.0

const emr=25
const amr=35

func _ready():
	base_rot.x=self.rotation_degrees.x
	self.environment=load("res://default_env.tres") as Environment #to avoid bug
	self.translation=global_v.player_pos+Vector3(0.0,1.2,-1.5)

# DO NOT USE THIS
# use linear_interpolate https://docs.godotengine.org/en/3.1/tutorials/math/interpolation.html
# my logic come from GLSL ray-tracer camera logic (I keep it as anti copypasta.................(no im lazy to remake it xD))
# look right way in bot_hit.gd (upd_rot) as example

func _process(delta):
	var a=-max(-sign(global_v.player_rot),0)*360
	var a2=Vector2()
	a2=global_v.player_rot
	if(smoothrot<=-360):
		smoothrot=0
	if(smoothrot>=360):
		smoothrot=0
	if(smoothrot<-270)&&(global_v.player_rot<0):
		a2+=-720
	elif(smoothrot>270)&&(global_v.player_rot>0):
		a2+=360
	elif(smoothrot<50)&&(global_v.player_rot<0)||(smoothrot<-50)&&(global_v.player_rot>0):
		a2+=-360
	smoothrot+=-(a+smoothrot-a2)*delta*1.5
	var md = Transform2D()
	md = md.rotated(-deg2rad(smoothrot))
	md = md.translated(Vector2(0.0,-1.5))
	self.translation=Vector3(global_v.player_pos.x,global_v.player_pos.y*(0.4+0.6*smoothstep(0.5,3.0,-(global_v.player_pos.y-1.8))),global_v.player_pos.z)+Vector3(md.get_origin().x,1.8,md.get_origin().y)
	var r=180+self.rotation_degrees.y-smoothrot
	r=r-(int(r)/360)*360
	if ((!global_v.mouse_aim_e&&global_v.mouse_aim_ee)||global_v.mouse_aim_ee)&&(Input.is_mouse_button_pressed(BUTTON_RIGHT)||Input.is_mouse_button_pressed(BUTTON_LEFT)):
		var v=((global_v.iMouse.x/global_v.iResolution.x-0.5)*40.0*delta*max(global_v.iMouse_d.x,global_v.iMouse_d.y))
		a_rot+=v*smoothstep(amr,amr-10.0,sign(v)*sign(a_rot)*abs(a_rot))
		a_rot=clamp(a_rot,-amr,amr)
	else:
		var atx=sign(a_rot)
		a_rot+=-(a_rot*(1.0+1.0*smoothstep(amr-10.0,amr,amr-abs(a_rot))))*delta*(1.0-max(global_v.iMouse_d.x,global_v.iMouse_d.y))
		if(atx!=sign(a_rot)):
			a_rot=0.0
	smoothrota=(((base_rot.y-tsa+a_rot)))
	tsa+=smoothrota
	self.rotate_y(-deg2rad(r+tsa))
	
	if ((!global_v.mouse_aim_e&&global_v.mouse_aim_ee)||global_v.mouse_aim_ee)&&(Input.is_mouse_button_pressed(BUTTON_RIGHT)||Input.is_mouse_button_pressed(BUTTON_LEFT)):
		var v=(global_v.iMouse.y/global_v.iResolution.y-0.5)*40.0*delta*max(global_v.iMouse_d.x,global_v.iMouse_d.y)
		e_rot+=v*smoothstep(emr,emr-10.0,sign(v)*sign(e_rot)*abs(e_rot))
		e_rot=clamp(e_rot,-emr,emr)
	else:
		var atx=sign(e_rot)
		e_rot+=-(e_rot*(1.0+1.0*smoothstep(emr-10.0,emr,emr-abs(e_rot))))*delta*(1.0-max(global_v.iMouse_d.x,global_v.iMouse_d.y))
		if(atx!=sign(e_rot)):
			e_rot=0.0
	smoothroty=(deg2rad((base_rot.x-self.rotation_degrees.x+e_rot)))
	self.rotation.x+=smoothroty

func _physics_process(delta):
	if(global_v.game_over):
		return
	test_mouse()

const ray_length = 100
const collision_mask=525313
func test_mouse():
	if (!global_v.mouse_aim_e)&&(Input.is_mouse_button_pressed(BUTTON_RIGHT)||Input.is_mouse_button_pressed(BUTTON_LEFT)):
		var mouse_local=Vector2()
		mouse_local.x=global_v.iMouse.x
		mouse_local.y=global_v.iResolution.y-global_v.iMouse.y
		var camera = self
		var ray_from = camera.project_ray_origin(mouse_local)
		var ray_to = ray_from + camera.project_ray_normal(mouse_local) * ray_length
		var space_state = get_world().direct_space_state
		var selection = space_state.intersect_ray(ray_from, ray_to, [self,global_v.get_node("main_player")], collision_mask)
		if(selection):
			global_v.iMouse_3d=selection.position
			global_v.iMouse_3d_normal=selection.normal
	
