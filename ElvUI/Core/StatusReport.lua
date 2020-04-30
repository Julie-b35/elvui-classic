local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local Skins = E:GetModule('Skins')

--WoW API / Variables
local CreateFrame = CreateFrame
local GetAddOnInfo = GetAddOnInfo
local GetCVar = GetCVar
local GetLocale = GetLocale
local GetNumAddOns = GetNumAddOns
local GetRealZoneText = GetRealZoneText

function E:AreOtherAddOnsEnabled()
	local EP, addons, plugins = E.Libs.EP.plugins

	for i = 1, GetNumAddOns() do
		local name = GetAddOnInfo(i)
		if name ~= 'ElvUI' and name ~= 'ElvUI_OptionsUI' and E:IsAddOnEnabled(name) then
			if EP[name] then plugins = true else addons = true end
		end
	end

	return addons, plugins
end

function E:GetDisplayMode()
	local window, maximize = GetCVar('gxWindow') == '1', GetCVar('gxMaximize') == '1'
	return (window and maximize and 'Windowed (Fullscreen)') or (window and 'Windowed') or 'Fullscreen'
end

local EnglishClassName = {
	['DRUID'] = 'Druid',
	['HUNTER'] = 'Hunter',
	['MAGE'] = 'Mage',
	['MONK'] = 'Monk',
	['PALADIN'] = 'Paladin',
	['PRIEST'] = 'Priest',
	['ROGUE'] = 'Rogue',
	['SHAMAN'] = 'Shaman',
	['WARLOCK'] = 'Warlock',
	['WARRIOR'] = 'Warrior',
}

function E:CreateStatusContent(num, parent, anchorTo)
	local content = CreateFrame('Frame', nil, parent)
	content:Size(260, (num * 20) + ((num-1)*5)) --20 height and 5 spacing
	content:Point('TOP', anchorTo, 'BOTTOM')

	for i = 1, num do
		local line = CreateFrame('Frame', nil, content)
		line:Size(260, 20)

		local text = line:CreateFontString(nil, 'ARTWORK')
		text:SetAllPoints()
		text:SetJustifyH('LEFT')
		text:SetJustifyV('MIDDLE')
		text:FontTemplate(E.Media.Fonts.Expressway, 14, 'OUTLINE')
		line.Text = text

		local numLine = line
		if i == 1 then
			numLine:Point('TOP', content, 'TOP')
		else
			numLine:Point('TOP', content['Line'..(i-1)], 'BOTTOM', 0, -5)
		end

		content['Line'..i] = numLine
	end

	return content
end

local function CloseClicked()
	if E.StatusReportToggled then
		E.StatusReportToggled = nil
		E:ToggleOptionsUI()
	end
end

function E:CreateStatusSection(width, height, parent, anchor1, anchorTo, anchor2, yOffset)
	local parentWidth, parentHeight = parent:GetSize()

	if width > parentWidth then parent:SetWidth(width + 25) end
	if height then parent:SetHeight(parentHeight + height) end

	local section = CreateFrame('Frame', nil, parent)
	section:Size(width, height)
	section:Point(anchor1, anchorTo, anchor2, 0, yOffset)

	local header = CreateFrame('Frame', nil, section)
	header:Size(300, 30)
	header:Point('TOP', section)
	section.Header = header

	local text = section.Header:CreateFontString(nil, 'ARTWORK')
	text:Point('TOP')
	text:Point('BOTTOM')
	text:SetJustifyH('CENTER')
	text:SetJustifyV('MIDDLE')
	text:FontTemplate(E.Media.Fonts.Expressway, 18, 'OUTLINE')
	section.Header.Text = text

	local leftDivider = section.Header:CreateTexture(nil, 'ARTWORK')
	leftDivider:Height(8)
	leftDivider:Point('LEFT', section.Header, 'LEFT', 5, 0)
	leftDivider:Point('RIGHT', section.Header.Text, 'LEFT', -5, 0)
	leftDivider:SetTexture('Interface\\Tooltips\\UI-Tooltip-Border')
	leftDivider:SetTexCoord(0.81, 0.94, 0.5, 1)
	section.Header.LeftDivider = leftDivider

	local rightDivider = section.Header:CreateTexture(nil, 'ARTWORK')
	rightDivider:Height(8)
	rightDivider:Point('RIGHT', section.Header, 'RIGHT', -5, 0)
	rightDivider:Point('LEFT', section.Header.Text, 'RIGHT', 5, 0)
	rightDivider:SetTexture('Interface\\Tooltips\\UI-Tooltip-Border')
	rightDivider:SetTexCoord(0.81, 0.94, 0.5, 1)
	section.Header.RightDivider = rightDivider

	return section
