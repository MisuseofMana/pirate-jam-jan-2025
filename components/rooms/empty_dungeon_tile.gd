class_name EmptyRoomSprite extends Sprite2D

var red : Color = Color(0.827, 0, 0)
var purple : Color = Color(0.827, 0.408, 1)
var green : Color = Color(0, 0.745, 0)

func make_shader_red():
	modulate = red
	get_material().set_shader_parameter("color", red);

func make_shader_purple():
	modulate = purple
	get_material().set_shader_parameter("color", purple);
	
func make_shader_green():
	modulate = green
	get_material().set_shader_parameter("color", green);
	
func turn_on_shader():
	get_material().set_shader_parameter("maxLineWidth", 2);
	get_material().set_shader_parameter("minLineWidth", 1);

func turn_off_shader():
	get_material().set_shader_parameter("maxLineWidth", 0);
	get_material().set_shader_parameter("minLineWidth", 0);
