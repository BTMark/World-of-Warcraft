
ElvDB = {
	["profileKeys"] = {
		["Plebe - Area 52"] = "Plebe - Area 52",
		["Plebeian - Area 52"] = "Plebeian - Area 52",
		["Mooselini - Area 52"] = "Mooselini - Area 52",
		["Esoom - Garona"] = "Esoom - Garona",
	},
	["gold"] = {
		["Garona"] = {
			["Esoom"] = 33,
		},
		["Area 52"] = {
			["Plebeian"] = 2325977,
			["Mooselini"] = 57059187,
			["Plebe"] = 18232164,
		},
	},
	["namespaces"] = {
		["LibDualSpec-1.0"] = {
		},
	},
	["global"] = {
		["unitframe"] = {
			["aurafilters"] = {
				["Blacklist"] = {
					["spells"] = {
						["Physical Vulnerability"] = {
							["enable"] = true,
							["priority"] = 0,
						},
						["Blood Plague"] = {
							["enable"] = true,
							["priority"] = 0,
						},
						["Censure"] = {
							["enable"] = true,
							["priority"] = 0,
						},
						["Deep Wounds"] = {
							["enable"] = true,
							["priority"] = 0,
						},
					},
				},
			},
			["buffwatch"] = {
				["SHAMAN"] = {
					{
						["color"] = {
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
						["displayText"] = true,
						["style"] = "NONE",
					}, -- [1]
					{
						["point"] = "BOTTOMRIGHT",
						["yOffset"] = 10,
						["style"] = "texturedIcon",
					}, -- [2]
					{
						["point"] = "TOPLEFT",
						["color"] = {
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["displayText"] = true,
						["style"] = "NONE",
					}, -- [3]
				},
				["PRIEST"] = {
					{
						["point"] = "LEFT",
						["displayText"] = true,
						["yOffset"] = 2,
						["style"] = "NONE",
						["textColor"] = {
							["g"] = 0,
							["b"] = 0,
						},
					}, -- [1]
					{
						["point"] = "TOPRIGHT",
						["style"] = "texturedIcon",
					}, -- [2]
					{
						["enabled"] = false,
					}, -- [3]
					{
						["color"] = {
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["displayText"] = true,
						["style"] = "NONE",
					}, -- [4]
					nil, -- [5]
					{
						["enabled"] = false,
					}, -- [6]
					{
						["enabled"] = false,
					}, -- [7]
					{
						["enabled"] = false,
					}, -- [8]
					{
						["enabled"] = true,
						["anyUnit"] = false,
						["point"] = "BOTTOMLEFT",
						["color"] = {
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
						["displayText"] = true,
						["textThreshold"] = -1,
						["yOffset"] = 8,
						["style"] = "NONE",
						["id"] = 47753,
					}, -- [9]
					{
						["enabled"] = true,
						["anyUnit"] = false,
						["point"] = "BOTTOMRIGHT",
						["color"] = {
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
						["displayText"] = true,
						["textThreshold"] = -1,
						["yOffset"] = 8,
						["style"] = "NONE",
						["id"] = 114908,
					}, -- [10]
				},
				["DRUID"] = {
					{
						["point"] = "TOPLEFT",
						["displayText"] = true,
						["style"] = "NONE",
					}, -- [1]
					{
						["displayText"] = true,
						["yOffset"] = 8,
						["style"] = "NONE",
					}, -- [2]
					{
						["point"] = "BOTTOMRIGHT",
						["displayText"] = true,
						["textThreshold"] = 5,
						["yOffset"] = 12,
						["style"] = "texturedIcon",
					}, -- [3]
					{
						["point"] = "TOPRIGHT",
						["displayText"] = true,
						["textThreshold"] = 3,
						["style"] = "texturedIcon",
					}, -- [4]
				},
				["MONK"] = {
					{
						["color"] = {
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["displayText"] = true,
						["style"] = "NONE",
					}, -- [1]
					{
						["enabled"] = false,
					}, -- [2]
					{
						["color"] = {
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["displayText"] = true,
						["yOffset"] = 8,
						["style"] = "NONE",
					}, -- [3]
					{
						["color"] = {
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["displayText"] = true,
						["yOffset"] = 8,
						["style"] = "NONE",
					}, -- [4]
					{
						["enabled"] = true,
						["anyUnit"] = false,
						["point"] = "TOPRIGHT",
						["id"] = 115175,
						["color"] = {
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
						["displayText"] = false,
						["style"] = "texturedIcon",
						["yOffset"] = 0,
					}, -- [5]
				},
			},
		},
	},
	["profiles"] = {
		["Plebe - Area 52"] = {
			["sle"] = {
				["datatext"] = {
					["dp6"] = {
						["enabled"] = true,
						["width"] = 410,
					},
					["top"] = {
						["width"] = 104,
					},
					["bottom"] = {
						["enabled"] = true,
						["width"] = 104,
					},
				},
			},
			["movers"] = {
				["DP_6_Mover"] = "BOTTOMElvUIParentBOTTOM04",
				["ElvUF_Raid40Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4200",
				["ElvUF_PlayerCastbarMover"] = "BOTTOMElvUIParentBOTTOM0100",
				["ElvAB_1"] = "BOTTOMElvUIParentBOTTOM060",
				["Bottom_Panel_Mover"] = "BOTTOMElvUIParentBOTTOM2604",
				["ElvAB_4"] = "BOTTOMLEFTElvUIParentBOTTOMRIGHT-413200",
				["ElvUF_Raid10Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4200",
				["ElvAB_3"] = "BOTTOMElvUIParentBOTTOM26027",
				["ElvAB_5"] = "BOTTOMElvUIParentBOTTOM-26027",
				["ElvUF_TargetTargetMover"] = "BOTTOMElvUIParentBOTTOM0190",
				["BossButton"] = "CENTERElvUIParentCENTER-413188",
				["LeftChatMover"] = "BOTTOMLEFTUIParentBOTTOMLEFT021",
				["RightChatMover"] = "BOTTOMRIGHTUIParentBOTTOMRIGHT021",
				["ShiftAB"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT41421",
				["TotemBarMover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT41421",
				["ElvUF_FocusMover"] = "BOTTOMElvUIParentBOTTOM-63436",
				["ArenaHeaderMover"] = "TOPRIGHTElvUIParentTOPRIGHT-210-410",
				["ElvUF_PlayerMover"] = "BOTTOMElvUIParentBOTTOM-278200",
				["Top_Center_Mover"] = "BOTTOMElvUIParentBOTTOM-2604",
				["BossHeaderMover"] = "BOTTOMRIGHTElvUIParentBOTTOMRIGHT-210435",
				["ElvUF_PetMover"] = "BOTTOMElvUIParentBOTTOM0230",
				["ElvUF_Raid25Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4200",
				["ElvUF_PartyMover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4200",
				["PetAB"] = "RIGHTElvUIParentRIGHT00",
				["ElvAB_2"] = "BOTTOMElvUIParentBOTTOM027",
				["ElvUF_TargetMover"] = "BOTTOMElvUIParentBOTTOM278200",
			},
			["gridSize"] = 110,
			["tooltip"] = {
				["style"] = "inset",
			},
			["hideTutorial"] = 1,
			["chat"] = {
				["emotionIcons"] = false,
				["editBoxPosition"] = "ABOVE_CHAT",
			},
			["unitframe"] = {
				["statusbar"] = "Polished Wood",
				["colors"] = {
					["auraBarBuff"] = {
						["r"] = 0.3098039215686275,
						["g"] = 0.07843137254901961,
						["b"] = 0.09411764705882353,
					},
					["health"] = {
						["b"] = 0.2352941176470588,
						["g"] = 0.2352941176470588,
						["r"] = 0.2352941176470588,
					},
					["castColor"] = {
						["b"] = 0.1,
						["g"] = 0.1,
						["r"] = 0.1,
					},
					["transparentHealth"] = true,
					["transparentPower"] = true,
				},
				["fontOutline"] = "OUTLINE",
				["font"] = "Doris PP",
				["units"] = {
					["tank"] = {
						["enable"] = false,
					},
					["pet"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["pettarget"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["raid10"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["anchorPoint"] = "TOPRIGHT",
							["sizeOverride"] = 21,
							["xOffset"] = -4,
							["enable"] = true,
							["yOffset"] = -7,
						},
						["power"] = {
							["width"] = "inset",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["yOffset"] = -7,
								["text_format"] = "[healthcolor][health:deficit]",
								["size"] = 10,
							},
						},
						["rdebuffs"] = {
							["enable"] = false,
						},
						["roleIcon"] = {
							["enable"] = false,
						},
						["growthDirection"] = "LEFT_UP",
						["health"] = {
							["frequentUpdates"] = true,
							["text_format"] = "",
						},
						["buffs"] = {
							["noConsolidated"] = false,
							["sizeOverride"] = 22,
							["useBlacklist"] = false,
							["xOffset"] = 30,
							["playerOnly"] = false,
							["yOffset"] = 28,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["enable"] = true,
							["useFilter"] = "TurtleBuffs",
							["perrow"] = 1,
							["noDuration"] = false,
						},
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort]",
						},
						["positionOverride"] = "BOTTOMRIGHT",
						["height"] = 45,
						["verticalSpacing"] = 4,
						["healPrediction"] = true,
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["size"] = 13,
							["xOffset"] = 9,
							["yOffset"] = 0,
						},
					},
					["focustarget"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["targettarget"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["player"] = {
						["debuffs"] = {
							["attachTo"] = "BUFFS",
						},
						["portrait"] = {
							["enable"] = true,
							["overlay"] = true,
						},
						["castbar"] = {
							["height"] = 25,
							["width"] = 410,
						},
						["power"] = {
							["width"] = "inset",
						},
						["buffs"] = {
							["enable"] = true,
							["noDuration"] = false,
							["attachTo"] = "FRAME",
						},
						["classbar"] = {
							["enable"] = false,
						},
						["aurabar"] = {
							["enable"] = false,
						},
					},
					["target"] = {
						["power"] = {
							["width"] = "inset",
						},
						["portrait"] = {
							["enable"] = true,
							["overlay"] = true,
						},
						["aurabar"] = {
							["enable"] = false,
						},
					},
					["party"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["anchorPoint"] = "TOPRIGHT",
							["sizeOverride"] = 21,
							["xOffset"] = -4,
							["yOffset"] = -7,
						},
						["growthDirection"] = "LEFT_UP",
						["buffIndicator"] = {
							["size"] = 10,
						},
						["roleIcon"] = {
							["enable"] = false,
						},
						["targetsGroup"] = {
							["anchorPoint"] = "BOTTOM",
						},
						["GPSArrow"] = {
							["size"] = 40,
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["yOffset"] = -7,
								["text_format"] = "[healthcolor][health:deficit]",
								["size"] = 10,
							},
						},
						["healPrediction"] = true,
						["width"] = 80,
						["power"] = {
							["text_format"] = "",
							["width"] = "inset",
						},
						["health"] = {
							["text_format"] = "",
							["frequentUpdates"] = true,
							["position"] = "BOTTOM",
						},
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort] [difficultycolor][smartlevel]",
							["position"] = "TOP",
						},
						["buffs"] = {
							["noConsolidated"] = false,
							["sizeOverride"] = 22,
							["useBlacklist"] = false,
							["xOffset"] = 30,
							["playerOnly"] = false,
							["yOffset"] = 28,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["enable"] = true,
							["useFilter"] = "TurtleBuffs",
							["perrow"] = 1,
							["noDuration"] = false,
						},
						["height"] = 45,
						["verticalSpacing"] = 1,
						["petsGroup"] = {
							["anchorPoint"] = "BOTTOM",
						},
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["size"] = 13,
							["xOffset"] = 9,
							["yOffset"] = 0,
						},
					},
					["raid40"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["sizeOverride"] = 21,
							["useBlacklist"] = false,
							["xOffset"] = -4,
							["yOffset"] = -9,
							["anchorPoint"] = "TOPRIGHT",
							["clickThrough"] = true,
							["enable"] = true,
							["useFilter"] = "Blacklist",
							["perrow"] = 2,
						},
						["power"] = {
							["enable"] = true,
							["position"] = "CENTER",
							["width"] = "inset",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["yOffset"] = -7,
								["text_format"] = "[healthcolor][health:deficit]",
								["size"] = 10,
							},
						},
						["rdebuffs"] = {
							["size"] = 26,
						},
						["growthDirection"] = "UP_LEFT",
						["healPrediction"] = true,
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort]",
							["position"] = "TOP",
						},
						["health"] = {
							["frequentUpdates"] = true,
						},
						["verticalSpacing"] = 1,
						["height"] = 43,
						["buffs"] = {
							["noConsolidated"] = false,
							["sizeOverride"] = 17,
							["useBlacklist"] = false,
							["xOffset"] = 21,
							["playerOnly"] = false,
							["yOffset"] = 25,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["enable"] = true,
							["useFilter"] = "TurtleBuffs",
							["perrow"] = 1,
							["noDuration"] = false,
						},
						["width"] = 50,
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["size"] = 13,
							["xOffset"] = 9,
							["yOffset"] = 0,
						},
					},
					["focus"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["raid25"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["countFontSize"] = 12,
							["fontSize"] = 9,
							["xOffset"] = -4,
							["enable"] = true,
							["sizeOverride"] = 21,
							["anchorPoint"] = "TOPRIGHT",
							["yOffset"] = -7,
						},
						["power"] = {
							["position"] = "CENTER",
							["width"] = "inset",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["yOffset"] = -7,
								["text_format"] = "[healthcolor][health:deficit]",
								["size"] = 10,
							},
						},
						["rdebuffs"] = {
							["enable"] = false,
						},
						["growthDirection"] = "UP_LEFT",
						["roleIcon"] = {
							["enable"] = false,
						},
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort]",
						},
						["health"] = {
							["frequentUpdates"] = true,
							["text_format"] = "",
						},
						["verticalSpacing"] = 4,
						["height"] = 45,
						["buffs"] = {
							["noConsolidated"] = false,
							["sizeOverride"] = 22,
							["useBlacklist"] = false,
							["xOffset"] = 30,
							["playerOnly"] = false,
							["yOffset"] = 28,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["enable"] = true,
							["useFilter"] = "TurtleBuffs",
							["perrow"] = 1,
							["noDuration"] = false,
						},
						["healPrediction"] = true,
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["size"] = 13,
							["xOffset"] = 9,
							["yOffset"] = 0,
						},
					},
					["arena"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["assist"] = {
						["enable"] = false,
						["targetsGroup"] = {
							["enable"] = false,
						},
					},
					["boss"] = {
						["portrait"] = {
							["enable"] = true,
							["overlay"] = true,
						},
						["power"] = {
							["width"] = "inset",
						},
					},
				},
			},
			["datatexts"] = {
				["panels"] = {
					["RightChatDataPanel"] = {
						["right"] = "WeakAuras",
						["left"] = "Skada",
						["middle"] = "Combat Time",
					},
					["Top_Center"] = "Spec Switch",
					["Bottom_Panel"] = "Bags",
					["DP_6"] = {
						["right"] = "Gold",
						["left"] = "System",
						["middle"] = "Time",
					},
					["LeftChatDataPanel"] = {
						["left"] = "",
						["right"] = "",
					},
				},
				["fontOutline"] = "None",
			},
			["actionbar"] = {
				["bar3"] = {
					["backdrop"] = true,
					["buttonsPerRow"] = 3,
				},
				["bar2"] = {
					["enabled"] = true,
					["backdrop"] = true,
					["heightMult"] = 2,
				},
				["stanceBar"] = {
					["buttonsPerRow"] = 1,
				},
				["bar5"] = {
					["backdrop"] = true,
					["buttonsPerRow"] = 3,
				},
				["bar4"] = {
					["point"] = "BOTTOMLEFT",
					["buttonsPerRow"] = 6,
					["backdrop"] = false,
					["mouseover"] = true,
				},
			},
			["layoutSet"] = "dpsMelee",
			["general"] = {
				["threat"] = {
					["position"] = "LEFTCHAT",
				},
				["autoAcceptInvite"] = true,
				["autoRoll"] = true,
				["autoRepair"] = "GUILD",
				["vendorGrays"] = true,
				["bottomPanel"] = false,
				["backdropfadecolor"] = {
					["b"] = 0.054,
					["g"] = 0.054,
					["r"] = 0.054,
				},
				["valuecolor"] = {
					["b"] = 0.819,
					["g"] = 0.513,
					["r"] = 0.09,
				},
				["BUFFS"] = {
				},
				["health"] = {
				},
				["topPanel"] = false,
			},
		},
		["Plebeian - Area 52"] = {
			["sle"] = {
				["datatext"] = {
					["dp6"] = {
						["enabled"] = true,
						["width"] = 410,
					},
					["top"] = {
						["width"] = 104,
					},
					["bottom"] = {
						["enabled"] = true,
						["width"] = 104,
					},
				},
			},
			["movers"] = {
				["DP_6_Mover"] = "BOTTOMElvUIParentBOTTOM04",
				["ElvUF_Raid40Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4200",
				["ElvUF_PlayerCastbarMover"] = "BOTTOMElvUIParentBOTTOM0100",
				["ElvAB_1"] = "BOTTOMElvUIParentBOTTOM060",
				["LeftChatMover"] = "BOTTOMLEFTUIParentBOTTOMLEFT021",
				["ElvAB_4"] = "BOTTOMLEFTElvUIParentBOTTOMRIGHT-413200",
				["ElvUF_Raid10Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4200",
				["BossButton"] = "CENTERElvUIParentCENTER-413188",
				["ElvAB_5"] = "BOTTOMElvUIParentBOTTOM-26027",
				["ElvUF_TargetTargetMover"] = "BOTTOMElvUIParentBOTTOM0190",
				["Bottom_Panel_Mover"] = "BOTTOMElvUIParentBOTTOM2604",
				["ElvAB_3"] = "BOTTOMElvUIParentBOTTOM26027",
				["RightChatMover"] = "BOTTOMRIGHTUIParentBOTTOMRIGHT021",
				["ShiftAB"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT41421",
				["ElvUF_PlayerMover"] = "BOTTOMElvUIParentBOTTOM-278200",
				["ElvUF_FocusMover"] = "BOTTOMElvUIParentBOTTOM-63436",
				["ArenaHeaderMover"] = "TOPRIGHTElvUIParentTOPRIGHT-210-410",
				["ElvUF_PetMover"] = "BOTTOMElvUIParentBOTTOM0230",
				["Top_Center_Mover"] = "BOTTOMElvUIParentBOTTOM-2604",
				["BossHeaderMover"] = "BOTTOMRIGHTElvUIParentBOTTOMRIGHT-210435",
				["TotemBarMover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT41421",
				["ElvUF_Raid25Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4200",
				["ElvUF_PartyMover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4200",
				["ElvAB_2"] = "BOTTOMElvUIParentBOTTOM027",
				["PetAB"] = "RIGHTElvUIParentRIGHT00",
				["ElvUF_TargetMover"] = "BOTTOMElvUIParentBOTTOM278200",
			},
			["gridSize"] = 110,
			["tooltip"] = {
				["style"] = "inset",
			},
			["hideTutorial"] = 1,
			["chat"] = {
				["emotionIcons"] = false,
				["editBoxPosition"] = "ABOVE_CHAT",
			},
			["unitframe"] = {
				["font"] = "Doris PP",
				["colors"] = {
					["auraBarBuff"] = {
						["r"] = 0.3098039215686275,
						["g"] = 0.07843137254901961,
						["b"] = 0.09411764705882353,
					},
					["health"] = {
						["b"] = 0.2352941176470588,
						["g"] = 0.2352941176470588,
						["r"] = 0.2352941176470588,
					},
					["castColor"] = {
						["b"] = 0.1,
						["g"] = 0.1,
						["r"] = 0.1,
					},
					["transparentHealth"] = true,
					["transparentPower"] = true,
				},
				["fontOutline"] = "OUTLINE",
				["statusbar"] = "Polished Wood",
				["units"] = {
					["tank"] = {
						["enable"] = false,
					},
					["targettarget"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["pet"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["raid10"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["anchorPoint"] = "TOPRIGHT",
							["sizeOverride"] = 21,
							["xOffset"] = -4,
							["enable"] = true,
							["yOffset"] = -7,
						},
						["power"] = {
							["width"] = "inset",
						},
						["positionOverride"] = "BOTTOMRIGHT",
						["rdebuffs"] = {
							["enable"] = false,
						},
						["roleIcon"] = {
							["enable"] = false,
						},
						["growthDirection"] = "LEFT_UP",
						["healPrediction"] = true,
						["buffs"] = {
							["noConsolidated"] = false,
							["sizeOverride"] = 22,
							["useBlacklist"] = false,
							["enable"] = true,
							["playerOnly"] = false,
							["yOffset"] = 28,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["noDuration"] = false,
							["perrow"] = 1,
							["useFilter"] = "TurtleBuffs",
							["xOffset"] = 30,
						},
						["health"] = {
							["frequentUpdates"] = true,
							["text_format"] = "",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["yOffset"] = -7,
								["text_format"] = "[healthcolor][health:deficit]",
								["size"] = 10,
							},
						},
						["height"] = 45,
						["verticalSpacing"] = 4,
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort]",
						},
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["size"] = 13,
							["xOffset"] = 9,
							["yOffset"] = 0,
						},
					},
					["focustarget"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["pettarget"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["player"] = {
						["debuffs"] = {
							["attachTo"] = "BUFFS",
						},
						["portrait"] = {
							["enable"] = true,
							["overlay"] = true,
						},
						["power"] = {
							["width"] = "inset",
						},
						["castbar"] = {
							["height"] = 25,
							["width"] = 410,
						},
						["buffs"] = {
							["enable"] = true,
							["attachTo"] = "FRAME",
							["noDuration"] = false,
						},
						["classbar"] = {
							["enable"] = false,
						},
						["aurabar"] = {
							["enable"] = false,
						},
					},
					["target"] = {
						["aurabar"] = {
							["enable"] = false,
						},
						["portrait"] = {
							["enable"] = true,
							["overlay"] = true,
						},
						["power"] = {
							["width"] = "inset",
						},
					},
					["party"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["anchorPoint"] = "TOPRIGHT",
							["sizeOverride"] = 21,
							["xOffset"] = -4,
							["yOffset"] = -7,
						},
						["growthDirection"] = "LEFT_UP",
						["buffIndicator"] = {
							["size"] = 10,
						},
						["roleIcon"] = {
							["enable"] = false,
						},
						["targetsGroup"] = {
							["anchorPoint"] = "BOTTOM",
						},
						["power"] = {
							["text_format"] = "",
							["width"] = "inset",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["yOffset"] = -7,
								["text_format"] = "[healthcolor][health:deficit]",
								["size"] = 10,
							},
						},
						["healPrediction"] = true,
						["width"] = 80,
						["GPSArrow"] = {
							["size"] = 40,
						},
						["health"] = {
							["frequentUpdates"] = true,
							["text_format"] = "",
							["position"] = "BOTTOM",
						},
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort] [difficultycolor][smartlevel]",
							["position"] = "TOP",
						},
						["buffs"] = {
							["noConsolidated"] = false,
							["sizeOverride"] = 22,
							["useBlacklist"] = false,
							["enable"] = true,
							["playerOnly"] = false,
							["yOffset"] = 28,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["noDuration"] = false,
							["perrow"] = 1,
							["useFilter"] = "TurtleBuffs",
							["xOffset"] = 30,
						},
						["height"] = 45,
						["verticalSpacing"] = 1,
						["petsGroup"] = {
							["anchorPoint"] = "BOTTOM",
						},
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["size"] = 13,
							["xOffset"] = 9,
							["yOffset"] = 0,
						},
					},
					["raid40"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["sizeOverride"] = 21,
							["useBlacklist"] = false,
							["enable"] = true,
							["yOffset"] = -9,
							["anchorPoint"] = "TOPRIGHT",
							["clickThrough"] = true,
							["perrow"] = 2,
							["useFilter"] = "Blacklist",
							["xOffset"] = -4,
						},
						["power"] = {
							["enable"] = true,
							["width"] = "inset",
							["position"] = "CENTER",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["yOffset"] = -7,
								["text_format"] = "[healthcolor][health:deficit]",
								["size"] = 10,
							},
						},
						["rdebuffs"] = {
							["size"] = 26,
						},
						["growthDirection"] = "UP_LEFT",
						["healPrediction"] = true,
						["width"] = 50,
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort]",
							["position"] = "TOP",
						},
						["verticalSpacing"] = 1,
						["height"] = 43,
						["buffs"] = {
							["noConsolidated"] = false,
							["sizeOverride"] = 17,
							["useBlacklist"] = false,
							["enable"] = true,
							["playerOnly"] = false,
							["yOffset"] = 25,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["noDuration"] = false,
							["perrow"] = 1,
							["useFilter"] = "TurtleBuffs",
							["xOffset"] = 21,
						},
						["health"] = {
							["frequentUpdates"] = true,
						},
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["size"] = 13,
							["xOffset"] = 9,
							["yOffset"] = 0,
						},
					},
					["focus"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["raid25"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["countFontSize"] = 12,
							["fontSize"] = 9,
							["xOffset"] = -4,
							["enable"] = true,
							["anchorPoint"] = "TOPRIGHT",
							["sizeOverride"] = 21,
							["yOffset"] = -7,
						},
						["power"] = {
							["width"] = "inset",
							["position"] = "CENTER",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["yOffset"] = -7,
								["text_format"] = "[healthcolor][health:deficit]",
								["size"] = 10,
							},
						},
						["rdebuffs"] = {
							["enable"] = false,
						},
						["growthDirection"] = "UP_LEFT",
						["roleIcon"] = {
							["enable"] = false,
						},
						["healPrediction"] = true,
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort]",
						},
						["verticalSpacing"] = 4,
						["height"] = 45,
						["buffs"] = {
							["noConsolidated"] = false,
							["sizeOverride"] = 22,
							["useBlacklist"] = false,
							["enable"] = true,
							["playerOnly"] = false,
							["yOffset"] = 28,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["noDuration"] = false,
							["perrow"] = 1,
							["useFilter"] = "TurtleBuffs",
							["xOffset"] = 30,
						},
						["health"] = {
							["frequentUpdates"] = true,
							["text_format"] = "",
						},
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["size"] = 13,
							["xOffset"] = 9,
							["yOffset"] = 0,
						},
					},
					["arena"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["assist"] = {
						["enable"] = false,
						["targetsGroup"] = {
							["enable"] = false,
						},
					},
					["boss"] = {
						["portrait"] = {
							["enable"] = true,
							["overlay"] = true,
						},
						["power"] = {
							["width"] = "inset",
						},
					},
				},
			},
			["datatexts"] = {
				["panels"] = {
					["RightChatDataPanel"] = {
						["right"] = "WeakAuras",
						["left"] = "Skada",
						["middle"] = "Combat Time",
					},
					["Top_Center"] = "Spec Switch",
					["Bottom_Panel"] = "Bags",
					["DP_6"] = {
						["right"] = "Gold",
						["left"] = "System",
						["middle"] = "Time",
					},
					["LeftChatDataPanel"] = {
						["left"] = "Spell/Heal Power",
						["right"] = "Haste",
					},
				},
				["fontOutline"] = "None",
			},
			["actionbar"] = {
				["bar3"] = {
					["backdrop"] = true,
					["buttonsPerRow"] = 3,
				},
				["bar2"] = {
					["enabled"] = true,
					["backdrop"] = true,
					["heightMult"] = 2,
				},
				["stanceBar"] = {
					["buttonsPerRow"] = 1,
				},
				["bar5"] = {
					["backdrop"] = true,
					["buttonsPerRow"] = 3,
				},
				["bar4"] = {
					["mouseover"] = true,
					["buttonsPerRow"] = 6,
					["backdrop"] = false,
					["point"] = "BOTTOMLEFT",
				},
			},
			["layoutSet"] = "dpsCaster",
			["general"] = {
				["threat"] = {
					["position"] = "LEFTCHAT",
				},
				["autoAcceptInvite"] = true,
				["autoRoll"] = true,
				["autoRepair"] = "GUILD",
				["topPanel"] = false,
				["bottomPanel"] = false,
				["backdropfadecolor"] = {
					["b"] = 0.054,
					["g"] = 0.054,
					["r"] = 0.054,
				},
				["valuecolor"] = {
					["b"] = 0.819,
					["g"] = 0.513,
					["r"] = 0.09,
				},
				["BUFFS"] = {
				},
				["health"] = {
				},
				["vendorGrays"] = true,
			},
		},
		["Mooselini - Area 52"] = {
			["sle"] = {
				["datatext"] = {
					["bottom"] = {
						["enabled"] = true,
						["width"] = 104,
					},
					["dp6"] = {
						["enabled"] = true,
						["width"] = 410,
					},
					["top"] = {
						["width"] = 104,
					},
				},
			},
			["movers"] = {
				["DP_6_Mover"] = "BOTTOMElvUIParentBOTTOM04",
				["ElvUF_Raid40Mover"] = "TOPLEFTElvUIParentTOPLEFT335-369",
				["ElvUF_PlayerCastbarMover"] = "BOTTOMElvUIParentBOTTOM0100",
				["ElvAB_1"] = "BOTTOMElvUIParentBOTTOM060",
				["ElvAB_2"] = "BOTTOMElvUIParentBOTTOM027",
				["ElvAB_4"] = "BOTTOMLEFTElvUIParentBOTTOMRIGHT-413200",
				["ElvUF_Raid10Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT311450",
				["ElvAB_3"] = "BOTTOMElvUIParentBOTTOM26027",
				["ElvAB_5"] = "BOTTOMElvUIParentBOTTOM-26027",
				["ElvUF_TargetMover"] = "BOTTOMElvUIParentBOTTOM278200",
				["PetAB"] = "RIGHTElvUIParentRIGHT00",
				["LeftChatMover"] = "BOTTOMLEFTUIParentBOTTOMLEFT021",
				["ElvUF_PartyMover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT311450",
				["ShiftAB"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT41421",
				["TotemBarMover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT41421",
				["ElvUF_FocusMover"] = "BOTTOMElvUIParentBOTTOM-63436",
				["ArenaHeaderMover"] = "TOPRIGHTElvUIParentTOPRIGHT-210-410",
				["ElvUF_PetMover"] = "BOTTOMElvUIParentBOTTOM0230",
				["Top_Center_Mover"] = "BOTTOMElvUIParentBOTTOM-2604",
				["BossHeaderMover"] = "BOTTOMRIGHTElvUIParentBOTTOMRIGHT-210435",
				["ElvUF_PlayerMover"] = "BOTTOMElvUIParentBOTTOM-278200",
				["ElvUF_Raid25Mover"] = "TOPLEFTElvUIParentTOPLEFT311-369",
				["RightChatMover"] = "BOTTOMRIGHTUIParentBOTTOMRIGHT021",
				["Bottom_Panel_Mover"] = "BOTTOMElvUIParentBOTTOM2604",
				["BossButton"] = "CENTERElvUIParentCENTER-413188",
				["ElvUF_TargetTargetMover"] = "BOTTOMElvUIParentBOTTOM0190",
			},
			["gridSize"] = 110,
			["tooltip"] = {
				["style"] = "inset",
			},
			["hideTutorial"] = 1,
			["chat"] = {
				["editBoxPosition"] = "ABOVE_CHAT",
				["emotionIcons"] = false,
			},
			["unitframe"] = {
				["units"] = {
					["tank"] = {
						["enable"] = false,
					},
					["boss"] = {
						["portrait"] = {
							["enable"] = true,
							["overlay"] = true,
						},
						["power"] = {
							["width"] = "inset",
						},
					},
					["assist"] = {
						["targetsGroup"] = {
							["enable"] = false,
						},
						["enable"] = false,
					},
					["raid10"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["sizeOverride"] = 21,
							["xOffset"] = -4,
							["yOffset"] = -7,
							["anchorPoint"] = "TOPRIGHT",
							["enable"] = true,
						},
						["rdebuffs"] = {
							["enable"] = false,
						},
						["growthDirection"] = "LEFT_UP",
						["health"] = {
							["frequentUpdates"] = true,
							["text_format"] = "",
						},
						["roleIcon"] = {
							["enable"] = false,
						},
						["power"] = {
							["width"] = "inset",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["size"] = 10,
								["text_format"] = "[healthcolor][health:deficit]",
								["yOffset"] = -7,
							},
						},
						["healPrediction"] = true,
						["positionOverride"] = "BOTTOMRIGHT",
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort]",
						},
						["verticalSpacing"] = 4,
						["height"] = 45,
						["buffs"] = {
							["xOffset"] = 30,
							["yOffset"] = 28,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["useBlacklist"] = false,
							["noDuration"] = false,
							["playerOnly"] = false,
							["perrow"] = 1,
							["useFilter"] = "TurtleBuffs",
							["noConsolidated"] = false,
							["sizeOverride"] = 22,
							["enable"] = true,
						},
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["xOffset"] = 9,
							["yOffset"] = 0,
							["size"] = 13,
						},
					},
					["focustarget"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["pettarget"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["party"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["sizeOverride"] = 21,
							["yOffset"] = -7,
							["anchorPoint"] = "TOPRIGHT",
							["xOffset"] = -4,
						},
						["growthDirection"] = "LEFT_UP",
						["GPSArrow"] = {
							["size"] = 40,
						},
						["buffIndicator"] = {
							["size"] = 10,
						},
						["roleIcon"] = {
							["enable"] = false,
							["position"] = "BOTTOMRIGHT",
						},
						["targetsGroup"] = {
							["anchorPoint"] = "BOTTOM",
						},
						["power"] = {
							["text_format"] = "",
							["width"] = "inset",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["size"] = 10,
								["text_format"] = "[healthcolor][health:deficit]",
								["yOffset"] = -7,
							},
						},
						["healPrediction"] = true,
						["width"] = 80,
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort] [difficultycolor][smartlevel]",
							["position"] = "TOP",
						},
						["health"] = {
							["frequentUpdates"] = true,
							["position"] = "BOTTOM",
							["text_format"] = "",
						},
						["verticalSpacing"] = 1,
						["height"] = 45,
						["buffs"] = {
							["xOffset"] = 30,
							["yOffset"] = 28,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["useBlacklist"] = false,
							["noDuration"] = false,
							["playerOnly"] = false,
							["perrow"] = 1,
							["useFilter"] = "TurtleBuffs",
							["noConsolidated"] = false,
							["sizeOverride"] = 22,
							["enable"] = true,
						},
						["petsGroup"] = {
							["anchorPoint"] = "BOTTOM",
						},
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["xOffset"] = 9,
							["yOffset"] = 0,
							["size"] = 13,
						},
					},
					["raid25"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["countFontSize"] = 12,
							["fontSize"] = 9,
							["enable"] = true,
							["yOffset"] = -7,
							["anchorPoint"] = "TOPRIGHT",
							["sizeOverride"] = 21,
							["xOffset"] = -4,
						},
						["rdebuffs"] = {
							["enable"] = false,
						},
						["growthDirection"] = "UP_LEFT",
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort]",
						},
						["roleIcon"] = {
							["enable"] = false,
						},
						["power"] = {
							["width"] = "inset",
							["position"] = "CENTER",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["size"] = 10,
								["text_format"] = "[healthcolor][health:deficit]",
								["yOffset"] = -7,
							},
						},
						["healPrediction"] = true,
						["health"] = {
							["frequentUpdates"] = true,
							["text_format"] = "",
						},
						["buffs"] = {
							["xOffset"] = 30,
							["yOffset"] = 28,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["useBlacklist"] = false,
							["noDuration"] = false,
							["playerOnly"] = false,
							["perrow"] = 1,
							["useFilter"] = "TurtleBuffs",
							["noConsolidated"] = false,
							["sizeOverride"] = 22,
							["enable"] = true,
						},
						["height"] = 45,
						["verticalSpacing"] = 4,
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["xOffset"] = 9,
							["yOffset"] = 0,
							["size"] = 13,
						},
					},
					["player"] = {
						["debuffs"] = {
							["attachTo"] = "BUFFS",
						},
						["portrait"] = {
							["enable"] = true,
							["overlay"] = true,
						},
						["classbar"] = {
							["enable"] = false,
						},
						["aurabar"] = {
							["enable"] = false,
						},
						["castbar"] = {
							["width"] = 410,
							["height"] = 25,
						},
						["buffs"] = {
							["enable"] = true,
							["attachTo"] = "FRAME",
							["noDuration"] = false,
						},
						["power"] = {
							["width"] = "inset",
						},
					},
					["raid40"] = {
						["horizontalSpacing"] = 1,
						["debuffs"] = {
							["xOffset"] = -4,
							["yOffset"] = -9,
							["anchorPoint"] = "TOPRIGHT",
							["clickThrough"] = true,
							["perrow"] = 2,
							["useFilter"] = "Blacklist",
							["sizeOverride"] = 21,
							["useBlacklist"] = false,
							["enable"] = true,
						},
						["rdebuffs"] = {
							["size"] = 26,
						},
						["growthDirection"] = "UP_LEFT",
						["name"] = {
							["text_format"] = "[namecolor][name:veryshort]",
							["position"] = "TOP",
						},
						["power"] = {
							["enable"] = true,
							["width"] = "inset",
							["position"] = "CENTER",
						},
						["customTexts"] = {
							["Health Text"] = {
								["font"] = "Doris PP",
								["justifyH"] = "CENTER",
								["fontOutline"] = "OUTLINE",
								["xOffset"] = 0,
								["size"] = 10,
								["text_format"] = "[healthcolor][health:deficit]",
								["yOffset"] = -7,
							},
						},
						["healPrediction"] = true,
						["width"] = 50,
						["health"] = {
							["frequentUpdates"] = true,
						},
						["buffs"] = {
							["xOffset"] = 21,
							["yOffset"] = 25,
							["anchorPoint"] = "BOTTOMLEFT",
							["clickThrough"] = true,
							["useBlacklist"] = false,
							["noDuration"] = false,
							["playerOnly"] = false,
							["perrow"] = 1,
							["useFilter"] = "TurtleBuffs",
							["noConsolidated"] = false,
							["sizeOverride"] = 17,
							["enable"] = true,
						},
						["height"] = 43,
						["verticalSpacing"] = 1,
						["raidicon"] = {
							["attachTo"] = "LEFT",
							["xOffset"] = 9,
							["yOffset"] = 0,
							["size"] = 13,
						},
					},
					["focus"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["target"] = {
						["portrait"] = {
							["enable"] = true,
							["overlay"] = true,
						},
						["aurabar"] = {
							["enable"] = false,
						},
						["power"] = {
							["width"] = "inset",
						},
					},
					["arena"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["pet"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
					["targettarget"] = {
						["power"] = {
							["width"] = "inset",
						},
					},
				},
				["statusbar"] = "Polished Wood",
				["colors"] = {
					["auraBarBuff"] = {
						["b"] = 0.09411764705882353,
						["g"] = 0.07843137254901961,
						["r"] = 0.3098039215686275,
					},
					["transparentPower"] = true,
					["castColor"] = {
						["r"] = 0.1,
						["g"] = 0.1,
						["b"] = 0.1,
					},
					["health"] = {
						["r"] = 0.2352941176470588,
						["g"] = 0.2352941176470588,
						["b"] = 0.2352941176470588,
					},
					["transparentHealth"] = true,
				},
				["fontOutline"] = "OUTLINE",
				["font"] = "Doris PP",
			},
			["datatexts"] = {
				["panels"] = {
					["RightChatDataPanel"] = {
						["right"] = "WeakAuras",
						["left"] = "Skada",
						["middle"] = "Combat Time",
					},
					["LeftChatDataPanel"] = {
						["right"] = "Haste",
						["left"] = "Spell/Heal Power",
					},
					["Top_Center"] = "Spec Switch",
					["Bottom_Panel"] = "Bags",
					["DP_6"] = {
						["right"] = "Gold",
						["left"] = "System",
						["middle"] = "Time",
					},
				},
				["fontOutline"] = "None",
			},
			["actionbar"] = {
				["bar3"] = {
					["buttonsPerRow"] = 3,
					["backdrop"] = true,
				},
				["bar2"] = {
					["enabled"] = true,
					["backdrop"] = true,
					["heightMult"] = 2,
				},
				["bar5"] = {
					["buttonsPerRow"] = 3,
					["backdrop"] = true,
				},
				["stanceBar"] = {
					["buttonsPerRow"] = 1,
				},
				["bar4"] = {
					["point"] = "BOTTOMLEFT",
					["mouseover"] = true,
					["buttonsPerRow"] = 6,
					["backdrop"] = false,
				},
			},
			["layoutSet"] = "healer",
			["general"] = {
				["autoAcceptInvite"] = true,
				["autoRepair"] = "GUILD",
				["bottomPanel"] = false,
				["backdropfadecolor"] = {
					["r"] = 0.054,
					["g"] = 0.054,
					["b"] = 0.054,
				},
				["valuecolor"] = {
					["r"] = 0.09,
					["g"] = 0.513,
					["b"] = 0.819,
				},
				["threat"] = {
					["position"] = "LEFTCHAT",
				},
				["topPanel"] = false,
				["autoRoll"] = true,
				["health"] = {
				},
				["BUFFS"] = {
				},
				["vendorGrays"] = true,
			},
		},
		["Esoom - Garona"] = {
			["movers"] = {
				["ElvUF_Raid40Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4195",
				["ElvUF_Raid25Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4195",
				["ElvUF_PartyMover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4195",
				["RightChatMover"] = "BOTTOMRIGHTUIParentBOTTOMRIGHT019",
				["LeftChatMover"] = "BOTTOMLEFTUIParentBOTTOMLEFT019",
				["ElvUF_Raid10Mover"] = "BOTTOMLEFTElvUIParentBOTTOMLEFT4195",
			},
		},
	},
}
ElvPrivateDB = {
	["profileKeys"] = {
		["Plebe - Area 52"] = "Plebe - Area 52",
		["Plebeian - Area 52"] = "Plebeian - Area 52",
		["Mooselini - Area 52"] = "Mooselini - Area 52",
		["Esoom - Garona"] = "Esoom - Garona",
	},
	["profiles"] = {
		["Plebe - Area 52"] = {
			["skins"] = {
				["addons"] = {
					["AlwaysTrue"] = true,
					["EmbedSkada"] = true,
				},
			},
			["theme"] = "default",
			["general"] = {
				["glossTex"] = "Polished Wood",
				["normTex"] = "Polished Wood",
			},
			["install_complete"] = "5.73",
		},
		["Plebeian - Area 52"] = {
			["skins"] = {
				["addons"] = {
					["EmbedSkada"] = true,
					["AlwaysTrue"] = true,
				},
			},
			["general"] = {
				["normTex"] = "Polished Wood",
				["glossTex"] = "Polished Wood",
			},
			["theme"] = "default",
			["install_complete"] = "5.73",
		},
		["Mooselini - Area 52"] = {
			["general"] = {
				["normTex"] = "Polished Wood",
				["glossTex"] = "Polished Wood",
			},
			["skins"] = {
				["addons"] = {
					["EmbedSkada"] = true,
					["AlwaysTrue"] = true,
				},
			},
			["theme"] = "default",
			["install_complete"] = "5.73",
		},
		["Esoom - Garona"] = {
			["skins"] = {
				["addons"] = {
					["AlwaysTrue"] = true,
				},
			},
		},
	},
}
