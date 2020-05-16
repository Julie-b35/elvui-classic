local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local _G = _G
local sort = sort
local ipairs = ipairs
local strlen = strlen
local strjoin = strjoin
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldStatData = GetBattlefieldStatData
local GetBattlefieldScore = GetBattlefieldScore
local BATTLEGROUND = BATTLEGROUND

local displayString = ''
local holder = {
	LEFT = { data = {}, _G.KILLS, _G.KILLING_BLOWS, _G.DEATHS },
	RIGHT = { data = {}, _G.DAMAGE, _G.SHOW_COMBAT_HEALING, _G.HONOR }
}

function DT:UpdateBattlePanel(which)
	local info = which and holder[which]

	local panel = info and info.dataPanels
	if not panel then return end

	for i, name in ipairs(info) do
		local dt = panel[i]
		if dt and dt.text then
			dt.text:SetFormattedText(displayString, name, info.data[i] or 0)
		end
	end
end

local myIndex
local LEFT = holder.LEFT.data
local RIGHT = holder.RIGHT.data
function DT:UPDATE_BATTLEFIELD_SCORE()
	myIndex = nil

	if not RIGHT.panel then RIGHT.panel = _G.RightChatDataPanel and _G.RightChatDataPanel.dataPanels end
	if not LEFT.panel then LEFT.panel = _G.LeftChatDataPanel and _G.LeftChatDataPanel.dataPanels end
	if not LEFT.panel then return end

	for i = 1, GetNumBattlefieldScores() do
		local name, kb, hks, deaths, honor, _, _, _, _, dmg, heals = GetBattlefieldScore(i)
		if name == E.myname then
			LEFT[1], LEFT[2], LEFT[3] = E:ShortValue(hks), E:ShortValue(kb), E:ShortValue(deaths)
			RIGHT[1], RIGHT[2], RIGHT[3] = E:ShortValue(dmg), E:ShortValue(heals), E:ShortValue(honor)
			myIndex = i
			break
		end
	end

	DT:UpdateBattlePanel('LEFT')
	DT:UpdateBattlePanel('RIGHT')
end

local function columnSort(lhs,rhs)
	return lhs.orderIndex < rhs.orderIndex
end

function DT:HoverBattleStats()
	DT:SetupTooltip(self)

	if DT.ShowingBattleStats == 'pvp' then
		local columns = myIndex and C_PvP_GetMatchPVPStatColumns()
		if columns then
			sort(columns, columnSort)

			local firstLine
			local classColor = E:ClassColor(E.myclass)
			DT.tooltip:AddDoubleLine(BATTLEGROUND, E.MapInfo.name, 1,1,1, classColor.r, classColor.g, classColor.b)

			-- Add extra statistics to watch based on what BG you are in.
			for _, stat in ipairs(columns) do
				local name = stat.name
				if name and strlen(name) > 0 then
					if not firstLine then
						DT.tooltip:AddLine(' ')
						firstLine = true
					end

					DT.tooltip:AddDoubleLine(name, GetBattlefieldStatData(myIndex, stat.pvpStatID), 1,1,1)
				end
			end

			DT.tooltip:Show()
		end
	end
end

function DT:ToggleBattleStats()
	if DT.ForceHideBGStats then
		DT.ForceHideBGStats = nil
		E:Print(L["Battleground datatexts will now show again if you are inside a battleground."])
	else
		DT.ForceHideBGStats = true
		E:Print(L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."])
	end

	DT:UpdatePanelInfo('LeftChatDataPanel')
	DT:UpdatePanelInfo('RightChatDataPanel')

	if DT.ShowingBattleStats then
		DT:UpdateBattlePanel('LEFT')
		DT:UpdateBattlePanel('RIGHT')
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s: ", hex, "%s|r")

	DT:UpdateBattlePanel('LEFT')
	DT:UpdateBattlePanel('RIGHT')
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true