end

function E:CreateStatusFrame()
	--Main frame
	local StatusFrame = CreateFrame('Frame', 'ElvUIStatusReport', E.UIParent)
	StatusFrame:Point('CENTER', E.UIParent, 'CENTER')
	StatusFrame:SetFrameStrata('HIGH')
	StatusFrame:CreateBackdrop('Transparent', nil, true)
	StatusFrame.backdrop:SetBackdropColor(0, 0, 0, 0.6)
	StatusFrame:SetMovable(true)
	StatusFrame:SetSize(0, 35)
	StatusFrame:Hide()

	--Close button and script to retoggle the options.
	StatusFrame:CreateCloseButton()
	StatusFrame.CloseButton:HookScript('OnClick', CloseClicked)

	--Title logo (drag to move frame)
	local titleLogoFrame = CreateFrame('Frame', nil, StatusFrame, 'TitleDragAreaTemplate')
	titleLogoFrame:Point('CENTER', StatusFrame, 'TOP')
	titleLogoFrame:Size(240, 80)
	StatusFrame.TitleLogoFrame = titleLogoFrame

	local LogoTop = StatusFrame.TitleLogoFrame:CreateTexture(nil, 'ARTWORK')
	LogoTop:Point('CENTER', titleLogoFrame, 'TOP', 0, -36)
	LogoTop:SetTexture(E.Media.Textures.LogoTopSmall)
	LogoTop:Size(128, 64)
	titleLogoFrame.LogoTop = LogoTop

	local LogoBottom = StatusFrame.TitleLogoFrame:CreateTexture(nil, 'ARTWORK')
	LogoBottom:Point('CENTER', titleLogoFrame, 'TOP', 0, -36)
	LogoBottom:SetTexture(E.Media.Textures.LogoBottomSmall)
	LogoBottom:Size(128, 64)
	titleLogoFrame.LogoBottom = LogoBottom

	--Sections
	StatusFrame.Section1 = E:CreateStatusSection(300, 125, StatusFrame, 'TOP', StatusFrame, 'TOP', -30)
	StatusFrame.Section2 = E:CreateStatusSection(300, 150, StatusFrame, 'TOP', StatusFrame.Section1, 'BOTTOM', 0)
	StatusFrame.Section3 = E:CreateStatusSection(300, 185, StatusFrame, 'TOP', StatusFrame.Section2, 'BOTTOM', 0)
	--StatusFrame.Section4 = E:CreateStatusSection(300, 60, StatusFrame, 'TOP', StatusFrame.Section3, 'BOTTOM', 0)

	--Section content
	StatusFrame.Section1.Content = E:CreateStatusContent(4, StatusFrame.Section1, StatusFrame.Section1.Header)
	StatusFrame.Section2.Content = E:CreateStatusContent(5, StatusFrame.Section2, StatusFrame.Section2.Header)
	StatusFrame.Section3.Content = E:CreateStatusContent(6, StatusFrame.Section3, StatusFrame.Section3.Header)
	--StatusFrame.Section4.Content = CreateFrame('Frame', nil, StatusFrame.Section4)
	--StatusFrame.Section4.Content:Size(240, 25)
	--StatusFrame.Section4.Content:Point('TOP', StatusFrame.Section4.Header, 'BOTTOM', 0, 0)

	--Content lines
	StatusFrame.Section1.Content.Line3.Text:SetFormattedText('Recommended Scale: |cff4beb2c%s|r', E:PixelBestSize())
	StatusFrame.Section1.Content.Line4.Text:SetFormattedText('UI Scale Is: |cff4beb2c%s|r', E.global.general.UIScale)
	StatusFrame.Section2.Content.Line1.Text:SetFormattedText('Version of WoW: |cff4beb2c%s (build %s)|r', E.wowpatch, E.wowbuild)
	StatusFrame.Section2.Content.Line2.Text:SetFormattedText('Client Language: |cff4beb2c%s|r', GetLocale())
	StatusFrame.Section2.Content.Line5.Text:SetFormattedText('Using Mac Client: |cff4beb2c%s|r', (E.isMacClient == true and 'Yes' or 'No'))
	StatusFrame.Section3.Content.Line1.Text:SetFormattedText('Faction: |cff4beb2c%s|r', E.myfaction)
	StatusFrame.Section3.Content.Line2.Text:SetFormattedText('Race: |cff4beb2c%s|r', E.myrace)
	StatusFrame.Section3.Content.Line3.Text:SetFormattedText('Class: |cff4beb2c%s|r', EnglishClassName[E.myclass])

	--[[Export buttons
	StatusFrame.Section4.Content.Button1 = CreateFrame('Button', nil, StatusFrame.Section4.Content, 'UIPanelButtonTemplate')
	StatusFrame.Section4.Content.Button1:Size(100, 25)
	StatusFrame.Section4.Content.Button1:Point('LEFT', StatusFrame.Section4.Content, 'LEFT')
	StatusFrame.Section4.Content.Button1:SetText('Forum')
	StatusFrame.Section4.Content.Button1:SetButtonState('DISABLED')
	StatusFrame.Section4.Content.Button2 = CreateFrame('Button', nil, StatusFrame.Section4.Content, 'UIPanelButtonTemplate')
	StatusFrame.Section4.Content.Button2:Size(100, 25)
	StatusFrame.Section4.Content.Button2:Point('RIGHT', StatusFrame.Section4.Content, 'RIGHT')
	StatusFrame.Section4.Content.Button2:SetText('Ticket')
	StatusFrame.Section4.Content.Button2:SetButtonState('DISABLED')
	Skins:HandleButton(StatusFrame.Section4.Content.Button1, true)
	Skins:HandleButton(StatusFrame.Section4.Content.Button2, true)]]

	return StatusFrame
