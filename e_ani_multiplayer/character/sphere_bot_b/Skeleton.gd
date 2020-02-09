extends Skeleton

#onready var global_v=get_tree().get_root().get_node("scene")
var static_rot=Array()

func _ready():
	for a in range(6):
		var md = Transform2D()
		md = md.translated(Vector2(0.5,0.0))
		md = md.rotated(PI/2+(PI/3)*(a-3))
		static_rot.append(md.get_origin())
	
	
#	get_node("../../../sh").get_child(0).mesh.radius=2
#	get_node("../../../sh").get_child(0).mesh.height=3.1
#	get_node("../../../sh").get_child(0).mesh.is_hemisphere=false
#	get_node("../../../sh").get_child(0).transform=Transform(Basis(Vector3(1, 0.000001, 0.000001), Vector3(0.000001, -0.280029, 0.959992), Vector3(-0, -0.959992, -0.280029)), Vector3(-0, -0.323152, 2.042352))
	

func _process(delta):
	
	var ttr=get_bone_global_pose(6)
#	get_node("../../../sh").get_child(0).transform=ttr
#	get_node("../../../sh").get_child(0).translation+=(2.0)*get_node("../../../sh").get_child(0).transform.basis.y
	
	for a in range(get_node("../../../parts_s").get_child_count()):
		get_node("../../../parts_s").get_child(a).transform=ttr
		get_node("../../../parts_s").get_child(a).translation+=(2.5-a*0.3)*get_node("../../../parts_s").get_child(a).transform.basis.y
	
	
	for a in range(get_node("../../../parts").get_child_count()):
		get_node("../../../parts").get_child(a).transform=get_bone_global_pose(32+a*2)
		#get_node("../../../parts").get_child(a).rotation=Vector3()
		
		#get_node("../../../parts").get_child(a).translation.x+=static_rot[a].x
		#get_node("../../../parts").get_child(a).translation.y+=static_rot[a].y

