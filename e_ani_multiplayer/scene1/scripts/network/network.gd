extends Spatial

var game_start=false

const DEFAULT_PORT = 8910

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(_id):
	status_t.set_text("Connecting ......")
	status_t.get("custom_styles/normal").bg_color=Color("2eb840")
	yield(get_tree().create_timer(.10), "timeout")
	get_node("network_menu").visible=false
	var world = load("res://scene1/scene.tscn").instance()
	get_tree().get_root().call_deferred("add_child",world,true)

func _player_disconnected(_id):
	if has_node("../scene"):
		get_node("../scene").free()
	get_node("network_menu").visible=true
	if get_tree().is_network_server():
		set_status_t("Client disconnected",false)
	else:
		set_status_t("Server disconnected",false)

func _connected_ok():
	pass

func _connected_fail():
	get_node("network_menu").visible=true
	set_status_t("Couldn't connect",false)
	
	get_tree().set_network_peer(null)

func _server_disconnected():
	get_node("network_menu").visible=true
	if has_node("../scene"):
		get_node("../scene").free()
	set_status_t("Server disconnected",false)


func _on_singlep_pressed():
	if(game_start):
		return
	game_start=true
	get_node("network_menu").visible=false
	var world = load("res://scene1/scene.tscn").instance()
	get_tree().get_root().call_deferred("add_child",world,true)
	

onready var bt_sp=get_node("network_menu/sc/btns/singlep")
onready var bt_ho=get_node("network_menu/sc/btns/host")
onready var bt_jo=get_node("network_menu/sc/btns/join")
onready var ip_t=get_node("network_menu/sc/btns/ip/ip")
onready var wait_p=get_node("network_menu/sc/btns/wait")
onready var status_t=get_node("network_menu/sc/btns/wait/status")

func set_status_t(text, b):
	if(b):
		status_t.get("custom_styles/normal").bg_color=Color("2e40b8")
	else:
		status_t.get("custom_styles/normal").bg_color=Color("b8402e")
	status_t.set_text(str(text))

func host_it():
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(DEFAULT_PORT, 1) # max: 1 peer, since it's a 2 players game
	if err != OK:
		#is another server running?
		set_status_t("Err:address in use",false)
		return
	
	get_tree().set_network_peer(host)
	set_status_t("waiting player ...", true)

func join_it():
	var ip = ip_t.get_text()
	if not ip.is_valid_ip_address():
		set_status_t("IP is invalid", false)
		return
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
	set_status_t("Connecting..", true)


func _on_host_pressed():
	if(game_start):
		return
	game_start=true
	bt_sp.disabled=true
	bt_ho.disabled=true
	bt_jo.disabled=true
	ip_t.editable=false
	wait_p.visible=true
	host_it()


func _on_join_pressed():
	if(game_start):
		return
	game_start=true
	bt_sp.disabled=true
	bt_ho.disabled=true
	bt_jo.disabled=true
	ip_t.editable=false
	wait_p.visible=true
	join_it()


func _on_canc_pressed():
	bt_sp.disabled=false
	bt_ho.disabled=false
	bt_jo.disabled=false
	ip_t.editable=true
	wait_p.visible=false
	if has_node("../scene"):
		get_node("../scene").free()
	get_tree().set_network_peer(null)
	get_tree().reload_current_scene()
