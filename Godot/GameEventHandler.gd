extends Node

@onready var lobbyNode = $"../Lobby"
@onready var introNode = $"../Intro"
@onready var roleNode = $"../RoleAssignment"
@onready var questionsNode = $"../Questions"
@onready var chipChooseNode = $"../ChipChoosing"
@onready var murderRevealNode = $"../MurderReveal"
@onready var votingNode = $"../Voting"
@onready var voteRevealNode = $"../VoteReveal"
@onready var endgameNode = $"../Endgame"

@onready var theTimer = $Timer

@onready var audio_stream_player = $AudioStreamPlayer


var duringTutorial;
signal beginRoleAssignment;
signal sendRolesToDevice;
signal beginQuestions;

var pplConfirmed = 0;
var playerList;
var murderIndex;
var iconList=[];

func _ready():
	duringTutorial = false
	
	lobbyNode.visible = true
	introNode.visible = false
	roleNode.visible = false
	questionsNode.visible = false
	chipChooseNode.visible = false
	murderRevealNode.visible =false
	votingNode.visible = false
	voteRevealNode.visible= false 
	endgameNode.visible = false

	var audio_stream = load("res://gfx/audio/music/" + "MenuMusic" + ".mp3")
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()
		
	

func _process(delta):
	if(theTimer.is_stopped() and duringTutorial):
		beginRoleAssignment.emit(playerList) 
		duringTutorial = false

func _on_start_button_pressed():
	#enter tutorial
	lobbyNode.visible = false
	introNode.visible = true
	
	duringTutorial = true
	
	audio_stream_player.stop()
	
	theTimer.set_wait_time(1)
	theTimer.set_one_shot(true)
	theTimer.start()
	

func _on_begin_role_assignment(players):
	introNode.visible = false
	roleNode.visible = true
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	murderIndex = rng.randi_range(0, playerList.size()-1)
	sendRolesToDevice.emit(murderIndex, playerList)

func _on_client_player_list_changed(players):
	if(lobbyNode.visible == true):
		playerList = players
		for player in playerList:
			player["tokens"]=0
			player["alive"]=true

func _on_client_role_confirmed(uuid):
	pplConfirmed+=1;
	if(pplConfirmed==playerList.size()):
		#move on to questions
		beginQuestions.emit(playerList.size())
		questionsNode.visible = true
		roleNode.visible = false

signal sendQuestionsToDevice

var playersCorrect;
func _on_questions_begin_answer_question(question):
	questionsNode.visible = true
	voteRevealNode.visible = false
	murderRevealNode.visible = false
	playersCorrect=0
	sendQuestionsToDevice.emit(playerList, question)



func _on_questions_answer_to_game_handler(uuid, correct):
	for player in playerList:
		if(uuid==player.uuid):
			if(correct):
				playersCorrect+=1;
				player["tokens"] += 1;
				

signal sendMessageToPlayer

var currentDeaths

func _on_questions_begin_chip_choosing(pc):
	questionsNode.visible=false
	chipChooseNode.visible=true
	
	#for the reveal that round!!!
	currentDeaths = playerList.duplicate()
	
	for player in currentDeaths:
		player["deathValue"]=0
	
	for i in range(playerList.size()):
		var choosingList=[];
		for j in range(playerList.size()):
			if(playerList[j].alive and (playerList[j]!=playerList[i] or i!=murderIndex)):
				choosingList.append(playerList[j].username)
		
		var message = {
			"type": "chip_choose_info",
			"uuid": playerList[i].uuid,
			"tokens": playerList[i].tokens,
			"choosingList": choosingList
			# ^^ list of players that they can choose from
		}
		sendMessageToPlayer.emit(message)
	

signal sendAllToHome
func _on_questions_send_all_to_home():
	sendAllToHome.emit(playerList)

signal sendCurrentDeaths
func _on_chip_choosing_begin_murder_reveal():
	sendAllToHome.emit(playerList)
	chipChooseNode.visible=false
	murderRevealNode.visible=true
	
	var peopleGyattUs = currentDeaths.duplicate(true)
	
	sendCurrentDeaths.emit(peopleGyattUs)
	
	for i in range(playerList.size()):
		if(currentDeaths[i].deathValue == 1):
			playerList[i].alive = false;
			
		
	


func _on_client_chips_chosen(message):
	for player in playerList:
		if message.uuid == player.uuid:
			#matching player!
			player.tokens -= (message.playersPicked.size() * (1 if message.victim else 2))
			break
	for player in message.playersPicked:
		for deather in currentDeaths:
			if(deather.username == player):
				deather["deathValue"] += (1 if message.victim else 2)
				break
		
	## 0 means nothing
	## 1 means DEAD no shield
	## 2 or above means alive (bc shielded)
		

signal beginVoting

func _on_murder_reveal_begin_voting():
	votingNode.visible = true
	murderRevealNode.visible = false
	if(!endgameCheck()):
		beginVoting.emit(playerList)


signal startVoteReveal
func _on_voting_start_vote_reveal(voteName):
	votingNode.visible=false
	voteRevealNode.visible=true
	
	var index=-1
	for i in range(playerList.size()):
		if(playerList[i].username==voteName):
			index=i
	var thePlayer=playerList[index]
	var skipTie=-1
	if(index >= 0):
		playerList[index].alive=false
	if(voteName=="_tie"): skipTie=2
	if(voteName=="vote_skip"): skipTie=1
	startVoteReveal.emit(thePlayer, (murderIndex==index), skipTie)
	
	await get_tree().create_timer(12).timeout
	voteRevealNode.visible = false
	if(!endgameCheck()):	
		beginQuestions.emit(playerList.size())
	

func endgameCheck():
	#check if the game should end
	if(playerList[murderIndex].alive==false):
		startEnd(false)
		return true
	for i in range(playerList.size()):
		if(i==murderIndex):
			continue
		if(playerList[i].alive):
			return false
	startEnd(true)
	return true

signal endgameStart
func startEnd(value):
	#FALSE IF INNCOENTS WIN
	#TRUE IF MURDERER WINS
	questionsNode.visible=false
	votingNode.visible=false
	endgameNode.visible=true
	endgameStart.emit(value, playerList, murderIndex)
