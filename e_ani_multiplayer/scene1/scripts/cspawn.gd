extends MeshInstance


var max_time=2.0
var timer=0.0

onready var pause_time=get_node("../../../").pause_time
onready var rand_rot=get_node("../../../").rand_rot

var once=true

func _ready():
	get_surface_material(0).set("shader_param/cval",0)
	get_child(0).translation.y=-1.0

func _process(delta):
	var l_timer=max(timer-pause_time,0)
	if(once):
		if(l_timer>max_time*2):
			once=false
			get_surface_material(0).set("shader_param/act",false)
			get_node("../").is_anim_end=true
		else:
			var v=smoothstep(0,1,l_timer/max_time)
			var va=smoothstep(0.5,2.0,l_timer/max_time)
			var aab=self.get_aabb().size+Vector3(0,0.15,0)
			get_child(0).translation.y=max(v*aab.y-aab.y/2.0,-get_node("../../").translation.y+0.02)
			get_child(0).get_surface_material(0).set("shader_param/bsz",aab)
			get_child(0).get_surface_material(0).set("shader_param/timer",l_timer/max_time)
			get_child(0).rotate_y(0.08*v*smoothstep(0.3,0.0,va))
			get_surface_material(0).set("shader_param/cval",v)
			get_surface_material(0).set("shader_param/timer",va)
			get_surface_material(0).set("shader_param/bsz",aab)
			get_surface_material(0).set("shader_param/act",true)
	timer+=delta