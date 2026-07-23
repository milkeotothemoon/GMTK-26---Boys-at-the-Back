extends BaseItem
class_name ModifierItem

var attached_to: SoundItem = null

func attach_to(target: SoundItem) -> void:
	attached_to = target
