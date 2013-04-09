local VUHDO_CUSTOM_DEBUFF_CONFIG = { };
local VUHDO_UNIT_CUSTOM_DEBUFFS = { };
local VUHDO_LAST_UNIT_DEBUFFS = { };
local VUHDO_PLAYER_ABILITIES = { };



local VUHDO_IGNORE_DEBUFFS_BY_CLASS = { };
local VUHDO_IGNORE_DEBUFF_NAMES = { };



--
local VUHDO_DEBUFF_TYPES = {
	["Magic"] = VUHDO_DEBUFF_TYPE_MAGIC,
	["Disease"] = VUHDO_DEBUFF_TYPE_DISEASE,
	["Poison"] = VUHDO_DEBUFF_TYPE_POISON,
	["Curse"] = VUHDO_DEBUFF_TYPE_CURSE
};




VUHDO_DEBUFF_BLACKLIST = {
	[GetSpellInfo(69127)] = true, -- MOP okay Chill of the Throne (st�ndiger debuff)
	[GetSpellInfo(57724)] = true, -- MOP okay Sated
	[GetSpellInfo(71328)] = true  -- MOP okay Dungeon Cooldown
}




local VUHDO_INIT_UNIT_DEBUFF_SCHOOLS = {
	[VUHDO_DEBUFF_TYPE_POISON] = { },
	[VUHDO_DEBUFF_TYPE_DISEASE] = { },
	[VUHDO_DEBUFF_TYPE_MAGIC] = { },
	[VUHDO_DEBUFF_TYPE_CURSE] = { },
};


-- BURST CACHE ---------------------------------------------------

local VUHDO_CONFIG;
local VUHDO_RAID;
local VUHDO_PANEL_SETUP;
local VUHDO_DEBUFF_COLORS = { };

local VUHDO_shouldScanUnit;
local VUHDO_DEBUFF_BLACKLIST = { };

local UnitDebuff = UnitDebuff;
local UnitBuff = UnitBuff;
local table = table;
local GetTime = GetTime;
local PlaySoundFile = PlaySoundFile;
local InCombatLockdown = InCombatLockdown;
local twipe = table.wipe;
local pairs = pairs;
local _;
local tostring = tostring;

local sIsNotRemovableOnly;
local sIsNotRemoveableOnlyIcons;
local sIsUseDebuffIcon;
local sIsUseDebuffIconBossOnly;
local sIsMiBuColorsInFight;
local sStdDebuffSound;
local sAllDebuffSettings;
local sEmpty = { };

function VUHDO_debuffsInitBurst()
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_DEBUFF_BLACKLIST = _G["VUHDO_DEBUFF_BLACKLIST"];

	VUHDO_shouldScanUnit = _G["VUHDO_shouldScanUnit"];

	sIsNotRemovableOnly = not VUHDO_CONFIG["DETECT_DEBUFFS_REMOVABLE_ONLY"];
	sIsNotRemoveableOnlyIcons = not VUHDO_CONFIG["DETECT_DEBUFFS_REMOVABLE_ONLY_ICONS"];
	sIsUseDebuffIcon = VUHDO_PANEL_SETUP["BAR_COLORS"]["useDebuffIcon"];
	sIsUseDebuffIconBossOnly = VUHDO_PANEL_SETUP["BAR_COLORS"]["useDebuffIconBossOnly"];
	sIsMiBuColorsInFight = VUHDO_BUFF_SETTINGS["CONFIG"]["BAR_COLORS_IN_FIGHT"];
	sStdDebuffSound = VUHDO_CONFIG["SOUND_DEBUFF"];
	sAllDebuffSettings = VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"];
	VUHDO_DEBUFF_COLORS = {
		[1] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF1"],
		[2] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF2"],
		[3] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF3"],
		[4] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF4"],
		[6] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF6"],
	};
end

----------------------------------------------------



--
local tIdx = 0;
local tCopies = { };
local tIsRevolvInit = true;
local function VUHDO_copyColorRevolving()
	if (tIdx > 39) then
		tIdx = 1;
		tIsRevolvInit = false;
	else
		tIdx = tIdx + 1;
	end

	if (tIsRevolvInit) then
		tCopies[tIdx] = { };
	else
		twipe(tCopies[tIdx]);
	end

	return tCopies[tIdx];
