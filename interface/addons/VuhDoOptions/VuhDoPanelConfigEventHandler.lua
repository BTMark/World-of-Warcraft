local _;

VUHDO_DRAG_PANEL = nil;
DESIGN_MISC_PANEL_NUM = nil;
local sCurrentGroupsCombo;
local VUHDO_CURRENT_GROUP_ID;



local VUHDO_ID_TYPE_NAMES = {
	[VUHDO_ID_TYPE_UNDEFINED] = VUHDO_I18N_UNDEFINED,
	[VUHDO_ID_TYPE_CLASS] = VUHDO_I18N_CLASS,
	[VUHDO_ID_TYPE_GROUP] = VUHDO_I18N_GROUP,
	[VUHDO_ID_TYPE_SPECIAL] = VUHDO_I18N_SPECIAL
};



--
function VUHDO_panelSetupRemoveGroupOnClick(aPanel)
	local tPanelNum, tModelNum = VUHDO_getComponentPanelNumModelNum(aPanel)
	VUHDO_removeFromModel(tPanelNum, tModelNum);
	VUHDO_clearGuessedModels(tPanelNum);
	VUHDO_redrawAllPanels();
end



--
function VUHDO_panelSetupChooseGroupOnClick(aButton)
	local tGroupOrderPanel = aButton:GetParent();
	local tPanelNum, tModelNum = VUHDO_getComponentPanelNumModelNum(tGroupOrderPanel);
	local tGroupSelectPanel = VUHDO_getGroupSelectPanel(tPanelNum, tModelNum);

	tGroupOrderPanel:Hide();
	tGroupSelectPanel:Show();
end



--
function VUHDO_groupSelectOkayOnClick(aButton)
	local tGroupSelectPanel = aButton:GetParent();
	local tPanelNum, tModelNum = VUHDO_getComponentPanelNumModelNum(tGroupSelectPanel);
	local tGroupOrderPanel = VUHDO_getGroupOrderPanel(tPanelNum, tModelNum);

	tGroupSelectPanel:Hide();
	VUHDO_redrawPanel(tPanelNum);

	VUHDO_setGuessedModel(tPanelNum, tModelNum, false);
	VUHDO_guessUndefinedEntries(tPanelNum);
	tGroupOrderPanel:Show();
	VUHDO_reloadUI();
end



--
function VUHDO_PanelSetupGroupSelectOnShow(aGroupSelectPanel)
	aGroupSelectPanel:SetBackdropColor(0, 0, 0, 1);
	aGroupSelectPanel:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
end



--
function VUHDO_groupSelectTypeComboOnShow(aComboBox)
	local tPanelNum, tModelNum = VUHDO_getComponentPanelNumModelNum(aComboBox:GetParent());
	local tModelId = VUHDO_PANEL_MODELS[tPanelNum][tModelNum];
	local tOkayButton = _G[aComboBox:GetParent():GetName() .. "OkayButton"];

	if (tModelId ~= VUHDO_ID_UNDEFINED) then
		tOkayButton:Enable();
	else
		tOkayButton:Disable();
	end

	local tType = VUHDO_getModelType(tModelId);
	UIDropDownMenu_SetSelectedValue(aComboBox, tType);
	VUHDO_configFillGroupsCombo(aComboBox:GetParent(), tModelId);
	_G[aComboBox:GetName() .. "Text"]:SetText(VUHDO_ID_TYPE_NAMES[tType]);
end



--
function VUHDO_groupSelectTypeOnSelectionChanged(anEntry)
	local tText = VUHDO_ID_TYPE_NAMES[anEntry.value];
	local tPanel = anEntry.owner:GetParent();

	UIDropDownMenu_SetSelectedValue(anEntry.owner, anEntry.value, true);

	_G[anEntry.owner:GetName() .. "Text"]:SetText(tText);

	local tPanelNum, tModelNum = VUHDO_getComponentPanelNumModelNum(tPanel);

	local tModelId;
	if (anEntry.value == VUHDO_ID_TYPE_GROUP) then
		 tModelId = VUHDO_ID_GROUP_1;
	elseif (anEntry.value == VUHDO_ID_TYPE_CLASS) then
		tModelId = VUHDO_ID_WARRIORS;
	else
		tModelId = VUHDO_ID_PETS;
	end

	VUHDO_PANEL_MODELS[tPanelNum][tModelNum] = tModelId;
	VUHDO_configFillGroupsCombo(tPanel, tModelId);
	_G[tPanel:GetName() .. "OkayButton"]:Enable();
end



