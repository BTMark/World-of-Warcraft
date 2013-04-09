--[[ 
  @file       oqueue.defines.lua
  @brief      core defines for oqueue (should be region/language independent)

  @author     rmcinnis
  @date       november 26, 2012
  @par        copyright (c) 2012 Solid ICE Technologies, Inc.  All rights reserved.
              this file may be distributed so long as it remains unaltered
              if this file is posted to a web site, credit must be given to me along with a link to my web page
              no code in this file may be used in other works without expressed permission  
]]--
local addonName, OQ = ... ;

OQ.FONT = "Fonts\\FRIZQT__.TTF" ;

OQ.RND  = 0 ;
OQ.TP   = 1 ;
OQ.BFG  = 2 ;
OQ.WSG  = 3 ;
OQ.AB   = 4 ;
OQ.EOTS = 5 ;
OQ.AV   = 6 ;
OQ.SOTA = 7 ;
OQ.IOC  = 8 ;
OQ.SSM  = 9 ;
OQ.TOK  = 10 ;
OQ.NONE = 15 ;

OQ.TYPE_NONE     = 'X' ;
OQ.TYPE_BG       = 'B' ;
OQ.TYPE_RBG      = 'A' ;
OQ.TYPE_RAID     = 'R' ;
OQ.TYPE_DUNGEON  = 'D' ;
OQ.TYPE_SCENARIO = 'S' ;
OQ.TYPE_ARENA    = 'a' ;


OQ.DD_NONE     = "none" ;
OQ.DD_STAR     = "star" ;
OQ.DD_CIRCLE   = "circle" ;
OQ.DD_DIAMOND  = "diamond" ;
OQ.DD_TRIANGLE = "triangle" ;
OQ.DD_MOON     = "moon" ;
OQ.DD_SQUARE   = "square" ;
OQ.DD_REDX     = "cross" ;
OQ.DD_SKULL    = "skull" ;

-- Class talent specs
OQ.BG_ROLES = {
	["Death Knight"] = {
		["Blood"]         = "Tank",
		["Frost"]         = "Melee",
		["Unholy"]        = "Melee",
	},
	["Druid"] = {
		["Balance"]       = "Knockback",
		["Feral Combat"]  = "Melee",
		["Restoration"]   = "Healer",
		["Guardian"]      = "Tank",
	},
	["Hunter"] = {
		["Beast Mastery"] = "Knockback",
		["Marksmanship"]  = "Ranged",
		["Survival"]      = "Ranged",
	},
	["Mage"] = {
		["Arcane"]        = "Knockback",
		["Fire"]          = "Ranged",
		["Frost"]         = "Ranged",
	},
	["Monk"] = {
		["Brewmaster"]    = "Tank",
		["Mistweaver"]    = "Healer",
		["Windwalker"]    = "Melee",
	},
	["Paladin"] = {
		["Holy"]          = "Healer",
		["Protection"]    = "Tank",
		["Retribution"]   = "Melee",
	},
	["Priest"] = {
		["Discipline"]    = "Healer",
		["Holy"]          = "Healer",
		["Shadow"]        = "Ranged",
	},
	["Rogue"] = {
		["Assassination"] = "Melee",
		["Combat"]        = "Melee",
		["Subtlety"]      = "Melee",
	},
	["Shaman"] = {
		["Elemental"]     = "Knockback",
		["Enhancement"]   = "Melee",
		["Restoration"]   = "Healer",
	},
	["Warlock"] = {
		["Affliction"]    = "Knockback",
		["Demonology"]    = "Knockback",
		["Destruction"]   = "Knockback",
	},
	["Warrior"] = {
		["Arms"]          = "Melee",
		["Fury"]          = "Melee",
		["Protection"]    = "Tank",
	},
} ;

OQ.RACE_DWARF     =  1 ;
OQ.RACE_DRAENEI   =  2 ;
OQ.RACE_GNOME     =  3 ;
OQ.RACE_HUMAN     =  4 ;
OQ.RACE_NIGHTELF  =  5 ;
OQ.RACE_WORGEN    =  6 ;
OQ.RACE_BLOODELF  =  7 ;
OQ.RACE_GOBLIN    =  8 ;
OQ.RACE_ORC       =  9 ;
OQ.RACE_TAUREN    = 10 ;
OQ.RACE_TROLL     = 11 ;
OQ.RACE_SCOURGE   = 12 ;
OQ.RACE_PANDAREN  = 13 ;

OQ.RACE = { ["Dwarf"   ] = OQ.RACE_DWARF,
            ["Draenei" ] = OQ.RACE_DRAENEI,
            ["Gnome"   ] = OQ.RACE_GNOME,
            ["Human"   ] = OQ.RACE_HUMAN,
            ["NightElf"] = OQ.RACE_NIGHTELF,
            ["Worgen"  ] = OQ.RACE_WORGEN,
            ["BloodElf"] = OQ.RACE_BLOODELF,
            ["Goblin"  ] = OQ.RACE_GOBLIN,
            ["Orc"     ] = OQ.RACE_ORC,
            ["Tauren"  ] = OQ.RACE_TAUREN,
            ["Troll"   ] = OQ.RACE_TROLL,
            ["Scourge" ] = OQ.RACE_SCOURGE,
            ["Pandaren"] = OQ.RACE_PANDAREN,
          } ;

