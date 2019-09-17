extends Sprite

#udate uniforms

var iTime=0.0
var iFrame=0
var iMouse=Vector3(0.0,0.0,0.0)

func _ready():
	pass

func _process(delta):
	self.material.set("shader_param/iMouse",iMouse)
	self.material.set("shader_param/iTime",iTime)
	self.material.set("shader_param/iFrame",iFrame)
	if(!get_tree().paused):
		iTime+=delta
		iFrame+=1

