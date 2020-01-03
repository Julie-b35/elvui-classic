local E, _, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local next = next
local gsub = gsub
local ipairs = ipairs
local select = select
local format = format
local tinsert = tinsert
local strmatch = strmatch
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local getmetatable = getmetatable
local setmetatable = setmetatable
local rawset = rawset

-- these do *not* need to match the current lib minor version
-- these numbers are used to not attempt skinning way older
-- versions of AceGUI and AceConfigDialog.
local minorGUI, minorConfigDialog = 36, 76

function S:Ace3_SkinDropdown()
	if self and self.obj then
		if self.obj.pullout and self.obj.pullout.frame then
			self.obj.pullout.frame:SetTemplate(nil, true)
		elseif self.obj.dropdown then -- this will be LSM
			self.obj.dropdown:SetTemplate(nil, true)

			if self.obj.dropdown.slider then
				self.obj.dropdown.slider:SetTemplate()
				self.obj.dropdown.slider:SetThumbTexture(E.Media.Textures.White8x8)

				local t = self.obj.dropdown.slider:GetThumbTexture()
				t:SetVertexColor(1, .82, 0, 0.8)
			end
		end
	end
end

function S:Ace3_CheckBoxIsEnable(widget)
	local text = widget and widget.text and widget.text:GetText()
	if text and S.Ace3_EnableMatch then return strmatch(text, S.Ace3_EnableMatch) end
end

function S:Ace3_CheckBoxSetDesaturated(value)
	local widget = self:GetParent().obj
	if value == true then
		self:SetVertexColor(.6, .6, .6, .8)
	elseif S:Ace3_CheckBoxIsEnable(widget) then
		if widget.checked then
			self:SetVertexColor(0.2, 1.0, 0.2, 1.0)
		else
			self:SetVertexColor(1.0, 0.2, 0.2, 1.0)
		end
	else
		self:SetVertexColor(1, .82, 0, 0.8)
	end
end

function S:Ace3_CheckBoxSetDisabled(disabled)
	if S:Ace3_CheckBoxIsEnable(self) then
		local tristateOrDisabled = disabled or (self.tristate and self.checked == nil)
		self:SetLabel((tristateOrDisabled and S.Ace3_L.Enable) or (self.checked and S.Ace3_EnableOn) or S.Ace3_EnableOff)
	end
end

function S:Ace3_EditBoxSetTextInsets(l, r, t, b)
	if l == 0 then self:SetTextInsets(3, r, t, b) end
end

function S:Ace3_EditBoxSetPoint(a, b, c, d, e)
	if d == 7 then self:Point(a, b, c, 0, e) end
end

function S:Ace3_CreateTabSetPoint(a, b, c, d, e, f)
	if f ~= 'ignore' and a == 'TOPLEFT' then
		self:SetPoint(a, b, c, d, e+2, 'ignore')
	end
end

function S:Ace3_SkinTab(tab)
	tab:StripTextures()

	if not tab.backdrop then
		tab:CreateBackdrop()
	end

	tab.backdrop:Point('TOPLEFT', 10, -3)
	tab.backdrop:Point('BOTTOMRIGHT', -10, 0)

	if not tab.Ace3_CreateTabSetPoint then
		hooksecurefunc(tab, 'SetPoint', S.Ace3_CreateTabSetPoint)
		tab.Ace3_CreateTabSetPoint = true
	end
end

function S:Ace3_SkinPopup(popup)
	popup:SetTemplate('Transparent')
	popup:GetChildren():StripTextures()
	S:HandleButton(popup.accept, true)
	S:HandleButton(popup.cancel, true)
end

