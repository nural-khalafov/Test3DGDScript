class_name PlayerMovementState extends State

var player_controller : PlayerController

func _ready() -> void:
    await owner.ready
    player_controller = owner as PlayerController

func _process(_delta: float) -> void:
    pass

