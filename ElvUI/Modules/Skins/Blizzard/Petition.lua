local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

function S:SkinPetition()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.petition) then return end

	local PetitionFrame = _G.PetitionFrame
	S:HandleFrame(PetitionFrame, true, nil, 12, -17, -28, 65)

	S:HandleButton(_G.PetitionFrameSignButton)
	S:HandleButton(_G.PetitionFrameRequestButton)
	S:HandleButton(_G.PetitionFrameRenameButton)
	S:HandleButton(_G.PetitionFrameCancelButton)
	S:HandleCloseButton(_G.PetitionFrameCloseButton)

	_G.PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
	_G.PetitionFrameCharterName:SetTextColor(1, 1, 1)
	_G.PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
	_G.PetitionFrameMasterName:SetTextColor(1, 1, 1)
	_G.PetitionFrameMemberTitle:SetTextColor(1, 1, 0)

	for i = 1, 9 do
		_G['PetitionFrameMemberName'..i]:SetTextColor(1, 1, 1)
	end

	_G.PetitionFrameInstructions:SetTextColor(1, 1, 1)

	_G.PetitionFrameRenameButton:Point('LEFT', _G.PetitionFrameRequestButton, 'RIGHT', 3, 0)
	_G.PetitionFrameRenameButton:Point('RIGHT', _G.PetitionFrameCancelButton, 'LEFT', -3, 0)
end

S:AddCallback('SkinPetition')
