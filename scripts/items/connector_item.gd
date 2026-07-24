extends BaseItem
class_name ConnectorItem

## Seconds of delay this connector introduces between the items it links.
@export var link_delay: float = 0.3

signal triggered

func propagate_trigger() -> void:
	triggered.emit()

func links(a: BaseItem, b: BaseItem) -> bool:
	if a == null or b == null:
		return false
	var da := a.grid_position.distance_to(grid_position)
	var db := b.grid_position.distance_to(grid_position)
	return da <= 1.5 and db <= 1.5
