extends Node2D

var foreveralone : PackedScene = preload("res://scenes/foreveralone.tscn")
var fuckencia : PackedScene = preload("res://scenes/fuckencia.tscn")
var fuckencio : PackedScene = preload("res://scenes/fuckencio.tscn")
var fuuuuuu : PackedScene = preload("res://scenes/fuuuuuu.tscn")
var looooool : PackedScene = preload("res://scenes/looooool.tscn")
var ohgod : PackedScene = preload("res://scenes/ohgod.tscn")
var okay : PackedScene = preload("res://scenes/okay.tscn")
var pokerface : PackedScene = preload("res://scenes/pokerface.tscn")
var really : PackedScene = preload("res://scenes/really.tscn")
var trollface : PackedScene = preload("res://scenes/trollface.tscn")

const TOP = 60
const MIN = 420
const MAX = 735
const SAVE_PATH : String = "user://RageGame.dat"
const SCREENSHOT_PATH : String = 'user://screenshoot_'

var data : Array = []
var json = JSON.new()
var rng = RandomNumberGenerator.new()
var index : int = 0
var time : int = 0
var initials = [foreveralone, fuckencia, fuckencio, fuuuuuu]
var initials_names = ['foreveralone', 'fuckencia', 'fuckencio', 'fuuuuuu']
var preview = {'rage':foreveralone, 'name':'foreveralone'}
var next = {'rage':foreveralone, 'name':'foreveralone'}
var can_create : bool = true
var loop_seek : int = 0
var new_game : bool = true
var is_pause : bool = true
var screenshot
var is_web : bool = true
var is_pressed : bool = false


func save_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json.stringify(data))

func load_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var error = json.parse(file.get_as_text(true))
		if error == OK:
			data = json.data
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", file.get_as_text(true), " at line ", json.get_error_line())
	else:
		print('Data not exists')


func update_best_times():
	var count = 0
	var text = 'Best Times'
	for time in data:
		count += 1
		text += '\n  -  ' + time_convert(int(time))
		if count >= 10: break
	$lblBestTime.text = text


func clean_scene():
	var objects = get_tree().get_nodes_in_group("rageface")
	for obj in objects:
		obj.queue_free()

func _ready():
	if is_web == true:
		$Menu/lblExit.visible = false
	load_score()
	update_best_times()
	set_next_rage()
	get_tree().paused = true


func _physics_process(_delta: float) -> void:
	var left = get_global_mouse_position().x
	if get_global_mouse_position().x > MAX:
		left = MAX
	elif get_global_mouse_position().x < MIN:
		left = MIN
	$Preview.global_position = Vector2(left, TOP)
	$Line.position = Vector2(left, TOP)
	if Input.is_action_just_pressed("ui_cancel"):
		pause_game()


func _unhandled_input(event):
	if event.is_echo():
		return
	if event is InputEventMouseButton and (event.is_pressed() or event.is_released()):
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				is_pressed = true
			if event.is_released() and is_pressed == true:
				if can_create == true:
					$Out.play()
					can_create = false
					$Preview.texture = null
					$Line.visible = false
					spawn(preview['rage'], $Preview.global_position, true)
			

func pause_game():
	screenshot = get_viewport().get_texture().get_image()
	$Menu/Screenshot.texture = ImageTexture.create_from_image(screenshot)
	$Menu/Screenshot.visible = true
	$Menu/lblScreenshot.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$Menu/lblContinue.visible = true
	$Menu.visible = true
	$Time.stop()


func spawn(object, spawn_position : Vector2, from_top : bool = false):
	var instance = object.instantiate()
	#var instance = foreveralone.instantiate()
	instance.global_position = spawn_position
	instance.from_top = from_top
	instance.normal_collision.connect(normal_collision)
	instance.rage_collision.connect(rage_collision)
	add_child(instance)


func set_next_rage():
	var prev_index = index
	index = rng.randi_range(0, 3)
	# Set Values
	preview = next
	next = {'rage':initials[index], 'name':initials_names[index]}
	$Next.texture = load('res://assets/rages/' + next['name'] + '.png')
	$Next.scale = Vector2(float(index + 1) / 10, float(index + 1) / 10)
	$Preview.texture = load('res://assets/rages/' + preview['name'] + '.png')
	$Preview.scale = Vector2(float(prev_index + 1) / 10, float(prev_index + 1) / 10)
	$Line.visible = true
	prev_index = index


func rage_collision(rage, position):
	await get_tree().create_timer(0.1).timeout
	$Bubble.play()
	if rage == 'foreveralone':
		spawn(fuckencia, position)
	elif rage == 'fuckencia':
		spawn(fuckencio, position)
	elif rage == 'fuckencio':
		spawn(fuuuuuu, position)
	elif rage == 'fuuuuuu':
		spawn(looooool, position)
	elif rage == 'looooool':
		spawn(ohgod, position)
	elif rage == 'ohgod':
		spawn(okay, position)
	elif rage == 'okay':
		spawn(pokerface, position)
	elif rage == 'pokerface':
		spawn(really, position)
	elif rage == 'really':
		spawn(trollface, position)
		win_game()
	elif rage == 'trollface':
		print('FIN')
	else:
		print('>>> ', rage)


func normal_collision():
	pass
	#$Toc.play()
	#can_create = true
	#set_next_rage()


