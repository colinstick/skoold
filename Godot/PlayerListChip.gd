extends GridContainer

var playerList;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_game_event_handler_begin_role_assignment(players):
	playerList = players
	for i in range(players.size()):
		var icon = get_node("Label" + str(i+1) + "/Icon" + str(i + 1)) as Sprite2D  # construct node name dynamically
		icon.visible=true
		icon.texture = load("res://gfx/icons/eyes0.png")
		
	for i in range(players.size(), 8):
		var pic = get_node("Label" + str(i+1) + "/Icon" + str(i + 1)) as Sprite2D  # construct node name dynamically
		if pic:
			pic.visible = false

func _on_client_chips_chosen(message):
	for i in range(playerList.size()):
		if(playerList[i].uuid == message.uuid):  # player array
			var icon = get_node("Label" + str(i+1) + "/Icon" + str(i + 1)) as Sprite2D  # construct node name dynamically
			icon.visible = false
