class_name CarSetupMenu
extends TabContainer


func update_params(params: CarParameters):
	$Suspension/VBoxContainer/FrontSuspAntiRollRate/SpinBox.value = params.wheel_params_fl.anti_roll
	$Suspension/VBoxContainer/FrontSuspBumpRateLo/SpinBox.value = params.wheel_params_fl.bump_ls
	$Suspension/VBoxContainer/FrontSuspBumpRateHi/SpinBox.value = params.wheel_params_fl.bump_hs
	$Suspension/VBoxContainer/FrontSuspReboundRateLo/SpinBox.value = params.wheel_params_fl.rebound_ls
	$Suspension/VBoxContainer/FrontSuspReboundRateHi/SpinBox.value = params.wheel_params_fl.rebound_hs
	$Suspension/VBoxContainer/FrontSuspLength/Slider.value = params.wheel_params_fl.spring_length
	$Suspension/VBoxContainer/FrontSuspLength/Label2.text = str(params.wheel_params_fl.spring_length)
	$Suspension/VBoxContainer/FrontSuspSpringRate/SpinBox.value = params.wheel_params_fl.spring_stiffness
	
	$Suspension/VBoxContainer/RearSuspAntiRollRate/SpinBox.value = params.wheel_params_bl.anti_roll
	$Suspension/VBoxContainer/RearSuspBumpRateLo/SpinBox.value = params.wheel_params_bl.bump_ls
	$Suspension/VBoxContainer/RearSuspBumpRateHi/SpinBox.value = params.wheel_params_bl.bump_hs
	$Suspension/VBoxContainer/RearSuspReboundRateLo/SpinBox.value = params.wheel_params_bl.rebound_ls
	$Suspension/VBoxContainer/RearSuspReboundRateHi/SpinBox.value = params.wheel_params_bl.rebound_hs
	$Suspension/VBoxContainer/RearSuspLength/Slider.value = params.wheel_params_bl.spring_length
	$Suspension/VBoxContainer/RearSuspLength/Label2.text = str(params.wheel_params_bl.spring_length)
	$Suspension/VBoxContainer/RearSuspSpringRate/SpinBox.value = params.wheel_params_bl.spring_stiffness
	
	$Wheels/VBoxContainer/BrakeBiasFrontBack/Slider.value = params.front_brake_bias
	$Wheels/VBoxContainer/BrakeBiasFrontBack/Label2.text = str(params.front_brake_bias)
	$Wheels/VBoxContainer/TireStiffness/Slider.value = params.wheel_params_fl.tire_model.tire_stiffness
	$Wheels/VBoxContainer/TireStiffness/Label2.text = str(params.wheel_params_fl.tire_model.tire_stiffness)
	$Wheels/VBoxContainer/ThreadLength/Slider.value = params.wheel_params_fl.tire_model.thread_length
	$Wheels/VBoxContainer/ThreadLength/Label2.text = "%2.2f" % params.wheel_params_fl.tire_model.thread_length
	$Wheels/VBoxContainer/TireWidth/Slider.value = params.wheel_params_fl.tire_model.tire_width
	$Wheels/VBoxContainer/TireWidth/Label2.text = str(params.wheel_params_fl.tire_model.tire_width)
	$Wheels/VBoxContainer/TireRatio/Slider.value = params.wheel_params_fl.tire_model.tire_ratio
	$Wheels/VBoxContainer/TireRatio/Label2.text = "%2.2f" % params.wheel_params_fl.tire_model.tire_ratio
	$Wheels/VBoxContainer/RimSize/Slider.value = params.wheel_params_fl.tire_model.tire_rim_size
	$Wheels/VBoxContainer/RimSize/Label2.text = "%2.1f" % params.wheel_params_fl.tire_model.tire_rim_size
	
	$Wheels/VBoxContainer/RearTireStiffness/Slider.value = params.wheel_params_bl.tire_model.tire_stiffness
	$Wheels/VBoxContainer/RearTireStiffness/Label2.text = str(params.wheel_params_bl.tire_model.tire_stiffness)
	$Wheels/VBoxContainer/RearThreadLength/Slider.value = params.wheel_params_bl.tire_model.thread_length
	$Wheels/VBoxContainer/RearThreadLength/Label2.text = "%2.2f" % params.wheel_params_bl.tire_model.thread_length
	$Wheels/VBoxContainer/RearTireWidth/Slider.value = params.wheel_params_bl.tire_model.tire_width
	$Wheels/VBoxContainer/RearTireWidth/Label2.text = str(params.wheel_params_bl.tire_model.tire_width)
	$Wheels/VBoxContainer/RearTireRatio/Slider.value = params.wheel_params_bl.tire_model.tire_ratio
	$Wheels/VBoxContainer/RearTireRatio/Label2.text = "%2.2f" % params.wheel_params_bl.tire_model.tire_ratio
	$Wheels/VBoxContainer/RearRimSize/Slider.value = params.wheel_params_bl.tire_model.tire_rim_size
	$Wheels/VBoxContainer/RearRimSize/Label2.text = "%2.1f" % params.wheel_params_bl.tire_model.tire_rim_size
	
	$Drivetrain/VBoxContainer/TorqueSplit/Slider.value = params.drivetrain_params.center_split_fr
	$Drivetrain/VBoxContainer/TorqueSplit/Label2.text = str(params.drivetrain_params.center_split_fr)
	$Drivetrain/VBoxContainer/FinalRatio/Slider.value = params.drivetrain_params.final_drive
	$Drivetrain/VBoxContainer/FinalRatio/Label2.text = str(params.drivetrain_params.final_drive)
	$Drivetrain/VBoxContainer/ReverseRatio/Slider.value = params.drivetrain_params.reverse_ratio
	$Drivetrain/VBoxContainer/ReverseRatio/Label2.text = str(params.drivetrain_params.reverse_ratio)
	$Drivetrain/VBoxContainer/FrontDiffPreload/Label2.text = str(params.drivetrain_params.front_diff.diff_preload)
	$Drivetrain/VBoxContainer/FrontDiffPowerRatio/Label2.text = str(params.drivetrain_params.front_diff.power_ratio)
	$Drivetrain/VBoxContainer/FrontDiffCoastRatio/Label2.text = str(params.drivetrain_params.front_diff.coast_ratio)
	$Drivetrain/VBoxContainer/RearDiffPreload/Label2.text = str(params.drivetrain_params.rear_diff.diff_preload)
	$Drivetrain/VBoxContainer/RearDiffPowerRatio/Label2.text = str(params.drivetrain_params.rear_diff.power_ratio)
	$Drivetrain/VBoxContainer/RearDiffCoastRatio/Label2.text = str(params.drivetrain_params.rear_diff.coast_ratio)
	
	var gear_amount := params.drivetrain_params.gear_ratios.size()
	
	match gear_amount:
		1:
			$Drivetrain/VBoxContainer/Gear1/Slider.value = params.drivetrain_params.gear_ratios[0]
			$Drivetrain/VBoxContainer/Gear1/Label2.text = str(params.drivetrain_params.gear_ratios[0])
		2:
			$Drivetrain/VBoxContainer/Gear1/Slider.value = params.drivetrain_params.gear_ratios[0]
			$Drivetrain/VBoxContainer/Gear1/Label2.text = str(params.drivetrain_params.gear_ratios[0])
			$Drivetrain/VBoxContainer/Gear2/Slider.value = params.drivetrain_params.gear_ratios[1]
			$Drivetrain/VBoxContainer/Gear2/Label2.text = str(params.drivetrain_params.gear_ratios[1])
		3:
			$Drivetrain/VBoxContainer/Gear1/Slider.value = params.drivetrain_params.gear_ratios[0]
			$Drivetrain/VBoxContainer/Gear1/Label2.text = str(params.drivetrain_params.gear_ratios[0])
			$Drivetrain/VBoxContainer/Gear2/Slider.value = params.drivetrain_params.gear_ratios[1]
			$Drivetrain/VBoxContainer/Gear2/Label2.text = str(params.drivetrain_params.gear_ratios[1])
			$Drivetrain/VBoxContainer/Gear3/Slider.value = params.drivetrain_params.gear_ratios[2]
			$Drivetrain/VBoxContainer/Gear3/Label2.text = str(params.drivetrain_params.gear_ratios[2])
		4:
			$Drivetrain/VBoxContainer/Gear1/Slider.value = params.drivetrain_params.gear_ratios[0]
			$Drivetrain/VBoxContainer/Gear1/Label2.text = str(params.drivetrain_params.gear_ratios[0])
			$Drivetrain/VBoxContainer/Gear2/Slider.value = params.drivetrain_params.gear_ratios[1]
			$Drivetrain/VBoxContainer/Gear2/Label2.text = str(params.drivetrain_params.gear_ratios[1])
			$Drivetrain/VBoxContainer/Gear3/Slider.value = params.drivetrain_params.gear_ratios[2]
			$Drivetrain/VBoxContainer/Gear3/Label2.text = str(params.drivetrain_params.gear_ratios[2])
			$Drivetrain/VBoxContainer/Gear4/Slider.value = params.drivetrain_params.gear_ratios[3]
			$Drivetrain/VBoxContainer/Gear4/Label2.text = str(params.drivetrain_params.gear_ratios[3])
		5:
			$Drivetrain/VBoxContainer/Gear1/Slider.value = params.drivetrain_params.gear_ratios[0]
			$Drivetrain/VBoxContainer/Gear1/Label2.text = str(params.drivetrain_params.gear_ratios[0])
			$Drivetrain/VBoxContainer/Gear2/Slider.value = params.drivetrain_params.gear_ratios[1]
			$Drivetrain/VBoxContainer/Gear2/Label2.text = str(params.drivetrain_params.gear_ratios[1])
			$Drivetrain/VBoxContainer/Gear3/Slider.value = params.drivetrain_params.gear_ratios[2]
			$Drivetrain/VBoxContainer/Gear3/Label2.text = str(params.drivetrain_params.gear_ratios[2])
			$Drivetrain/VBoxContainer/Gear4/Slider.value = params.drivetrain_params.gear_ratios[3]
			$Drivetrain/VBoxContainer/Gear4/Label2.text = str(params.drivetrain_params.gear_ratios[3])
			$Drivetrain/VBoxContainer/Gear5/Slider.value = params.drivetrain_params.gear_ratios[4]
			$Drivetrain/VBoxContainer/Gear5/Label2.text = str(params.drivetrain_params.gear_ratios[4])
		6:
			$Drivetrain/VBoxContainer/Gear1/Slider.value = params.drivetrain_params.gear_ratios[0]
			$Drivetrain/VBoxContainer/Gear1/Label2.text = str(params.drivetrain_params.gear_ratios[0])
			$Drivetrain/VBoxContainer/Gear2/Slider.value = params.drivetrain_params.gear_ratios[1]
			$Drivetrain/VBoxContainer/Gear2/Label2.text = str(params.drivetrain_params.gear_ratios[1])
			$Drivetrain/VBoxContainer/Gear3/Slider.value = params.drivetrain_params.gear_ratios[2]
			$Drivetrain/VBoxContainer/Gear3/Label2.text = str(params.drivetrain_params.gear_ratios[2])
			$Drivetrain/VBoxContainer/Gear4/Slider.value = params.drivetrain_params.gear_ratios[3]
			$Drivetrain/VBoxContainer/Gear4/Label2.text = str(params.drivetrain_params.gear_ratios[3])
			$Drivetrain/VBoxContainer/Gear5/Slider.value = params.drivetrain_params.gear_ratios[4]
			$Drivetrain/VBoxContainer/Gear5/Label2.text = str(params.drivetrain_params.gear_ratios[4])
			$Drivetrain/VBoxContainer/Gear6/Slider.value = params.drivetrain_params.gear_ratios[5]
			$Drivetrain/VBoxContainer/Gear6/Label2.text = str(params.drivetrain_params.gear_ratios[5])


