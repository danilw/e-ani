extends RigidBody

onready var global_v=get_tree().get_root().get_node("scene")
onready var is_preload=get_node("../").is_preload
onready var pos=get_node("../").pos

onready var sh=get_node("sh/s")
onready var p1=get_node("parts/p1")

var is_alive=true
var is_anim_end=false
var timer=0.0
var hit_time=-10.0
var e_time=-10
var start_pos=Vector3()
var last_pos=Vector3()

onready var hpx=6+get_node("../").extra_hp
onready var bonus_in=get_node("../").bonus_in

const parts_t=5

onready var last_hp=6
var self_speed=0.0

var tplayer_pos=Vector2()
var pl_rot=0.0

func _ready():
	if(is_preload):
		return
	self.translation=pos
	tplayer_pos=Vector2(self.translation.x,self.translation.z+1)
	last_pos=self.translation
	start_pos=self.translation+Vector3(0.0,01.0,0.0)
	sh.set_surface_material(0,get_node("sh/s").get_surface_material(0).duplicate())
	sh.visible=false
	for a in range(get_node("parts").get_child_count()):
		get_node("parts").get_child(a).emitting=false
	if !is_network_master():
		self.mode=RigidBody.MODE_KINEMATIC

func spwn_bonus(bonus_idsl):
	if(bonus_in==null):
		return
	bonus_in.translation=self.translation
	bonus_in.no_parts=global_v.no_parts
	var tss=Node.new()
	tss.name="cont"+str(bonus_idsl)
	tss.add_child(bonus_in,true)
	global_v.get_node("bonus_container").call_deferred("add_child",tss,true)

remotesync func hit(dmg,pos,bonus_idsl):
	if(!is_alive):
		return
	#hpx+=-dmg
	hpx+=-1
	hpx=max(hpx,0)
	is_alive=!(int(hpx)==0)
	if(!is_alive):
		self.mode=RigidBody.MODE_KINEMATIC
		get_node("CollisionShape").disabled=true
		get_node("CollisionShape2").disabled=true
		e_time=timer
		global_v.alive_en+=-1
		spwn_bonus(bonus_idsl)
	hit_time=timer

func test_hit(pos, dmg):
	if(is_anim_end):
		rpc("hit",dmg,pos,global_v.bonus_ids)
		global_v.bonus_ids+=1
		global_v.bonus_ids=global_v.bonus_ids

var cfree=false
remotesync func free_it():
	if is_network_master():
		print("debug del host: "+get_node("../../").name)
	else:
		print("debug del client: "+get_node("../../").name)
	cfree=true
	get_node("../").visible=false
	get_node("../../").queue_free()

var aendo=false
remotesync func anim_endo():
	if(aendo):
		return
	aendo=true
	sh.visible=true
	for a in range(get_node("parts").get_child_count()):
		get_node("parts").get_child(a).emitting=true

# antifall
func Spherex(p):
	var s=50
	return p.length()-s

func angle2d(c,e):
	var theta = atan2(e.y-c.y, e.x-c.x)
	return theta

var is_mov=false

func upd_proc_rot(delta):
	var a=Vector2(self.translation.x,self.translation.z)
	var b=Vector2(global_v.player_pos.x,global_v.player_pos.z)
	var c=Vector2(global_v.player_pos2.x,global_v.player_pos2.z)
	if((((a-b)).length())>(((a-c)).length())):
		b=c
	else:
		b=b
	is_mov=((a-b)).length()>3
	
	#if(is_mov):
	var m_pow=min(((a-b).length()-3)/8,1)
	tplayer_pos=tplayer_pos.linear_interpolate(b, delta*(max(0.1,0.4*m_pow)))
	
	self_speed=(self.translation-last_pos).length()*(1.0/max(delta,0.001))
	pl_rot=angle2d(Vector2(),a-tplayer_pos)
	get_node("sh").rotation.y=-self.rotation.y
	last_pos=self.translation

puppet func update_tranform(transformx):
	self.transform=transformx
	get_node("sh").rotation.y=-self.rotation.y

puppet func update_a(a):
	get_node("parts").get_child(a).emitting=false

puppet func update_b(svx,tr):
	get_node("e").visible=true
	get_node("e").scale=svx
	get_node("bot_holder").transform=tr

puppet func update_timers(is_alivem,timerm,e_timem,hit_timem,col):
	if(is_alivem):
		sh.get_surface_material(0).set("shader_param/iTime",timerm)
		sh.get_surface_material(0).set("shader_param/sstime",smoothstep(0,1,timerm))
	else:
		sh.get_surface_material(0).set("shader_param/iTime",e_timem)
		sh.get_surface_material(0).set("shader_param/sstime",smoothstep(0,1,1-(timerm-e_timem)))
	sh.get_surface_material(0).set("shader_param/hit_time",hit_timem)
	sh.get_surface_material(0).set("shader_param/ppos",global_v.player_pos-(self.translation)) #-0.02x
	sh.get_surface_material(0).set("shader_param/ppos2",global_v.player_pos2-(self.translation))
	sh.get_surface_material(0).set("shader_param/colorx",col)

