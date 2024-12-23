local canExecute = false
local lastDriveVal = 0

function _OnInit()
	GameVersion = 0
end

function GetVersion()
	if GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
        --[[if ENGINE_VERSION < 5.0 then
            ConsolePrint('LuaBackend is outdated', 2)
			return
        end
		Slot1    = 0x2A20C58 - 0x56450E
		Save 	 = 0x09A7070 - 0x56450E
		Pause 	 = 0xBEBD28 - 0x56454E]]

		if ReadString(0x09A92F0,4) == 'KH2J' then --EGS
			GameVersion = 2
			Save = 0x09A92F0
			Pause = 0x0ABB2B8
			Slot1    = 0x2A22FD8
		elseif ReadString(0x09A9830,4) == 'KH2J' then --Steam Global
			GameVersion = 3
			Save = 0x09A9830
			Pause = 0x0ABB7F8
			Slot1    = 0x2A23518
		elseif ReadString(0x09A8830,4) == 'KH2J' then --Steam JP
			GameVersion = 4
			Save = 0x09A8830
			Pause = 0x0ABA7F8
			Slot1    = 0x2A22518
		end

		canExecute = true
    end
end

function _OnFrame()
	if GameVersion == 0 then --Get anchor addresses
		GetVersion()
		return
	end

	--Check if Drive is decreasing
	if ReadFloat(Slot1+0x1B4) ~= lastDriveVal then
		--ConsolePrint("Decreasing")
		--Limit
		if ReadByte(Save+0x3524) == 3 and ReadByte(Pause) ~= 3 then
			--WriteFloat(Slot1+0x1B4,ReadFloat(Slot1+0x1B4)-0.25)
		--Final
		elseif ReadByte(Save+0x3524) == 5 and ReadByte(Pause) ~= 3 then
			WriteFloat(Slot1+0x1B4,ReadFloat(Slot1+0x1B4)-0.25)
		--Valor
		elseif ReadByte(Save+0x3524) == 1 and ReadByte(Pause) ~= 3 then
			WriteFloat(Slot1+0x1B4,ReadFloat(Slot1+0x1B4)+0.1)
		end
	end

	lastDriveVal = ReadFloat(Slot1+0x1B4)
end