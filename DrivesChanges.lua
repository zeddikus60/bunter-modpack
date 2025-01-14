local lastDriveVal = 0

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
	Save = kh2lib.Save
	Pause = kh2lib.Pause
	Slot1 = kh2lib.Slot1
	print('Drive Form Changes Loaded')
end

function _OnFrame()
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