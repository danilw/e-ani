extends Spatial

var extra_speed=0
var self_speed=10.5
var show_timer=1
var is_preload=false
var player_pos=Vector3()
var player_pos_l=Vector3()
var pposid=0
var start_pos=Vector3()
var selfID=0

var timer=0.0
const ttl=15

var la=Vector3()
var la_t=false
var host_alive=true

onready var global_v=get_tree().get_root().get_node("scene") #only player_pos

onready var a1=get_node("Area")
onready var a2=get_node("Area2")

onready var sq1=get_node("sq/frame1/a")
onready var sq2=get_node("sq/frame1/b")

onready var parts=get_node("sq/parts")

func _on_shoot_body2_entered(body):
	if(del_it):
		return
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")||body.is_in_group("player2")):
		body.test_hit(self.translation,selfID)
	if(body.is_in_group("chess")):
		body.test_hit(self.translation,selfID)

func _on_shoot_body_entered(body):
	if(del_it):
		return
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")||body.is_in_group("player2")):
		body.test_hit(self.translation,selfID)
	if(body.is_in_group("wall")):
		body.test_hit(self.translation,100)

func gen_pos():
	var a=Vector2(self.translation.x,self.translation.z)
	var b=Vector2(global_v.player_pos.x,global_v.player_pos.z)
	var c=Vector2(global_v.player_pos2.x,global_v.player_pos2.z)
	if((((a-b)).length())>(((a-c)).length())):
		pposid=1
	else:
		pposid=0

func get_pos():
	if(pposid==0):
		return global_v.player_pos
	else:
		return global_v.player_pos2

func _ready():
	if(is_preload):
		return
	gen_pos()
	player_pos=get_pos()
	start_pos=self.translation
	self_speed+=min(extra_speed,10)
	for a in range(a1.get_child_count()):
		a1.get_child(a).disabled=true
		a2.get_child(a).disabled=true
	
	sq1.scale.y=0.01
	sq2.scale.x=0.01
	la=player_pos
	la.y=max(la.y,self.translation.y)
	
	if is_network_master():
		a2.connect("body_entered",self,"_on_shoot_body2_entered")
		a1.connect("body_entered",self,"_on_shoot_body_entered")
	
	self.visible=true
	

func Spherex(p):
	var s=50
	return p.length()-s

var cfree=false
remotesync func free_shoot():
	cfree=true
	self.visible=false
	get_node("../").queue_free()

var show_anim=true
var once=true
var once_del=true
var del_it=false
var del_timer=0.0

puppet func on_del():
	for a in range(parts.get_child_count()):
		parts.get_child(a).emitting=false
	sq1.visible=false
	sq2.visible=false

puppet func upd_em():
		for a in range(a1.get_child_count()):
			a1.get_child(a).disabled=false
			a2.get_child(a).disabled=false
		for a in range(parts.get_child_count()):
			parts.get_child(a).emitting=true

puppet func update_tranform(scale1,scale2,transformx):
	self.transform=transformx
	sq1.scale=scale1
	sq2.scale=scale2

func _process(delta):
	if(is_preload):
		return
	if !is_network_master():
		return
	if(cfree):
		return
	if(del_it):
		if(once_del):
			rpc("on_del")
			a2.disconnect("body_entered",self,"_on_shoot_body2_entered")
			a1.disconnect("body_entered",self,"_on_shoot_body_entered")
			for a in range(parts.get_child_count()):
				parts.get_child(a).emitting=false
			sq1.visible=false
			sq2.visible=false
			once_del=false
		del_timer+=delta
		if(del_timer>8):
			rpc("free_shoot")
	else:
		timer+=delta
		if(show_anim):
			if(!host_alive):
				timer+=-2*delta
				if(timer<0):
					del_it=true
			var tpp=get_pos()
			tpp.y=max(tpp.y,self.translation.y)
			self.look_at(tpp,Vector3(0, 1, 0))
			sq1.scale.y=0.01+0.99*smoothstep(0,show_timer,timer)
			sq2.scale.x=0.01+0.99*smoothstep(0,show_timer,timer)
			show_anim=timer<=show_timer
		else:
			if(once):
				once=false
				player_pos_l=get_pos()
				player_pos_l+=(player_pos_l-la)*1.3 #simple predition movement
				player_pos_l.y=max(player_pos_l.y,self.translation.y)
				la_t=(self.translation-get_pos()).length()>3.8
				for a in range(a1.get_child_count()):
					a1.get_child(a).disabled=false
					a2.get_child(a).disabled=false
				for a in range(parts.get_child_count()):
					parts.get_child(a).emitting=true
				rpc("upd_em")
			var forward_dir = self.transform.basis.z.normalized()
			forward_dir=Vector3(0,0,-1)
			self.translate(forward_dir*delta*self_speed)
			if(la_t):
				la=la.linear_interpolate(player_pos_l,1.5*delta)
				var tla=la+(self.translation-start_pos)
				self.look_at(tla,Vector3(0, 1, 0))
		if(Spherex(self.translation+Vector3(-10.0,0.0,0.0))>=1)||(timer>ttl):
				del_it=true
	rpc("update_tranform",sq1.scale,sq2.scale,self.transform)