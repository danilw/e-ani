extends Spatial

var iTime=0.0
var iFrame=0

var pleload_once=false
var pleload_done=false
var preload_time=0.0

var paused=false
var ptime=0.0
var idx=false
var player_pos=Vector3() #player pos
var player_rot=0 #rotation for camera
var FPS_s=1.0 
var iMouse=Vector3() #mouse xy
var iMouse_d=Vector2() #mouse press
var iMouse_3d=Vector3() #camera mouse
var iMouse_3d_normal=Vector3() #camera mouse
var iResolution=Vector2(1280,720) #to fix godot viewport rescale
var en_base_HPMP=Vector2(100.0,100.0)
var en_last_max_HPMP=en_base_HPMP
var en_HPMP=en_base_HPMP #boss hp
const round_rtime=5.5
var ground=0 #round
var add_figs=false
var round_reseda=true
var round_resedb=true
var mouse_aim_e=false #setting
var mouse_aim_ee=false #setting
var eh_pos=Vector3()
var ehtime=-10.0
var no_parts=false #setting
var ftime_b=-10.0

var sIDs=0 #ID for enemy bullets, to hit once

var game_over=false
var heal_player=false #heal on end of round

var bonus_a=true
var bonus_b=true
var bonus_c=true


var blocks_counter=23*4 #to keep alive for particles, size in wall_hit&staticwallgen
var active_blocks_c=0
const max_ph_blocks=12 #max blocks animated physics at same time
var blocks_map=Array()

var active_blocks_cc=0
const max_c_blocks=12 #max chess animated physics at same time
var board_map=Array()

const max_en_ph=6 #max_enemy 
var alive_en=0

func pause_go():
	paused=!paused
	get_node("menu").set_visible(paused)
	get_node("bg3").set_visible(paused)
	get_node("bg1").set_visible(paused)
	
	get_node("settings").set_visible(false)
	if(paused):
		ptime=iTime
		idx=!idx
	

func _ready():
	randomize()

func _process(delta):
	var m_pos=get_viewport().get_mouse_position()/iResolution
	iMouse=Vector3(m_pos.x*iResolution.x,iResolution.y*(1.0-m_pos.y),0)
	if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		iMouse.z=1
	
	if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		iMouse_d.x=min(iMouse_d.x+delta,1.0)
	else:
		iMouse_d.x=max(iMouse_d.x-delta,0.0)
		
	if(Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		iMouse_d.y=min(iMouse_d.y+delta,1.0)
	else:
		iMouse_d.y=max(iMouse_d.y-delta,0.0)
	
	FPS_s=1.0/max(delta,0.001)
	FPS_s=max(FPS_s,1.0)
	if(!get_tree().paused):
		iTime+=delta
		iFrame+=1
	if(pleload_once):
		pleload_once=false
		pleload_done=true
		iTime=iTime-preload_time

func _on_play_pressed():
	get_tree().paused=false
	get_node("mp").upnause_parts(get_tree().paused)
	pause_go()