func update_tire_model(tire_model: BaseTireModel):
	tire_model.tire_stiffness = $Wheels/VBoxContainer/TireStiffness/Slider.value
	tire_model.thread_length = $Wheels/VBoxContainer/ThreadLength/Slider.value
	tire_model.tire_width = $Wheels/VBoxContainer/TireWidth/Slider.value
	tire_model.tire_ratio = $Wheels/VBoxContainer/TireRatio/Slider.value
	tire_model.tire_rim_size = $Wheels/VBoxContainer/RimSize/Slider.value


func _on_car_selected():
	update_params(SessionManager.player_car_setup)



func _on_front_spring_length_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.spring_length = value
	SessionManager.player_car_setup.wheel_params_fr.spring_length = value
	$Suspension/VBoxContainer/FrontSuspLength/Label2.text = str(value)


func _on_front_spring_rate_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.spring_stiffness = value
	SessionManager.player_car_setup.wheel_params_fr.spring_stiffness = value


func _on_front_bump_rate_lo_changed(value):
	SessionManager.player_car_setup.wheel_params_fl.bump_ls = value
	SessionManager.player_car_setup.wheel_params_fr.bump_ls = value


func _on_front_bump_rate_hi_changed(value):
	SessionManager.player_car_setup.wheel_params_fl.bump_hs = value
	SessionManager.player_car_setup.wheel_params_fr.bump_hs = value

