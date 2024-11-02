extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_node_player_list_changed(players):
	for i in range(players.size()):
		var player_name = players[i].username  # Assuming players is an Array containing player names
		var label = get_node("Label" + str(i + 1)) as Label  # Construct node name dynamically
		label.text = player_name
		
	for i in range(players.size(), 8):
		var label = get_node("Label" + str(i + 1)) as Label  # Construct node name dynamically
		var pic = get_node("Icon" + str(i+1)) as Sprite2D
		if label:
			label.text = "..."
		if pic:
			pic.visible = false
	
	for i in range(players.size()):
		var iconNum = players[i].icon
		var pic = get_node("Icon" + str(i+1)) as Sprite2D
		pic.visible=true
		pic.texture = load("res://gfx/icons/" + str(iconNum) + ".png")

