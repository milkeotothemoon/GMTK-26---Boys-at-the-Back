extends BaseItem
class_name ConnectorItem

signal triggered

func propagate_trigger() -> void:
	triggered.emit()
