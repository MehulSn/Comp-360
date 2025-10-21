extends Node

func create_sand_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var tex := load("res://assets/textures/sand_texture.png")
	
	mat.albedo_texture = tex
	mat.roughness = 0.9
	mat.metallic = 0.0
	mat.uv1_scale = Vector3(4.0, 4.0, 1.0) # Adjust for proper scaling
	mat.name = "SandMaterial"
	
	return mat
