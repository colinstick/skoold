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
		var iconNum = playerList[i].icon
		var icon = get_node("Label" + str(i+1) + "/Icon" + str(i + 1)) as Sprite2D 
		icon.visible=true
		icon.texture = load("res://gfx/icons/" + str(iconNum) + ".png")
	for i in range(players.size()):
		var player_name = players[i].username 
		var label = get_node("Label" + str(i + 1)) as Label 
		label.text = player_name
		
	for i in range(players.size(), 8):
		var label = get_node("Label" + str(i + 1)) as Label  
		label.visible = false



func _on_client_role_confirmed(uuid):
	for i in range(playerList.size()):
		if(playerList[i].uuid == uuid): 
			var icon = get_node("Label" + str(i+1) + "/Icon" + str(i + 1)) as Sprite2D 
			var label = get_node("Label" + str(i + 1)) as Label
			icon.visible = false
			label.text = ""
