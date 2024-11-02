extends Node

@onready var animation_player = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
var roomCode = "x#!^"

func _ready():
	animation_player.play("float_up_down")
	self.text = "Join the game at
				\"localhost:5173\"
				with code " + roomCode

func _on_start_button_pressed():
	animation_player.stop()
	self.visible = false
	


func _on_client_send_room_code(rc):
	roomCode=rc
	self.text = "Join the game at\n
				\"localhost:5173\"\n
				with code " + roomCode
