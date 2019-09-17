extends Viewport

onready var iChannel=get_node("../iChannel0")
onready var iChannel_buf=get_node("../iChannel0_buf")

func _ready():
	var tc=iChannel_buf.get_viewport().get_texture()
	tc.flags=Texture.FLAG_FILTER
	iChannel.get_child(0).material.set("shader_param/iChannel0",tc)
