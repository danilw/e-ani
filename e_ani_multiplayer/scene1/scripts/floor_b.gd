extends Spatial

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	pass


func _process(delta):
	for a in range(self.get_child_count()):
		self.get_child(a).process_material.set("shader_param/iTime",global_v.iTime)