function S:Ace3_RegisterAsWidget(widget)
	local TYPE = widget.type
	if TYPE == 'MultiLineEditBox' then
		local frame = widget.frame

		if not widget.scrollBG.template then
			widget.scrollBG:SetTemplate()
		end

		S:HandleButton(widget.button)
		S:HandleScrollBar(widget.scrollBar)
		widget.scrollBar:Point('RIGHT', frame, 'RIGHT', 0 -4)
		widget.scrollBG:Point('TOPRIGHT', widget.scrollBar, 'TOPLEFT', -2, 19)
		widget.scrollBG:Point('BOTTOMLEFT', widget.button, 'TOPLEFT')
		widget.scrollFrame:Point('BOTTOMRIGHT', widget.scrollBG, 'BOTTOMRIGHT', -4, 8)
	elseif TYPE == 'CheckBox' then
		local check = widget.check
		local checkbg = widget.checkbg
		local highlight = widget.highlight

		if not checkbg.backdrop then
			checkbg:CreateBackdrop()
		end

		checkbg.backdrop:SetInside(widget.checkbg, 4, 4)
		checkbg.backdrop:SetFrameLevel(widget.checkbg.backdrop:GetFrameLevel() + 1)
		checkbg:SetTexture()
		highlight:SetTexture()

		if not widget.Ace3_CheckBoxSetDisabled then
			hooksecurefunc(widget, 'SetDisabled', S.Ace3_CheckBoxSetDisabled)
			widget.Ace3_CheckBoxSetDisabled = true
		end

		if E.private.skins.checkBoxSkin then
			if not widget.Ace3_CheckBoxSetDesaturated then
				S.Ace3_CheckBoxSetDesaturated(check, check:GetDesaturation())
				hooksecurefunc(check, 'SetDesaturated', S.Ace3_CheckBoxSetDesaturated)
				widget.Ace3_CheckBoxSetDesaturated = true
			end

			checkbg.backdrop:SetInside(widget.checkbg, 5, 5)
			check:SetInside(widget.checkbg.backdrop)
			check:SetTexture(E.Media.Textures.Melli)
			check.SetTexture = E.noop
		else
			check:SetOutside(widget.checkbg.backdrop, 3, 3)
		end

		checkbg.SetTexture = E.noop
		highlight.SetTexture = E.noop
	elseif TYPE == 'Dropdown' or TYPE == 'LQDropdown' then
		local frame = widget.dropdown
		local button = widget.button
		local button_cover = widget.button_cover
		local text = widget.text
		frame:StripTextures()

		S:HandleNextPrevButton(button, nil, {1, .8, 0})

		if not frame.backdrop then
			frame:CreateBackdrop()
		end

		frame.backdrop:Point('TOPLEFT', 15, -2)
		frame.backdrop:Point('BOTTOMRIGHT', -21, 0)
		frame.backdrop:SetClipsChildren(true)

		widget.label:ClearAllPoints()
		widget.label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)

		button:ClearAllPoints()
		button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
		button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)

		text:ClearAllPoints()
		text:SetJustifyH('RIGHT')
		text:Point('RIGHT', button, 'LEFT', -3, 0)
		text:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)

		button:SetParent(frame.backdrop)
		text:SetParent(frame.backdrop)
		button:HookScript('OnClick', S.Ace3_SkinDropdown)
		button_cover:HookScript('OnClick', S.Ace3_SkinDropdown)
	elseif TYPE == 'LSM30_Font' or TYPE == 'LSM30_Sound' or TYPE == 'LSM30_Border' or TYPE == 'LSM30_Background' or TYPE == 'LSM30_Statusbar' then
		local frame = widget.frame
		local button = frame.dropButton
		local text = frame.text
		frame:StripTextures()

		S:HandleNextPrevButton(button, nil, {1, .8, 0})

		if not frame.backdrop then
			frame:CreateBackdrop()
		end

		frame.label:ClearAllPoints()
		frame.label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)

		frame.text:ClearAllPoints()
		frame.text:Point('RIGHT', button, 'LEFT', -2, 0)
		frame.text:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)

		button:ClearAllPoints()
		button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
		button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)

		frame.backdrop:Point('TOPLEFT', 0, -21)
		frame.backdrop:Point('BOTTOMRIGHT', -4, -1)
		frame.backdrop:SetClipsChildren(true)

		if TYPE == 'LSM30_Sound' then
			widget.soundbutton:SetParent(frame.backdrop)
			widget.soundbutton:ClearAllPoints()
			widget.soundbutton:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
		elseif TYPE == 'LSM30_Statusbar' then
			widget.bar:SetParent(frame.backdrop)
			widget.bar:ClearAllPoints()
			widget.bar:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 2, -2)
			widget.bar:Point('BOTTOMRIGHT', button, 'BOTTOMLEFT', -1, 0)
		end

		button:SetParent(frame.backdrop)
		text:SetParent(frame.backdrop)
		button:HookScript('OnClick', S.Ace3_SkinDropdown)
	elseif TYPE == 'EditBox' then
		local frame = widget.editbox
		local button = widget.button
		S:HandleEditBox(frame)
		S:HandleButton(button)

		button:Point('RIGHT', frame.backdrop, 'RIGHT', -2, 0)

		if not frame.Ace3_EditBoxSetTextInsets then
			hooksecurefunc(frame, 'SetTextInsets', S.Ace3_EditBoxSetTextInsets)
			frame.Ace3_EditBoxSetTextInsets = true
		end
		if not frame.Ace3_EditBoxSetPoint then
			hooksecurefunc(frame, 'SetPoint', S.Ace3_EditBoxSetPoint)
			frame.Ace3_EditBoxSetPoint = true
		end

		frame.backdrop:Point('TOPLEFT', 0, -2)
		frame.backdrop:Point('BOTTOMRIGHT', -1, 0)
	elseif (TYPE == 'Button' or TYPE == 'Button-ElvUI') then
		local frame = widget.frame
		S:HandleButton(frame, true, nil, true)
		frame.backdrop:SetInside()

		widget.text:SetParent(frame.backdrop)
	elseif TYPE == 'Slider' or TYPE == 'Slider-ElvUI' then
		local frame = widget.slider
		local editbox = widget.editbox
		local lowtext = widget.lowtext
		local hightext = widget.hightext

		S:HandleSliderFrame(frame)

		editbox:SetTemplate()
		editbox:Height(15)
		editbox:Point('TOP', frame, 'BOTTOM', 0, -1)

		lowtext:Point('TOPLEFT', frame, 'BOTTOMLEFT', 2, -2)
		hightext:Point('TOPRIGHT', frame, 'BOTTOMRIGHT', -2, -2)
	elseif TYPE == 'Keybinding' then
		local button = widget.button
		local msgframe = widget.msgframe

		S:HandleButton(button, true, nil, true)
		button.backdrop:SetInside()

		msgframe:StripTextures()
		msgframe:SetTemplate('Transparent')
		msgframe.msg:ClearAllPoints()
		msgframe.msg:Point('CENTER')
	elseif (TYPE == 'ColorPicker' or TYPE == 'ColorPicker-ElvUI') then
		local frame = widget.frame
		local colorSwatch = widget.colorSwatch

		if not frame.backdrop then
			frame:CreateBackdrop()
		end

		frame.backdrop:Size(24, 16)
		frame.backdrop:ClearAllPoints()
		frame.backdrop:Point('LEFT', frame, 'LEFT', 4, 0)

		colorSwatch:SetTexture(E.media.blankTex)
		colorSwatch:ClearAllPoints()
		colorSwatch:SetParent(frame.backdrop)
		colorSwatch:SetInside(frame.backdrop)

		if colorSwatch.background then
			colorSwatch.background:SetColorTexture(0, 0, 0, 0)
		end

		if colorSwatch.checkers then
			colorSwatch.checkers:ClearAllPoints()
			colorSwatch.checkers:SetParent(frame.backdrop)
			colorSwatch.checkers:SetInside(frame.backdrop)
		end
	elseif TYPE == 'Icon' then
		widget.frame:StripTextures()
	end
