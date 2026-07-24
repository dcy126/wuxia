extends Control

var locations = {
	"village": {"name": "新手村", "pos": Vector2(300, 480), "desc": "江湖梦开始的地方"},
	"luoyang": {"name": "洛阳城", "pos": Vector2(700, 300), "desc": "中原繁华之都"},
	"shaolin": {"name": "少林寺", "pos": Vector2(500, 140), "desc": "千年古刹，武林泰斗"},
	"tomb": {"name": "古墓", "pos": Vector2(140, 200), "desc": "神秘莫测的地下遗迹"},
	"taohua": {"name": "桃花岛", "pos": Vector2(920, 500), "desc": "东海孤岛，世外桃源"},
	"zhongnan": {"name": "终南山", "pos": Vector2(340, 340), "desc": "全真教祖庭所在"},
	"xiangyang": {"name": "襄阳城", "pos": Vector2(640, 460), "desc": "兵家必争之地"},
}
var current_location = "village"

@onready var map_container = $MapPanel/MapContainer
@onready var player_icon = %PlayerIcon
@onready var loc_name = %LocName
@onready var loc_desc = %LocDesc
@onready var back_btn = $BackBtn
@onready var char_avatar = %CharAvatar
@onready var char_name = %CharName

func _ready():
	back_btn.pressed.connect(_on_back_pressed)
	map_container.draw.connect(_on_map_draw)
	show_character_info()
	await get_tree().process_frame
	place_locations()
	update_player_position()

func show_character_info():
	if Globals.current_character:
		char_avatar.text = Globals.current_character.get("icon", "🗡️")
		char_name.text = Globals.current_character.get("name", "江湖侠客")

func _on_map_draw():
	var c = map_container
	var w = c.size.x
	var h = c.size.y

	var mountain_color = Color(0.4, 0.35, 0.28, 0.8)
	_draw_mountain(c, Vector2(480, 110), 55, mountain_color)
	_draw_mountain(c, Vector2(540, 95), 50, mountain_color)
	_draw_mountain(c, Vector2(430, 140), 40, mountain_color)
	_draw_mountain(c, Vector2(340, 310), 45, mountain_color)
	_draw_mountain(c, Vector2(380, 290), 35, mountain_color)
	_draw_mountain(c, Vector2(290, 350), 30, mountain_color)

	var river_color = Color(0.3, 0.5, 0.6, 0.4)
	var pts = PackedVector2Array([
		Vector2(610, 0), Vector2(590, 80), Vector2(560, 160),
		Vector2(570, 240), Vector2(540, 320), Vector2(510, 400),
		Vector2(490, 480), Vector2(460, 560),
	])
	for i in range(pts.size() - 1):
		c.draw_line(pts[i], pts[i + 1], river_color, 5, true)

	var forest_color = Color(0.25, 0.45, 0.2, 0.45)
	_draw_forest(c, Vector2(180, 240), 4, forest_color)
	_draw_forest(c, Vector2(780, 380), 5, forest_color)
	_draw_forest(c, Vector2(380, 460), 4, forest_color)
	_draw_forest(c, Vector2(650, 180), 3, forest_color)

	var road_color = Color(0.55, 0.45, 0.3, 0.35)
	var roads = [
		["village", "luoyang"], ["village", "zhongnan"], ["village", "xiangyang"],
		["luoyang", "shaolin"], ["luoyang", "xiangyang"], ["luoyang", "taohua"],
		["shaolin", "zhongnan"], ["zhongnan", "tomb"], ["xiangyang", "tomb"],
	]
	for road in roads:
		var a = locations[road[0]].pos
		var b = locations[road[1]].pos
		c.draw_line(a, b, road_color, 2.0, true)

func _draw_mountain(c: Control, pos: Vector2, size: float, color: Color):
	var pts = PackedVector2Array([
		pos + Vector2(0, -size),
		pos + Vector2(-size * 0.6, size * 0.4),
		pos + Vector2(size * 0.6, size * 0.4),
	])
	c.draw_polygon(pts, PackedColorArray([color]))

	var snow = Color(0.88, 0.88, 0.85, 0.5)
	var snow_pts = PackedVector2Array([
		pos + Vector2(0, -size),
		pos + Vector2(-size * 0.2, -size * 0.25),
		pos + Vector2(size * 0.2, -size * 0.25),
	])
	c.draw_polygon(snow_pts, PackedColorArray([snow]))

func _draw_forest(c: Control, center: Vector2, count: int, color: Color):
	for i in range(count):
		var offset = Vector2(randf_range(-18, 18), randf_range(-18, 18))
		var r = randf_range(8, 14)
		c.draw_circle(center + offset, r, color)

func place_locations():
	var pending_btns = []
	for key in locations:
		var loc = locations[key]
		var btn = Button.new()
		btn.text = loc.name
		btn.add_theme_font_size_override("font_size", 14)
		btn.add_theme_color_override("font_color", Color(0.93, 0.82, 0.56, 1))
		var empty = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty)
		btn.add_theme_stylebox_override("hover", empty)
		btn.add_theme_stylebox_override("pressed", empty)
		var loc_key = key
		btn.pressed.connect(_on_location_pressed.bind(loc_key))
		map_container.add_child(btn)
		pending_btns.append({"btn": btn, "pos": loc.pos})

		var dot = ColorRect.new()
		dot.size = Vector2(8, 8)
		dot.color = Color(0.85, 0.75, 0.55, 0.9)
		dot.position = loc.pos + Vector2(-4, 24)
		map_container.add_child(dot)

	await get_tree().process_frame
	for entry in pending_btns:
		entry.btn.position = entry.pos - Vector2(entry.btn.size.x * 0.5, 0)

func update_player_position():
	var loc = locations[current_location]
	player_icon.text = "🧑"
	player_icon.position = loc.pos - Vector2(16, 48)

func _on_location_pressed(loc_key: String):
	current_location = loc_key
	var loc = locations[loc_key]
	loc_name.text = loc.name
	loc_desc.text = loc.desc
	update_player_position()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
