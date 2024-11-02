extends Node2D

@onready var killerLabel = $"KillerLabel"
@onready var killerTexture = $"killerWinTexture"
@onready var innoTexture = $"innoWinTexture"

@onready var audio_stream_player = $AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	audio_stream_player.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_game_event_handler_endgame_start(value, playerList, murderIndex):
	#true if killer won!!
	var audio_stream = load("res://gfx/audio/music/" + "EndingMusic" + ".mp3")
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()
	
	killerTexture.visible = value
	innoTexture.visible = !value
	
	for i in range(playerList.size()):
		var player_name = playerList[i].username  
		var label = get_node("PlayerList/Label" + str(i + 1)) as Label  # construct node name dynamically
		if(i==murderIndex):
			label.text="..."
			continue
		label.text = player_name
	
	killerLabel.text=playerList[murderIndex].username
