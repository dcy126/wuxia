extends Control

enum Phase { QUIZ, ROLL }

var current_phase = Phase.QUIZ
var current_question = 0
var stats = {"hp": 50, "atk": 50, "spd": 50}
var talent = ""
var selected_avatar = "🗡️"
var current_tab = 0

var questions = [
	{
		"question": "你行走江湖，路遇一位老乞丐向你乞讨，你会？",
		"answers": [
			{"text": "慷慨解囊，倾囊相助", "hp": 10, "atk": 0, "spd": 0, "talent": "仁心"},
			{"text": "给他一些碎银便离去", "hp": 5, "atk": 3, "spd": 2, "talent": ""},
			{"text": "无视他，继续赶路", "hp": 0, "atk": 8, "spd": 5, "talent": "冷峻"},
			{"text": "打量一番，怀疑是骗子", "hp": 0, "atk": 2, "spd": 8, "talent": "机敏"},
		]
	},
	{
		"question": "江湖传言某处藏有绝世秘籍，你会？",
		"answers": [
			{"text": "立刻动身前往寻找", "hp": 3, "atk": 10, "spd": 5, "talent": ""},
			{"text": "先打听消息再做打算", "hp": 5, "atk": 3, "spd": 8, "talent": "谋略"},
			{"text": "将此消息告知好友同往", "hp": 8, "atk": 5, "spd": 3, "talent": "义气"},
			{"text": "嗤之以鼻，不屑于此", "hp": 10, "atk": 0, "spd": 0, "talent": "傲骨"},
		]
	},
	{
		"question": "遇到强敌拦路，对方武功远高于你，你选择？",
		"answers": [
			{"text": "正面迎战，绝不退缩", "hp": 5, "atk": 12, "spd": 0, "talent": "勇猛"},
			{"text": "利用地形周旋游击", "hp": 0, "atk": 5, "spd": 12, "talent": "灵巧"},
			{"text": "寻找对方破绽一击制敌", "hp": 3, "atk": 8, "spd": 5, "talent": "精明"},
			{"text": "暂避锋芒，日后再战", "hp": 10, "atk": 0, "spd": 5, "talent": "隐忍"},
		]
	},
	{
		"question": "你希望自己的武学风格偏向？",
		"answers": [
			{"text": "大开大合，刚猛霸道", "hp": 8, "atk": 12, "spd": 0, "talent": "刚猛"},
			{"text": "轻灵飘逸，以巧取胜", "hp": 0, "atk": 5, "spd": 12, "talent": "飘逸"},
			{"text": "攻守兼备，稳扎稳打", "hp": 10, "atk": 8, "spd": 5, "talent": ""},
			{"text": "出其不意，一招制敌", "hp": 3, "atk": 10, "spd": 8, "talent": "诡变"},
		]
	},
	{
		"question": "你如何看待江湖中的门派纷争？",
		"answers": [
			{"text": "积极参与，扬名立万", "hp": 5, "atk": 10, "spd": 5, "talent": "好战"},
			{"text": "明哲保身，独善其身", "hp": 10, "atk": 0, "spd": 8, "talent": "淡泊"},
			{"text": "从中斡旋，化解恩怨", "hp": 8, "atk": 3, "spd": 5, "talent": "调和"},
			{"text": "趁机壮大自己的势力", "hp": 3, "atk": 8, "spd": 10, "talent": "野心"},
		]
	},
]

@onready var quiz_ui = $QuizUI
@onready var roll_ui = $RollUI
@onready var question_label = $QuizUI/QuestionLabel
@onready var progress_label = $QuizUI/ProgressLabel
@onready var answer_container = $QuizUI/AnswerContainer
@onready var back_btn_quiz = $QuizUI/BackBtn

@onready var portrait_btn = %PortraitBtn
@onready var name_label = %NameLabel
@onready var edit_name_btn = %EditNameBtn
@onready var stats_tab_btn = %StatsTabBtn
@onready var talent_tab_btn = %TalentTabBtn
@onready var result_talent = %ResultTalent
@onready var result_hp = %ResultHP
@onready var result_atk = %ResultAtk
@onready var result_spd = %ResultSpd
@onready var dice_btn = %DiceBtn
@onready var confirm_btn = %ConfirmBtn
@onready var back_btn_roll = $RollUI/BackBtn
@onready var stats_tab = $RollUI/MainHBox/RightPanel/TabContent/StatsTab
@onready var talent_tab = $RollUI/MainHBox/RightPanel/TabContent/TalentTab

@onready var name_dialog = %NameDialog
@onready var name_input = %NameInput
@onready var name_confirm_btn = %NameConfirmBtn
@onready var name_cancel_btn = %NameCancelBtn

@onready var avatar_dialog = %AvatarDialog
@onready var avatar_grid_dialog = %AvatarGrid
@onready var avatar_dialog_confirm = %AvatarDialogConfirm

