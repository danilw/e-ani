extends Area

onready var is_preload=get_node("../").is_preload
onready var no_parts=get_node("../").no_parts
var del_it=false
var is_hit=false
var once=true
var cfree=false

var del_timer=0.0
var timer=0.0

func _ready():
	if(is_preload):
		return
	
	get_node("../").translation.y=0.35
	if is_network_master():
		connect("body_entered",self,"_on_bonus_body_entered")
	
	get_node("../futari/on_hit").visible=!no_parts
	get_node("../futari/f").visible=!no_parts
	
func _on_bonus_body_entered(body):
	if(del_it):
		return
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")||body.is_in_group("player2")):
		body.rpc("bonus_hit",get_node("../").self_type)
		del_it=true
		is_hit=true
		return

remotesync func free_bonus():
	cfree=true
	get_node("../").visible=false
	get_node("../../").queue_free()

puppet func on_hitm(is_hitm):
	if(is_hitm)&&(!no_parts):
		get_node("../futari/on_hit").emitting=true
	get_node("../model").get_child(0).visible=false
	get_node("../model").get_child(1).visible=false
	get_node("../futari/f").emitting=false

puppet func update_tranform(transformx):
	get_node("../").transform=transformx

func _process(delta):
	if(is_preload):
		return
	if(cfree):
		return
	if !is_network_master():
		return
	if(del_it):
		if(once):
			disconnect("body_entered",self,"_on_bonus_body_entered")
			if(is_hit)&&(!no_parts):
				get_node("../futari/on_hit").emitting=true
			get_node("../model").get_child(0).visible=false
			get_node("../model").get_child(1).visible=false
			get_node("../futari/f").emitting=false
			rpc("on_hitm",is_hit)
			#get_node("../futari/f").process_material.flag_enable_attractor=true #need make each material unique on each creation,it may lag
			once=false
		del_timer+=delta
		if(del_timer>5):
			rpc("free_bonus")
	else:
		if(get_node("../").translation.y>5):
			del_it=true
		get_node("../").rotate_y(delta)
		get_node("../").translation.y+=delta*(0.04+0.12*smoothstep(0.0,26.5,timer)+0.2*smoothstep(8.0,20.5,timer))
		timer+=delta
	rpc("update_tranform",get_node("../").transform)
