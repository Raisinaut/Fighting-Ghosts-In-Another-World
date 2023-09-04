extends Node2D

export var chain_link_scene : PackedScene = null
export var link_size = 3
export var connecting_node : NodePath = ""

onready var base = $Base
onready var start_pos = base.global_position

var link_arr : Array = []


func _ready():
	if not connecting_node:
		return
	
	var end_pos = get_node(connecting_node).global_position
	
	# first "link" is the base
	link_arr.append(base)
	
	# make length a multiple of link size
	var chain_length : int = start_pos.distance_to(end_pos)
	if chain_length % link_size != 0:
		chain_length = stepify(chain_length, link_size)
	
	# instance links
	var num_links = chain_length / link_size
	for i in num_links:
		var l : Node2D = instance_link()
		link_arr.append(l)
		# adjust position
		l.global_position.y = self.global_position.y + (i * link_size)
		# alternate sprite
		l.set_turned(i % 2)
	
	if link_arr.size() > 1:
		var arr_size = link_arr.size()
		# skip base and last link
		for i in range(1, arr_size - 1):
			link_arr[i].set_attached_nodes(link_arr[i-1].get_path(), link_arr[i].get_path())
		# handle end separately
		var last_link = link_arr[arr_size - 1]
		last_link.set_attached_nodes(link_arr[arr_size - 2].get_path(), connecting_node)


func instance_link():
	var link_inst = chain_link_scene.instance()
	add_child(link_inst)
	return link_inst
