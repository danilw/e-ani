extends StaticBody

onready var global_v=get_tree().get_root().get_node("scene")
onready var hpmpv=global_v.get_node("floor/visible_/main_en/shield/s2")
onready var hpmpa=global_v.get_node("floor/visible_/main_en/shield/s")
onready var hpmpb=global_v.get_node("floor/static_collision/en/en2/StaticBody/CollisionShape")

var is_alive=true
var once=true

func hit(dmg):
	if(!is_alive):
		return
	global_v.en_HPMP.y+=-dmg
	global_v.en_HPMP.y=max(global_v.en_HPMP.y,0)
	is_alive=!(int(global_v.en_HPMP.y)==0)
	if(!is_alive):
		#hpmpv.visible=false
		hpmpb.disabled=true
		hpmpa.visible=true
		global_v.ftime_b=global_v.iTime
	

func test_hit(pos,dmg):
	global_v.eh_pos=pos
	global_v.ehtime=global_v.iTime
	hit(dmg)
	
func refresh_hpmp2():
	is_alive=true
	hpmpb.disabled=false
	once=true
	hpmpv.visible=true
	global_v.ftime_b=-10.0

func _ready():
	pass

func _process(delta):
	if(once):
		if(!is_alive)&&(global_v.iTime-global_v.ftime_b>4.0):
			hpmpv.visible=false
			once=false
	if(!is_alive)&&(int(global_v.en_HPMP.y)>0):
		refresh_hpmp2()