--
function VUHDO_configGroupSelectButtonOnMouseDown(aButton)
	local tComboBox = aButton:GetParent();
	local tPanelNum, tModelNum = VUHDO_getComponentPanelNumModelNum(tComboBox:GetParent());

	local tModelId = VUHDO_PANEL_MODELS[tPanelNum][tModelNum];
	local tType = VUHDO_getModelType(tModelId);

	sCurrentGroupsCombo = tComboBox;
end



--
function VUHDO_groupSelectGroupOnSelectionChanged(anEntry)
	local tPanelNum, tModelNum;

	local tGroupSelectPanel = anEntry.owner:GetParent();
	tPanelNum, tModelNum = VUHDO_getComponentPanelNumModelNum(tGroupSelectPanel);

	VUHDO_configFillGroupsCombo(tGroupSelectPanel, anEntry.value);
	VUHDO_PANEL_MODELS[tPanelNum][tModelNum] = anEntry.value;
end



--
local function VUHDO_createComboBoxInfo(aComboBox, aText, aValue, aCheckedValue, aFunction)
	return {
		["text"] = aText,
		["value"] = aValue,
		["owner"] = aComboBox,
		["checked"] = aValue == aCheckedValue and true or nil,
		["func"] = aFunction
	};
end



--
function VUHDO_configInitGroupsCombo()
	local tType = VUHDO_getModelType(VUHDO_CURRENT_GROUP_ID);

	for _, tId in ipairs(VUHDO_ID_TYPE_MEMBERS[tType]) do
		UIDropDownMenu_AddButton(
			VUHDO_createComboBoxInfo(sCurrentGroupsCombo,
				VUHDO_HEADER_TEXTS[tId], tId, VUHDO_CURRENT_GROUP_ID,
				VUHDO_groupSelectGroupOnSelectionChanged
			)
		);
	end

	_G[sCurrentGroupsCombo:GetName() .. "Text"]:SetText(
		VUHDO_HEADER_TEXTS[VUHDO_CURRENT_GROUP_ID]
	);
end



--
function VUHDO_refreshGroupsCombo(aGroupsCombo, aModelId)
	sCurrentGroupsCombo = aGroupsCombo;
	VUHDO_CURRENT_GROUP_ID = aModelId;

	UIDropDownMenu_Initialize(aGroupsCombo, VUHDO_configInitGroupsCombo);
end



--
function VUHDO_configFillGroupsCombo(aGroupSelectPanel, aModelId)
	local tGroupsCombo = _G[aGroupSelectPanel:GetName() .. "VlCmb"];

	UIDropDownMenu_ClearAll(tGroupsCombo);
	VUHDO_refreshGroupsCombo(tGroupsCombo, aModelId);
end



--
function VUHDO_PanelSetupGroupOrderOnShow(aGroupOrderPanel)
	VUHDO_PanelSetupGroupOrderSetStandard(aGroupOrderPanel);
end



--
function VUHDO_PanelSetupGroupOrderSetStandard(aPanel)
	aPanel:SetBackdropColor(0, 0, 0, 1);
	aPanel:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	aPanel:SetToplevel(false);
	VUHDO_getGroupOrderLabel2(aPanel):SetText(VUHDO_I18N_ME);
end



--
function VUHDO_PanelSetupGroupOrderSetDragging(aPanel)
	aPanel:SetBackdropColor(0, 0, 0, 1);
	aPanel:SetBackdropBorderColor(1, 0, 0, 1);
	aPanel:SetToplevel(true);
	local tPanelNum, tModelNum = VUHDO_getComponentPanelNumModelNum(aPanel);
	local tText = VUHDO_getHeaderText(VUHDO_PANEL_MODELS[tPanelNum][tModelNum]);

	VUHDO_getGroupOrderLabel2(aPanel):SetText(tText);
end



--
function VUHDO_panelSetupGroupDragOnMouseDown(aDragArea)
	local tGroupPanel = aDragArea:GetParent();

	VUHDO_PanelSetupGroupOrderSetDragging(tGroupPanel);
	tGroupPanel:StartMoving();
	VUHDO_DRAG_PANEL = tGroupPanel;
end



--
function VUHDO_panelSetupGroupDragOnMouseUp(aDragArea)
	local tGroupPanel = aDragArea:GetParent();
	tGroupPanel:StopMovingOrSizing();
	VUHDO_DRAG_PANEL = nil;
	VUHDO_PanelSetupGroupOrderSetStandard(tGroupPanel);
	VUHDO_reorderGroupsAfterDragged(tGroupPanel);
end

