local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local _G = _G
local select, pairs = select, pairs
local format = string.format
--WoW API / Variables
local GetCurrencyInfo = GetCurrencyInfo
local GetMoney = GetMoney
local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY
local EXPANSION_NAME7 = EXPANSION_NAME7
local OTHER = OTHER

-- Currencies we care about
local iconString = "|T%s:16:16:0:0:64:64:4:60:4:60|t"

-- CurrencyList for config
local currencyList = {}
currencyList.GOLD = BONUS_ROLL_REWARD_MONEY
DT.CurrencyList = currencyList

local function OnClick()
	_G.ToggleCharacter("TokenFrame")
end

local goldText
local function OnEvent(self)
	goldText = E:FormatMoney(GetMoney(), E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins)
	local chosenCurrency = Currencies[E.db.datatexts.currencies.displayedCurrency]
	if E.db.datatexts.currencies.displayedCurrency == "GOLD" or chosenCurrency == nil then
		self.text:SetText(goldText)
	else
		local currencyAmount = select(2, GetCurrencyInfo(chosenCurrency.ID))
		if E.db.datatexts.currencies.displayStyle == "ICON" then
			self.text:SetFormattedText("%s %d", chosenCurrency.ICON, currencyAmount)
		elseif E.db.datatexts.currencies.displayStyle == "ICON_TEXT" then
			self.text:SetFormattedText("%s %s %d", chosenCurrency.ICON, chosenCurrency.NAME, currencyAmount)
		else --ICON_TEXT_ABBR
			self.text:SetFormattedText("%s %s %d", chosenCurrency.ICON, E:AbbreviateString(chosenCurrency.NAME), currencyAmount)
		end
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L["Gold"]..":", goldText, nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine(EXPANSION_NAME7) --"BfA"
	DT.tooltip:AddDoubleLine(Currencies.RICH_AZERITE_FRAGMENT.NAME, select(2, GetCurrencyInfo(Currencies.RICH_AZERITE_FRAGMENT.ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies.SEAFARERS_DUBLOON.NAME, select(2, GetCurrencyInfo(Currencies.SEAFARERS_DUBLOON.ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies.SEAL_OF_WARTORN_FATE.NAME, select(2, GetCurrencyInfo(Currencies.SEAL_OF_WARTORN_FATE.ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies.WAR_RESOURCES.NAME, select(2, GetCurrencyInfo(Currencies.WAR_RESOURCES.ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies.WAR_SUPPLIES.NAME, select(2, GetCurrencyInfo(Currencies.WAR_SUPPLIES.ID)), 1, 1, 1)
	if E.myfaction == "Alliance" then
		DT.tooltip:AddDoubleLine(Currencies['7TH_LEGION_SERVICE_MEDAL'].NAME, select(2, GetCurrencyInfo(Currencies['7TH_LEGION_SERVICE_MEDAL'].ID)), 1, 1, 1)
	else
		DT.tooltip:AddDoubleLine(Currencies.HONORBOUND_SERVICE_MEDAL.NAME, select(2, GetCurrencyInfo(Currencies.HONORBOUND_SERVICE_MEDAL.ID)), 1, 1, 1)
	end
	DT.tooltip:AddDoubleLine(Currencies.TITAN_RESIDUUM.NAME, select(2, GetCurrencyInfo(Currencies.TITAN_RESIDUUM.ID)), 1, 1, 1)
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine(OTHER)
	DT.tooltip:AddDoubleLine(Currencies.DARKMOON_PRIZE_TICKET.NAME, select(2, GetCurrencyInfo(Currencies.DARKMOON_PRIZE_TICKET.ID)), 1, 1, 1)

	--[[
		If the "Display In Tooltip" box is checked (on by default), then also display custom
		currencies in the tooltip.
	]]
	local shouldAddHeader = true
	for _, info in pairs(E.global.datatexts.customCurrencies) do
		if info.DISPLAY_IN_MAIN_TOOLTIP then
			if shouldAddHeader then
				DT.tooltip:AddLine(' ')
				DT.tooltip:AddLine(L["Custom Currency"])
				shouldAddHeader = false
			end

			DT.tooltip:AddDoubleLine(info.NAME, select(2, GetCurrencyInfo(info.ID)), 1, 1, 1)
		end
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Currencies', {'PLAYER_ENTERING_WORLD', 'PLAYER_MONEY', 'SEND_MAIL_MONEY_CHANGED', 'SEND_MAIL_COD_CHANGED', 'PLAYER_TRADE_MONEY', 'TRADE_MONEY_CHANGED', 'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, OnClick, OnEnter, nil, CURRENCY)

