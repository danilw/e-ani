extends KinematicBody

var dir = Vector3()
var vel = Vector3()
var ovel = Vector3()
var GRAVITY = -9.8 # -2.8 -9.8
var shoot_mov_l=5.0
var shoot_mov_r=3.5
var self_dmg_l=15
var self_dmg_r=35
const MAX_SPEED = 1.25
const JUMP_SPEED = 3.0
const MAX_SLOPE_ANGLE = 20
const ACCEL= 2.1
const DEACCEL= 1.85
var arot=0.0
var hit_floor=false
var iMouse=Vector2()
var iMouseu=Vector2()
var iMoused=Vector2()
var iMouser=false
var iMousel=false
var local_speed=0.0

var jump_timer=0.0
var hfloor_timer=0.0

var shoot_timer_l=0.0
var shoot_timeout_l=1.25 # >0, max 4
var shoot_timer_r=0.0
var shoot_timeout_r=2.6 # >0, max 4

var tl=shoot_timeout_l #const
var tr=shoot_timeout_r #const
var shoot_mov_lo=shoot_mov_l
var shoot_mov_ro=shoot_mov_r

var start_pos=Vector3()

var HP_val=12
var hit_time=-10.0
var heal_time=-10.0

func Spherex(p):
	var s=50
	return p.length()-s

onready var anim_tree=get_node("model/AnimationTree")
onready var global_v=get_tree().get_root().get_node("scene")
onready var hp_bar=get_tree().get_root().get_node("scene/UI_panels/vbc/HP")

onready var f_vortex_l=get_node("l_s_h/futari/FutariVortex")
onready var f_vortex_r=get_node("r_s_h/futari/FutariVortex")
onready var f_part_l=get_node("l_s_h/futari/FutariParticles")
onready var f_part_r=get_node("r_s_h/futari/FutariParticles")

var hit_ids=Array()
var hitidx=0

puppet func hp_sync(hv,ht,go):
	HP_val=hv
	hit_time=ht
	global_v.game_over=go
	if(global_v.game_over):
		get_node("../end_game").visible=true


puppet func hp_synch(hv,ht):
	HP_val=hv
	heal_time=ht

func hit(pos):
	HP_val+=-1
	HP_val=max(HP_val,0)
	hit_time=global_v.iTime
	global_v.game_over=(int(HP_val)==0)
	if(global_v.game_over):
		get_node("../end_game").visible=true
	rpc("hp_sync",HP_val,hit_time,global_v.game_over)
	

func heal():
	global_v.heal_player=false
	HP_val+=1
	HP_val=min(HP_val,12)
	heal_time=global_v.iTime
	rpc("hp_synch",HP_val,heal_time)
	

func test_hit(pos, sID):
	if(global_v.game_over):
		return
	var usd=true
	for a in range(5):
		if(hit_ids[a]==sID):
			usd=false
			break
	hit_ids[hitidx]=sID
	hitidx+=1
	hitidx=hitidx%5
	if(usd):
		hit(pos)

func _ready():
	anim_tree.set("parameters/walk_c/blend_amount", 1.0)
	anim_tree.set("parameters/walk_t/scale", 1.0)
	anim_tree.set("parameters/walk_s/blend_amount", 1.0)
	anim_tree.set("parameters/shoot_R/add_amount", 0.0)
	anim_tree.set("parameters/shoot_L/add_amount", 0.0)
	anim_tree.set("parameters/jump_c/add_amount", 0.0)
	global_v.player_pos=self.translation
	start_pos=self.translation+Vector3(0.0,01.0,0.0)
	preload_shoot()
	for a in range(5):
		hit_ids.append(-1)
	

puppet func update_tranform(transformx):
	self.transform=transformx
	global_v.player_pos=self.translation
	global_v.player_rot=self.rotation_degrees.y

puppet func update_ex_p(iMoused_l,f_part_l_e,f_part_r_e):
	get_node("l_s_h/Particles").process_material.set("shader_param/h_pos",smoothstep(0.25,1.0,iMoused_l.x))
	get_node("r_s_h/Particles").process_material.set("shader_param/h_pos",smoothstep(0.25,1.0,iMoused_l.y))
	f_part_l.emitting=f_part_l_e
	f_part_r.emitting=f_part_r_e
	

