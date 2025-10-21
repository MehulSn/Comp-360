@tool
extends MeshInstance3D

# --- Exported Parameters ---
@export_range(2, 1024, 1) var grid_size: int = 128 : set = set_grid_size
@export var quad_size: float = 1.0 : set = set_quad_size
@export var height_scale: float = 8.0 : set = set_height_scale
@export var noise_frequency: float = 0.02 : set = set_noise_frequency
@export var noise_seed: int = 1234 : set = set_noise_seed

# for ocean (future refrence)
@export var ocean_slope: float = 0.03 : set = set_ocean_slope
@export var ocean_direction: Vector2 = Vector2(1, 0) : set = set_ocean_direction # (x,z) direction

@export var auto_update_in_editor := true

# Internal
var noise := FastNoiseLite.new()
func vert_index(x_index: int, z_index: int, verts_per_side: int) -> int:
	return z_index * verts_per_side + x_index


# -----------------------------
# Initialization
# -----------------------------
func _ready():
	if Engine.is_editor_hint():
		_generate_beach_mesh()


# -----------------------------
# Property Setters
# -----------------------------
func set_grid_size(v): grid_size = max(2, v); _maybe_regenerate()
func set_quad_size(v): quad_size = max(0.1, v); _maybe_regenerate()
func set_height_scale(v): height_scale = v; _maybe_regenerate()
func set_noise_frequency(v): noise_frequency = v; _maybe_regenerate()
func set_noise_seed(v): noise_seed = v; _maybe_regenerate()
func set_ocean_slope(v): ocean_slope = v; _maybe_regenerate()
func set_ocean_direction(v):
	if v.length() > 0.001:
		ocean_direction = v.normalized()
	else:
		ocean_direction = Vector2(1, 0)
	_maybe_regenerate()



func _maybe_regenerate():
	if Engine.is_editor_hint() and auto_update_in_editor:
		_generate_beach_mesh()


# -----------------------------
# Main Mesh Generation
# -----------------------------
func _generate_beach_mesh():
	# Configure noise
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.frequency = noise_frequency
	noise.fractal_octaves = 4

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var verts_per_side := grid_size + 1
	var positions: Array = []
	var uvs: Array = []

	# --- Generate Vertex Grid ---
	for z in range(verts_per_side):
		for x in range(verts_per_side):
			var world_x = float(x) * quad_size
			var world_z = float(z) * quad_size

			var height_val = noise.get_noise_2d(world_x, world_z) * height_scale

			# Apply gentle slope toward ocean
			var slope_offset = ocean_slope * Vector2(world_x, world_z).dot(ocean_direction)
			height_val -= slope_offset

			positions.append(Vector3(world_x, height_val, world_z))
			uvs.append(Vector2(float(x) / grid_size, float(z) / grid_size))

	# --- Build triangles (shared vertices, no seams) ---




	for z in range(grid_size):
		for x in range(grid_size):
			var i0 = vert_index(x, z, verts_per_side)
			var i1 = vert_index(x + 1, z, verts_per_side)
			var i2 = vert_index(x, z + 1, verts_per_side)
			var i3 = vert_index(x + 1, z + 1, verts_per_side)



			# Triangle 1
			st.add_uv(uvs[i0]); st.add_vertex(positions[i0])
			st.add_uv(uvs[i2]); st.add_vertex(positions[i2])
			st.add_uv(uvs[i1]); st.add_vertex(positions[i1])

			# Triangle 2
			st.add_uv(uvs[i1]); st.add_vertex(positions[i1])
			st.add_uv(uvs[i2]); st.add_vertex(positions[i2])
			st.add_uv(uvs[i3]); st.add_vertex(positions[i3])

	st.generate_normals()
	var mesh_data = st.commit()
	mesh = mesh_data

	# Assign material
	material_override = _create_sand_material()


# -----------------------------
# Material Setup
# -----------------------------
func _create_sand_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/sand_texture.webp")
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.albedo_color = Color(0.95, 0.85, 0.6)
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.texture_repeat = true
	return mat


# -----------------------------
# Manual Regeneration Function
# -----------------------------
func regenerate():
	_generate_beach_mesh()
