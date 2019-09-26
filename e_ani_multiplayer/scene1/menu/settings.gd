extends GridContainer

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	pass

func upd_resize_ed():
	get_node("sc/btns/HBoxContainer12/res_x").text=str(get_viewport().get_size().x)
	get_node("sc/btns/HBoxContainer12/res_y").text=str(get_viewport().get_size().y)

func _process(delta):
	if(self.visible)&&(!cres):
		upd_resize_ed()

func _on_fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen


func _on_GI_pressed():
	get_node("../GIProbe1").set_visible(!get_node("../GIProbe1").visible)
	get_node("../GIProbe2").set_visible(!get_node("../GIProbe2").visible)


func _on_Back_pressed():
	self.set_visible(false)
	get_node("../menu").set_visible(true)
	get_node("../bg3").set_visible(true)


func _on_ssr_pressed():
	var ov=global_v.main_cam.environment.is_ssr_enabled()
	global_v.main_cam.environment.set_ssr_enabled(!ov)


func _on_msaa_value_changed(value):
	get_viewport().set_msaa(value)


func _on_fow_value_changed(value):
	global_v.main_cam.set_fov(value)


var state_transp=false
func _on_transp_pressed():
	state_transp=!state_transp
	if(state_transp):
		get_node("../main_player/model/skeleton/s/Skeleton/Mesh 2").mesh.surface_get_material(0).flags_transparent=1
		get_node("../main_player/model/skeleton/s/Skeleton/Mesh").mesh.surface_get_material(0).refraction_enabled=0
	else:
		get_node("../main_player/model/skeleton/s/Skeleton/Mesh 2").mesh.surface_get_material(0).flags_transparent=0
		get_node("../main_player/model/skeleton/s/Skeleton/Mesh").mesh.surface_get_material(0).refraction_enabled=1

master func upd_e(el):
	global_v.mouse_aim_e2=el

func _on_mouse_aim_pressed():
	global_v.mouse_aim_e=!global_v.mouse_aim_e
	if !is_network_master():
		global_v.mouse_aim_e2=global_v.mouse_aim_e
		rpc("upd_e",global_v.mouse_aim_e)

func rec_node(b):
	if (b.get_child_count()>0):
		for a in b.get_child_count():
			if (b.get_child(a).get_child_count()>0):
				rec_node(b.get_child(a))
			else:
				if(b.get_child(a) is SpotLight) or (b.get_child(a) is OmniLight):
					b.get_child(a).visible=!b.get_child(a).visible
	else:
		if(b is SpotLight) or (b is OmniLight):
			b.visible=!b.visible

func _on_light_pressed():
	var b=get_node("../floor/visible_/lamps")
	for a in b.get_child_count():
		rec_node(b.get_child(a))
	


func _on_glow_pressed():
	var ov=global_v.main_cam.environment.is_glow_enabled()
	global_v.main_cam.environment.set_glow_enabled(!ov)


func _on_grass_pressed():
	var b=get_node("../floor/visible_/borders/borders5")
	for a in b.get_child_count():
		for ab in b.get_child(a).get_child_count():
			if (b.get_child(a).get_child(ab) is MultiMeshInstance):
				b.get_child(a).get_child(ab).visible=!b.get_child(a).get_child(ab).visible

var cres=false
const STRETCH_MODE_2D = 1 
const STRETCH_MODE_VIEWPORT = 2 
const STRETCH_ASPECT_IGNORE = 0
const STRETCH_ASPECT_KEEP = 1

func _on_resol_pressed():
	cres=!cres
	get_node("sc/btns/HBoxContainer12/res_x").editable=cres
	get_node("sc/btns/HBoxContainer12/res_y").editable=cres
	get_node("sc/btns/HBoxContainer12/appl").disabled=!cres
	if(!cres):
		global_v.iResolution=Vector2(1280,720)
		get_tree().set_screen_stretch(STRETCH_MODE_2D,STRETCH_ASPECT_IGNORE,Vector2(1280,720))
	else:
		global_v.iResolution=Vector2(1280,720)
		get_tree().set_screen_stretch(STRETCH_MODE_VIEWPORT,STRETCH_ASPECT_KEEP,Vector2(1280,720))
	get_node("../menu").rect_scale=Vector2(1,1)
	get_node("../UI_panels/vnc/r").get("custom_fonts/font").set_size(25)
	upd_resize_ed()


