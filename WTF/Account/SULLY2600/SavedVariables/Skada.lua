
SkadaDB = {
	["namespaces"] = {
		["LibDualSpec-1.0"] = {
		},
	},
	["profileKeys"] = {
		["Esoom - Garona"] = "Default",
		["Plebe - Area 52"] = "Default",
		["Ohgirl - Garona"] = "Default",
		["Plebeian - Area 52"] = "Default",
		["Mooselini - Area 52"] = "Test",
	},
	["profiles"] = {
		["Shadow and Light (Affinitii)"] = {
			["report"] = {
				["number"] = 12,
				["mode"] = "Damage taken",
				["target"] = "Graveblood",
				["channel"] = "party",
			},
			["columns"] = {
				["Deaths_Deaths"] = false,
				["Damage spell details_Damage"] = true,
				["Threat_Threat"] = false,
				["Death log_Change"] = false,
				["Death log_Health"] = false,
				["Damage_Percent"] = false,
				["Damage_Damage"] = false,
				["Damage spell details_Percent"] = true,
				["Deaths_Timestamp"] = false,
				["Death log_Percent"] = false,
				["Threat_Percent"] = false,
			},
			["hidedisables"] = false,
			["windows"] = {
				{
					["barheight"] = 22,
					["barbgcolor"] = {
						["a"] = 0,
						["r"] = 0.3019607843137255,
						["g"] = 0.3019607843137255,
						["b"] = 0.3019607843137255,
					},
					["barcolor"] = {
						["a"] = 0,
						["r"] = 0,
						["g"] = 0,
						["b"] = 0,
					},
					["barfontsize"] = 10,
					["classicons"] = false,
					["clickthrough"] = true,
					["spark"] = false,
					["bartexture"] = "Smooth",
					["barwidth"] = 201.4999542236328,
					["point"] = "BOTTOMRIGHT",
					["x"] = 0,
					["y"] = 5.217475891113281,
					["barfont"] = "SSPro - Semibold",
					["name"] = "HPS",
					["mode"] = "Healing",
					["enabletitle"] = true,
					["title"] = {
						["color"] = {
							["a"] = 0,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
						["font"] = "ElvUI Font",
						["fontsize"] = 15,
						["texture"] = "Blizzard",
					},
					["buttons"] = {
						["segment"] = false,
						["menu"] = false,
						["mode"] = false,
						["report"] = false,
						["reset"] = false,
					},
					["background"] = {
						["color"] = {
							["a"] = 0,
							["b"] = 0,
						},
						["height"] = 161,
						["texture"] = "Blizzard Dialog Background",
					},
				}, -- [1]
			},
			["tooltippos"] = "topleft",
			["icon"] = {
				["minimapPos"] = 160.4361246854299,
				["hide"] = true,
			},
			["reset"] = {
				["leave"] = 2,
				["instance"] = 2,
				["join"] = 2,
			},
		},
		["Default"] = {
			["windows"] = {
				{
					["barslocked"] = true,
					["spark"] = false,
					["barwidth"] = 406.9999084472656,
					["background"] = {
						["height"] = 161,
					},
					["hidden"] = true,
					["mode"] = "DPS",
				}, -- [1]
			},
		},
		["Test"] = {
			["windows"] = {
				{
					["barheight"] = 22,
					["classicons"] = false,
					["clickthrough"] = true,
					["wipemode"] = "DPS",
					["set"] = "total",
					["y"] = 5.217475891113281,
					["x"] = 0,
					["name"] = "HPS",
					["point"] = "BOTTOMRIGHT",
					["scale"] = 0.9,
					["barcolor"] = {
						["r"] = 0,
						["g"] = 0,
						["b"] = 0,
					},
					["mode"] = "DPS",
					["title"] = {
						["color"] = {
							["a"] = 0,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
						["font"] = "SSPro - Regular",
						["fontsize"] = 15,
						["texture"] = "Blizzard",
					},
					["spark"] = false,
					["buttons"] = {
						["report"] = false,
						["menu"] = false,
						["mode"] = false,
						["segment"] = false,
						["reset"] = false,
					},
					["barwidth"] = 201.4999542236328,
					["bartexture"] = "Smooth",
					["barbgcolor"] = {
						["a"] = 1,
						["r"] = 0.3019607843137255,
						["g"] = 0.3019607843137255,
						["b"] = 0.3019607843137255,
					},
					["background"] = {
						["color"] = {
							["a"] = 0,
							["b"] = 0,
						},
						["height"] = 161,
						["texture"] = "Blizzard Dialog Background",
					},
					["barfontsize"] = 15,
					["modeincombat"] = "DPS",
					["barfont"] = "SSPro - Semibold",
				}, -- [1]
			},
			["icon"] = {
				["minimapPos"] = 160.4361246854299,
				["hide"] = true,
			},
			["report"] = {
				["number"] = 12,
				["channel"] = "party",
				["target"] = "Graveblood",
				["mode"] = "Damage taken",
			},
			["columns"] = {
				["Deaths_Deaths"] = false,
				["Damage spell details_Damage"] = true,
				["Threat_Threat"] = false,
				["Death log_Change"] = false,
				["Damage_Percent"] = false,
				["Death log_Health"] = false,
				["Damage_Damage"] = false,
				["Damage spell details_Percent"] = true,
				["Death log_Percent"] = false,
				["Deaths_Timestamp"] = false,
				["Threat_Percent"] = false,
			},
			["hidedisables"] = false,
			["tooltippos"] = "topleft",
			["reset"] = {
				["leave"] = 2,
				["instance"] = 2,
				["join"] = 2,
			},
		},
	},
}
