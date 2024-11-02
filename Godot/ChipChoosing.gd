extends Node2D


@onready var theTimer = $Timer
@onready var timerLabel = $TimerLabel

@onready var audio_stream_player = $AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	theTimer.set_wait_time(60)
	theTimer.set_one_shot(true)
	tempFr=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timerLabel.text = str(ceil(theTimer.get_time_left()))
	if((theTimer.get_time_left() <= 0 or playersSubmitted==playerCount) and !tempFr ):
		endChoosing()
		tempFr = true
		
var tempFr
var playersSubmitted
var playerCount
func _on_questions_begin_chip_choosing(pc):
	var audio_stream = load("res://gfx/audio/music/" + "ChipChoosing"+ ".mp3")
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()

	playerCount=pc
	playersSubmitted=0
	theTimer.set_wait_time(60)
	theTimer.start()
	tempFr = false

func _on_client_chips_chosen(message):
	playersSubmitted+=1

signal beginMurderReveal

func endChoosing():
	if audio_stream_player.playing:
		audio_stream_player.stop()
	
	theTimer.stop()
	beginMurderReveal.emit()
