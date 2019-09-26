extends Spatial

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	self.visible=false

var ctime=-10.0

func _process(delta):
	if (!global_v.mouse_aim_e)&&(Input.is_mouse_button_pressed(BUTTON_RIGHT)||Input.is_mouse_button_pressed(BUTTON_LEFT)):
		self.get_child(0).emitting=true
		self.get_child(1).emitting=true
		self.visible=true
		self.translation=Vector3(0.001,0.001,0.001)
		if is_network_master():
			self.look_at(global_v.iMouse_3d_normal,Vector3(0, 1, 0))
			self.translation=global_v.iMouse_3d
		else:
			self.look_at(global_v.iMouse_3d_normal2,Vector3(0, 1, 0))
			self.translation=global_v.iMouse_3d2
		ctime=global_v.iTime
	else:
		self.get_child(0).emitting=false
		self.get_child(1).emitting=false
		if(global_v.iTime-ctime>1.5):
			self.visible=false