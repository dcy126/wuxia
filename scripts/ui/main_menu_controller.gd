extends Control

@onready var background_layer = $BackgroundLayer
@onready var background = $BackgroundLayer/Background
@onready var fog_layer = $BackgroundLayer/FogLayer
@onready var title_text = $UILayer/TitleContainer/TitleText
@onready var subtitle_text = $UILayer/TitleContainer/SubtitleText
@onready var menu_container = $UILayer/MenuContainer
@onready var btn_new_game = $UILayer/MenuContainer/BtnNewGame
@onready var btn_load_game = $UILayer/MenuContainer/BtnLoadGame
@onready var btn_settings = $UILayer/MenuContainer/BtnSettings
@onready var btn_exit = $UILayer/MenuContainer/BtnExit
@onready var settings_panel = $UILayer/SettingsPanel
@onready var settings_container = $UILayer/SettingsPanel/SettingsContainer
@onready var btn_close_settings = $UILayer/SettingsPanel/SettingsContainer/BtnCloseSettings
@onready var music_slider = $UILayer/SettingsPanel/SettingsContainer/AudioSettings/MusicSlider
@onready var sfx_slider = $UILayer/SettingsPanel/SettingsContainer/SfxSettings/SfxSlider
@onready var fullscreen_check = $UILayer/SettingsPanel/SettingsContainer/DisplaySettings/FullscreenCheck
@onready var load_game_panel = $UILayer/LoadGamePanel
@onready var load_game_container = $UILayer/LoadGamePanel/LoadGameContainer
@onready var save_slot_container = $UILayer/LoadGamePanel/LoadGameContainer/SaveSlotContainer
@onready var btn_back_from_load = $UILayer/LoadGamePanel/LoadGameContainer/BtnBackFromLoad
@onready var save_slot_1 = $UILayer/LoadGamePanel/LoadGameContainer/SaveSlotContainer/SaveSlot1
@onready var save_slot_2 = $UILayer/LoadGamePanel/LoadGameContainer/SaveSlotContainer/SaveSlot2
@onready var save_slot_3 = $UILayer/LoadGamePanel/LoadGameContainer/SaveSlotContainer/SaveSlot3
@onready var version_label = $UILayer/VersionLabel
@onready var copyright_label = $UILayer/CopyrightLabel

@onready var audio_manager = get_node_or_null("/root/AudioManager")
@onready var save_manager = get_node_or_null("/root/SaveManager")
@onready var scene_manager = get_node_or_null("/root/SceneManager")

@export var background_music: AudioStream
@export var menu_click_sound: AudioStream
@export var menu_hover_sound: AudioStream

var current_menu_state = "main"
var focused_button_index = 0
var menu_buttons = []

func _ready() -> void:
    _setup_ui()
    _connect_signals()
    _load_settings()
    _start_ambient_effects()
    _animate_title()
    _focus_first_button()

func _setup_ui() -> void:
    menu_buttons = [btn_new_game, btn_load_game, btn_settings, btn_exit]
    
    for i, btn in menu_buttons:
        btn.focus_mode = Control.FOCUS_ALL
        btn.mouse_entered.connect(_on_button_hovered.bind(i))
        btn.focus_entered.connect(_on_button_focused.bind(i))
    
    settings_panel.visible = false
    load_game_panel.visible = false
    
    version_label.text = "v0.1.0 | 神游工作室"
    copyright_label.text = "© 2026 武侠江湖计划"

func _connect_signals() -> void:
    btn_new_game.pressed.connect(_on_new_game_pressed)
    btn_load_game.pressed.connect(_on_load_game_pressed)
    btn_settings.pressed.connect(_on_settings_pressed)
    btn_exit.pressed.connect(_on_exit_pressed)
    
    btn_close_settings.pressed.connect(_on_close_settings_pressed)
    music_slider.value_changed.connect(_on_music_volume_changed)
    sfx_slider.value_changed.connect(_on_sfx_volume_changed)
    fullscreen_check.toggled.connect(_on_fullscreen_toggled)
    
    btn_back_from_load.pressed.connect(_on_back_from_load_pressed)
    save_slot_1.pressed.connect(_on_save_slot_pressed.bind(1))
    save_slot_2.pressed.connect(_on_save_slot_pressed.bind(2))
    save_slot_3.pressed.connect(_on_save_slot_pressed.bind(3))

func _load_settings() -> void:
    var config = ConfigFile.new()
    var config_path = "user://settings.cfg"
    
    if config.load(config_path) == OK:
        var music_vol = config.get_value("audio", "music_volume", 0.8)
        var sfx_vol = config.get_value("audio", "sfx_volume", 1.0)
        var fullscreen = config.get_value("display", "fullscreen", true)
        
        music_slider.value = music_vol
        sfx_slider.value = sfx_vol
        fullscreen_check.button_pressed = fullscreen
        
        if audio_manager:
            audio_manager.set_music_volume(music_vol)
            audio_manager.set_sfx_volume(sfx_vol)
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func _save_settings() -> void:
    var config = ConfigFile.new()
    config.set_value("audio", "music_volume", music_slider.value)
    config.set_value("audio", "sfx_volume", sfx_slider.value)
    config.set_value("display", "fullscreen", fullscreen_check.button_pressed)
    config.save("user://settings.cfg")

