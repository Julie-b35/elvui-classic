local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')
local TT = E:GetModule('Tooltip')
local LDB = E.Libs.LDB
local LSM = E.Libs.LSM

--Lua functions
local _G = _G
local pairs, type, error, strlen = pairs, type, error, strlen
local pcall = pcall
--WoW API / Variables
local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local InCombatLockdown = InCombatLockdown

function DT:Initialize()
	--if E.db.datatexts.enable ~= true then return end
	self.Initialized = true
	self.db = E.db.datatexts

	self.tooltip = CreateFrame("GameTooltip", "DatatextTooltip", E.UIParent, "GameTooltipTemplate")
	TT:HookScript(self.tooltip, 'OnShow', 'SetStyle')

	-- Ignore header font size on DatatextTooltip
	local font = E.Libs.LSM:Fetch("font", E.db.tooltip.font)
	local fontOutline = E.db.tooltip.fontOutline
	local textSize = E.db.tooltip.textFontSize
	_G.DatatextTooltipTextLeft1:FontTemplate(font, textSize, fontOutline)
	_G.DatatextTooltipTextRight1:FontTemplate(font, textSize, fontOutline)

	LDB.RegisterCallback(E, "LibDataBroker_DataObjectCreated", DT.SetupObjectLDB)
	self:RegisterLDB() -- LibDataBroker
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'LoadDataTexts')
end

DT.RegisteredPanels = {}
DT.RegisteredDataTexts = {}
DT.PointLocation = {
	[1] = 'middle',
	[2] = 'left',
	[3] = 'right',
}

local LDBHex = '|cffFFFFFF'
function DT:SetupObjectLDB(name, obj)
	local curFrame = nil

	local function OnEnter(dt)
		DT:SetupTooltip(dt)
		if obj.OnTooltipShow then obj.OnTooltipShow(DT.tooltip) end
		if obj.OnEnter then obj.OnEnter(dt) end
		DT.tooltip:Show()
	end

	local function OnLeave(dt)
		if obj.OnLeave then obj.OnLeave(dt) end
		DT.tooltip:Hide()
	end

	local function OnClick(dt, button)
		if obj.OnClick then obj.OnClick(dt, button) end
	end

	local function textUpdate(_, Name, _, Value)
		if Value == nil or (strlen(Value) >= 3) or Value == 'n/a' or Name == Value then
			curFrame.text:SetText(Value ~= 'n/a' and Value or Name)
		else
			curFrame.text:SetFormattedText("%s: %s%s|r", Name, LDBHex, Value)
		end
	end

	local function OnCallback(newHex)
		if name and obj then
			LDBHex = newHex
			LDB.callbacks:Fire("LibDataBroker_AttributeChanged_"..name.."_text", name, nil, obj.text, obj)
		end
	end

	local function OnEvent(dt)
		curFrame = dt
		LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..name.."_text", textUpdate)
		LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..name.."_value", textUpdate)
		OnCallback(LDBHex)
	end

	local data = DT:RegisterDatatext(name, nil, OnEvent, nil, OnClick, OnEnter, OnLeave)
	data.isLibDataBroker = true

	E.valueColorUpdateFuncs[OnCallback] = true

	-- Update config if it has been loaded
	if DT.PanelLayoutOptions then
		DT:PanelLayoutOptions()
	end
end

function DT:RegisterLDB()
	for name, obj in LDB:DataObjectIterator() do
		DT:SetupObjectLDB(name, obj)
	end
end

function DT:GetDataPanelPoint(panel, i, numPoints)
	if numPoints == 1 then
		return 'CENTER', panel, 'CENTER'
	else
		if i == 1 then
			return 'CENTER', panel, 'CENTER'
		elseif i == 2 then
			return 'RIGHT', panel.dataPanels.middle, 'LEFT', -4, 0
		elseif i == 3 then
			return 'LEFT', panel.dataPanels.middle, 'RIGHT', 4, 0
		end
	end
end

