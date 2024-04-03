class_name TileEntityInstance extends Resource

signal world_attached(world)
signal world_removed
signal world_tick(delta)

static var next_id := 0
static var list := {}

@export var data_id: String
@export var position: Vector2:
	set(val):
		position = val
		update_position()

@export var rotation: float:
	set(val):
		rotation = global.clamp_deg(val)
		if node_ref: node_ref.global_rotation_degrees = rotation
		update_position()

var next_rotation: float:
	get:
		return global.add_deg(rotation, tile_data.rotation_step)

var prev_rotation: float:
	get:
		return global.sub_deg(rotation, tile_data.rotation_step)

var node_ref: Node2D
var id: int
var world: TileWorld:
	set(val):
		if val == world: return
		world = val
		
		if val != null:
			world_attached.emit(val)
			world.tick.connect(relay_tick)
			world.tile_render.emit(id)
		else:
			world_removed.emit()
			if world.tick.is_connected(relay_tick): world.tick.disconnect(relay_tick)

var tile_data: TileEntityData:
	get:
		return TileEntityData.get_tile_data(data_id)

var placement_rect: Rect2:
	get:
		return Rect2(position, tile_data.placement_size)

var index: int:
	get:
		if not world: return -1
		
		return world.tiles.find(func (v): return v.id == id)

var render_position: Vector2:
	get:
		if not world: return Vector2()
		
		return world.tile_to_world(position - global.center_rotation_displacement(placement_rect, rotation))

var render_rect: Rect2:
	get:
		if not world: return Rect2()
		
		var rect := global.rotated_bounding_box(placement_rect, rotation)
		
		return Rect2(
			world.tile_to_world(rect.position),
			rect.size * world.tile_size
		)

func _init() -> void:
	id = next_id
	next_id += 1
	
	list[id] = self

static func get_tile(id: int) -> TileEntityInstance:
	return list.get(id)

func remove_from_world() -> void:
	if not world: return
	
	var idx := world.tiles.find(func (v: TileEntityInstance): return v.id == id)
	world.tiles.remove_at(idx)
	
	world.tile_removed.emit(id)

func relay_tick(delta: float) -> void:
	world_tick.emit(delta)

func update_position() -> void:
	if node_ref: node_ref.position = render_position
