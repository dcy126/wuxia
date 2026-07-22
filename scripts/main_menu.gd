extends Control

@onready var start_btn = %StartGameBtn
@onready var settings_btn = %SettingsBtn
@onready var char_preview_btn = %CharPreviewBtn

func _ready():
	start_btn.pressed.connect(_on_start_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	char_preview_btn.pressed.connect(_on_char_preview_pressed)
	setup_particles()

func setup_particles():
	_create_particle_material($BgParticles, 0.6)
	_create_particle_material($BgParticles2, 0.4)

func _create_particle_material(node: GPUParticles2D, alpha: float):
	var pm = ParticleProcessMaterial.new()
	pm.gravity = Vector3.ZERO
	pm.direction = Vector3.DOWN
	pm.spread = 180.0
	pm.initial_velocity_min = 10.0
	pm.initial_velocity_max = 30.0
	pm.scale_min = 0.5
	pm.scale_max = 1.5
	var c = Curve.new()
	c.add_point(Vector2(0, 1.0))
	c.add_point(Vector2(0.5, alpha))
	c.add_point(Vector2(1.0, 0.0))
	pm.alpha_curve = c
	pm.color = Color(0.85, 0.8, 0.7, alpha)
	node.process_material = pm

	var img = Image.create(2, 2, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	var tex = ImageTexture.create_from_image(img)
	node.texture = tex

func _on_char_preview_pressed():
	get_tree().change_scene_to_file("res://scenes/char_select/char_select.tscn")

func _on_start_pressed():
	var game_scene = load("res://scenes/game/game.tscn")
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		start_btn.text = "敬请期待"

func _on_settings_pressed():
	start_btn.text = "开发中..."

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
