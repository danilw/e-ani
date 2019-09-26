extends Spatial

onready var global_v=get_tree().get_root().get_node("scene")

onready var p1=get_node("../main_player/l_s_h/futari/FutariParticles")
onready var p2=get_node("../main_player/r_s_h/futari/FutariParticles")

func _ready():
	pass

func upnause_parts(val):
	if(val):
		p1.speed_scale=0.001
		p2.speed_scale=0.001
	else:
		p1.speed_scale=1.0
		p2.speed_scale=1.0

func _input(event):
	if(event.is_action_pressed("menu_esc")):
		if(global_v.game_over):
			return
		if(!global_v.pleload_done):
			return
		#get_tree().paused=!get_tree().paused
		get_node("../").pause_go()
		#upnause_parts(get_tree().paused)