func win_game():
	await get_tree().create_timer(0.5).timeout
	screenshot = get_viewport().get_texture().get_image()
	$Menu/Screenshot.texture = ImageTexture.create_from_image(screenshot)
	$Aplauses.play()
	$Time.stop()
	data.append(time)
	data.sort()
	update_best_times()
	save_score()
	new_game = true
	$Menu/lblGameOver.visible = true
	$Menu/lblGameOver.label_settings.font_color = Color.GREEN
	$Menu/lblGameOver.text = 'Congrats!'
	$Menu/lblRecord.visible = true
	$Menu/lblRecord.label_settings.font_color = Color.BLANCHED_ALMOND
	$Menu/lblStart.text = 'New Game'
	$Menu/lblContinue.visible = false
	#if is_web == false:
	$Menu/Screenshot.visible = true
	$Menu/lblScreenshot.visible = true
	if time <= data.min():
		$Menu/lblRecord.text = 'New Record: ' + time_convert(time)
	else:
		$Menu/lblRecord.text = 'Time: ' + time_convert(time)
	time = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$Menu.visible = true


func lose_game():
	await get_tree().create_timer(0.5).timeout
	screenshot = get_viewport().get_texture().get_image()
	$Menu/Screenshot.texture = ImageTexture.create_from_image(screenshot)
	$GameOver.play()
	$Time.stop()
	$TimerDead.stop()
	new_game = true
	$Menu/lblGameOver.visible = true
	$Menu/lblGameOver.label_settings.font_color = Color.DARK_RED
	$Menu/lblGameOver.text = 'Game Over'
	#$Menu/lblRecord.visible = false
	$Menu/lblStart.text = 'New Game'
	$Menu/lblContinue.visible = false
	#if is_web == false:
	$Menu/Screenshot.visible = true
	$Menu/lblScreenshot.visible = true
	time = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$Menu.visible = true


func time_convert(time_in_sec):
	var seconds = time_in_sec%60
	var minutes = (time_in_sec/60)%60
	var hours = (time_in_sec/60)/60
	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


func _on_time_timeout():
	time += 1
	$lblTime.text = time_convert(time)


func _on_lbl_start_mouse_entered():
	$Menu/lblStart.label_settings.font_color = Color.CHARTREUSE


func _on_lbl_start_mouse_exited():
	$Menu/lblStart.label_settings.font_color = Color.WHITE


func _on_lbl_exit_mouse_entered():
	$Menu/lblExit.label_settings.font_color = Color.CHARTREUSE


func _on_lbl_exit_mouse_exited():
	$Menu/lblExit.label_settings.font_color = Color.WHITE


func _on_lbl_continue_mouse_entered():
	$Menu/lblContinue.label_settings.font_color = Color.CHARTREUSE


func _on_lbl_continue_mouse_exited():
	$Menu/lblContinue.label_settings.font_color = Color.WHITE


func _on_lbl_continue_gui_input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
			$Menu/lblGameOver.visible = false
			$Menu/lblRecord.visible = false
			$Menu/lblContinue.label_settings.font_color = Color.WHITE
			$Menu/Trollface.visible = false
			$Menu.visible = false
			$Time.start()
			get_tree().paused = false


func _on_lbl_exit_gui_input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().quit()


func _on_lbl_start_gui_input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			clean_scene()
			new_game = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
			$Menu/lblGameOver.visible = false
			$Menu/lblRecord.visible = false
			$Menu/lblStart.label_settings.font_color = Color.WHITE
			$Menu/Trollface.visible = false
			$lblTime.text = '00:00:00'
			$Menu/Screenshot.visible = false
			$Menu/lblScreenshot.visible = false
			$Menu.visible = false
			time = 0
			$Time.start()
			get_tree().paused = false


func loop_pause():
	loop_seek = $NyanCat.get_playback_position()
	$NyanCat.stop()
	
func loop_play():
	$NyanCat.play()
	$NyanCat.seek(loop_seek)

func _on_btn_sound_pressed():
	if $NyanCat.is_playing() == true:
		loop_pause()
		$Menu/btnSound.texture_normal = load("res://assets/images/sound-off.png")
	else:
		loop_play()
		$Menu/btnSound.texture_normal = load("res://assets/images/sound-on.png")


func _on_btn_window_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$Menu/btnWindow.texture_normal = load("res://assets/images/windowed.png")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$Menu/btnWindow.texture_normal = load("res://assets/images/fullscreen.png")


func _on_btn_pause_pressed():
	pause_game()


func _on_area_dead_body_entered(body):
	$TimerDead.start()
	$Top.default_color = Color.DARK_RED


func _on_area_dead_body_exited(body):
	can_create = true
	set_next_rage()
	if len($AreaDead.get_overlapping_bodies()) == 0:
		$TimerDead.stop()
		$Top.default_color = Color.DARK_GRAY


func _on_timer_dead_timeout():
	if len($AreaDead.get_overlapping_bodies()) == 0:
		$TimerDead.stop()
		$Top.default_color = Color.DARK_GREEN
	else:
		lose_game()


func _on_nyan_cat_finished():
	$NyanCat.play()


func _on_lbl_screenshot_mouse_entered():
	$Menu/lblScreenshot.label_settings.font_color = Color.CHARTREUSE


func _on_lbl_screenshot_mouse_exited():
	$Menu/lblScreenshot.label_settings.font_color = Color.WHITE


func _on_lbl_screenshot_gui_input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			var t = Time.get_datetime_dict_from_system()
			var filename = 'screenshot_' + str(t['year']) + str(t['month']) + str(t['day']) + str(t['hour']) + str(t['minute']) + str(t['second']) + '.jpg'
			if is_web == false:
				$Menu/FileDialog.popup()
				$Menu/FileDialog.set_filters(PackedStringArray(["*.jpg ; JPEG Images"]))
				$Menu/FileDialog.current_file = filename
			else:
				var buf = screenshot.save_png_to_buffer()
				JavaScriptBridge.download_buffer(buf, filename)


func _on_file_dialog_file_selected(path):
	screenshot.save_jpg(path)
