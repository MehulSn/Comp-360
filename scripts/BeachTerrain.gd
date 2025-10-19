extends MeshInstance3D

@export var grid_size: int = 128
@export var quad_size: float = 1.0
@export var height_scale: float = 8.0
@export var noise_frequency: float = 0.02
@export var noise_seed: int = 1234

func _ready():
	generate_beach_mesh()


func generate_beach_mesh():
	var noise = FastNoiseLite.new()
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.frequency = noise_frequency
	noise.fractal_octaves = 4

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in range(grid_size):
		for x in range(grid_size):
			var h1 = noise.get_noise_2d(x, z) * height_scale
			var h2 = noise.get_noise_2d(x + 1, z) * height_scale
			var h3 = noise.get_noise_2d(x, z + 1) * height_scale
			var h4 = noise.get_noise_2d(x + 1, z + 1) * height_scale

			var p1 = Vector3(x * quad_size, h1, z * quad_size)
			var p2 = Vector3((x + 1) * quad_size, h2, z * quad_size)
			var p3 = Vector3(x * quad_size, h3, (z + 1) * quad_size)
			var p4 = Vector3((x + 1) * quad_size, h4, (z + 1) * quad_size)

			# first triangle
			st.add_vertex(p1)
			st.add_vertex(p3)
			st.add_vertex(p2)
			# second triangle
			st.add_vertex(p2)
			st.add_vertex(p3)
			st.add_vertex(p4)

	st.generate_normals()

	var mesh_data = st.commit()
	mesh = mesh_data
	material_override = create_sand_material()


func create_sand_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/sand_texture.webp")
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.albedo_color = Color(0.95, 0.85, 0.6)
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return mat