func _ready():
	back_btn_quiz.pressed.connect(_on_back_pressed)
	back_btn_roll.pressed.connect(_on_back_pressed)
	dice_btn.pressed.connect(_on_roll_pressed)
	confirm_btn.pressed.connect(_on_confirm_pressed)
	stats_tab_btn.pressed.connect(_on_stats_tab_pressed)
	talent_tab_btn.pressed.connect(_on_talent_tab_pressed)

	portrait_btn.pressed.connect(_on_portrait_pressed)
	edit_name_btn.pressed.connect(_on_edit_name_pressed)
	name_confirm_btn.pressed.connect(_on_name_dialog_confirm)
	name_cancel_btn.pressed.connect(_on_name_dialog_cancel)
	avatar_dialog_confirm.pressed.connect(_on_avatar_dialog_confirm)
	setup_avatar_dialog()

	show_question(0)

func setup_avatar_dialog():
	for child in avatar_grid_dialog.get_children():
		if child is Button:
			child.pressed.connect(_on_avatar_dialog_select.bind(child))

func _on_portrait_pressed():
	avatar_dialog.show()

func _on_edit_name_pressed():
	name_input.text = name_label.text
	name_dialog.show()

func _on_name_dialog_confirm():
	var new_name = name_input.text.strip_edges()
	if new_name != "":
		name_label.text = new_name
	name_dialog.hide()

func _on_name_dialog_cancel():
	name_dialog.hide()

func _on_avatar_dialog_select(btn: Button):
	for child in avatar_grid_dialog.get_children():
		if child is Button:
			child.add_theme_color_override("font_color", Color(0.745, 0.745, 0.71, 1))
	btn.add_theme_color_override("font_color", Color(0.929, 0.82, 0.561, 1))
	selected_avatar = btn.text

func _on_avatar_dialog_confirm():
	portrait_btn.text = selected_avatar
	avatar_dialog.hide()

func _on_stats_tab_pressed():
	current_tab = 0
	stats_tab.show()
	talent_tab.hide()
	stats_tab_btn.add_theme_color_override("font_color", Color(0.929, 0.82, 0.561, 1))
	talent_tab_btn.add_theme_color_override("font_color", Color(0.745, 0.745, 0.71, 1))

func _on_talent_tab_pressed():
	current_tab = 1
	stats_tab.hide()
	talent_tab.show()
	talent_tab_btn.add_theme_color_override("font_color", Color(0.929, 0.82, 0.561, 1))
	stats_tab_btn.add_theme_color_override("font_color", Color(0.745, 0.745, 0.71, 1))

func show_question(index: int):
	current_question = index
	var q = questions[index]
	question_label.text = q.question
	progress_label.text = "第 " + str(index + 1) + " / " + str(questions.size()) + " 题"

	for child in answer_container.get_children():
		answer_container.remove_child(child)
		child.queue_free()

	for i in range(q.answers.size()):
		var a = q.answers[i]
		var btn = Button.new()
		btn.text = a.text
		btn.add_theme_font_size_override("font_size", 18)
		btn.custom_minimum_size = Vector2(0, 48)
		var idx = i
		btn.pressed.connect(_on_answer_selected.bind(idx))
		answer_container.add_child(btn)

func _on_answer_selected(answer_index: int):
	var q = questions[current_question]
	var a = q.answers[answer_index]
	stats.hp += a.hp
	stats.atk += a.atk
	stats.spd += a.spd
	if a.talent != "" and talent == "":
		talent = a.talent
	elif a.talent != "" and talent != "":
		talent += "·" + a.talent

	if current_question + 1 < questions.size():
		show_question(current_question + 1)
	else:
		show_roll_phase()

func show_roll_phase():
	quiz_ui.hide()
	roll_ui.show()
	current_phase = Phase.ROLL
	portrait_btn.text = selected_avatar
	_on_stats_tab_pressed()
	_do_roll()

func _do_roll():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var roll_hp = rng.randi_range(20, 40)
	var roll_atk = rng.randi_range(20, 40)
	var roll_spd = rng.randi_range(20, 40)
	stats.hp += roll_hp
	stats.atk += roll_atk
	stats.spd += roll_spd
	update_roll_display()

func update_roll_display():
	result_talent.text = "天赋：" + (talent if talent != "" else "无")
	result_hp.text = "气血：" + str(stats.hp)
	result_atk.text = "攻击：" + str(stats.atk)
	result_spd.text = "身法：" + str(stats.spd)

func _on_roll_pressed():
	stats.hp = 50
	stats.atk = 50
	stats.spd = 50
	talent = ""
	_on_stats_tab_pressed()
	_do_roll()

func _on_confirm_pressed():
	var char_name = name_label.text.strip_edges()
	if char_name == "":
		char_name = "江湖侠客"
	Globals.pending_character = {
		"name": char_name,
		"desc": "初出茅庐的江湖新人",
		"icon": selected_avatar,
		"hp": stats.hp,
		"atk": stats.atk,
		"spd": stats.spd,
		"talent": talent,
	}
	get_tree().change_scene_to_file("res://scenes/char_select/char_select.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/char_select/char_select.tscn")
