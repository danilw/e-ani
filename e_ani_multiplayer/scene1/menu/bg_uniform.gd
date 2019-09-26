extends ColorRect

onready var global_v=get_tree().get_root().get_node("scene")
var iTime=0.0

func _ready():
	pass

func _process(delta):
	self.material.set("shader_param/iTime",iTime)
	self.material.set("shader_param/idx",global_v.idx)
	if(global_v.paused):
		iTime+=delta
	else:
		iTime=0.0