end

function E:UpdateStatusFrame()
	local StatusFrame = E.StatusFrame

	--Section headers
	local valueColor = E.media.hexvaluecolor
	StatusFrame.Section1.Header.Text:SetFormattedText('%sAddOn Info|r', valueColor)
	StatusFrame.Section2.Header.Text:SetFormattedText('%sWoW Info|r', valueColor)
	StatusFrame.Section3.Header.Text:SetFormattedText('%sCharacter Info|r', valueColor)
	--StatusFrame.Section4.Header.Text:SetFormattedText('%sExport To|r', valueColor)

	local verWarning = E.recievedOutOfDateMessage and 'ff3333' or E.shownUpdatedWhileRunningPopup and 'ff9933'
	StatusFrame.Section1.Content.Line1.Text:SetFormattedText('Version of ElvUI: |cff%s%s|r', verWarning or '33ff33', E.version)

	local addons, plugins = E:AreOtherAddOnsEnabled()
	StatusFrame.Section1.Content.Line2.Text:SetFormattedText('Other AddOns Enabled: |cff%s|r', (not addons and plugins and 'ff9933Plugins') or (addons and 'ff3333Yes') or '33ff33No')

	local Section2 = StatusFrame.Section2
	Section2.Content.Line3.Text:SetFormattedText('Display Mode: |cff4beb2c%s|r', E:GetDisplayMode())
	Section2.Content.Line4.Text:SetFormattedText('Resolution: |cff4beb2c%s|r', E.resolution)

	local Section3 = StatusFrame.Section3
	Section3.Content.Line4.Text:SetFormattedText('Level: |cff4beb2c%s|r', E.mylevel)
	Section3.Content.Line5.Text:SetFormattedText('Zone: |cff4beb2c%s|r', GetRealZoneText())

	StatusFrame.TitleLogoFrame.LogoTop:SetVertexColor(unpack(E.media.rgbvaluecolor))
end

function E:ShowStatusReport()
	if not E.StatusFrame then
		E.StatusFrame = E:CreateStatusFrame()
	end

	if not E.StatusFrame:IsShown() then
		E:UpdateStatusFrame()
		E.StatusFrame:Raise() --Set framelevel above everything else
		E.StatusFrame:Show()
	else
		E.StatusFrame:Hide()
	end
end
