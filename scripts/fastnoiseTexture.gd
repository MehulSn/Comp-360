extends Resource
class_name FastNoiseTexture

@export var seed: int = 1337:
	set(value):
		seed = value
		_dirty = true

@export var frequency: float = 0.01:
	set(value):
		frequency = value
		_dirty = true

@export var octaves: int = 4:
	set(value):
		octaves = value
		_dirty = true

@export var gain: float = 0.5:
	set(value):
		gain = value
		_dirty = true

@export var size: int = 256:
	set(value):
		size = clamp(value, 1, 256)
		_dirty = true

# Signal emitted when the noise or texture is regenerated
signal noise_updated(texture: Texture2D)

# Internal FastNoiseLite instance
var _noise: FastNoiseLite
var _image: Image
var _texture: ImageTexture
var _heightmap: PackedFloat32Array
var _dirty: bool = true

func _init() -> void:
	_noise = FastNoiseLite.new()
	_image = null
	_texture = null
	_heightmap = []
	_update_noise_settings()

# ------------------------------------------------------------
# INTERNAL CONFIGURATION
# ------------------------------------------------------------
func _update_noise_settings() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	_noise.seed = seed
	_noise.frequency = frequency
	_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_noise.fractal_octaves = octaves
	_noise.fractal_gain = gain

# ------------------------------------------------------------
# NOISE GENERATION
# ------------------------------------------------------------
func _normalize(value: float) -> float:
	return (value + 1.0) * 0.5

func _generate_image() -> Image:
	var img := Image.create(size, size, false, Image.FORMAT_RF)
	img.lock()
	for x in size:
		for y in size:
			var val = _normalize(_noise.get_noise_2d(x * frequency, y * frequency))
			img.set_pixel(x, y, Color(val, val, val))
	img.unlock()
	return img

func regenerate() -> void:
	_update_noise_settings()
	_image = _generate_image()
	_texture = ImageTexture.create_from_image(_image)
	_bake_heightmap()
	_dirty = false
	emit_signal("noise_updated", _texture)

# ------------------------------------------------------------
# HEIGHTMAP AND ACCESSORS
# ------------------------------------------------------------
func _bake_heightmap() -> void:
	_heightmap.resize(size * size)
	for x in size:
		for z in size:
			_heightmap[x * size + z] = _normalize(_noise.get_noise_2d(x * frequency, z * frequency))

func get_height(x: float, z: float) -> float:
	if _dirty:
		regenerate()
	x = clampi(int(x), 0, size - 1)
	z = clampi(int(z), 0, size - 1)
	return _heightmap[x * size + z]

func get_texture() -> ImageTexture:
	if _dirty or _texture == null:
		regenerate()
	return _texture

func get_image() -> Image:
	if _dirty or _image == null:
		regenerate()
	return _image

# ------------------------------------------------------------
# DEBUG VIEW (optional for testing)
# ------------------------------------------------------------
func show_debug_preview(node: TextureRect) -> void:
	if node and node is TextureRect:
		node.texture = get_texture()
