hasRevertedGrowthText = false
-- hasUpdatedGrowthText = false

prevHJ = -1
prevQR = -1
prevDR = -1
prevAD = -1
prevG = -1

function _OnInit()
	GameVersion = 0
end

function GetVersion()
	print('Accurate Growth Levels v2.0.0')
	GoAOffset = 0x7C
	if (GAME_ID == 0xF266B00B or GAME_ID == 0xFAF99301) and ENGINE_TYPE == "ENGINE" then --PCSX2
		if ENGINE_VERSION < 3.0 then
			print('LuaEngine is Outdated. Things might not work properly.')
		end
		onPC = false
	elseif GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
		onPC = true
		if ReadString(0x09A92F0,4) == 'KH2J' then --EGS
			GameVersion = 2
			Now = 0x0716DF8
			Save = 0x09A92F0
			Sys3Pointer = 0x2AE5890
			PauseMenu = 0x743350
			Sys3 = ReadLong(Sys3Pointer)
		elseif ReadString(0x09A9830,4) == 'KH2J' then --Steam Global
			GameVersion = 3
			Now = 0x0717008
			Save = 0x09A9830
			Sys3Pointer = 0x2AE5DD0
			PauseMenu = 0x7435D0
			Sys3 = ReadLong(Sys3Pointer)
		elseif ReadString(0x09A8830,4) == 'KH2J' then --Steam JP
			GameVersion = 4
			Now = 0x0716008
			Save = 0x09A8830
			Sys3Pointer = 0x2AE4DD0
			PauseMenu = 0x7425D0
			Sys3 = ReadLong(Sys3Pointer)
		end
	end
end

function _OnFrame()
	if GameVersion == 0 then --Get anchor addresses
		GetVersion()
		return
	end

	if not onPC then
		return
	end

	Slot70 = Save+0x25CE -- High Jump
	Slot71 = Save+0x25D0 -- Quick Run
	Slot72 = Save+0x25D2 -- Dodge Roll
	Slot73 = Save+0x25D4 -- Aerial Dodge
	Slot74 = Save+0x25D6 -- Glide

	if ReadByte(PauseMenu) == 10 then
		-- In Pause Menu, put everything back to normal
		if not hasRevertedGrowthText then
			--print('Reverting Growth Text to original')
			revertGrowthText(Save+0x25CE, Sys3+0x11754, 0x064C) -- High Jump
			revertGrowthText(Save+0x25D0, Sys3+0x117B4, 0x0654) -- Quick Run
			revertGrowthText(Save+0x25D2, Sys3+0x11814, 0x4E83) -- Dodge Roll
			revertGrowthText(Save+0x25D4, Sys3+0x11874, 0x065C) -- Aerial Dodge
			revertGrowthText(Save+0x25D6, Sys3+0x118D4, 0x0664) -- Glide
			hasRevertedGrowthText = true
		end
	else
		-- In the field, fuck shit up
		if hasRevertedGrowthText then
			--print('In the field, updating custom text')
		end
		updateGrowthText(Save+0x25CE, 0x05E, Sys3+0x11754, 0x064C, prevHJ) -- High Jump
		prevHJ = ReadShort(Save+0x25CE) & 0x0FFF
		updateGrowthText(Save+0x25D0, 0x062, Sys3+0x117B4, 0x0654, prevQR) -- Quick Run
		prevQR = ReadShort(Save+0x25D0) & 0x0FFF
		updateGrowthText(Save+0x25D2, 0x234, Sys3+0x11814, 0x4E83, prevDR) -- Dodge Roll
		prevDR = ReadShort(Save+0x25D2) & 0x0FFF
		updateGrowthText(Save+0x25D4, 0x066, Sys3+0x11874, 0x065C, prevAD) -- Aerial Dodge
		prevAD = ReadShort(Save+0x25D4) & 0x0FFF
		updateGrowthText(Save+0x25D6, 0x06A, Sys3+0x118D4, 0x0664, prevG) -- Glide
		prevG = ReadShort(Save+0x25D6) & 0x0FFF
		hasRevertedGrowthText = false
	end
end

function revertGrowthText(slotNum, baseLevelAddress, baseLevelName)
	lvl1 = baseLevelAddress
	lvl2 = lvl1 + 0x18
	lvl3 = lvl2 + 0x18
	lvl4 = lvl3 + 0x18
	WriteShort(lvl1+0x8, baseLevelName, onPC) -- Lvl 1
	WriteShort(lvl1+0xA, baseLevelName + 1, onPC) -- Lvl 1 Description
	WriteShort(lvl2+0x8, baseLevelName + 2, onPC) -- Lvl 2
	WriteShort(lvl2+0xA, baseLevelName + 3, onPC) -- Lvl 2 Description
	WriteShort(lvl3+0x8, baseLevelName + 4, onPC) -- Lvl 3
	WriteShort(lvl3+0xA, baseLevelName + 5, onPC) -- Lvl 3 Description
	WriteShort(lvl4+0x8, baseLevelName + 6, onPC) -- Max
	WriteShort(lvl4+0xA, baseLevelName + 7, onPC) -- Max Description
end

function updateGrowthText(slotNum, baseAbilityAddress, baseLevelAddress, baseLevelName, prevAbility)
	lvl1 = baseLevelAddress
	lvl2 = lvl1 + 0x18
	lvl3 = lvl2 + 0x18
	lvl4 = lvl3 + 0x18
	slotAbility = ReadShort(slotNum) & 0x0FFF
	if prevAbility ~= slotAbility or hasRevertedGrowthText then
		if slotAbility < baseAbilityAddress then
			-- I don't have this growth at all, so set all growth text to Lvl 1
			WriteShort(lvl1+0x8, baseLevelName, onPC) -- Lvl 1
			WriteShort(lvl1+0xA, baseLevelName + 1, onPC) -- Lvl 1 Description
			WriteShort(lvl2+0x8, baseLevelName, onPC) -- Lvl 2
			WriteShort(lvl2+0xA, baseLevelName + 1, onPC) -- Lvl 2 Description
			WriteShort(lvl3+0x8, baseLevelName, onPC) -- Lvl 3
			WriteShort(lvl3+0xA, baseLevelName + 1, onPC) -- Lvl 3 Description
			WriteShort(lvl4+0x8, baseLevelName, onPC) -- Max
			WriteShort(lvl4+0xA, baseLevelName + 1, onPC) -- Max Description
		elseif slotAbility < (baseAbilityAddress + 3) then
			-- I have this growth in my inventory, set all growth text to next level
			currentGrowthLevel = slotAbility - baseAbilityAddress + 1
			nextLevelName = baseLevelName + (2 * currentGrowthLevel)
			nextLevelDescription = baseLevelName + 1 + (2 * currentGrowthLevel)
			WriteShort(lvl1+0x8, nextLevelName, onPC) -- Lvl 1
			WriteShort(lvl1+0xA, nextLevelDescription, onPC) -- Lvl 1 Description
			WriteShort(lvl2+0x8, nextLevelName, onPC) -- Lvl 2
			WriteShort(lvl2+0xA, nextLevelDescription, onPC) -- Lvl 2 Description
			WriteShort(lvl3+0x8, nextLevelName, onPC) -- Lvl 3
			WriteShort(lvl3+0xA, nextLevelDescription, onPC) -- Lvl 3 Description
			WriteShort(lvl4+0x8, nextLevelName, onPC) -- Max
			WriteShort(lvl4+0xA, nextLevelDescription, onPC) -- Max Description
		end
	end
end
