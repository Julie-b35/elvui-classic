local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))

E.Options.args.tagGroup = {
	order = 925,
	type = "group",
	name = L["Available Tags"],
	args = {
		header = {
			order = 1,
			type = "header",
			name = L["Available Tags"],
		},
		general = {
			order = 2,
			type = "group",
			name = "",
			guiInline = true,
			childGroups = 'tab',
			args = {},
		},
	}
}

E.TagInfo = {
	--Colors
	['namecolor'] = { category = 'Colors', description = "Colors Names by Player Class / NPC Reaction" },
	['reactioncolor'] = { category = 'Colors', description = "Colors Names NPC Reaction (Bad/Neutral/Good)" },
	['powercolor'] = { category = 'Colors', description = "Colors Unit Power based upon its type" },
	['happiness:color'] = { category = 'Colors', description = "Colors the following tags based upon pet happiness (e.g. 'Happy = green')" },
	['difficultycolor'] = { category = 'Colors', description = "Colors the difficulty, red for impossible, orange for hard, green for easy" },
	['difficulty'] = { category = 'Colors', description = "Changes color of the next tag based on how difficult the unit is compared to the players level" },
	['classificationcolor'] = { category = 'Colors', description = " " },
	['healthcolor'] = { category = 'Colors', description = " " },
	--Classification
	['classification'] = { category = 'Classification', description = "Show the Unit Classification (e.g. 'ELITE' and 'RARE')" },
	['shortclassification'] = { category = 'Classification', description = "Show the Unit Classification in short form (e.g. '+' for ELITE and 'R' for RARE)" },
	['classification:icon'] = { category = 'Classification', description = "Show the Unit Classification in icon form (Gold for 'ELITE' Silver for 'RARE')" },
	--Guild
	['guild'] = { category = 'Guild', description = " " },
	['guild:brackets'] = { category = 'Guild', description = " " },
	['guild:brackets:translit'] = { category = 'Guild', description = " " },
	['guild:rank'] = { category = 'Guild', description = " " },
	['guild:translit'] = { category = 'Guild', description = " " },
	--Health
	['curhp'] = { category = 'Health', description = "Display current HP without decimals" },
	['perhp'] = { category = 'Health', description = "Display percentage HP without decimals" },
	['maxhp'] = { category = 'Health', description = " " },
	['deficit:name'] = { category = 'Health', description = "Shows the health as a deficit, and the name at full health" },
	['health:current'] = { category = 'Health', description = "Shows the unit's current health" },
	['health:current-max'] = { category = 'Health', description = "Shows the unit's current and maximum health, separated by a dash" },
	['health:current-max-nostatus'] = { category = 'Health', description = " " },
	['health:current-max-nostatus:shortvalue'] = { category = 'Health', description = " " },
	['health:current-max-percent'] = { category = 'Health', description = " " },
	['health:current-max-percent-nostatus'] = { category = 'Health', description = " " },
	['health:current-max-percent-nostatus:shortvalue'] = { category = 'Health', description = " " },
	['health:current-max-percent:shortvalue'] = { category = 'Health', description = " " },
	['health:current-max:shortvalue'] = { category = 'Health', description = " " },
	['health:current-nostatus'] = { category = 'Health', description = " " },
	['health:current-nostatus:shortvalue'] = { category = 'Health', description = " " },
	['health:current-percent'] = { category = 'Health', description = " " },
	['health:current-percent-nostatus'] = { category = 'Health', description = " " },
	['health:current-percent-nostatus:shortvalue'] = { category = 'Health', description = " " },
	['health:current-percent:shortvalue'] = { category = 'Health', description = " " },
	['health:current:shortvalue'] = { category = 'Health', description = " " },
	['health:deficit'] = { category = 'Health', description = " " },
	['health:deficit-nostatus'] = { category = 'Health', description = " " },
	['health:deficit-nostatus:shortvalue'] = { category = 'Health', description = " " },
	['health:deficit-percent:name'] = { category = 'Health', description = " " },
	['health:deficit-percent:name-long'] = { category = 'Health', description = " " },
	['health:deficit-percent:name-medium'] = { category = 'Health', description = " " },
	['health:deficit-percent:name-short'] = { category = 'Health', description = " " },
	['health:deficit-percent:name-veryshort'] = { category = 'Health', description = " " },
	['health:deficit:shortvalue'] = { category = 'Health', description = " " },
	['health:max'] = { category = 'Health', description = " " },
	['health:max:shortvalue'] = { category = 'Health', description = " " },
	['health:percent'] = { category = 'Health', description = " " },
	['health:percent-nostatus'] = { category = 'Health', description = " " },
	['missinghp'] = { category = 'Health', description = "Shows the missing health of the unit in whole numbers when not at full health" },
	--Hunter
	['happiness:icon'] = { category = 'Hunter', description = "Displays the Pet Happiness like the default Blizzard icon" },
	['happiness:discord'] = { category = 'Hunter', description = "Displays the Pet Happiness like a Discord Emoji" },
	['happiness:full'] = { category = 'Hunter', description = "Displays the Pet Happiness as a word (e.g. 'Happy')" },
	['loyalty'] = { category = 'Hunter', description = "Display the Pet Loyalty Level" },
	['diet'] = { category = 'Hunter', description = "Shows the Diet of your pet (Fish, Meat, ...)" },
	--Level
	['smartlevel'] = { category = 'Level', description = "Only shows the unit's level if it is not the same as yours" },
	['level'] = { category = 'Level', description = "Display the level" },
	--Mana
	['mana:current'] = { category = 'Mana', description = "Shows the current amount of Mana a unit has" },
	['mana:current:shortvalue'] = { category = 'Mana', description = "Shortvalue of the current amount of Mana a unit has (e.g. 4k instead of 4000)" },
	['mana:current-percent'] = { category = 'Mana', description = "Shows the current Mana and power as a percent, separated by a dash" },
	['mana:current-percent:shortvalue'] = { category = 'Mana', description = "Shortvalue of the current Mana and Mana as a percent, separated by a dash" },
	['mana:current-max'] = { category = 'Mana', description = "Shows the current Mana and max Mana, separated by a dash" },
	['mana:current-max:shortvalue'] = { category = 'Mana', description = "Shortvalue of the current Mana and max Mana, separated by a dash" },
	['mana:current-max-percent'] = { category = 'Mana', description = "Shows the current Mana and max Mana, separated by a dash (% when not full power)" },
	['mana:current-max-percent:shortvalue'] = { category = 'Mana', description = "Shortvalue of the current Mana and max Mana, separated by a dash (% when not full power)" },
	['mana:percent'] = { category = 'Mana', description = "Displays the Unit Mana as a percentage value" },
	['mana:max'] = { category = 'Mana', description = "Shows the unit's maximum Mana" },
	['mana:max:shortvalue'] = { category = 'Mana', description = "Shortvalue of the unit's maximum Mana" },
	['mana:deficit'] = { category = 'Mana', description = "Shows the power as a deficit (Total Mana - Current Mana = -Deficit)" },
	['mana:deficit:shortvalue'] = { category = 'Mana', description = "Shortvalue of the mana as a deficit (Total Mana - Current Mana = -Deficit)" },
	['curmana'] = { category = 'Mana', description = "Display current Mana without decimals" },
	['maxmana'] = { category = 'Mana', description = "Displays the max amount of mana the unit can have" },
	--Names
	['name'] = { category = 'Names', description = "Shows the full Unit Name without any letter limitation" },
	['name:veryshort'] = { category = 'Names', description = "Shows the Unit Name (limited to 5 letters)" },
	['name:short'] = { category = 'Names', description = "Shows the Unit Name (limited to 10 letters)" },
	['name:medium'] = { category = 'Names', description = "Shows the Unit Name (limited to 15 letters)" },
	['name:long'] = { category = 'Names', description = "Shows the Unit Name (limited to 20 letters)" },
	['name:veryshort:translit'] = { category = 'Names', description = "Shows the Unit Name with transliteration for cyrillic letters (limited to 5 letters)" },
	['name:short:translit'] = { category = 'Names', description = "Shows the Unit Name with transliteration for cyrillic letters (limited to 10 letters)" },
	['name:medium:translit'] = { category = 'Names', description = "Shows the Unit Name with transliteration for cyrillic letters (limited to 15 letters)" },
	['name:long:translit'] = { category = 'Names', description = "Shows the Unit Name with transliteration for cyrillic letters (limited to 20 letters)" },
	['name:abbrev'] = { category = 'Names', description = "Shows the Unit Name with Abbreviation (e.g. 'Shadowfury Witch Doctor' becomes 'S. W. Doctor')" },
	['name:abbrev:veryshort'] = { category = 'Names', description = "Shows the Unit Name with Abbreviation (limited to 5 letters)" },
	['name:abbrev:short'] = { category = 'Names', description = "Shows the Unit Name with Abbreviation (limited to 10 letters)" },
	['name:abbrev:medium'] = { category = 'Names', description = "Shows the Unit Name with Abbreviation (limited to 15 letters)" },
	['name:abbrev:long'] = { category = 'Names', description = "Shows the Unit Name with Abbreviation (limited to 20 letters)" },
	['name:veryshort:status'] = { category = 'Names', description = "Replaces the Unit Name 'DEAD' or 'OFFLINE' (limited to 5 letters)" },
	['name:short:status'] = { category = 'Names', description = "Replaces the Unit Name 'DEAD' or 'OFFLINE' (limited to 10 letters)" },
	['name:medium:status'] = { category = 'Names', description = "Replaces the Unit Name 'DEAD' or 'OFFLINE' (limited to 15 letters)" },
	['name:long:status'] = { category = 'Names', description = "Replaces the Unit Name with 'DEAD' or 'OFFLINE' (limited to 20 letters)" },
	--Party and Raid
	['group'] = { category = 'Party and Raid', description = "Shows the group number the unit is in ('1' - '8')" },
	['leader'] = { category = 'Party and Raid', description = "Shows 'L' if the unit is the group leader" },
	['leaderlong'] = { category = 'Party and Raid', description = "Shows 'Leader' if the unit is the group leader" },
	--Power
	['power:current'] = { category = 'Power', description = "Shows the current amount of power a unit has" },
	['power:current:shortvalue'] = { category = 'Power', description = "Shortvalue of the current amount of power a unit has (e.g. 4k instead of 4000)" },
	['power:current-percent'] = { category = 'Power', description = "Shows the current power and power as a percent, separated by a dash" },
	['power:current-percent:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and power as a percent, separated by a dash" },
	['power:current-max'] = { category = 'Power', description = "Shows the current power and max power, separated by a dash" },
	['power:current-max:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash" },
	['power:current-max-percent'] = { category = 'Power', description = "Shows the current power and max power, separated by a dash (% when not full power)" },
	['power:current-max-percent:shortvalue'] = { category = 'Power', description = "Shortvalue of the current power and max power, separated by a dash (% when not full power)" },
	['power:percent'] = { category = 'Power', description = "Displays the Unit Power as a percentage value" },
	['power:max'] = { category = 'Power', description = "Shows the unit's maximum power" },
	['power:max:shortvalue'] = { category = 'Power', description = "Shortvalue of the unit's maximum power" },
	['power:deficit'] = { category = 'Power', description = "Shows the power as a deficit (Total Power - Current Power = -Deficit)" },
	['power:deficit:shortvalue'] = { category = 'Power', description = "Shortvalue of the power as a deficit (Total Power - Current Power = -Deficit)" },
	['curpp'] = { category = 'Power', description = "Display current Power without decimals" },
	['perpp'] = { category = 'Power', description = "Display percentage Power without decimals " },
	['maxpp'] = { category = 'Power', description = "Displays the max amount of power of the unit in whole numbers with no decimals" },
	['cpoints'] = { category = 'Power', description = "Displays amount of combo points the player has (only for player, shows nothing on 0)" },
	['missingpp'] = { category = 'Power', description = "Shows the missing power of the unit in whole numbers when not at full power" },
	--Quest
	['quest:info'] = { category = 'Quest', description = " " },
	['quest:title'] = { category = 'Quest', description = " " },
	--Realm
	['realm'] = { category = 'Realm', description = "Shows the Server Name" },
	['realm:translit'] = { category = 'Realm', description = "Shows the Server Name with transliteration for cyrillic letters" },
	['realm:dash'] = { category = 'Realm', description = "Shows the Server Name with a dash in front (e.g. -Realm)" },
	['realm:dash:translit'] = { category = 'Realm', description = "Shows the Server with transliteration for cyrillic letters and a dash in front" },
	--Status
	['status'] = { category = 'Status', description = 'Show Zzz(inactive), dead, ghost, offline' },
	['status:icon'] = { category = 'Status', description = "Show AFK/DND as an orange(afk) / red(dnd) icon" },
	['status:text'] = { category = 'Status', description = "Show <AFK> and <DND>" },
	['statustimer'] = { category = 'Status', description = "Show a timer for how long a unit has had that status (e.g 'DEAD - 0:34')" },
	['dead'] = { category = 'Status', description = "Show <DEAD> if the Unit is dead" },
	['offline'] = { category = 'Status', description = "Show OFFLINE if the Unit is disconnected" },
	--Target
	['target'] = { category = 'Target', description = "Displays the current target of the Unit" },
	['target:veryshort'] = { category = 'Target', description = "Displays the current target of the Unit (limited to 5 letters)" },
	['target:short'] = { category = 'Target', description = "Displays the current target of the Unit (limited to 10 letters)" },
	['target:medium'] = { category = 'Target', description = "Displays the current target of the Unit (limited to 15 letters)" },
	['target:long'] = { category = 'Target', description = "Displays the current target of the Unit (limited to 20 letters)" },
	['target:translit'] = { category = 'Target', description = "Displays the current target of the Unit with transliteration for cyrillic letters" },
	['target:veryshort:translit'] = { category = 'Target', description = "Displays the current target of the Unit with transliteration for cyrillic letters (limited to 5 letters)" },
	['target:short:translit'] = { category = 'Target', description = "Displays the current target of the Unit with transliteration for cyrillic letters (limited to 10 letters)" },
	['target:medium:translit'] = { category = 'Target', description = "Displays the current target of the Unit with transliteration for cyrillic letters (limited to 15 letters)" },
	['target:long:translit'] = { category = 'Target', description = "Displays the current target of the Unit with transliteration for cyrillic letters (limited to 20 letters)" },
	--Work in Progress from here
	['affix'] = { category = 'Miscellanous', description = " " },
	['name:title'] = { category = 'Miscellanous', description = " " },
	['npctitle'] = { category = 'Miscellanous', description = " " },
	['class'] = { category = 'Miscellanous', description = "Shows the class of the unit, if that unit is a player" } ,
	['faction'] = { category = 'Miscellanous', description = "Shows 'Aliance' or 'Horde'" },
	['plus'] = { category = 'Miscellanous', description = "Displays the character '+' if the unit is an elite or rare-elite" },
	['pvp'] = { category = 'Miscellanous', description = "Displays 'PvP' if the unit is flagged for PvP" },
	['rare'] = { category = 'Miscellanous', description = "Shows 'Rare' when the unit is a rare or rare elite" },
	['resting'] = { category = 'Miscellanous', description = "Shows 'Resting' when the unit is resting" },
}

-- We need to implement this
-- |cffXXXXXX [tags] or text here |r
-- description = "Custom color your Text: replace the XXXXXX with a Hex color code"

for Tag in next, E.oUF.Tags.Events do
	if not E.TagInfo[Tag] then
		E.TagInfo[Tag] = { category = 'Miscellanous', description = "" }
		E:Print("['"..Tag.."'] = { category = 'Miscellanous', description = '' }")
	end

	if not E.Options.args.tagGroup.args.general.args[E.TagInfo[Tag].category] then
		E.Options.args.tagGroup.args.general.args[E.TagInfo[Tag].category] = {
			order = 925,
			type = "group",
			name = E.InfoColor..E.TagInfo[Tag].category,
			args = {}
		}
	end

	E.Options.args.tagGroup.args.general.args[E.TagInfo[Tag].category].args[Tag] = {
		type = "description",
		fontSize = "medium",
		name = format('[%s] - %s', Tag, E.TagInfo[Tag].description),
	}
end
