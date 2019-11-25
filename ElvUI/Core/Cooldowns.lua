local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

--Lua functions
local next, ipairs, pairs = next, ipairs, pairs
local floor, tinsert = floor, tinsert
--WoW API / Variables
local GetTime = GetTime
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local FONT_SIZE = 20 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 2 --the minimum duration to show cooldown text for

function E:Cooldown_TooSmall(cd)
	if cd.parent then
		if cd.parent.hideText then return true end
		if cd.parent.skipScale then return end
	end

	return cd.fontScale and (cd.fontScale < MIN_SCALE)
end

function E:Cooldown_OnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if not E:Cooldown_IsEnabled(self) then
		E:Cooldown_StopTimer(self)
	else
		local now = GetTime()
		if self.endCooldown and now >= self.endCooldown then
			E:Cooldown_StopTimer(self)
		else
			if E:Cooldown_TooSmall(self) then
				self.text:SetText('')
				self.nextUpdate = 500
			else
				local value, id, nextUpdate, remainder = E:GetTimeInfo(self.endTime - now, self.threshold, self.hhmm, self.mmss)
				self.nextUpdate = nextUpdate

				if self.useColor then
					self.text:SetFormattedText(E.TimeFormats[id][3], value, self.indicatorColors[id], remainder)
				else
					self.text:SetFormattedText(E.TimeFormats[id][2], value, remainder)
				end

				local colors = self.timeColors[id]
				if colors then
					self.text:SetTextColor(colors.r, colors.g, colors.b)
				end

				if self.customUpdate then
					self.customUpdate(self, value, id, nextUpdate, remainder)
				end
			end
		end
	end
end

function E:Cooldown_OnSizeChanged(cd, width, force)
	local fontScale = width and (floor(width + .5) / ICON_SIZE)

	if fontScale and (fontScale == cd.fontScale) and (force ~= true) then return end
	cd.fontScale = fontScale

	if E:Cooldown_TooSmall(cd) then
		cd:Hide()
	else
		if cd.text then
			if cd.fontScale < MIN_SCALE then
				fontScale = MIN_SCALE
			end

			local useCustomFont = (cd.timerOptions and cd.timerOptions.fontOptions and cd.timerOptions.fontOptions.enable) and E.Libs.LSM:Fetch('font', cd.timerOptions.fontOptions.font)
			if useCustomFont then
				cd.text:FontTemplate(useCustomFont, (fontScale * cd.timerOptions.fontOptions.fontSize), cd.timerOptions.fontOptions.fontOutline)
			elseif fontScale then
				cd.text:FontTemplate(nil, (fontScale * FONT_SIZE), 'OUTLINE')
			end
		end

		if cd.enabled and (force ~= true) then
			self:Cooldown_ForceUpdate(cd)
		end
	end
end

function E:Cooldown_IsEnabled(cd)
	if cd.forceEnabled then
		return true
	elseif cd.forceDisabled then
		return false
	elseif cd.timerOptions and (cd.timerOptions.reverseToggle ~= nil) then
		return (E.db.cooldown.enable and not cd.timerOptions.reverseToggle) or (not E.db.cooldown.enable and cd.timerOptions.reverseToggle)
	else
		return E.db.cooldown.enable
	end
end

function E:Cooldown_ForceUpdate(cd)
	cd.nextUpdate = -1
	cd:Show()
end

function E:Cooldown_StopTimer(cd)
	cd.enabled = nil
	cd:Hide()
end

function E:Cooldown_CreateOptions(timer, db, parent)
	if not timer.timerOptions then
		timer.timerOptions = {}
	end

	timer.timerOptions.reverseToggle = db.cooldown.reverse
	timer.timerOptions.hideBlizzard = db.cooldown.hideBlizzard
	timer.timerOptions.useIndicatorColor = db.cooldown.useIndicatorColor

	if parent and db.cooldown.override and E.TimeColors[parent.CooldownOverride] and E.TimeIndicatorColors[parent.CooldownOverride] then
		timer.timerOptions.timeColors, timer.timerOptions.indicatorColors, timer.timerOptions.timeThreshold = E.TimeColors[parent.CooldownOverride], E.TimeIndicatorColors[parent.CooldownOverride], db.cooldown.threshold
	else
		timer.timerOptions.timeColors, timer.timerOptions.timeThreshold = nil, nil
	end

	if db.cooldown.checkSeconds then
		timer.timerOptions.hhmmThreshold, timer.timerOptions.mmssThreshold = db.cooldown.hhmmThreshold, db.cooldown.mmssThreshold
	else
		timer.timerOptions.hhmmThreshold, timer.timerOptions.mmssThreshold = nil, nil
	end

	if (db.cooldown ~= self.db.cooldown) and db.cooldown.fonts and db.cooldown.fonts.enable then
		timer.timerOptions.fontOptions = db.cooldown.fonts
	elseif self.db.cooldown.fonts and self.db.cooldown.fonts.enable then
		timer.timerOptions.fontOptions = self.db.cooldown.fonts
	else
		timer.timerOptions.fontOptions = nil
	end
