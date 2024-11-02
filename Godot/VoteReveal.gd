extends Node2D

@onready var label_label = $Label

@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer

# await get_tree().create_timer(5).timeout
var theText = [["Recounting...","Calculating...","Vote Skipped!"],["Confirming...","Vote Tied!","Nobody was removed"],["PLAYERNAME...","...was...","...INNOCENT!"]]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_game_event_handler_start_vote_reveal(thePlayer, killer, skipTie):
	#-1 is player, 1 is skipped, 2 is tied
	if(skipTie==2):
		skipTie=1
	elif(skipTie==1):
		skipTie=0
	else:
		skipTie=2
		theText[2][0]=thePlayer.username+"..."
		theText[2][2]=("...a murderer" if killer else "...innocent")
	
	label_label.text = theText[skipTie][0]
		
	animation_player.play("voteReveal")
	
	var audio_stream = load("res://gfx/audio/music/" + "VotedReveal" + ".mp3")
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()
	
	await get_tree().create_timer(3.5).timeout
	label_label.text = theText[skipTie][1]
	await get_tree().create_timer(3.5).timeout
	label_label.text = theText[skipTie][2]
	
