
FC_Saved = {
}
FX_Saved = {
	["Timers"] = {
	},
	["Healthstone"] = {
		["Mooselini"] = 0,
	},
	["Exceptions"] = {
		["Hellfire Channeler"] = 0,
		["Grand Astromancer Capernian"] = 1,
		["Lord Sanguinar"] = 1,
		["Thaladred the Darkener"] = 1,
		["Fathom-Guard Caribdis"] = 1,
		["Master Engineer Telonicus"] = 1,
		["Fathom-Guard Tidalvess"] = 1,
		["Fathom-Guard Sharkkis"] = 1,
	},
	["Update"] = 173613.387,
	["Profiles"] = {
		["Active"] = 1,
		["Characters"] = {
			["Mooselini-Area 52"] = 1,
		},
		["Links"] = {
		},
		["Data"] = {
			{
				["name"] = "Mooselini-Area 52",
			}, -- [1]
		},
		["Instances"] = {
			{
				["TimerImproveRaidTarget"] = false,
				["OptionsFontLabelColor"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
				["TimerSmooth"] = 5,
				["LinkNoneColor"] = {
					0.5, -- [1]
					0, -- [2]
					1, -- [3]
					0.1, -- [4]
					[0] = false,
				},
				["LoadDelay"] = 1,
				["GlobalScale"] = 1,
				["GlobalLock"] = false,
				["RemoveAfterCombat"] = false,
				["TimerClearcastingSound"] = {
					"Sound\\Spells\\SimonGame_Visual_GameStart.wav", -- [1]
					4, -- [2]
					[0] = false,
				},
				["Delay"] = 0.05,
				["LinkBothColor"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
					0.1, -- [4]
					[0] = true,
				},
				["TimerSmartSpace"] = {
					30, -- [1]
					[0] = true,
				},
				["LinkProfileColor"] = {
					1, -- [1]
					1, -- [2]
					0, -- [3]
					0.1, -- [4]
					[0] = true,
				},
				["OptionsBackdrop"] = {
					"Interface\\AddOns\\Forte_Core\\Textures\\Background", -- [1]
					"Interface\\AddOns\\Forte_Core\\Textures\\Border", -- [2]
					false, -- [3]
					16, -- [4]
					5, -- [5]
					5, -- [6]
				},
				["LinkClone"] = false,
				["DiffCloneColor"] = {
					1, -- [1]
					0.5, -- [2]
					0, -- [3]
					0.2, -- [4]
					[0] = true,
				},
				["MeetingStoneSummon"] = {
					"Summoning >> %s << Clicky clicky!", -- [1]
					[0] = 0,
				},
				["CancelDelay"] = 0.5,
				["DiffBothColor"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
					0.2, -- [4]
					[0] = true,
				},
				["LoadExpandSubcats"] = true,
				["TimerSpellsTooltip"] = true,
				["RightClickOptions"] = true,
				["IgnoreCooldown"] = 2.99,
				["ShowStartupText"] = true,
				["ExpandSubcats"] = false,
				["Font"] = {
					"Fonts\\MORPHEUS.TTF", -- [1]
					10, -- [2]
				},
				["Timer"] = {
					["Active"] = 1,
					["Instance"] = "Timer",
					["Links"] = {
					},
					["Data"] = {
						{
							["name"] = "Spell Timer",
						}, -- [1]
					},
					["Instances"] = {
						{
							["TargetDebuff"] = {
								0, -- [1]
								0.36, -- [2]
								1, -- [3]
								[0] = true,
							},
							["FocusBgColor"] = {
								1, -- [1]
								1, -- [2]
								0.5, -- [3]
								1, -- [4]
								[0] = false,
							},
							["NoTarget"] = false,
							["CustomTag"] = {
								"id target :: spell stacks", -- [1]
								[0] = false,
							},
							["Expand"] = true,
							["HideTime"] = 2,
							["TargetDebuffOther"] = {
								0, -- [1]
								0.18, -- [2]
								0.5, -- [3]
								[0] = false,
							},
							["StacksFont"] = {
								"Fonts\\MORPHEUS.TTF", -- [1]
								10, -- [2]
								"OUTLINE", -- [3]
							},
							["FadeTime"] = 1,
							["NormalColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								1, -- [4]
							},
							["Fail"] = {
								1, -- [1]
								0, -- [2]
								0.3, -- [3]
								[0] = false,
							},
							["y"] = 250,
							["Blink"] = {
								3, -- [1]
								[0] = false,
							},
							["NormalAlpha"] = 0.5,
							["FailTime"] = 1,
							["Bane"] = {
								0, -- [1]
								0.54, -- [2]
								0.42, -- [3]
								[0] = true,
							},
							["GroupID"] = true,
							["Enchant"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								[0] = true,
							},
							["Buff"] = {
								1, -- [1]
								1, -- [2]
								0, -- [3]
								[0] = false,
							},
							["scale"] = 1,
							["Crowd"] = {
								0, -- [1]
								1, -- [2]
								0.5, -- [3]
								[0] = false,
							},
							["TargetColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								1, -- [4]
								[0] = false,
							},
							["IconRight"] = false,
							["Target"] = true,
							["IgnoreLong"] = false,
							["ShowID"] = false,
							["MaximizeName"] = false,
							["TimeRight"] = true,
							["Max"] = {
								10, -- [1]
								[0] = true,
							},
							["Backdrop"] = {
								"Interface\\AddOns\\Forte_Core\\Textures\\Background", -- [1]
								"Interface\\AddOns\\Forte_Core\\Textures\\Border", -- [2]
								false, -- [3]
								16, -- [4]
								5, -- [5]
								3, -- [6]
							},
							["You"] = false,
							["LabelFlip"] = false,
							["Font"] = {
								"Fonts\\MORPHEUS.TTF", -- [1]
								10, -- [2]
							},
							["Name"] = true,
							["Height"] = 16,
							["Label"] = false,
							["Enable"] = true,
							["BarBackgroundAlpha"] = 0.3,
							["Time"] = true,
							["Focus"] = false,
							["TicksNext"] = false,
							["x"] = 683,
							["Texture"] = "Interface\\TargetingFrame\\UI-StatusBar",
							["alpha"] = 1,
							["Spell"] = false,
							["Spark"] = {
								0.3, -- [1]
								[0] = true,
							},
							["lock"] = true,
							["Icon"] = true,
							["IconStacks"] = true,
							["LabelFont"] = {
								"Fonts\\MORPHEUS.TTF", -- [1]
								10, -- [2]
							},
							["Width"] = 400,
							["Hide"] = true,
							["CastSparkGCD"] = true,
							["TargetBgColor"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								0.3, -- [4]
								[0] = false,
							},
							["ExpiredColor"] = {
								0.5, -- [1]
								0.5, -- [2]
								0.5, -- [3]
								1, -- [4]
								[0] = false,
							},
							["Test"] = false,
							["SparkDamage"] = {
								1.5, -- [1]
								[0] = false,
							},
							["Cooldown"] = {
								1, -- [1]
								0.39, -- [2]
								0.35, -- [3]
								[0] = true,
							},
							["FocusColor"] = {
								1, -- [1]
								1, -- [2]
								0.5, -- [3]
								1, -- [4]
								[0] = false,
							},
							["Other"] = true,
							["OneMax"] = true,
							["RaidTargets"] = {
								0.7, -- [1]
								[0] = false,
							},
							["Flip"] = false,
							["SelfDebuffOther"] = {
								0.5, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = false,
							},
							["CooldownOther"] = {
								0.5, -- [1]
								0.2, -- [2]
								0.18, -- [3]
								[0] = false,
							},
							["LabelLimit"] = false,
							["SelfBuffOther"] = {
								0.5, -- [1]
								0.5, -- [2]
								0.5, -- [3]
								[0] = false,
							},
							["HighlightColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								[0] = false,
							},
							["Ticks"] = {
								0.1, -- [1]
								[0] = true,
							},
							["SelfDebuff"] = {
								1, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = true,
							},
							["SelfBuff"] = {
								0, -- [1]
								0.75, -- [2]
								1, -- [3]
								[0] = true,
							},
							["Space"] = 1,
							["Background"] = true,
							["Outwands"] = true,
							["Filter"] = {
								["enter ability/spell/item name"] = {
									[3] = {
										0, -- [1]
										0, -- [2]
										0, -- [3]
										0, -- [4]
									},
								},
							},
							["Channel"] = {
								0.42, -- [1]
								0, -- [2]
								1, -- [3]
								[0] = false,
							},
							["Default"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = true,
							},
							["LabelHeight"] = 18,
							["UnknownTarget"] = false,
							["HideLongerNoBoss"] = false,
							["CastSpark"] = {
								0.1, -- [1]
								[0] = true,
							},
							["Pet"] = {
								1, -- [1]
								0, -- [2]
								0.95, -- [3]
								[0] = false,
							},
							["Curse"] = {
								0.64, -- [1]
								0.21, -- [2]
								0.9300000000000001, -- [3]
								[0] = true,
							},
							["RaidDebuffs"] = false,
							["Heal"] = {
								0, -- [1]
								1, -- [2]
								0, -- [3]
								[0] = false,
							},
							["NormalBgColor"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								0, -- [4]
							},
							["MaxTime"] = {
								30, -- [1]
								[0] = true,
							},
							["SpacingHeight"] = 2,
							["ForceMax"] = false,
							["HideLonger"] = {
								30, -- [1]
								[0] = false,
							},
							["CastSparkTickOverlap"] = true,
						}, -- [1]
					},
				},
				["FrameSnap"] = true,
				["LinkCloneColor"] = {
					1, -- [1]
					0.5, -- [2]
					0, -- [3]
					0.1, -- [4]
					[0] = true,
				},
				["TimerBreakSound"] = {
					"Sound\\Spells\\SimonGame_Visual_LevelStart.wav", -- [1]
					4, -- [2]
					[0] = true,
				},
				["FWOptions"] = {
					["y"] = 309.0550908362802,
					["x"] = 1074.458073891074,
					["lock"] = false,
					["scale"] = 1,
					["alpha"] = 1,
				},
				["Splash"] = {
					["Active"] = 1,
					["Instance"] = "Splash",
					["Links"] = {
					},
					["Data"] = {
						{
							["name"] = "Secondary Splash",
						}, -- [1]
					},
					["Instances"] = {
						{
							["SplashGlow"] = true,
							["SecondSplashMax"] = 4,
							["x"] = 682.6666831970215,
							["lock"] = false,
							["Enable"] = false,
							["y"] = 383.9999658955458,
							["alpha"] = 0.7,
							["scale"] = 2,
						}, -- [1]
					},
				},
				["Cooldown"] = {
					["Active"] = 1,
					["Instance"] = "Cooldown",
					["Links"] = {
					},
					["Data"] = {
						{
							["name"] = "Cooldown Timer",
						}, -- [1]
					},
					["Instances"] = {
						{
							["Soulstone"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = true,
							},
							["Enable"] = true,
							["Loga"] = 0.33,
							["BgColor"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								0, -- [4]
							},
							["Vertical"] = false,
							["HideCombat"] = true,
							["lock"] = false,
							["IconSize"] = {
								32, -- [1]
								[0] = false,
							},
							["AlphaMax"] = 0.2,
							["Texture"] = "Interface\\TargetingFrame\\UI-StatusBar",
							["Spell"] = {
								0.01, -- [1]
								0.01, -- [2]
								0.01, -- [3]
								[0] = true,
							},
							["Spark"] = {
								1, -- [1]
								[0] = false,
							},
							["Tags"] = 6,
							["BuffOther"] = {
								0.5, -- [1]
								0.5, -- [2]
								0.5, -- [3]
								[0] = false,
							},
							["Alpha"] = 0.2,
							["Width"] = 681,
							["DebuffOther"] = {
								0.5, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = false,
							},
							["x"] = 653,
							["Potion"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = true,
							},
							["Filter"] = {
								["enter ability/spell/item name"] = {
									{
										0, -- [1]
										1, -- [2]
										1, -- [3]
										1, -- [4]
									}, -- [1]
								},
								["Recently Bandaged"] = {
									[2] = {
										0, -- [1]
										1, -- [2]
										0.65, -- [3]
										0, -- [4]
									},
								},
							},
							["GroupOverride"] = true,
							["y"] = 85,
							["Hide"] = true,
							["Detail"] = true,
							["Enchant"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = true,
							},
							["Swing"] = false,
							["alpha"] = 1,
							["Flip"] = false,
							["scale"] = 1,
							["IconTime"] = false,
							["Warn"] = true,
							["Powerup"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = true,
							},
							["IconTextColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								1, -- [4]
								[0] = false,
							},
							["IconFont"] = {
								"Fonts\\MORPHEUS.TTF", -- [1]
								10, -- [2]
								"OUTLINE", -- [3]
							},
							["Test"] = false,
							["Splash"] = true,
							["ResTimer"] = {
								1, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = false,
							},
							["Item"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = true,
							},
							["MaxRange"] = {
								600, -- [1]
								[0] = true,
							},
							["Pet"] = {
								1, -- [1]
								0, -- [2]
								0.95, -- [3]
								[0] = false,
							},
							["MinRemaining"] = {
								0, -- [1]
								[0] = false,
							},
							["Ignore"] = true,
							["BarColor"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								0.3, -- [4]
							},
							["MaxRemaining"] = {
								600, -- [1]
								[0] = true,
							},
							["Max"] = 300,
							["TextColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								0.5, -- [4]
							},
							["Backdrop"] = {
								"Interface\\AddOns\\Forte_Core\\Textures\\Background", -- [1]
								"Interface\\AddOns\\Forte_Core\\Textures\\Border", -- [2]
								false, -- [3]
								16, -- [4]
								5, -- [5]
								3, -- [6]
							},
							["CustomTags"] = {
								"0 1 10 30 60 120 300 600", -- [1]
								[0] = true,
							},
							["Healthstone"] = {
								0, -- [1]
								1, -- [2]
								0.5, -- [3]
								[0] = false,
							},
							["Font"] = {
								"Fonts\\MORPHEUS.TTF", -- [1]
								10, -- [2]
							},
							["Internal"] = {
								0, -- [1]
								0.6, -- [2]
								0.85, -- [3]
								[0] = true,
							},
							["SplashFactor"] = 1,
							["Height"] = 32,
							["Buff"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = true,
							},
							["MinRange"] = {
								12, -- [1]
								[0] = true,
							},
							["Debuff"] = {
								1, -- [1]
								0, -- [2]
								0, -- [3]
								[0] = false,
							},
						}, -- [1]
					},
				},
				["UseTokens"] = "pet pettarget vehicle focus mouseover",
				["TimeLeft"] = {
					">> %s on %s is fading in %s <<", -- [1]
					[0] = 1,
				},
				["Texture"] = "Interface\\AddOns\\Forte_Core\\Textures\\Aluminium",
				["FrameSnapDistance"] = 5,
				["AnimateScroll"] = false,
				["Chill"] = 0.05,
				["OptionHeaderColor"] = {
					0.2, -- [1]
					0.2, -- [2]
					0.2, -- [3]
				},
				["TimeLeftNoTarg"] = {
					">> %s is fading in %s <<", -- [1]
					[0] = 1,
				},
				["OptionsHeaderTexture"] = "Interface\\AddOns\\Forte_Core\\Textures\\Otravi",
				["TalentOffsetX"] = 0,
				["TimerColorOverride"] = {
					0.24, -- [1]
					0.24, -- [2]
					0.24, -- [3]
					[0] = false,
				},
				["OptionsHeaderFont"] = {
					"Interface\\AddOns\\Forte_Core\\Fonts\\GOTHICB.TTF", -- [1]
					11, -- [2]
				},
				["TimerResistsColor"] = {
					1, -- [1]
					0, -- [2]
					0.54, -- [3]
					[0] = true,
				},
				["Tips"] = true,
				["FrameDistance"] = 0,
				["OptionBackgroundColor"] = {
					0.18, -- [1]
					0.18, -- [2]
					0.18, -- [3]
					0.9, -- [4]
				},
				["AnimationInterval"] = 0.04,
				["TimerSortOrder"] = "buff selfdebuff debuff cooldown notarget target",
				["TimerStrata"] = "MEDIUM",
				["DiffNoneColor"] = {
					0, -- [1]
					1, -- [2]
					0, -- [3]
					0.2, -- [4]
					[0] = false,
				},
				["TimerFadeSpeed"] = 0.5,
				["GlobalAlpha"] = 1,
				["SpellGroupTips"] = true,
				["DiffProfileColor"] = {
					1, -- [1]
					1, -- [2]
					0, -- [3]
					0.2, -- [4]
					[0] = true,
				},
				["CooldownLeft"] = {
					">> %s is ready in %s <<", -- [1]
					[0] = 1,
				},
				["GlobalSpark"] = {
					0.7, -- [1]
					[0] = true,
				},
				["TimerResistSound"] = {
					"Sound\\Spells\\SimonGame_Visual_BadPress.wav", -- [1]
					1, -- [2]
					[0] = true,
				},
				["TimerFadeSound"] = {
					"Sound\\Spells\\ShaysBell.wav", -- [1]
					2, -- [2]
					[0] = true,
				},
				["OptionsSubHeaderTexture"] = "Interface\\AddOns\\Forte_Core\\Textures\\Minimalist",
				["OutputRaid"] = true,
				["UpdateInterval"] = 0.5,
				["DotTicksDelayNew"] = 1.5,
				["OptionsFontInputColor"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
				["OptionsModuleColor"] = true,
				["OptionsHeight"] = 440,
				["GlobalFrameNames"] = false,
				["CooldownStrata"] = "MEDIUM",
				["OptionsColums"] = 2,
				["SplashStrata"] = "MEDIUM",
				["SpellTimerInterval"] = 0.2,
				["Strata"] = "MEDIUM",
				["TimeFormat"] = true,
				["OptionsFont"] = {
					"Interface\\AddOns\\Forte_Core\\Fonts\\GOTHIC.TTF", -- [1]
					11, -- [2]
				},
				["DisableMouseover"] = false,
				["TalentOffsetY"] = 0,
				["TimerImprove"] = false,
				["LinkProfile"] = false,
				["RightClickIconOptions"] = true,
				["TimerInstantSound"] = {
					"Sound\\Spells\\ShadowWard.wav", -- [1]
					4, -- [2]
					[0] = false,
				},
				["DisableFocus"] = false,
				["Output"] = {
					"MyProChannel", -- [1]
					[0] = true,
				},
			}, -- [1]
		},
	},
	["RAID"] = false,
	["VERSION"] = "v1.980.8",
	["Cooldowns"] = {
	},
	["CATEGORIES"] = {
		["Spell Timer"] = {
			["Fading"] = {
				["expand"] = false,
			},
			["Spell Coloring/Filtering"] = {
				["expand"] = false,
			},
			["Naming and Grouping"] = {
				["expand"] = true,
			},
			["Units"] = {
				["expand"] = true,
			},
			["Visual Casting Aid"] = {
				["expand"] = false,
			},
			["Additional layout"] = {
				["expand"] = true,
			},
			["Frame Sizing"] = {
				["expand"] = false,
			},
			["My Spells"] = {
				["expand"] = false,
			},
			["Frame Appearance"] = {
				["expand"] = true,
			},
			["Maximum Time and Hiding"] = {
				["expand"] = false,
			},
		},
		["Cooldown Timer"] = {
			["Spell Coloring/Filtering"] = {
				["expand"] = true,
			},
			["Specifics"] = {
				["expand"] = false,
			},
			["Time Range"] = {
				["expand"] = false,
			},
			["My Cooldowns"] = {
				["expand"] = true,
			},
			["Splash Icons"] = {
				["expand"] = false,
			},
			["Frame Sizing"] = {
				["expand"] = true,
			},
			["Buffs/Debuffs (on me only)"] = {
				["expand"] = true,
			},
			["Frame Appearance"] = {
				["expand"] = true,
			},
			["Basics"] = {
				["expand"] = false,
			},
		},
	},
	["RaidStatus"] = {
		["Mooselini"] = {
			0, -- [1]
			173613.387, -- [2]
			"PRIEST", -- [3]
			"v1.980.8", -- [4]
		},
	},
	["GROUPED"] = false,
}
