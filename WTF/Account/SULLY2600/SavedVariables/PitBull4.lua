
PitBull4DB = {
	["namespaces"] = {
		["LeaderIcon"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["LibDualSpec-1.0"] = {
		},
		["RangeFader"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Border"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["PhaseIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["enabled"] = false,
						},
						["Tiny"] = {
							["enabled"] = false,
						},
						["Normal"] = {
							["enabled"] = false,
						},
						["Box"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["CombatIcon"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["RoleIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["position"] = 1.00001,
						},
						["Tiny"] = {
							["position"] = 1.00001,
						},
						["Normal"] = {
							["position"] = 1.00001,
						},
						["Box"] = {
							["position"] = 1.00001,
						},
					},
				},
			},
		},
		["LuaTexts"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["first"] = false,
							["elements"] = {
								["Lua:Eclipse"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_POWER"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["code"] = "return math.abs(Power(unit,SPELL_POWER_ECLIPSE))\n",
									["location"] = "center",
									["attach_to"] = "Eclipse",
								},
								["Lua: Absolute Health"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "right",
									["code"] = "local s = Status(unit)\nif s then\n  return \" \"\nelseif HP(unit) == MaxHP(unit) then\n  return \"%s\", Short(MaxHP(unit), true)\nelse\n  return \"%s / %s\",Short(HP(unit),true),Short(MaxHP(unit),true)\nend",
									["attach_to"] = "PowerBar",
									["size"] = 1.25,
								},
								["Lua:Power"] = {
									["events"] = {
										["UNIT_POWER"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  if Power(unit) == max then\n    return \"%s\", Short(Power(unit),true)\n  else\n    return \"%s / %s\",Short(Power(unit),true),Short(max,true)\n  end\nend",
									["location"] = "left",
									["exists"] = true,
									["attach_to"] = "PowerBar",
									["size"] = 0.8500000238418579,
								},
								["Lua:Reputation"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["code"] = "local name, _, min , max, value, id = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local fs_id, fs_rep, _, _, _, _, _, fs_threshold, next_fs_threshold = GetFriendshipReputation(id)\n  if fs_id then\n    if next_fs_threshold then\n      min, max, value = fs_threshold, next_fs_threshold, fs_rep\n    else\n      min, max, value = 0, 1, 1\n    end\n  end\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
								},
								["Lua:Name"] = {
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "local abbr = Name(unit)\nif abbr:len() > 20 and abbr:find(\" \") then\n  abbr = abbr:gsub(\"([^ ]+) +\",\n    function(text)\n        return text:sub(1,1) .. \". \"\n    end)\nend\nreturn \"%s\", abbr;",
									["location"] = "left",
									["attach_to"] = "HealthBar",
								},
								["Lua:Threat"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
								},
								["Lua:Experience"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
								},
								["Lua:PVPTimer"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
									["location"] = "out_right_top",
								},
								["Lua:Cast time"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
								},
								["Lua:Cast"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
									["location"] = "left",
									["attach_to"] = "CastBar",
								},
								["Lua:Health"] = {
									["exists"] = true,
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["position"] = 1.00001,
									["location"] = "right",
									["code"] = "local s = Status(unit)\nif s then\n  return s\nelseif HP(unit) == MaxHP(unit) then\n  return \" \"\nelse\n  return \"%s%%\",Percent(HP(unit),MaxHP(unit))\nend",
									["attach_to"] = "HealthBar",
								},
								["Lua:Alternate power"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_POWER"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\nif max > 0 then\n  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "AltPowerBar",
								},
								["Lua:Class"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
									["position"] = 1.00001,
									["location"] = "left",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["attach_to"] = "PowerBar",
								},
								["Lua:Druid mana"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_POWER"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
								},
								["Lua:Demonic fury"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_POWER_FREQUENT"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["code"] = "return \"%s/%s\",Power(unit,SPELL_POWER_DEMONIC_FURY),MaxPower(unit,SPELL_POWER_DEMONIC_FURY)\n",
									["location"] = "center",
									["attach_to"] = "DemonicFury",
								},
							},
						},
						["Tiny"] = {
							["first"] = false,
							["elements"] = {
								["Lua:Eclipse"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
									["exists"] = true,
									["code"] = "return math.abs(Power(unit,SPELL_POWER_ECLIPSE))\n",
									["location"] = "center",
									["attach_to"] = "Eclipse",
								},
								["Lua:Experience"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
									["exists"] = true,
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
								},
								["Lua:Name"] = {
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["location"] = "right",
									["position"] = 1.00001,
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000238418579,
								},
								["Lua:Reputation"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["code"] = "local name, _, min , max, value, id = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local fs_id, fs_rep, _, _, _, _, _, fs_threshold, next_fs_threshold = GetFriendshipReputation(id)\n  if fs_id then\n    if next_fs_threshold then\n      min, max, value = fs_threshold, next_fs_threshold, fs_rep\n    else\n      min, max, value = 0, 1, 1\n    end\n  end\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
								},
								["Lua:Power"] = {
									["enabled"] = false,
									["position"] = 1.00001,
									["exists"] = true,
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  if Power(unit) == max then\n    return \"%s\", Short(Power(unit),true)\n  else\n    return \"%s / %s\",Short(Power(unit),true),Short(max,true)\n  end\nend",
									["location"] = "left",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
									["attach_to"] = "PowerBar",
									["size"] = 0.8500000238418579,
								},
								["Lua:Threat"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
								},
								["Lua:AbsoluteHealth"] = {
									["enabled"] = false,
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "right",
									["code"] = "local s = Status(unit)\nif s then\n  return \" \"\nelseif HP(unit) == MaxHP(unit) then\n  return \"%s\", Short(MaxHP(unit), true)\nelse\n  return \"%s / %s\",Short(HP(unit),true),Short(MaxHP(unit),true)\nend",
									["attach_to"] = "PowerBar",
									["size"] = 0.9500000476837158,
								},
								["Lua:Alternate power"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
									["exists"] = true,
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\nif max > 0 then\n  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "AltPowerBar",
								},
								["Lua:Cast"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
									},
									["exists"] = true,
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
									["location"] = "left",
									["attach_to"] = "CastBar",
								},
								["Lua:Cast time"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["exists"] = true,
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
								},
								["Lua:Health"] = {
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "right",
									["code"] = "local s = Status(unit)\nif s then\n  return s\nelseif HP(unit) == MaxHP(unit) then\n  return \" \"\nelse\n  return \"%s%%\",Percent(HP(unit),MaxHP(unit))\nend",
									["attach_to"] = "HealthBar",
									["size"] = 0.5,
								},
								["Lua:PVPTimer"] = {
									["enabled"] = false,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
									["location"] = "out_right_top",
								},
								["Lua:Class"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "left",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["attach_to"] = "PowerBar",
								},
								["Lua:Druid mana"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
									["exists"] = true,
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
								},
								["Lua:Demonic fury"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["code"] = "return \"%s/%s\",Power(unit,SPELL_POWER_DEMONIC_FURY),MaxPower(unit,SPELL_POWER_DEMONIC_FURY)\n",
									["location"] = "center",
									["attach_to"] = "DemonicFury",
								},
							},
						},
						["Normal"] = {
							["first"] = false,
							["elements"] = {
								["Lua:Eclipse"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
									["exists"] = true,
									["code"] = "return math.abs(Power(unit,SPELL_POWER_ECLIPSE))\n",
									["location"] = "center",
									["attach_to"] = "Eclipse",
								},
								["Lua:AbsoluteHealth"] = {
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "right",
									["code"] = "local s = Status(unit)\nif s then\n  return \" \"\nelseif HP(unit) == MaxHP(unit) then\n  return \"%s\", Short(MaxHP(unit), true)\nelse\n  return \"%s / %s\",Short(HP(unit),true),Short(MaxHP(unit),true)\nend",
									["attach_to"] = "PowerBar",
									["size"] = 0.9500000476837158,
								},
								["Lua:Name"] = {
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
										["UNIT_NAME_UPDATE"] = true,
									},
									["code"] = "local abbr = Name(unit)\nif abbr:len() > 20 and abbr:find(\" \") then\n  abbr = abbr:gsub(\"([^ ]+) +\",\n    function(text)\n        return text:sub(1,1) .. \". \"\n    end)\nend\nreturn \"%s\", abbr;",
									["location"] = "left",
									["exists"] = true,
									["attach_to"] = "HealthBar",
									["size"] = 1.299999952316284,
								},
								["Lua:Reputation"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["exists"] = true,
									["code"] = "local name, _, min , max, value, id = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local fs_id, fs_rep, _, _, _, _, _, fs_threshold, next_fs_threshold = GetFriendshipReputation(id)\n  if fs_id then\n    if next_fs_threshold then\n      min, max, value = fs_threshold, next_fs_threshold, fs_rep\n    else\n      min, max, value = 0, 1, 1\n    end\n  end\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
								},
								["Lua:Druid mana"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
									["exists"] = true,
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
								},
								["Lua:Threat"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["exists"] = true,
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
								},
								["Lua:Experience"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
									["exists"] = true,
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
								},
								["Lua:Alternate power"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
									["exists"] = true,
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\nif max > 0 then\n  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "AltPowerBar",
								},
								["Lua:Cast"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
									},
									["exists"] = true,
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
									["location"] = "left",
									["attach_to"] = "CastBar",
								},
								["Lua:Cast time"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["exists"] = true,
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
								},
								["Lua:Health"] = {
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "right",
									["code"] = "local s = Status(unit)\nif s then\n  return s\nelseif HP(unit) == MaxHP(unit) then\n  return \" \"\nelse\n  return \"%s%%\",Percent(HP(unit),MaxHP(unit))\nend",
									["attach_to"] = "HealthBar",
								},
								["Lua:PVPTimer"] = {
									["enabled"] = false,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["exists"] = true,
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
									["location"] = "out_right_top",
								},
								["Lua:Class"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "left",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["attach_to"] = "PowerBar",
								},
								["Lua:Power"] = {
									["exists"] = true,
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  if Power(unit) == max then\n    return \"%s\", Short(Power(unit),true)\n  else\n    return \"%s / %s\",Short(Power(unit),true),Short(max,true)\n  end\nend",
									["location"] = "left",
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER"] = true,
									},
									["attach_to"] = "PowerBar",
									["size"] = 0.8500000238418579,
								},
								["Lua:Demonic fury"] = {
									["enabled"] = false,
									["events"] = {
										["UNIT_MAXPOWER"] = true,
										["UNIT_POWER_FREQUENT"] = true,
									},
									["exists"] = true,
									["code"] = "return \"%s/%s\",Power(unit,SPELL_POWER_DEMONIC_FURY),MaxPower(unit,SPELL_POWER_DEMONIC_FURY)\n",
									["location"] = "center",
									["attach_to"] = "DemonicFury",
								},
							},
						},
						["Box"] = {
							["first"] = false,
							["elements"] = {
								["Lua:AbsoluteHealth"] = {
									["enabled"] = false,
									["exists"] = true,
									["position"] = 1.00002,
									["location"] = "right",
									["code"] = "local s = Status(unit)\nif s then\n  return \" \"\nelseif HP(unit) == MaxHP(unit) then\n  return \"%s\", Short(MaxHP(unit), true)\nelse\n  return \"%s / %s\",Short(HP(unit),true),Short(MaxHP(unit),true)\nend",
									["attach_to"] = "PowerBar",
									["size"] = 0.9500000476837158,
								},
								["Lua:Reputation"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_FACTION"] = true,
										["UPDATE_FACTION"] = true,
									},
									["code"] = "local name, _, min , max, value, id = GetWatchedFactionInfo()\nif IsMouseOver() then\n  return name or ConfigMode() \nelse\n  local fs_id, fs_rep, _, _, _, _, _, fs_threshold, next_fs_threshold = GetFriendshipReputation(id)\n  if fs_id then\n    if next_fs_threshold then\n      min, max, value = fs_threshold, next_fs_threshold, fs_rep\n    else\n      min, max, value = 0, 1, 1\n    end\n  end\n  local bar_cur,bar_max = value-min,max-min\n  return \"%d/%d (%s%%)\",bar_cur,bar_max,Percent(bar_cur,bar_max)\nend",
									["location"] = "center",
									["attach_to"] = "ReputationBar",
								},
								["Lua:Power"] = {
									["enabled"] = false,
									["code"] = "local max = MaxPower(unit)\nif max > 0 then\n  if Power(unit) == max then\n    return \"%s\", Short(Power(unit),true)\n  else\n    return \"%s / %s\",Short(Power(unit),true),Short(max,true)\n  end\nend",
									["exists"] = true,
									["position"] = 1.00001,
									["location"] = "left",
									["events"] = {
										["UNIT_POWER"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["attach_to"] = "PowerBar",
									["size"] = 0.8500000238418579,
								},
								["Lua:Experience"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_PET_EXPERIENCE"] = true,
										["PLAYER_XP_UPDATE"] = true,
									},
									["code"] = "local cur, max, rest = XP(unit), MaxXP(unit), RestXP(unit)\nif rest then\n  return \"%s/%s (%s%%) R: %s%%\",cur,max,Percent(cur,max),Percent(rest,max)\nelse\n  return \"%s/%s (%s%%)\",cur,max,Percent(cur,max)\nend",
									["location"] = "center",
									["attach_to"] = "ExperienceBar",
								},
								["Lua:Druid mana"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_POWER"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["code"] = "if UnitPowerType(unit) ~= 0 then\n  return \"%s/%s\",Power(unit,0),MaxPower(unit,0)\nend",
									["location"] = "center",
									["attach_to"] = "DruidManaBar",
								},
								["Lua:Threat"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_THREAT_LIST_UPDATE"] = true,
										["UNIT_THREAT_SITUATION_UPDATE"] = true,
									},
									["code"] = "local unit_a,unit_b = ThreatPair(unit)\nif unit_a and unit_b then\n  local _,_,percent = UnitDetailedThreatSituation(unit_a, unit_b)\n  if percent and percent ~= 0 then\n    return \"%s%%\",Round(percent,1)\n  end\nend\nreturn ConfigMode()",
									["location"] = "center",
									["attach_to"] = "ThreatBar",
								},
								["Lua:Eclipse"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_POWER"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["code"] = "return math.abs(Power(unit,SPELL_POWER_ECLIPSE))\n",
									["location"] = "center",
									["attach_to"] = "Eclipse",
								},
								["Lua:PVPTimer"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["PLAYER_FLAGS_CHANGED"] = true,
									},
									["code"] = "if unit == \"player\" then\n  local pvp = PVPDuration()\n  if pvp then\n    return \"|cffff0000%s|r\",FormatDuration(pvp)\n  end\nend",
									["location"] = "out_right_top",
								},
								["Lua:Cast time"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_SPELLCAST_SUCCEEDED"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  if not cast_data.stop_time then\n    local delay,end_time = cast_data.delay, cast_data.end_time\n    local duration\n    if end_time then\n      duration = end_time - GetTime()\n    end\n    if delay and delay ~= 0 then\n      local delay_sign = '+'\n      if delay < 0 then\n        delay_sign = ''\n      end\n      if duration and duration >= 0 then\n        return \"|cffff0000%s%s|r %.1f\",delay_sign,Round(delay,1),duration\n      else\n        return \"|cffff0000%s%s|r\",delay_sign,Round(delay,1)\n      end\n    elseif duration and duration >= 0 then\n      return \"%.1f\",duration\n    end\n  end\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "CastBar",
								},
								["Lua:Cast"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_SPELLCAST_DELAYED"] = true,
										["UNIT_SPELLCAST_CHANNEL_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
										["UNIT_SPELLCAST_START"] = true,
										["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
										["UNIT_SPELLCAST_STOP"] = true,
										["UNIT_SPELLCAST_INTERRUPTED"] = true,
										["UNIT_SPELLCAST_FAILED"] = true,
									},
									["code"] = "local cast_data = CastData(unit)\nif cast_data then\n  local spell,stop_message,target = cast_data.spell,cast_data.stop_message,cast_data.target\n  local stop_time,stop_duration = cast_data.stop_time\n  if stop_time then\n    stop_duration = GetTime() - stop_time\n  end\n  Alpha(-(stop_duration or 0) + 1)\n  if stop_message then\n    return stop_message\n  elseif target then\n    return \"%s (%s)\",spell,target\n  else\n    return spell \n  end\nend\nreturn ConfigMode()",
									["location"] = "left",
									["attach_to"] = "CastBar",
								},
								["Lua:Health"] = {
									["exists"] = true,
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["position"] = 1.00002,
									["location"] = "right",
									["code"] = "local s = Status(unit)\nif s then\n  return s\nelseif HP(unit) == MaxHP(unit) then\n  return \" \"\nelse\n  return \"%s%%\",Percent(HP(unit),MaxHP(unit))\nend",
									["attach_to"] = "HealthBar",
								},
								["Lua:Alternate power"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_POWER"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["code"] = "local max = MaxPower(unit,ALTERNATE_POWER_INDEX)\nif max > 0 then\n  return \"%s%%\",Percent(Power(unit,ALTERNATE_POWER_INDEX),max)\nend\nreturn ConfigMode()",
									["location"] = "right",
									["attach_to"] = "AltPowerBar",
								},
								["Lua:Class"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_LEVEL"] = true,
										["UNIT_CLASSIFICATION_CHANGED"] = true,
										["UNIT_AURA"] = true,
									},
									["position"] = 1.00002,
									["location"] = "left",
									["code"] = "local dr,dg,db = DifficultyColor(unit)\nlocal form = DruidForm(unit)\nlocal classification = Classification(unit)\nif UnitIsPlayer(unit) or (not UnitIsFriend(unit,\"player\") and not IsPet(unit)) then\n  local cr,cg,cb = ClassColor(unit)\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),cr,cg,cb,Class(unit),SmartRace(unit) or ''\n  end\nelse\n  if form then\n    return \"%s%s|cff%02x%02x%02x%s|r (%s) %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),form,SmartRace(unit) or ''\n  else\n    return \"%s%s|cff%02x%02x%02x%s|r %s\",classification or '',classification and ' ' or '',dr,dg,db,Level(unit),SmartRace(unit) or ''\n  end\nend",
									["attach_to"] = "PowerBar",
								},
								["Lua:Name"] = {
									["exists"] = true,
									["events"] = {
										["UNIT_HEALTH"] = true,
										["UNIT_AURA"] = true,
										["UNIT_MAXHEALTH"] = true,
									},
									["code"] = "local s = Status(unit)\nif s then\n  return s\nend\nreturn \"%s%%\",Percent(HP(unit),MaxHP(unit))",
									["location"] = "right",
									["position"] = 1.00001,
									["attach_to"] = "HealthBar",
									["size"] = 0.8500000238418579,
								},
								["Lua:Demonic fury"] = {
									["enabled"] = false,
									["exists"] = true,
									["events"] = {
										["UNIT_POWER_FREQUENT"] = true,
										["UNIT_MAXPOWER"] = true,
									},
									["code"] = "return \"%s/%s\",Power(unit,SPELL_POWER_DEMONIC_FURY),MaxPower(unit,SPELL_POWER_DEMONIC_FURY)\n",
									["location"] = "center",
									["attach_to"] = "DemonicFury",
								},
							},
						},
					},
				},
			},
		},
		["HostilityFader"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["MasterLooterIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["location"] = "left",
							["attach_to"] = "HealthBar",
						},
						["Tiny"] = {
							["enabled"] = false,
							["location"] = "left",
							["attach_to"] = "HealthBar",
						},
						["Normal"] = {
							["location"] = "left",
							["attach_to"] = "HealthBar",
						},
						["Box"] = {
							["enabled"] = false,
							["location"] = "left",
							["attach_to"] = "HealthBar",
						},
					},
				},
			},
		},
		["CombatText"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["ReadyCheckIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["location"] = "center",
							["attach_to"] = "HealthBar",
						},
						["Tiny"] = {
							["location"] = "center",
							["attach_to"] = "HealthBar",
						},
						["Normal"] = {
							["location"] = "center",
							["attach_to"] = "HealthBar",
						},
						["Box"] = {
							["location"] = "center",
							["attach_to"] = "HealthBar",
						},
					},
				},
			},
		},
		["Portrait"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["RaidTargetIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["location"] = "right",
							["attach_to"] = "HealthBar",
							["size"] = 2.2,
						},
						["Tiny"] = {
							["location"] = "left",
							["attach_to"] = "HealthBar",
							["size"] = 2.2,
						},
						["Normal"] = {
							["location"] = "right",
							["attach_to"] = "HealthBar",
							["size"] = 2.2,
						},
						["Box"] = {
							["location"] = "right",
							["attach_to"] = "HealthBar",
							["size"] = 2.2,
						},
					},
				},
			},
		},
		["ShadowOrbs"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Tiny"] = {
							["enabled"] = false,
						},
						["Box"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["CastBar"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Aura"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["PvPIcon"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["PowerBar"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["deficit"] = true,
							["reverse"] = true,
							["background_alpha"] = 0.3,
						},
						["Tiny"] = {
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["deficit"] = true,
							["reverse"] = true,
							["background_alpha"] = 0.3,
						},
						["Normal"] = {
							["background_alpha"] = 0.3,
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["deficit"] = true,
							["reverse"] = true,
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
						},
						["Box"] = {
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["deficit"] = true,
							["reverse"] = true,
							["background_alpha"] = 0.3,
						},
					},
				},
			},
		},
		["HideBlizzard"] = {
		},
		["ReputationBar"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["HealthBar"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["background_alpha"] = 0.3,
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["size"] = 8,
							["deficit"] = true,
							["reverse"] = true,
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
						},
						["Tiny"] = {
							["background_alpha"] = 0.3,
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["size"] = 8,
							["deficit"] = true,
							["reverse"] = true,
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
						},
						["Normal"] = {
							["background_alpha"] = 0.3,
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["size"] = 8,
							["deficit"] = true,
							["reverse"] = true,
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
						},
						["Box"] = {
							["background_alpha"] = 0.3,
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["size"] = 8,
							["deficit"] = true,
							["reverse"] = true,
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
						},
					},
				},
			},
		},
		["Aggro"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Background"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["QuestIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["enabled"] = false,
						},
						["Tiny"] = {
							["enabled"] = false,
						},
						["Normal"] = {
							["enabled"] = false,
						},
						["Box"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["VisualHeal"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["CastBarLatency"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
						["show_queue"] = false,
						["show_gcd"] = false,
					},
				},
			},
		},
		["CombatFader"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["BattlePet"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["AltPowerBar"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Lua: Absolute Health"] = {
							["background_alpha"] = 0.3,
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["deficit"] = true,
							["reverse"] = true,
						},
						["Tiny"] = {
							["background_alpha"] = 0.3,
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["deficit"] = true,
							["reverse"] = true,
						},
						["Normal"] = {
							["background_alpha"] = 0.3,
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["deficit"] = true,
							["reverse"] = true,
						},
						["Box"] = {
							["background_alpha"] = 0.3,
							["custom_background"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["custom_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["deficit"] = true,
							["reverse"] = true,
						},
					},
				},
			},
		},
		["BlankSpace"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Normal"] = {
							["elements"] = {
								["Default"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
						["Lua: Absolute Health"] = {
							["elements"] = {
								["Default"] = {
									["exists"] = true,
								},
							},
							["first"] = false,
						},
					},
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["ThreatBar"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["Highlight"] = {
			["profiles"] = {
				["Default"] = {
					["global"] = {
						["enabled"] = false,
					},
				},
			},
		},
		["RestIcon"] = {
			["profiles"] = {
				["Default"] = {
					["layouts"] = {
						["Tiny"] = {
							["enabled"] = false,
						},
						["Box"] = {
							["enabled"] = false,
						},
					},
				},
			},
		},
		["Sounds"] = {
		},
	},
	["global"] = {
		["config_version"] = 2,
	},
	["profileKeys"] = {
		["Mooselini - Area 52"] = "Default",
	},
	["profiles"] = {
		["Default"] = {
			["class_order"] = {
				"WARRIOR", -- [1]
				"DEATHKNIGHT", -- [2]
				"PALADIN", -- [3]
				"MONK", -- [4]
				"PRIEST", -- [5]
				"SHAMAN", -- [6]
				"DRUID", -- [7]
				"ROGUE", -- [8]
				"MAGE", -- [9]
				"WARLOCK", -- [10]
				"HUNTER", -- [11]
			},
			["layouts"] = {
				["Lua: Absolute Health"] = {
					["indicator_size"] = 10,
					["bar_spacing"] = 1,
					["bar_padding"] = 0,
					["indicator_spacing"] = 5,
					["exists"] = true,
					["size_x"] = 260,
				},
				["Tiny"] = {
					["indicator_size"] = 10,
					["bar_spacing"] = 1,
					["bar_padding"] = 0,
					["size_x"] = 130,
					["indicator_spacing"] = 5,
					["font_size"] = 1.5,
					["font"] = "SSPro - Semibold",
					["exists"] = true,
				},
				["Normal"] = {
					["indicator_size"] = 10,
					["bar_spacing"] = 1,
					["bar_padding"] = 0,
					["indicator_spacing"] = 5,
					["font"] = "SSPro - Semibold",
					["exists"] = true,
					["size_x"] = 260,
				},
				["Box"] = {
					["indicator_size"] = 10,
					["bar_spacing"] = 1,
					["bar_padding"] = 0,
					["indicator_spacing"] = 5,
					["exists"] = true,
					["size_x"] = 130,
				},
			},
			["made_groups"] = true,
			["units"] = {
				["targettargettarget"] = {
					["enabled"] = false,
					["position_x"] = -201.205810546875,
					["position_y"] = 141.32177734375,
				},
				["focustarget"] = {
					["position_x"] = 214.657470703125,
					["size_y"] = 0.6,
					["size_x"] = 1.3,
					["position_y"] = -461.9999389648438,
					["layout"] = "Tiny",
				},
				["targettarget"] = {
					["position_x"] = -41.51898193359375,
					["position_y"] = -509.999942779541,
					["layout"] = "Box",
				},
				["player"] = {
					["position_x"] = -251.9832153320313,
					["position_y"] = -509.999942779541,
				},
				["focus"] = {
					["position_x"] = -296.0208129882813,
					["layout"] = "Tiny",
					["size_x"] = 1.299999952316284,
					["position_y"] = -461.9999389648438,
					["size_y"] = 0.6000000238418579,
					["horizontal_mirror"] = true,
				},
				["target"] = {
					["position_x"] = 169.1575927734375,
					["position_y"] = -509.999942779541,
					["horizontal_mirror"] = true,
				},
				["pet"] = {
					["enabled"] = false,
				},
				["focustargettarget"] = {
					["enabled"] = false,
					["position_x"] = 290.68994140625,
					["position_y"] = 315.1884155273438,
				},
				["pettarget"] = {
					["enabled"] = false,
				},
			},
			["groups"] = {
				["Party pets"] = {
					["unit_group"] = "partypet",
					["exists"] = true,
				},
				["Party"] = {
					["exists"] = true,
				},
			},
		},
	},
}
