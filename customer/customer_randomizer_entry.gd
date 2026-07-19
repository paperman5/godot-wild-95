class_name CustomerRandomizerEntry
extends Resource

@export var order_ice_cream := true
@export_range(1, 3, 1) var ice_cream_scoops := 1
@export var picky := false

@export var order_food := false

@export_range(1, 100, 1, "or_greater") var amount := 1

func create_customer() -> Customer:
	var customer := preload("uid://uddj0n5ca5xs").instantiate() as Customer
	customer.customer_type = [Customer.CustomerType.Nightwalker,
								Customer.CustomerType.Mothman,
								Customer.CustomerType.Yeti,
								Customer.CustomerType.Goo,
								Customer.CustomerType.Alien].pick_random()
	var orders : Array[FoodItem] = []
	if order_food:
		var food := preload("uid://b6duh0virt7sy").instantiate() as CookedFood
		food.food_type = [Utils.FoodType.MonsterMashBurger, 
							Utils.FoodType.Werewaffles].pick_random()
		food.icon = true
		orders.append(food)
	if order_ice_cream:
		var ice_cream := preload("uid://cg80er3ff08wp").instantiate() as IceCream
		for i in range(ice_cream_scoops):
			var flavor = [Utils.IceCreamType.BooBerry, 
							Utils.IceCreamType.ShockALot, 
							Utils.IceCreamType.Vilenilla].pick_random()
			ice_cream.add_flavor(flavor)
		ice_cream.strict_order = picky
		orders.append(ice_cream)
	customer.set_orders(orders)
	return customer
