extends AnimationTree

var atimer=0.0
var lFrame=0
var once=true

var start_time=8

onready var global_v=get_tree().get_root().get_node("scene")
onready var is_preload=get_node("../../").is_preload
onready var anim_tree=self
onready var elem=get_node("../../").elem
onready var extra_hp=get_node("../../").extra_hp

var aonce=true
var eonce=true

var at_timer=0.0
var at_cd=0.0
const at_cd_t=6.35 # at_cd_t>at_timer_t, min at_cd_t=at_timer_t
const at_timer_t=2.5

# this animation or Godot animation player has bug
# bug rotate half of model if do not preload
# I preload /bot_holder/ap/01_Sphere_bot_Roll animation and play 2 frames to fix bug

func _ready():
	if(is_preload):
		return
	self.active=false
	get_node("../bot_holder/ap").play("01_Sphere_bot_Roll")
	
	anim_tree.set("parameters/wb_s/seek_position", 0.0)
	anim_tree.set("parameters/wb_t/scale", 0.0)
	anim_tree.set("parameters/walk_s/blend_amount", 1.0)
	anim_tree.set("parameters/wb_wt/add_amount", 1.0)
	anim_tree.set("parameters/w_o/active", true)
	anim_tree.set("parameters/f/current", 0)
	anim_tree.set("parameters/wt_wa/blend_amount", 0.0)
	anim_tree.set("parameters/wt_s/seek_position", 0.0)
	anim_tree.set("parameters/wt_t/scale", 0.0)
	anim_tree.set("parameters/reset_s/seek_position", 0.0)
	anim_tree.set("parameters/reset_t/scale", 0.0)
	anim_tree.set("parameters/reset_b/blend_amount", 1.0)
	anim_tree.set("parameters/op_s/seek_position", 0.0)
	anim_tree.set("parameters/op_t/scale", 0.0)
	get_node("../bot_holder").visible=false
	get_node("../spawn").visible=true
	for a in range(get_node("../spawn").get_child_count()):
		get_node("../spawn").get_child(a).set_process_material(get_node("../spawn").get_child(a).process_material.duplicate())
		get_node("../spawn").get_child(a).emitting=true
	


func _process(delta):
	if(is_preload):
		return
	lFrame+=1
	if(eonce):
		if is_network_master():
			process_animation(delta)
	if((lFrame>2)&&(once)):
		once=false
		get_node("../bot_holder/ap").stop(true)
		self.active=true

func angle2d(c,e):
	var theta = atan2(e.y-c.y, e.x-c.x)
	return theta

puppet func update_parts_s(st):
	get_node("../parts_s/p1/p1").emitting=st
	get_node("../parts_s/p2/p1").emitting=st
	get_node("../parts_s/p3/p1").emitting=st

puppet func spawn_p(transf,show_timer,extra_speed,selfID,en_bulidsl):
	var ae=elem.instance()
	ae.transform=transf
	ae.visible=false
	ae.show_timer=show_timer
	ae.extra_speed=extra_speed
	ae.selfID=selfID
	ae.host_alive=true
	var tss=Node.new()
	tss.name="cont"+str(en_bulidsl)
	tss.add_child(ae,true)
	global_v.get_node("en_bul_cont").call_deferred("add_child",tss,true)
	last_elem=ae

puppet func upd_anim1(tvalx):
	anim_tree.set("parameters/wt_wa/blend_amount", tvalx)

puppet func upd_h():
	get_node("../bot_holder").visible=true

puppet func upd_at(atimerx):
	for a in range(get_node("../spawn").get_child_count()):
			get_node("../spawn").get_child(a).process_material.set("shader_param/iTime",atimerx)

puppet func upd_sc():
	anim_tree.set("parameters/op_t/scale", 1.0)

puppet func upd_spw():
	get_node("../spawn").visible=false
	for a in range(get_node("../spawn").get_child_count()):
		get_node("../spawn").get_child(a).emitting=false

puppet func upd_sc2(tv2,tv):
	anim_tree.set("parameters/wb_t/scale", tv2)
	anim_tree.set("parameters/wt_t/scale", tv)

puppet func upd_res():
	anim_tree.set("parameters/reset_b/blend_amount", 0.0)
	

puppet func upd_ptsa():
	anim_tree.set("parameters/f/current", 1)
	get_node("../parts_s/p1/p1").emitting=false
	get_node("../parts_s/p2/p1").emitting=false
	get_node("../parts_s/p3/p1").emitting=false
	if(last_elem!=null)&&(is_instance_valid(last_elem)):
		last_elem.host_alive=false

