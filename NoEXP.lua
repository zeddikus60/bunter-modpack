--Set Initial Values
function _OnInit()
	GameVersion = 0
end

function GetVersion() --Define anchor addresses
	if (GAME_ID == 0xF266B00B or GAME_ID == 0xFAF99301) and ENGINE_TYPE == "ENGINE" then --PCSX2
		OnPC = false
		GameVersion = 1
		Now = 0x032BAE0 --Current Location
		Save = 0x032BB30 --Save File
		BtlTyp = 0x1C61958 --Battle Status (Out-of-Battle, Regular, Forced)
		Slot1    = 0x1C6C750 --Unit Slot 1
	elseif GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
		OnPC = true
		if ReadString(0x09A92F0,4) == 'KH2J' then --EGS
			GameVersion = 2
			Now = 0x0716DF8
			Save = 0x09A92F0
			BtlTyp = 0x2A10E44
			Slot1    = 0x2A22FD8
		elseif ReadString(0x09A9830,4) == 'KH2J' then --Steam Global
			GameVersion = 3
			Now = 0x0717008
			Save = 0x09A9830
			BtlTyp = 0x2A11384
			Slot1    = 0x2A23518
		elseif ReadString(0x09A8830,4) == 'KH2J' then --Steam JP
			GameVersion = 4
			Now = 0x0716008
			Save = 0x09A8830
			BtlTyp = 0x2A10384
			Slot1    = 0x2A22518
		end
	end
end

local function BitOr(Address,Bit,Abs)
	WriteByte(Address,ReadByte(Address)|Bit,Abs and OnPC)
end
local function BitNot(Address,Bit,Abs)
	WriteByte(Address,ReadByte(Address)&~Bit,Abs and OnPC)
end

local world = 0x00
local room = 0x00
local event = 0x00
local prev_World = 0x00
local prev_Room = 0x00
local prev_event = 0x00
local equip = false
function _OnFrame()
	if GameVersion == 0 then --Get anchor addresses
		GetVersion()
		return
	end

    --------Checks for Current room
	--if going to a new room
    if world ~= ReadByte(Now + 0x00) or room ~= ReadByte(Now + 0x01) or event ~= ReadByte(Now + 0x08) then
		prev_World = world
		prev_Room = room
		prev_event = event
	end
	world = ReadByte(Now + 0x00)
	room = ReadByte(Now + 0x01)
	event = ReadByte(Now + 0x08)

	equip = false
	if (world == 0x04 and room == 0x1A) or
		--STT
		(world == 0x02 and room == 0x22 and event == 0x9D) or
		(world == 0x02 and room == 0x05 and event == 0x57) or
		(world == 0x02 and room == 0x14 and event == 0x89) or	
		(world == 0x02 and room == 0x14 and event == 0xD5) or	
		(world == 0x12 and room == 0x15 and event == 0x63) or
		--HB
		(world == 0x04 and room == 0x04 and event == 0x37) or
		(world == 0x04 and room == 0x04 and event == 0x72) or
		(world == 0x04 and room == 0x01 and event == 0x4B) or
		--BC
		(world == 0x05 and room == 0x0B and event == 0x48) or
		(world == 0x05 and room == 0x05 and event == 0x4E) or
		(world == 0x05 and room == 0x05 and event == 0x4F) or
		(world == 0x05 and room == 0x0F and event == 0x52) or
		(world == 0x05 and room == 0x0F and event == 0x61) or
		--OC
		(world == 0x06 and room == 0x07 and event == 0x72) or
		(world == 0x06 and room == 0x08 and event == 0x74) or
		(world == 0x06 and room == 0x12 and event == 0xAB) or
		(world == 0x06 and room == 0x13 and event == 0xCA) or
		(world == 0x04 and room == 0x22 and event == 0x97) or
		(world == 0x04 and room == 0x22 and event == 0x98) or
		--AG
		(world == 0x07 and room == 0x03 and event == 0x3B) or
		(world == 0x07 and room == 0x05 and event == 0x3E) or
		(world == 0x04 and room == 0x21 and event == 0x8E) or
		(world == 0x04 and room == 0x21 and event == 0x93) or
		--LoD
		(world == 0x08 and room == 0x09 and event == 0x4B) or
		(world == 0x08 and room == 0x07 and event == 0x4C) or
		(world == 0x08 and room == 0x08 and event == 0x4F) or
		(world == 0x12 and room == 0x0A and event == 0x64) or
		--PL
		(world == 0x0A and room == 0x0E and event == 0x37) or
		--DC/TR
		(world == 0x0D and room == 0x01 and event == 0x3A) or
		(world == 0x0D and room == 0x03 and event == 0x35) or
		(world == 0x0C and room == 0x07 and event == 0x43) or
		(world == 0x0C and room == 0x07 and event == 0x49) or
		(world == 0x04 and room == 0x26 and event == 0x91) or
		(world == 0x04 and room == 0x26 and event == 0x96) or
		--PR
		(world == 0x10 and room == 0x0A and event == 0x3C) or
		(world == 0x10 and room == 0x12 and event == 0x55) or
		(world == 0x10 and room == 0x01 and event == 0x36) or
		(world == 0x12 and room == 0x0E and event == 0x65) or
		--HT
		(world == 0x0E and room == 0x03 and event == 0x34) or
		(world == 0x0E and room == 0x09 and event == 0x37) or
		(world == 0x0E and room == 0x07 and event == 0x40) or
		(world == 0x04 and room == 0x20 and event == 0x73) or
		(world == 0x04 and room == 0x20 and event == 0x92) or
		--SP
		(world == 0x11 and room == 0x04 and event == 0x37) or
		(world == 0x11 and room == 0x09 and event == 0x3A) or
		(world == 0x11 and room == 0x09 and event == 0x3B) or
		(world == 0x04 and room == 0x21 and event == 0x8F) or
		(world == 0x04 and room == 0x21 and event == 0x94) or
		--TWTNW
		(world == 0x12 and room == 0x15 and event == 0x41) or
		(world == 0x12 and room == 0x0A and event == 0x39) or
		(world == 0x12 and room == 0x0E and event == 0x3A) or
		(world == 0x12 and room == 0x0F and event == 0x38) or
		(world == 0x12 and room == 0x0F and event == 0x66) or
		(world == 0x12 and room == 0x13 and event == 0x3B) or
		(world == 0x12 and room == 0x13 and event == 0x61) or
		(world == 0x12 and room == 0x14 and event == 0x62) or
		(world == 0x12 and room == 0x17 and event == 0x49) or
		(world == 0x12 and room == 0x18 and event == 0x3A) then
		equip = true
	end


    --------Force equip no exp
    local NoExpCount = 0 --no exps equipped
    for Slot = 0,68 do
        local Current = Save + 0x2544 + 2*Slot
        local Ability = ReadShort(Current) & 0x0FFF
		--No Exp Check
        if Ability == 0x0194 then
			--if not equipped and supposed to equip
			if equip then
                WriteShort(Current,Ability)
				--print("equipping")
            else
				WriteShort(Current,Ability+0x8000)
				--print("Unequipping")
			end
		end
    end
	--------Force equip no exp
end