puppet func update_anim(walk_c,walk_t,walk_s,shoot_R,shoot_L,jump_c):
	anim_tree.set("parameters/walk_c/blend_amount", walk_c)
	anim_tree.set("parameters/walk_t/scale", walk_t)
	anim_tree.set("parameters/walk_s/blend_amount", walk_s)
	anim_tree.set("parameters/shoot_R/add_amount", shoot_R)
	anim_tree.set("parameters/shoot_L/add_amount", shoot_L)
	anim_tree.set("parameters/jump_c/add_amount", jump_c)

puppet func gen_shoot_l_m(angle,start_pos,aim_point_pos,extra_speed,aie_e,min_mov,shoot_mov,self_dmg,tidsx_ll):
	var s=elema.instance()
	s.get_node("b1").angle=angle
	s.get_node("b1").start_pos=start_pos
	s.get_node("b1").aim_point_pos=aim_point_pos
	s.get_node("b1").extra_speed=extra_speed
	s.get_node("b1").aie_e=aie_e
	s.get_node("b1").no_parts=global_v.no_parts
	s.get_node("b1").min_mov+=min_mov
	s.get_node("b1").shoot_mov=shoot_mov
	s.get_node("b1").self_dmg=self_dmg
	var tss=Node.new()
	tss.name="cont"+str(tidsx_ll)
	tss.add_child(s,true)
	global_v.get_node("shoot_l").call_deferred("add_child",tss,true)

puppet func gen_shoot_r_m(angle,start_pos,aim_point_pos,extra_speed,aie_e,min_mov,shoot_mov,self_dmg,tidsx_rl):
	var s=elemb.instance()
	s.get_node("b1").angle=angle
	s.get_node("b1").start_pos=start_pos
	s.get_node("b1").aim_point_pos=aim_point_pos
	s.get_node("b1").extra_speed=extra_speed
	s.get_node("b1").aie_e=aie_e
	s.get_node("b1").no_parts=global_v.no_parts
	s.get_node("b1").min_mov+=min_mov
	s.get_node("b1").shoot_mov=shoot_mov
	s.get_node("b1").self_dmg=self_dmg
	var tss=Node.new()
	tss.name="cont"+str(tidsx_rl)
	tss.add_child(s,true)
	global_v.get_node("shoot_r").call_deferred("add_child",tss,true)

func _process(delta):
	if !(is_network_master()):
		return

	if(global_v.pleload_done)&&(!global_v.game_over):
		process_shoot_l(delta)
		process_shoot_r(delta)
	free_shotq_l()
	free_shotq_r()
	if(global_v.heal_player):
		heal()
	hp_bar.material.set("shader_param/iTime",global_v.iTime)
	hp_bar.material.set("shader_param/hp_val",HP_val)
	hp_bar.material.set("shader_param/hit_time",hit_time)
	hp_bar.material.set("shader_param/heal_time",heal_time)
	hp_bar.material.set("shader_param/a_timer",shoot_timer_r/shoot_timeout_r)
	hp_bar.material.set("shader_param/b_timer",shoot_timer_l/shoot_timeout_l)
	if(Spherex(self.translation+Vector3(-10.0,0.0,0.0))>1):
		self.translation=start_pos
	rpc("update_tranform",self.transform)

# I put each bullet-node to Array, to have them aviable if I need
# (better add node, and spawn bullets in their node, but need check if they on queue to delete)
# Array has only alive bullets

var tmp_shoot_l=Array()
var tmp_shoot_r=Array()
var elema
var elemb
func preload_shoot():
	elema=preload("res://scene1/b1.tscn")
	elemb=preload("res://scene1/b2.tscn")

