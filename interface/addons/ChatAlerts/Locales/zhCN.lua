local ADDON_NAME, namespace = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN", false);

if not L then return end

L["Active"] = "启动"
L["Alert"] = "提示"
L["Alert Options"] = "提示选项"
L["Always Show"] = "始终显示"
L["Bold Outline"] = "清晰轮廓"
L["Changes the appearance of the pulsing alert flash."] = "改变闪光提示外观"
L["Classic"] = "经典"
L["Disables the pulsing alert flash."] = "关闭闪光警示"
L["Fade Inactive"] = "不活动时隐褪"
L["Fades the name of inactive tabs."] = "将不活动索引名称隐褪"
L["Font Colors"] = "字型颜色"
L["Hide Border"] = "隐藏边框"
L["Hides the tab border, leaving only the text visible."] = "隐藏索引边框"
L["Inactive"] = "不活动"
L["Large"] = "大型"
L["Outline"] = "轮廓"
L["Tab Options"] = "索引选项"
L["Toggles between always showing the tab or only showing it on mouse-over."] = "切换始终显示索引或鼠标指向时才显示索引"
