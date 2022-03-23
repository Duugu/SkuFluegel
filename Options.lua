local MODULE_NAME = "SkuFluegel"
local L = LibStub("AceLocale-3.0"):GetLocale("SkuFluegel", false)

SkuFluegel.options = {
	type = "group",
	args = {
		addonEnabled = {
			name = L["Enabled"],
			desc = "",
			type = "toggle",
			set = function(info, val)
				SkuFluegel.db.profile.addonEnabled = val
				SkuFluegel:RefreshVisuals()
			end,
			get = function(info)
				return SkuFluegel.db.profile.addonEnabled
			end
		},
		locked = {
			name = L["Gesperrt"],
			desc = "",
			type = "toggle",
			set = function(info, val)
				SkuFluegel.db.profile.locked = val
				SkuFluegel:RefreshVisuals()
			end,
			get = function(info)
				return SkuFluegel.db.profile.locked
			end
		},
		size = {
			name = L["Größe"] ,
			desc = "",
			type = "range",
			min = 5,
			max = 50,
			step = 1,
			set = function(info, val)
				SkuFluegel.db.profile.size = val
				SkuFluegel:RefreshVisuals()
			end,
			get = function(info)
				return SkuFluegel.db.profile.size
			end
		},
		followEnabled = {
			name = L["Folgen"],
			desc = "",
			type = "toggle",
			set = function(info, val)
				SkuFluegel.db.profile.followEnabled = val
				SkuFluegel:RefreshVisuals()
			end,
			get = function(info)
				return SkuFluegel.db.profile.followEnabled
			end
		},
		castEnabled = {
			name = L["Casten"] ,
			desc = "",
			type = "toggle",
			set = function(info, val)
				SkuFluegel.db.profile.castEnabled = val
				SkuFluegel:RefreshVisuals()
			end,
			get = function(info)
				return SkuFluegel.db.profile.castEnabled
			end
		},
		interactEnabled = {
			name = L["Interagieren"],
			desc = "",
			type = "toggle",
			set = function(info, val)
				SkuFluegel.db.profile.interactEnabled = val
				SkuFluegel:RefreshVisuals()
			end,
			get = function(info)
				return SkuFluegel.db.profile.interactEnabled
			end
		},
		mountedEnabled = {
			name = L["Reiten"] ,
			desc = "",
			type = "toggle",
			set = function(info, val)
				SkuFluegel.db.profile.mountedEnabled = val
				SkuFluegel:RefreshVisuals()
			end,
			get = function(info)
				return SkuFluegel.db.profile.mountedEnabled
			end
		},
		lootingEnabled = {
			name = L["Looten"] ,
			desc = "",
			type = "toggle",
			set = function(info, val)
				SkuFluegel.db.profile.lootingEnabled = val
				SkuFluegel:RefreshVisuals()
			end,
			get = function(info)
				return SkuFluegel.db.profile.lootingEnabled
			end
		},
	}
}

SkuFluegel.defaults = {
	profile = {
		addonEnabled = true,
		locked = false,
		size = 15,
		followEnabled = true,
		castEnabled = true,
		interactEnabled = true,
		mountedEnabled = true,
		lootingEnabled = true,
	}
 }