func _on_front_rebound_rate_lo_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.rebound_ls = value
	SessionManager.player_car_setup.wheel_params_fr.rebound_ls = value

func _on_front_rebound_rate_hi_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.rebound_hs = value
	SessionManager.player_car_setup.wheel_params_fr.rebound_hs = value
	
func _on_front_anti_roll_changed(value:float):
	SessionManager.player_car_setup.wheel_params_fl.anti_roll = value
	SessionManager.player_car_setup.wheel_params_fr.anti_roll = value


func _on_rear_spring_length_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.spring_length = value
	SessionManager.player_car_setup.wheel_params_br.spring_length = value
	$Suspension/VBoxContainer/RearSuspLength/Label2.text = str(value)


func _on_rear_spring_rate_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.spring_stiffness = value
	SessionManager.player_car_setup.wheel_params_br.spring_stiffness = value


func _on_rear_bump_rate_lo_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.bump_ls = value
	SessionManager.player_car_setup.wheel_params_br.bump_ls = value

func _on_rear_bump_rate_hi_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.bump_hs = value
	SessionManager.player_car_setup.wheel_params_br.bump_hs = value

func _on_rear_rebound_rate_lo_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.rebound_ls = value
	SessionManager.player_car_setup.wheel_params_br.rebound_ls = value

