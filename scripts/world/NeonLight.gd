@tool
extends PointLight2D

## Generates a radial gradient texture for the light at runtime.
## Set color and energy in the inspector.

@export var light_radius: float = 128.0:
	set(value):
		light_radius = value
		_update_texture()


func _ready() -> void:
	_update_texture()


func _update_texture() -> void:
	var img := Image.create(int(light_radius * 2), int(light_radius * 2), false, Image.FORMAT_RGBA8)
	var center := Vector2(light_radius, light_radius)
	for y in img.get_height():
		for x in img.get_width():
			var dist := Vector2(x, y).distance_to(center) / light_radius
			var alpha := clampf(1.0 - dist, 0.0, 1.0)
			alpha = alpha * alpha  # Quadratic falloff
			img.set_pixel(x, y, Color(1, 1, 1, alpha))
	texture = ImageTexture.create_from_image(img)