end



--
local function VUHDO_formColor(aColor)
	if (aColor["useText"]) then
		aColor["TR"], aColor["TG"], aColor["TB"] = aColor["TR"] or 0, aColor["TG"] or 0, aColor["TB"] or 0;
	end
	if (aColor["useBackground"]) then
		aColor["R"], aColor["G"], aColor["B"] = aColor["R"] or 0, aColor["G"] or 0, aColor["B"] or 0;
	end

	aColor["TO"], aColor["O"] = aColor["TO"] or 1, aColor["O"] or 1;
	return aColor;
end



--
local function VUHDO_copyColorTo(aSource, aDest)
	aDest["R"], aDest["G"], aDest["B"] = aSource["R"], aSource["G"], aSource["B"];
	aDest["TR"], aDest["TG"], aDest["TB"] = aSource["TR"], aSource["TG"], aSource["TB"];
	aDest["O"], aDest["TO"] = aSource["O"], aSource["TO"];
	aDest["useText"], aDest["useBackground"], aDest["useOpacity"] = aSource["useText"], aSource["useBackground"], aSource["useOpacity"];
	return aDest;
end



--
local tSourceColor;
local tDebuffSettings;
local tDebuff;
local function _VUHDO_getDebuffColor(anInfo, aNewColor)
	tDebuff = anInfo["debuff"];

	if (anInfo["charmed"]) then
		return VUHDO_copyColorTo(VUHDO_PANEL_SETUP["BAR_COLORS"]["CHARMED"], aNewColor);
	elseif (anInfo["mibucateg"] == nil and (tDebuff or 0) == 0) then -- VUHDO_DEBUFF_TYPE_NONE
		return aNewColor;
	end

	tDebuffSettings = sAllDebuffSettings[anInfo["debuffName"]];

	if ((tDebuff or 6) ~= 6 and VUHDO_DEBUFF_COLORS[tDebuff] ~= nil) then -- VUHDO_DEBUFF_TYPE_CUSTOM
		return VUHDO_copyColorTo(VUHDO_DEBUFF_COLORS[tDebuff], aNewColor);
	elseif (tDebuff == 6 and tDebuffSettings ~= nil -- VUHDO_DEBUFF_TYPE_CUSTOM
		and tDebuffSettings["isColor"] and tDebuffSettings["color"] ~= nil) then
		tSourceColor = tDebuffSettings["color"];

		if (VUHDO_DEBUFF_COLORS[6]["useBackground"]) then
			aNewColor["useBackground"] = true;
			aNewColor["R"], aNewColor["G"], aNewColor["B"], aNewColor["O"] = tSourceColor["R"], tSourceColor["G"], tSourceColor["B"], tSourceColor["O"];
		end

		if (VUHDO_DEBUFF_COLORS[6]["useText"]) then
			aNewColor["useText"] = true;
			aNewColor["TR"], aNewColor["TG"], aNewColor["TB"], aNewColor["TO"] = tSourceColor["TR"], tSourceColor["TG"], tSourceColor["TB"], tSourceColor["TO"];
		end

		return aNewColor;
	end

	if (anInfo["mibucateg"] == nil or VUHDO_BUFF_SETTINGS[anInfo["mibucateg"]] == nil) then
		return aNewColor;
	end

	tSourceColor = VUHDO_BUFF_SETTINGS[anInfo["mibucateg"]]["missingColor"];
	if (VUHDO_BUFF_SETTINGS["CONFIG"]["BAR_COLORS_TEXT"]) then
		aNewColor["useText"] = true;
		aNewColor["TR"], aNewColor["TG"], aNewColor["TB"], aNewColor["TO"] = tSourceColor["TR"], tSourceColor["TG"], tSourceColor["TB"], tSourceColor["TO"];
	end

	if (VUHDO_BUFF_SETTINGS["CONFIG"]["BAR_COLORS_BACKGROUND"]) then
		aNewColor["useBackground"] = true;
		aNewColor["R"], aNewColor["G"], aNewColor["B"], aNewColor["O"] = tSourceColor["R"], tSourceColor["G"], tSourceColor["B"], tSourceColor["O"];
	end

	return aNewColor;
