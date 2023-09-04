extends Node2D


export var particle_scene : PackedScene = null
export(int, 0, 100) var quantity = 10

var queue : Array = []
var idx : int = 0


func _ready():
	for i in quantity:
		var p = instance_particle(particle_scene)
		queue.append(p)

func instance_particle(p_scene : PackedScene) -> Node2D:
	var p_inst = p_scene.instance()
	call_deferred("add_child", p_inst)
	return p_inst

func emit():
	var p : CPUParticles2D = queue[idx]
	if p.emitting:
		p.emitting = false
#	p.modulate = sample_pixel_color(global_position.x, global_position.y+2)
	p.emitting = true
	idx = wrapi(idx+1, 0, queue.size()-1)


func sample_pixel_color(x, y):
	var screen_image : Image = get_viewport().get_texture().get_data()
	screen_image.lock()
	return screen_image.get_pixel(x, y)
