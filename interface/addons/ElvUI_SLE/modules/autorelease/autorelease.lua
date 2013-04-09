--Credit to Repooc.
--Remade his auto release featule to module which allows profile setting of the function not the global one.
local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local AR = E:NewModule('AutoRelease', 'AceHook-3.0', 'AceEvent-3.0');

function AR:Releasing()
	local inInstance, instanceType = IsInInstance()
	if (inInstance and (instanceType == "pvp")) then
		if E.db.sle.pvpautorelease then 
			local soulstone = GetSpellInfo(20707)
				if ((E.myclass ~= "SHAMAN") and not (soulstone and UnitBuff("player", soulstone))) then
					RepopMe()
				end
		end
	end
	
	-- auto resurrection for world PvP area...when active
	if E.db.sle.pvpautorelease then 
		for index = 1, GetNumWorldPVPAreas() do
			local _, localizedName, isActive = GetWorldPVPAreaInfo(index)
			
			if (GetRealZoneText() == localizedName and isActive) then
				RepopMe()
			end
		end
	end
end

function AR:Initialize()
	self:RegisterEvent("PLAYER_DEAD", "Releasing");
end

E:RegisterModule(AR:GetName())