end



--
local tColor;
function VUHDO_getDebuffColor(anInfo)
	return VUHDO_formColor(_VUHDO_getDebuffColor(anInfo, VUHDO_copyColorRevolving()));
end



--
--[[local function VUHDO_isDebuffRelevant(aDebuffName, aClass)
	return not VUHDO_IGNORE_DEBUFF_NAMES[aDebuffName]
		and not (VUHDO_IGNORE_DEBUFFS_BY_CLASS[aClass or ""] or sEmpty)[aDebuffName];
end]]



--
local tNextSoundTime = 0;
local function VUHDO_playDebuffSound(aSound)
	if ((aSound or "") == "" or GetTime() < tNextSoundTime) then
		return;
	end

	PlaySoundFile(aSound);
	tNextSoundTime = GetTime() + 2;
end



--
local tIconIndex = 0;
local tIconArray;
local tIconArrayDispenser = { };
local function VUHDO_getOrCreateIconArray(anIcon, aExpiry, aStacks, aDuration, anIsBuff)
	tIconIndex = tIconIndex + 1;
	if (#tIconArrayDispenser < tIconIndex) then
		tIconArray = { anIcon, aExpiry, aStacks, aDuration, anIsBuff };
		tIconArrayDispenser[tIconIndex] = tIconArray;
	else
		tIconArray = tIconArrayDispenser[tIconIndex];
		tIconArray[1], tIconArray[2], tIconArray[3], tIconArray[4], tIconArray[5]
			= anIcon, aExpiry, aStacks, aDuration, anIsBuff;
	end

	return tIconArray;
end



--
function VUHDO_resetDebuffIconDispenser()
	twipe(tIconArrayDispenser);
	tIconIndex = 0;
end



--
local VUHDO_UNIT_DEBUFF_INFOS = { };
local sCurChosenType;
local sCurChosenName;
local sCurSoundName;
local sCurIsStandard;
local sCurIcons = { };

local tUnitDebuffInfo;
local function VUHDO_initDebuffInfos(aUnit)
	if (VUHDO_UNIT_DEBUFF_INFOS[aUnit] == nil) then
		VUHDO_UNIT_DEBUFF_INFOS[aUnit] = {
			["CHOSEN"] = { [1] = nil, [2] = 0 },
			[VUHDO_DEBUFF_TYPE_POISON] = { },
			[VUHDO_DEBUFF_TYPE_DISEASE] = { },
			[VUHDO_DEBUFF_TYPE_MAGIC] = { },
			[VUHDO_DEBUFF_TYPE_CURSE] = { },
		}
	end

	tUnitDebuffInfo = VUHDO_UNIT_DEBUFF_INFOS[aUnit];
	tUnitDebuffInfo[VUHDO_DEBUFF_TYPE_POISON][2] = nil;
	tUnitDebuffInfo[VUHDO_DEBUFF_TYPE_DISEASE][2] = nil;
	tUnitDebuffInfo[VUHDO_DEBUFF_TYPE_MAGIC][2] = nil;
	tUnitDebuffInfo[VUHDO_DEBUFF_TYPE_CURSE][2] = nil;

	if (VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit] == nil) then
		VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit] = { };
	end

	sCurChosenType = VUHDO_DEBUFF_TYPE_NONE;
	sCurChosenName = "";
	sCurSoundName = nil;
	sCurIsStandard = false;
	tIconIndex = 0;
	twipe(sCurIcons);

	return tUnitDebuffInfo;
end