var rest_k=true
func _process(delta):
	if !is_network_master():
		return
	if(is_preload):
		return
	if(cfree):
		return
	if(rest_k)&&(is_anim_end):
		rest_k=false
		self.mode=RigidBody.MODE_RIGID
	if(Spherex(self.translation+Vector3(-10.0,0.0,0.0))>1):
		self.mode=RigidBody.MODE_KINEMATIC
		rest_k=true
		self.translation=start_pos
	if(is_anim_end):
		rpc("anim_endo")
		timer+=delta
	if(is_alive):
		sh.get_surface_material(0).set("shader_param/iTime",timer)
		sh.get_surface_material(0).set("shader_param/sstime",smoothstep(0,1,timer))
	else:
		sh.get_surface_material(0).set("shader_param/iTime",e_time)
		sh.get_surface_material(0).set("shader_param/sstime",smoothstep(0,1,1-(timer-e_time)))
	sh.get_surface_material(0).set("shader_param/hit_time",hit_time)
	sh.get_surface_material(0).set("shader_param/ppos",global_v.player_pos-(self.translation))
	sh.get_surface_material(0).set("shader_param/ppos2",global_v.player_pos2-(self.translation))
	
	if(!rest_k):
		upd_proc_rot(delta)
	
	var col
	if(hpx>=6):
		sh.get_surface_material(0).set("shader_param/colorx",Color("193f40"))
		col=Color("193f40")
	else:
		sh.get_surface_material(0).set("shader_param/colorx",Color("30130c"))
		col=Color("30130c")
	
	
	if(hpx<last_hp):
		if(hpx<6):
			for a in range(last_hp-hpx):
				get_node("parts").get_child(hpx+a).emitting=false
				rpc("update_a",hpx+a)
	
	if(!is_alive):
		get_node("e").visible=true
		var sv=0.05+0.95*smoothstep(1,2,timer-e_time)*smoothstep(6,5,timer-e_time)
		get_node("e").scale=Vector3(sv,sv,sv)*0.5
		get_node("bot_holder").translation.y+=-delta*2*smoothstep(2,4,timer-e_time)*smoothstep(4.5,4,timer-e_time)
		rpc("update_b",Vector3(sv,sv,sv)*0.5,get_node("bot_holder").transform)
		if(timer-e_time>8+parts_t):
			rpc("free_it")
	
	rpc("update_tranform",self.transform)
	rpc("update_timers",is_alive,timer,e_time,hit_time,col)

func look_follow(state, current_transform, target_position, andlex):
	var up_dir = Vector3(0, 1, 0)
	var cur_dir = current_transform.basis.xform(Vector3(0, 0, 1))
	var target_dir = (target_position - current_transform.origin).normalized()
	var rotation_angle = 0
	if(andlex<=0):
		andlex=abs(andlex)
		if(andlex>PI-PI/6):
			rotation_angle = (asin(cur_dir.z) - asin(target_dir.z))
		elif(andlex<PI/6):
			rotation_angle = (acos(cur_dir.z) - acos(target_dir.z))
		else:
			rotation_angle = (acos(cur_dir.x) - acos(target_dir.x))
	else:
		if(andlex>PI-PI/6):
			rotation_angle = (asin(cur_dir.z) - asin(target_dir.z))
		elif(andlex<PI/6):
			rotation_angle = (acos(cur_dir.z) - acos(target_dir.z))
		else:
			rotation_angle = (asin(cur_dir.x) - asin(target_dir.x))
	state.set_angular_velocity(up_dir * (rotation_angle / state.get_step()))

func upd_forces_rot(state):
	look_follow(state,self.transform,Vector3(tplayer_pos.x,self.translation.y,tplayer_pos.y),(pl_rot))
	var tdir=(-self.translation+Vector3(tplayer_pos.x,self.translation.y,tplayer_pos.y))
	if(is_mov):
		var tsp=self_speed
		tsp=min(tsp,1.5)
		tdir=tdir.normalized()*(30+50*clamp((tdir.length()-3)/7,0,1))*(1.5-tsp)
		state.add_central_force(tdir)
		#tdir=Vector3(0,-100,0)
		#state.add_central_force(tdir)

func _integrate_forces(state):
	if !is_network_master():
		return
	if(is_preload):
		return
	if(cfree):
		return
	if(rest_k):
		return
	upd_forces_rot(state)