var obc=false
func process_shoot_l(delta):
	shoot_timer_l+=delta
	if(shoot_timer_l>=shoot_timeout_l)&&(iMoused.x>0.99)&&(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		shoot_timer_l=0.0
		obc=true
	else:
		if(shoot_timer_l>=shoot_timeout_l):
			shoot_timer_l=shoot_timeout_l
	if(obc):
		obc=false
		gen_shoot_l()

var obc2=false
func process_shoot_r(delta):
	shoot_timer_r+=delta
	if(shoot_timer_r>=shoot_timeout_r)&&(iMoused.y>0.99)&&(Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		shoot_timer_r=0.0
		obc2=true
	else:
		if(shoot_timer_r>=shoot_timeout_r):
			shoot_timer_r=shoot_timeout_r
	if(obc2):
		obc2=false
		gen_shoot_r()

var tidsx_l=0
func gen_shoot_l():
	tmp_shoot_l.append(elema.instance())
	var idx=tmp_shoot_l.size()-1
	tmp_shoot_l[idx].get_node("b1").angle=deg2rad(-(self.rotation_degrees.y))
	tmp_shoot_l[idx].get_node("b1").start_pos=self.translation
	tmp_shoot_l[idx].get_node("b1").aim_point_pos=global_v.iMouse_3d
	tmp_shoot_l[idx].get_node("b1").extra_speed=max(-local_speed,0)
	tmp_shoot_l[idx].get_node("b1").aie_e=global_v.mouse_aim_e
	tmp_shoot_l[idx].get_node("b1").no_parts=global_v.no_parts
	tmp_shoot_l[idx].get_node("b1").min_mov+=0.25*clamp(tl-shoot_timeout_l,0,1)*shoot_mov_l
	tmp_shoot_l[idx].get_node("b1").shoot_mov=shoot_mov_l+0.05*clamp(tl-shoot_timeout_l,0,1)*shoot_mov_l
	tmp_shoot_l[idx].get_node("b1").self_dmg=self_dmg_l
	var tss=Node.new()
	tss.name="cont"+str(tidsx_l)
	tss.add_child(tmp_shoot_l[idx],true)
	global_v.get_node("shoot_l").call_deferred("add_child",tss,true)
	var a=tmp_shoot_l[idx].get_node("b1")
	rpc("gen_shoot_l_m",a.angle,a.start_pos,a.aim_point_pos,a.extra_speed,a.aie_e,a.min_mov,a.shoot_mov,a.self_dmg,tidsx_l)
	tidsx_l+=1
	tidsx_l=tidsx_l

var tidsx_r=0
func gen_shoot_r():
	tmp_shoot_r.append(elemb.instance())
	var idx=tmp_shoot_r.size()-1
	tmp_shoot_r[idx].get_node("b1").angle=deg2rad(-(self.rotation_degrees.y))
	tmp_shoot_r[idx].get_node("b1").start_pos=self.translation
	tmp_shoot_r[idx].get_node("b1").aim_point_pos=global_v.iMouse_3d
	tmp_shoot_r[idx].get_node("b1").extra_speed=max(-local_speed,0)
	tmp_shoot_r[idx].get_node("b1").aie_e=global_v.mouse_aim_e
	tmp_shoot_r[idx].get_node("b1").no_parts=global_v.no_parts
	tmp_shoot_r[idx].get_node("b1").min_mov+=0.25*clamp(tr-shoot_timeout_r,0,1)*shoot_mov_r
	tmp_shoot_r[idx].get_node("b1").shoot_mov=shoot_mov_r+0.1*clamp(tr-shoot_timeout_r,0,1)*shoot_mov_r
	tmp_shoot_r[idx].get_node("b1").self_dmg=self_dmg_r
	var tss=Node.new()
	tss.name="cont"+str(tidsx_r)
	tss.add_child(tmp_shoot_r[idx],true)
	global_v.get_node("shoot_r").call_deferred("add_child",tss,true)
	var a=tmp_shoot_r[idx].get_node("b1")
	rpc("gen_shoot_r_m",a.angle,a.start_pos,a.aim_point_pos,a.extra_speed,a.aie_e,a.min_mov,a.shoot_mov,a.self_dmg,tidsx_r)
	tidsx_r+=1
	tidsx_r=tidsx_r

func free_shotq_l():
	var idx=0
	for a in tmp_shoot_l:
		if(!is_instance_valid(a)):
			tmp_shoot_l.remove(idx)
			#print("deleted_A "+ str(idx))
		else:
			idx+=1

func free_shotq_r():
	var idx=0
	for a in tmp_shoot_r:
		if(!is_instance_valid(a)):
			tmp_shoot_r.remove(idx)
			#print("deleted_B "+ str(idx))
		else:
			idx+=1

func _physics_process(delta):
	if !(is_network_master()):
		return
	process_anim(delta)
	if(global_v.pleload_done):
		process_input(delta)
	process_movement(delta)
	process_collision(delta)
	global_v.player_pos=self.translation
	global_v.player_rot=self.rotation_degrees.y
	

var smoothd=0.0
func process_anim(delta):
	var d=0.0
	var unvel=Vector2()
	var md = Transform2D()
	md = md.rotated(-arot)
	md = md.translated( Vector2(vel.x,vel.z) )
	if (md.get_origin().y>0.0)&&((smoothd)<(md.get_origin().y)):
		smoothd=min(smoothd+MAX_SPEED/25.0,(md.get_origin().y))
	elif (md.get_origin().y<=0.0)&&((smoothd)>(md.get_origin().y)):
		smoothd=max(smoothd-MAX_SPEED/25.0,(md.get_origin().y))
	elif (md.get_origin().y>0.0)&&((smoothd)>(md.get_origin().y)):
		smoothd=max(smoothd-MAX_SPEED/25.0,(md.get_origin().y))
	elif (md.get_origin().y<=0.0)&&((smoothd)<(md.get_origin().y)):
		smoothd=min(smoothd+MAX_SPEED/25.0,(md.get_origin().y))
	var vx=abs(GRAVITY)/2.0
	d=smoothstep(0,1,vx*(global_v.iTime-jump_timer))*(1-smoothstep(0,1,vx*(global_v.iTime-jump_timer-(1.0/vx)*2.0)))
	anim_tree.set("parameters/jump_c/add_amount", d)
	d=1.0-min(abs(smoothd)/(MAX_SPEED/2.0),1.0)
	anim_tree.set("parameters/walk_s/blend_amount", d)
	d=1.0+(abs(smoothd)/(MAX_SPEED))*1.5
	anim_tree.set("parameters/walk_t/scale", d)
	d=1.0-min(max(smoothd,0)/(MAX_SPEED/2.0),1.0)
	anim_tree.set("parameters/walk_c/blend_amount", d)

	if(iMousel):
		iMoused.x=min(iMoused.x+delta*4.0,1.0)
		anim_tree.set("parameters/shoot_L/add_amount", iMoused.x)
	else:
		iMoused.x=max(iMoused.x-delta*4.0,0.0)
		anim_tree.set("parameters/shoot_L/add_amount", iMoused.x)
	if(iMouser):
		iMoused.y=min(iMoused.y+delta*4.0,1.0)
		anim_tree.set("parameters/shoot_R/add_amount", iMoused.y)
	else:
		iMoused.y=max(iMoused.y-delta*4.0,0.0)
		anim_tree.set("parameters/shoot_R/add_amount", iMoused.y)
	get_node("l_s_h/Particles").process_material.set("shader_param/h_pos",smoothstep(0.25,1.0,iMoused.x))
	get_node("r_s_h/Particles").process_material.set("shader_param/h_pos",smoothstep(0.25,1.0,iMoused.y))
	
	if(iMoused.x>0.95)&&(shoot_timer_l-shoot_timeout_l/(4.0/shoot_timeout_l)>=shoot_timeout_l/(4.0/shoot_timeout_l)):
		f_part_l.emitting=true
	else:
		f_part_l.emitting=false
	if(iMoused.y>0.95)&&(shoot_timer_r-shoot_timeout_r/(4.0/shoot_timeout_r)>=shoot_timeout_r/(4.0/shoot_timeout_r)):
		f_part_r.emitting=true
	else:
		f_part_r.emitting=false
	
	rpc("update_ex_p",iMoused,f_part_l.emitting,f_part_r.emitting)
	var ax=anim_tree.get("parameters/walk_c/blend_amount")
	var bx=anim_tree.get("parameters/walk_t/scale")
	var cx=anim_tree.get("parameters/walk_s/blend_amount")
	var dx=anim_tree.get("parameters/shoot_R/add_amount")
	var ex=anim_tree.get("parameters/shoot_L/add_amount")
	var fx=anim_tree.get("parameters/jump_c/add_amount")
	rpc("update_anim",ax,bx,cx,dx,ex,fx)

func process_input(delta):
	#if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
	#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	dir = Vector3()
	arot=deg2rad(rad2deg(arot)-(int(rad2deg(arot))%360)*360)
	var input_movement_vector = Vector2()
	if(!global_v.game_over):
		if Input.is_action_pressed("ui_down"):
			input_movement_vector.y += 1
		if Input.is_action_pressed("ui_up"):
			input_movement_vector.y -= 1
		if Input.is_action_pressed("ui_left"):
			arot -= PI*delta*0.31
		if Input.is_action_pressed("ui_right"):
			arot += PI*delta*0.31
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT)&&(!global_v.game_over):
		if(!iMousel):
			iMouse.x=global_v.iTime
		iMousel=true
	else:
		if(iMousel):
			iMouseu.x=global_v.iTime
		iMousel=false
	if Input.is_mouse_button_pressed(BUTTON_RIGHT)&&(!global_v.game_over):
		if(!iMouser):
			iMouse.y=global_v.iTime
		iMouser=true
	else:
		if(iMouser):
			iMouseu.y=global_v.iTime
		iMouser=false
	
	input_movement_vector = input_movement_vector.normalized()
	if is_on_floor()||(hit_floor&&(GRAVITY<-3.0)):
		hfloor_timer=global_v.iTime
	if is_on_floor()||hit_floor||global_v.iTime-hfloor_timer>3:
		hit_floor=true
		if(!global_v.game_over):
			if Input.is_action_just_pressed("ui_select"):
				hit_floor=false
				vel.y = JUMP_SPEED
				jump_timer=global_v.iTime
	
	var md = Transform2D()
	md = md.rotated(arot)
	md = md.translated( Vector2(input_movement_vector.x,input_movement_vector.y) )
	dir.x+=md.get_origin().x
	dir.z+=md.get_origin().y
	self.rotate_y(-deg2rad(self.rotation_degrees.y-179.9998)-arot)
	
	#f_vortex_l.rotate_y(-deg2rad(self.rotation_degrees.y)-arot) #not work
	#f_vortex_l.rotation_degrees.y=self.rotation_degrees.y-180 #fix for bug in futari object
	#f_vortex_r.rotation_degrees.y=self.rotation_degrees.y-180 #fix for bug in futari object
	

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	vel.y += delta*GRAVITY
	var hvel = vel
	hvel.y = 0
	var target = dir
	target *= MAX_SPEED+min(max(hvel.length()-MAX_SPEED/1.85,0),MAX_SPEED)
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	if(!hit_floor):
		accel = accel*0.42
	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	#if(!hit_floor):
	#	vel.x=ovel.x
	#	vel.z=ovel.z
	var md = Transform2D()
	md = md.translated(Vector2(vel.x,vel.z))
	md = md.rotated(-arot)
	local_speed=md.get_origin().y
	ovel=vel
	vel = move_and_slide(vel,Vector3(0,1,0), true, 4, deg2rad(MAX_SLOPE_ANGLE),false)


remotesync func bonus_hit(b_type):
	if(b_type==2):
		GRAVITY=min(GRAVITY+0.15,-2.8)
		#if(GRAVITY>=-2.801):
		#	global_v.bonus_c=false
	if(b_type==1):
		shoot_timeout_l=max(shoot_timeout_l-tl*0.015,tl*0.1)
		shoot_timeout_r=max(shoot_timeout_r-tr*0.015,tr*0.1)
		shoot_mov_r=min(shoot_mov_r+shoot_mov_ro*0.045,shoot_mov_ro*3)
		shoot_mov_l=min(shoot_mov_l+shoot_mov_lo*0.045,shoot_mov_lo*3)
		#if(shoot_timeout_l<=tl*0.101)&&(shoot_timeout_r<=tr*0.101)&&(shoot_mov_r>=shoot_mov_ro*2.99)&&(shoot_mov_l>=shoot_mov_lo*2.99):
		#	global_v.bonus_b=false
		
	if(b_type==0):
		var xx=false
		if(self_dmg_l<self_dmg_l+int(self_dmg_l/6)):
			self_dmg_l+=int(self_dmg_l/6)
		else:
			xx=true
		if(self_dmg_r<self_dmg_r+int(self_dmg_r/6)):
			self_dmg_r+=int(self_dmg_r/6)
		#else:
		#	if(xx):
		#		global_v.bonus_a=false

# set collision layer 8 and 9 to collide with crashed parts (need add force)

func process_collision(delta):
	for a in get_slide_count():
		var collision = get_slide_collision(a)
		if(collision.collider.is_in_group("chess")||collision.collider.is_in_group("Enemy")||collision.collider.is_in_group("dyn_obj")||collision.collider.is_in_group("dyn_obj_nodmg")):
			if(collision.collider is RigidBody):
				if(collision.collider.mode==RigidBody.MODE_RIGID):
					#collision.collider.apply_central_impulse(-collision.normal * ovel.length() * 10.0)
					collision.collider.add_central_force(-collision.normal * (ovel.length()+10*dir.length()) * 10.0)
					#not best but it work
					vel.x=(ovel.x)+(collision.normal*ovel.length()).x*0.1
					vel.x=clamp(vel.x,-MAX_SPEED,MAX_SPEED)
					vel.z=(ovel.z)+(collision.normal*ovel.length()).z*0.1
					vel.z=clamp(vel.z,-MAX_SPEED,MAX_SPEED)









