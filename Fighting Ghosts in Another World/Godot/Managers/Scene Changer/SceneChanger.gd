extends Node

#############################################################
# Credit to Tiny Legions (YouTube) AKA PhillipWee (Github) #
#############################################################

signal changing_scene
signal scene_changed

export var max_load_time = 10000
export var LoadingScreen : PackedScene = null

var current_scene_path := ""

# Caller nodes must pass "self" as the current_scene
func goto_scene(path, show_loading_progress = false):
	var current_scene = get_current_scene()
	var loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		print("Resource loader unable to load the resource at path.")
		return
	
	var loading_screen = LoadingScreen.instance()
	get_tree().get_root().call_deferred("add_child", loading_screen)
	yield(loading_screen, "faded_in")
	current_scene.queue_free()
	
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() - t < max_load_time:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			#Loading Complete
			var resource = loader.get_resource()
			get_tree().get_root().call_deferred('add_child',resource.instance())
			current_scene_path = path
			loading_screen.fade_out()
			yield(loading_screen, "faded_out")
			emit_signal("scene_changed")
			break
		elif err == OK:
			#Still loading
			var progress = float(loader.get_stage())/loader.get_stage_count()
			loading_screen.set_loading_value(progress * 100, show_loading_progress)
		else:
			print("Error while loading file.")
			break
		yield(get_tree(),"idle_frame")


func reload_current_scene():
	goto_scene(current_scene_path)

func get_current_scene():
	var root_children = get_tree().get_root().get_children()
	var number_of_singletons = 5
	var current_scene = root_children[number_of_singletons]
	return current_scene