function DT:UpdateAllDimensions()
	for _, panel in pairs(DT.RegisteredPanels) do
		local width = (panel:GetWidth() / panel.numPoints) - 4
		local height = panel:GetHeight() - 4
		for i=1, panel.numPoints do
			local pointIndex = DT.PointLocation[i]
			local dt = panel.dataPanels[pointIndex]
			dt:Width(width)
			dt:Height(height)
			dt:Point(DT:GetDataPanelPoint(panel, i, panel.numPoints))
		end
	end
end

function DT:Data_OnLeave()
	DT.tooltip:Hide()
end

function DT:SetupTooltip(panel)
	local parent = panel:GetParent()
	self.tooltip:Hide()
	self.tooltip:SetOwner(parent, parent.anchor, parent.xOff, parent.yOff)
	self.tooltip:ClearLines()
	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide() -- WHY??? BECAUSE FUCK GAMETOOLTIP, THATS WHY!!
	end
end

function DT:RegisterPanel(panel, numPoints, anchor, xOff, yOff)
	DT.RegisteredPanels[panel:GetName()] = panel
	panel.dataPanels = {}
	panel.numPoints = numPoints
	panel.xOff = xOff
	panel.yOff = yOff
	panel.anchor = anchor

	for i=1, numPoints do
		local pointIndex = DT.PointLocation[i]
		local dt = panel.dataPanels[pointIndex]
		if not dt then
			dt = CreateFrame('Button', 'DataText'..i, panel)
			dt:RegisterForClicks("AnyUp")
			dt.text = dt:CreateFontString(nil, 'OVERLAY')
			dt.text:SetAllPoints()
			dt.text:FontTemplate()
			dt.text:SetJustifyH("CENTER")
			dt.text:SetJustifyV("MIDDLE")
			panel.dataPanels[pointIndex] = dt
		end

		dt:Point(DT:GetDataPanelPoint(panel, i, numPoints))
	end

	panel:SetScript('OnSizeChanged', DT.UpdateAllDimensions)
	DT.UpdateAllDimensions(panel)
end

function DT:AssignPanelToDataText(panel, data, event, ...)
	data.panel = panel
	panel.name = ""

	if data.name then
		panel.name = data.name
	end

	if data.events then
		for _, ev in pairs(data.events) do
			if data.objectEvent then
				if not E:HasFunctionForObject(ev, data.objectEvent, data.objectEventFunc) then
					E:RegisterEventForObject(ev, data.objectEvent, data.objectEventFunc)
				end
			elseif data.eventFunc then
				-- use new filtered event registration for appropriate events
				if ev == "UNIT_AURA" or ev == "UNIT_RESISTANCES"  or ev == "UNIT_STATS" or ev == "UNIT_ATTACK_POWER"
				or ev == "UNIT_RANGED_ATTACK_POWER" or ev == "UNIT_TARGET" or ev == "UNIT_SPELL_HASTE" then
					pcall(panel.RegisterUnitEvent, panel, ev, 'player')
				else
					pcall(panel.RegisterEvent, panel, ev)
				end
			end
		end
	end

	local ev = event or 'ELVUI_FORCE_UPDATE'
	if data.objectEvent then
		data.objectEventFunc(data.objectEvent, ev, ...)
	elseif data.eventFunc then
		panel:SetScript('OnEvent', data.eventFunc)
		data.eventFunc(panel, ev, ...)
		print(data.name, ev, ...)
	end

	if data.onUpdate then
		panel:SetScript('OnUpdate', data.onUpdate)
		data.onUpdate(panel, 20000)
	end

	if data.onClick then
		panel:SetScript('OnClick', function(p, button)
			if E.db.datatexts.noCombatClick and InCombatLockdown() then return end
			data.onClick(p, button)
		end)
	end

	if data.onEnter then
		panel:SetScript('OnEnter', function(p)
			if E.db.datatexts.noCombatHover and InCombatLockdown() then return end
			data.onEnter(p)
		end)
	end

	if data.onLeave then
		panel:SetScript('OnLeave', data.onLeave)
	else
		panel:SetScript('OnLeave', DT.Data_OnLeave)
	end
