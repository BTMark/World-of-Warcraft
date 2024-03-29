local _;

local strlen = strlen;
local strsub = strsub;
local InCombatLockdown = InCombatLockdown;
local twipe = table.wipe;
local tinsert = tinsert;
local strfind = strfind;
local strsplit = strsplit;
local strbyte = strbyte;
local floor = floor;
local tonumber = tonumber;
local select = select;
local strmatch = strmatch;
local IsInRaid = IsInRaid;
local IsInGroup = IsInGroup;
local UnitInRange = UnitInRange;
local GetRaidRosterInfo = GetRaidRosterInfo;
local IsInInstance = IsInInstance;
local IsSpellInRange = IsSpellInRange;
local GetTime = GetTime;
local GetRealZoneText = GetRealZoneText;
local GetMapInfo = GetMapInfo;
local GetSpellInfo = GetSpellInfo;
local SetMapToCurrentZone = SetMapToCurrentZone;
local UnitAlternatePowerInfo = UnitAlternatePowerInfo;
local WorldMapFrame = WorldMapFrame;
local GetMouseFocus = GetMouseFocus;
local GetPlayerFacing = GetPlayerFacing;
local GetPlayerMapPosition = GetPlayerMapPosition;
local GetSpellBookItemInfo = GetSpellBookItemInfo;
local CheckInteractDistance = CheckInteractDistance;
--local UnitIsTrivial = UnitIsTrivial;
local UnitIsUnit = UnitIsUnit;
local IsAltKeyDown = IsAltKeyDown;
local IsControlKeyDown = IsControlKeyDown;
local IsShiftKeyDown = IsShiftKeyDown;
local VUHDO_atan2 = math.atan2;
local VUHDO_PI, VUHDO_2_PI = math.pi, math.pi * 2;
local pairs = pairs;
local type = type;
local abs = abs;
local sEmpty = { };



-- returns an array of numbers sequentially found in a string
local tNumbers = { };
local tIndex;
local tDigit;
local tIsInNumber;
function VUHDO_getNumbersFromString(aName, aMaxAnz)
	twipe(tNumbers);
	tIndex = 0;
	tIsInNumber = false;

	for tCnt = 1, strlen(aName) do
		tDigit = strbyte(aName, tCnt);
		if (tDigit >= 48 and tDigit <= 57) then
			if (tIsInNumber) then
				tNumbers[tIndex] = tNumbers[tIndex] * 10 + tDigit - 48;
			else
				tIsInNumber = true;
				tIndex = tIndex + 1;
				tNumbers[tIndex] = tDigit - 48;
			end
		else
			if (tIndex >= aMaxAnz) then
				return tNumbers;
			end

			tIsInNumber = false;
		end
	end

	return tNumbers;
end



--
--[[VUHDO_COMBAT_LOG_TRACE = {};
local tEntry;
function VUHDO_traceCombatLog(anArg1, anArg2, anArg3, anArg4, anArg5, anArg6, anArg7, anArg8, anArg9, anArg10, anArg11, anArg12, anArg13, anArg14)
	tEntry = "";
	tEntry = tEntry .. "[1]:" .. (anArg1 or "<nil>") .. ",";
	tEntry = tEntry .. "[2]:" .. (anArg2 or "<nil>") .. ",";
	tEntry = tEntry .. "[3]:" .. (anArg3 or "<nil>") .. ",";
	tEntry = tEntry .. "[4]:" .. (anArg4 or "<nil>") .. ",";
	tEntry = tEntry .. "[5]:" .. (anArg5 or "<nil>") .. ",";
	tEntry = tEntry .. "[6]:" .. (anArg6 or "<nil>") .. ",";
	tEntry = tEntry .. "[7]:" .. (anArg7 or "<nil>") .. ",";
	tEntry = tEntry .. "[8]:" .. (anArg8 or "<nil>") .. ",";
	tEntry = tEntry .. "[9]:" .. (anArg9 or "<nil>") .. ",";
	tEntry = tEntry .. "[10]:" .. (anArg10 or "<nil>") .. ",";
	tEntry = tEntry .. "[11]:" .. (anArg11 or "<nil>") .. ",";
	tEntry = tEntry .. "[12]:" .. (anArg12 or "<nil>") .. ",";
	tEntry = tEntry .. "[13]:" .. (anArg13 or "<nil>") .. ",";
	tEntry = tEntry .. "[14]:" .. (anArg14 or "<nil>") .. ",";
	tEntry = tEntry .. "[15]:" .. (anArg15 or "<nil>") .. ",";
	tEntry = tEntry .. "[16]:" .. (anArg16 or "<nil>") .. ",";
	tinsert(VUHDO_COMBAT_LOG_TRACE, tEntry);
end]]