func _on_appl_pressed():
	var a=(get_node("sc/btns/HBoxContainer12/res_x").text)
	if(int(a)<32):
		return
	var b=(get_node("sc/btns/HBoxContainer12/res_y").text)
	if(int(b)<32):
		return
	get_tree().set_screen_stretch(STRETCH_MODE_VIEWPORT,STRETCH_ASPECT_KEEP,Vector2(int(a),int(b)))
	global_v.iResolution=Vector2(int(a),int(b))
	get_node("../menu").rect_scale=Vector2(int(a),int(b))/Vector2(1280,720)
	get_node("../UI_panels/vnc/r").get("custom_fonts/font").set_size(25*(int(b)/float(720)))


func rec_node_sh(b):
	if (b.get_child_count()>0):
		for a in b.get_child_count():
			if (b.get_child(a).get_child_count()>0):
				rec_node_sh(b.get_child(a))
			else:
				if(b.get_child(a) is SpotLight) or (b.get_child(a) is OmniLight):
					b.get_child(a).shadow_enabled=!b.get_child(a).shadow_enabled
	else:
		if(b is SpotLight) or (b is OmniLight):
			b.shadow_enabled=!b.shadow_enabled

func _on_shadows_pressed():
	var x=get_node("sc/btns/HBoxContainer3/shadows2")
	x.disabled=!x.disabled
	var l=get_node("../DirectionalLight")
	l.shadow_enabled=!l.shadow_enabled
	var b=get_node("../floor/visible_/lamps")
	for a in b.get_child_count():
		rec_node_sh(b.get_child(a))
	

func _on_shadows2_pressed():
	var f=get_node("../floor/visible_/floor")
	f.cast_shadow=!f.cast_shadow
	f=get_node("../floor/visible_/floor3/floor_a/f")
	f.cast_shadow=!f.cast_shadow
	f=get_node("../floor/visible_/borders/borders1/blocks_border")
	f.cast_shadow=!f.cast_shadow
	f=get_node("../floor/visible_/borders/borders1/blocks_border2")
	f.cast_shadow=!f.cast_shadow
	f=get_node("../floor/visible_/borders/borders1/blocks_border3")
	f.cast_shadow=!f.cast_shadow
	f=get_node("../floor/visible_/borders/borders1/blocks_border4")
	f.cast_shadow=!f.cast_shadow
	f=get_node("../floor/visible_/borders/borders3")
	for a in f.get_child_count():
		for b in f.get_child(a).get_child_count():
			f.get_child(a).get_child(b).cast_shadow=!f.get_child(a).get_child(b).cast_shadow
	
	f=get_node("../floor/visible_/borders/borders5")
	for a in f.get_child_count():
		for b in f.get_child(a).get_child_count():
			f.get_child(a).get_child(b).cast_shadow=!f.get_child(a).get_child(b).cast_shadow


func _on_less_pa_pressed():
	global_v.no_parts=!global_v.no_parts
	var a=get_node("../floor/visible_/decor/tree/FutariParticles")
	a.emitting=!a.emitting
	a= get_node("../floor/visible_/floor2/ice/FutariParticles")
	a.emitting=!a.emitting

master func upd_ee(el):
	global_v.mouse_aim_ee2=el

func _on_mouse_eaim_pressed():
	global_v.mouse_aim_ee=!global_v.mouse_aim_ee
	if !is_network_master():
		global_v.mouse_aim_ee2=global_v.mouse_aim_ee
		rpc("upd_ee",global_v.mouse_aim_ee)


func _on_fps_l_pressed():
	var x=get_node("sc/btns/HBoxContainer/aply_fps")
	x.disabled=!x.disabled
	x=get_node("sc/btns/HBoxContainer/fps")
	x.editable=!x.editable
	if(!x.editable):
		get_node("sc/btns/HBoxContainer/fps").text=str(0)
		Engine.set_target_fps(0)
	if(x.editable):
		get_node("sc/btns/HBoxContainer/fps").text=str(60)
		Engine.set_target_fps(60)


func _on_aply_fps_pressed():
	var a=(get_node("sc/btns/HBoxContainer/fps").text)
	if(int(a)>=15):
		Engine.set_target_fps(int(a))


func _on_vsync_pressed():
	OS.vsync_enabled=!OS.vsync_enabled
