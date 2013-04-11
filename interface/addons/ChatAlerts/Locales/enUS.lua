local ADDON_NAME, namespace = ...

local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true, debug)

if not L then return end

L["Active"] = true
L["Alert"] = true
L["Alert Options"] = true
L["Always Show"] = true
L["Bold Outline"] = true
L["Changes the appearance of the pulsing alert flash."] = true
L["Classic"] = true
L["Disables the pulsing alert flash."] = true
L["Fade Inactive"] = true
L["Fades the name of inactive tabs."] = true
L["Font Colors"] = true
L["Hide Border"] = true
L["Hides the tab border, leaving only the text visible."] = true
L["Inactive"] = true
L["Large"] = true
L["Outline"] = true
L["Tab Options"] = true
L["Toggles between always showing the tab or only showing it on mouse-over."] = true
