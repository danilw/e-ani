extends RigidBody

var start_pos=Vector3()
var stop_time=0.0

var hpx=1000
var is_alive=true
var del_timer=0

onready var global_v=get_tree().get_root().get_node("scene")

func _ready():
	start_pos=self.translation+Vector3(0.0,01.0,0.0)
	if !is_network_master():
		self.mode=RigidBody.MODE_KINEMATIC

puppet func update_tranform(transformx):
	self.transform=transformx

remotesync func hit(dmg):
	if(!is_alive):
		return
	hpx+=-dmg
	hpx=max(hpx,0)
	is_alive=!(int(hpx)==0)
	if(!is_alive):
		for a in self.get_child_count():
			if self.get_child(a) is MeshInstance:
				self.get_child(a).visible=false
			if (self.get_child(a) is FutariParticles)&&(!global_v.no_parts):
				self.get_child(a).visible=true
				self.get_child(a).emitting=true
		self.mode=RigidBody.MODE_KINEMATIC
		for a in self.get_child_count():
			if self.get_child(a) is CollisionShape:
				self.get_child(a).disabled=true

func test_hit(pos, dmg):
	rpc("hit",dmg)

var cfree=false
remotesync func free_block():
	cfree=true
	self.visible=false
	self.queue_free()

func Spherex(p):
	var s=50
	return p.length()-s

func _process(delta):
	if !is_network_master():
		return
	if(cfree):
		return
	if(!is_alive):
		del_timer+=delta
	if(del_timer>10.0):
		rpc("free_block")
	if(is_alive):
		if(Spherex(self.translation+Vector3(-10.0,0.0,0.0))>1)&&(self.mode==RigidBody.MODE_RIGID):
			self.mode=RigidBody.MODE_KINEMATIC
			self.set_visible(false)
			stop_time=global_v.iTime
		if(global_v.iTime-stop_time>5.0)&&(self.mode==RigidBody.MODE_KINEMATIC):
			self.translation=start_pos
			self.mode=RigidBody.MODE_RIGID
			self.set_visible(true)
	rpc("update_tranform",self.transform)
