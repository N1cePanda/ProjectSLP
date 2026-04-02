extends Node

signal health_changed(new_health : float)

@export var health := 100.0: #says that the var health starts at 100
	set(value):  #start of set 
		health = clamp(value, 0.0, 100.0) #clamp makes it so you cannot go above or below the int
		health_changed.emit(health) #uses the signal to emit a new health value

func boosted_health(boost_mult:float) -> float:
	return health * boost_mult
 
var boost_mult := 2

func _ready () ->void:
	health = 12.3 * boost_mult
	if health >= 100.0:
		print("you are healthy")
	elif health > 0:
			print("you are injured")
	else:
		print("you have pawed away")



func _on_health_changed(new_health : float) ->void:
	print(new_health)

#func health_lookup (): 
	#print(health) #this is a lookup expression that will tell you what that value is at the time of calling

#func boosted_health():
	#return health * 1.5 
