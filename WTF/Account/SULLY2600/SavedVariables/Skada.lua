
SkadaDB = {
	["namespaces"] = {
		["LibDualSpec-1.0"] = {
		},
	},
	["profileKeys"] = {
		["Esoom - Garona"] = "Default",
		["Plebe - Area 52"] = "Default",
		["Mooselini - Area 52"] = "Test",
		["Plebeian - Area 52"] = "Default",
		["Ohgirl - Garona"] = "Default",
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
				["Damage_Percent"] = false,
				["Death log_Health"] = false,
				["Damage_Damage"] = false,
				["Damage spell details_Percent"] = true,
				["Death log_Percent"] = false,
				["Deaths_Timestamp"] = false,
				["Threat_Percent"] = false,
			},
			["hidedisables"] = false,
			["windows"] = {
				{
					["barheight"] = 22,
					["barbgcolor"] = {
						["a"] = 0,
						["b"] = 0.3019607843137255,
						["g"] = 0.3019607843137255,
						["r"] = 0.3019607843137255,
					},
					["barcolor"] = {
						["a"] = 0,
						["b"] = 0,
						["g"] = 0,
						["r"] = 0,
					},
					["barfontsize"] = 10,
					["classicons"] = false,
					["clickthrough"] = true,
					["spark"] = false,
					["bartexture"] = "Smooth",
					["barwidth"] = 201.4999542236328,
					["background"] = {
						["color"] = {
							["a"] = 0,
							["b"] = 0,
						},
						["height"] = 161,
						["texture"] = "Blizzard Dialog Background",
					},
					["buttons"] = {
						["segment"] = false,
						["menu"] = false,
						["mode"] = false,
						["report"] = false,
						["reset"] = false,
					},
					["y"] = 5.217475891113281,
					["barfont"] = "SSPro - Semibold",
					["name"] = "HPS",
					["title"] = {
						["color"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["font"] = "ElvUI Font",
						["fontsize"] = 15,
						["texture"] = "Blizzard",
					},
					["enabletitle"] = true,
					["mode"] = "Healing",
					["x"] = 0,
					["point"] = "BOTTOMRIGHT",
				}, -- [1]
			},
			["icon"] = {
				["minimapPos"] = 160.4361246854299,
				["hide"] = true,
			},
			["tooltippos"] = "topleft",
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
					["clickthrough"] = true,
					["set"] = "total",
					["y"] = 5.217475891113281,
					["barfont"] = "SSPro - Semibold",
					["name"] = "HPS",
					["scale"] = 0.9,
					["barcolor"] = {
						["b"] = 0,
						["g"] = 0,
						["r"] = 0,
					},
					["bartexture"] = "Smooth",
					["spark"] = false,
					["buttons"] = {
						["report"] = false,
						["menu"] = false,
						["mode"] = false,
						["segment"] = false,
						["reset"] = false,
					},
					["barwidth"] = 201.4999542236328,
					["mode"] = "DPS",
					["barbgcolor"] = {
						["a"] = 1,
						["b"] = 0.3019607843137255,
						["g"] = 0.3019607843137255,
						["r"] = 0.3019607843137255,
					},
					["point"] = "BOTTOMRIGHT",
					["barfontsize"] = 15,
					["background"] = {
						["color"] = {
							["a"] = 0,
							["b"] = 0,
						},
						["height"] = 161,
						["texture"] = "Blizzard Dialog Background",
					},
					["enabletitle"] = false,
					["x"] = 0,
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
				["Death log_Health"] = false,
				["Damage_Percent"] = false,
				["Damage_Damage"] = false,
				["Damage spell details_Percent"] = true,
				["Deaths_Timestamp"] = false,
				["Death log_Percent"] = false,
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