--
function VUHDO_tableUniqueAdd(aTable, aValue)
	for _, tValue in pairs(aTable) do
		if (tValue == aValue) then
			return false;
		end
	end

	aTable[#aTable + 1] = aValue;
	return true;
end



--
function VUHDO_tableRemoveValue(aTable, aValue)
	for tIndex, tValue in pairs(aTable) do
		if (tValue == aValue) then
			tremove(aTable, tIndex);
			return;
		end
	end
end



--
function VUHDO_tableGetKeyFromValue(aTable, aValue)
	for tKey, tValue in pairs(aTable) do
		if (tValue == aValue) then
			return tKey;
		end
	end

	return nil;
end


----------------------------------------------------
local VUHDO_RAID_NAMES;
local VUHDO_RAID;
local VUHDO_UNIT_BUTTONS;
local VUHDO_CONFIG;
local VUHDO_GROUPS_BUFFS;
local sRangeSpell;
local sIsGuessRange = true;
local sScanRange;
local sZeroRange = "";


--
local VUHDO_updateBouquetsForEvent;
function VUHDO_toolboxInitBurst()
	VUHDO_RAID_NAMES = _G["VUHDO_RAID_NAMES"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_UNIT_BUTTONS = _G["VUHDO_UNIT_BUTTONS"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_GROUPS_BUFFS = _G["VUHDO_GROUPS_BUFFS"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	sScanRange = tonumber(VUHDO_CONFIG["SCAN_RANGE"]);
	sRangeSpell = VUHDO_CONFIG["RANGE_SPELL"];
	sIsGuessRange = VUHDO_CONFIG["RANGE_PESSIMISTIC"] or GetSpellInfo(VUHDO_CONFIG["RANGE_SPELL"]) == nil;
	sZeroRange = "0.0 " .. VUHDO_I18N_YARDS;
end



local VUHDO_PROFILE_TIMER = 0; -- Profilers starting time stamp

-- Init by setting start time stamp
function VUHDO_initProfiler()
	VUHDO_PROFILE_TIMER = GetTime() * 1000;
end



-- Dump the duration in ms since profiler has been initialized
function VUHDO_seeProfiler()
	local tTimeDelta = floor(GetTime() * 1000 - VUHDO_PROFILE_TIMER);
	VUHDO_Msg("Duration: " .. tTimeDelta);
end



-- Print chat frame line with no "{Vuhdo} prefix
function VUHDO_MsgC(aMessage, aRed, aGreen, aBlue)
	aRed, aGreen, aBlue = aRed or 1, aGreen or 0.7, aBlue or 0.2;
	DEFAULT_CHAT_FRAME:AddMessage(aMessage, aRed, aGreen, aBlue);
end



--
local function VUHDO_arg2Text(anArg)

	if (anArg == nil) then
		return "<nil>";
	elseif ("function" == type(anArg)) then
		return "<func>";
	elseif ("table" == type(anArg)) then
		return "<table>";
	elseif ("boolean" == type(anArg)) then
		return anArg and "<true>" or  "<false>";
	elseif (anArg == "") then
		return " ";
	else
		return anArg;
	end
end



-- Print a standard chat frame
function VUHDO_Msg(aMessage, aRed, aGreen, aBlue)
	VUHDO_MsgC("|cffffe566{VuhDo}|r " .. VUHDO_arg2Text(aMessage), aRed, aGreen, aBlue)
end



--
function VUHDO_xMsg(...)
	local tText;
	local tFrag;

	tText = "";
	for tCnt = 1, select('#', ...) do
		tFrag = select(tCnt, ...);
		tText = tText .. tCnt .. "=[" .. VUHDO_arg2Text(tFrag) .. "] ";
	end
	VUHDO_MsgC(tText);
end



--
function VUHDO_getCurrentGroupType()
	return IsInRaid() and 2 or IsInGroup() and 1 or 0;
end
local VUHDO_getCurrentGroupType = VUHDO_getCurrentGroupType;



-- returns unit-prefix, pet-prefix and maximum number of players in a party
function VUHDO_getUnitIds()
	if (IsInRaid()) then
		return "raid", "raidpet";
	elseif (IsInGroup()) then
		return "party", "partypet";
	else
		return "player", "pet";
	end
end
local VUHDO_getUnitIds = VUHDO_getUnitIds;



-- Extracts unit number from a Unit's name
local tUnitNo;
function VUHDO_getUnitNo(aUnit)
	if ("focus" == aUnit or "target" == aUnit) then
		return 0;
	end

	if ("player" == aUnit) then
		aUnit = VUHDO_PLAYER_RAID_ID or "player";
	end

	return tonumber(strsub(aUnit, -2, -1)) or tonumber(strsub(aUnit, -1)) or 1;
end
local VUHDO_getUnitNo = VUHDO_getUnitNo;



-- returns the units subgroup number, or 0 for pets/focus
function VUHDO_getUnitGroup(aUnit, anIsPet)
	if (anIsPet or aUnit == nil or aUnit == "focus" or aUnit == "target") then
		return 0;
	elseif (VUHDO_GROUP_TYPE_RAID == VUHDO_getCurrentGroupType()) then
		return select(3, GetRaidRosterInfo(VUHDO_getUnitNo(aUnit))) or 1;
	else
		return 1;
	end
end



--
function VUHDO_isTargetInRange(aUnit)
	return UnitIsUnit("player", aUnit) or CheckInteractDistance(aUnit, 1);
end
local VUHDO_isTargetInRange = VUHDO_isTargetInRange;



-- returns wether or not a unit is in range
function VUHDO_isInRange(aUnit)
	if ("player" == aUnit) then
		return true;
	elseif ("focus" == aUnit or "target" == aUnit) then
		return VUHDO_isTargetInRange(aUnit);
	elseif (sIsGuessRange) then
		return UnitInRange(aUnit);
	else
		return 1 == IsSpellInRange(sRangeSpell, aUnit);
	end
end



-- Parses a aString line into an array of arguments
function VUHDO_textParse(aString)
	aString = strtrim(aString);

	while (strfind(aString, "  ", 1, true)) do
		aString = gsub(aString, "  ", " ");
	end

	return VUHDO_splitString(aString, " ");
end



-- Returns a "deep" copy of a table,
-- which means containing tables will be copies value-wise, not by reference
function VUHDO_deepCopyTable(aTable)
	local tDestTable = { };

	for tKey, tValue in pairs(aTable) do
		if ("table" == type(tValue)) then
			tDestTable[tKey] = VUHDO_deepCopyTable(tValue);
		else
			tDestTable[tKey] = tValue;
		end
	end

	return tDestTable;
end



-- Tokenizes a String into an array of strings, which were delimited by "aChar"
function VUHDO_splitString(aText, aChar)
	return { strsplit(aChar, aText) };
end



-- returns true if player currently is in a battleground
local tType;
function VUHDO_isInBattleground()
	_, tType = IsInInstance();
	return "pvp" == tType or "arena" == tType;
end
local VUHDO_isInBattleground = VUHDO_isInBattleground;



-- returns the appropriate addon message channel for player
function VUHDO_getAddOnDistribution()
	return VUHDO_isInBattleground() and "BATTLEGROUND"
		or VUHDO_GROUP_TYPE_RAID == VUHDO_getCurrentGroupType() and "RAID"
		or "PARTY";
end



-- returns the units rank in a raid which is 0 = raid member, 1 = assist, 2 = leader
-- returns 2 if not in raid
local tRank, tIsMl, tGroupType;
function VUHDO_getUnitRank(aUnit)
	tGroupType = VUHDO_getCurrentGroupType();
	if (VUHDO_GROUP_TYPE_RAID == tGroupType) then
		_, tRank, _, _, _, _, _, _, _, _, tIsMl = GetRaidRosterInfo(VUHDO_getUnitNo(aUnit));
		return tRank, tIsMl;
	elseif (VUHDO_GROUP_TYPE_PARTY == tGroupType) then
		if (UnitIsGroupLeader(aUnit)) then
			return 2, true;
		else
			return 0, true;
		end
	else
		return 2, true;
	end
end



-- returns the players rank in a raid which is 0 = raid member, 1 = assist, 2 = leader
-- returns leader if not in raid, and member if solo, as no main tank are needed
function VUHDO_getPlayerRank()
	return VUHDO_getUnitRank("player");
end



-- returns the raid unit of player eg. "raid13" or "party4"
local tRaidUnit;
function VUHDO_getPlayerRaidUnit()
	if (VUHDO_GROUP_TYPE_RAID == VUHDO_getCurrentGroupType()) then
		for tCnt = 1, 40 do
			tRaidUnit = format("raid%d", tCnt);
			if (UnitIsUnit("player", tRaidUnit)) then
				return tRaidUnit;
			end
		end
	end
	return "player";
end
local VUHDO_getPlayerRaidUnit = VUHDO_getPlayerRaidUnit;



--
function VUHDO_getNumGroupMembers(aGroupId)
	return #(VUHDO_GROUPS[aGroupId] or sEmpty);
end



--
local tZone, tIndex, tMap, tInfo;
function VUHDO_getUnitZoneName(aUnit)
	tInfo = VUHDO_RAID[aUnit];
	if (tInfo == nil) then
		return;
	end

	if ("player" == aUnit or tInfo["visible"]) then
		tZone = GetRealZoneText();
	elseif (VUHDO_GROUP_TYPE_RAID == VUHDO_getCurrentGroupType()) then
		tIndex = (VUHDO_RAID[aUnit] or sEmpty)["number"] or 1;
		_, _, _, _, _, _, tZone = GetRaidRosterInfo(tIndex);
	else
		VuhDoScanTooltip:SetOwner(VuhDo, "ANCHOR_NONE");
		VuhDoScanTooltip:ClearLines();
		VuhDoScanTooltip:SetUnit(aUnit)
		tZone = VuhDoScanTooltipTextLeft3:GetText();
		if (tZone == "PvP") then
			tZone = VuhDoScanTooltipTextLeft4:GetText();
		end
	end

	tMap = GetMapInfo();
	return tZone or tMap or VUHDO_I18N_UNKNOWN, tMap;
end



--
local tName, tEnchant;
function VUHDO_getWeaponEnchantName(aSlot)
	VuhDoScanTooltip:SetOwner(VuhDo, "ANCHOR_NONE");
	VuhDoScanTooltip:ClearLines();
	VuhDoScanTooltip:SetInventoryItem("player", aSlot);
	for tCnt = 1, VuhDoScanTooltip:NumLines() do
		tName = strmatch(_G["VuhDoScanTooltipTextLeft" .. tCnt]:GetText(), "^.+ %(%d+%s+.+%)$");
		if (tName ~= nil) then
			tEnchant = gsub(tName, " %(.+%)", "");
			return tEnchant;
		end
	end

	return "*";
end



--
local tEmptyZone = { };
function VUHDO_isInSameZone(aUnit)
	return (VUHDO_RAID[aUnit] or tEmptyZone)["map"] == (VUHDO_RAID["player"] or tEmptyZone)["map"];
end
local VUHDO_isInSameZone = VUHDO_isInSameZone;



-- Returns health of unit info in Percent
local tHealthMax;
function VUHDO_getUnitHealthPercent(anInfo)
	tHealthMax = anInfo["healthmax"];
	return tHealthMax == 0 and 0
		or anInfo["health"] < tHealthMax and 100 * anInfo["health"] / tHealthMax
		or 100;
end



--
function VUHDO_isSpellKnown(aSpellName)
	return GetSpellBookItemInfo(aSpellName) ~= nil
		or VUHDO_NAME_TO_SPELL[aSpellName] ~= nil and GetSpellBookItemInfo(VUHDO_NAME_TO_SPELL[aSpellName]);
end



--
local tDeltaSecs;
function VUHDO_getDurationTextSince(aStartTime)
	if (aStartTime == nil) then
		return "";
	end

	tDeltaSecs = GetTime() - aStartTime;
	return tDeltaSecs >= 3600 and format("(|cffffffff%.0f:%02d %s|r)", tDeltaSecs / 3600, floor(tDeltaSecs / 60) % 60, VUHDO_I18N_HOURS)
		  or format("(|cffffffff%d:%02d %s|r)", tDeltaSecs / 60, tDeltaSecs % 60, VUHDO_I18N_MINS);
end



--
local tDistance;
function VUHDO_getDistanceText(aUnit)
	tDistance = VUHDO_getDistanceBetween("player", aUnit);
	return tDistance ~= nil and tDistance
	    or "player" == aUnit and sZeroRange
	    or VUHDO_I18N_UNKNOWN;
end



--
local sTargetUnits = { };
function VUHDO_getTargetUnit(aSourceUnit)
	if (sTargetUnits[aSourceUnit] == nil) then
		sTargetUnits[aSourceUnit] = "player" == aSourceUnit and "target" or aSourceUnit .. "target";
	end

	return sTargetUnits[aSourceUnit];
end



--
function VUHDO_getResurrectionSpells()
	return (VUHDO_RESURRECTION_SPELLS[VUHDO_PLAYER_CLASS] or {})[1],
		(VUHDO_RESURRECTION_SPELLS[VUHDO_PLAYER_CLASS] or {})[2];
end



--
local tInfo;
local tEmptyInfo = { };
function VUHDO_resolveVehicleUnit(aUnit)
	tInfo = VUHDO_RAID[aUnit] or tEmptyInfo;

	if (tInfo["isPet"] and (VUHDO_RAID[tInfo["ownerUnit"]] or tEmptyInfo)["isVehicle"]) then
		return tInfo["ownerUnit"];
	else
		return aUnit;
	end
end



--
function VUHDO_getUnitButtons(aUnit)
	return VUHDO_UNIT_BUTTONS[aUnit];
end


function VUHDO_getUnitButtonsSafe(aUnit)
	return VUHDO_UNIT_BUTTONS[aUnit] or sEmpty;
end


--
function VUHDO_getUnitButtonsPanel(aUnit, aPanelNum)
	return (VUHDO_UNIT_BUTTONS_PANEL[aUnit] or sEmpty)[aPanelNum] or sEmpty;
end



--
local tInfo;
function VUHDO_shouldScanUnit(aUnit)
	tInfo = VUHDO_RAID[aUnit] or sEmpty;
	if (not tInfo["connected"] or tInfo["dead"]) then
		return true;
	elseif (sScanRange == 1) then
		return VUHDO_isInSameZone(aUnit);
	elseif (sScanRange == 2) then
		return tInfo["visible"];
	elseif (sScanRange == 3) then
		return tInfo["baseRange"];
	else
		return true;
	end
end



--
local tNumBytes, tNumChars;
local tNumCut;
local tByte;
function VUHDO_utf8Cut(aString, aNumChars)
	tNumBytes = strlen(aString);
	tNumCut = 1;
	tNumChars = 0;
	while (tNumCut < tNumBytes and tNumChars < aNumChars) do
		tByte = strbyte(aString, tNumCut);

		tNumCut = tNumCut + (
			    tByte < 194 and 1
			 or tByte < 224 and 2
			 or tByte < 240 and 3
			 or tByte < 245 and 4
			 or 1 -- invalid
		);

		tNumChars = tNumChars + 1;
	end

	return strsub(aString, 1, tNumCut - 1);
end



--
function VUHDO_strempty(aString)
	if (aString ~= nil) then
		for tCnt = 1, strlen(aString) do
			if (strbyte(aString, tCnt) ~= 32) then
				return false;
			end
		end
	end

	return true;
end



--
function VUHDO_tableAddAllKeys(aDestTable, aTableToAdd)
	for tIndex, tValue in pairs(aTableToAdd) do
		aDestTable[tIndex] = tValue;
	end
end



-- Throttle resetting to current map to avoid conflicts with other addons
local tNextTime = 0;
function VUHDO_setMapToCurrentZone()
	if (tNextTime < GetTime()) then
		SetMapToCurrentZone();
		tNextTime = GetTime() + 2;
	end
end
local VUHDO_setMapToCurrentZone = VUHDO_setMapToCurrentZone;



--
local tInfo;
function VUHDO_replaceMacroTemplates(aText, aUnit)
	if (aUnit ~= nil) then
		aText = gsub(aText, "[Vv][Uu][Hh][Dd][Oo]", aUnit);
		tInfo = VUHDO_RAID[aUnit];
		if (tInfo ~= nil) then
			aText = gsub(aText, "[Vv][Dd][Nn][Aa][Mm][Ee]", tInfo["name"]);

			if (tInfo["petUnit"] ~= nil) then
				aText = gsub(aText, "[Vv][Dd][Pp][Ee][Tt]", tInfo["petUnit"]);
			end

			if (tInfo["targetUnit"] ~= nil) then
				aText = gsub(aText, "[Vv][Dd][Tt][Aa][Rr][Gg][Ee][Tt]", tInfo["targetUnit"]);
			end
		end
	end

	return aText;
end



--
local tActionLowerName;
local tIsMacroKnown, tIsSpellKnown
function VUHDO_isActionValid(anActionName, anIsCustom)

	if ((anActionName or "") == "") then
		return nil;
	end

	tActionLowerName = strlower(anActionName);

	if (VUHDO_SPELL_KEY_ASSIST == tActionLowerName
	 or VUHDO_SPELL_KEY_FOCUS == tActionLowerName
	 or VUHDO_SPELL_KEY_MENU == tActionLowerName
	 or VUHDO_SPELL_KEY_TELL == tActionLowerName
	 or VUHDO_SPELL_KEY_TARGET == tActionLowerName
	 or VUHDO_SPELL_KEY_DROPDOWN == tActionLowerName) then
		return VUHDO_I18N_COMMAND, 0.8, 1, 0.8, "CMD";
	end

	tIsMacroKnown = GetMacroIndexByName(anActionName) ~= 0;
	tIsSpellKnown = VUHDO_isSpellKnown(anActionName);

	if (tIsSpellKnown and tIsMacroKnown) then
		VUHDO_Msg(format(VUHDO_I18N_AMBIGUOUS_MACRO, anActionName), 1, 0.3, 0.3);
		return VUHDO_I18N_WARNING, 1, 0.3, 0.3, "WRN";
	elseif (tIsMacroKnown) then
		return VUHDO_I18N_MACRO, 0.8, 0.8, 1, "MCR";
	elseif (tIsSpellKnown) then
		return VUHDO_I18N_SPELL, 1, 0.8, 0.8, "SPL";
	elseif (IsUsableItem(anActionName)) then
		return VUHDO_I18N_ITEM, 1, 1, 0.8, "ITM";
	elseif (anIsCustom) then
		return "Custom", 0.9, 0.9, 0.2, "CUS";
	else
		return nil;
	end

end



--
local tBarType, tIsHideFromOthers;
function VUHDO_isAltPowerActive(aUnit)
	local tBarType, _, _, _, _, tIsHideFromOthers = UnitAlternatePowerInfo(aUnit);
	return tBarType ~= nil and (not tIsHideFromOthers or "player" == aUnit);
end



--
function VUHDO_decompressIfCompressed(aFile)
	if ("string" == type(aFile)) then
		return VUHDO_deserializeTable(aFile);
	else
		return aFile;
	end
end



--
function VUHDO_decompressOrCopy(aFile)
	if ("string" == type(aFile)) then
		return VUHDO_deserializeTable(aFile);
	else
		return VUHDO_deepCopyTable(aFile);
	end
end



--
function VUHDO_compressTable(aTable)
	if (type(aTable) == "table") then
		return VUHDO_serializeTable(aTable);
	else
		return aTable;
	end
end



--
function VUHDO_compressAllBouquets()
	for tName, _ in pairs(VUHDO_BOUQUETS["STORED"]) do
		VUHDO_BOUQUETS["STORED"][tName] = VUHDO_compressTable(VUHDO_BOUQUETS["STORED"][tName]);
	end
end



--
function VUHDO_decompressAllBouquets()
	for tName, _ in pairs(VUHDO_BOUQUETS["STORED"]) do
		VUHDO_BOUQUETS["STORED"][tName] = VUHDO_decompressIfCompressed(VUHDO_BOUQUETS["STORED"][tName]);
	end
end



--
function VUHDO_isGlyphed(aGlyphId)
	local tGlyphId;
	for tCnt = 1, GetNumGlyphs() do
		if (select(4, GetGlyphSocketInfo(tCnt)) == aGlyphId) then
			return true;
		end
	end

	return false;
end



--
local tPlayerX, tPlayerY;
local tUnitX, tUnitY;
local tFacing;
function VUHDO_getUnitDirection(aUnit)
	if ((WorldMapFrame ~= nil and WorldMapFrame:IsShown())
		or (GetMouseFocus() ~= nil and GetMouseFocus():GetName() == nil)) then
		return nil;
	end

	tPlayerX, tPlayerY = GetPlayerMapPosition("player");
	if ((tPlayerX or 0) + (tPlayerY or 0) <= 0) then
		VUHDO_setMapToCurrentZone();
		tPlayerX, tPlayerY = GetPlayerMapPosition("player");
		if ((tPlayerX or 0) + (tPlayerY or 0) <= 0) then
			return nil;
		end
	end

	tUnitX, tUnitY = GetPlayerMapPosition(aUnit);
	if ((tUnitX or 0) + (tUnitY or 0) <= 0) then
		return nil;
	end

	tFacing = GetPlayerFacing();
	tFacing = tFacing < 0 and tFacing + VUHDO_2_PI or tFacing;

	return VUHDO_PI - VUHDO_atan2(tPlayerX - tUnitX, tUnitY - tPlayerY) - tFacing;
end
local VUHDO_getUnitDirection = VUHDO_getUnitDirection;



--
local tDirection;
local tConeFactor = 180 / VUHDO_PI;
function VUHDO_isInConeInFrontOf(aUnit, aDegrees)
	if (aDegrees >= 360 or "player" == aUnit) then
		return true;
	end

	tDirection = VUHDO_getUnitDirection(aUnit);

	if (tDirection == nil) then
		return false;
	elseif (tDirection < 0) then
		tDirection = tDirection + VUHDO_2_PI;
	end

	return aDegrees * 0.5 >= 180 - abs(180 - tConeFactor * tDirection);
end



--
function VUHDO_forceBooleanValue(aRawValue)
	if (aRawValue == nil or aRawValue == 0 or aRawValue == false) then
		return false;
	else
		return true;
	end
end



function VUHDO_getCurrentKeyModifierString()
return format("%s%s%s",
		IsAltKeyDown() and "alt" or "",
		IsControlKeyDown() and "ctrl" or "",
		IsShiftKeyDown() and "shift" or ""
	);
end