extends Node

var debug # ref to DebugPanel for debug property assignment
var player
var player_state_machine

func _process(delta: float) -> void:
	debug.add_property("Current Velocity", "%.2f" % player.velocity.length(), 0)
	debug.add_property("Current State", player_state_machine.current_state.name, 1)
