local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, 'ElvUI was unable to locate ElvUF.')
local Translit = E.Libs.Translit
local translitMark = '!'

local _G = _G
local tonumber, next = tonumber, next
local pairs, wipe, floor, ceil = pairs, wipe, floor, ceil
local gmatch, gsub, format, select = gmatch, gsub, format, select
local strfind, strmatch, strlower, strsplit = strfind, strmatch, strlower, strsplit
local utf8lower, utf8sub, utf8len = string.utf8lower, string.utf8sub, string.utf8len

local UnitIsFeignDeath = UnitIsFeignDeath
local CreateTextureMarkup = CreateTextureMarkup
local UnitFactionGroup = UnitFactionGroup
local GetCVarBool = GetCVarBool
local GetGuildInfo = GetGuildInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetPVPTimer = GetPVPTimer
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetTime = GetTime
local GetUnitSpeed = GetUnitSpeed
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsAFK = UnitIsAFK
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDND = UnitIsDND
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitPVPName = UnitPVPName
local UnitReaction = UnitReaction
local CreateAtlasMarkup = CreateAtlasMarkup
local GetThreatStatusColor = GetThreatStatusColor
local UnitDetailedThreatSituation = UnitDetailedThreatSituation

local CHAT_FLAG_AFK = CHAT_FLAG_AFK:gsub('<(.-)>', '|r<|cffFF3333%1|r>')
local CHAT_FLAG_DND = CHAT_FLAG_DND:gsub('<(.-)>', '|r<|cffFFFF33%1|r>')

local HasPetUI = HasPetUI
local UnitPVPRank = UnitPVPRank
local GetPVPRankInfo = GetPVPRankInfo
local GetPetHappiness = GetPetHappiness
local GetPetLoyalty = GetPetLoyalty
local GetPetFoodTypes = GetPetFoodTypes

local SPELL_POWER_MANA = Enum.PowerType.Mana or 0
local DEFAULT_AFK_MESSAGE = DEFAULT_AFK_MESSAGE
local LEVEL = LEVEL
local PVP = PVP

-- GLOBALS: ElvUF, Hex, _TAGS, _COLORS

--Expose local functions for plugins onto this table
E.TagFunctions = {}

------------------------------------------------------------------------
--	Tags
------------------------------------------------------------------------

local function UnitName(unit)
	local name, realm = _G.UnitName(unit)

	if realm and realm ~= "" then
		return name, realm
	else
		return name
	end
end
E.TagFunctions.UnitName = UnitName

local function Abbrev(name)
	local letters, lastWord = '', strmatch(name, '.+%s(.+)$')
	if lastWord then
		for word in gmatch(name, '.-%s') do
			local firstLetter = utf8sub(gsub(word, '^[%s%p]*', ''), 1, 1)
			if firstLetter ~= utf8lower(firstLetter) then
				letters = format('%s%s. ', letters, firstLetter)
			end
		end
		name = format('%s%s', letters, lastWord)
	end
	return name
end
E.TagFunctions.Abbrev = Abbrev

ElvUF.Tags.Events['afk'] = 'PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['afk'] = function(unit)
	if UnitIsAFK(unit) then
		return format('|cffFFFFFF[|r|cffFF0000%s|r|cFFFFFFFF]|r', DEFAULT_AFK_MESSAGE)
	end
end

ElvUF.Tags.Events['faction:icon'] = 'UNIT_FACTION'
ElvUF.Tags.Methods['faction:icon'] = function(unit)
	local factionGroup = UnitFactionGroup(unit)
	if factionGroup == 'Horde' or factionGroup == 'Alliance' then
		return CreateTextureMarkup(format([[Interface\FriendsFrame\PlusManz-%s]], factionGroup), 16, 16, 16, 16, 0, 1, 0, 1, 0, 0)
	end
end

