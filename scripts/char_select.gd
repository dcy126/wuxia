extends Control

@onready var char_list = %CharList
@onready var portrait_label = %PortraitLabel
@onready var name_label = %NameLabel
@onready var desc_label = %DescLabel
@onready var hp_label = %HPLabel
@onready var atk_label = %AtkLabel
@onready var spd_label = %SpdLabel
@onready var confirm_btn = %ConfirmBtn
@onready var back_btn = %BackBtn

var characters = [
	{"name": "云飞扬", "desc": "剑法飘逸，行侠仗义", "icon": "🗡️", "hp": 85, "atk": 90, "spd": 80},
	{"name": "柳如烟", "desc": "暗器无双，来去无踪", "icon": "🌸", "hp": 70, "atk": 85, "spd": 95},
	{"name": "铁无双", "desc": "拳脚刚猛，铁骨铮铮", "icon": "👊", "hp": 95, "atk": 80, "spd": 65},
	{"name": "慕容琴", "desc": "琴音惑敌，医术济世", "icon": "🎵", "hp": 75, "atk": 70, "spd": 75},
]
var current_index = 0

func _ready():
	back_btn.pressed.connect(_on_back_pressed)
	confirm_btn.pressed.connect(_on_confirm_pressed)
	if Globals.pending_character:
		characters.append(Globals.pending_character)
		Globals.pending_character = null
	_create_char_buttons()

func _create_char_buttons():
	var entry_scene = preload("res://scenes/char_select/char_entry.tscn")
	for i in range(characters.size()):
		var c = characters[i]
		var entry = entry_scene.instantiate()
		entry.get_node("VBox/AvatarLabel").text = c.icon
		entry.get_node("VBox/NameLabel").text = c.name
		var idx = i
		entry.pressed.connect(_on_char_selected.bind(idx))
		char_list.add_child(entry)

	var create_entry = entry_scene.instantiate()
	create_entry.get_node("VBox/AvatarLabel").text = "＋"
	create_entry.get_node("VBox/NameLabel").text = "创建角色"
	create_entry.pressed.connect(_on_create_char_pressed)
	char_list.add_child(create_entry)

	show_character(0)

func show_character(index: int):
	current_index = index
	var c = characters[index]
	portrait_label.text = c.icon
	name_label.text = c.name
	desc_label.text = c.desc
	hp_label.text = "气血：" + str(c.hp)
	atk_label.text = "攻击：" + str(c.atk)
	spd_label.text = "身法：" + str(c.spd)

	for i in range(char_list.get_child_count()):
		var entry = char_list.get_child(i)
		if entry is Button:
			var name_label_node = entry.get_node("VBox/NameLabel")
			name_label_node.add_theme_color_override("font_color", Color(0.929, 0.82, 0.561, 1) if i == index else Color(0.745, 0.745, 0.71, 1))

func _on_char_selected(index: int):
	show_character(index)

func _on_create_char_pressed():
	get_tree().change_scene_to_file("res://scenes/char_create/char_create.tscn")

func _on_confirm_pressed():
	if characters.size() > current_index:
		Globals.current_character = characters[current_index]
	get_tree().change_scene_to_file("res://scenes/world_map/world_map.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
