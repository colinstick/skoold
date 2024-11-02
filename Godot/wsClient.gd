extends Node

# The URL we will connect to.
@export var websocket_url = "ws://127.0.0.1:8000"

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()
signal player_list_changed
signal role_confirmed
signal answer_sent
signal chips_chosen
var iconList=[]

const RoomCode = "ABCX"

signal sendRoomCode
signal uploadVote

func _ready():
	var rng = RandomNumberGenerator.new()
	sendRoomCode.emit(RoomCode)
	rng.randomize()
	var something = false
	var i =0
	while(i<8):
		something = false
		var tempVar = rng.randi_range(1, 8)
		for icon in iconList:
			if(tempVar==icon):
				something = true
				break;
		if(!something):
			iconList.append(tempVar)
			i+=1
	# initiate connection
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		# wait for the socket to connect
		await get_tree().create_timer(1).timeout
		# send data
		var host_info = {
			"type": "establish_info",
			"roomCode": RoomCode,
			"username": "host",
		 	"hosting": true
		}
		
		socket.send_text(JSON.stringify(host_info))

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	var state = socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			var json_str = packet.get_string_from_utf8()
			var message = JSON.parse_string(json_str)
			
			match message.type:
				"room_info":
					var players = message.players
					for i in players.size():
						players[i]["icon"] = iconList[i]
					player_list_changed.emit(players)
				"confirm_role":
					role_confirmed.emit(message.uuid)
				"send_my_answer":
					answer_sent.emit(message)
				"send_my_cc":
					chips_chosen.emit(message)
				"send_my_vote":
					uploadVote.emit(message)
				_:
					print("Message type isnt supported: ", message.type)
				

	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.


func _on_game_event_handler_send_roles_to_device(murderIndex, playerList):
	for i in range(playerList.size()): 
		var player_info = {
			"type": "role_info",
			"roomCode": RoomCode,
			"uuid": playerList[i].uuid,
		 	"murderer": (i==murderIndex)
		}
		socket.send_text(JSON.stringify(player_info))

func _on_game_event_handler_send_questions_to_device(playerList, question):
	for i in range(playerList.size()): 
		var question_info = {
			"type": 'send_question',
			"roomCode": RoomCode,
			"uuid": playerList[i].uuid,
		 	"question": question.question,
			"A": question.A,
			"B": question.B,
			"C": question.C,
			"D": question.D
		}
		socket.send_text(JSON.stringify(question_info))
		


func _on_game_event_handler_send_message_to_player(message):
	socket.send_text(JSON.stringify(message))

func send_player_to_home(playerList):
	for i in range(playerList.size()):
		var infoinfo = {
				"type": 'send_to_home',
				"roomCode": RoomCode,
				"uuid": playerList[i].uuid
			}
		socket.send_text(JSON.stringify(infoinfo))


func _on_game_event_handler_send_all_to_home(playerL):
	send_player_to_home(playerL)


func _on_voting_send_vote_list_to_player(playerList, votingList):
	for i in range(playerList.size()): 
		var message_info = {
			"type": 'send_vote_now',
			"roomCode": RoomCode,
			"uuid": playerList[i].uuid,
			"voteList": votingList
		}
		socket.send_text(JSON.stringify(message_info))
	
	
func _on_voting_send_all_to_home(pL):
	send_player_to_home(pL)
