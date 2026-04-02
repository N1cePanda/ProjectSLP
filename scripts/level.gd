extends Node 

signal leveled_up(msg : String)

var xp := 0 
 
func _on_pressed() ->void:
	xp += 5 
	print(xp) 
	if xp >= 20: 
		xp = 0  
		leveled_up.emit("You Leveled Up!!!!")

func _on_leveled_up(msg : String) -> void:
	print(msg)