end

function DT:LoadDataTexts(...)
	local fontTemplate = LSM:Fetch("font", self.db.font)
	local inInstance, instanceType = IsInInstance()
	local isInPVP = inInstance and instanceType == "pvp"
	local pointIndex, isBGPanel, enableBGPanel
	for panelName, panel in pairs(DT.RegisteredPanels) do
		isBGPanel = isInPVP and (panelName == 'LeftChatDataPanel' or panelName == 'RightChatDataPanel')
		enableBGPanel = isBGPanel and (not DT.ForceHideBGStats and E.db.datatexts.battleground)

		--Restore Panels
		for i=1, panel.numPoints do
			pointIndex = DT.PointLocation[i]
			local dt = panel.dataPanels[pointIndex]
			dt:UnregisterAllEvents()
			dt:SetScript('OnUpdate', nil)
			dt:SetScript('OnEnter', nil)
			dt:SetScript('OnLeave', nil)
			dt:SetScript('OnClick', nil)
			dt.text:FontTemplate(fontTemplate, self.db.fontSize, self.db.fontOutline)
			dt.text:SetWordWrap(self.db.wordWrap)
			dt.text:SetText('')
			dt.pointIndex = pointIndex

			if enableBGPanel then
				dt:RegisterEvent('UPDATE_BATTLEFIELD_SCORE')
				dt:SetScript('OnEvent', DT.UPDATE_BATTLEFIELD_SCORE)
				dt:SetScript('OnEnter', DT.BattlegroundStats)
				dt:SetScript('OnLeave', DT.Data_OnLeave)
				dt:SetScript('OnClick', DT.HideBattlegroundTexts)
				DT.UPDATE_BATTLEFIELD_SCORE(dt)
				DT.ShowingBGStats = true
			else
				-- we aren't showing BGStats anymore
				if (isBGPanel or not isInPVP) and DT.ShowingBGStats then
					DT.ShowingBGStats = nil
				end

				--Register Panel to Datatext
				for name, data in pairs(DT.RegisteredDataTexts) do
					for option, value in pairs(self.db.panels) do
						if value and type(value) == 'table' then
							if option == panelName and self.db.panels[option][pointIndex] and self.db.panels[option][pointIndex] == name then
								DT:AssignPanelToDataText(dt, data, ...)
							end
						elseif value and type(value) == 'string' and value == name then
							if self.db.panels[option] == name and option == panelName then
								DT:AssignPanelToDataText(dt, data, ...)
							end
						end
					end
				end
			end
		end
	end

	if DT.ForceHideBGStats then
		DT.ForceHideBGStats = nil
	end
end

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc, localizedName)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
	localizedName - localized name of the datetext
	objectEvent - register events on an object, using E.RegisterEventForObject instead of panel.RegisterEvent
]]
function DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc, localizedName, objectEvent)
	if not name then error('Cannot register datatext no name was provided.') end
	local data = {name = name}

	if type(events) ~= 'table' and events ~= nil then
		error('Events must be registered as a table.')
	else
		data.events = events
		data.eventFunc = eventFunc
		data.objectEvent = objectEvent
		data.objectEventFunc = data.objectEvent and function(_, ...)
			if data.eventFunc then
				data.eventFunc(data.panel, ...)
			end
		end
	end

	if updateFunc and type(updateFunc) == 'function' then
		data.onUpdate = updateFunc
	end

	if clickFunc and type(clickFunc) == 'function' then
		data.onClick = clickFunc
	end

	if onEnterFunc and type(onEnterFunc) == 'function' then
		data.onEnter = onEnterFunc
	end

	if onLeaveFunc and type(onLeaveFunc) == 'function' then
		data.onLeave = onLeaveFunc
	end

	if localizedName and type(localizedName) == 'string' then
		data.localizedName = localizedName
	end

	DT.RegisteredDataTexts[name] = data

	return data
end

E:RegisterModule(DT:GetName())
