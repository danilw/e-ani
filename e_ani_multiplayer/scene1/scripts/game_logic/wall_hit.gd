extends StaticBody

onready var global_v=get_tree().get_root().get_node("scene")

var hpx=100
var is_alive=true
var once=true
var del_timer=0
var adel_timer=0
var is_fvis=false

onready var is_preload=get_node("../../").is_preload

remotesync func hit(dmg,pos):
	if(!is_alive):
		return
	hpx+=-dmg
	hpx=max(hpx,0)
	is_alive=!(int(hpx)==0)
	if(!is_alive):
		if (is_network_master()):
			global_v.blocks_map[get_node("../../").self_idx.x][get_node("../../").self_idx.y]=false
		get_node("../").visible=false
		get_child(0).disabled=true
		get_node("../../futari/f").emitting=true
		global_v.blocks_counter+=-1
		if(global_v.active_blocks_c<global_v.max_ph_blocks):
			is_fvis=true
			global_v.active_blocks_c+=1
			get_node("../../block_e2").visible=true
			var n=-pos+get_node("../../").translation+get_node("../../../").translation
			for a in range(get_node("../../block_e2").get_child_count()):
				get_node("../../block_e2").get_child(a).get_node("CollisionShape").disabled=false
				get_node("../../block_e2").get_child(a).mode=RigidBody.MODE_RIGID
				get_node("../../block_e2").get_child(a).apply_impulse(Vector3(),n*7.1+Vector3(6.0*get_node("../../block_e2").get_child(a).translation.x,0,0))

func test_hit(pos, dmg):
	rpc("hit",dmg,pos)

var cfree=false
remotesync func free_block():
	cfree=true
	get_node("../../").visible=false
	get_node("../../").queue_free()

var cafree=false
remotesync func free_block_ea():
	global_v.active_blocks_c+=-1
	cafree=true
	get_node("../../block_e2").visible=false
	get_node("../../block_e2").queue_free()

puppet func func_a_m():
	once=false
	get_node("../../futari/f").emitting=false
	get_node("../../futari/f").process_material.gravity.y=-0.8

puppet func func_b_m(va):
	if(va)&&(!global_v.no_parts):
		get_node("../../futari/e").visible=true
		for a in range(get_node("../../block_e2").get_child_count()):
			get_node("../../futari/e").get_child(a).transform=get_node("../../block_e2").get_child(a).transform
			get_node("../../futari/e").get_child(a).emitting=true

func _ready():
	pass

func _process(delta):
	if !(is_network_master()):
		return
	if(is_preload):
		return
	if(cfree):
		return
	if(is_alive):
		if(!(global_v.blocks_map[get_node("../../").self_idx.x][max(get_node("../../").self_idx.y-1,0)])):
			global_v.blocks_map[get_node("../../").self_idx.x][get_node("../../").self_idx.y]=false
			if((get_node("../../").self_idx.y+1==3)||!(global_v.blocks_map[get_node("../../").self_idx.x][min(get_node("../../").self_idx.y+1,3)])):
				rpc("hit",hpx,get_node("../../").translation+get_node("../../../").translation+Vector3(0,-0.35,0))
			
	
	if(!is_alive):
		adel_timer+=delta
	if(!is_alive)&&(global_v.blocks_counter<=0):
		del_timer+=delta
	if(!is_alive)&&(once)&&(del_timer>1.0):
		once=false
		get_node("../../futari/f").emitting=false
		get_node("../../futari/f").process_material.gravity.y=-0.8
		rpc("func_a_m")
	if(del_timer>25.0):
		rpc("free_block")
	if(adel_timer>0.75)&&(!cafree):
		rpc("func_b_m",((is_fvis)&&(global_v.active_blocks_c<global_v.max_ph_blocks)))
		if(is_fvis)&&(global_v.active_blocks_c<global_v.max_ph_blocks)&&(!global_v.no_parts):
			get_node("../../futari/e").visible=true
			for a in range(get_node("../../block_e2").get_child_count()):
				get_node("../../futari/e").get_child(a).transform=get_node("../../block_e2").get_child(a).transform
				get_node("../../futari/e").get_child(a).emitting=true
		rpc("free_block_ea")
	if(adel_timer>15.0):
		get_node("../../futari/e").visible=false