extends Node
class_name TempStatManager

var tempStats : Array[StatModifier]

func add_temp_stat(_newTempStatModifier : StatModifier) -> void: 
	if _newTempStatModifier.duration > 0:
		tempStats.append(_newTempStatModifier)
	return
	
	printerr("ERROR: Tried to add a temp stat modifier to StatManager that was not a temp stat modifier!")
	
func _process(delta : float) ->void:
	if !tempStats.is_empty():
		update_temp_stat_modifier()

func update_temp_stat_modifier()->void:
	var statsToRemove : Array[StatModifier] = []
	
	for tempStat in tempStats: 
		tempStat.duration -= get_process_delta_time()
	
	if tempStat.duration <= 0:
		statsToRemove.append_array(tempStat) 
	
	for statToRemove in statsToRemove:
		tempStats.erase(statToRemove)
	
	statsToRemove.clear()
