
local LBF = LibStub("LibButtonFacade", true)
local LMB = LibStub("Masque", true) or (LibMasque and LibMasque("Button"))
local Stub = (LMB or LBF)
if not Stub then return end

local f = CreateFrame("Frame")
local db, isSet
local pairs, wipe =
	  pairs, wipe
	  
local NULLFUNC = function() end
local SetTexCoord = f:CreateTexture().SetTexCoord
	  
local oldMakeAura = PitBull4.Controls.MakeAura
function PitBull4.Controls.MakeAura(frame)
    local control = oldMakeAura(frame)
	control.overlay = nil -- sorry! but this is causing issues
	
	if not LMB and not control.count_text:GetFont() then -- old buttonfacade requires that font be set in order to fall back on, otherwise there are errors
		control.count_text:SetFontObject(GameFontNormal)
	end
	
	control.texture.SetTexCoord = NULLFUNC
	
    local groupname = PitBull4.Utils.GetLocalizedClassification(frame.classification)
    local group = Stub:Group("PitBull4", groupname)
	frame.__LMBoLBFgroup = group
	
    group:AddButton(control, {
            Icon = control.texture,
            Cooldown = control.cooldown,
            Border = control.border,
            Count = control.count_text
    })
    
    if not LMB then
        local v = PitBull4Facade and PitBull4Facade[groupName]
        if v then
            group:Skin(v.S,v.G,v.B,v.C)
        end
    end
	
	control.texture.SetTexCoord = SetTexCoord
    
    return control
end


hooksecurefunc(PitBull4:GetModule("Aura"), "LayoutAuras", function(self, frame)
	local group = frame.__LMBoLBFgroup
	if not group then return end
	
	for button in pairs(group.Buttons) do
		button.texture.SetTexCoord = SetTexCoord
	end
	
	group:ReSkin()
	
	for button in pairs(group.Buttons) do
		button.texture.SetTexCoord = NULLFUNC
	end
end)

hooksecurefunc(PitBull4.Options, "OpenConfig", function()
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
	approachTable = nil -- meet your new friend: collectgarbage()
end)

if not LMB then
    local function OnEvent(self, event, addon)
        PitBull4Facade = PitBull4Facade or {}
        db = PitBull4Facade
        Stub:RegisterSkinCallback("PitBull4",
            function(_, SkinID, Gloss, Backdrop, Group, _, Colors)
                if not (db and SkinID) then return end
                if Group then
                    local gs = db[Group] or {}
                    db[Group] = gs
                    gs.S = SkinID
                    gs.G = Gloss
                    gs.B = Backdrop
                    gs.C = Colors
                end
            end
        )
        for k, v in pairs(db) do
            Stub:Group("PitBull4", k):Skin(v.S,v.G,v.B,v.C)
        end
        f:SetScript("OnEvent", nil)
    end
    
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", OnEvent)
end