extends Position3D

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	#return
	var elema=preload("res://floor/stone_tiles/block_ed/block_mesh_ex.tscn")
	var elemb=preload("res://floor/stone_tiles/block_ed/block_mesh_ex_t.tscn")
	var na=23 #size in wall_hit&scene
	var nb=4
	for a in range(na):
		global_v.blocks_map.append(Array())
		var rda=min(int(rand_range(0,5)/3.0),1)
		for b in range(nb):
			global_v.blocks_map[global_v.blocks_map.size()-1].append(true)
			var rd=min(int(rand_range(0,5)/3.2),1)
			var s
			if(rd==1):
				s=elemb.instance()
			else:
				s=elema.instance()
			s.self_idx=Vector2(global_v.blocks_map.size()-1,global_v.blocks_map[global_v.blocks_map.size()-1].size()-1)
			rd=min(int(rand_range(0,5)/2.0),1)
			s.rotate_y(deg2rad(90))
			s.rotate_x(deg2rad(rd*180))
			rd=min(int(rand_range(0,5)/3.5),1)
			s.rotate_z(deg2rad(rd*180))
			s.translation.z=a*0.845-((na-1)/2)*0.845
			s.translation.x=sign(rda-0.5)*0.05+0.3*(1.0-cos(PI*(float(a)/(na-1)-0.5)))
			s.translation.y=0.64*(2.0*(float(b)/(nb-1)-0.5))
			self.call_deferred("add_child",s)
