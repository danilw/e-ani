extends StaticBody

onready var global_v=get_tree().get_root().get_node("scene")
onready var hpmpv=global_v.get_node("floor/visible_/main_en/shield/s")

var is_alive=true
var gtimer=0.0

func hit(dmg):
	if(!is_alive):
		return
	global_v.en_HPMP.x+=-dmg
	global_v.en_HPMP.x=max(global_v.en_HPMP.x,0)
	is_alive=!(int(global_v.en_HPMP.x)==0)
	if(!is_alive):
		gtimer=0.0
		global_v.ground+=1
		global_v.heal_player=true
		global_v.heal_player2=true
		global_v.round_reseda=true
		global_v.round_resedb=true
		global_v.get_node("UI_panels/vnc/r").text="Round "+str(global_v.ground)
		hpmpv.visible=false
	

puppet func test_hit_m(pos,dmg):
	global_v.eh_pos=pos
	global_v.ehtime=global_v.iTime
	hit(dmg)

func test_hit(pos,dmg):
	rpc("test_hit_m",pos,dmg)
	global_v.eh_pos=pos
	global_v.ehtime=global_v.iTime
	hit(dmg)

func refresh_hpmp():
	hpmpv.visible=false
	is_alive=true

func _ready():
	pass

func _process(delta):
	if(global_v.round_reseda&&(!is_alive)):
		gtimer+=delta
	if(global_v.round_reseda&&(gtimer>global_v.round_rtime)&&(!is_alive))&&(global_v.alive_en<1):
		global_v.round_reseda=false
		gtimer=0.0
		
		var tv=Vector2(global_v.ground,(global_v.ground)/1.35)
		global_v.en_HPMP=global_v.en_last_max_HPMP+global_v.en_last_max_HPMP/Vector2(1.5,1.75)+(global_v.en_base_HPMP*Vector2(max(1,tv.x-1),max(1,tv.y-1))+global_v.en_base_HPMP*tv)*tv
		global_v.en_HPMP=Vector2(max(global_v.en_HPMP.x,global_v.en_last_max_HPMP.x),max(global_v.en_HPMP.y,global_v.en_last_max_HPMP.y))
		global_v.en_last_max_HPMP=global_v.en_HPMP
		refresh_hpmp()