end

function S:Ace3_RegisterAsContainer(widget)
	local TYPE = widget.type
	if TYPE == 'ScrollFrame' then
		S:HandleScrollBar(widget.scrollbar)
	elseif TYPE == 'InlineGroup' or TYPE == 'TreeGroup' or TYPE == 'TabGroup' or TYPE == 'Frame' or TYPE == 'DropdownGroup' or TYPE == 'Window' then
		local frame = widget.content:GetParent()
		if TYPE == 'Frame' then
			frame:StripTextures()
			for i=1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child:IsObjectType('Button') and child:GetText() then
					S:HandleButton(child)
				else
					child:StripTextures()
				end
			end
		elseif TYPE == 'Window' then
			frame:StripTextures()
			S:HandleCloseButton(frame.obj.closebutton)
		end

		if TYPE == 'InlineGroup' then
			frame:SetTemplate('Transparent')
			frame.ignoreBackdropColors = true
			frame:SetBackdropColor(0, 0, 0, 0.25)
		else
			frame:SetTemplate('Transparent')
		end

		if widget.treeframe then
			widget.treeframe:SetTemplate('Transparent')
			frame:Point('TOPLEFT', widget.treeframe, 'TOPRIGHT', 1, 0)

			if not widget.oldRefreshTree then
				widget.oldRefreshTree = widget.RefreshTree
				widget.RefreshTree = function(wdg, scrollToSelection)
					widget.oldRefreshTree(wdg, scrollToSelection)
					if not wdg.tree then return end
					local status = wdg.status or wdg.localstatus
					local groupstatus = status.groups
					local lines = wdg.lines
					local buttons = wdg.buttons
					local offset = status.scrollvalue

					for i = offset + 1, #lines do
						local button = buttons[i - offset]
						if button then
							button.highlight:SetVertexColor(1.0, 0.9, 0.0, 0.8)
							if groupstatus[lines[i].uniquevalue] then
								button.toggle:SetNormalTexture(E.Media.Textures.Minus)
								button.toggle:SetPushedTexture(E.Media.Textures.Minus)
								button.toggle:SetHighlightTexture('')
							else
								button.toggle:SetNormalTexture(E.Media.Textures.Plus)
								button.toggle:SetPushedTexture(E.Media.Textures.Plus)
								button.toggle:SetHighlightTexture('')
							end
						end
					end
				end
			end
		end

		if TYPE == 'TabGroup' then
			if not widget.oldCreateTab then
				widget.oldCreateTab = widget.CreateTab
				widget.CreateTab = function(wdg, id)
					local tab = widget.oldCreateTab(wdg, id)
					S:Ace3_SkinTab(tab)

					return tab
				end
			end

			if widget.tabs then
				for _, n in next, widget.tabs do
					S:Ace3_SkinTab(n)
				end
			end
		end

		if widget.scrollbar then
			S:HandleScrollBar(widget.scrollbar)
		end
	elseif TYPE == 'SimpleGroup' then
		local frame = widget.content:GetParent()
		frame:SetTemplate('Transparent')
		frame.ignoreBackdropColors = true
		frame:SetBackdropColor(0, 0, 0, 0.25)
	end

	if widget.sizer_se then
		for i = 1, widget.sizer_se:GetNumRegions() do
			local Region = select(i, widget.sizer_se:GetRegions())
			if Region and Region:IsObjectType("Texture") then
				Region:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
			end
		end
	end