--
local tInfo;
local tSound;
local tRemaining;
local tAbility;
local tSchool;
local tName, tIcon, tStacks, tTypeString, tDuration, tExpiry, tSpellId, tIsBossDebuff;
local tDebuffConfig;
local tIsRelevant;
local tNow;
local tUnitDebuffInfo;
function VUHDO_determineDebuff(aUnit)
	tInfo = (VUHDO_RAID or sEmpty)[aUnit];

	if (tInfo == nil) then
		return VUHDO_DEBUFF_TYPE_NONE, "";
	elseif (VUHDO_CONFIG_SHOW_RAID) then
		return tInfo["debuff"], tInfo["debuffName"];
	end

	tUnitDebuffInfo = VUHDO_initDebuffInfos(aUnit);

	if (VUHDO_shouldScanUnit(aUnit)) then
		tNow = GetTime();

		for tCnt = 1, 255 do
			tName, _, tIcon, tStacks, tTypeString, tDuration, tExpiry, _, _, _, tSpellId, _, tIsBossDebuff = UnitDebuff(aUnit, tCnt, false);
			if (tIcon == nil) then
				break;
			end

			tStacks = tStacks or 0;
			if ((tExpiry or 0) == 0) then
				tExpiry = (sCurIcons[tName] or sEmpty)[2] or tNow;
			end

			-- Custom Debuff?
			tDebuffConfig = VUHDO_CUSTOM_DEBUFF_CONFIG[tName] or VUHDO_CUSTOM_DEBUFF_CONFIG[tostring(tSpellId or -1)] or sEmpty;
			if (tDebuffConfig[1]) then -- Farbe?
				sCurChosenType, sCurChosenName, sCurSoundName = VUHDO_DEBUFF_TYPE_CUSTOM, tName, tName;
			end

			if (sCurIcons[tName] ~= nil) then
				tStacks = tStacks + sCurIcons[tName][3];
			end

			if (tDebuffConfig[2]) then -- Icon?
				sCurIcons[tName] = VUHDO_getOrCreateIconArray(tIcon, tExpiry, tStacks, tDuration, false);
				sCurSoundName = tName;
			end

			tType = VUHDO_DEBUFF_TYPES[tTypeString];
			tAbility = VUHDO_PLAYER_ABILITIES[tType];
			--tIsRelevant = VUHDO_isDebuffRelevant(tName, tInfo["class"]);
			tIsRelevant = not VUHDO_IGNORE_DEBUFF_NAMES[tName]
				and not (VUHDO_IGNORE_DEBUFFS_BY_CLASS[tInfo["class"] or ""] or sEmpty)[tName];

			if (tType ~= nil and tIsRelevant) then
				tSchool = tUnitDebuffInfo[tType];
				tRemaining = floor(tExpiry - tNow);
				if ((tSchool[2] or 0) < tRemaining) then
					tSchool[1], tSchool[2], tSchool[3], tSchool[4] = tIcon, tRemaining, tStacks, tDuration;
				end
			end

			if (sCurChosenType ~= VUHDO_DEBUFF_TYPE_CUSTOM
				and not VUHDO_DEBUFF_BLACKLIST[tName]
				and tIsRelevant) then

				if (sIsUseDebuffIcon and (tIsBossDebuff or not sIsUseDebuffIconBossOnly)
					and (sIsNotRemoveableOnlyIcons or tAbility ~= nil)) then

					sCurIcons[tName] = VUHDO_getOrCreateIconArray(tIcon, tExpiry, tStacks, tDuration, false);
					sCurIsStandard = true;
				end

				-- Entweder F�higkeit vorhanden ODER noch keiner gew�hlt UND auch nicht entfernbare
				if (tType ~= nil and (tAbility ~= nil or (sCurChosenType == VUHDO_DEBUFF_TYPE_NONE and sIsNotRemovableOnly))) then
					sCurChosenType = tType;
					tUnitDebuffInfo["CHOSEN"][1], tUnitDebuffInfo["CHOSEN"][2] = tIcon, tStacks;
				end
			end
		end

		for tCnt = 1, 255 do
			tName, _, tIcon, tStacks, _, tDuration, tExpiry, _, _, _, tSpellId = UnitBuff(aUnit, tCnt);
			if (tIcon == nil) then
				break;
			end

			tDebuffConfig = VUHDO_CUSTOM_DEBUFF_CONFIG[tName] or VUHDO_CUSTOM_DEBUFF_CONFIG[tostring(tSpellId or -1)] or sEmpty;

			if (tDebuffConfig[1]) then -- Set color
				sCurChosenType, sCurChosenName, sCurSoundName = VUHDO_DEBUFF_TYPE_CUSTOM, tName, tName;
			end

			if (tDebuffConfig[2]) then -- Set icon
				sCurIcons[tName] = VUHDO_getOrCreateIconArray(tIcon, tExpiry, tStacks or 0, tDuration, true);
				sCurSoundName = tName;
			end
		end

		-- Gained new custom debuff?
		for tName, tDebuffInfo in pairs(sCurIcons) do

			if (VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName] == nil) then
				VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName] = { tDebuffInfo[2], tDebuffInfo[3] };
				VUHDO_addDebuffIcon(aUnit, tDebuffInfo[1], tName, tDebuffInfo[2], tDebuffInfo[3], tDebuffInfo[4], tDebuffInfo[5]);

				if (not VUHDO_IS_CONFIG and VUHDO_MAY_DEBUFF_ANIM and tSoundDebuff ~= nil) then
					if (sAllDebuffSettings[tSoundDebuff] ~= nil) then -- Spezieller custom debuff sound?
						VUHDO_playDebuffSound(sAllDebuffSettings[tSoundDebuff]["SOUND"]);
					elseif (VUHDO_CONFIG["CUSTOM_DEBUFF"]["SOUND"] ~= nil) then -- Allgemeiner custom debuff sound?
						VUHDO_playDebuffSound(VUHDO_CONFIG["CUSTOM_DEBUFF"]["SOUND"]);
					end
				end

				VUHDO_updateBouquetsForEvent(aUnit, 29); -- VUHDO_UPDATE_CUSTOM_DEBUFF
			-- update number of stacks?
			elseif(VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName][1] ~= tDebuffInfo[2]
				or VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName][2] ~= tDebuffInfo[3]) then

				twipe(VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName]);
				VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName] = { tDebuffInfo[2], tDebuffInfo[3] };
				VUHDO_updateDebuffIcon(aUnit, tDebuffInfo[1], tName, tDebuffInfo[2], tDebuffInfo[3], tDebuffInfo[4]);
				VUHDO_updateBouquetsForEvent(aUnit, 29); -- VUHDO_UPDATE_CUSTOM_DEBUFF
			end
		end

		-- Play standard debuff sound?
		if (sStdDebuffSound ~= nil
			and (sCurChosenType ~= VUHDO_DEBUFF_TYPE_NONE or sCurIsStandard)
			and sCurChosenType ~= VUHDO_DEBUFF_TYPE_CUSTOM
			and sCurChosenType ~= VUHDO_LAST_UNIT_DEBUFFS[aUnit]
			and tInfo["range"]) then

				VUHDO_playDebuffSound(sStdDebuffSound);
				VUHDO_LAST_UNIT_DEBUFFS[aUnit] = sCurChosenType;
		end
	end -- shouldScanUnit

	-- Lost old custom debuff?
	for tName, _ in pairs(VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit]) do
		if (sCurIcons[tName] == nil) then
			twipe(VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName]);
			VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName] = nil;
			VUHDO_removeDebuffIcon(aUnit, tName);
			VUHDO_updateBouquetsForEvent(aUnit, 29); -- VUHDO_UPDATE_CUSTOM_DEBUFF
		end
	end

	if (sCurChosenType == VUHDO_DEBUFF_TYPE_NONE and tInfo["missbuff"] ~= nil and (sIsMiBuColorsInFight or not InCombatLockdown())) then
		sCurChosenType = VUHDO_DEBUFF_TYPE_MISSING_BUFF;
	end

	return sCurChosenType, sCurChosenName;
