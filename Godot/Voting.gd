extends Node2D

@onready var theTimer = $Timer

@onready var timerLabel = $"TitleLabel/TimerLabel"
@onready var voteCountLabel = $"TitleLabel/SubtitleLabel/VoteCountLabel"

@onready var audio_stream_player = $AudioStreamPlayer
# Called when the node enters the scene tree for the first time.

var votingTime = 90
var playersSubmitted=-1
var votingList
var voteCountList
var totalPlayers=-1

var playerList

var currentlyTiming=false
func _ready():
	theTimer.set_one_shot(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timerLabel.text = str(ceil(theTimer.get_time_left()))
	voteCountLabel.text = str(playersSubmitted) + "/" + str(totalPlayers) + " voted"
	
	if(theTimer.is_stopped() && currentlyTiming):
		doneVoting()


signal sendVoteListToPlayer

func _on_game_event_handler_begin_voting(players):
	timerLabel.visible=true
	playerList=players
	currentlyTiming=true
	playersSubmitted=0
	votingList = []
	voteCountList=[]
	totalPlayers=players.size()
	
	var audio_stream = load("res://gfx/audio/music/" + "VotingMusic" + ".mp3")
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()
	
	for i in range(8):
			var fullTag = get_node("GridContainer/NameTag" + str(i + 1)) as TextureRect 
			
			if(players.size() <= i or !players[i].alive):
				fullTag.visible=false
				continue
			
			votingList.append(players[i].username)
			voteCountList.append(0)
			
			fullTag.visible=true
			var player_name = players[i].username
			var label = get_node("GridContainer/NameTag" + str(i + 1) + "/NameLabel") as Label 
			label.text = player_name
			
			var pic = get_node("GridContainer/NameTag" + str(i + 1) + "/PlayerIcon") as TextureRect
			pic.visible=true
			pic.texture = load("res://gfx/icons/" + str(players[i].icon) + ".png")
			
			var count = get_node("GridContainer/NameTag" + str(i + 1) + "/CountLabel") as Label
			count.visible=false
	
	var count = get_node("GridContainer/NameTag9/CountLabel") as Label
	count.visible=false
	
	
	theTimer.set_wait_time(votingTime)
	theTimer.start()
	
	sendVoteListToPlayer.emit(players, votingList)
	
	votingList.append("vote_skip")
	voteCountList.append(0)
			
			

signal startVoteReveal
signal sendAllToHome
func _on_client_upload_vote(message):
	playersSubmitted+=1
	for i in range(votingList.size()):
		if(votingList[i]==message.playerPicked):
			voteCountList[i] += 1
			
	if(playersSubmitted == totalPlayers):
		# end voting
		doneVoting()

func doneVoting():
	audio_stream_player.stop()
	sendAllToHome.emit(playerList)
	timerLabel.visible=false
	currentlyTiming = false
	var temp=0
	for i in range(9):
			var fullTag = get_node("GridContainer/NameTag" + str(i + 1)) as TextureRect 
			
			if(fullTag.visible==false):
				continue
			
			var count = get_node("GridContainer/NameTag" + str(i + 1) + "/CountLabel") as Label
			count.text=str(voteCountList[temp])
			
			count.visible=(voteCountList[temp]!=0)
			
			temp+=1
	
	await get_tree().create_timer(5).timeout
	
	
	var votedPlayer="_tie"
	var max=-1
	var tied=false
	#equal username of player to be revealed OR will be "_tie" if NOBODY
	for i in range(voteCountList.size()):
		if(voteCountList[i]>max):
			max=voteCountList[i]
			votedPlayer=votingList[i]
			tied=false
		elif(voteCountList[i]==max):
			tied=true
			
	
	if(tied): votedPlayer="_tie"
	print(votedPlayer)
	startVoteReveal.emit(votedPlayer)



			
	
