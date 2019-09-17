extends RigidBody

onready var global_v=get_tree().get_root().get_node("scene")
onready var en_spwn=global_v.get_node("enemy_spawner")

var hpx=1
var start_hp=hpx #const(on _ready)
var is_alive=true
var once=true
var del_timer=0
var adel_timer=0
var is_fvis=false
var hp_vis=false
var is_anim_end=false
onready var self_mat=get_node("../../").self_mat # >0.5 black
onready var rand_rot=get_node("../../").rand_rot
onready var self_id=get_node("../../").self_id

var tba

onready var is_preload=get_node("../../").is_preload
onready var bonus_in=get_node("../../").bonus_in
onready var b_mat=get_node("../../").b_mat

func spwn_bonus():
	if(bonus_in==null):
		return
	bonus_in.translation=get_node("../../").translation
	bonus_in.no_parts=global_v.no_parts
	global_v.call_deferred("add_child",bonus_in)

func hit_bs():
	var th=global_v.en_last_max_HPMP.x/clamp(15-global_v.ground,3.5,6)
	global_v.get_node("floor/static_collision/en/StaticBody").hit(th)

onready var board_map=global_v.board_map
var sz=Vector2(7,8)
func check_alive():
	for a in range(sz.x):
			for b in range(sz.y):
				if(board_map[a][b][2]):
					return
	global_v.add_figs=true
	hit_bs()


func hit(dmg,pos):
	if(!is_alive):
		return
	#hpx+=-dmg
	hpx+=-1
	hpx=max(hpx,0)
	is_alive=!(int(hpx)==0)
	
	if(is_alive)&&(!hp_vis):
		hp_vis=true
		get_node("../hp").visible=true
	
	if(!is_alive):
		en_spwn.load_new(get_node("../../").translation)
		global_v.board_map[get_node("../../").self_idx.x][get_node("../../").self_idx.y][2]=false
		check_alive()
		self.visible=false
		get_node("../hp").visible=false
		get_node("CollisionShape").disabled=true
		spwn_bonus()
		if(global_v.active_blocks_cc<global_v.max_c_blocks):
			is_fvis=true
			global_v.active_blocks_cc+=1
			get_node("../b").visible=true
			#get_node("../b").rotate_y(rand_rot)
			for a in range(get_node("../b").get_child_count()):
				if(self_mat>0.5):
					for ac in range(get_node("../b").get_child(a).get_child_count()):
						if(get_node("../b").get_child(a).get_child(ac) is MeshInstance):
							get_node("../b").get_child(a).get_child(ac).set_surface_material(0,tba)
				get_node("../b").get_child(a).get_node("CollisionShape").disabled=false
				get_node("../b").get_child(a).mode=RigidBody.MODE_RIGID
				var n=get_node("../b").get_child(a).translation-0.75*(pos-get_node("../../").translation)
				get_node("../b").get_child(a).apply_impulse(Vector3(),7.0*Vector3(n.x,0,n.z))

func test_hit(pos, dmg):
	if(is_anim_end):
		hit(dmg,pos)

var cfree=false
func free_block():
	cfree=true
	get_node("../../").visible=false
	get_node("../../").queue_free()

var cafree=false
func free_block_ea():
	global_v.active_blocks_cc+=-1
	cafree=true
	get_node("../b").visible=false
	get_node("../b").queue_free()


func _ready():
	if(is_preload):
		return
	hpx+=int(rand_range(0,self_id))+int(global_v.ground/3)
	if(int(global_v.ground)%10==0):
		hpx=1
	start_hp=hpx
	get_node("../../").rotate_y(PI/2)
	self.rotate_y(rand_rot)
	get_node("../b").rotate_y(rand_rot)
	get_node("../futari").rotate_y(rand_rot)
	if(self_mat>0.5):
		tba=b_mat.duplicate()
	for a in range(self.get_child_count()):
		if(get_child(a) is MeshInstance):
			var tbb=get_child(a).get_surface_material(0).duplicate()
			if(self_mat>0.5):
				tbb.set("shader_param/albedo",Color("1e1e1e"))
				tbb.set("shader_param/emt_col",Color("c0fff5"))
			get_child(a).set_surface_material(0,tbb)
			var tbc=get_child(a).get_child(0).get_surface_material(0).duplicate()
			if(self_mat>0.5):
				tbc.set("shader_param/emission",Color("1eefff"))
			get_child(a).get_child(0).set_surface_material(0,tbc)
			break
#
	
	
	get_node("../hp/h").set_surface_material(0,get_node("../hp/h").get_surface_material(0).duplicate())
	

func process_loop():
	get_node("../hp/h").get_surface_material(0).set("shader_param/value",float(hpx)/start_hp)

func _process(delta):
	if(is_preload):
		return
	if(cfree):
		return
	if(!is_alive):
		adel_timer+=delta
	if(!is_alive):
		del_timer+=delta
	if(del_timer>25.0):
		free_block()
	if(adel_timer>1.2)&&(!cafree):
		if(is_fvis)&&(global_v.active_blocks_cc<global_v.max_c_blocks)&&(!global_v.no_parts):
			get_node("../futari").visible=true
			#get_node("../futari").rotate_y(rand_rot)
			for a in range(get_node("../b").get_child_count()):
				get_node("../futari").get_child(a).transform=get_node("../b").get_child(a).transform
				get_node("../futari").get_child(a).emitting=true
				get_node("../futari").get_child(a).process_material.gravity.y=-0.6
				#get_node("../futari").get_child(a).process_material.initial_velocity=0.25
		free_block_ea()
	if(adel_timer>15.0):
		get_node("../futari").visible=false
	
	process_loop()