end

function E:Cooldown_UpdateOptions(timer)
	timer.hhmm = (self.timerOptions and self.timerOptions.hhmmThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.hhmmThreshold)
	timer.mmss = (self.timerOptions and self.timerOptions.mmssThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.mmssThreshold)
	timer.indicatorColors = (self.timerOptions and self.timerOptions.indicatorColors) or E.TimeIndicatorColors
	timer.useColor = (self.timerOptions and self.timerOptions.useIndicatorColor) or E.db.cooldown.useIndicatorColor
	timer.timeColors = (self.timerOptions and self.timerOptions.timeColors) or E.TimeColors
	timer.threshold = (self.timerOptions and self.timerOptions.timeThreshold) or E.db.cooldown.threshold or E.TimeThreshold
end

function E:CreateCooldownTimer(parent)
	local timer = CreateFrame('Frame', nil, parent)
	timer:Hide()
	timer:SetAllPoints()
	timer.parent = parent
	parent.timer = timer

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:Point('CENTER', 1, 1)
	text:SetJustifyH('CENTER')
	timer.text = text

	-- can be used to modify elements created from this function
	if parent.CooldownPreHook then
		parent.CooldownPreHook(parent)
	end

	-- cooldown override settings
	if parent.CooldownOverride then
		local db = E.db[parent.CooldownOverride]
		if db and db.cooldown then
			timer.timerOptions = E:Cooldown_CreateOptions(timer, db, parent)

			-- prevent LibActionBar from showing blizzard CD when the CD timer is created
			if AB and (parent.CooldownOverride == 'actionbar') then
				AB:ToggleCountDownNumbers(nil, nil, parent)
			end
		end
	end

	E:Cooldown_UpdateOptions(timer)
	E:ToggleBlizzardCooldownText(parent, timer)

	-- keep an eye on the size so we can rescale the font if needed
	self:Cooldown_OnSizeChanged(timer, parent:GetWidth())
	parent:SetScript('OnSizeChanged', function(_, width)
		self:Cooldown_OnSizeChanged(timer, width)
	end)

	-- keep this after Cooldown_OnSizeChanged
	timer:SetScript('OnUpdate', E.Cooldown_OnUpdate)

	return timer
end

E.RegisteredCooldowns = {}
function E:OnSetCooldown(start, duration)
	if (not self.forceDisabled) and (start and duration) and (duration > MIN_DURATION) then
		local timer = self.timer or E:CreateCooldownTimer(self)
		timer.start = start
		timer.duration = duration
		timer.endTime = start + duration
		timer.endCooldown = timer.endTime - 0.05
		timer.nextUpdate = -1
		timer:Show()
	elseif self.timer then
		E:Cooldown_StopTimer(self.timer)
	end
end

function E:RegisterCooldown(cooldown)
	if not cooldown.isHooked then
		hooksecurefunc(cooldown, 'SetCooldown', E.OnSetCooldown)
		cooldown.isHooked = true
	end

	if not cooldown.isRegisteredCooldown then
		local module = (cooldown.CooldownOverride or 'global')
		if not E.RegisteredCooldowns[module] then E.RegisteredCooldowns[module] = {} end

		tinsert(E.RegisteredCooldowns[module], cooldown)
		cooldown.isRegisteredCooldown = true
	end
end

function E:ToggleBlizzardCooldownText(cd, timer, request)
	-- we should hide the blizzard cooldown text when ours are enabled
	if timer and cd and cd.SetHideCountdownNumbers then
		local forceHide = cd.hideText or (timer.timerOptions and timer.timerOptions.hideBlizzard) or (E.db and E.db.cooldown and E.db.cooldown.hideBlizzard)
		if request then
			return forceHide or E:Cooldown_IsEnabled(timer)
		else
			cd:SetHideCountdownNumbers(forceHide or E:Cooldown_IsEnabled(timer))
		end
	end
end

function E:GetCooldownColors(db)
	if not db then db = self.db.cooldown end -- just incase someone calls this without a first arg use the global
	local c13 = E:RGBToHex(db.hhmmColorIndicator.r, db.hhmmColorIndicator.g, db.hhmmColorIndicator.b) -- color for timers that are soon to expire
	local c12 = E:RGBToHex(db.mmssColorIndicator.r, db.mmssColorIndicator.g, db.mmssColorIndicator.b) -- color for timers that are soon to expire
	local c11 = E:RGBToHex(db.expireIndicator.r, db.expireIndicator.g, db.expireIndicator.b) -- color for timers that are soon to expire
	local c10 = E:RGBToHex(db.secondsIndicator.r, db.secondsIndicator.g, db.secondsIndicator.b) -- color for timers that have seconds remaining
	local c9 = E:RGBToHex(db.minutesIndicator.r, db.minutesIndicator.g, db.minutesIndicator.b) -- color for timers that have minutes remaining
	local c8 = E:RGBToHex(db.hoursIndicator.r, db.hoursIndicator.g, db.hoursIndicator.b) -- color for timers that have hours remaining
	local c7 = E:RGBToHex(db.daysIndicator.r, db.daysIndicator.g, db.daysIndicator.b) -- color for timers that have days remaining
	local c6 = db.hhmmColor -- HH:MM color
	local c5 = db.mmssColor -- MM:SS color
	local c4 = db.expiringColor -- color for timers that are soon to expire
	local c3 = db.secondsColor -- color for timers that have seconds remaining
	local c2 = db.minutesColor -- color for timers that have minutes remaining
	local c1 = db.hoursColor -- color for timers that have hours remaining
	local c0 = db.daysColor -- color for timers that have days remaining
	return c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13
