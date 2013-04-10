
SkadaDB = {
	["namespaces"] = {
		["LibDualSpec-1.0"] = {
		},
	},
	["profileKeys"] = {
		["Plebe - Area 52"] = "Default",
		["Esoom - Garona"] = "Default",
		["Mooselini - Area 52"] = "Test",
		["Plebeian - Area 52"] = "Default",
	},
	["profiles"] = {
		["Shadow and Light (Affinitii)"] = {
			["windows"] = {
				{
					["barheight"] = 22,
					["classicons"] = false,
					["clickthrough"] = true,
					["y"] = 5.217475891113281,
					["barfont"] = "SSPro - Semibold",
					["name"] = "HPS",
					["barfontsize"] = 10,
					["background"] = {
						["color"] = {
							["a"] = 0,
							["b"] = 0,
						},
						["height"] = 161,
						["texture"] = "Blizzard Dialog Background",
					},
					["bartexture"] = "Smooth",
					["spark"] = false,
					["buttons"] = {
						["segment"] = false,
						["menu"] = false,
						["mode"] = false,
						["report"] = false,
						["reset"] = false,
					},
					["barwidth"] = 201.4999542236328,
					["title"] = {
						["fontsize"] = 15,
						["font"] = "ElvUI Font",
						["color"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["texture"] = "Blizzard",
					},
					["barcolor"] = {
						["a"] = 0,
						["b"] = 0,
						["g"] = 0,
						["r"] = 0,
					},
					["enabletitle"] = true,
					["mode"] = "Healing",
					["barbgcolor"] = {
						["a"] = 0,
						["b"] = 0.3019607843137255,
						["g"] = 0.3019607843137255,
						["r"] = 0.3019607843137255,
					},
					["x"] = 0,
					["point"] = "BOTTOMRIGHT",
				}, -- [1]
			},
			["report"] = {
				["number"] = 12,
				["channel"] = "party",
				["target"] = "Graveblood",
				["mode"] = "Damage taken",
			},
			["icon"] = {
				["minimapPos"] = 160.4361246854299,
				["hide"] = true,
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
			["tooltippos"] = "topleft",
			["hidedisables"] = false,
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
					["background"] = {
						["height"] = 161,
					},
					["barwidth"] = 406.9999084472656,
					["mode"] = "DPS",
					["hidden"] = true,
					["spark"] = false,
				}, -- [1]
			},
		},
		["Test"] = {
			["windows"] = {
				{
					["barheight"] = 22,
					["classicons"] = false,
					["y"] = 5.217475891113281,
					["barfont"] = "SSPro - Semibold",
					["name"] = "HPS",
					["barbgcolor"] = {
						["a"] = 1,
						["b"] = 0.3019607843137255,
						["g"] = 0.3019607843137255,
						["r"] = 0.3019607843137255,
					},
					["point"] = "BOTTOMRIGHT",
					["x"] = 0,
					["spark"] = false,
					["buttons"] = {
						["report"] = false,
						["menu"] = false,
						["mode"] = false,
						["segment"] = false,
						["reset"] = false,
					},
					["barwidth"] = 201.4999542236328,
					["mode"] = "Healing",
					["background"] = {
						["color"] = {
							["a"] = 0,
							["b"] = 0,
						},
						["height"] = 161,
						["texture"] = "Blizzard Dialog Background",
					},
					["barcolor"] = {
						["b"] = 0,
						["g"] = 0,
						["r"] = 0,
					},
					["clickthrough"] = true,
					["barfontsize"] = 10,
					["bartexture"] = "Smooth",
					["title"] = {
						["color"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["font"] = "SSPro - Regular",
						["fontsize"] = 15,
						["texture"] = "Blizzard",
					},
				}, -- [1]
			},
			["report"] = {
				["number"] = 12,
				["target"] = "Graveblood",
				["mode"] = "Damage taken",
				["channel"] = "party",
			},
			["icon"] = {
				["minimapPos"] = 160.4361246854299,
				["hide"] = true,
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
			["tooltippos"] = "topleft",
			["hidedisables"] = false,
			["reset"] = {
				["leave"] = 2,
				["instance"] = 2,
				["join"] = 2,
			},
		},
	},
}
