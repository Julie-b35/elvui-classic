local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))

E.Options.args.tagGroup = {
	order = 925,
	type = "group",
	name = L["Available Tags"],
	args = {
		link = {
			order = 1,
			type = "input",
			width = "full",
			name = L["Guide:"],
			get = function() return "https://www.tukui.org/forum/viewtopic.php?f=9&t=6" end,
		},
		header = {
			order = 2,
			type = "header",
			name = L["Available Tags"],
		},
		general = {
			order = 3,
			type = "group",
			name = "",
			guiInline = true,
			childGroups = 'tab',
			args = {
				Colors = {
					type = "group",
					name = E.InfoColor..'Colors',
					args = {
						customTagColorInfo = {
							type = "description",
							fontSize = "medium",
							name = '||cffXXXXXX [tags] or text here ||r - Custom color your Text: replace the XXXXXX with a Hex color code',
						}
					}
				},
			},
		},
	}
}

for Tag in next, E.oUF.Tags.Events do
	if not E.TagInfo[Tag] then
		E.TagInfo[Tag] = { category = 'Miscellanous', description = "" }
		--E:Print("['"..Tag.."'] = { category = 'Miscellanous', description = '' }")
	end

	if not E.Options.args.tagGroup.args.general.args[E.TagInfo[Tag].category] then
		E.Options.args.tagGroup.args.general.args[E.TagInfo[Tag].category] = {
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