ElvUF.Tags.Events['healthcolor'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['healthcolor'] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return Hex(0.84, 0.75, 0.65)
	else
		local r, g, b = ElvUF:ColorGradient(UnitHealth(unit), UnitHealthMax(unit), 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return Hex(r, g, b)
	end
end


ElvUF.Tags.Events['status:text'] = 'PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['status:text'] = function(unit)
	if UnitIsAFK(unit) then
		return CHAT_FLAG_AFK
	elseif UnitIsDND(unit) then
		return CHAT_FLAG_DND
	end
end

ElvUF.Tags.Events['status:icon'] = 'PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['status:icon'] = function(unit)
	if UnitIsAFK(unit) then
		return CreateTextureMarkup('Interface\\FriendsFrame\\StatusIcon-Away', 16, 16, 16, 16, 0, 1, 0, 1, 0, 0)
	elseif UnitIsDND(unit) then
		return CreateTextureMarkup('Interface\\FriendsFrame\\StatusIcon-DnD', 16, 16, 16, 16, 0, 1, 0, 1, 0, 0)
	end
end

ElvUF.Tags.Events['name:abbrev'] = 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT'
ElvUF.Tags.Methods['name:abbrev'] = function(unit)
	local name = UnitName(unit)
	if name and strfind(name, '%s') then
		name = Abbrev(name)
	end

	return name
end

ElvUF.Tags.Events['name:last'] = 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT'
ElvUF.Tags.Methods['name:last'] = function(unit)
	local name = UnitName(unit)
	if name and strfind(name, '%s') then
		name = strmatch(name, '([%S]+)$')
	end

	return name
end

ElvUF.Tags.Events['health:deficit-percent:nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:deficit-percent:nostatus'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = (min / max) - 1
	if deficit ~= 0 then
		return E:GetFormattedText('PERCENT', deficit, -1)
	end
end

for textFormat in pairs(E.GetFormattedTextStyles) do
	local tagTextFormat = strlower(gsub(textFormat, '_', '-'))
	ElvUF.Tags.Events[format('health:%s', tagTextFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
	ElvUF.Tags.Methods[format('health:%s', tagTextFormat)] = function(unit)
		local status = not UnitIsFeignDeath(unit) and UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		if (status) then
			return status
		else
			local min, max = UnitHealth(unit), UnitHealthMax(unit)
			return E:GetFormattedText(textFormat, min, max)
		end
	end

	ElvUF.Tags.Events[format('health:%s-nostatus', tagTextFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
	ElvUF.Tags.Methods[format('health:%s-nostatus', tagTextFormat)] = function(unit)
		local min, max = UnitHealth(unit), UnitHealthMax(unit)
		return E:GetFormattedText(textFormat, min, max)
	end

	ElvUF.Tags.Events[format('power:%s', tagTextFormat)] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
	ElvUF.Tags.Methods[format('power:%s', tagTextFormat)] = function(unit)
		local pType = UnitPowerType(unit)
		local min = UnitPower(unit, pType)
		if min ~= 0 and tagTextFormat ~= 'deficit' then
			return E:GetFormattedText(textFormat, min, UnitPowerMax(unit, pType))
		end
	end

	ElvUF.Tags.Events[format('mana:%s', tagTextFormat)] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER'
	ElvUF.Tags.Methods[format('mana:%s', tagTextFormat)] = function(unit)
		local min = UnitPower(unit, SPELL_POWER_MANA)

		if min == 0 and tagTextFormat ~= 'deficit' then
			return
		else
			return E:GetFormattedText(textFormat, UnitPower(unit, SPELL_POWER_MANA), UnitPowerMax(unit, SPELL_POWER_MANA))
		end
	end

	if tagTextFormat ~= 'percent' then
		ElvUF.Tags.Events[format('health:%s:shortvalue', tagTextFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
		ElvUF.Tags.Methods[format('health:%s:shortvalue', tagTextFormat)] = function(unit)
			local status = not UnitIsFeignDeath(unit) and UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
			if (status) then
				return status
			else
				local min, max = UnitHealth(unit), UnitHealthMax(unit)
				return E:GetFormattedText(textFormat, min, max, nil, true)
			end
		end

		ElvUF.Tags.Events[format('health:%s-nostatus:shortvalue', tagTextFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH'
		ElvUF.Tags.Methods[format('health:%s-nostatus:shortvalue', tagTextFormat)] = function(unit)
			local min, max = UnitHealth(unit), UnitHealthMax(unit)
			return E:GetFormattedText(textFormat, min, max, nil, true)
		end


		ElvUF.Tags.Events[format('power:%s:shortvalue', tagTextFormat)] = 'UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER'
		ElvUF.Tags.Methods[format('power:%s:shortvalue', tagTextFormat)] = function(unit)
			local pType = UnitPowerType(unit)
			return E:GetFormattedText(textFormat, UnitPower(unit, pType), UnitPowerMax(unit, pType), nil, true)
		end

		ElvUF.Tags.Events[format('mana:%s:shortvalue', tagTextFormat)] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER'
		ElvUF.Tags.Methods[format('mana:%s:shortvalue', tagTextFormat)] = function(unit)
			return E:GetFormattedText(textFormat, UnitPower(unit, SPELL_POWER_MANA), UnitPowerMax(unit, SPELL_POWER_MANA), nil, true)
		end
	end
end

for textFormat, length in pairs({veryshort = 5, short = 10, medium = 15, long = 20}) do
	ElvUF.Tags.Events[format('health:deficit-percent:name-%s', textFormat)] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods[format('health:deficit-percent:name-%s', textFormat)] = function(unit)
		local cur, max = UnitHealth(unit), UnitHealthMax(unit)
		local deficit = max - cur

		if deficit > 0 and cur > 0 then
			return _TAGS["health:deficit-percent:nostatus"](unit)
		else
			return _TAGS[format('name:%s', textFormat)](unit)
		end
	end

	ElvUF.Tags.Events[format('name:abbrev:%s', textFormat)] = 'UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods[format('name:abbrev:%s', textFormat)] = function(unit)
		local name = UnitName(unit)
		if name and strfind(name, '%s') then
			name = Abbrev(name)
		end

		if name then
			return E:ShortenString(name, length)
		end
	end

	ElvUF.Tags.Events[format('name:%s', textFormat)] = 'UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods[format('name:%s', textFormat)] = function(unit)
		local name = UnitName(unit)
		if name then
			return E:ShortenString(name, length)
		end
	end

	ElvUF.Tags.Events[format('name:%s:status', textFormat)] = 'UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_HEALTH_FREQUENT'
	ElvUF.Tags.Methods[format('name:%s:status', textFormat)] = function(unit)
		local status = not UnitIsFeignDeath(unit) and UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		local name = UnitName(unit)
		if status then
			return status
		elseif name then
			return E:ShortenString(name, length)
		end
	end

	ElvUF.Tags.Events[format('name:%s:translit', textFormat)] = 'UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods[format('name:%s:translit', textFormat)] = function(unit)
		local name = Translit:Transliterate(UnitName(unit), translitMark)
		if name then
			return E:ShortenString(name, length)
		end
	end

	ElvUF.Tags.Events[format('target:%s', textFormat)] = 'UNIT_TARGET'
	ElvUF.Tags.Methods[format('target:%s', textFormat)] = function(unit)
		local targetName = UnitName(unit.."target")
		if targetName then
			return E:ShortenString(targetName, length)
		end
	end

	ElvUF.Tags.Events[format('target:%s:translit', textFormat)] = 'UNIT_TARGET'
	ElvUF.Tags.Methods[format('target:%s:translit', textFormat)] = function(unit)
		local targetName = Translit:Transliterate(UnitName(unit.."target"), translitMark)
		if targetName then
			return E:ShortenString(targetName, length)
		end
	end
end

ElvUF.Tags.Events['name:abbrev'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbrev'] = function(unit)
	local name = UnitName(unit)

	if name and strfind(name, '%s') then
		name = Abbrev(name)
	end

	return name ~= nil and name or ''
end

ElvUF.Tags.Events['health:max'] = 'UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:max'] = function(unit)
	local max = UnitHealthMax(unit)
	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.Tags.Events['power:max'] = 'UNIT_DISPLAYPOWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:max'] = function(unit)
	local pType = UnitPowerType(unit)
	local max = UnitPowerMax(unit, pType)

	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.Tags.Events['mana:max'] = 'UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:max'] = function(unit)
	local max = UnitPowerMax(unit, SPELL_POWER_MANA)

	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.Tags.Events['health:max:shortvalue'] = 'UNIT_MAXHEALTH'
ElvUF.Tags.Methods['health:max:shortvalue'] = function(unit)
	local _, max = UnitHealth(unit), UnitHealthMax(unit)

	return E:GetFormattedText('CURRENT', max, max, nil, true)
end

ElvUF.Tags.Events['power:max:shortvalue'] = 'UNIT_DISPLAYPOWER UNIT_MAXPOWER'
ElvUF.Tags.Methods['power:max:shortvalue'] = function(unit)
	local pType = UnitPowerType(unit)
	local max = UnitPowerMax(unit, pType)

	return E:GetFormattedText('CURRENT', max, max, nil, true)
end

ElvUF.Tags.Events['mana:max:shortvalue'] = 'UNIT_MAXPOWER'
ElvUF.Tags.Methods['mana:max:shortvalue'] = function(unit)
	local max = UnitPowerMax(unit, SPELL_POWER_MANA)

	return E:GetFormattedText('CURRENT', max, max, nil, true)
end

do
	local function NameHealthColor(tags,hex,unit,default)
		if hex == 'class' or hex == 'reaction' then
			return tags.namecolor(unit) or default
		elseif hex and strmatch(hex, '^%x%x%x%x%x%x$') then
			return '|cFF'..hex
		end

		return default
	end
	E.TagFunctions.NameHealthColor = NameHealthColor

	-- the third arg here is added from the user as like [name:health{ff00ff:00ff00}] or [name:health{class:00ff00}]
	ElvUF.Tags.Events['name:health'] = 'UNIT_NAME_UPDATE UNIT_FACTION UNIT_HEALTH_FREQUENT UNIT_HEALTH UNIT_MAXHEALTH'
	ElvUF.Tags.Methods['name:health'] = function(unit, _, args)
		local name = UnitName(unit)
		if not name then return '' end

		local min, max, bco, fco = UnitHealth(unit), UnitHealthMax(unit), strsplit(':', args or '')
		local to = ceil(utf8len(name) * (min / max))

		local fill = NameHealthColor(_TAGS, fco, unit, '|cFFff3333')
		local base = NameHealthColor(_TAGS, bco, unit, '|cFFffffff')

		return to > 0 and (base..utf8sub(name, 0, to)..fill..utf8sub(name, to+1, -1)) or fill..name
	end
end

ElvUF.Tags.Events['health:deficit-percent:name'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['health:deficit-percent:name'] = function(unit)
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - cur

	if deficit > 0 and cur > 0 then
		return _TAGS["health:percent-nostatus"](unit)
	else
		return _TAGS.name(unit)
	end
end

ElvUF.Tags.Methods['manacolor'] = function()
	local color = ElvUF.colors.power.MANA
	if color then
		return Hex(color[1], color[2], color[3])
	else
		local mana = _G.PowerBarColor.MANA
		return Hex(mana.r, mana.g, mana.b)
	end
end

ElvUF.Tags.Events['difficultycolor'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags.Methods['difficultycolor'] = function(unit)
	local c = GetCreatureDifficultyColor(UnitLevel(unit))

	return Hex(c.r, c.g, c.b)
end

ElvUF.Tags.Events['namecolor'] = 'UNIT_NAME_UPDATE UNIT_FACTION'
ElvUF.Tags.Methods['namecolor'] = function(unit)
	local unitReaction = UnitReaction(unit, 'player')
	local unitPlayer = UnitIsPlayer(unit)
	if unitPlayer then
		local _, unitClass = UnitClass(unit)
		local class = ElvUF.colors.class[unitClass]
		if not class then return end
		return Hex(class[1], class[2], class[3])
	elseif unitReaction then
		local reaction = ElvUF.colors.reaction[unitReaction]
		return Hex(reaction[1], reaction[2], reaction[3])
	else
		return '|cFFC2C2C2'
	end
end

ElvUF.Tags.Events['reactioncolor'] = 'UNIT_NAME_UPDATE UNIT_FACTION'
ElvUF.Tags.Methods['reactioncolor'] = function(unit)
	local unitReaction = UnitReaction(unit, 'player')
	if (unitReaction) then
		local reaction = ElvUF.colors.reaction[unitReaction]
		return Hex(reaction[1], reaction[2], reaction[3])
	else
		return '|cFFC2C2C2'
	end
end

ElvUF.Tags.Events['smartlevel'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags.Methods['smartlevel'] = function(unit)
	local level = UnitLevel(unit)
	if level == UnitLevel('player') then
		return nil
	elseif level > 0 then
		return level
	else
		return '??'
	end
end

ElvUF.Tags.Events['realm'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['realm'] = function(unit)
	local _, realm = UnitName(unit)
	if realm and realm ~= "" then
		return realm
	end
end

ElvUF.Tags.Events['realm:dash'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['realm:dash'] = function(unit)
	local _, realm = UnitName(unit)
	if realm and (realm ~= "" and realm ~= E.myrealm) then
		return format("-%s", realm)
	elseif realm ~= "" then
		return realm
	end
end

ElvUF.Tags.Events['realm:translit'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['realm:translit'] = function(unit)
	local _, realm = Translit:Transliterate(UnitName(unit), translitMark)
	if realm and realm ~= "" then
		return realm
	end
end

ElvUF.Tags.Events['realm:dash:translit'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['realm:dash:translit'] = function(unit)
	local _, realm = Translit:Transliterate(UnitName(unit), translitMark)

	if realm and (realm ~= "" and realm ~= E.myrealm) then
		return format("-%s", realm)
	elseif realm ~= "" then
		return realm
	end
end

ElvUF.Tags.SharedEvents.PLAYER_GUILD_UPDATE = true

ElvUF.Tags.Events['guild'] = 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return GetGuildInfo(unit) or nil
	end
end

ElvUF.Tags.Events['guild:brackets'] = 'PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild:brackets'] = function(unit)
	local guildName = GetGuildInfo(unit)

	return guildName and format('<%s>', guildName) or nil
end

ElvUF.Tags.Events['guild:translit'] = 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild:translit'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return Translit:Transliterate(GetGuildInfo(unit), translitMark) or nil
	end
end

ElvUF.Tags.Events['guild:brackets:translit'] = 'PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild:brackets:translit'] = function(unit)
	local guildName = Translit:Transliterate(GetGuildInfo(unit), translitMark)

	return guildName and format('<%s>', guildName) or nil
end

ElvUF.Tags.Events['target'] = 'UNIT_TARGET'
ElvUF.Tags.Methods['target'] = function(unit)
	local targetName = UnitName(unit..'target')
	return targetName or nil
end

ElvUF.Tags.Events['target:translit'] = 'UNIT_TARGET'
ElvUF.Tags.Methods['target:translit'] = function(unit)
	local targetName = Translit:Transliterate(UnitName(unit..'target'), translitMark)
	return targetName or nil
end

ElvUF.Tags.Events['happiness:full'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['happiness:full'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (UnitIsUnit('pet', unit) and hasPetUI and isHunterPet) then
		return _G['PET_HAPPINESS'..GetPetHappiness()]
	end
end

ElvUF.Tags.Events['happiness:icon'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['happiness:icon'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (UnitIsUnit('pet', unit) and hasPetUI and isHunterPet) then
		local left, right, top, bottom
		local happiness = GetPetHappiness()

		if(happiness == 1) then
			left, right, top, bottom = 0.375, 0.5625, 0, 0.359375
		elseif(happiness == 2) then
			left, right, top, bottom = 0.1875, 0.375, 0, 0.359375
		elseif(happiness == 3) then
			left, right, top, bottom = 0, 0.1875, 0, 0.359375
		end

		return CreateTextureMarkup([[Interface\PetPaperDollFrame\UI-PetHappiness]], 128, 64, 16, 16, left, right, top, bottom, 0, 0)
	end
end

ElvUF.Tags.Events['happiness:discord'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['happiness:discord'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (UnitIsUnit('pet', unit) and hasPetUI and isHunterPet) then
		local happiness = GetPetHappiness()

		if(happiness == 1) then
			return CreateTextureMarkup([[Interface\AddOns\ElvUI\Media\ChatEmojis\Rage]], 32, 32, 16, 16, 0, 1, 0, 1, 0, 0)
		elseif(happiness == 2) then
			return CreateTextureMarkup([[Interface\AddOns\ElvUI\Media\ChatEmojis\SlightFrown]], 32, 32, 16, 16, 0, 1, 0, 1, 0, 0)
		elseif(happiness == 3) then
			return CreateTextureMarkup([[Interface\AddOns\ElvUI\Media\ChatEmojis\HeartEyes]], 32, 32, 16, 16, 0, 1, 0, 1, 0, 0)
		end
	end
end

ElvUF.Tags.Events['happiness:color'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['happiness:color'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (UnitIsUnit('pet', unit) and hasPetUI and isHunterPet) then
		return Hex(_COLORS.happiness[GetPetHappiness()])
	end
end

ElvUF.Tags.Events['loyalty'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['loyalty'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (UnitIsUnit('pet', unit) and hasPetUI and isHunterPet) then
		local loyalty = gsub(GetPetLoyalty(), '.-(%d).*', '%1')
		return loyalty
	end
end

ElvUF.Tags.Events['diet'] = 'UNIT_HAPPINESS PET_UI_UPDATE'
ElvUF.Tags.Methods['diet'] = function(unit)
	local hasPetUI, isHunterPet = HasPetUI()
	if (UnitIsUnit('pet', unit) and hasPetUI and isHunterPet) then
		return GetPetFoodTypes()
	end
end

ElvUF.Tags.Events['threat:percent'] = 'UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['threat:percent'] = function(unit)
	local _, _, percent = UnitDetailedThreatSituation('player', unit)
	if percent and percent > 0 and (IsInGroup() or UnitExists('pet')) then
		return format('%.0f%%', percent)
	end
end

ElvUF.Tags.Events['threat:current'] = 'UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['threat:current'] = function(unit)
	local _, _, percent, _, threatvalue = UnitDetailedThreatSituation('player', unit)
	if percent and percent > 0 and (IsInGroup() or UnitExists('pet')) then
		return E:ShortValue(threatvalue)
	end
end

ElvUF.Tags.Events['threatcolor'] = 'UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['threatcolor'] = function(unit)
	local _, status = UnitDetailedThreatSituation('player', unit)
	if status and (IsInGroup() or UnitExists('pet')) then
		return Hex(GetThreatStatusColor(status))
	end
end

local unitStatus = {}
ElvUF.Tags.OnUpdateThrottle['statustimer'] = 1
ElvUF.Tags.Methods['statustimer'] = function(unit)
	if not UnitIsPlayer(unit) then return end

	local guid = UnitGUID(unit)
	local status = unitStatus[guid]

	if UnitIsAFK(unit) then
		if not status or status[1] ~= 'AFK' then
			unitStatus[guid] = {'AFK', GetTime()}
		end
	elseif UnitIsDND(unit) then
		if not status or status[1] ~= 'DND' then
			unitStatus[guid] = {'DND', GetTime()}
		end
	elseif UnitIsDead(unit) or UnitIsGhost(unit) then
		if not status or status[1] ~= 'Dead' then
			unitStatus[guid] = {'Dead', GetTime()}
		end
	elseif not UnitIsConnected(unit) then
		if not status or status[1] ~= 'Offline' then
			unitStatus[guid] = {'Offline', GetTime()}
		end
	else
		unitStatus[guid] = nil
	end

	if status ~= unitStatus[guid] then
		status = unitStatus[guid]
	end

	if status then
		local timer = GetTime() - status[2]
		local mins = floor(timer / 60)
		local secs = floor(timer - (mins * 60))
		return format("%s (%01.f:%02.f)", L[status[1]], mins, secs)
	end
end

ElvUF.Tags.OnUpdateThrottle['pvptimer'] = 1
ElvUF.Tags.Methods['pvptimer'] = function(unit)
	if UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit) then
		local timer = GetPVPTimer()

		if timer ~= 301000 and timer ~= -1 then
			local mins = floor((timer / 1000) / 60)
			local secs = floor((timer / 1000) - (mins * 60))
			return format('%s (%01.f:%02.f)', PVP, mins, secs)
		else
			return PVP
		end
	end
end

local GroupUnits = {}
local f = CreateFrame('Frame')

f:RegisterEvent('GROUP_ROSTER_UPDATE')
f:SetScript('OnEvent', function()
	local groupType, groupSize
	wipe(GroupUnits)

	if IsInRaid() then
		groupType = 'raid'
		groupSize = GetNumGroupMembers()
	elseif IsInGroup() then
		groupType = 'party'
		groupSize = GetNumGroupMembers() - 1
		GroupUnits.player = true
	else
		groupType = 'solo'
		groupSize = 1
	end

	for index = 1, groupSize do
		local unit = groupType..index
		if not UnitIsUnit(unit, 'player') then
			GroupUnits[unit] = true
		end
	end
end)

ElvUF.Tags.OnUpdateThrottle['nearbyplayers:8'] = 0.25
ElvUF.Tags.Methods['nearbyplayers:8'] = function(unit)
	local unitsInRange, distance = 0
	if UnitIsConnected(unit) then
		for groupUnit in pairs(GroupUnits) do
			if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
				distance = E:GetDistance(unit, groupUnit)
				if distance and distance <= 8 then
					unitsInRange = unitsInRange + 1
				end
			end
		end
	end

	return unitsInRange
end

ElvUF.Tags.OnUpdateThrottle['nearbyplayers:10'] = 0.25
ElvUF.Tags.Methods['nearbyplayers:10'] = function(unit)
	local unitsInRange, distance = 0
	if UnitIsConnected(unit) then
		for groupUnit in pairs(GroupUnits) do
			if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
				distance = E:GetDistance(unit, groupUnit)
				if distance and distance <= 10 then
					unitsInRange = unitsInRange + 1
				end
			end
		end
	end

	return unitsInRange
end

ElvUF.Tags.OnUpdateThrottle['nearbyplayers:30'] = 0.25
ElvUF.Tags.Methods['nearbyplayers:30'] = function(unit)
	local unitsInRange, distance = 0
	if UnitIsConnected(unit) then
		for groupUnit in pairs(GroupUnits) do
			if not UnitIsUnit(unit, groupUnit) and UnitIsConnected(groupUnit) then
				distance = E:GetDistance(unit, groupUnit)
				if distance and distance <= 30 then
					unitsInRange = unitsInRange + 1
				end
			end
		end
	end

	return unitsInRange
end

ElvUF.Tags.OnUpdateThrottle['distance'] = 0.1
ElvUF.Tags.Methods['distance'] = function(unit)
	local distance
	if UnitIsConnected(unit) and not UnitIsUnit(unit, 'player') then
		distance = E:GetDistance('player', unit)

		if distance then
			distance = format("%.1f", distance)
		end
	end

	return distance
end

local speedText = _G.SPEED
local baseSpeed = _G.BASE_MOVEMENT_SPEED
ElvUF.Tags.OnUpdateThrottle['speed:percent'] = 0.1
ElvUF.Tags.Methods['speed:percent'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	local currentSpeedInPercent = (currentSpeedInYards / baseSpeed) * 100

	return format('%s: %d%%', speedText, currentSpeedInPercent)
end

ElvUF.Tags.OnUpdateThrottle['speed:percent-moving'] = 0.1
ElvUF.Tags.Methods['speed:percent-moving'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	local currentSpeedInPercent = currentSpeedInYards > 0 and ((currentSpeedInYards / baseSpeed) * 100)

	if currentSpeedInPercent then
		currentSpeedInPercent = format('%s: %d%%', speedText, currentSpeedInPercent)
	end

	return currentSpeedInPercent
end

ElvUF.Tags.OnUpdateThrottle['speed:percent-raw'] = 0.1
ElvUF.Tags.Methods['speed:percent-raw'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	local currentSpeedInPercent = (currentSpeedInYards / baseSpeed) * 100

	return format('%d%%', currentSpeedInPercent)
end

ElvUF.Tags.OnUpdateThrottle['speed:percent-moving-raw'] = 0.1
ElvUF.Tags.Methods['speed:percent-moving-raw'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	local currentSpeedInPercent = currentSpeedInYards > 0 and ((currentSpeedInYards / baseSpeed) * 100)

	if currentSpeedInPercent then
		currentSpeedInPercent = format('%d%%', currentSpeedInPercent)
	end

	return currentSpeedInPercent
end

ElvUF.Tags.OnUpdateThrottle['speed:yardspersec'] = 0.1
ElvUF.Tags.Methods['speed:yardspersec'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	return format("%s: %.1f", speedText, currentSpeedInYards)
end

ElvUF.Tags.OnUpdateThrottle['speed:yardspersec-moving'] = 0.1
ElvUF.Tags.Methods['speed:yardspersec-moving'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	return currentSpeedInYards > 0 and format("%s: %.1f", speedText, currentSpeedInYards) or nil
end

ElvUF.Tags.OnUpdateThrottle['speed:yardspersec-raw'] = 0.1
ElvUF.Tags.Methods['speed:yardspersec-raw'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	return format('%.1f', currentSpeedInYards)
end

ElvUF.Tags.OnUpdateThrottle['speed:yardspersec-moving-raw'] = 0.1
ElvUF.Tags.Methods['speed:yardspersec-moving-raw'] = function(unit)
	local currentSpeedInYards = GetUnitSpeed(unit)
	return currentSpeedInYards > 0 and format("%.1f", currentSpeedInYards) or nil
end

ElvUF.Tags.Events['classificationcolor'] = 'UNIT_CLASSIFICATION_CHANGED'
ElvUF.Tags.Methods['classificationcolor'] = function(unit)
	local c = UnitClassification(unit)
	if c == 'rare' or c == 'elite' then
		return Hex(1, 0.5, 0.25)
	elseif c == 'rareelite' or c == 'worldboss' then
		return Hex(1, 0, 0)
	end
end

ElvUF.Tags.Events['classification:icon'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['classification:icon'] = function(unit)
	if UnitIsPlayer(unit) then return end

	local classification = UnitClassification(unit)
	if classification == "elite" or classification == "worldboss" then
		return CreateAtlasMarkup("nameplates-icon-elite-gold", 16, 16)
	elseif classification == "rareelite" or classification == 'rare' then
		return CreateAtlasMarkup("nameplates-icon-elite-silver", 16, 16)
	end
end

ElvUF.Tags.SharedEvents.PLAYER_GUILD_UPDATE = true

ElvUF.Tags.Events['guild'] = 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild'] = function(unit)
	if UnitIsPlayer(unit) then
		return GetGuildInfo(unit)
	end
end

ElvUF.Tags.Events['guild:brackets'] = 'PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild:brackets'] = function(unit)
	local guildName = GetGuildInfo(unit)
	if guildName then
		return format("<%s>", guildName)
	end
end

ElvUF.Tags.Events['guild:translit'] = 'UNIT_NAME_UPDATE PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild:translit'] = function(unit)
	if UnitIsPlayer(unit) then
		local guildName = GetGuildInfo(unit)
		if guildName then
			return Translit:Transliterate(guildName, translitMark)
		end
	end
end

ElvUF.Tags.Events['guild:brackets:translit'] = 'PLAYER_GUILD_UPDATE'
ElvUF.Tags.Methods['guild:brackets:translit'] = function(unit)
	local guildName = GetGuildInfo(unit)
	if guildName then
		return format("<%s>", Translit:Transliterate(guildName, translitMark))
	end
end

ElvUF.Tags.Events['target'] = 'UNIT_TARGET'
ElvUF.Tags.Methods['target'] = function(unit)
	local targetName = UnitName(unit.."target")
	if targetName then
		return targetName
	end
end

ElvUF.Tags.Events['target:translit'] = 'UNIT_TARGET'
ElvUF.Tags.Methods['target:translit'] = function(unit)
	local targetName = UnitName(unit.."target")
	if targetName then
		return Translit:Transliterate(targetName, translitMark)
	end
end


ElvUF.Tags.Events['name:title'] = 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT'
ElvUF.Tags.Methods['name:title'] = function(unit)
	if UnitIsPlayer(unit) then
		return UnitPVPName(unit) or UnitName(unit)
	end
end

ElvUF.Tags.Events['title'] = 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT'
ElvUF.Tags.Methods['title'] = function(unit)
	if UnitIsPlayer(unit) then
		return GetTitleName(GetCurrentTitle())
	end
end

do
	local function GetTitleNPC(unit, custom)
		if UnitIsPlayer(unit) then return end

		E.ScanTooltip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
		E.ScanTooltip:SetUnit(unit)
		E.ScanTooltip:Show()

		local Title = _G[format('ElvUI_ScanTooltipTextLeft%d', GetCVarBool('colorblindmode') and 3 or 2)]:GetText()
		if Title and not strfind(Title, '^'..LEVEL) then
			return custom and format(custom, Title) or Title
		end
	end
	E.TagFunctions.GetTitleNPC = GetTitleNPC

	ElvUF.Tags.Events['npctitle'] = 'UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods['npctitle'] = function(unit)
		return GetTitleNPC(unit)
	end

	ElvUF.Tags.Events['npctitle:brackets'] = 'UNIT_NAME_UPDATE'
	ElvUF.Tags.Methods['npctitle:brackets'] = function(unit)
		return GetTitleNPC(unit, '<%s>')
	end
end

ElvUF.Tags.Events['guild:rank'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['guild:rank'] = function(unit)
	if UnitIsPlayer(unit) then
		local _, rank = GetGuildInfo(unit)
		if rank then
			return rank
		end
	end
end

ElvUF.Tags.Events['class'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['class'] = function(unit)
	if not UnitIsPlayer(unit) then return end

	local _, classToken = UnitClass(unit)
	if UnitSex(unit) == 3 then
		return _G.LOCALIZED_CLASS_NAMES_FEMALE[classToken]
	else
		return _G.LOCALIZED_CLASS_NAMES_MALE[classToken]
	end
end

ElvUF.Tags.Events['name:title'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:title'] = function(unit)
	if UnitIsPlayer(unit) then
		return UnitPVPName(unit)
	end
end

ElvUF.Tags.Events['title'] = 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT'
ElvUF.Tags.Methods['title'] = function(unit)
    if UnitIsPlayer(unit) then
		return GetTitleName(GetCurrentTitle())
    end
end

ElvUF.Tags.Events['pvp:title'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['pvp:title'] = function(unit)
	if (UnitIsPlayer(unit)) then
		local rank = UnitPVPRank(unit)
		local title = GetPVPRankInfo(rank, unit)

		return title
	end
end

ElvUF.Tags.Events['pvp:rank'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['pvp:rank'] = function(unit)
	if (UnitIsPlayer(unit)) then
		local rank = UnitPVPRank(unit)
		local _, rankNumber = GetPVPRankInfo(rank, unit)

		if rankNumber > 0 then
			return rankNumber
		end
	end
end

ElvUF.Tags.Events['pvp:icon'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['pvp:icon'] = function(unit)
	if (UnitIsPlayer(unit)) then
		local rank = UnitPVPRank(unit)
		local _, rankNumber = GetPVPRankInfo(rank, unit)
		local texture = format('%s%02d', 'Interface\\PvPRankBadges\\PvPRank', rankNumber)

		if rankNumber > 0 then
			return CreateTextureMarkup(texture, 12, 12, 12, 12, 0, 1, 0, 1, 0, 0)
		end
	end
end

local highestVersion = E.version
ElvUF.Tags.OnUpdateThrottle['ElvUI-Users'] = 20
ElvUF.Tags.Methods['ElvUI-Users'] = function(unit)
	if E.UserList and next(E.UserList) then
		local name, realm = UnitName(unit)
		if name then
			local nameRealm = (realm and realm ~= "" and format("%s-%s", name, realm)) or name
			local userVersion = nameRealm and E.UserList[nameRealm]
			if userVersion then
				if highestVersion < userVersion then
					highestVersion = userVersion
				end
				return (userVersion < highestVersion) and "|cffFF3333E|r" or "|cff3366ffE|r"
			end
		end
	end
end

ElvUF.Tags.Events['creature'] = ''

E.TagInfo = {
	--Altpower
	['altpower:current-max-percent'] = { category = 'Altpower', description = "Displays altpower text on a unit in current-max-percent format" },
	['altpower:current-max'] = { category = 'Altpower', description = "Displays altpower text on a unit in current-max format" },
	['altpower:current-percent'] = { category = 'Altpower', description = "Displays altpower text on a unit in current-percent format" },
	['altpower:current'] = { category = 'Altpower', description = "Displays altpower text on a unit in current format" },
	['altpower:deficit'] = { category = 'Altpower', description = "Displays altpower text on a unit in deficit format" },
	['altpower:percent'] = { category = 'Altpower', description = "Displays altpower text on a unit in percent format" },
	--Classification
	['classification:icon'] = { category = 'Classification', description = "Displays the unit's classification in icon form (golden icon for 'ELITE' silver icon for 'RARE')" },
	['classification'] = { category = 'Classification', description = "Displays the unit's classification (e.g. 'ELITE' and 'RARE')" },
	['creature'] = { category = 'Classification', description = "Displays the creature type of the unit" },
	['plus'] = { category = 'Classification', description = "Displays the character '+' if the unit is an elite or rare-elite" },
	['rare'] = { category = 'Classification', description = "Displays 'Rare' when the unit is a rare or rareelite" },
	['shortclassification'] = { category = 'Classification', description = "Displays the unit's classification in short form (e.g. '+' for ELITE and 'R' for RARE)" },
	--Classpower
	['arcanecharges'] = { category = 'Classpower', description = "Displays the arcane charges (Mage)" },
	['chi'] = { category = 'Classpower', description = "Displays the chi points (Monk)" },
	['classpower:current-max-percent'] = { category = 'Classpower', description = "Displays the unit's current and max amount of special power, separated by a dash (% when not full power)" },
	['classpower:current-max'] = { category = 'Classpower', description = "Displays the unit's current and max amount of special power, separated by a dash" },
	['classpower:current-percent'] = { category = 'Classpower', description = "Displays the unit's current and percentage amount of special power, separated by a dash" },
	['classpower:current'] = { category = 'Classpower', description = "Displays the unit's current amount of special power" },
	['classpower:deficit'] = { category = 'Classpower', description = "Displays the unit's special power as a deficit (Total Special Power - Current Special Power = -Deficit)" },
	['classpower:percent'] = { category = 'Classpower', description = "Displays the unit's current amount of special power as a percentage" },
	['cpoints'] = { category = 'Classpower', description = "Displays amount of combo points the player has (only for player, shows nothing on 0)" },
	['holypower'] = { category = 'Classpower', description = "Displays the holy power (Paladin)" },
	['runes'] = { category = 'Classpower', description = "Displays the runes (Death Knight)" },
	['soulshards'] = { category = 'Classpower', description = "Displays the soulshards (Warlock)" },
	--Colors
	['classificationcolor'] = { category = 'Colors', description = "Changes the text color, depending on the unit's classification" },
	['difficulty'] = { category = 'Colors', description = "Colors the next tag by difficulty, red for impossible, orange for hard, green for easy" },
	['difficultycolor'] = { category = 'Colors', description = "Colors the following tags by difficulty, red for impossible, orange for hard, green for easy" },
	['happiness:color'] = { category = 'Colors', description = "Colors the following tags based upon pet happiness (e.g. happy = green)" },
	['healthcolor'] = { category = 'Colors', description = "Changes color of health text, depending on the unit's current health" },
	['manacolor'] = { category = 'Colors', description = "Changes the text color to a light-blue mana color" },
	['namecolor'] = { category = 'Colors', description = "Colors names by player class or NPC reaction (Ex: ['namecolor']['name'])" },
	['powercolor'] = { category = 'Colors', description = "Colors the power text based upon its type" },
	['reactioncolor'] = { category = 'Colors', description = "Colors names by NPC reaction (Bad/Neutral/Good)" },
	['threatcolor'] = { category = 'Colors', description = "Changes the text color, depending on the unit's threat situation" },
	--Guild
	['guild:brackets:translit'] = { category = 'Guild', description = "Displays the guild name with < > and transliteration (e.g. <GUILD>)" },
	['guild:brackets'] = { category = 'Guild', description = "Displays the guild name with < > brackets (e.g. <GUILD>)" },
	['guild:rank'] = { category = 'Guild', description = "Displays the guild rank" },
	['guild:translit'] = { category = 'Guild', description = "Displays the guild name with transliteration for cyrillic letters" },
	['guild'] = { category = 'Guild', description = "Displays the guild name" },
	--Health
	['curhp'] = { category = 'Health', description = "Displays the current HP without decimals" },
	['deficit:name'] = { category = 'Health', description = "Displays the health as a deficit and the name at full health" },
	['health:current-max-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current and max health, without status" },
	['health:current-max-nostatus'] = { category = 'Health', description = "Displays the current and maximum health of the unit, separated by a dash, without status" },
	['health:current-max-percent-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of current and max hp (% when not full hp, without status)" },
	['health:current-max-percent-nostatus'] = { category = 'Health', description = "Displays the current and max hp of the unit, separated by a dash (% when not full hp), without status" },
	['health:current-max-percent:shortvalue'] = { category = 'Health', description = "Shortvalue of current and max hp (% when not full hp)" },
	['health:current-max-percent'] = { category = 'Health', description = "Displays the current and max hp of the unit, separated by a dash (% when not full hp)" },
	['health:current-max:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current and max hp, separated by a dash" },
	['health:current-max'] = { category = 'Health', description = "Displays the current and maximum health of the unit, separated by a dash" },
	['health:current-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current health without status" },
	['health:current-nostatus'] = { category = 'Health', description = "Displays the current health of the unit, without status" },
	['health:current-percent-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current hp (% when not full hp), without status" },
	['health:current-percent-nostatus'] = { category = 'Health', description = "Displays the current hp of the unit (% when not full hp), without status" },
	['health:current-percent:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current hp (% when not full hp)" },
	['health:current-percent'] = { category = 'Health', description = "Displays the current hp of the unit (% when not full hp)" },
	['health:current:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's current health (e.g. 81k instead of 81200)" },
	['health:current'] = { category = 'Health', description = "Displays the current health of the unit" },
	['health:deficit-nostatus:shortvalue'] = { category = 'Health', description = "Shortvalue of the health deficit, without status" },
	['health:deficit-nostatus'] = { category = 'Health', description = "Displays the health of the unit as a deficit, without status" },
	['health:deficit-percent:name-long'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 20 letters)" },
	['health:deficit-percent:name-medium'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 15 letters)" },
	['health:deficit-percent:name-short'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 10 letters)" },
	['health:deficit-percent:name-veryshort'] = { category = 'Health', description = "Displays the health deficit as a percentage and the name of the unit (limited to 5 letters)" },
	['health:deficit-percent:name'] = { category = 'Health', description = "Displays the health deficit as a percentage and the full name of the unit" },
	['health:deficit-percent:nostatus'] = { category = 'Health', description = "Displays the health deficit as a percentage, without status" },
	['health:deficit:shortvalue'] = { category = 'Health', description = "Shortvalue of the health deficit (e.g. -41k instead of -41300)" },
	['health:deficit'] = { category = 'Health', description = "Displays the health of the unit as a deficit (Total Health - Current Health = -Deficit)" },
	['health:max:shortvalue'] = { category = 'Health', description = "Shortvalue of the unit's maximum health" },
	['health:max'] = { category = 'Health', description = "Displays the maximum health of the unit" },
	['health:percent-nostatus'] = { category = 'Health', description = "Displays the unit's current health as a percentage, without status" },
	['health:percent'] = { category = 'Health', description = "Displays the current health of the unit as a percentage" },
	['maxhp'] = { category = 'Health', description = "Displays max HP without decimals" },
	['missinghp'] = { category = 'Health', description = "Displays the missing health of the unit in whole numbers, when not at full health" },
	['perhp'] = { category = 'Health', description = "Displays percentage HP without decimals or the % sign.  You can display the percent sign by adjusting the tag to [perhp<%]." },
	--Hunter
	['diet'] = { category = 'Hunter', description = "Displays the diet of your pet (Fish, Meat, ...)" },
	['happiness:discord'] = { category = 'Hunter', description = "Displays the pet happiness like a Discord emoji" },
	['happiness:full'] = { category = 'Hunter', description = "Displays the pet happiness as a word (e.g. 'Happy')" },
	['happiness:icon'] = { category = 'Hunter', description = "Displays the pet happiness like the default Blizzard icon" },
	['loyalty'] = { category = 'Hunter', description = "Displays the pet loyalty level" },
	--Level
	['level'] = { category = 'Level', description = "Displays the level of the unit" },
	['smartlevel'] = { category = 'Level', description = "Only display the unit's level if it is not the same as yours" },
	--Mana
	['curmana'] = { category = 'Mana', description = "Displays the current mana without decimals" },
	['mana:current-max-percent:shortvalue'] = { category = 'Mana', description = "Shortvalue of the current mana and max mana, separated by a dash (% when not full power)" },
	['mana:current-max-percent'] = { category = 'Mana', description = "Displays the current mana and max mana, separated by a dash (% when not full power)" },
	['mana:current-max:shortvalue'] = { category = 'Mana', description = "Shortvalue of the current mana and max mana, separated by a dash" },
	['mana:current-max'] = { category = 'Mana', description = "Displays the current mana and max mana, separated by a dash" },
	['mana:current-percent:shortvalue'] = { category = 'Mana', description = "Shortvalue of the current mana and mana as a percentage, separated by a dash" },
	['mana:current-percent'] = { category = 'Mana', description = "Displays the current amount of mana as a whole number and a percentage, separated by a dash" },
	['mana:current:shortvalue'] = { category = 'Mana', description = "Shortvalue of the unit's current amount of mana (e.g. 4k instead of 4000)" },
	['mana:current'] = { category = 'Mana', description = "Displays the unit's current amount of mana (e.g. 97200)" },
	['mana:deficit:shortvalue'] = { category = 'Mana', description = "Shortvalue of the mana deficit (Total Mana - Current Mana = -Deficit)" },
	['mana:deficit'] = { category = 'Mana', description = "Displays the mana deficit (Total Mana - Current Mana = -Deficit)" },
	['mana:max:shortvalue'] = { category = 'Mana', description = "Shortvalue of the unit's maximum mana" },
	['mana:max'] = { category = 'Mana', description = "Displays the unit's maximum mana" },
	['mana:percent'] = { category = 'Mana', description = "Displays the mana of the unit as a percentage value" },
	['maxmana'] = { category = 'Mana', description = "Displays the max amount of mana the unit can have" },
	--Miscellaneous
	['affix'] = { category = 'Miscellaneous', description = "Displays low level critter mobs" },
	['class'] = { category = 'Miscellaneous', description = "Displays the class of the unit, if that unit is a player" },
	['race'] = { category = 'Miscellaneous', description = "Displays the race" },
	['smartclass'] = { category = 'Miscellaneous', description = "Displays the player's class or creature's type" },
	['specialization'] = { category = 'Miscellaneous', description = "Displays your current specialization as text" },
	['ElvUI-Users'] = { category = 'Miscellaneous', description = "Displays ElvUI users and their version" },
	--Names
	['name:abbrev:long'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 20 letters)" },
	['name:abbrev:medium'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 15 letters)" },
	['name:abbrev:short'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 10 letters)" },
	['name:abbrev:veryshort'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (limited to 5 letters)" },
	['name:abbrev'] = { category = 'Names', description = "Displays the name of the unit with abbreviation (e.g. 'Shadowfury Witch Doctor' becomes 'S. W. Doctor')" },
	['name:last'] = { category = 'Names', description = "Displays the last word of the unit's name" },
	['name:long:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 20 letters)" },
	['name:long:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 20 letters)" },
	['name:long'] = { category = 'Names', description = "Displays the name of the unit (limited to 20 letters)" },
	['name:medium:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 15 letters)" },
	['name:medium:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 15 letters)" },
	['name:medium'] = { category = 'Names', description = "Displays the name of the unit (limited to 15 letters)" },
	['name:short:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 10 letters)" },
	['name:short:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 10 letters)" },
	['name:short'] = { category = 'Names', description = "Displays the name of the unit (limited to 10 letters)" },
	['name:title'] = { category = 'Names', description = "Displays player name and pvp title" },
	['name:veryshort:status'] = { category = 'Names', description = "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 5 letters)" },
	['name:veryshort:translit'] = { category = 'Names', description = "Displays the name of the unit with transliteration for cyrillic letters (limited to 5 letters)" },
	['name:veryshort'] = { category = 'Names', description = "Displays the name of the unit (limited to 5 letters)" },
	['name'] = { category = 'Names', description = "Displays the full name of the unit without any letter limitation" },
	['npctitle:brackets'] = { category = 'Names', description = "Displays the NPC title with < > brackets (e.g. <General Goods Vendor>)" },
	['npctitle'] = { category = 'Names', description = "Displays the NPC title (e.g. General Goods Vendor)" },
	--Party and Raid
	['group'] = { category = 'Party and Raid', description = "Displays the group number the unit is in ('1' - '8')" },
	['leader'] = { category = 'Party and Raid', description = "Displays 'L' if the unit is the group/raid leader" },
	['leaderlong'] = { category = 'Party and Raid', description = "Displays 'Leader' if the unit is the group/raid leader" },
	--Power
	['additionalpower:current-max-percent'] = { category = 'Power', description = "Displays the current and max additional power of the unit, separated by a dash (% when not full)" },
	['additionalpower:current-max'] = { category = 'Power', description = "Displays the unit's current and maximum additional power, separated by a dash" },
	['additionalpower:current-percent'] = { category = 'Power', description = "Displays the current additional power of the unit and % when not full" },
	['additionalpower:current'] = { category = 'Power', description = "Displays the unit's current additional power" },
	['additionalpower:deficit'] = { category = 'Power', description = "Displays the player's additional power as a deficit" },
	['additionalpower:percent'] = { category = 'Power', description = "Displays the player's additional power as a percentage" },
	['cpoints'] = { category = 'Power', description = "Displays amount of combo points the player has (only for player, shows nothing on 0)" },
	['curpp'] = { category = 'Power', description = "Displays the unit's current power without decimals" },
	['maxpp'] = { category = 'Power', description = "Displays the max amount of power of the unit in whole numbers without decimals" },
	['missingpp'] = { category = 'Power', description = "Displays the missing power of the unit in whole numbers when not at full power" },
	['perpp'] = { category = 'Power', description = "Displays the unit's percentage power without decimals " },
	['power:current-max-percent:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash (% when not full power)" },
	['power:current-max-percent'] = { category = 'Power', description = "Displays the current power and max power, separated by a dash (% when not full power)" },
	['power:current-max:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash" },
	['power:current-max'] = { category = 'Power', description = "Displays the current power and max power, separated by a dash" },
	['power:current-percent:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and power as a percentage, separated by a dash" },
	['power:current-percent'] = { category = 'Power', description = "Displays the current power and power as a percentage, separated by a dash" },
	['power:current:shortvalue'] = { category = 'Power', description = "Shortvalue of the unit's current amount of power (e.g. 4k instead of 4000)" },
	['power:current'] = { category = 'Power', description = "Displays the unit's current amount of power" },
	['power:deficit:shortvalue'] = { category = 'Power', description = "Shortvalue of the power as a deficit (Total Power - Current Power = -Deficit)" },
	['power:deficit'] = { category = 'Power', description = "Displays the power as a deficit (Total Power - Current Power = -Deficit)" },
	['power:max:shortvalue'] = { category = 'Power', description = "Shortvalue of the unit's maximum power" },
	['power:max'] = { category = 'Power', description = "Displays the unit's maximum power" },
	['power:percent'] = { category = 'Power', description = "Displays the unit's power as a percentage" },
	--PvP
	['faction:icon'] = { category = 'PvP', description = "Displays 'Alliance' or 'Horde' Texture" },
	['faction'] = { category = 'PvP', description = "Displays 'Aliance' or 'Horde'" },
	['pvp:icon'] = { category = 'PvP', description = "Displays player pvp rank icon" },
	['pvp:rank'] = { category = 'PvP', description = "Displays player pvp rank number" },
	['pvp:title'] = { category = 'PvP', description = "Displays player pvp title" },
	['pvp'] = { category = 'PvP', description = "Displays 'PvP' if the unit is pvp flagged" },
	['pvptimer'] = { category = 'PvP', description = "Displays remaining time on pvp-flagged status" },
	--Realm
	['realm:dash:translit'] = { category = 'Realm', description = "Displays the server name with transliteration for cyrillic letters and a dash in front" },
	['realm:dash'] = { category = 'Realm', description = "Displays the server name with a dash in front (e.g. -Realm)" },
	['realm:translit'] = { category = 'Realm', description = "Displays the server name with transliteration for cyrillic letters" },
	['realm'] = { category = 'Realm', description = "Displays the server name" },
	--Status
	['afk'] = { category = 'Status', description = "Displays <AFK> if the unit is afk" },
	['dead'] = { category = 'Status', description = "Displays <DEAD> if the unit is dead" },
	['offline'] = { category = 'Status', description = "Displays 'OFFLINE' if the unit is disconnected" },
	['resting'] = { category = 'Status', description = "Displays 'zzz' if the unit is resting" },
	['status:icon'] = { category = 'Status', description = "Displays AFK/DND as an orange(afk) / red(dnd) icon" },
	['status:text'] = { category = 'Status', description = "Displays <AFK> and <DND>" },
	['status'] = { category = 'Status', description = "Displays zzz, dead, ghost, offline" },
	['statustimer'] = { category = 'Status', description = "Displays a timer for how long a unit has had the status (e.g 'DEAD - 0:34')" },
	--Speed
	['speed:percent-moving-raw'] = { category = 'Speed', description = "" },
	['speed:percent-moving'] = { category = 'Speed', description = "" },
	['speed:percent-raw'] = { category = 'Speed', description = "" },
	['speed:percent'] = { category = 'Speed', description = "" },
	['speed:yardspersec-moving-raw'] = { category = 'Speed', description = "" },
	['speed:yardspersec-moving'] = { category = 'Speed', description = "" },
	['speed:yardspersec-raw'] = { category = 'Speed', description = "" },
	['speed:yardspersec'] = { category = 'Speed', description = "" },
	--Target
	['target:long:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 20 letters)" },
	['target:long'] = { category = 'Target', description = "Displays the current target of the unit (limited to 20 letters)" },
	['target:medium:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 15 letters)" },
	['target:medium'] = { category = 'Target', description = "Displays the current target of the unit (limited to 15 letters)" },
	['target:short:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 10 letters)" },
	['target:short'] = { category = 'Target', description = "Displays the current target of the unit (limited to 10 letters)" },
	['target:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters" },
	['target:veryshort:translit'] = { category = 'Target', description = "Displays the current target of the unit with transliteration for cyrillic letters (limited to 5 letters)" },
	['target:veryshort'] = { category = 'Target', description = "Displays the current target of the unit (limited to 5 letters)" },
	['target'] = { category = 'Target', description = "Displays the current target of the unit" },
	--Range
	['distance'] = { category = 'Range', description = "Displays the distance" },
	['nearbyplayers:10'] = { category = 'Range', description = "Displays all players within 10 yards" },
	['nearbyplayers:30'] = { category = 'Range', description = "Displays all players within 30 yards" },
	['nearbyplayers:8'] = { category = 'Range', description = "Displays all players within 8 yards" },
	--Threat
	['threat:current'] = { category = 'Threat', description = "Displays the current threat as a value" },
	['threat:percent'] = { category = 'Threat', description = "Displays the current threat as a percent" },
	['threat'] = { category = 'Threat', description = "Displays the current threat situation (Aggro is secure tanking, -- is losing threat and ++ is gaining threat)" },
}

--[[
	tagName = Tag Name
	category = Category that you want it to fall in
	description = self explainitory
	order = This is optional. It's used for sorting the tags by order and not by name. The +10 is not a rule. I reserve the first 10 slots.
]]

function E:AddTagInfo(tagName, category, description, order)
	if type(order) == 'number' then order = order + 10 else order = nil end

	E.TagInfo[tagName] = E.TagInfo[tagName] or {}
	E.TagInfo[tagName].category = category or 'Miscellaneous'
	E.TagInfo[tagName].description = description or ''
	E.TagInfo[tagName].order = order or nil
end
