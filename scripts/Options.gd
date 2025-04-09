extends Panel

@export var fullscreen_switcher : CheckButton

func _init() -> void:
    MenuGlobals.options = self

func _ready() -> void:
    visible = false


func _on_fullscreen_switcher_toggled(toggled_on:bool) -> void:
    if toggled_on:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
        print("FULLSCREEN MODE ENABLED")
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        print("FULLSCREEN MODE DISABLED")
