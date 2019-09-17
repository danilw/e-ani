extends Spatial

onready var global_v=get_tree().get_root().get_node("scene")
onready var board_map=global_v.board_map

var atimer=0.0
var gtimer=0.0
var once=true

const bsize=2

var elems=Array()
var elems_bonus=Array()
var sz=Vector2(7,8)
var b_mat

# I do not know is Array.duplicate safe
#and how it clean memory(array of arrays) if use each frame
# if it unsafe use this and for-loop to copy
#var board_map_tmp=Array()

func gen_board():
	for a in range(sz.x):
		board_map.append(Array())
		for b in range(sz.y):
			var v=Array()
			v.append(Vector2(0,0)) #pos
			v.append(0) #id
			v.append(false) #state
			board_map[board_map.size()-1].append(v)
	#board_map_tmp=board_map.duplicate(true)

func _ready():
	var elemp=preload("res://character/chess/v2/p.tscn")
	var eleml=preload("res://character/chess/v2/l.tscn")
	var elemh=preload("res://character/chess/v2/h.tscn")
	var elemsl=preload("res://character/chess/v2/s.tscn")
	var elemq=preload("res://character/chess/v2/q.tscn")
	var elemk=preload("res://character/chess/v2/k.tscn")
	elems=[elemp,eleml,elemh,elemsl,elemq,elemk]
	
	var elem_a=preload("res://character/coin/purp.tscn")
	var elem_b=preload("res://character/coin/blue.tscn")
	var elem_c=preload("res://character/coin/yellow.tscn")
	elems_bonus=[elem_a,elem_b,elem_c]
	
	b_mat=load("res://character/chess/v2/Material_003.material") as Material
	
	gen_board()

var que=Array()
var max_q=sz.x*sz.y
func add_child_unlag(s):
	if(que.size()>=max_q):
		board_map[s.self_idx.x][s.self_idx.y][2]=false
		if(s.bonus_in!=null):
			s.bonus_in.queue_free()
		s.queue_free()
		return false
	
	que.append(s)
	return true

func upd_child_unlag(frame):
	if(int(frame)%65==0):
		var osz=que.size()
		for a in range(min(3,osz)):
			self.call_deferred("add_child",que[osz-a-1])
			que.remove(osz-a-1)

func gen_bonus(bval):
	if(!bval):
		return null
	var rnd=int(rand_range(0,2.9))
	if((global_v.bonus_a)&&(rnd==0))||((global_v.bonus_b)&&(rnd==1))||((global_v.bonus_c)&&(rnd==2)):
		var s=elems_bonus[rnd].instance()
		s.self_type=rnd
		return s
	else:
		return null

func spwn_r0(bval):
#	for a in range(sz.x):
#		for b in range(sz.y):
#			board_map_tmp[a][b][2]=board_map[a][b][2]
	var board_map_tmp=board_map.duplicate(true)
	for a in range(2):
		for b in range(4):
			if(!board_map_tmp[a][b+2][2]):
				board_map[a][b+2][0]=Vector2(a,b+2)
				var c=0
				if(a==0):
					c=5-(2-b)
					if(2-b<0):c=5-abs(2-b)-1
				board_map[a][b+2][1]=c
				board_map[a][b+2][2]=true
	for a in range(sz.x):
		for b in range(sz.y):
			if(board_map[a][b][2])&&(!board_map_tmp[a][b][2]):
				var s=elems[board_map[a][b][1]].instance()
				s.translation.z=(board_map[a][b][0].x-4+1.5)*2
				s.translation.x=(board_map[a][b][0].y-4+0.5)*2
				s.pause_time=1+(a*sz.x+b)/5.0
				s.self_idx=board_map[a][b][0]
				s.self_id=board_map[a][b][1]
				s.bonus_in=gen_bonus(bval)
				s.b_mat=b_mat
				if(b-4>=0):
					s.self_mat=0
				else:
					s.self_mat=1
				s.rand_rot=((PI/2)*(2-int(4*randf())))
				if(!add_child_unlag(s)):
					return

