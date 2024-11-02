extends Node2D

var questionNum
var maxQuestions
var questionsToBeAsked = []
var questions

var playersAnswered

var initialNum=0
var roundLength=3

@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer

@onready var grid_questions = $GridContainer
@onready var question_label = $Question
@onready var correct_ans_label = $CorrectAns
@onready var question_num_label = $QuestionNum
@onready var correct_count_label = $CorrectCountLabel
@onready var grid_icons = $PlayerList

@onready var theTimer = $Timer
@onready var timerLabel = $TimerLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	theTimer.set_one_shot(true)
	questionNum=initialNum
	var file = FileAccess.open("res://gfx/questions.json", FileAccess.READ)
	var content = file.get_as_text()
	questions = JSON.parse_string(content)
	maxQuestions = questions.size()
	
	grid_questions.visible=false
	question_label.visible=false
	correct_ans_label.visible=false
	question_num_label.visible=false
	timerLabel.visible=false
	grid_icons.visible=false
	correct_count_label.visible=false
	
	#generate 10 question indexes
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var tempblah = false
	var qDone = 0
	while qDone < 10:
		tempblah = false
		var qNum = rng.randi_range(0, maxQuestions-1)
		for tempQ in questionsToBeAsked:
			if(qNum == tempQ):
				tempblah=true
				break
		if(tempblah == false):
			qDone+=1
			questionsToBeAsked.append(qNum)
	

var fartTemp=0;
var questionAnswered=false;

func _process(delta):
	if(animation_player.get_current_animation() == "questionNumIn"):
		question_num_label.visible=true
	elif(animation_player.get_current_animation() == "questionIn"):
		question_num_label.visible=false
		question_label.visible=true
	elif(animation_player.get_current_animation() == "answersAppear"):
		grid_questions.visible=true
		timerLabel.visible=true
	elif(animation_player.get_current_animation()=="correctAnswerAppear"):
		grid_questions.visible=false
		correct_ans_label.visible=true
	
	timerLabel.text = str(ceil(theTimer.get_time_left()))
	
	if(fartTemp==1&&!audio_stream_player.is_playing()):
		questionIn()
		fartTemp=2
	elif(fartTemp==2&&!audio_stream_player.is_playing()):
		answerQuestion()
		fartTemp=2.5
	elif(fartTemp==2.5&&theTimer.get_time_left() <= 29.5):
		var currQuestion = questions[questionsToBeAsked[questionNum-1]]
		beginAnswerQuestion.emit(currQuestion)
		fartTemp=3
	elif(fartTemp==3&&questionAnswered):
		answerReveal()
		fartTemp+=1
	elif(fartTemp==3):
		if(theTimer.is_stopped()):
			questionAnswered=true
	elif(fartTemp==4):
		correctCountReveal()
		fartTemp+=1
	elif(fartTemp==5 && theTimer.is_stopped()):
		#3 questions per round
		if(questionNum%roundLength!=0):
			_on_game_event_handler_begin_questions(playerCount)
		else:
			beginChipChoosing.emit(playerCount)
			fartTemp=6
	
	

func questionNumIn():
	question_num_label.text = "Question "+ str(questionNum)
	animation_player.play("questionNumIn")
	var audio_stream = load("res://gfx/audio/questionClips/q"+ str(questionNum) + ".mp3")
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()
	
func questionIn():
	animation_player.queue("questionIn")
	var audNum = randi() % 6
	var audio_stream = load("res://gfx/audio/questionClips/" + "00" + str(audNum) + ".mp3")
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()

signal beginAnswerQuestion()
signal beginChipChoosing()

signal sendAllToHome()

func answerQuestion():
	var currQuestion = questions[questionsToBeAsked[questionNum-1]]
	timerLabel.visible=true
	grid_icons.visible=true
	animation_player.queue("questionPlace")
	animation_player.queue("answersAppear")
	theTimer.set_wait_time(32)
	theTimer.start()
	
	var audio_stream = load("res://gfx/audio/music/" + "QuestionMusic" + ".mp3")
	audio_stream_player.stream = audio_stream
	audio_stream_player.play()
	
	
func answerReveal():
	if audio_stream_player.playing:
		audio_stream_player.stop()
	
	sendAllToHome.emit()
	
	grid_questions.visible=false
	correct_ans_label.visible=true
	grid_icons.visible = false
	timerLabel.visible=false
	
	animation_player.queue("correctAnswerAppear")

func correctCountReveal():
	correct_count_label.text = str(playersCorrect)
	correct_count_label.visible=true
	#do again if needed
	theTimer.set_wait_time(5)
	theTimer.start()
	

var playerCount;
var playersCorrect;
func _on_game_event_handler_begin_questions(size):
	
	questionNum += 1
	playersAnswered=0
	playersCorrect=0
	playerCount=size
	
	self.visible=true
	grid_questions.visible=false
	question_label.visible=false
	correct_ans_label.visible=false
	question_num_label.visible=false
	timerLabel.visible=false
	grid_icons.visible=false
	correct_count_label.visible=false
	
	questionAnswered = false
	var letterList = ['A','B','C','D']
	
	#assign text values
	var currQuestion = questions[questionsToBeAsked[questionNum-1]]
	question_label.text = currQuestion["question"]
	correct_ans_label.text = currQuestion["correct"] + ". " + currQuestion[currQuestion["correct"]]
	for letter in letterList:
		var labelName = "Answer" + letter
		var labelNode = grid_questions.get_node(labelName)
		labelNode.text = letter + ". " + currQuestion[letter]
	
	questionNumIn()
	fartTemp=1
	
signal answerToGameHandler;

func _on_client_answer_sent(message):
	playersAnswered+=1
	var currQuestion = questions[questionsToBeAsked[questionNum-1]]
	var correct = (message.ansLetter == currQuestion["correct"])
	if(correct):
		playersCorrect+=1
	answerToGameHandler.emit(message.uuid, correct)
	if(playersAnswered==playerCount):
		theTimer.stop()
	
