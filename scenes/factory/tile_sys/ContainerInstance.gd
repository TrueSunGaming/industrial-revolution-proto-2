class_name ContainerEntityInstance extends TileEntityInstance

func add_item(item: ItemStack) -> int:
	assert(false, "Cannot add item to abstract class ContainerEntityInstance")
	
	return 0

func remove_item(item: ItemStack) -> bool:
	assert(false, "Cannot remove item from abstract class ContainerEntityInstance")
	
	return false