end

function S:Ace3_StyleTooltip()
	if not self or self:IsForbidden() then return end
	if E.private.skins.ace3.enable then
		self:SetTemplate('Transparent', nil, true)
	end
end

function S:Ace3_MetaTable(lib)
	local t = getmetatable(lib)
	if t then
		t.__newindex = S.Ace3_MetaIndex
	else
		setmetatable(lib, {__newindex = S.Ace3_MetaIndex})
	end
end

function S:Ace3_SkinTooltip(lib, minor) -- lib: AceConfigDialog or AceGUI
	-- we only check `minor` here when checking an instance of AceConfigDialog
	-- we can safely ignore it when checking AceGUI because we minor check that
	-- inside of its own function.
	if not lib or (minor and minor < minorConfigDialog) then return end

	if not lib.tooltip then
		S:Ace3_MetaTable(lib)
	else
		if not S:IsHooked(lib.tooltip, 'OnShow') then
			S:SecureHookScript(lib.tooltip, 'OnShow', S.Ace3_StyleTooltip)
		end
		if not lib.popup.template then -- StaticPopup
			S:Ace3_SkinPopup(lib.popup)
		end
	end
end

function S:Ace3_MetaIndex(k, v)
	if k == 'tooltip' then
		rawset(self, k, v)
		S:SecureHookScript(v, 'OnShow', S.Ace3_StyleTooltip)
	elseif k == 'popup' then
		rawset(self, k, v)
		local t = getmetatable(v)
		if t then
			t.__newindex = function(q, w, e)
				rawset(q, w, e)
				if w == 'cancel' then
					S:Ace3_SkinPopup(q)
				end
			end
		end
	elseif k == 'RegisterAsContainer' then
		rawset(self, k, function(...)
			if E.private.skins.ace3.enable then
				S.Ace3_RegisterAsContainer(...)
			end
			return v(...)
		end)
	elseif k == 'RegisterAsWidget' then
		rawset(self, k, function(...)
			if E.private.skins.ace3.enable then
				S.Ace3_RegisterAsWidget(...)
			end
			return v(...)
		end)
	else
		rawset(self, k, v)
	end
