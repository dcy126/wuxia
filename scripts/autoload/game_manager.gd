extends Node

class_name GameManager

signal game_started(save_data: Dictionary)
signal game_loaded(save_data: Dictionary)
signal game_saved(save_data: Dictionary)
signal game_exited()

enum GameState {
	MAIN_MENU,
	NEW_GAME,
	LOAD_GAME,
	SETTINGS,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MAIN_MENU
var current_save_slot: int = 1
var game_data: Dictionary = {}

func _ready() -> void:
	DontDestroyOnLoad = true
	_load_game_data()

func _load_game_data() -> void:
	var file = FileAccess.open("user://save_data.json", FileAccess.READ)
	if file:
		var json = JSON.parse_string(file.get_as_text())
		if json.error == OK:
			game_data = json.result
		file.close()

func _save_game_data() -> void:
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(game_data))
		file.close()

func new_game(slot: int = 1) -> void:
	current_save_slot = slot
	current_state = GameState.NEW_GAME
	game_data = _create_new_game_data()
	_save_game_data()
	game_started.emit(game_data)
	current_state = GameState.PLAYING

func load_game(slot: int = 1) -> bool:
	current_save_slot = slot
	var file = FileAccess.open("user://save_slot_%d.json" % slot, FileAccess.READ)
	if file:
		var json = JSON.parse_string(file.get_as_text())
		if json.error == OK:
			game_data = json.result
			current_state = GameState.LOAD_GAME
			_save_game_data()
			game_loaded.emit(game_data)
			current_state = GameState.PLAYING
			return true
		file.close()
	return false

func save_game(slot: int = -1) -> void:
	if slot == -1:
		slot = current_save_slot
	var file = FileAccess.open("user://save_slot_%d.json" % slot, FileAccess.WRITE)
	if file:
		game_data.last_save_time = Time.get_datetime_dict_from_system()
		file.store_string(JSON.stringify(game_data))
		file.close()
		game_saved.emit(game_data)

func _create_new_game_data() -> Dictionary:
	return {
		"player": {
			"name": "无名侠客",
			"gender": 0,
			"age": 18,
			"origin": "平民百姓",
			"attributes": {
				"strength": 10,
				"agility": 10,
				"constitution": 10,
				"intelligence": 10,
				"spirit": 10,
				"luck": 10
			},
			"skills": {},
			"inventory": [],
			"equipment": {},
			"reputation": {},
			"relationships": {},
			"location": "新手村",
			"cultivation": {
				"realm": "凡人",
				"exp": 0,
				"max_exp": 100
			},
			"health": 100,
			"max_health": 100,
			"inner_force": 50,
			"max_inner_force": 50
		},
		"world": {
			"current_chapter": 1,
			"unlocked_locations": ["新手村"],
			"completed_quests": [],
			"active_quests": [],
			"world_state": {}
		},
		"playtime": 0,
		"last_save_time": Time.get_datetime_dict_from_system()
	}

func exit_game() -> void:
	save_game()
	game_exited.emit()
	get_tree().quit()

func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false

func go_to_main_menu() -> void:
	save_game()
	current_state = GameState.MAIN_MENU
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_game_manager_game_started(save_data):
	print("游戏开始: ", save_data.player.name)

func _on_game_manager_game_loaded(save_data):
	print("游戏加载: ", save_data.player.name)

func _on_game_manager_game_saved(save_data):
	print("游戏已保存")

func _on_game_manager_game_exited():
	print("退出游戏")