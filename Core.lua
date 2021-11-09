---@diagnostic disable: undefined-field
local _G = _G

---------------------------------------------------------------------------------------------------------------------------------------
SkuFluegel = LibStub("AceAddon-3.0"):NewAddon("SkuFluegel", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SkuFluegel", false)
LibStub("AceComm-3.0"):Embed(SkuFluegel)

---------------------------------------------------------------------------------------------------------------------------------------
SkuFluegel.inCombat = false
SkuFluegel.NotificationWidgets = {
	[1] = "F", --following
	[2] = "C", --casting
	[3] = "I", --interacting
	[4] = "M", --mounted
	[5] = "L", --looting
}
SkuFluegel.TrackingTarget = {
	[1] = "Kein Ziel",
	[2] = "Kein Ziel",
	[3] = "Kein Ziel",
	[4] = "Kein Ziel",
}
SkuFluegel.moving = {
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false,
}
SkuFluegel.OldTrackingData = {
	[1] = {
		F = 0, --following
		C = 0, --casting
		I = 0, --interacting
		M = 0, --mounted
		L = 0, --looting
		Z = 0, --target in interaction range
		FN = "", --target in interaction range
	},
	[2] = {
		F = 0, --following
		C = 0, --casting
		I = 0, --interacting
		M = 0, --mounted
		L = 0, --looting
		Z = 0, --target in interaction range
		FN = "", --target in interaction range
	},
	[3] = {
		F = 0, --following
		C = 0, --casting
		I = 0, --interacting
		M = 0, --mounted
		L = 0, --looting
		Z = 0, --target in interaction range
		FN = "", --target in interaction range
	},
	[4] = {
		F = 0, --following
		C = 0, --casting
		I = 0, --interacting
		M = 0, --mounted
		L = 0, --looting
		Z = 0, --target in interaction range
		FN = "", --target in interaction range
	},
}

SkuFluegel.TrackingData = {
	[1] = {
		F = 0, --following
		C = 0, --casting
		I = 0, --interacting
		M = 0, --mounted
		L = 0, --looting
		Z = 0, --target in interaction range
		FN = "", --
	},
	[2] = {
		F = 0, --following
		C = 0, --casting
		I = 0, --interacting
		M = 0, --mounted
		L = 0, --looting
		Z = 0, --target in interaction range
		FN = "", --
	},
	[3] = {
		F = 0, --following
		C = 0, --casting
		I = 0, --interacting
		M = 0, --mounted
		L = 0, --looting
		Z = 0, --target in interaction range
		FN = "", --
	},
	[4] = {
		F = 0, --following
		C = 0, --casting
		I = 0, --interacting
		M = 0, --mounted
		L = 0, --looting
		Z = 0, --target in interaction range
		FN = "", --
	},
}

---------------------------------------------------------------------------------------------------------------------------------------
function SkuFluegel:OnInitialize()
	--print("SkuFluegel OnInitialize")
	SkuFluegel.AceConfig = LibStub("AceConfig-3.0")
	SkuFluegel.AceConfig:RegisterOptionsTable("SkuFluegel", SkuFluegel.options, {"taop"})

	SkuFluegel.AceConfigDialog = LibStub("AceConfigDialog-3.0")
	SkuFluegel.AceConfigDialog:AddToBlizOptions("SkuFluegel")

	SkuFluegel.db = LibStub("AceDB-3.0"):New("SkuFluegelDB", SkuFluegel.defaults) -- TODO: fix default values for subgroups

	SkuFluegel.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(SkuFluegel.db)

	SkuFluegel.db.RegisterCallback(self, "OnProfileChanged", SkuFluegel.RefreshVisuals)
	SkuFluegel.db.RegisterCallback(self, "OnProfileCopied", SkuFluegel.RefreshVisuals)
	SkuFluegel.db.RegisterCallback(self, "OnProfileReset", function()
		for q = 1, 4 do
			_G["SkuFluegelVisual"..q]:ClearAllPoints()
			_G["SkuFluegelVisual"..q]:SetPoint("Center")
		end
		SkuFluegel:RefreshVisuals()
	end)

	SkuFluegel:RegisterEvent("PLAYER_ENTERING_WORLD")
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuFluegel:OnEnable()
	local ttime = 0

	local f = _G["SkuFluegelControl"] or CreateFrame("Frame", "SkuFluegelControl", UIParent)
	f:SetScript("OnUpdate", function(self, time)
		if SkuFluegel.db.profile.addonEnabled == true then
 			ttime = ttime + time
			if ttime > 5 then
				for q = 1, 4 do
					if SkuFluegel.TrackingTarget[q] ~= "Kein Ziel" then
						if UnitInRaid("player") == true then
							SkuFluegel:SendCommMessage("Sku", "ping-ping", "RAID", nil, "ALERT")
						elseif UnitInParty("player") == true then
							SkuFluegel:SendCommMessage("Sku", "ping-ping", "PARTY", nil, "ALERT")
						else
							SkuFluegel:SendCommMessage("Sku", "ping-ping", "WHISPER", SkuFluegel.TrackingTarget[q], "ALERT")
						end
					end
				end
				ttime = 0
			end
		end
	end)

	local tFrame = CreateFrame("Button", "SkuFluegelMain", UIParent)
	tFrame:SetSize(80, 22)
	tFrame:SetText("SkuFluegelMain")
	tFrame:SetPoint("LEFT", UIParent, "RIGHT", 1500, 0)
	tFrame:SetPoint("CENTER")
	tFrame:SetScript("OnClick", function(self, a, b)
		for q = 1, 4 do
			if a == "CTRL-SHIFT-"..q then
				--print(self, a, b)
				local tname = UnitName("target")
				local pname = UnitName("player")
				if tname and tname ~= pname then
					SkuFluegel.TrackingTarget[q] = tname
					if UnitInRaid("player") == true then
						SkuFluegel:SendCommMessage("Sku", "ping-ping", "RAID", nil, "ALERT")
					elseif UnitInParty("player") == true then
						SkuFluegel:SendCommMessage("Sku", "ping-ping", "PARTY", nil, "ALERT")
					else
						SkuFluegel:SendCommMessage("Sku", "ping-ping", "WHISPER", SkuFluegel.TrackingTarget[q], "ALERT")
					end
				else
					SkuFluegel.TrackingTarget[q] = "Kein Ziel"
				end
				SkuFluegel.TrackingData[q] = {
					F = 0,
					C = 0,
					I = 0,
					M = 0,
					L = 0,
					Z = 0,
					FN = "",
				}

				SkuFluegel:RefreshVisuals()
			end
		end
	end)
	SetOverrideBindingClick(tFrame, true, "CTRL-SHIFT-1", tFrame:GetName(), "CTRL-SHIFT-1")
	SetOverrideBindingClick(tFrame, true, "CTRL-SHIFT-2", tFrame:GetName(), "CTRL-SHIFT-2")
	SetOverrideBindingClick(tFrame, true, "CTRL-SHIFT-3", tFrame:GetName(), "CTRL-SHIFT-3")
	SetOverrideBindingClick(tFrame, true, "CTRL-SHIFT-4", tFrame:GetName(), "CTRL-SHIFT-4")

	local tSize = 15
	for q = 1, 4 do

		local f = CreateFrame("Frame", "SkuFluegelVisual"..q, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
		f:SetScale(1)
		f:SetFrameStrata("HIGH")
		f:SetWidth(tSize * 6)
		f:SetHeight(tSize)
		f:SetScript("OnDragStart", function()
			if SkuFluegel.db.profile.locked == false then
				SkuFluegel.moving[q] = true
				_G["SkuFluegelVisual"..q]:StartMoving()
			end
		end)
		f:SetScript("OnDragStop", function()
			SkuFluegel.moving[q] = false
			_G["SkuFluegelVisual"..q]:StopMovingOrSizing()
			local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(1)
			SkuFluegel.db.profile.position[q] = {
				point = point, 
				relativeTo = "UIParent", 
				relativePoint = relativePoint, 
				xOfs = xOfs, 
				yOfs = yOfs,
			}
		end)

		f:SetPoint("CENTER")
---@diagnostic disable-next-line: undefined-field

		f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "", tile = false, tileSize = 0, edgeSize = 32, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		f:SetMovable(true)
		f:EnableMouse(true)
		f:SetClampedToScreen(true)
		f:RegisterForDrag("LeftButton")
		f:SetUserPlaced(true)
		local fs = f:CreateFontString("SkuFluegelVisual"..q.."FSTarget")
		fs:SetFont("Interface\\AddOns\\SkuFluegel\\assets\\09803_CourierNewFett.ttf", tSize / 2, "OUTLINE")
		fs:SetTextColor(1, 1, 1, 1)
		fs:SetJustifyH("LEFT")
		fs:SetJustifyV("BOTTOM")
		fs:SetPoint("BOTTOMLEFT", f, "TOPLEFT")
		fs:SetText("Kein Ziel")
		local fs = f:CreateFontString("SkuFluegelVisual"..q.."FSFollowTarget")
		fs:SetFont("Interface\\AddOns\\SkuFluegel\\assets\\09803_CourierNewFett.ttf", tSize / 2, "OUTLINE")
		fs:SetTextColor(1, 1, 1, 1)
		fs:SetJustifyH("LEFT")
		fs:SetJustifyV("BOTTOM")
		fs:SetPoint("TOPLEFT", f, "BOTTOMLEFT")
		fs:SetText("Kein Ziel")
		for x = 1, #SkuFluegel.NotificationWidgets do
			local fs = f:CreateFontString("SkuFluegelVisual"..q.."FS"..SkuFluegel.NotificationWidgets[x])
			fs:SetFont("Interface\\AddOns\\SkuFluegel\\assets\\09803_CourierNewFett.ttf", tSize, "OUTLINE")
			fs:SetTextColor(1, 1, 0, 1)
			fs:SetJustifyH("LEFT")
			fs:SetJustifyV("TOP")
			fs:SetPoint("TOPLEFT", f, "TOPLEFT", (x - 1) * tSize, 0)
			fs:SetText(SkuFluegel.NotificationWidgets[x])
		end
		f:Hide()
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuFluegel:OnDisable()

end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuFluegel:RefreshVisuals()
	local tSize = SkuFluegel.db.profile.size or 15
	for q = 1, 4 do
		local f = _G["SkuFluegelVisual"..q]
		if f then




			SkuFluegel.db.profile.position = SkuFluegel.db.profile.position or {}
			if not SkuFluegel.db.profile.position[q] then
				local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(1)
				SkuFluegel.db.profile.position[q] = {
					point = point,
					relativeTo = "UIParent",
					relativePoint = relativePoint,
					xOfs = xOfs,
					yOfs = yOfs,
				}
			end



			if SkuFluegel.db.profile.position[q].relativeTo then
				if SkuFluegel.moving[q] ~= true then
					f:SetPoint(SkuFluegel.db.profile.position[q].point, SkuFluegel.db.profile.position[q].relativeTo, SkuFluegel.db.profile.position[q].relativePoint, SkuFluegel.db.profile.position[q].xOfs, SkuFluegel.db.profile.position[q].yOfs)
				end
				f:SetWidth(tSize * 6)
				f:SetHeight(tSize)
				if SkuFluegel.db.profile.locked == false then
					f:EnableMouse(true)
				else
					f:EnableMouse(false)
				end

				_G["SkuFluegelVisual"..q.."FSTarget"]:SetFont("Interface\\AddOns\\SkuFluegel\\assets\\09803_CourierNewFett.ttf", tSize / 2, "OUTLINE")
				for x = 1, #SkuFluegel.NotificationWidgets do
					local fs = _G["SkuFluegelVisual"..q.."FS"..SkuFluegel.NotificationWidgets[x]]
					fs:Hide()
				end

				local tMod = 0
				for x = 1, #SkuFluegel.NotificationWidgets do
					if (SkuFluegel.NotificationWidgets[x] == "F" and SkuFluegel.db.profile.followEnabled == true) or
					(SkuFluegel.NotificationWidgets[x] == "C" and SkuFluegel.db.profile.castEnabled == true) or
					(SkuFluegel.NotificationWidgets[x] == "I" and SkuFluegel.db.profile.interactEnabled == true) or
					(SkuFluegel.NotificationWidgets[x] == "M" and SkuFluegel.db.profile.mountedEnabled == true) or
					(SkuFluegel.NotificationWidgets[x] == "L" and SkuFluegel.db.profile.lootingEnabled == true)
					then
						local fs = _G["SkuFluegelVisual"..q.."FS"..SkuFluegel.NotificationWidgets[x]]
						fs:SetFont("Interface\\AddOns\\SkuFluegel\\assets\\09803_CourierNewFett.ttf", tSize, "OUTLINE")

						if SkuFluegel.TrackingTarget[q]~= "Kein Ziel" then
							if SkuFluegel.TrackingData[q][SkuFluegel.NotificationWidgets[x]] == 0 then
								fs:SetTextColor(0.5, 0.5, 0.5, 1)
							elseif SkuFluegel.TrackingData[q][SkuFluegel.NotificationWidgets[x]] == 1 then
								fs:SetTextColor(0, 1, 0, 1)
							elseif SkuFluegel.TrackingData[q][SkuFluegel.NotificationWidgets[x]] == 2 then
								fs:SetTextColor(1, 1, 0, 1)
							elseif SkuFluegel.TrackingData[q][SkuFluegel.NotificationWidgets[x]] == 3 then
								fs:SetTextColor(1, 0.659, 0, 1)
							elseif SkuFluegel.TrackingData[q][SkuFluegel.NotificationWidgets[x]] == 4 then
								fs:SetTextColor(1, 0, 0, 1)
							elseif SkuFluegel.TrackingData[q][SkuFluegel.NotificationWidgets[x]] == 5 then
								fs:SetTextColor(1, 1, 1, 1)
							end
						else
							fs:SetTextColor(0.5, 0.5, 0.5, 1)
						end
						fs:SetPoint("TOPLEFT", f, "TOPLEFT", tMod * tSize, 0)
						fs:Show()
						tMod = tMod + 1
					end
				end
				if tMod == 0 then
					tMod = 1
				end
				f:SetWidth(tSize * tMod)

				_G["SkuFluegelVisual"..q.."FSTarget"]:SetText(q.." "..SkuFluegel.TrackingTarget[q])

				_G["SkuFluegelVisual"..q.."FSFollowTarget"]:SetText(SkuFluegel.TrackingData[q]["FN"])

				if SkuFluegel.TrackingTarget[q] == "Kein Ziel" then
					f:Hide()
				else
					f:Show()
				end
			end

		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------
local oSkuFlDCFAddMessage = nil--DEFAULT_CHAT_FRAME.AddMessage
function nSkuFlDCFAddMessage(...)
	local a, b, c, d, e, f = ...
	local tResult 
	if b then
		tResult = string.find(b, "Momentan ist kein Spieler mit dem Namen")
	end
	if not tResult then
		oSkuFlDCFAddMessage(...)
	else
		local _, tTargetName, _ = string.split("'", b)
		if SkuOptions then
			if SkuOptions.TrackingTargets then
				for x = 1, #SkuOptions.TrackingTargets do
					if SkuOptions.TrackingTargets[x] then
						if SkuOptions.TrackingTargets[x] == tTargetName then
							table.remove(SkuOptions.TrackingTargets, x)
						end
					end
				end
			end
		end
		if SkuFluegel then
			if SkuFluegel.TrackingTarget then
				for q = 1, 4 do
					if tTargetName == SkuFluegel.TrackingTarget[q] then
						SkuFluegel.TrackingTarget[q] = "Kein Ziel"
						SkuFluegel:RefreshVisuals()
					end
				end
			end
		end



	end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuFluegel:PLAYER_ENTERING_WORLD(...)

	SkuFluegel:RefreshVisuals()
	SkuFluegel:RegisterComm("Sku")

	if not oSkuFlDCFAddMessage then
		oSkuFlDCFAddMessage = DEFAULT_CHAT_FRAME.AddMessage
		DEFAULT_CHAT_FRAME.AddMessage = nSkuFlDCFAddMessage
	end
	C_Timer.After(1, SkuFluegel.RefreshVisuals)

end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuFluegel:OnCommReceived(aPrefix, aData, aChannel, aSender, ...)
	--print("OnCommReceived", aPrefix, aData, aChannel, aSender, ...)
	if aPrefix == "Sku" and aData then
		SkuFluegel:ProcessComm(aSender, string.split("-", aData))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------
function SkuFluegel:ProcessComm(aSender, aIndex, aValue)
	--print("SkuFluegel:ProcessComm", aSender, aIndex, aValue)
	for q = 1, 4 do
		if aSender == SkuFluegel.TrackingTarget[q] then

			if SkuFluegel.TrackingData[q][aIndex] then
				SkuFluegel.TrackingData[q][aIndex] = tonumber(aValue) or aValue

				if SkuFluegel.TrackingData[q][aIndex] ~= SkuFluegel.OldTrackingData[q][aIndex] then
					SkuFluegel.OldTrackingData[q][aIndex] = SkuFluegel.TrackingData[q][aIndex]
					if aIndex == "F" then
						if SkuFluegel.TrackingData[q][aIndex] == 1 then
							PlaySoundFile("Interface\\AddOns\\SkuFluegel\\assets\\sound-on3_1.mp3", "Master")
						elseif SkuFluegel.TrackingData[q][aIndex] == 4 then
							PlaySoundFile("Interface\\AddOns\\SkuFluegel\\assets\\sound-off2.mp3", "Master")
						end
					end

					if aIndex == "FN" then
						
					end

					if aIndex == "I" then
						if SkuFluegel.TrackingData[q][aIndex] == 1 then
							PlaySoundFile("Interface\\AddOns\\SkuFluegel\\assets\\sound-success2.mp3", "Master")
						end
					end
				end
			end

			SkuFluegel:RefreshVisuals()
		end
	end
end