func spwn_r1(bval):
#	for a in range(sz.x):
#		for b in range(sz.y):
#			board_map_tmp[a][b][2]=board_map[a][b][2]
	var board_map_tmp=board_map.duplicate(true)
	for a in range(2):
		for b in range(sz.y):
			if(!board_map_tmp[a][b][2]):
				board_map[a][b][0]=Vector2(a,b)
				var c=0
				if(a==0):
					c=5-abs(b-4)
					if(b-4>0):c=5-abs(b-4)-1
				board_map[a][b][1]=c
				board_map[a][b][2]=true
	for a in range(sz.x):
		for b in range(sz.y):
			if(board_map[a][b][2])&&(!board_map_tmp[a][b][2]):
				var s=elems[board_map[a][b][1]].instance()
				s.translation.z=(board_map[a][b][0].x-4+1.5)*2
				s.translation.x=(board_map[a][b][0].y-4+0.5)*2
				s.pause_time=1+(a*sz.x+b)/5.0
				s.self_idx=board_map[a][b][0]
				s.self_id=board_map[a][b][1]
				s.bonus_in=gen_bonus(bval)
				s.b_mat=b_mat
				s.self_mat=0
				s.rand_rot=((PI/2)*(2-int(4*randf())))
				if(!add_child_unlag(s)):
					return

func spwn_r2(bval):
#	for a in range(sz.x):
#		for b in range(sz.y):
#			board_map_tmp[a][b][2]=board_map[a][b][2]
	var board_map_tmp=board_map.duplicate(true)
	for a in range(4):
		for b in range(sz.y):
			var ta=a-1
			if(ta>0):
				ta=sz.x-(a-2)-1
			else:
				ta=abs(ta)
			if(!board_map_tmp[ta][b][2]):
				board_map[ta][b][0]=Vector2(ta,b)
				var c=0
				if(ta==0)||(ta==sz.x-1):
					var tb=b
					if(a-1>0):
						tb=(sz.y-1)-b
					c=5-abs(tb-4)
					if(tb-4>0):c=5-abs(tb-4)-1
				board_map[ta][b][1]=c
				board_map[ta][b][2]=true
			
	for a in range(sz.x):
		for b in range(sz.y):
			if(board_map[a][b][2])&&(!board_map_tmp[a][b][2]):
				var s=elems[board_map[a][b][1]].instance()
				s.translation.z=(board_map[a][b][0].x-4+1.5)*2
				s.translation.x=(board_map[a][b][0].y-4+0.5)*2
				s.pause_time=1+(a*sz.x+b)/5.0
				s.self_idx=board_map[a][b][0]
				s.self_id=board_map[a][b][1]
				s.bonus_in=gen_bonus(bval)
				s.b_mat=b_mat
				if(a-4>=0):
					s.self_mat=1
				else:
					s.self_mat=0
				s.rand_rot=((PI/2)*(2-int(4*randf())))
				if(!add_child_unlag(s)):
					return

func spwn_rX(xx,bval):
#	for a in range(sz.x):
#		for b in range(sz.y):
#			board_map_tmp[a][b][2]=board_map[a][b][2]
	var board_map_tmp=board_map.duplicate(true)
	for a in range(min(xx,sz.x)):
		for b in range(sz.y):
			if(!board_map_tmp[a][b][2]):
				board_map[a][b][0]=Vector2(a,b)
				board_map[a][b][1]=int(rand_range(0,5))
				board_map[a][b][2]=true
	for a in range(sz.x):
		for b in range(sz.y):
			if(board_map[a][b][2])&&(!board_map_tmp[a][b][2]):
				var s=elems[board_map[a][b][1]].instance()
				s.translation.z=(board_map[a][b][0].x-4+1.5)*2
				s.translation.x=(board_map[a][b][0].y-4+0.5)*2
				s.pause_time=3+(a*sz.x+b)/5.0
				s.self_idx=board_map[a][b][0]
				s.self_id=board_map[a][b][1]
				s.bonus_in=gen_bonus(bval)
				s.b_mat=b_mat
				s.self_mat=(a*int(sz.x)+b+1)%2
				s.rand_rot=((PI/2)*(2-int(4*randf())))
				if(!add_child_unlag(s)):
					return

func _process(delta):
	if(!global_v.pleload_done):
		return
	if(global_v.add_figs):
		atimer+=delta
	if(global_v.round_resedb):
		gtimer+=delta
	var a=(global_v.round_resedb&&((gtimer>global_v.round_rtime)||(global_v.ground==0)))&&(global_v.alive_en<1)
	var b=((!global_v.round_resedb)&&global_v.add_figs&&(atimer>global_v.round_rtime*1.5))
	upd_child_unlag(global_v.iFrame)
	if(a||b):
		global_v.round_resedb=false
		global_v.add_figs=false
		atimer=0.0
		gtimer=0.0
		if(global_v.ground==0):
			#spwn_rX(100,!b) #debug
			spwn_r0(!b)
		if(global_v.ground==1):
			spwn_r1(!b)
		if(global_v.ground==2):
			spwn_r2(!b)
		if(global_v.ground>2):
			spwn_rX(global_v.ground,!b)











