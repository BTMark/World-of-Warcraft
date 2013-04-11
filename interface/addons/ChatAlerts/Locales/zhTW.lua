local ADDON_NAME, namespace = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhTW", false)

if not L then return end

L["Active"] = "啟動"
L["Alert"] = "提示"
L["Alert Options"] = "提示選項"
L["Always Show"] = "始終顯示"
L["Bold Outline"] = "清晰輪廓"
L["Changes the appearance of the pulsing alert flash."] = "改變閃光提示外觀"
L["Classic"] = "經典" -- Needs review
L["Disables the pulsing alert flash."] = "關閉閃光警示"
L["Fade Inactive"] = "不活動時隱褪"
L["Fades the name of inactive tabs."] = "將不活動索引名稱隱褪"
L["Font Colors"] = "字型顏色"
L["Hide Border"] = "隱藏邊框"
L["Hides the tab border, leaving only the text visible."] = "隱藏索引邊框"
L["Inactive"] = "不活動"
L["Large"] = "大型"
L["Outline"] = "輪廓"
L["Tab Options"] = "索引選項"
L["Toggles between always showing the tab or only showing it on mouse-over."] = "切換始終顯示索引或滑鼠指向時才顯示索引"
