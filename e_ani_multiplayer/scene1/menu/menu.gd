extends GridContainer

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	pass

func _on_settings_pressed():
	self.set_visible(false)
	get_node("../bg3").set_visible(false)
	get_node("../settings").set_visible(true)

const STRETCH_MODE_2D = 1 
const STRETCH_MODE_VIEWPORT = 2 
const STRETCH_ASPECT_IGNORE = 0
const STRETCH_ASPECT_KEEP = 1

func _on_restart_pressed():
	get_tree().paused=false
	global_v.iResolution=Vector2(1280,720)
	get_tree().set_screen_stretch(STRETCH_MODE_2D,STRETCH_ASPECT_IGNORE,Vector2(1280,720))
	get_node("../menu").rect_scale=Vector2(1,1)
	get_node("../UI_panels/vnc/r").get("custom_fonts/font").set_size(25)
	#get_tree().reload_current_scene()
	
	get_tree().set_network_peer(null)
	get_tree().reload_current_scene()
	global_v.queue_free()
	




