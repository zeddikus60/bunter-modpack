--Updated for v1.0.0.9 Steam and Epic Global

local canExecute = false

function _OnFrame()
	if canExecute == true then
		World = ReadByte(Now + 0x00)
		Room = ReadByte(Now + 0x01)
		Place = ReadShort(Now + 0x00)
		Door = ReadShort(Now + 0x02)
		Map = ReadShort(Now + 0x04)
		Btl = ReadShort(Now + 0x06)
		Evt = ReadShort(Now + 0x08)
		Cheats()
	end
end

function _OnInit()
	if GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
		canExecute = true
		if ReadByte(0x566A8E) == 0xFF then --EGS Global
			Platform = 'PC-Epic'
			Now = 0x0716DF8
			Save = 0x09A92F0
			Obj0Pointer = 0x2A24A70
			Sys3Pointer = 0x2AE5890
			Btl0Pointer = 0x2AE5898
			Cntrl = 0x2A16C28
			Obj0 = ReadLong(Obj0Pointer)
			Sys3 = ReadLong(Sys3Pointer)
			Btl0 = ReadLong(Btl0Pointer)
			Slot1 = 0x2A22FD8
			ConsolePrint('Epic Games Global')
		elseif ReadByte(0x56668E) == 0xFF then --Steam Global
			Platform = 'PC-Steam'
			Now = 0x0717008
			Save = 0x09A9830
			Obj0Pointer = 0x2A24FB0
			Sys3Pointer = 0x2AE5DD0
			Btl0Pointer = 0x2AE5DD8
			Cntrl = 0x2A17168
			Obj0 = ReadLong(Obj0Pointer)
			Sys3 = ReadLong(Sys3Pointer)
			Btl0 = ReadLong(Btl0Pointer)
			Slot1 = 0x2A23518
			ConsolePrint('Steam Global')
		else
			canExecute = false
			ConsolePrint('KH2 not detected, not running script')
		end
	else
		ConsolePrint('KH2 not detected, not running script')
	end
end

function Events(M,B,E) --Check for Map, Btl, and Evt
    return ((Map == M or not M) and (Btl == B or not B) and (Evt == E or not E))
end

function Cheats()
	if ReadShort(Now+0) ~= 0x0110 and ReadShort(Now+0) ~= 0x080E then
		if ReadByte(Save+0x24F9) < 4 and ReadByte(Cntrl) == 0 then -- If a # of Boosts given is less than 4
			WriteByte(Slot1+0x188, ReadByte(Slot1+0x188) + 1) -- Add 1 boost to Sora
			WriteByte(Save+0x24F9, ReadByte(Save+0x24F9) + 1) -- Add 1 to the counter
		--[[elseif ReadByte(Save+0x24FA) < 4 and ReadByte(Cntrl) == 0 then -- Magic Boosts
			WriteByte(Slot1+0x18A, ReadByte(Slot1+0x18A) + 1)
			WriteByte(Save+0x24FA, ReadByte(Save+0x24FA) + 1)
		elseif ReadByte(Save+0x24FB) < 4 and ReadByte(Cntrl) == 0 then -- Defense Boosts
			WriteByte(Slot1+0x18C, ReadByte(Slot1+0x18C) + 1)
			WriteByte(Save+0x24FB, ReadByte(Save+0x24FB) + 1)
		elseif ReadByte(Save+0x24F8) < 4 and ReadByte(Cntrl) == 0 then -- AP Boosts
			WriteByte(Slot1+0x18E, ReadByte(Slot1+0x18E) + 1)
			WriteByte(Save+0x24F8, ReadByte(Save+0x24F8) + 1)]]
		end
	end
end
