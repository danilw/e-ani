extends Spatial


onready var global_v=get_tree().get_root().get_node("scene")

var elem
var elemx
var elems_bonus=Array()

func _ready():
	elem=preload("res://character/sphere_bot_b/bot_b.tscn")
	elemx=preload("res://character/sphere_bot_b/shot.tscn")
	var elem_a=preload("res://character/coin/purp.tscn")
	var elem_b=preload("res://character/coin/blue.tscn")
	var elem_c=preload("res://character/coin/yellow.tscn")
	elems_bonus=[elem_a,elem_b,elem_c]
	#load_new(Vector3(0,0,0))

func gen_bonus(bval,rnd):
	if(!bval):
		return null
	if((global_v.bonus_a)&&(rnd==0))||((global_v.bonus_b)&&(rnd==1))||((global_v.bonus_c)&&(rnd==2)):
		var s=elems_bonus[rnd].instance()
		s.self_type=rnd
		return s
	else:
		return null

func load_new(pos,enemys_idsl,rnd,rnd2):
	if(global_v.alive_en<global_v.max_en_ph):
		global_v.alive_en+=1
		var s=elem.instance()
		s.pos=Vector3((pos.z+27),0.15,pos.x)
		s.extra_hp=min(global_v.ground,10)
		s.elem=elemx
		s.bonus_in=gen_bonus(rnd2,rnd)
		var tss=Node.new()
		tss.name="cont"+str(enemys_idsl)
		tss.add_child(s,true)
		self.call_deferred("add_child",tss,true)