end

function E:UpdateCooldownOverride(module)
	local cooldowns = (module and E.RegisteredCooldowns[module])
	if (not cooldowns) or not next(cooldowns) then return end

	local customFont, customFontSize, blizzText
	for _, parent in ipairs(cooldowns) do
		local db = (parent.CooldownOverride and E.db[parent.CooldownOverride]) or self.db
		db = db and db.cooldown

		if db then
			local timer = parent.isHooked and parent.isRegisteredCooldown and parent.timer
			local cd = timer or parent

			-- cooldown override settings
			cd.timerOptions = E:Cooldown_CreateOptions(cd, db, parent)

			-- update font
			if timer and cd then
				self:Cooldown_OnSizeChanged(cd, parent:GetWidth(), true)
			else
				if cd.text then
					if cd.timerOptions.fontOptions and cd.timerOptions.fontOptions.enable then
						if not customFont then
							customFont = E.Libs.LSM:Fetch('font', cd.timerOptions.fontOptions.font)
						end
						if customFont then
							cd.text:FontTemplate(customFont, cd.timerOptions.fontOptions.fontSize, cd.timerOptions.fontOptions.fontOutline)
						end
					elseif parent.CooldownOverride then
						if not customFont then
							customFont = E.Libs.LSM:Fetch('font', E.db[parent.CooldownOverride].font)
						end

						-- parent.auraType defined in `A:UpdateHeader` and `A:CreateIcon`
						if customFont and parent.auraType and (parent.CooldownOverride == 'auras') then
							customFontSize = E.db[parent.CooldownOverride][parent.auraType] and E.db[parent.CooldownOverride][parent.auraType].durationFontSize
							if customFontSize then
								cd.text:FontTemplate(customFont, customFontSize, E.db[parent.CooldownOverride].fontOutline)
							end
						end
					end
				end
			end

			-- force update cooldown
			if timer and cd then
				E:Cooldown_ForceUpdate(cd)
				E:ToggleBlizzardCooldownText(parent, cd)

				if (not blizzText) and AB and AB.handledBars and (parent.CooldownOverride == 'actionbar') then
					blizzText = true
				end
			elseif parent.CooldownOverride == 'auras' and not (timer and cd) then
				parent.nextUpdate = -1
			end
		end
	end

	if blizzText then
		for _, bar in pairs(AB.handledBars) do
			if bar then
				AB:ToggleCountDownNumbers(bar)
			end
		end
	end
end

function E:UpdateCooldownSettings(module)
	local cooldownDB, timeColors, indicatorColors = self.db.cooldown, E.TimeColors, E.TimeIndicatorColors

	-- update the module timecolors if the config called it but ignore 'global' and 'all':
	-- global is the main call from config, all is the core file calls
	local isModule = module and (module ~= 'global' and module ~= 'all') and self.db[module] and self.db[module].cooldown
	if isModule then
		if not E.TimeColors[module] then E.TimeColors[module] = {} end
		if not E.TimeIndicatorColors[module] then E.TimeIndicatorColors[module] = {} end
		cooldownDB, timeColors, indicatorColors = self.db[module].cooldown, E.TimeColors[module], E.TimeIndicatorColors[module]
	end

	timeColors[0], timeColors[1], timeColors[2], timeColors[3], timeColors[4], timeColors[5], timeColors[6], indicatorColors[0], indicatorColors[1], indicatorColors[2], indicatorColors[3], indicatorColors[4], indicatorColors[5], indicatorColors[6] = E:GetCooldownColors(cooldownDB)

	if isModule then
		E:UpdateCooldownOverride(module)
	elseif module == 'global' then -- this is only a call from the config change
		for key in pairs(E.RegisteredCooldowns) do
			E:UpdateCooldownOverride(key)
		end
	end

	-- okay update the other override settings if it was one of the core file calls
	if module and (module == 'all') then
		E:UpdateCooldownSettings('bags')
		E:UpdateCooldownSettings('nameplates')
		E:UpdateCooldownSettings('actionbar')
		E:UpdateCooldownSettings('unitframe')
		E:UpdateCooldownSettings('auras') -- has special OnUpdate
	end
end
