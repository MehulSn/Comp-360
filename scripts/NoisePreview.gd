@tool
extends TextureRect

@export var noise_seed: int = 1234 : set = _update_preview
@export var noise_frequency: float = 0.02 : set = _update_preview
@export var noise_size: int = 256 : set = _update_preview

var _noise := FastNoiseLite.new()

func _ready():
	_update_preview()

func _update_preview(_v = null):
	print("Generating noise preview...")

	if !is_inside_tree():
		return

	# --- configure noise ---
	_noise.seed = noise_seed
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.frequency = noise_frequency
	_noise.fractal_octaves = 4

	# --- build image ---
	var img := Image.create(noise_size, noise_size, false, Image.FORMAT_RGB8)
	for x in range(noise_size):
		for y in range(noise_size):
			var n := _noise.get_noise_2d(x, y)
			n = (n + 1.0) * 0.5             # normalize [-1,1] → [0,1]
			img.set_pixel(x, y, Color(n, n, n))

	# --- apply as texture ---
	var tex := ImageTexture.create_from_image(img)
	texture = tex