func _start_ambient_effects() -> void:
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(fog_layer, "modulate:a", 0.3, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(fog_layer, "modulate:a", 0.6, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _animate_title() -> void:
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(title_text, "modulate:a", 0.7, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(title_text, "modulate:a", 1.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    
    var subtitle_tween = create_tween()
    subtitle_tween.set_loops()
    subtitle_tween.tween_property(subtitle_text, "modulate:a", 0.5, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    subtitle_tween.tween_property(subtitle_text, "modulate:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _focus_first_button() -> void:
    focused_button_index = 0
    menu_buttons[0].grab_focus()

func _on_button_hovered(index: int) -> void:
    if current_menu_state == "main":
        focused_button_index = index
        _play_sound(menu_hover_sound)

func _on_button_focused(index: int) -> void:
    focused_button_index = index

func _on_new_game_pressed() -> void:
    _play_sound(menu_click_sound)
    _start_new_game()

func _start_new_game() -> void:
    var tween = create_tween()
    tween.tween_property(UILayer, "modulate:a", 0.0, 0.5)
    tween.tween_callback(_transition_to_game.bind())

func _transition_to_game() -> void:
    if scene_manager:
        scene_manager.change_scene("res://scenes/game/main_game.tscn")
    else:
        get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")

func _on_load_game_pressed() -> void:
    _play_sound(menu_click_sound)
    _show_load_game_panel()

func _show_load_game_panel() -> void:
    current_menu_state = "load_game"
    menu_container.visible = false
    load_game_panel.visible = true
    _refresh_save_slots()
    btn_back_from_load.grab_focus()

func _refresh_save_slots() -> void:
    if save_manager:
        var slots = save_manager.get_save_slots_info()
        var slot_buttons = [save_slot_1, save_slot_2, save_slot_3]
        
        for i, btn in slot_buttons:
            if i < slots.size() and slots[i].exists:
                var info = slots[i]
                btn.text = "存档槽 %d - %s  第%s章  %s" % [i + 1, info.character_name, info.chapter, info.play_time]
                btn.disabled = false
            else:
                btn.text = "存档槽 %d - 空" % (i + 1)
                btn.disabled = true

func _on_save_slot_pressed(slot_index: int) -> void:
    _play_sound(menu_click_sound)
    if save_manager and save_manager.load_game(slot_index):
        _transition_to_game()

func _on_back_from_load_pressed() -> void:
    _play_sound(menu_click_sound)
    _hide_load_game_panel()

func _hide_load_game_panel() -> void:
    current_menu_state = "main"
    load_game_panel.visible = false
    menu_container.visible = true
    _focus_first_button()

func _on_settings_pressed() -> void:
    _play_sound(menu_click_sound)
    _show_settings_panel()

func _show_settings_panel() -> void:
    current_menu_state = "settings"
    menu_container.visible = false
    settings_panel.visible = true
    btn_close_settings.grab_focus()

func _on_close_settings_pressed() -> void:
    _play_sound(menu_click_sound)
    _save_settings()
    _hide_settings_panel()

func _hide_settings_panel() -> void:
    current_menu_state = "main"
    settings_panel.visible = false
    menu_container.visible = true
    _focus_first_button()

func _on_exit_pressed() -> void:
    _play_sound(menu_click_sound)
    get_tree().quit()

func _on_music_volume_changed(value: float) -> void:
    if audio_manager:
        audio_manager.set_music_volume(value)

func _on_sfx_volume_changed(value: float) -> void:
    if audio_manager:
        audio_manager.set_sfx_volume(value)

func _on_fullscreen_toggled(pressed: bool) -> void:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if pressed else DisplayServer.WINDOW_MODE_WINDOWED)

func _play_sound(sound: AudioStream) -> void:
    if sound and audio_manager:
        audio_manager.play_sfx(sound)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match current_menu_state:
            "main":
                _handle_main_menu_input(event)
            "settings":
                _handle_settings_input(event)
            "load_game":
                _handle_load_game_input(event)

func _handle_main_menu_input(event: InputEventKey) -> void:
    match event.keycode:
        KEY_DOWN, KEY_S:
            _navigate_menu(1)
        KEY_UP, KEY_W:
            _navigate_menu(-1)
        KEY_ENTER, KEY_SPACE, KEY_KP_ENTER:
            _activate_focused_button()
        KEY_ESCAPE:
            _on_exit_pressed()

func _handle_settings_input(event: InputEventKey) -> void:
    match event.keycode:
        KEY_ESCAPE:
            _on_close_settings_pressed()

func _handle_load_game_input(event: InputEventKey) -> void:
    match event.keycode:
        KEY_ESCAPE:
            _on_back_from_load_pressed()

func _navigate_menu(direction: int) -> void:
    focused_button_index = clamp(focused_button_index + direction, 0, menu_buttons.size() - 1)
    menu_buttons[focused_button_index].grab_focus()
    _play_sound(menu_hover_sound)

func _activate_focused_button() -> void:
    if focused_button_index < menu_buttons.size():
        menu_buttons[focused_button_index].emit_signal("pressed")

func _on_background_loaded(texture: Texture2D) -> void:
    background.texture = texture
```