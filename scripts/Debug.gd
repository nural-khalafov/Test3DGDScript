extends PanelContainer

@onready var property_container = %VBoxContainer

var property
var frames_per_second : String

func _ready() -> void:
    # set global ref to self in Global Singleton
    Global.debug = self
    
    # hide debug panel on load
    visible = false

    # add_debug_property("FPS", frames_per_second)

func _process(delta: float) -> void:
    if visible:
        # use delta time to get approx frames per second and round to two decimal places !Disable VSync if fps is stuck at 60
        frames_per_second = "%.2f" % (1.0/delta)
        # frames_per_second = Engine.get_frames_per_second() # gets frames per second every second
        # property.text = property.name + ": " + frames_per_second

func _input(event: InputEvent) -> void:
    # toggle debug panel
    if event.is_action_pressed("debug"):
        visible = !visible

func add_property(title: String, value, order):
    var target
    target = property_container.find_child(title, true, false) # try to find Label node with same name

    if !target: # if there is no current Label node for property (ie. initial load)
        target = Label.new() # create new Label node
        property_container.add_child(target) # add new node as child to VBox container
        target.name = title # set name to title
        target.text = target.name + ": " + str(value) # set text value
    elif visible:
        target.text = title + ": " + str(value) # update text value
        property_container.move_child(target, order) # reorder property based on given order value

# callable function to add new debug property
# func add_debug_property(title: String, value):
#     property = Label.new() # create new Label node
#     property_container.add_child(property) # add new node as child to VBox container
#     property.name = title # set name to title
#     property.text = property.name + value