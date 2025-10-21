extends Node

func apply_sand_material(target: MeshInstance3D):
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/sand_texture.webp")
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.albedo_color = Color(0.95, 0.85, 0.6)
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.texture_repeat = true
	target.material_override = mat
