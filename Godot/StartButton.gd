extends Button

var minPlayers = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false


func _on_client_player_list_changed(players):
	if(players.size() >= minPlayers):
		self.visible = true
	else:
		self.visible = false
