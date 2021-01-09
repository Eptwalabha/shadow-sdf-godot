extends Spatial

onready var fps : Label = $Infos/HBoxContainer/FPS as Label
onready var player : FPSPlayer = $FPSPlayer as FPSPlayer

var light : = Vector3(10.0, 2.0, 10.0);
var time := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_ui()

func _process(delta: float) -> void:
	time += delta
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()

	if Input.is_action_just_pressed("toggle_shader"):
		toggle("shader")
	if Input.is_action_just_pressed("toggle_shadow"):
		toggle("shadow")
	if Input.is_action_just_pressed("toggle_shadow_feather"):
		toggle("feather")
	if Input.is_action_just_pressed("toggle_normal"):
		toggle("normal")
	if Input.is_action_just_pressed("toggle_ao"):
		toggle("ao")

	fps.text = "fps: %s" % Engine.get_frames_per_second()
	$Pivot.rotate(Vector3.UP, delta * .1)
	player.shader.set_shader_param("light", $Pivot/Light.global_transform.origin)

func toggle(what: String) -> void:
	player.toggle(what)
	update_ui()

func update_ui() -> void:
	if not player.shader is ShaderMaterial:
		return
	var enable = player.shader.get_shader_param("enable")
	var normal = enable and player.shader.get_shader_param("normal_enable")
	var shadow = enable and player.shader.get_shader_param("shadow_enable")
	var ao = shadow and player.shader.get_shader_param("ao_enable")
	var feather = shadow and player.shader.get_shader_param("feather_enable")
	$Infos/HBoxContainer/VBoxContainer/Shader.text = "shader: %s" % enable
	$Infos/HBoxContainer/VBoxContainer/Shadow.text = "shadow: %s" % shadow
	$Infos/HBoxContainer/VBoxContainer/Feather.text = "shadow feather: %s" % feather
	$Infos/HBoxContainer/VBoxContainer/Normal.text = "normal: %s" % normal
	$Infos/HBoxContainer/VBoxContainer/AO.text = "ao: %s" % ao