end

local VUHDO_determineDebuff = VUHDO_determineDebuff;



--
function VUHDO_updateAllCustomDebuffs(anIsEnableAnim)
	twipe(VUHDO_UNIT_CUSTOM_DEBUFFS);
	VUHDO_MAY_DEBUFF_ANIM = false;
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		VUHDO_removeAllDebuffIcons(tUnit);
		tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineDebuff(tUnit);
	end
	VUHDO_MAY_DEBUFF_ANIM = anIsEnableAnim;
end



-- Remove debuffing abilities individually not known to the player
function VUHDO_initDebuffs()
	local tAbility;

	local _, tClass = UnitClass("player");
	twipe(VUHDO_PLAYER_ABILITIES);

	for tDebuffType, tAbilities in pairs(VUHDO_INIT_DEBUFF_ABILITIES[tClass] or sEmpty) do
		for tCnt = 1, #tAbilities do
			tAbility = tAbilities[tCnt];
			--VUHDO_Msg("check: " .. tAbility);
			if (VUHDO_isSpellKnown(tAbility) or tAbility == "*") then
				VUHDO_PLAYER_ABILITIES[tDebuffType] = VUHDO_SPEC_TO_DEBUFF_ABIL[tAbility] or tAbility;
				--VUHDO_Msg("KEEP:" .. VUHDO_PLAYER_ABILITIES[tDebuffType]);
				break;
			end
		end
	end
	--VUHDO_Msg("---");

	if (VUHDO_CONFIG == nil) then
		VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	end

	for _, tDebuffName in pairs(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"]) do
		if (VUHDO_CUSTOM_DEBUFF_CONFIG[tDebuffName] == nil) then
			VUHDO_CUSTOM_DEBUFF_CONFIG[tDebuffName] = { };
		end

		VUHDO_CUSTOM_DEBUFF_CONFIG[tDebuffName][1] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tDebuffName]["isColor"];
		VUHDO_CUSTOM_DEBUFF_CONFIG[tDebuffName][2] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tDebuffName]["isIcon"];
	end

	for tDebuffName, _ in pairs(VUHDO_CUSTOM_DEBUFF_CONFIG) do
		if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tDebuffName] == nil) then
			VUHDO_CUSTOM_DEBUFF_CONFIG[tDebuffName] = nil;
		end
	end

	twipe(VUHDO_IGNORE_DEBUFF_NAMES);

	if (VUHDO_CONFIG["DETECT_DEBUFFS_IGNORE_NO_HARM"]) then
		VUHDO_IGNORE_DEBUFFS_BY_CLASS = VUHDO_INIT_IGNORE_DEBUFFS_BY_CLASS;
		VUHDO_tableAddAllKeys(VUHDO_IGNORE_DEBUFF_NAMES, VUHDO_INIT_IGNORE_DEBUFFS_NO_HARM);
	else
		VUHDO_IGNORE_DEBUFFS_BY_CLASS = sEmpty;
	end

	if (VUHDO_CONFIG["DETECT_DEBUFFS_IGNORE_MOVEMENT"]) then
		VUHDO_tableAddAllKeys(VUHDO_IGNORE_DEBUFF_NAMES, VUHDO_INIT_IGNORE_DEBUFFS_MOVEMENT);
	end

	if (VUHDO_CONFIG["DETECT_DEBUFFS_IGNORE_DURATION"]) then
		VUHDO_tableAddAllKeys(VUHDO_IGNORE_DEBUFF_NAMES, VUHDO_INIT_IGNORE_DEBUFFS_DURATION);
	end
end



--
function VUHDO_getDebuffAbilities()
	return VUHDO_PLAYER_ABILITIES;
end



--
local tEmptySchoolInfo = { };
function VUHDO_getUnitDebuffSchoolInfos(aUnit, aDebuffSchool)
	return (VUHDO_UNIT_DEBUFF_INFOS[aUnit] or VUHDO_INIT_UNIT_DEBUFF_SCHOOLS)[aDebuffSchool] or tEmptySchoolInfo;
end


--
local tEmptyChosen = { nil, 0 };
function VUHDO_getChosenDebuffInfo(aUnit)
	return (VUHDO_UNIT_DEBUFF_INFOS[aUnit] or sEmpty)["CHOSEN"] or tEmptyChosen;
end



--
function VUHDO_resetDebuffsFor(aUnit)
	VUHDO_initDebuffInfos(aUnit);
	VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit] = nil;
end