var atponce=true

var last_elem=null

func atack_l(delta):
	var tval=0.0
	if(at_cd<at_cd_t):
		get_node("../parts_s/p1/p1").emitting=false
		get_node("../parts_s/p2/p1").emitting=false
		get_node("../parts_s/p3/p1").emitting=false
		rpc("update_parts_s",false)
		at_cd+=delta
		if(at_cd>at_timer_t):
			atponce=true
			at_timer=0.0
		tval=1-smoothstep(0,at_timer/2+0.001,at_cd)
		tval=max(tval,smoothstep(at_cd_t-at_timer_t/2,at_cd_t+0.001,at_cd))
	else:
		get_node("../parts_s/p1/p1").emitting=true
		get_node("../parts_s/p2/p1").emitting=true
		get_node("../parts_s/p3/p1").emitting=true
		rpc("update_parts_s",true)
		if(atponce)&&(!global_v.game_over):
			var a=Vector2(get_node("../").translation.x,get_node("../").translation.z)
			var b=Vector2(global_v.player_pos.x,global_v.player_pos.z)
			var c=Vector2(global_v.player_pos2.x,global_v.player_pos2.z)
			if((((a-b)).length())>(((a-c)).length())):
				b=c
			else:
				b=b
			var pl_rot=angle2d(Vector2(),a-b)
			atponce=false
			var ae=elem.instance()
			ae.translation=get_node("../").translation
			ae.translation.y+=1.234
			ae.rotate_y(-pl_rot-PI/2)
			ae.visible=false
			ae.show_timer=at_timer_t-at_timer_t/3.0
			ae.extra_speed=extra_hp
			ae.selfID=global_v.sIDs
			ae.host_alive=true
			global_v.sIDs+=1
			var tss=Node.new()
			tss.name="cont"+str(global_v.en_bulids)
			tss.add_child(ae,true)
			global_v.get_node("en_bul_cont").call_deferred("add_child",tss,true)
			last_elem=ae
			rpc("spawn_p",ae.transform,ae.show_timer,ae.extra_speed,ae.selfID,global_v.en_bulids)
			global_v.en_bulids+=1
		tval=1
		at_timer+=delta
		if(at_timer>at_timer_t):
			at_cd=0
	
	anim_tree.set("parameters/wt_wa/blend_amount", 0.63*tval)
	rpc("upd_anim1",0.63*tval)
	
	

var start_once=true
func process_animation(delta):
	atimer+=delta
	if(once):
		return
	if(start_once):
		if(atimer>=4):
			get_node("../bot_holder").visible=true
			rpc("upd_h")
		rpc("upd_at",atimer)
		for a in range(get_node("../spawn").get_child_count()):
				get_node("../spawn").get_child(a).process_material.set("shader_param/iTime",atimer)
	if(atimer>=start_time):
		anim_tree.set("parameters/op_t/scale", 1.0)
		rpc("upd_sc")
		if(start_once):
			rpc("upd_spw")
			start_once=false
			get_node("../spawn").visible=false
			for a in range(get_node("../spawn").get_child_count()):
				get_node("../spawn").get_child(a).emitting=false
	
	if(!aonce):
		atack_l(delta)
	
	var tv=smoothstep(start_time+1.5,start_time+2.0,atimer)
	anim_tree.set("parameters/wb_t/scale", min(get_node("../").self_speed,1.5)*2)
	anim_tree.set("parameters/wt_t/scale", tv)
	rpc("upd_sc2",min(get_node("../").self_speed,1.5)*2,tv)
	if(atimer>start_time+0.5):
		anim_tree.set("parameters/reset_b/blend_amount", 0.0)
		rpc("upd_res")
	if(aonce)&&(atimer>=start_time+1.5):
		aonce=false
		get_node("../").is_anim_end=true
	
	
	if(!(get_node("../").is_alive)):
		rpc("upd_ptsa")
		anim_tree.set("parameters/f/current", 1)
		get_node("../parts_s/p1/p1").emitting=false
		get_node("../parts_s/p2/p1").emitting=false
		get_node("../parts_s/p3/p1").emitting=false
		if(last_elem!=null)&&(is_instance_valid(last_elem)):
			last_elem.host_alive=false
		eonce=false
	
	



