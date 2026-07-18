class_name CustomerRandomizer
extends Resource

@export var randomizer_entries : Array[CustomerRandomizerEntry] = []

func pick_customer() -> Customer:
	if len(randomizer_entries) == 0:
		return null
	var ei = randi_range(0, len(randomizer_entries)-1)
	var customer = randomizer_entries[ei].create_customer()
	randomizer_entries[ei].amount -= 1
	if randomizer_entries[ei].amount <= 0:
		randomizer_entries.remove_at(ei)
	return customer
