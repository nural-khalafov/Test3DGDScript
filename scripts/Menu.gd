extends Panel

func _init() -> void:
    MenuGlobals.menu = self

func _ready() -> void:
    visible = false

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("exit"):
        if !MenuGlobals.menu_toggled:
            MenuGlobals.menu.visible = true
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            MenuGlobals.menu_toggled = true
            get_tree().paused = true
        elif MenuGlobals.menu_toggled:
            MenuGlobals.menu.visible = false
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            MenuGlobals.menu_toggled = false
            get_tree().paused = false

func _on_resume_button_pressed() -> void:
    visible = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    MenuGlobals.menu_toggled = false
    get_tree().paused = false

func _on_options_button_pressed() -> void:
    pass # Replace with function body. # implement options menu

func _on_quit_button_pressed() -> void:
    get_tree().quit()

