--Updated for v1.0.0.9 Steam and Epic Global
function _OnInit()
    kh2libstatus, kh2lib = pcall(require, "kh2lib")
    if not kh2libstatus then
        print("ERROR (GoA): KH2-Lua-Library mod is not installed")
        CanExecute = false
        return
    end

    CanExecute = kh2lib.CanExecute
    if not CanExecute then
        return
    end

	StaticPointersLoaded = false

	Now = kh2lib.Now
	Save = kh2lib.Save
	Cntrl = kh2lib.Cntrl
	Slot1 = kh2lib.Slot1
	print('4STr Loaded')
end

--[[if not StaticPointersLoaded then
    Obj0 = ReadPointer(kh2lib.Obj0Pointer)
    Sys3 = ReadPointer(kh2lib.Sys3Pointer)
    Btl0 = ReadPointer(kh2lib.Btl0Pointer)
    StaticPointersLoaded = true
end]]--

function _OnFrame()
	--Get anchor addresses
	if not CanExecute
		then return
	else
		World  = ReadByte(Now+0x00)
		Room   = ReadByte(Now+0x01)
		Place  = ReadShort(Now+0x00)
		Door   = ReadShort(Now+0x02)
		Map    = ReadShort(Now+0x04)
		Btl    = ReadShort(Now+0x06)
		Evt    = ReadShort(Now+0x08)
		Cheats()
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
