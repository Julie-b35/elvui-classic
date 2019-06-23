local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local join = string.join
--WoW API / Variables
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local ToggleAllBags = ToggleAllBags
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local CURRENCY = CURRENCY
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS

local displayString = '';
local lastPanel

local function OnEvent(self)
	lastPanel = self
	local free, total = 0, 0
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
	end
	self.text:SetFormattedText(displayString, L["Bags"]..': ', total - free, total)
end

local function OnClick()
	ToggleAllBags()
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s", hex, "%d/%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Bags', {"PLAYER_ENTERING_WORLD", "BAG_UPDATE"}, OnEvent, nil, OnClick, nil, nil, L["Bags"])
