extends Spatial

onready var global_v=get_tree().get_root().get_node("scene")
onready var circle=get_node("circle/circle")
onready var HP=get_node("HP")
onready var MP=get_node("MP")
#onready var ring_vortex=get_node("futari/vortex")

func _ready():
	pass

func _process(delta):
	circle.rotate_y(deg2rad(30.0*delta))
	HP.get_surface_material(0).set("shader_param/value",global_v.en_HPMP.x/global_v.en_last_max_HPMP.x)
	MP.get_surface_material(0).set("shader_param/value",global_v.en_HPMP.y/global_v.en_last_max_HPMP.y)
	
	var tv=int(global_v.en_HPMP.x)
	var mm=false
	if(str(tv).length()>7):
		tv=tv/1000000
		mm=true
	HP.get_node("num").get_surface_material(0).set("shader_param/value",tv)
	HP.get_node("num").get_surface_material(0).set("shader_param/len",str(tv).length()-1)
	HP.get_node("num").get_surface_material(0).set("shader_param/mm",mm)
	tv=int(global_v.en_HPMP.y)
	mm=false
	if(str(tv).length()>7):
		tv=tv/1000000
		mm=true
	MP.get_node("num").get_surface_material(0).set("shader_param/value",tv)
	MP.get_node("num").get_surface_material(0).set("shader_param/len",str(tv).length()-1)
	MP.get_node("num").get_surface_material(0).set("shader_param/mm",mm)
	
	get_node("shield/s").process_material.set("shader_param/ppos",global_v.player_pos)
	get_node("shield/s").process_material.set("shader_param/h_pos",global_v.eh_pos)
	get_node("shield/s").process_material.set("shader_param/iTime",-global_v.ehtime+global_v.iTime)
	get_node("shield/s2").process_material.set("shader_param/ppos",global_v.player_pos)
	get_node("shield/s2").process_material.set("shader_param/h_pos",global_v.eh_pos)
	get_node("shield/s2").process_material.set("shader_param/iTime",-global_v.ehtime+global_v.iTime)
	get_node("shield/s2").process_material.set("shader_param/r_speed",1.0+3.5*(1.0-global_v.en_HPMP.y/global_v.en_last_max_HPMP.y))
	get_node("shield/s2").process_material.set("shader_param/rest",(int(global_v.en_HPMP.y)==0)&&(global_v.iTime-global_v.ftime_b>4.0))
	get_node("shield/s2").process_material.set("shader_param/ftime",abs(global_v.iTime-4-global_v.ftime_b))

	get_node("orb/Icosphere/Icosphere_0").get_surface_material(0).set("shader_param/ena",global_v.alive_en>=1)
	
	#var a=Vector2(circle.transform.basis.get_rotation_quat().x,circle.transform.basis.get_rotation_quat().y)
	#var b=Vector2(circle.transform.basis.get_rotation_quat().z,circle.transform.basis.get_rotation_quat().w)
	#get_node("shield/s").process_material.set("shader_param/rquad_a",a)
	#get_node("shield/s").process_material.set("shader_param/rquad_b",b)