extends Panel
class_name Strength

@export var tempStatManager : TempStatManager
@export var strength : stat
@export var strengthLabel : Label
@export var addStrengthButton : Button
@export var removeStrengthButton : Button 
@export var addTempStrengthButton : Button

func _ready() -> void:
	strength.initialize()
	strength.stat_adjusted.connect(_update_strength_label)
	
	addStrengthButton.pressed.connect(_add_strength)
	removeStrengthButton.pressed.connect(_remove_strength)
	addTempStrengthButton.pressed.connect(_add_temp_strength)
	strengthLabel.text = "Strength" + str(strength.basevalue)

func _add_strength() -> void:
	var strengthStatModifier : StatModifier = StatModifier.new()
	strengthStatModifier.initialize(5, StatModifier.StatModifierType.ADD)
	strength.add_stat_modifier(strengthStatModifier)
	strengthLabel.text = "Strength" + str(strength.adjustedValue)

func _remove_strength()-> void:
	if strength.statModifiers.is_empty():
		return
	strength.remove_stat_modifier(strength.statModifiers[0])
	strengthLabel.text = "Strength" + str(strength.adjustedValue)

func _add_temp_strength() ->void:
	var strengthStatModifier : StatModifier = StatModifier.new()
	strengthStatModifier.initialize(5, StatModifier.StatModifierType.ADD, 3)
	strength.add_temp_stat_modifier(strengthStatModifier, tempStatManager)
	strengthLabel.text = "Strength:" + str(strength.adjustedValue)

func _update_strength_label(_stat : stat) ->void:
	strengthLabel.text + "Strength" + str(_stat.adjustedValue)
