SpeedLimiter = {}
SpeedLimiter.keys = {
	toggleLimiter = {
		id = 137,
		group = 2,
		controlName = "INPUT_MULTIPLAYER_INFO" -- Caps Lock
	},
	LimitRaise = {
		id = 61,
		group = 2,
		controlName = "INPUT_VEH_DUCK" -- LEFT SHIFT
	},
	LimitLower = {
		id = 36,
		group = 2,
		controlName = "INPUT_VEH_DUCK" -- Left CTRL
	},
	gearShiftUp = {
		id = 172,
		group = 2,
		controlName = "INPUT_CELLPHONE_UP" -- Arrow Up
	},
	gearShiftDown = {
		id = 173,
		group = 2,
		controlName = "INPUT_CELLPHONE_DOWN" --  Arrow Down
	}
}
SpeedLimiter.isMpH = false
SpeedLimiter.maxSpeed = 300 --KmH or MpH
SpeedLimiter.precision = 5 -- rounds to nearst 5 KmH or MpH