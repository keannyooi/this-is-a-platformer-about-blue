extends Node

signal progress_changed(progress: Array)
signal load_complete()

var loading_screen_path: String = "res://util/loading_screen.tscn"
var loading_screen = load(loading_screen_path)
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_subthreads: bool = true


func load_scene(path: String) -> void:
	scene_path = path
	
	var new_loading_screen = loading_screen.instantiate()
	get_tree().get_root().add_child(new_loading_screen)
	
	self.progress_changed.connect(new_loading_screen.update_progress_bar)
	self.load_complete.connect(new_loading_screen.start_outro_animation)
	
	await new_loading_screen.loading_screen_has_full_coverage
	
	start_load()
	

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "PackedScene", use_subthreads)
	if state == OK:
		set_process(true)
	

func _ready() -> void:
	set_process(false)
	

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			return push_error("ERROR: failed to load level or level scene path invalid")
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_changed.emit(progress[0])
		ResourceLoader.THREAD_LOAD_LOADED:
			# ok we've finished loading, we can stop _process now
			progress_changed.emit(progress[0])
			set_process(false)
			
			load_complete.emit()
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(loaded_resource)
	