func _on_rear_rebound_rate_hi_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.rebound_hs = value
	SessionManager.player_car_setup.wheel_params_br.rebound_hs = value

func _on_rear_anti_roll_changed(value:float):
	SessionManager.player_car_setup.wheel_params_bl.anti_roll = value
	SessionManager.player_car_setup.wheel_params_br.anti_roll = value


func _on_brake_bias_changed(value: float) -> void:
	SessionManager.player_car_setup.front_brake_bias = value
	$Wheels/VBoxContainer/BrakeBiasFrontBack/Label2.text = str(value)


func _on_tire_stiffness_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_fr.tire_model.tire_stiffness = value
	SessionManager.player_car_setup.wheel_params_fl.tire_model.tire_stiffness = value
	$Wheels/VBoxContainer/TireStiffness/Label2.text = str(value)


func _on_rear_tire_stiffness_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_bl.tire_model.tire_stiffness = value
	SessionManager.player_car_setup.wheel_params_br.tire_model.tire_stiffness = value
	$Wheels/VBoxContainer/RearTireStiffness/Label2.text = str(value)


func _on_tire_width_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_fl.tire_model.tire_width = value
	SessionManager.player_car_setup.wheel_params_fr.tire_model.tire_width = value
	$Wheels/VBoxContainer/TireWidth/Label2.text = "%2.3f" % value


func _on_rear_tire_width_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_bl.tire_model.tire_width = value
	SessionManager.player_car_setup.wheel_params_br.tire_model.tire_width = value
	$Wheels/VBoxContainer/RearTireWidth/Label2.text = "%2.3f" % value


