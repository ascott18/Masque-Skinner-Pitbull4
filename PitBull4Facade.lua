
local LMB = LibStub("Masque", true) or (LibMasque and LibMasque("Button"))
if not LMB then return end

local f = CreateFrame("Frame")
local db, isSet
local pairs, wipe =
	  pairs, wipe
	  
local NULLFUNC = function() end
local SetTexCoord = f:CreateTexture().SetTexCoord
	  
local oldMakeAura = PitBull4.Controls.MakeAura
-- raw hook used because i need access to the return value of the orig. function
function PitBull4.Controls.MakeAura(frame)
    local button = oldMakeAura(frame)
	
    local groupname = PitBull4.Utils.GetLocalizedClassification(frame.classification)
    local group = LMB:Group("PitBull4", groupname)
	frame.__LMBgroup = group
	
    group:AddButton(button, {
            Icon = button.texture,
            Cooldown = button.cooldown,
            Border = button.border,
            Count = button.count_text
    })
	
	button.texture.SetTexCoord = NULLFUNC --PB4 attempts its own tex coord setting, but that causes skin settings to be overriden.
    
    return button
end


hooksecurefunc(PitBull4:GetModule("Aura"), "LayoutAuras", function(self, frame)
	local group = frame.__LMBgroup
	if not group then return end
	
	for button in pairs(group.Buttons) do
		button.texture.SetTexCoord = SetTexCoord
	end
	
	group:ReSkin()
	
	for button in pairs(group.Buttons) do
		button.texture.SetTexCoord = NULLFUNC  --PB4 attempts its own tex coord setting, but that causes skin settings to be overriden.
	end
end)

hooksecurefunc(PitBull4.Options, "OpenConfig", function()
	-- disable zoom_aura in the options menu so people might be able to figure out that it won't have any affect.
	local function approachTable(...)
		local t = ...
		if not t then return end
		for i=2, select("#", ...) do
			t = t[select(i, ...)]
			if not t then return end
		end
		return t
	end
	local options = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("PitBull4", "dialog", "PitBull4Facade-1.0")
	local zoom_aura = approachTable(options, "args", "layout_editor", "args", "Aura", "args", "display", "args", "zoom_aura")
	if zoom_aura then
		zoom_aura.disabled = true
	end
	approachTable = nil -- meet your new friend. his name is collectgarbage()
end)