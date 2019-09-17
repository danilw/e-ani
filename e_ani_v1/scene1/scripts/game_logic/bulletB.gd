extends Area

var angle=0
var shoot_mov=5.0
var min_mov=0.8
var extra_speed=0
var start_pos=Vector3()
var l_h=Vector3(-0.263,-0.156,0.388)
var aie_e=false
var del_it=false
var is_hit=false
var del_timer=0.0
var once=true
var cfree=false
var no_parts=false
var impulse_power=15.0
var self_dmg=20.0

var start_time=0.0

var aim_point_pos=Vector3()
var start_pos_dir=Vector3()

onready var is_preload=get_node("../").is_preload

func _ready():
	if(is_preload):
		return
	var md = Transform2D()
	md = md.translated(Vector2(l_h.x,l_h.z))
	md = md.rotated(angle)
	get_node("../").translation=start_pos+Vector3(md.get_origin().x,l_h.y,md.get_origin().y)
	get_node("../").visible=true
	
	get_node("../model").rotate_y(-angle)
	var tv=(get_node("../").translation-aim_point_pos).length()
	tv=smoothstep(16.0,3.0,tv)*shoot_mov*1.25
	start_pos_dir = Vector3(0,min(shoot_mov*0.5+tv,10),0)+get_node("../").translation+get_node("../model").transform.basis.z.normalized()*(shoot_mov+extra_speed)*(1.0)
	#get_node("../model").look_at(aim_point_pos, Vector3(0, 1, 0))
	#get_node("../model").rotate_object_local(Vector3(0, 1, 0), deg2rad(180))
	
	connect("body_entered",self,"_on_b2_body_entered")
	
	get_node("../futari/on_hit").visible=!no_parts
	get_node("../futari/f").visible=!no_parts

func imp(body,n):
	if(body is RigidBody):
		if(body.mode==RigidBody.MODE_RIGID):
			var v=1
			if(body.mass<=1):
				v=0.5
			body.apply_impulse(Vector3(),n*impulse_power*min(v*body.mass,2.5))

func _on_b2_body_entered(body):
	if(del_it):
		return
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("chess")||body.is_in_group("Enemy")||body.is_in_group("wall")||body.is_in_group("dyn_obj")):
		body.test_hit(get_node("../").translation,self_dmg)
		imp(body,(-get_node("../").translation+body.translation))
		del_it=true
		is_hit=true
		return
	if(!body.is_in_group("ignore"))&&(!body.is_in_group("player")):
		imp(body,(-get_node("../").translation+body.translation))
		del_it=true
		is_hit=true
		return

func free_shoot():
	cfree=true
	get_node("../").visible=false
	get_node("../").queue_free()

func Spherex(p):
	var s=50
	return p.length()-s

var ltst=true

var last_pstate=false

func _process(delta):
	if(is_preload):
		return
	if(cfree):
		return
	
	if(last_pstate!=get_tree().paused):
		if(get_tree().paused):
			get_node("../futari/f").speed_scale=0.001
			get_node("../futari/on_hit").speed_scale=0.001
			last_pstate=get_tree().paused
			return
		else:
			get_node("../futari/f").speed_scale=1.0
			get_node("../futari/on_hit").speed_scale=1.0
			last_pstate=get_tree().paused
	
	if(get_tree().paused):
		return
	
	if(del_it):
		if(once):
			disconnect("body_entered",self,"_on_b2_body_entered")
			if(is_hit)&&(!no_parts):
				get_node("../futari/on_hit").emitting=true
			get_node("../model/Particles").emitting=false
			get_node("../model/Spatial").get_child(0).emitting=false
			get_node("../model/Spatial").get_child(1).emitting=false
			get_node("../futari/f").emitting=false
			once=false
		del_timer+=delta
		if(del_timer>5):
			free_shoot()
	else:
		var t=max(5.0*(1.0/shoot_mov),0.06)
		if(start_time<4.0)&&(t>start_time)&&(ltst)&&(!aie_e):
			ltst=(get_node("../").translation-aim_point_pos).length()>(0.05)
			if(ltst):
				get_node("../").look_at(start_pos_dir.linear_interpolate(aim_point_pos,smoothstep(0.05,t,start_time)), Vector3(0, 1, 0))
				get_node("../").rotate_object_local(Vector3(0, 1, 0), (-deg2rad(180)+angle))
		var forward_dir = get_node("../model").transform.basis.z.normalized()
		get_node("../").translate(forward_dir * (extra_speed+(min_mov+(shoot_mov-min_mov)*smoothstep(0.5,02.5,start_time))) * delta)
		
		get_node("../model/Spatial").rotate_z(delta*5.0)
		
		if(Spherex(get_node("../").translation+Vector3(-10.0,0.0,0.0))>=1):
			del_it=true
	start_time+=delta
