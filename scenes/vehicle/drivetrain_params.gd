class_name DriveTrainParameters
extends Resource


enum DRIVE_TYPE{
	FWD,
	RWD,
	AWD,
}

@export var drivetype := DRIVE_TYPE.RWD
@export var gear_ratios := [ 3.1, 2.61, 2.1, 1.72, 1.2, 0.8 ] 
@export var final_drive := 3.7
@export var reverse_ratio := 3.9
@export var gear_inertia := 0.20
@export var automatic := false

@export var drivetrain_efficiency := 0.9

@export var rear_diff := DiffParameters.new()
@export var front_diff := DiffParameters.new()
@export var center_diff := DiffParameters.new()


@export var center_split_fr := 0.4 # AWD torque split front / rear, unused if central diff is not limited slip