OQ.SHORT_LEVEL_RANGE = { [ "unavailable" ] = 1,
                         [ "10 - 14" ] = 2,
                         [ "15 - 19" ] = 3,
                         [ "20 - 24" ] = 4,
                         [ "25 - 29" ] = 5,
                         [ "30 - 34" ] = 6,
                         [ "35 - 39" ] = 7,
                         [ "40 - 44" ] = 8,
                         [ "45 - 49" ] = 9,
                         [ "50 - 54" ] = 10,
                         [ "55 - 59" ] = 11,
                         [ "60 - 64" ] = 12,
                         [ "65 - 69" ] = 13,
                         [ "70 - 74" ] = 14,
                         [ "75 - 79" ] = 15,
                         [ "80 - 84" ] = 16,
                         [ "85"      ] = 17,
                         [ "85 - 89" ] = 18,
                         [ "90"      ] = 19,
                         [  1 ] = "unavailable",
                         [  2 ] = "10 - 14",
                         [  3 ] = "15 - 19",
                         [  4 ] = "20 - 24",
                         [  5 ] = "25 - 29",
                         [  6 ] = "30 - 34",
                         [  7 ] = "35 - 39",
                         [  8 ] = "40 - 44",
                         [  9 ] = "45 - 49",
                         [ 10 ] = "50 - 54",
                         [ 11 ] = "55 - 59",
                         [ 12 ] = "60 - 64",
                         [ 13 ] = "65 - 69",
                         [ 14 ] = "70 - 74",
                         [ 15 ] = "75 - 79",
                         [ 16 ] = "80 - 84",
                         [ 17 ] = "85"     ,
                         [ 18 ] = "85 - 89",
                         [ 19 ] = "90"     ,
                       } ;

OQ.CLASS_COLORS = { ["DK"]  = { r = 0.77, g = 0.12, b = 0.23 },
                    ["DR"]  = { r = 1.00, g = 0.49, b = 0.04 },
                    ["HN"]  = { r = 0.67, g = 0.83, b = 0.45 },
                    ["MG"]  = { r = 0.41, g = 0.80, b = 0.94 },
                    ["MK"]  = { r = 0.00, g = 1.00, b = 0.59 },
                    ["PA"]  = { r = 0.96, g = 0.55, b = 0.73 },
                    ["PR"]  = { r = 1.00, g = 1.00, b = 1.00 },
                    ["RO"]  = { r = 1.00, g = 0.96, b = 0.41 },
                    ["SH"]  = { r = 0.00, g = 0.44, b = 0.87 },
                    ["LK"]  = { r = 0.58, g = 0.51, b = 0.79 },
                    ["WA"]  = { r = 0.78, g = 0.61, b = 0.43 },
                    ["XX"]  = { r = 0.20, g = 0.20, b = 0.00 },
                    ["YY"]  = { r = 0.20, g = 0.20, b = 0.00 },
                    ["ZZ"]  = { r = 0.20, g = 0.20, b = 0.00 },
                  } ;

OQ.ROLES        = { [ "DAMAGER" ] = 1,
                    [ "HEALER"  ] = 2,
                    [ "NONE"    ] = 3,
                    [ "TANK"    ] = 4,
                    [ 1 ]         = "DAMAGER",
                    [ 2 ]         = "HEALER",
                    [ 3 ]         = "NONE",
                    [ 4 ]         = "TANK",
                    [ "D" ]       = 1,
                    [ "H" ]       = 2,
                    [ "N" ]       = 3,
                    [ "T" ]       = 4,
                  } ;

OQ.CLASS_TEXTCLR = {
	["DK"]      = "|cFFC41F3B",
	["DR"]      = "|cFFFF7D0A",
	["HN"]      = "|cFFABD473",
	["MG"]      = "|cFF69CCF0",
	["PA"]      = "|cFFF58CBA",
	["PR"]      = "|cFFFFFFFF",
	["RO"]      = "|cFFFFF569",
	["SH"]      = "|cFF0070DE",
	["LK"]      = "|cFF9482C9",
	["WA"]      = "|cFFC79C6E",
} ;

OQ.SHORT_CLASS = { ["DEATHKNIGHT"]  = "DK",
                   ["DEATH KNIGHT"] = "DK",
                   ["DRUID"]        = "DR",
                   ["HUNTER"]       = "HN",
                   ["MAGE"]         = "MG",
                   ["MONK"]         = "MK",
                   ["PALADIN"]      = "PA",
                   ["PRIEST"]       = "PR",
                   ["ROGUE"]        = "RO",
                   ["SHAMAN"]       = "SH",
                   ["WARLOCK"]      = "LK",
                   ["WARRIOR"]      = "WA",
                   ["NONE"]         = "XX",
                   ["UNKNOWN"]      = "ZZ",
                 } ;
                   
OQ.LONG_CLASS  = { ["DK"]           = "DEATHKNIGHT",
                   ["DR"]           = "DRUID",
                   ["HN"]           = "HUNTER",
                   ["MG"]           = "MAGE",
                   ["MK"]           = "MONK",
                   ["PA"]           = "PALADIN",
                   ["PR"]           = "PRIEST",
                   ["RO"]           = "ROGUE",
                   ["SH"]           = "SHAMAN",
                   ["LK"]           = "WARLOCK",
                   ["WA"]           = "WARRIOR",
                   ["XX"]           = "NONE",
                   ["YY"]           = "UNK",
                   ["ZZ"]           = "UNK",
                 } ;

OQ.QUEUE_STATUS = { ["none"   ] = "0",
                    ["queued" ] = "1",
                    ["confirm"] = "2",
                    ["active" ] = "3",
                    ["error"  ] = "4",
                    [ 0       ] = "-",
                    [ 1       ] = "queued",
                    [ 2       ] = "CONFIRM",
                    [ 3       ] = "inside",
                    [ 4       ] = "error",
                    ["0"      ] = "-",
                    ["1"      ] = "queued",
                    ["2"      ] = "CONFIRM",
                    ["3"      ] = "inside",
                    ["4"      ] = "error",
                  } ;

OQ.gbl = { ["TTS#1959"] = 1,
         } ;

