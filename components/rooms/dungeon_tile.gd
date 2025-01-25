class_name RoomSprite extends Sprite2D

var red : Color = Color(0.827, 0, 0)
var purple : Color = Color(0.827, 0.408, 1)
var green : Color = Color(0, 0.745, 0)

func make_shader_red():
	get_material().set_shader_parameter("color", red);

func make_shader_purple():
	get_material().set_shader_parameter("color", purple);
	
func make_shader_green():
	get_material().set_shader_parameter("color", green);

func turn_on_shader():
	self.get_material().set_shader_parameter("maxLineWidth", 5);
	self.get_material().set_shader_parameter("minLineWidth", 1);

func turn_off_shader():
	self.get_material().set_shader_parameter("maxLineWidth", 0);
	self.get_material().set_shader_parameter("minLineWidth", 0);
	
