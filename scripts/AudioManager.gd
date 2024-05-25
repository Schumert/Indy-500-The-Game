extends Node

var menu_theme = preload("res://audio/racy.mp3")
var crash_sound = preload("res://audio/hitHurt.wav")
var level_theme = preload("res://audio/crowd.mp3")
var click_sound = preload("res://audio/click.wav")
var finish_lap_sound = preload("res://audio/finishLap.wav")
var coin_sound = preload("res://audio/pickupCoin.wav")
var start_red_sound = preload("res://audio/start_red.wav")
var start_green_sound = preload("res://audio/start_green.wav")
func _ready():
	pass # Replace with function body.


func play_music(music:AudioStream, volume = 0.0):
	if $Music.stream == music:
		return
	
	$Music.stream = music
	$Music.volume_db = volume
	$Music.play()


func play_main_menu_music():
	play_music(menu_theme, -10)


func play_crowd_music():
	play_music(level_theme, -30)


func play_crash(volume = 0.0):
	$Crash.stream = crash_sound
	$Crash.volume_db = volume
	$Crash.play()

func play_click(volume = 0.0):
	$Click.stream = click_sound
	$Click.volume_db = volume
	$Click.play()

func play_score(score: AudioStream, volume = 0.0):
	$Score.stream = score
	$Score.volume_db = volume
	$Score.play()

func play_coin():
	play_score(coin_sound)

func play_lap():
	play_score(finish_lap_sound)


func play_start_red(volume = 0.0):
	$Start.stream = start_red_sound
	$Start.volume_db = volume
	$Start.play()
func play_start_green(volume = 0.0):
	$Start.stream = start_green_sound
	$Start.volume_db = volume
	$Start.play()




