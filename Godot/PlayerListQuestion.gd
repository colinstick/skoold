extends GridContainer

var playerList

func _ready():
	self.visible=false

func _on_game_event_handler_begin_role_assignment(players):
	playerList = players
	for i in range(players.size()):
		var iconNum = playerList[i].icon
		var icon = get_node("Icon" + str(i + 1)) as Sprite2D 
		icon.visible=true
		icon.texture = load("res://gfx/icons/" + str(iconNum) + ".png")
		
	for i in range(players.size(), 8):
		var pic = get_node("Icon" + str(i + 1)) as Sprite2D 
		if pic:
			pic.visible = false
	

func _on_questions_begin_answer_question(currQuestion):
	self.visible=true
	_on_game_event_handler_begin_role_assignment(playerList)
	

func _on_client_answer_sent(message):
	for i in range(playerList.size()):
		if(message.uuid==playerList[i].uuid):
			var icon = get_node("Icon" + str(i + 1)) as Sprite2D
			icon.visible=false
			
			