end

local lastMinor = 0
function S:HookAce3(lib, minor, earlyLoad) -- lib: AceGUI
	if not lib or (not minor or minor < minorGUI) then return end

	if not S.Ace3_L and not earlyLoad then
		S.Ace3_L = E.Libs.ACL:GetLocale('ElvUI', (E.global and E.global.general.locale) or 'enUS')

		-- Special Enable Coloring
		if not S.Ace3_EnableMatch then S.Ace3_EnableMatch = '^|?c?[Ff]?[Ff]?%x?%x?%x?%x?%x?%x?' .. E:EscapeString(S.Ace3_L.Enable) .. '|?r?$' end
		if not S.Ace3_EnableOff then S.Ace3_EnableOff = format('|cffff3333%s|r', S.Ace3_L.Enable) end
		if not S.Ace3_EnableOn then S.Ace3_EnableOn = format('|cff33ff33%s|r', S.Ace3_L.Enable) end
	end

	local earlyContainer, earlyWidget
	local oldMinor = lastMinor
	if lastMinor < minor then
		lastMinor = minor
	end
	if earlyLoad then
		earlyContainer = lib.RegisterAsContainer
		earlyWidget = lib.RegisterAsWidget
	end
	if earlyLoad or oldMinor ~= minor then
		lib.RegisterAsContainer = nil
		lib.RegisterAsWidget = nil
	end

	if not lib.RegisterAsWidget then
		S:Ace3_MetaTable(lib)
	end

	if earlyContainer then lib.RegisterAsContainer = earlyContainer end
	if earlyWidget then lib.RegisterAsWidget = earlyWidget end

	S:Ace3_SkinTooltip(lib)
end

do -- Early Skin Loading
	local Libraries = {
		['AceGUI'] = true,
		['AceConfigDialog'] = true,
		['AceConfigDialog-3.0-ElvUI'] = true,
		['LibUIDropDownMenu'] = true,
		['LibUIDropDownMenuQuestie'] = true,
		['NoTaint_UIDropDownMenu'] = true,
	}

	S.EarlyAceWidgets = {}
	S.EarlyAceTooltips = {}
	S.EarlyDropdowns = {}

	local LibStub = _G.LibStub
	local numEnding = '%-[%d%.]+$'
	function S:LibStub_NewLib(major, minor)
		local earlyLoad = major == 'ElvUI'
		if earlyLoad then major = minor end

		local n = gsub(major, numEnding, '')
		if Libraries[n] then
			if n == 'AceGUI' then
				S:HookAce3(LibStub.libs[major], LibStub.minors[major], earlyLoad)
			elseif n == 'AceConfigDialog' or n == 'AceConfigDialog-3.0-ElvUI' then
				if earlyLoad then
					tinsert(S.EarlyAceTooltips, major)
				else
					S:Ace3_SkinTooltip(LibStub.libs[major], LibStub.minors[major])
				end
			else
				local prefix = (n == 'NoTaint_UIDropDownMenu' and 'Lib') or (n == 'LibUIDropDownMenuQuestie' and 'LQuestie') or (n == 'LibUIDropDownMenu' and 'L')
				if prefix and not S[prefix..'_UIDropDownMenuSkinned'] then
					if earlyLoad then
						tinsert(S.EarlyDropdowns, prefix)
					else
						S:SkinLibDropDownMenu(prefix)
					end
				end
			end
		end
	end

	local findWidget
	local function earlyWidget(y)
		if y.children then findWidget(y.children) end
		if y.frame and (y.base and y.base.Release) then
			tinsert(S.EarlyAceWidgets, y)
		end
	end

	findWidget = function(x)
		for _, y in ipairs(x) do
			earlyWidget(y)
		end
	end

	for n in next, LibStub.libs do
		if n == 'AceGUI-3.0' then
			for _, x in ipairs({_G.UIParent:GetChildren()}) do
				if x and x.obj then earlyWidget(x.obj) end
			end
		end
		if Libraries[gsub(n, numEnding, '')] then
			S:LibStub_NewLib('ElvUI', n)
		end
	end

	hooksecurefunc(LibStub, 'NewLibrary', S.LibStub_NewLib)
end
