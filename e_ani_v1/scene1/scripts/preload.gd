extends Spatial

const frames_per_obj=5

onready var global_v=get_tree().get_root().get_node("scene")
onready var preload_h=get_tree().get_root().get_node("scene/preload_h/progress")
onready var preload_ho=get_tree().get_root().get_node("scene/preload_h")

var once=true

var preload_done=false #true

func _ready():
	preload_cam()
	preload_ho.visible=true


func preload_cam():
	global_v.get_node("main_camera").current=false
	global_v.get_node("preload/preload_camera").current=true
	global_v.get_node("preload/preload_camera").make_current()

func unload_cam():
	global_v.get_node("main_camera").current=true
	global_v.get_node("preload/preload_camera").current=false
	global_v.get_node("main_camera").make_current()

func rec_s(v):
	if(v.has_method("set_visible")):
		v.set_visible(true)
	if (v.get_child_count()>0):
		for a in range(v.get_child_count()):
			rec_s(v.get_child(a))
	else:
		if(v is Particles)||(v is FutariParticles):
			v.emitting=true

var elemp=preload("res://character/chess/v2/p.tscn")
var elemh=preload("res://character/chess/v2/h.tscn")
var elemsl=preload("res://character/chess/v2/s.tscn")
var eleml=preload("res://character/chess/v2/l.tscn")
var elemq=preload("res://character/chess/v2/q.tscn")
var elemk=preload("res://character/chess/v2/k.tscn")
var elemi=preload("res://floor/stone_tiles/block_ed/block_mesh_ex.tscn")
var elemj=preload("res://floor/stone_tiles/block_ed/block_mesh_ex_t.tscn")
var elemx=preload("res://character/sphere_bot_b/shot.tscn")

var elems=[preload("res://scene1/b1.tscn"),preload("res://scene1/b2.tscn"),
preload("res://character/coin/purp.tscn"),preload("res://character/coin/blue.tscn"),
preload("res://character/coin/yellow.tscn"),preload("res://character/sphere_bot_b/bot_b.tscn"),
elemp,elemh,elemsl,eleml,elemq,elemk,elemi,elemj,elemx]

var cpart=0
var ael
var fael=false
var last_frame=0

func preload_parts():
	if(!is_instance_valid(ael)):
		global_v.get_node("preload_h/progress/VBoxContainer/Label5").text="progress: "+str(cpart)+"/"+str(elems.size()) +" (" + str(int(global_v.iTime)) + " sec)"
		if cpart<elems.size():
			ael=elems[cpart].instance()
			ael.is_preload=true
			fael=false
			rec_s(ael)
			self.call_deferred("add_child",ael)
			cpart+=1
			last_frame=global_v.iFrame
		else:
			preload_done=true
	
func unload_parts():
	if(is_instance_valid(ael))&&(!fael):
		fael=true
		ael.queue_free()

var fonce=true
func finishx():
	if(fonce):
		global_v.pleload_once=true
		global_v.preload_time=global_v.iTime
		fonce=false
		preload_ho.visible=false
		global_v.get_node("UI_panels").visible=true
		unload_cam()
		unload_parts()
		self.queue_free()

func _process(delta):
	if(!once)||(preload_done):
		finishx()
		return
	preload_parts()
	if(global_v.iFrame-last_frame>frames_per_obj):
		unload_parts()
	preload_h.material.set("shader_param/iTime",global_v.iTime*2.0)
	if(global_v.iTime>25):
		global_v.get_node("preload_h/progress/VBoxContainer/Label4").text="Error: Preload long or failed, some effects may be broken. Returning to game."
	if(global_v.iTime>30):
		print("Error: Preloadng failed!")
		once=false