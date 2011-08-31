
local LBF = LibStub("LibButtonFacade", true)
local LMB = LibStub("Masque", true) or (LibMasque and LibMasque("Button"))
local Stub = (LBF or LMB)
if not Stub then return end

local f = CreateFrame("Frame")
local db, isSet
local groups = {}
local pairs, wipe =
	  pairs, wipe

	  
local oldMakeAura = PitBull4.Controls.MakeAura
function PitBull4.Controls.MakeAura(frame)
    local control = oldMakeAura(frame)
	
	if not LMB and not control.count_text:GetFont() then -- old buttonfacade requires that font be set in order to fall back on, otherwise there are errors
		control.count_text:SetFontObject(GameFontNormal)
	end
	
    local groupname = PitBull4.Utils.GetLocalizedClassification(frame.classification)
    local group = Stub:Group("PitBull4", groupname)
	
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
	
	groups[group] = 1
    
    return control
end

hooksecurefunc(PitBull4:GetModule("Aura"), "LayoutAuras", function()
	for group in pairs(groups) do
		group:ReSkin()
	end
	wipe(groups)
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