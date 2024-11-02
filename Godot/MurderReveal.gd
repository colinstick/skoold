extends Node2D

@onready var name_label = $NameLabel
@onready var status_label = $StatusLabel

@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer

@onready var timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = 6

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#START MURDER REVEAL!!!!
signal beginVoting
func _on_game_event_handler_send_current_deaths(currentD):

	for player in currentD:
		if(player.alive):
			name_label.text = player.username;
			status_label.text = "was killed!" if player.deathValue==1 else "survived!"
			
			var audio_stream = load("res://gfx/audio/music/" + ("PlayerDead" if player.deathValue==1 else "PlayerSafe") + ".mp3")
			audio_stream_player.stream = audio_stream
			audio_stream_player.play()
			
			animation_player.queue("approach")
			animation_player.queue("dead" if player.deathValue==1 else "alive")
			
			timer.start()
			await timer.timeout
			
	beginVoting.emit()