func _on_thread_length_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_fl.tire_model.thread_length = value
	SessionManager.player_car_setup.wheel_params_fr.tire_model.thread_length = value
	$Wheels/VBoxContainer/ThreadLength/Label2.text = "%2.2f" % value


func _on_rear_thread_length_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_bl.tire_model.thread_length = value
	SessionManager.player_car_setup.wheel_params_br.tire_model.thread_length = value
	$Wheels/VBoxContainer/RearThreadLength/Label2.text = "%2.2f" % value


func _on_tire_aspect_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_fl.tire_model.tire_ratio = value
	SessionManager.player_car_setup.wheel_params_fr.tire_model.tire_ratio = value
	$Wheels/VBoxContainer/TireRatio/Label2.text = "%2.2f" % value


func _on_rear_tire_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_bl.tire_model.tire_ratio = value
	SessionManager.player_car_setup.wheel_params_br.tire_model.tire_ratio = value
	$Wheels/VBoxContainer/RearTireRatio/Label2.text = "%2.2f" % value


func _on_rim_size_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_fl.tire_model.tire_rim_size = value
	SessionManager.player_car_setup.wheel_params_fr.tire_model.tire_rim_size = value
	$Wheels/VBoxContainer/RimSize/Label2.text = "%2.1f" % value


func _on_rear_rim_size_changed(value: float) -> void:
	SessionManager.player_car_setup.wheel_params_bl.tire_model.tire_rim_size = value
	SessionManager.player_car_setup.wheel_params_br.tire_model.tire_rim_size = value
	$Wheels/VBoxContainer/RearRimSize/Label2.text = "%2.1f" % value

func _on_torque_split_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.center_split_fr = value
	$Drivetrain/VBoxContainer/TorqueSplit/Label2.text = str(value)


func _on_final_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.final_drive = value
	$Drivetrain/VBoxContainer/FinalRatio/Label2.text = str(value)

func _on_gear1_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.gear_ratios[0] = value
	$Drivetrain/VBoxContainer/Gear1/Label2.text = str(value)


func _on_gear2_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.gear_ratios[1] = value
	$Drivetrain/VBoxContainer/Gear2/Label2.text = str(value)


func _on_gear3_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.gear_ratios[2] = value
	$Drivetrain/VBoxContainer/Gear3/Label2.text = str(value)


func _on_gear4_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.gear_ratios[3] = value
	$Drivetrain/VBoxContainer/Gear4/Label2.text = str(value)


func _on_gear5_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.gear_ratios[4] = value
	$Drivetrain/VBoxContainer/Gear5/Label2.text = str(value)


func _on_gear6_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.gear_ratios[5] = value
	$Drivetrain/VBoxContainer/Gear6/Label2.text = str(value)


func _on_reverse_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.reverse_ratio = value
	$Drivetrain/VBoxContainer/ReverseRatio/Label2.text = str(value)


func _on_front_diff_preload_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.front_diff.diff_preload = value
	$Drivetrain/VBoxContainer/FrontDiffPreload/Label2.text = str(value)


func _on_front_diff_power_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.front_diff.power_ratio = value
	$Drivetrain/VBoxContainer/FrontDiffPowerRatio/Label2.text = str(value)


func _on_front_diff_coast_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.front_diff_coast.ratio = value
	$Drivetrain/VBoxContainer/FrontDiffCoastRatio/Label2.text = str(value)


func _on_rear_diff_preload_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.rear_diff.diff_preload = value
	$Drivetrain/VBoxContainer/RearDiffPreload/Label2.text = str(value)


func _on_rear_diff_power_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.rear_diff.power_ratio = value
	$Drivetrain/VBoxContainer/RearDiffPowerRatio/Label2.text = str(value)


func _on_rear_diff_coast_ratio_changed(value: float) -> void:
	SessionManager.player_car_setup.drivetrain_params.rear_diff.coast_ratio = value
	$Drivetrain/VBoxContainer/RearDiffCoastRatio/Label2.text = str(value)

