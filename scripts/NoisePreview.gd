extends Node2D

const FastNoiseTextureRes = preload("res://scripts/FastNoiseTexture.gd")

@onready var noise_tex = FastNoiseTextureRes.new()
@onready var preview = $NoisePreview

func _ready():
	noise_tex.seed = 42
	noise_tex.size = 256
	noise_tex.frequency = 0.02
	noise_tex.octaves = 5
	noise_tex.gain = 0.5
	noise_tex.regenerate()
	noise_tex.show_debug_preview(preview)
