local GameVersion = 0
local canExecute = false

function _OnInit()
  GameVersion = 0
end

function GetVersion() --Define anchor addresses
    if GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
        if ReadString(0x09A70B0 - 0x56454E,4) == 'KH2J' then --EGS 1.0.0.8
            GameVersion = 1
            print('Epic Version 1.0.0.8_WW Detected - CutsceneSkipper')
            Now = 0x0714DB8 - 0x56454E --Current Location
            Save = 0x09A70B0 - 0x56454E --Save File
            CutNow = 0x0B62798 - 0x56454E --Cutscene Timer
            CutLen = 0x0B627B4 - 0x56454E --Cutscene Length
            CutSkp = 0x0B6279C - 0x56454E --Cutscene Skip
            MaxDriveGauge = 0x2A20E4A - 0x56454E
            HBBGM = 0x2A66B3C - 0x56454E
            ARDEvent = 0x29C2CDE - 0x56454E
            canExecute = true
        elseif ReadString(0x09A92F0,4) == 'KH2J' then --EGS 1.0.0.9
            GameVersion = 2
            print('Epic Version 1.0.0.9_WW Detected - CutsceneSkipper')
            Now = 0x0716DF8 --Current Location
            Save = 0x09A92F0 --Save File
            CutNow = 0x0B649D8 --Cutscene Timer
            CutLen = 0x0B649F4 --Cutscene Length
            CutSkp = 0x0B649DC --Cutscene Skip
            MaxDriveGauge = 0x2A2318A
            HBBGM = 0x2A693FC
            ARDEvent = 0x29C501E
            canExecute = true
        elseif ReadString(0x09A9830,4) == 'KH2J' then --Steam Global
            GameVersion = 3
            print('Steam Global Version Detected - CutsceneSkipper')
            Now = 0x0717008 --Current Location
            Save = 0x09A9830 --Save File
            CutNow = 0x0B64F18 --Cutscene Timer
            CutLen = 0x0B64F34 --Cutscene Length
            CutSkp = 0x0B64F1C --Cutscene Skip
            MaxDriveGauge = 0x2A236CA
            HBBGM = 0x2A6993C
            ARDEvent = 0x29C571E
            canExecute = true
        elseif ReadString(0x09A8830,4) == 'KH2J' then --Steam JP (Needs Testing)
            GameVersion = 4
            print('Steam JP Version Detected - CutsceneSkipper')
            Now = 0x0716008 --Current Location
            Save = 0x09A8830 --Save File
            CutNow = 0x0B63F18 --Cutscene Timer
            CutLen = 0x0B63F34 --Cutscene Length
            CutSkp = 0x0B63F1C --Cutscene Skip
            MaxDriveGauge = 0x2A226CA
            HBBGM = 0x2A6893C
            ARDEvent = 0x29C471E
            canExecute = true
        end
    end
end

function BitOr(Address,Bit,Abs)
WriteByte(Address,ReadByte(Address)|Bit,Abs and OnPC)
end
    
function BitNot(Address,Bit,Abs)
WriteByte(Address,ReadByte(Address)&~Bit,Abs and OnPC)
end

function _OnFrame()
    if GameVersion == 0 then --Get anchor addresses
		GetVersion()
		return
	end
	if ReadShort(Now+0x00) == 0x1A04 and ReadShort(CutLen) == 0x021C then
		WriteByte(CutSkp, 0x01) --GoA Intro Cutscene
        WriteByte(Save+0x1D2D, 0x00) --Resets HB BGM Back to Normal in Case
	end
    if ReadShort(Now+0x00) == 0x1A04 and ReadShort(CutLen) == 0x01E3 then --GoA Computer Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1A04 and ReadShort(ARDEvent+0x2C458) == 0xFFFF then
        WriteShort(ARDEvent+0x2C458, 0x0001)
        WriteShort(ARDEvent+0x2C478, 0x0001)
    end
    if ReadShort(Now+0x00) == 0x0112 and ReadShort(CutLen) == 0x0591 then --The World That Never Was
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0312 and ReadShort(CutLen) == 0x0514 then --Pre-Roxas Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1B26, 0x02)
	end
    if ReadShort(Now+0x00) == 0x1512 and ReadByte(Now+0x08) == 0x01 then --Post Roxas Cutscene 1
        WriteByte(Now+0x01, 0x03)
        WriteInt(Now+0x04, 0x00010000)
        WriteByte(Now+0x08, 0x02)
        WriteByte(Save+0x0D, 0x03)
    end
    if ReadShort(Now+0x00) == 0x0312 and ReadByte(Now+0x08) == 0x02 then --Post Roxas Cutscene 2
        if ReadByte(ARDEvent+0x13BB2) == 0x92 then --Normal
            WriteInt(ARDEvent+0x13BB2, 0x00420042)
        end
        if ReadByte(ARDEvent+0x13BB2) ~= 0x92 and ReadByte(ARDEvent+0x13BF2) == 0x92 then --Boss/Enemy
            WriteInt(ARDEvent+0x13BF2, 0x00420042)
        end
        if ReadShort(CutLen) == 0x0857 then
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
            WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
            WriteShort(Save+0x24FC, 0x0000)
            if ReadShort(Save+0x3524) > 0x0000 then
                WriteShort(Save+0x3524, 0x0000)
                WriteByte(Save+0x3528, 0x64)
                WriteByte(Save+0x3529,ReadByte(Save+0x352A))
            end
        end
	end
    if ReadShort(Now+0x00) == 0x0412 and ReadShort(CutLen) == 0x020C then --Pre-Enter Castle Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1B16, 0x00)
        WriteByte(Save+0x1B1A, 0x00)
        WriteByte(Save+0x1B28, 0x04)
        WriteByte(Save+0x1B2C, 0x16)
        WriteByte(Save+0x1B32, 0x00)
        WriteInt(Save+0x1B36, 0x00010001)
        BitOr(Save+0x1ED1, 0x18)
        WriteByte(Save+0x1EDF, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0512 and ReadByte(Now+0x08) == 0x00 then --Pre-Enter Castle Cutscene 2
        WriteShort(Now+0x01, 0x3204)
        WriteByte(Now+0x04, 0x04)
        WriteByte(Now+0x08, 0x16)
        WriteShort(Save+0x0D, 0x3204)
    end
    if ReadShort(Now+0x00) == 0x0612 and ReadShort(CutLen) == 0x030A then --Enter Castle Cutscene 1
        WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1B28, 0x00)
        WriteByte(Save+0x1B2C, 0x15)
        WriteByte(Save+0x1B46, 0x01)
        WriteByte(Save+0x1B4A, 0x16)
        WriteByte(Save+0x1B50, 0x01)
        WriteByte(Save+0x1B74, 0x00)
        BitOr(Save+0x1ED1, 0x40)
        WriteByte(Save+0x1EDF, 0x02)
	end
    if ReadShort(Now+0x00) == 0x1012 and ReadByte(Now+0x21) == 0x06 then --Enter Castle Cutscene 2
        WriteShort(Now+0x01, 0x3206)
        WriteByte(Now+0x06, 0x01)
        WriteShort(Save+0x0D, 0x3206)
    end
    if ReadShort(Now+0x00) == 0x0A12 and ReadShort(CutLen) == 0x12C2 then --Pre-Xigbar Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1B5C, 0x00)
        BitOr(Save+0x1ED2, 0x03)
	end
    if ReadShort(Now+0x00) == 0x0C12 and ReadByte(Now+0x31) == 0x0A then --Pre-Xigbar Cutscene 2
        if ReadByte(Now+0x38) == 0x01 then
            WriteByte(Now+0x01, 0x0A)
            WriteInt(Now+0x04, 0x00390039)
            WriteByte(Now+0x08, 0x39)
            WriteByte(Save+0x0D, 0x0A)
        end
    end
    if ReadShort(Now+0x00) == 0x0A12 and ReadShort(CutLen) == 0x0755 then --Post Xigbar Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadByte(Save+0x1B5C) == 0x002 then --Pre-Reunion Cutscene
		WriteByte(Save+0x1B56, 0x01)
        WriteByte(Save+0x1B5C, 0x00)
        WriteByte(Save+0x1B80, 0x00)
	end
    if ReadShort(Now+0x00) == 0x0B12 and ReadShort(CutLen) == 0x1C8B then --Reunion Cutscene
		WriteByte(CutSkp, 0x01)
        BitOr(Save+0x1ED2, 0x08)
	end
    if ReadShort(Now+0x00) == 0x1012 and ReadShort(CutLen) == 0x04B2 then --Before Proof of Existence Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0E12 then --Luxord Cutscenes
        if ReadShort(CutLen) == 0x03FD or ReadShort(CutLen) == 0x0492 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0D12 and ReadShort(CutLen) == 0x008C then --The Open Path & The New Path
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0F12 and ReadShort(CutLen) == 0x0691 then --Pre-Saix Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0F12 and ReadShort(CutLen) == 0x0495 then --Post Saix Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
        WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
        WriteByte(Save+0x2608,ReadByte(Save+0x2609))
        WriteByte(Save+0x260A,ReadByte(Save+0x260B))
        WriteByte(Save+0x271C,ReadByte(Save+0x271D))
        WriteByte(Save+0x271E,ReadByte(Save+0x271F))
	end
    if ReadShort(Now+0x00) == 0x0F12 and ReadByte(Now+0x08) == 0x60 then --Post Saix Cutscene
        WriteInt(Now+0x04, 0x007A007A)
        WriteByte(Now+0x08, 0x7A)
    end
    if ReadByte(Save+0x1B5E) == 0x04 and ReadByte(Save+0x1B62) == 0x14 then --Path to Xemnas
        if ReadByte(Save+0x35C1) >= 0x02 then
            WriteByte(Save+0x1B5E, 0x00)
        end
    end
    if ReadByte(Save+0x1B74) == 0x03 then --Pre-Riku Joins Party Cutscene
        WriteByte(Save+0x1B70, 0x02)
        WriteByte(Save+0x1B74, 0x05)
	end
    if ReadShort(Now+0x00) == 0x1012 and ReadShort(CutLen) == 0x1114 then --Riku Joins Party Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1B16, 0x02)
        WriteInt(Save+0x1B1C, 0x00020002)
        WriteInt(Save+0x1B22, 0x00020002)
        WriteByte(Save+0x1B28, 0x02)
        WriteByte(Save+0x1B34, 0x02)
        WriteByte(Save+0x1B4C, 0x02)
        WriteByte(Save+0x1B52, 0x02)
        WriteByte(Save+0x1B58, 0x02)
        WriteByte(Save+0x1B64, 0x02)
        WriteByte(Save+0x1B6A, 0x02)
        WriteByte(Save+0x1B7C, 0x02)
        BitOr(Save+0x1ED3, 0x30)
	end
    if ReadShort(Now+0x00) == 0x1112 and ReadShort(CutLen) == 0x0C9F then --Pete & Maleficent Helps Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1212 and ReadShort(ARDEvent+0x1EFCC) == 0xFFFF then --Normal & Boss/Enemy
        WriteByte(ARDEvent+0x1F8EE, 0x02)
        WriteInt(ARDEvent+0x1F8F6, 0x0001003B)
        WriteByte(ARDEvent+0x1F938, 0x02)
        WriteByte(ARDEvent+0x1F9EE, 0x4B)
        WriteShort(ARDEvent+0x1EFCC, 0x01)
    end
    if ReadShort(Now+0x00) == 0x1212 and ReadShort(ARDEvent+0x1EF0C) == 0xFFFF then --Boss/Enemy
        WriteShort(ARDEvent+0x1EF0C, 0x01)
    end
    if ReadShort(Now+0x00) == 0x1212 and ReadShort(CutLen) == 0x0FDD then --Pre-Xemnas Cutscene
		WriteByte(CutSkp, 0x01)
        BitOr(Save+0x1ED4, 0x08)
	end
    if ReadShort(Now+0x00) == 0x1312 and ReadShort(CutLen) == 0x02C6 then --Post Xemnas Cutscene 1
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1212 and ReadShort(CutLen) == 0x1168 then --Post Xemnas Cutscene 2
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1212 and ReadShort(CutLen) == 0x0364 then --Pre-Final Battles Cutscene
		WriteByte(CutSkp, 0x01)
        BitOr(Save+0x1ED4, 0x80)
	end
    if ReadShort(Now+0x00) == 0x1B12 and ReadShort(CutLen) == 0x04B7 then --Pre-Final Battles Cutscene (Promise Charm)
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1B12 and ReadByte(Now+0x08) == 0x5E then --Start of Final Battles
        WriteInt(Now+0x04, 0x004B004B)
        WriteByte(Now+0x08, 0x4B)
    end
    if ReadShort(Now+0x00) == 0x1812 and ReadByte(Now+0x08) == 0x57 then --Armor Xemnas I
        WriteInt(Now+0x04, 0x00470047)
        WriteByte(Now+0x08, 0x47)
    end
    if ReadShort(Now+0x00) == 0x1712 and ReadByte(Now+0x08) == 0x49 then --Armor Xemnas II Auto-Revert/Refill
        if ReadShort(Now+0x30) == 0x1812 and ReadByte(Now+0x38) == 0x47 then
            WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
            WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
            WriteShort(Save+0x24FC, 0x0000)
            if ReadShort(Save+0x3524) > 0x0000 then
                WriteShort(Save+0x3524, 0x0000)
                WriteByte(Save+0x3528, 0x64)
                WriteByte(Save+0x3529,ReadByte(Save+0x352A))
            end
            WriteByte(Save+0x31E4,ReadByte(Save+0x31E5))
            WriteByte(Save+0x31E6,ReadByte(Save+0x31E7))
            WriteInt(Save+0x2524,ReadInt(Save+0x2534)) --Auto-Reload Item Slots 1 & 2
            WriteInt(Save+0x2528,ReadInt(Save+0x2538)) --Auto-Reload Item Slots 3 & 4
            WriteInt(Save+0x252C,ReadInt(Save+0x253C)) --Auto-Reload Item Slots 5 & 6
            WriteInt(Save+0x2530,ReadInt(Save+0x2540)) --Auto-Reload Item Slots 7 & 8
        end
    end
    if ReadShort(Now+0x00) == 0x1D12 and ReadByte(Now+0x08) == 0x5D then --Armor Xemnas II
        WriteByte(Now+0x01, 0x17)
        WriteInt(Now+0x04, 0x00490049)
        WriteByte(Now+0x08, 0x49)
        WriteByte(Save+0x0D, 0x17)
    end
    if ReadShort(Now+0x00) == 0x1412 and ReadByte(Now+0x08) == 0x4A then --Final Xemnas Auto-Refill
        if ReadShort(Now+0x30) == 0x1712 and ReadByte(Now+0x38) == 0x49 then
            WriteInt(Save+0x2524,ReadInt(Save+0x2534)) --Auto-Reload Item Slots 1 & 2
            WriteInt(Save+0x2528,ReadInt(Save+0x2538)) --Auto-Reload Item Slots 3 & 4
            WriteInt(Save+0x252C,ReadInt(Save+0x253C)) --Auto-Reload Item Slots 5 & 6
            WriteInt(Save+0x2530,ReadInt(Save+0x2540)) --Auto-Reload Item Slots 7 & 8
        end
    end
    if ReadShort(Now+0x00) == 0x1412 and ReadByte(Now+0x08) == 0x55 then --Final Xemnas
        WriteInt(Now+0x04, 0x004A004A)
        WriteByte(Now+0x08, 0x4A)
    end
    --[[if ReadShort(Now+0x00) == 0x1412 and ReadShort(CutLen) == 0x0C11 then --Post Final Xemnas Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0001 then --Ending
        if ReadByte(Now+0x08) == 0x33 then
            WriteInt(Now+0x04, 0x003A003A)
            WriteByte(Now+0x08, 0x3A)
        end
        if ReadShort(CutLen) == 0x7814 or ReadShort(CutLen) == 0x0A8C then --Ending FMVs
            WriteByte(CutSkp, 0x01)
        end
    end]]
    if ReadShort(Now+0x00) == 0x2102 then --Station of Calling Paths
        if ReadShort(ARDEvent+0x29874) == 0xFFFF then --Normal
            WriteShort(ARDEvent+0x29874, 0x01) --TWTNW Path
            WriteShort(ARDEvent+0x29896, 0x61)
            WriteShort(ARDEvent+0x29898, 0x01)
            WriteShort(ARDEvent+0x298D8, 0x01) --LoD Path
            WriteShort(ARDEvent+0x298F6, 0x64)
            WriteShort(ARDEvent+0x298F8, 0x01)
            WriteShort(ARDEvent+0x29938, 0x01) --BC Path
            WriteShort(ARDEvent+0x29956, 0x61)
            WriteShort(ARDEvent+0x29958, 0x01)
            WriteShort(ARDEvent+0x29998, 0x01) --PL Path
            WriteShort(ARDEvent+0x299B6, 0x66)
            WriteShort(ARDEvent+0x299B8, 0x01)
            WriteShort(ARDEvent+0x299F8, 0x01) --TT Path
            WriteShort(ARDEvent+0x29A1A, 0xD5)
            WriteShort(ARDEvent+0x29A1C, 0x01)
            WriteShort(ARDEvent+0x29A5C, 0x01) --HB Path
            WriteShort(ARDEvent+0x29A7A, 0x72)
            WriteShort(ARDEvent+0x29A7C, 0x01)
            WriteShort(ARDEvent+0x29ABC, 0x01) --PR Path
            WriteShort(ARDEvent+0x29ADA, 0x65)
            WriteShort(ARDEvent+0x29ADC, 0x01)
            WriteShort(ARDEvent+0x29B24, 0x01) --STT Path
            WriteShort(ARDEvent+0x29B42, 0x63)
            WriteShort(ARDEvent+0x29B44, 0x01)
            WriteShort(ARDEvent+0x29B84, 0x01) --PC Path
            WriteShort(ARDEvent+0x29BA4, 0x01)
        end
        if ReadShort(ARDEvent+0x29884) == 0xFFFF then --Boss/Enemy
            WriteShort(ARDEvent+0x29884, 0x01) --TWTNW Path
            WriteShort(ARDEvent+0x298A6, 0x61)
            WriteShort(ARDEvent+0x298A8, 0x01)
            WriteShort(ARDEvent+0x298E8, 0x01) --LoD Path
            WriteShort(ARDEvent+0x29906, 0x64)
            WriteShort(ARDEvent+0x29908, 0x01)
            WriteShort(ARDEvent+0x29948, 0x01) --BC Path
            WriteShort(ARDEvent+0x29966, 0x61)
            WriteShort(ARDEvent+0x29968, 0x01)
            WriteShort(ARDEvent+0x299A8, 0x01) --PL Path
            WriteShort(ARDEvent+0x299C6, 0x66)
            WriteShort(ARDEvent+0x299C8, 0x01)
            WriteShort(ARDEvent+0x29A08, 0x01) --TT Path
            WriteShort(ARDEvent+0x29A2A, 0xD5)
            WriteShort(ARDEvent+0x29A2C, 0x01)
            WriteShort(ARDEvent+0x29A6C, 0x01) --HB Path
            WriteShort(ARDEvent+0x29A8A, 0x72)
            WriteShort(ARDEvent+0x29A8C, 0x01)
            WriteShort(ARDEvent+0x29ACC, 0x01) --PR Path
            WriteShort(ARDEvent+0x29AEA, 0x65)
            WriteShort(ARDEvent+0x29AEC, 0x01)
            WriteShort(ARDEvent+0x29B34, 0x01) --STT Path
            WriteShort(ARDEvent+0x29B52, 0x63)
            WriteShort(ARDEvent+0x29B54, 0x01)
            WriteShort(ARDEvent+0x29B94, 0x01) --PC Path
            WriteShort(ARDEvent+0x29BB4, 0x01)
        end
    end
    if ReadShort(Now+0x00) == 0x1312 and ReadShort(CutLen) == 0x00DC then --Post Data Xemnas Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x1412 and ReadByte(Now+0x08) == 0x69 then --Data Final Xemnas
        WriteInt(Now+0x04, 0x00620062)
        WriteByte(Now+0x08, 0x62)
    end
    if ReadShort(Now+0x00) == 0x1412 and ReadShort(CutLen) == 0x00DC then --Post Data Final Xemnas Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0008 and ReadByte(Now+0x08) == 0x01 then --The Land of Dragons 1 1st Cutscene
        WriteByte(Now+0x04, 0x00)
        WriteByte(Now+0x08, 0x02)
        WriteShort(Save+0x3555, 0x0201)
        WriteByte(Save+0xC10, 0x00)
        WriteByte(Save+0xC14, 0x02)
        WriteByte(Save+0xC1A, 0x01)
        BitOr(Save+0x1D91, 0x02)
        BitOr(Save+0x1D94, 0x10)
    end
    if ReadShort(Now+0x00) == 0x0008 and ReadShort(CutLen) == 0x103A then --The Land of Dragons 1 2nd Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0108 then --Encampment Cutscenes
        if ReadShort(CutLen) == 0x0D58 then --Pre-Encampment Heartless Cutscene
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x062C or ReadShort(CutLen) == 0x0087 or ReadShort(CutLen) == 0x02B1 then
            if ReadShort(CutNow) == 0x0001 then --Post Encampment Heartless & Missions Cutscenes
                WriteByte(CutSkp, 0x01)
            end
        end
	end
    if ReadShort(Now+0x00) == 0x0308 then
        if ReadShort(CutLen) == 0x0276 or ReadShort(CutLen) == 0x05ED then --Mountain Trail Cutscenes
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0408 and ReadShort(CutLen) == 0x058E then --Post Mountain Trail Cutscene 2
        if ReadShort(CutNow) == 0x0001 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0508 then  --Village Cave Cutscenes
        if ReadShort(CutLen) == 0x0605 or ReadShort(CutLen) == 0x02A2 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0C08 then --Village (Destroyed) Cutscenes
        if ReadShort(CutLen) == 0x0A22 or ReadShort(CutLen) == 0x047A then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0708 then --Summit Cutscenes
        if ReadShort(CutLen) == 0x04D5 or ReadShort(CutLen) == 0x0A00 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x1D5F then --Post Summit Heartless 1 Cutscene
            if ReadShort(CutNow) == 0x0001 then
                WriteByte(CutSkp, 0x01)
            end
        end
        if ReadShort(CutLen) == 0x0A62 then --Post Riku Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xC14, 0x15)
            WriteInt(Save+0xC36, 0x0000000B)
            WriteInt(Save+0xC42, 0x000A0000)
            WriteByte(Save+0xC5C, 0x13)
            BitOr(Save+0x1D93, 0x02)
            BitOr(Save+0x1D98, 0x04)
            WriteByte(Save+0x1D9F, 0x06)
        end
        if ReadByte(ARDEvent+0x3466) == 0x06 then --Normal
            WriteShort(ARDEvent+0x0000, 0x01)
            WriteByte(ARDEvent+0x3466, 0x0C)
            WriteByte(ARDEvent+0x3468, 0x02)
        end
        if ReadByte(ARDEvent+0x34E6) == 0x06 then --Boss/Enemy
            WriteShort(ARDEvent+0x0000, 0x01)
            WriteByte(ARDEvent+0x34E6, 0x0C)
            WriteByte(ARDEvent+0x34E8, 0x02)
        end
	end
    if ReadShort(Now+0x00) == 0x0608 then  --Ridge Cutscenes
        if ReadShort(CutLen) == 0x0701 or ReadShort(CutLen) == 0x01F7 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0208 and ReadShort(CutLen) == 0x00A0 then --Before Imperial Square Heartless 1 Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0808 then --Imperial Square Cutscenes
        if ReadShort(CutLen) == 0x08AC or ReadShort(CutLen) == 0x00C1 or ReadShort(CutLen) == 0x02E3 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x0B then --Imperial Square Heartless 2
            WriteInt(Now+0x04, 0x00510051)
            WriteByte(Now+0x08, 0x51)
        end
        if ReadShort(CutLen) == 0x00CD then --Post Imperial Square Heartless 2 Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xC44, 0x00)
            BitOr(Save+0x1D98, 0x10)
        end
        if ReadByte(Now+0x08) == 0x0D then --Storm Rider
            WriteInt(Now+0x04, 0x004F004F)
            WriteByte(Now+0x08, 0x4F)
        end
        if ReadShort(CutLen) == 0x0533 then --Post Storm Rider Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xC14, 0x00)
            WriteByte(Save+0xC1C, 0x00)
            WriteByte(Save+0xC22, 0x00)
            WriteInt(Save+0xC2C, 0x00000014)
            WriteByte(Save+0xC34, 0x02)
            WriteByte(Save+0xC3A, 0x0D)
            WriteInt(Save+0xC42, 0x0000000A)
            WriteByte(Save+0xC48, 0x01)
            WriteByte(Save+0xC4E, 0x0A)
            WriteByte(Save+0xC56, 0x15)
            WriteByte(Save+0xC5C, 0x14)
            BitOr(Save+0x1D91, 0x80)
            BitOr(Save+0x1D94, 0x08)
            BitOr(Save+0x1D99, 0x04)
            WriteByte(Save+0x1D9E, 0x02)
            BitOr(Save+0x1E71, 0x10)
            WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
            WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
            WriteShort(Save+0x24FC, 0x0000)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
            WriteByte(Save+0x2608,ReadByte(Save+0x2609))
            WriteByte(Save+0x260A,ReadByte(Save+0x260B))
            WriteByte(Save+0x271C,ReadByte(Save+0x271D))
            WriteByte(Save+0x271E,ReadByte(Save+0x271F))
        end
	end
    if ReadShort(Now+0x00) == 0x0908 then --Palace Gate Cutscenes
        if ReadShort(CutLen) == 0x0542 or ReadShort(CutLen) == 0x1C42 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0601 then --Before Antechamber Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xC50, 0x0B)
            BitOr(Save+0x1D98, 0x40)
            WriteShort(Save+0x1F88, 0x0000)
        end
	end
    if ReadShort(Now+0x00) == 0x0A08 then --Antechamber
        if ReadByte(Now+0x02) == 0x01 then --Before Antechamber Nobodies
            if ReadByte(Now+0x08) == 0x0B and ReadShort(Now+0x30) == 0x0908 then
                WriteByte(Now+0x02, 0x32)
                WriteByte(Save+0x0E, 0x32)
            end
        end
        if ReadShort(CutLen) == 0x0455 or ReadShort(CutLen) == 0x0161 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0197 then --Post Antechamber Nobodies Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xC1C, 0x01)
            WriteByte(Save+0xC50, 0x0D)
            WriteByte(Save+0xC56, 0x16)
            BitOr(Save+0x1D99, 0x02)
            WriteByte(Save+0x1D9F, 0x07)
        end
    end
    if ReadShort(Now+0x00) == 0x0B08 and ReadInt(Now+0x36) == 0x004E004E then --Post Antechamber Nobodies Cutscene 2
        WriteByte(Now+0x02, 0x32)
        WriteByte(Save+0x0E, 0x32)
    end
    if ReadShort(Now+0x00) == 0x0B08 and ReadInt(Now+0x36) == 0x004F004F then --Post Storm Rider Cutscene 2
        WriteInt(Now+0x00, 0x00161A04)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x02)
        WriteInt(Save+0x0C, 0x00161A04)
    end
    if ReadShort(Now+0x00) == 0x0A12 and ReadShort(CutLen) == 0x00DC then --Post Data Xigbar Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0005 then --Entrance Hall Cutscenes
        if ReadByte(Now+0x08) == 0x01 then --Beast's Castle 1 1st Cutscene
            WriteByte(Now+0x01, 0x01)
            WriteInt(Now+0x04, 0x00440044)
            WriteByte(Now+0x08, 0x44)
            WriteByte(Save+0x0D, 0x01)
            WriteInt(Save+0x794, 0x00010000)
            BitOr(Save+0x1D30, 0x06)
            BitOr(Save+0x1D31, 0x20)
            WriteByte(Save+0x1D3F, 0x01)
        end
        if ReadShort(CutLen) == 0x02A6 or ReadShort(CutLen) == 0x015C or ReadShort(CutLen) == 0x064C or ReadShort(CutLen) == 0x048D or ReadShort(CutLen) == 0x01E0 then
            WriteByte(CutSkp, 0x01)
        end
    end
    if ReadShort(Now+0x00) == 0x0105 and ReadShort(CutLen) == 0x093E then --Post Parlor Shadows Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0205 then --Belle's Room Cutscenes
        if ReadShort(CutLen) == 0x09E4 or ReadShort(CutLen) == 0x01F1 or ReadShort(CutLen) == 0x02AC then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x0A then --Beast's Castle 2 1st Cutscene
            WriteShort(Now+0x01, 0x3300)
            WriteByte(Now+0x08, 0x0B)
            WriteShort(Save+0x0D, 0x3300)
            WriteByte(Save+0x794, 0x0B)
            WriteByte(Save+0x79A, 0x10)
            WriteInt(Save+0x7B4, 0x000A0001)
            WriteByte(Save+0x7BC, 0x0A)
            WriteByte(Save+0x7C2, 0x0A)
            WriteByte(Save+0x7C8, 0x0A)
            WriteByte(Save+0x7D4, 0x0A)
            WriteByte(Save+0x7DA, 0x0A)
            BitOr(Save+0x1D32, 0x02)
            BitOr(Save+0x1D33, 0x02)
            BitOr(Save+0x1D38, 0x08)
            WriteByte(Save+0x1D3F, 0x09)
            WriteInt(Save+0x1FCC, 0x85448543)
            WriteInt(Save+0x20BC, 0x85428541)
            WriteInt(Save+0x20C0, 0x853C853B)
            WriteInt(Save+0x20C4, 0x853E853D)
            WriteInt(Save+0x20C8, 0x8540853F)
        end
	end
    if ReadShort(Now+0x00) == 0x0805 then --The West Hall Cutscenes
        if ReadShort(CutLen) == 0x0267 or ReadShort(CutLen) == 0x025A or ReadShort(CutLen) == 0x0498 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0B05 then --Undercroft Cutscenes
        if ReadShort(CutLen) == 0x0492 or ReadShort(CutLen) == 0x0348 or ReadShort(CutLen) == 0x0290 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0A05 and ReadShort(CutLen) == 0x0E7D then --Dungeon Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0C05 then --Secret Passage Cutscenes
        if ReadShort(CutLen) == 0x064C or ReadShort(CutLen) == 0x05A5 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0305 then --Beast's Room Cutscenes
        if ReadShort(CutLen) == 0x08DA or ReadShort(CutLen) == 0x0DBA or ReadShort(CutLen) == 0x07EE then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0F0F then --Before Rumbling Rose Cutscene
            WriteByte(CutSkp, 0x01)
            WriteInt(Save+0x79A, 0x00010012)
            WriteByte(Save+0x7A0, 0x10)
            WriteByte(Save+0x7A6, 0x0B)
            WriteInt(Save+0x7C8, 0x00160000)
            BitOr(Save+0x1D38, 0x80)
        end
	end
    if ReadShort(Now+0x00) == 0x0405 then --Ballroom Cutscenes
        if ReadShort(CutLen) == 0x0494 or ReadShort(CutLen) == 0x0A82 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x038E then --Post Ballroom Nobodies Cutscene
            if ReadShort(CutNow) >= 0x0002 then
                WriteByte(CutSkp, 0x01)
            end
        end
        if ReadShort(ARDEvent+0x21EF0) == 0xFFFF then --Normal & Boss/Enemy
            WriteShort(ARDEvent+0x21EF0, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0505 then --Ballroom (Dark) Cutscenes
        if ReadShort(CutLen) == 0x02DA or ReadShort(CutLen) == 0x0258 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0E05 and ReadShort(CutLen) == 0x187C then --Post Dark Thorn Cutscene 2
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0605 and ReadShort(CutLen) == 0x05ED then --Pre-Xaldin Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0D05 and ReadByte(Now+0x08) == 0x0A then --Xaldin
        WriteByte(Now+0x01, 0x0F)
        WriteInt(Now+0x04, 0x00520052)
        WriteByte(Now+0x08, 0x52)
        WriteByte(Save+0x0D, 0x0F)
    end
    if ReadShort(Now+0x00) == 0x0F05 and ReadShort(CutLen) == 0x0277 then --Post Xaldin Cutscene
        if ReadShort(CutNow) == 0x0001 then
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x79A, 0x11)
            WriteInt(Save+0x7A0, 0x0000000E)
            WriteByte(Save+0x7A8, 0x0D)
            WriteInt(Save+0x7B4, 0x000A0000)
            WriteByte(Save+0x7B8, 0x00)
            WriteInt(Save+0x7E0, 0x0000000A)
            BitOr(Save+0x1D32, 0x04)
            BitOr(Save+0x1D34, 0x60)
            BitOr(Save+0x1D35, 0x01)
            WriteByte(Save+0x1D3E, 0x01)
            WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
            WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
            WriteShort(Save+0x24FC, 0x0000)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
            WriteByte(Save+0x2608,ReadByte(Save+0x2609))
            WriteByte(Save+0x260A,ReadByte(Save+0x260B))
            WriteByte(Save+0x271C,ReadByte(Save+0x271D))
            WriteByte(Save+0x271E,ReadByte(Save+0x271F))
        end
	end
    if ReadShort(Now+0x00) == 0x0605 and ReadInt(Now+0x36) == 0x00520052 then --Post Xaldin
        WriteInt(Now+0x00, 0x00171A04)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x02)
        WriteInt(Save+0x0C, 0x00171A04)
    end
    if ReadShort(Now+0x00) == 0x0F05 and ReadShort(CutLen) == 0x00DC then --Post Data Xaldin Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x040E and ReadByte(Now+0x08) == 0x01 then --Halloween Town 1 1st Cutscene
        WriteShort(Now+0x01, 0x3202)
        WriteInt(Now+0x04, 0x00000005)
        WriteByte(Now+0x08, 0x15)
        WriteShort(Save+0x0D, 0x3202)
        WriteShort(Save+0x356D, 0x0201)
        WriteByte(Save+0x1514, 0x01)
        WriteByte(Save+0x151C, 0x05)
        WriteByte(Save+0x1520, 0x15)
        WriteInt(Save+0x152C, 0x00)
        WriteByte(Save+0x1530, 0x14)
        BitOr(Save+0x1E50, 0x04)
        BitOr(Save+0x1E53, 0x10)
        BitOr(Save+0x1E57, 0x02)
        WriteInt(Save+0x2014, 0x858B858A)
    end
    if ReadShort(Now+0x00) == 0x000E then --Halloween Town Square Cutscenes
        if ReadByte(Now+0x08) == 0x01 then --Jack Reunion Cutscene
            WriteByte(Now+0x01, 0x01)
            WriteByte(Now+0x04, 0x00)
            WriteByte(Now+0x08, 0x01)
            WriteByte(Save+0x0D, 0x01)
            WriteByte(Save+0x1510, 0x00)
            WriteByte(Save+0x1514, 0x00)
            WriteInt(Save+0x151A, 0x00010001)
            WriteByte(Save+0x1520, 0x00)
            BitOr(Save+0x1E50, 0x08)
            WriteInt(Save+0x2018, 0x85898588)
        end
        if ReadShort(CutLen) == 0x033D or ReadShort(CutLen) == 0x02F4 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0172 then --Post Halloween Town Square Heartless Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x1514, 0x04)
            WriteByte(Save+0x151A, 0x12)
            WriteInt(Save+0x151E, 0x00000001)
            WriteByte(Save+0x1528, 0x01)
            WriteByte(Save+0x152C, 0x02)
            BitOr(Save+0x1E50, 0xE0)
            BitOr(Save+0x1E51, 0x01)
        end
        if ReadShort(CutLen) == 0x0465 then --Post Present Collection Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x1512, 0x0B)
            WriteByte(Save+0x151A, 0x14)
            WriteByte(Save+0x151E, 0x0B)
            WriteByte(Save+0x152A, 0x0B)
            WriteByte(Save+0x152E, 0x00)
            WriteByte(Save+0x1532, 0x15)
            WriteByte(Save+0x1536, 0x0B)
            WriteByte(Save+0x1544, 0x0F)
            WriteByte(Save+0x154A, 0x13)
            WriteByte(Save+0x1550, 0x16)
            BitOr(Save+0x1E55, 0x0C)
            WriteByte(Save+0x1E5F, 0x0B)
        end
        if ReadByte(Now+0x38) == 0x40 then --Post Experiment Cutscene 2
            WriteInt(Now+0x00, 0x00181A04)
            WriteInt(Now+0x04, 0x00000000)
            WriteByte(Now+0x08, 0x02)
            WriteInt(Save+0x0C, 0x00181A04)
        end
    end
    if ReadShort(Now+0x00) == 0x010E and ReadShort(CutLen) == 0x128B then --After Jack Reunion Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x020E and ReadByte(Now+0x38) == 0x33 then --Post HT Square Heartless Cutscene 2
        WriteShort(Now+0x01, 0x3300)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x04)
        WriteShort(Save+0x0D, 0x3300)
    end
    if ReadShort(Now+0x00) == 0x040E and ReadShort(CutLen) == 0x05BC then --Enter Christmas Town Cutscene
		WriteByte(CutSkp, 0x01)
        WriteInt(Save+0x1528, 0x00010000)
        WriteByte(Save+0x152E, 0x03)
        WriteInt(Save+0x1532, 0x00010011)
        WriteByte(Save+0x1538, 0x01)
        BitOr(Save+0x1E51, 0x04)
        WriteByte(Save+0x1E5F, 0x02)
	end
    if ReadShort(Now+0x00) == 0x060E then --Candy Cane Lane Cutscenes
        if ReadShort(CutLen) == 0x0253 or ReadShort(CutLen) == 0x025D or ReadShort(CutLen) == 0x209B then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x38) == 0x16 then --Toy Factory Cutscene 2
            if ReadShort(Now+0x20) == 0x090E then
                WriteByte(Now+0x02, 0x33)
                WriteByte(Save+0x0E, 0x33)
            end
        end
        if ReadByte(Now+0x08) == 0x0A then --Experiment
            WriteByte(Now+0x01, 0x07)
            WriteInt(Now+0x04, 0x00400040)
            WriteByte(Now+0x08, 0x40)
            WriteByte(Save+0x0D, 0x07)
        end
	end
    if ReadShort(Now+0x00) == 0x080E and ReadShort(CutLen) == 0x0837 then --Entered Santa's House Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x090E then --Toy Factory: Shipping and Receiving Cutscenes
        if ReadShort(CutLen) == 0x0A02 then --Toy Factory Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x1514, 0x05)
            WriteInt(Save+0x151A, 0x00020011)
            WriteInt(Save+0x1528, 0x00020002)
            WriteInt(Save+0x152C, 0x00010003)
            WriteInt(Save+0x1532, 0x0002000F)
            WriteInt(Save+0x1536, 0x00000002)
            WriteByte(Save+0x1540, 0x01)
            WriteByte(Save+0x1544, 0x0D)
            BitOr(Save+0x1E51, 0x80)
            WriteByte(Save+0x1E5F, 0x04)
            WriteInt(Save+0x2020, 0x858F858E)
        end
        if ReadShort(CutLen) == 0x0A09 then --Before Oogie Boogie Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x152E, 0x02)
            WriteByte(Save+0x1532, 0x13)
            WriteByte(Save+0x1536, 0x03)
            WriteByte(Save+0x1544, 0x0E)
            WriteByte(Save+0x154A, 0x02)
            BitOr(Save+0x1E52, 0x80)
            WriteByte(Save+0x1E5F, 0x06)
            WriteShort(Save+0x2010, 0x0000)
        end
        if ReadShort(CutLen) == 0x0DD4 or ReadShort(CutLen) == 0x03B3 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x030E then -- Curly Hill Cutscenes
        if ReadShort(CutLen) == 0x07D2 or ReadShort(CutLen) == 0x0D79 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x022C then --Post Prison Keeper Cutscene
            WriteByte(CutSkp, 0x01)
            WriteInt(Save+0x151A, 0x00030002)
            WriteInt(Save+0x151E, 0x00160000)
            WriteByte(Save+0x1524, 0x01)
            WriteInt(Save+0x152A, 0x00040003)
            WriteByte(Save+0x152E, 0x03)
            WriteByte(Save+0x1532, 0x02)
            BitOr(Save+0x1E52, 0x30)
            WriteByte(Save+0x1E5F, 0x05)
            WriteInt(Save+0x2010, 0x858D858C)
        end
        if ReadByte(ARDEvent+0x26F2A) == 0x3A then --Normal
            WriteByte(ARDEvent+0x26F22, 0x01)
            WriteInt(ARDEvent+0x26F26, 0x00340002)
            WriteInt(ARDEvent+0x26F2A, 0x00010000)
        end
        if ReadByte(ARDEvent+0x26ADE) == 0x3A then --Boss/Enemy
            WriteByte(ARDEvent+0x26AD6, 0x01)
            WriteInt(ARDEvent+0x26ADA, 0x00340002)
            WriteInt(ARDEvent+0x26ADE, 0x00010000)
        end
	end
    if ReadShort(Now+0x00) == 0x050E and ReadShort(Now+0x38) == 0x04 then --Before Oogie Boogie Cutscene 2
        if ReadShort(Now+0x040E) then
            WriteByte(Now+0x02, 0x32)
            WriteByte(Save+0x0E, 0x32)
        end
    end
    if ReadShort(Now+0x00) == 0x010E and ReadByte(Now+0x08) == 0x0A then --Halloween Town 2 1st Cutscene
        WriteShort(Now+0x01, 0x0004)
        WriteByte(Now+0x04, 0x03)
        WriteByte(Now+0x08, 0x0A)
        WriteShort(Save+0x0D, 0x0004)
        WriteByte(Save+0x151A, 0x0F)
        WriteByte(Save+0x152C, 0x0A)
        BitOr(Save+0x1E51, 0x10)
        BitOr(Save+0x1E56, 0x40)
        WriteByte(Save+0x1E5F, 0x09)
    end
    if ReadShort(Now+0x00) == 0x040E and ReadShort(CutLen) == 0x07A2 then --Halloween Town 2 2nd Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1544, 0x10)
        WriteByte(Save+0x154A, 0x15)
        WriteByte(Save+0x1550, 0x0A)
        BitOr(Save+0x1E54, 0x08)
        WriteShort(Save+0x2028, 0x0000)
	end
    if ReadShort(Now+0x00) == 0x040E and ReadInt(Now+0x10) == 0x0000080E then
        WriteByte(Now+0x12, 0x36)
    end
    if ReadShort(Now+0x00) == 0x0A0E and ReadShort(CutLen) == 0x03C5 then --Pre-Lock/Shock/Barrel Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0A0E and ReadShort(CutLen) == 0x02EF then --Post Lock/Shock/Barrel Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1514, 0x0A)
        WriteByte(Save+0x152E, 0x03)
        WriteByte(Save+0x1532, 0x10)
        WriteByte(Save+0x1544, 0x13)
        WriteByte(Save+0x154A, 0x14)
        BitOr(Save+0x1E54, 0x80)
        WriteShort(Save+0x200C, 0x0000)
	end
    if ReadShort(Now+0x00) == 0x080E and ReadByte(Now+0x38) == 0x3E then --Post Lock/Shock/Barrel Cutscene 2
        WriteByte(Now+0x02, 0x34)
        WriteByte(Save+0x0E, 0x34)
    end
    if ReadShort(Now+0x00) == 0x010E and ReadByte(Now+0x38) == 0x3C then --Post Present Collection Cutscene 2
        WriteShort(Now+0x01, 0x3308)
        WriteByte(Now+0x04, 0x02)
        WriteByte(Now+0x08, 0x0F)
        WriteShort(Save+0x0D, 0x3308)
    end
    if ReadShort(Now+0x00) == 0x0A0E and ReadShort(CutLen) == 0x0149 then --Post Gift Wrapping Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1544, 0x11)
        WriteByte(Save+0x154A, 0x12)
        WriteByte(Save+0x1550, 0x15)
        BitOr(Save+0x1E55, 0x20)
	end
    if ReadShort(Now+0x00) == 0x080E and ReadByte(Now+0x38) == 0x3F then --Post Gift Wrapping Cutscene 2
        WriteByte(Now+0x02, 0x35)
        WriteByte(Save+0x0E, 0x35)
    end
    if ReadShort(Now+0x00) == 0x070E and ReadShort(CutLen) == 0x0908 then --Post Experiment Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1514, 0x00)
        WriteByte(Save+0x151A, 0x13)
        WriteInt(Save+0x1530, 0x00120001)
        WriteByte(Save+0x1534, 0x00)
        WriteByte(Save+0x1538, 0x00)
        WriteByte(Save+0x153C, 0x01)
        WriteByte(Save+0x1540, 0x03)
        WriteInt(Save+0x1544, 0x0001000C)
        WriteInt(Save+0x154A, 0x00010011)
        WriteByte(Save+0x1550, 0x14)
        BitOr(Save+0x1E55, 0xC0)
        BitOr(Save+0x1E56, 0x86)
        BitOr(Save+0x1E71, 0x40)
        WriteShort(Save+0x1E5E, 0x0C02)
        WriteShort(Save+0x3524, 0x0000)
        WriteByte(Save+0x3528, 0x64)
        WriteByte(Save+0x3529,ReadByte(Save+0x352A))
	end
    if ReadShort(Now+0x00) == 0x2004 then --Vexen Cutscenes
        if ReadByte(Now+0x08) == 0x78 then --Pre-AS Vexen Cutscene
            WriteInt(Now+0x04, 0x00730073)
            WriteByte(Now+0x08, 0x73)
        end
        if ReadShort(CutLen) == 0x0140 or ReadShort(CutLen) == 0x00DC then --Post Vexen Cutscenes
            if ReadShort(CutNow) >= 0x0002 then
                WriteByte(CutSkp, 0x01)
            end
        end
        if ReadByte(Now+0x08) == 0x82 then --Pre-Data Vexen Cutscene
            WriteInt(Now+0x04, 0x00920092)
            WriteByte(Now+0x08, 0x92)
        end
	end
    if ReadShort(Now+0x00) == 0x0007 then --Agrabah Cutscenes
        if ReadByte(Now+0x08) == 0x01 then --Pre-Agrabah Heartless Cutscene
            WriteInt(Now+0x02, 0x00390000)
            WriteInt(Now+0x06, 0x00390039)
            WriteByte(Save+0x0E, 0x00)
            WriteByte(Save+0xA94, 0x00)
            BitOr(Save+0x1D73, 0x08)
            BitOr(Save+0x1D74, 0x08)
            WriteByte(Save+0x1D7F, 0x01)
        end
        if ReadShort(CutLen) == 0x0333 or ReadShort(CutLen) == 0x0B19 or ReadShort(CutLen) == 0x03EE then
            WriteByte(CutSkp, 0x01)
        end
    end
    if ReadShort(Now+0x00) == 0x0207 and ReadShort(CutLen) == 0x02D9 then --Post Agrabah Heartless Cutscene 2
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0307 then --The Palace Cutscenes
        if ReadByte(Now+0x08) == 0x01 then --Jasmine Reunion Cutscene
            WriteByte(Now+0x01, 0x00)
            WriteByte(Now+0x08, 0x03)
            WriteByte(Save+0x0D, 0x00)
            WriteByte(Save+0xA90, 0x00)
            WriteByte(Save+0xA94, 0x03)
            WriteByte(Save+0xA9C, 0x00)
            WriteByte(Save+0xAA6, 0x00)
            BitOr(Save+0x1D74, 0x60)
            WriteInt(Save+0x1F6C, 0x85348533)
            WriteInt(Save+0x1F78, 0x827D827C)
            WriteInt(Save+0x1F84, 0x827F827E)
        end
        if ReadShort(CutLen) == 0x129A or ReadShort(CutLen) == 0x10A8 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x03A6 then --Post Lords Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xAAC, 0x00)
            BitOr(Save+0x1D72, 0x08)
        end
        if ReadShort(CutLen) == 0x0963 then --Pre-Genie Jafar Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xA94, 0x00)
            WriteByte(Save+0xAB2, 0x00)
            BitOr(Save+0x1D77, 0x04)
        end
    end
    if ReadShort(Now+0x00) == 0x0207 and ReadShort(CutLen) == 0x020A then --Peddler Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0xA94, 0x00)
        WriteByte(Save+0xA98, 0x01)
        WriteByte(Save+0xAA4, 0x01)
        WriteByte(Save+0xAB4, 0x03)
        WriteByte(Save+0xAB8, 0x15)
        WriteByte(Save+0xABE, 0x01)
        BitOr(Save+0x1D75, 0x01)
        WriteShort(Save+0x1F6C, 0x0000)
        WriteShort(Save+0x1F84, 0x0000)
	end
    if ReadInt(Now+0x00) == 0x00000007 and ReadInt(Now+0x30) == 0x00340007 then --Post Peddler Cutscene 2
        WriteByte(Now+0x02, 0x36)
        WriteByte(Save+0x0E, 0x36)
    end
    if ReadShort(Now+0x00) == 0x0707 and ReadShort(CutLen) == 0x01FE then --Pete Enters Cave of Wonders Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0907 and ReadShort(CutLen) == 0x03A9 then --Pre-Abu Escort Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0907 and ReadByte(Now+0x08) == 0x03 then --Post Abu Escort Cutscene
        WriteByte(Now+0x08, 0x16)
        WriteInt(Save+0xAC6, 0x00000000)
        WriteByte(Save+0xACA, 0x16)
        WriteByte(Save+0xADE, 0x01)
        WriteByte(Save+0xAE2, 0x01)
        BitOr(Save+0x1D78, 0x80)
        WriteByte(Save+0x1D7F, 0x03)
	end
    if ReadShort(Now+0x00) == 0x0D07 then --The Cave of Wonders: Chasm of Challenges Cutscenes
        if ReadShort(CutLen) == 0x00B5 or ReadShort(CutLen) == 0x010F then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0A07 then --The Cave of Wonders: Treasure Room Cutscenes
        if ReadShort(CutLen) == 0x09E6 or ReadShort(CutLen) == 0x00E4 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0207 and ReadByte(Now+0x08) == 0x03 then --Before Lords Cutscene
        WriteByte(Now+0x01, 0x00)
        WriteInt(Now+0x04, 0x00020000)
        WriteByte(Now+0x08, 0x00)
        WriteByte(Save+0x0D, 0x00)
        WriteByte(Save+0xA92, 0x02)
        WriteByte(Save+0xA98, 0x02)
        WriteByte(Save+0xA9C, 0x02)
        WriteByte(Save+0xAA0, 0x13)
        WriteByte(Save+0xAA6, 0x02)
        WriteByte(Save+0xAB8, 0x11)
        WriteByte(Save+0xABC, 0x02)
        WriteByte(Save+0xAD0, 0x00)
        WriteByte(Save+0xADA, 0x02)
        BitOr(Save+0x1D72, 0x02)
        BitOr(Save+0x1D75, 0x80)
        BitOr(Save+0x1D76, 0x01)
        WriteByte(Save+0x1D7F, 0x05)
	end
    if ReadShort(Now+0x00) == 0x0407 and ReadByte(Now+0x38) == 0x3B then --Post Lords Cutscene 2
        WriteByte(Now+0x01, 0x03)
        WriteInt(Now+0x06, 0x00030001)
        WriteByte(Save+0x0D, 0x03)
    end
    if ReadShort(Now+0x00) == 0x0407 and ReadByte(Now+0x08) == 0x0A then --Agrabah 2 1st Cutscene
        WriteShort(Now+0x01, 0x000F)
        WriteInt(Now+0x04, 0x00000000)
        WriteShort(Save+0x0D, 0x000F)
        WriteByte(Save+0xAAC, 0x00)
        WriteByte(Save+0xAEE, 0x0A)
        BitOr(Save+0x1D72, 0x40)
        BitOr(Save+0x1D73, 0x40)
        WriteByte(Save+0x1D7F, 0x08)
        WriteInt(Save+0x1F5C, 0x853A8539)
    end
    if ReadShort(Now+0x00) == 0x0F07 and ReadShort(CutLen) == 0x0BB1 then --Agrabah 2 2nd Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0607 and ReadShort(CutLen) == 0x0956 then --Before Sandswept Ruins Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0E07 then --Sandswept Ruins Cutscene
        if ReadShort(CutLen) == 0x03D6 or ReadShort(CutLen) == 0x00B8 or ReadShort(CutLen) == 0x01AE then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x0C then --Sandswept Ruins Heartless 1
            WriteInt(Now+0x04, 0x00560056)
            WriteByte(Now+0x08, 0x56)
            WriteByte(Save+0xAE8, 0x00)
            BitOr(Save+0x1D70, 0x08)
        end
        if ReadShort(CutLen) == 0x00CC then --Post Sandswept Ruins Heartless 1 Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
            WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
        end
        if ReadByte(Now+0x08) == 0x0E then --Post Chase Jafar Cutscene
            WriteInt(Now+0x04, 0x000C0003)
            WriteByte(Now+0x08, 0x0F)
            WriteInt(Save+0xAE4, 0x000C0003)
            WriteByte(Save+0xAE8, 0x0F)
            BitOr(Save+0x1D70, 0x80)
        end
        if ReadByte(Now+0x08) == 0x10 then --Sandswept Ruins Heartless 2
            WriteInt(Now+0x04, 0x00570057)
            WriteByte(Now+0x08, 0x57)
            WriteInt(Save+0xAE6, 0x00000000)
            BitOr(Save+0x1D71, 0x08)
        end
	end
    if ReadShort(Now+0x00) == 0x0B07 and ReadShort(CutLen) == 0x098B then --Pre-Carpet Escape Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0607 and ReadByte(Now+0x08) == 0x0B then --Post Carpet Escape Cutscene
        WriteByte(Now+0x02, 0x33)
        WriteByte(Now+0x08, 0x14)
        WriteByte(Save+0x0E, 0x33)
        WriteInt(Save+0xA92, 0x00160000)
        WriteByte(Save+0xA98, 0x00)
        WriteInt(Save+0xAA4, 0x000A0000)
        WriteByte(Save+0xAB8, 0x14)
        WriteByte(Save+0xAD6, 0x16)
        BitOr(Save+0x1D77, 0x01)
        WriteByte(Save+0x1D7F, 0x0B)
	end
    if ReadShort(Now+0x00) == 0x0507 and ReadByte(Now+0x08) == 0x00 then --Pre-Genie Jafar Cutscene 2
        WriteInt(Now+0x04, 0x003E003E)
        WriteByte(Now+0x08, 0x3E)
    end
    if ReadShort(Now+0x00) == 0x0507 and ReadShort(CutLen) == 0x094E then --Post Genie Jafar Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteInt(Save+0xA90, 0x000A0004)
        WriteByte(Save+0xA94, 0x00)
        WriteByte(Save+0xA98, 0x0A)
        WriteByte(Save+0xAA6, 0x14)
        WriteByte(Save+0xAB8, 0x12)
        WriteByte(Save+0xACE, 0x02)
        WriteInt(Save+0xAEA, 0x00010003)
        WriteByte(Save+0xAEE, 0x15)
        BitOr(Save+0x1D74, 0x01)
        BitOr(Save+0x1D77, 0x10)
        WriteByte(Save+0x1D7E, 0x02)
        BitOr(Save+0x1E71, 0x80)
        WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
        WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
        WriteShort(Save+0x24FC, 0x0000)
        WriteShort(Save+0x3524, 0x0000)
        WriteByte(Save+0x3528, 0x64)
        WriteByte(Save+0x3529,ReadByte(Save+0x352A))
	end
    if ReadInt(Now+0x00) == 0x00000007 and ReadByte(Now+0x08) == 0x00 then --Post Genie Jafar Cutscene 2
        if ReadByte(Now+0x38) == 0x3E then
            WriteInt(Now+0x00, 0x00191A04)
            WriteInt(Now+0x04, 0x00000000)
            WriteByte(Now+0x08, 0x02)
            WriteInt(Save+0x0C, 0x00191A04)
        end
    end
    if ReadShort(Now+0x00) == 0x2104 then --Lexaeus & Larxene Cutscenes
        if ReadByte(Now+0x08) == 0x7A then --Pre-AS Lexaeus Cutscene
            WriteInt(Now+0x04, 0x008E008E)
            WriteByte(Now+0x08, 0x8E)
        end
        if ReadShort(CutLen) == 0x0139 or ReadShort(CutLen) == 0x00DC or ReadShort(CutLen) == 0x0104 or ReadShort(CutLen) == 0x00DB then
            if ReadShort(CutNow) >= 0x0002 then --Post Lexaeus & Larxene Cutscenes
                WriteByte(CutSkp, 0x01)
            end
        end
        if ReadByte(Now+0x08) == 0x84 then --Pre-Data Lexaeus Cutscene
            WriteByte(Now+0x04, 0x93)
            WriteByte(Now+0x06, 0x93)
            WriteByte(Now+0x08, 0x93)
        end
        if ReadByte(Now+0x08) == 0x80 then --Pre-AS Larxene Cutscene
            WriteInt(Now+0x04, 0x008F008F)
            WriteByte(Now+0x08, 0x8F)
        end
        if ReadByte(Now+0x08) == 0x8A then --Pre-Data Larxene Cutscene
            WriteInt(Now+0x04, 0x00940094)
            WriteByte(Now+0x08, 0x94)
        end
	end
    if ReadShort(Now+0x00) == 0x0006 then --The Coliseum Cutscenes
        if ReadByte(Now+0x08) == 0x01 then --Olympus Coliseum 1 1st Cutscene
            WriteShort(Now+0x01, 0x3203)
            WriteByte(Now+0x04, 0x01)
            WriteByte(Now+0x06, 0x16)
            WriteByte(Now+0x08, 0x02)
            WriteByte(Save+0x0D, 0x3203)
            WriteByte(Save+0x910, 0x00)
            WriteByte(Save+0x926, 0x02)
            BitOr(Save+0x1D50, 0x02)
            BitOr(Save+0x1D54, 0x01)
            BitOr(Save+0x1D56, 0x08)
            WriteByte(Save+0x1D6F, 0x01)
            WriteInt(Save+0x1F04, 0x82998298)
            WriteInt(Save+0x1F08, 0x829B829A)
            WriteInt(Save+0x1F38, 0xC13EC13D)
        end
        if ReadShort(CutLen) == 0x06FF or ReadShort(CutLen) == 0x00C7 or ReadShort(CutLen) == 0x0118 or ReadShort(CutLen) == 0x0EB7 or ReadShort(CutLen) == 0x038B then
            WriteByte(CutSkp, 0x01)
        end
    end
    if ReadShort(Now+0x00) == 0x0306 then --Underworld Entrance Cutscenes
        if ReadShort(CutLen) == 0x0654 or ReadShort(CutLen) == 0x00D6 or ReadShort(CutLen) == 0x0241 or ReadShort(CutLen) == 0x01AE or ReadShort(CutLen) == 0x00DE or ReadShort(CutLen) == 0x0B18 or ReadShort(CutLen) == 0x0078 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x0A then --Before OC2, Cups Intro Cutscene
            WriteByte(Now+0x02, 0x36)
            WriteByte(Now+0x08, 0x16)
            WriteByte(Save+0x0E, 0x36)
            BitOr(Save+0x1D5C, 0x20)
        end
        if ReadByte(Now+0x08) == 0x0B then --Olympus Coliseum 2 1st Cutscene 1
            WriteByte(Now+0x02, 0x38)
            WriteByte(Now+0x04, 0x05)
            WriteByte(Now+0x08, 0x0D)
            WriteByte(Save+0x0E, 0x38)
            WriteByte(Save+0x922, 0x05)
            WriteByte(Save+0x926, 0x0D)
            WriteByte(Save+0x930, 0x0A)
            WriteByte(Save+0x93C, 0x0A)
            WriteByte(Save+0x942, 0x0A) --Unused Well of Capitivity BTL Flag for 2nd Visit?
            WriteByte(Save+0x954, 0x0A)
            WriteByte(Save+0x95A, 0x0A)
            WriteByte(Save+0x96C, 0x0A)
            WriteByte(Save+0x972, 0x0A)
            WriteByte(Save+0x978, 0x0A)
            BitOr(Save+0x1D54, 0x20)
            BitOr(Save+0x1D5C, 0x40)
        end
        if ReadByte(Now+0x08) == 0x0C then --Olympus Coliseum 2 1st Cutscene 2
            WriteByte(Now+0x02, 0x38)
            WriteByte(Now+0x04, 0x05)
            WriteByte(Now+0x08, 0x0D)
            WriteByte(Save+0x0E, 0x38)
            WriteByte(Save+0x922, 0x05)
            WriteByte(Save+0x926, 0x0D)
            WriteByte(Save+0x930, 0x0A)
            WriteByte(Save+0x93C, 0x0A)
            WriteByte(Save+0x954, 0x0A)
            WriteByte(Save+0x95A, 0x0A)
            WriteByte(Save+0x96C, 0x0A)
            WriteByte(Save+0x972, 0x0A)
            WriteByte(Save+0x978, 0x0A)
            BitOr(Save+0x1D54, 0x20)
            BitOr(Save+0x1D5C, 0x80)
        end
        if ReadByte(Now+0x08) == 0x09 then --Post "Bad Alert" Cutscene 2
            if ReadByte(Now+0x38) == 0x7D then
                WriteByte(Now+0x02, 0x33)
                WriteByte(Save+0x0E, 0x33)
            end
        end
        if ReadShort(CutLen) == 0x075F then --Guardian Soul Cutscene
            WriteByte(CutSkp, 0x01)
            WriteInt(Save+0x920, 0x00030013)
            WriteByte(Save+0x924, 0x14)
            WriteByte(Save+0x94E, 0x01)
            WriteByte(Save+0x968, 0x00)
            WriteByte(Save+0x978, 0x02)
            BitOr(Save+0x1D54, 0x40)
            BitOr(Save+0x1D57, 0x20)
            BitOr(Save+0x1D5A, 0x20)
            BitOr(Save+0x1D5E, 0x80)
            WriteShort(Save+0x1D6E, 0x0C01)
            BitOr(Save+0x1EF3, 0x80)
            BitOr(Save+0x239C,0x08) --Unlock Titan Cup
            WriteShort(Save+0x24FC, 0x0000)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        end
	end
    if ReadShort(Now+0x00) == 0x0F06 and ReadShort(CutLen) == 0x00D0 then --Demyx Running 1 Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0A06 and ReadShort(CutLen) == 0x03A2 then --Demyx Running 2 Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0606 then --Hades' Chamber Cutscenes
        if ReadShort(CutLen) == 0x044C then --Before Hades Escape Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteInt(Save+0x930, 0x00000001)
            WriteByte(Save+0x934, 0x01)
            WriteByte(Save+0x938, 0x02)
            BitOr(Save+0x1D58, 0x40)
        end
        if ReadShort(CutLen) == 0x0C6C or ReadShort(CutLen) == 0x02EE or ReadShort(CutLen) == 0x05D3 or ReadShort(CutLen) == 0x02C0 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0363 then --Pre-Hades Escape Cutscene
            WriteByte(CutSkp, 0x01)
            BitOr(Save+0x1D59, 0x04)
        end
        if ReadShort(CutLen) == 0x06F7 then --Before Hercules Reunion Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x916, 0x01)
            WriteByte(Save+0x91A, 0x02)
            WriteByte(Save+0x92C, 0x00)
            BitOr(Save+0x1D52, 0x10)
            BitOr(Save+0x1D5A, 0x04)
        end
	end
    if ReadShort(Now+0x00) == 0x0506 and ReadByte(Now+0x38) == 0x02 then --Before Hades Escape Cutscene 2
        WriteByte(Now+0x02, 0x32)
        WriteByte(Save+0x0E, 0x32)
    end
    if ReadShort(Now+0x00) == 0x0506 and ReadByte(Now+0x38) == 0x70 then --Hades Escape
        WriteInt(Now+0x04, 0x006F006F)
        WriteByte(Now+0x08, 0x6F)
    end
    if ReadShort(Now+0x00) == 0x0A06 and ReadByte(Now+0x38) == 0x6F then --Post Hades Escape
        WriteByte(Now+0x02, 0x33)
        WriteByte(Now+0x08, 0x04)
        WriteByte(Save+0x0E, 0x33)
        WriteByte(Save+0x92E, 0x01)
        WriteByte(Save+0x94C, 0x01)
        WriteByte(Save+0x950, 0x04)
        WriteByte(Save+0x96C, 0x02)
        BitOr(Save+0x1D59, 0x10)
        WriteInt(Save+0x1F1C, 0x82A382A2)
        WriteInt(Save+0x1F34, 0x82A182A0)
    end
    if ReadShort(Now+0x00) == 0x0706 then --Cave of the Dead: Entrance Cutscenes
        if ReadShort(CutLen) == 0x0745 or ReadShort(CutLen) == 0x0C21 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x01AB then --Post Cerberus Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x92C, 0x00)
            BitOr(Save+0x1D52, 0x02)
            WriteShort(Save+0x1F04, 0x0000)
            WriteShort(Save+0x1F1C, 0x0000)
            WriteShort(Save+0x1D6F, 0x03)
        end
	end
    if ReadShort(Now+0x00) == 0x0406 and ReadByte(Now+0x38) == 0x72 then --Post Cerberus Cutscene 2
        WriteShort(Now+0x01, 0x0003)
        WriteInt(Now+0x04, 0x00C600C6)
        WriteByte(Now+0x08, 0xC6)
        WriteShort(Save+0x0D, 0x0003)
    end
    if ReadShort(Now+0x00) == 0x0406 and ReadByte(Now+0x38) == 0x04 then --Before Hercules Reunion Cutscene 2
        if ReadShort(Now+0x30) == 0x0306 then
            WriteShort(Now+0x01, 0x3201)
            WriteInt(Now+0x04, 0x00000001)
            WriteByte(Now+0x08, 0x02)
            WriteShort(Save+0x0D, 0x3201)
        end
    end
    if ReadShort(Now+0x00) == 0x0106 and ReadShort(CutLen) == 0x0334 then --Hercules Reunion Cutscene 1
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0406 and ReadShort(CutLen) == 0x0238 then --Hercules Reunion Cutscene 2
        if ReadShort(CutNow) == 0x0001 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0B06 and ReadShort(CutLen) == 0x015E then --After Hercules VS Hydra Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1106 then --Underworld Caverns: Atrium Cutscenes
        if ReadShort(CutLen) == 0x05A6 or ReadShort(CutLen) == 0x08E8 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0C06 and ReadShort(CutLen) == 0x03EF then --Opening the Seal Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0806 and ReadByte(Now+0x08) == 0x01 then --Pre-Pete Cutscene 1
		WriteByte(Now+0x08, 0x02)
        WriteByte(Save+0x938, 0x00)
        WriteByte(Save+0x944, 0x02)
        WriteByte(Save+0x958, 0x02)
        WriteByte(Save+0x95C, 0x00)
        BitOr(Save+0x1D54, 0x02)
        BitOr(Save+0x1D5B, 0xC0)
	end
    if ReadShort(Now+0x00) == 0x0806 and ReadShort(CutLen) == 0x026F then --Pre-Pete Cutscene 2
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0806 and ReadShort(CutLen) == 0x0389 then --Post Pete Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteInt(Save+0x920, 0x00020001)
        WriteByte(Save+0x926, 0x03)
        WriteByte(Save+0x958, 0x03)
        BitOr(Save+0x1D5C, 0x04)
        WriteByte(Save+0x1D6F, 0x07)
        WriteInt(Save+0x1F00, 0xC142C141)
        WriteInt(Save+0x1F28, 0x856A8569)
        WriteInt(Save+0x1F38, 0xC140C13F)
	end
    if ReadInt(Now+0x00) == 0x00000306 and ReadByte(Now+0x38) == 0x74 then --Post Pete Cutscene 2
        WriteByte(Now+0x02, 0x35)
        WriteByte(Save+0x0E, 0x35)
    end
    if ReadShort(Now+0x00) == 0x0206 and ReadShort(CutLen) == 0x07B9 then --Pre-Hydra Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1206 and ReadShort(CutLen) == 0x10E9 then --Post Hydra Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0906 and ReadShort(CutLen) == 0x00A9 then --Post "Spin Strike" Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0906 and ReadShort(CutLen) == 0x041B then --Post "Bad Alert" Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x922, 0x04)
        WriteByte(Save+0x926, 0x09)
        WriteByte(Save+0x93E, 0x0A)
        BitOr(Save+0x1D5D, 0x20)
        WriteInt(Save+0x1F2C, 0x856C856B)
	end
    if ReadShort(Now+0x00) == 0x0D06 then --The Underdrome Cutscenes
        if ReadShort(CutLen) == 0x016E or ReadShort(CutLen) == 0x127B or ReadShort(CutLen) == 0x0145 or ReadShort(CutLen) == 0x01E9 or ReadShort(CutLen) == 0x01E8 or ReadShort(CutLen) == 0x028B then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x38) == 0xC9 then --Hades Interlude
            WriteShort(Now+0x01, 0x0013)
            WriteInt(Now+0x04, 0x00CA00CA)
            WriteByte(Now+0x08, 0xCA)
            WriteShort(Save+0x0D, 0x0013)
        end
        if ReadByte(Now+0x38) == 0xCA then --Post Hades Cutscene 1
            WriteByte(Now+0x01, 0x03)
            WriteInt(Now+0x04, 0x00C700C7)
            WriteByte(Now+0x08, 0xC7)
            WriteByte(Save+0x0D, 0x03)
        end
	end
    if ReadShort(Now+0x00) == 0x0E06 and ReadByte(Now+0x38) == 0xCA then --Post Hades Cutscene 3
        WriteInt(Now+0x00, 0x001A1A04)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x02)
        WriteInt(Save+0x0C, 0x001A1A04)
    end
    if ReadShort(Now+0x00) == 0x2204 then --Zexion Cutscenes
        if ReadByte(Now+0x08) == 0x7C then --Pre-AS Zexion Cutscene
            WriteInt(Now+0x04, 0x00970097)
            WriteByte(Now+0x08, 0x97)
        end
        if ReadShort(CutLen) == 0x0140 or ReadShort(CutLen) == 0x00DC then --Post Zexion Cutscenes
            if ReadShort(CutNow) >= 0x0002 then
                WriteByte(CutSkp, 0x01)
            end
        end
        if ReadByte(Now+0x08) == 0x86 then --Pre-Data Zexion Cutscene
            WriteInt(Now+0x04, 0x00980098)
            WriteByte(Now+0x08, 0x98)
        end
	end
    if ReadShort(Now+0x00) == 0x100A and ReadByte(Now+0x08) == 0x01 then --Pride Lands 1 1st Cutscene
        WriteShort(Now+0x01, 0x3206)
        WriteByte(Now+0x04, 0x01)
        WriteByte(Now+0x08, 0x13)
        WriteShort(Save+0x0D, 0x3206)
        WriteShort(Save+0x355D, 0x0201)
        WriteInt(Save+0xF32, 0x00010001)
        WriteByte(Save+0xF38, 0x13)
        WriteByte(Save+0xF74, 0x00)
        BitOr(Save+0x1DD0, 0x0E)
        BitOr(Save+0x1DD5, 0x10)
        WriteByte(Save+0x1DDF, 0x01)
    end
    if ReadShort(Now+0x00) == 0x050A then --Elephant Graveyard Cutscenes
        if ReadShort(CutLen) == 0x0303 or ReadShort(CutLen) == 0x0E66 or ReadShort(CutLen) == 0x034A or ReadShort(CutLen) == 0x0981 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x000A then --Pride Rock Cutscenes
        if ReadShort(CutLen) == 0x093F or ReadShort(CutLen) == 0x116E or ReadShort(CutLen) == 0x0EDB or ReadShort(CutLen) == 0x034B then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0B24 then --Leaving Pride Rock Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xF2C, 0x02)
            WriteByte(Save+0xF4A, 0x01)
            BitOr(Save+0x1DD1, 0x01)
            WriteByte(Save+0x1DDF, 0x03)
            WriteInt(Save+0x2048, 0xC3F4C3F3)
            WriteShort(Save+0x2064, 0x0000)
            WriteShort(Save+0x20AC, 0x0000)
            WriteInt(Save+0x20B4, 0x8570856F)
        end
        if ReadByte(Now+0x08) == 0x03 then --Pride Rock Rafiki Cutscene
            WriteByte(Now+0x01, 0x07)
            WriteInt(Now+0x06, 0x00000001)
            WriteByte(Save+0x0D, 0x07)
            WriteInt(Save+0xF14, 0x00000000)
            WriteByte(Save+0xF26, 0x00)
            WriteByte(Save+0xF4A, 0x02)
            BitOr(Save+0x1DD1, 0x18)
        end
        if ReadShort(CutLen) == 0x03BC then --Post Hyenas II Cutscene 2
            if ReadShort(CutNow) >= 0x0002 then
                WriteByte(CutSkp, 0x01)
            end
        end
        if ReadShort(Now+0x30) == 0x080A then --Simba Defeats Scar's Ghost Cutscene 2
            if ReadByte(Now+0x08) == 0x06 then
                WriteByte(Now+0x02, 0x35)
                WriteByte(Save+0x0E, 0x35)
            end
        end
        if ReadByte(Now+0x08) == 0x11 then --Post Groundshaker Cutscene 2
            if ReadByte(Now+0x38) == 0x3B then
                WriteInt(Now+0x00, 0x001B1A04)
                WriteByte(Now+0x08, 0x02)
                WriteInt(Save+0x0C, 0x001B1A04)
            end
        end
	end
    if ReadShort(Now+0x00) == 0x090A then --Oasis Cutscenes
        if ReadByte(Now+0x08) == 0x01 then --Oasis 1st Cutscene
            WriteByte(Now+0x01, 0x03)
            WriteInt(Now+0x06, 0x00030001)
            WriteByte(Save+0x0D, 0x03)
            WriteByte(Save+0xF14, 0x03)
            WriteInt(Save+0xF24, 0x00030001)
            WriteByte(Save+0xF2C, 0x00)
            WriteByte(Save+0xF3C, 0x01)
            WriteByte(Save+0xF42, 0x01)
            WriteByte(Save+0xF4A, 0x00)
            BitOr(Save+0x1DD1, 0x06)
        end
        if ReadShort(CutLen) == 0x0834 or ReadShort(CutLen) == 0x015A then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x38) == 0x12 then --Simba & Nala Reunion Cutscene 2
            if ReadByte(Now+0x08) == 0x04 then
                WriteByte(Now+0x02, 0x33)
            end
        end
        if ReadByte(Now+0x08) == 0x0A then --Scar's Ghost Approaches Simba Cutscene
            WriteByte(Now+0x01, 0x08)
            WriteInt(Now+0x06, 0x0000000A)
            WriteByte(Save+0x0D, 0x08)
            WriteByte(Save+0xF3E, 0x00)
            WriteByte(Save+0xF4A, 0x0B)
            BitOr(Save+0x1DD4, 0x02)
        end
        if ReadShort(CutLen) == 0x1379 then --Simba Defeats Scar's Ghost Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xF10, 0x00)
            WriteByte(Save+0xF14, 0x06)
            WriteByte(Save+0xF26, 0x06)
            WriteByte(Save+0xF32, 0x06)
            WriteByte(Save+0xF6E, 0x0A)
            BitOr(Save+0x1DD4, 0x08)
        end
    end
    if ReadShort(Now+0x00) == 0x080A and ReadShort(CutLen) == 0x0B31 then --Simba & Nala Reunion Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0xF4A, 0x04)
        BitOr(Save+0x1DD1, 0x80)
	end
    if ReadShort(Now+0x00) == 0x0C0A and ReadShort(CutLen) == 0x0BCC then --Circle of Life Cutscene 2
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x040A and ReadByte(Now+0x08) == 0x03 then --Return to Pride Rock Cutscene 1
        WriteShort(Now+0x01, 0x0000)
        WriteInt(Now+0x06, 0x00040000)
        WriteShort(Save+0x0D, 0x0000)
        WriteByte(Save+0xF14, 0x04)
        WriteByte(Save+0xF1A, 0x16)
        WriteByte(Save+0xF2C, 0x00)
        WriteByte(Save+0xF4A, 0x13)
        BitOr(Save+0x1DD2, 0x04)
        WriteShort(Save+0x2048, 0x0000)
        WriteShort(Save+0x20B4, 0x0000)
        WriteInt(Save+0x20B8, 0x85748573)
    end
    if ReadShort(Now+0x00) == 0x020A then --The King's Den Cutscenes
        if ReadShort(CutLen) == 0x0129 or ReadShort(CutLen) == 0x0DFE then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0D0A then --Peak Cutscenes
        if ReadShort(CutLen) == 0x0967 then --Pre-Scar Cutscene
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(ARDEvent+0x2758C) == 0xFFFF then --Normal & Boss/Enemy
            WriteShort(ARDEvent+0x2758C, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0E0A and ReadShort(CutLen) == 0x0266 then --Post Scar Cutscene 1
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x040A and ReadByte(Now+0x08) == 0x0A then --Pride Lands 2 1st Cutscene
        WriteShort(Now+0x01, 0x3300)
        WriteByte(Now+0x04, 0x02)
        WriteByte(Now+0x08, 0x0B)
        WriteShort(Save+0x0D, 0x3300)
        WriteByte(Save+0xF10, 0x02)
        WriteByte(Save+0xF14, 0x0B)
        WriteByte(Save+0xF1A, 0x14)
        WriteByte(Save+0xF24, 0x0A)
        WriteInt(Save+0xF2A, 0x0000000A)
        WriteByte(Save+0xF30, 0x0A)
        WriteByte(Save+0xF3C, 0x0A)
        WriteByte(Save+0xF42, 0x0A)
        BitOr(Save+0x1DD3, 0x06)
        BitOr(Save+0x1DD5, 0x80)
        WriteByte(Save+0x1DDF, 0x09)
        WriteInt(Save+0x20B0, 0xC3FAC3F9)
    end
    if ReadShort(Now+0x10) == 0x010A and ReadShort(CutLen) == 0x0342 then --Talking to Rafiki Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x10) == 0x0F0A and ReadShort(CutLen) == 0x00FC then --Pre-Groundshaker Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x10) == 0x0F0A and ReadShort(CutLen) == 0x02AA then --Post Groundshaker Cutscene 1
        WriteByte(CutSkp, 0x01)
        WriteShort(Save+0x355E, 0x0102)
        WriteInt(Save+0xF14, 0x00010011)
        WriteByte(Save+0xF1A, 0x11)
        WriteByte(Save+0xF20, 0x15)
        WriteByte(Save+0xF24, 0x0B)
        WriteByte(Save+0xF2A, 0x0B)
        WriteByte(Save+0xF30, 0x0B)
        WriteByte(Save+0xF38, 0x14)
        WriteByte(Save+0xF3C, 0x0B)
        WriteByte(Save+0xF42, 0x0B)
        WriteByte(Save+0xF4A, 0x14)
        BitOr(Save+0x1DD6, 0x03)
        WriteByte(Save+0x1DDE, 0x03)
        WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
        WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
        WriteShort(Save+0x24FC, 0x0000)
	end
    if ReadShort(Now+0x00) == 0x0F12 and ReadShort(CutLen) == 0x00DC then --Post Data Saix Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0902 and ReadByte(Now+0x08) == 0x75 then --Twilight Town 1 1st Cutscene
        WriteShort(Now+0x01, 0x0017)
        WriteInt(Now+0x04, 0x0093009393)
        WriteByte(Now+0x08, 0x93)
        WriteShort(Save+0x0D, 0x0017)
        WriteByte(Save+0x310, 0x04)
        WriteInt(Save+0x31C, 0x04)
        WriteByte(Save+0x322, 0x04)
        WriteInt(Save+0x326, 0x00040005)
        WriteByte(Save+0x32C, 0x12)
        WriteInt(Save+0x334, 0x00160004)
        WriteInt(Save+0x338, 0x00040012)
        WriteInt(Save+0x33C, 0x00120015)
        WriteInt(Save+0x340, 0x00000004)
        WriteInt(Save+0x344, 0x00040012)
        WriteByte(Save+0x34A, 0x12)
        WriteByte(Save+0x34E, 0x16)
        WriteInt(Save+0x350, 0x00040012)
        WriteByte(Save+0x356, 0x12)
        WriteByte(Save+0x35C, 0x12)
        WriteInt(Save+0x362, 0x00020012)
        WriteByte(Save+0x368, 0x12)
        WriteByte(Save+0x37E, 0x01)
        WriteByte(Save+0x3E8, 0x04)
        WriteByte(Save+0x3EE, 0x04)
        BitOr(Save+0x1CE2, 0x58)
        WriteInt(Save+0x20E4, 0xCB75CB74)
        WriteInt(Save+0x20F4, 0x9F609F4D)
        WriteInt(Save+0x2120, 0xC54BC54A)
    end
    if ReadShort(Now+0x00) == 0x1702 and ReadShort(CutLen) == 0x0E6C then --Twilight Town 1 2nd Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0302 then --Back Alley Cutscenes
        if ReadShort(CutLen) == 0x02E3 then --Meeting Hayner/Pence/Olette Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x320, 0x00)
            WriteByte(Save+0x344, 0x03)
            BitOr(Save+0x1CE3, 0x02)
            WriteByte(Save+0x1D0D, 0x01)
        end
        if ReadShort(CutLen) == 0x0179 or ReadShort(CutLen) == 0x07BB or ReadShort(CutLen) == 0x02EE or ReadShort(CutLen) == 0x0168 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadInt(Now+0x00) == 0x00000202 and ReadShort(Now+0x30) == 0x0E02 then --Meeting Hayner/Pence/Olette Cutscene 2
        if ReadByte(Save+0x1CFF) == 0x08 then
            WriteByte(Now+0x02, 0x32)
            WriteByte(Save+0x0E, 0x32)
        end
    end
    if ReadShort(Now+0x00) == 0x0402 then --Sandlot Cutscenes
        if ReadShort(CutLen) == 0x087F or ReadShort(CutLen) == 0x019F or ReadShort(CutLen) == 0x1216 or ReadShort(CutLen) == 0x00F0 or ReadShort(CutLen) == 0x00C5 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x51 then --Post 3rd Tutorial
            WriteInt(Now+0x04, 0x004C004C)
            WriteByte(Now+0x08, 0x4C)
        end
        if ReadShort(CutLen) == 0x02E4 or ReadShort(CutLen) == 0x038F then --Post Seifer Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteInt(Save+0x360, 0x00160001)
            WriteByte(Save+0x364, 0x01)
            WriteByte(Save+0x368, 0x01)
            BitOr(Save+0x1CD4, 0x10)
            WriteShort(Save+0x20DC, 0x0000)
            WriteShort(Save+0x20E0, 0x0000)
            WriteInt(Save+0x20F0, 0x9F599F46)
        end
        if ReadShort(CutLen) == 0x03F4 then --Post Sandlot Dusk Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x3C4, 0x00)
            BitOr(Save+0x1CD8, 0x80)
            BitOr(Save+0x1CD9, 0x01)
        end
        if ReadByte(ARDEvent+0x93C6) == 0x9C then --Normal
            WriteByte(ARDEvent+0x93C6, 0x9A)
            WriteByte(ARDEvent+0x93C8, 0x01)
        end
        if ReadByte(ARDEvent+0x9B5A) == 0x9C then --Boss/Enemy
            WriteByte(ARDEvent+0x9B5A, 0x9A)
            WriteByte(ARDEvent+0x9B5C, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0802 then --Station Plaza Cutscenes
        if ReadShort(CutLen) == 0x040E or ReadShort(CutLen) == 0x0E93 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x04 then --End of Twilight Town 2 1st Cutscene
            WriteInt(Now+0x04, 0x00740074)
            WriteByte(Now+0x08, 0x74)
            WriteByte(Save+0x320, 0x12)
            WriteByte(Save+0x328, 0x00)
            WriteByte(Save+0x32C, 0x03)
            WriteByte(Save+0x344, 0x00)
            WriteByte(Save+0x362, 0x12)
            BitOr(Save+0x1CE6, 0xC0)
            WriteShort(Save+0x2080, 0x0000)
            WriteInt(Save+0x20E4, 0xCB75CB74)
            WriteShort(Save+0x20F4, 0x0000)
            WriteInt(Save+0x2120, 0x9F619F4E)
        end
        if ReadShort(CutLen) == 0x1086 then --End of Twilight Town 2 3rd Cutscene
            WriteByte(CutSkp, 0x01)
            if ReadByte(Save+0x3649) <= 0x02 then
                WriteByte(Save+0x1D0D, 0x0A)
            elseif ReadByte(Save+0x3649) > 0x02 then
                WriteByte(Save+0x1D0D, 0x0B)
            end
        end
        if ReadShort(CutLen) == 0x047A then --Munny Pouch Cutscene 1
            if ReadShort(CutNow) >= 0x0002 then
                WriteByte(CutSkp, 0x01)
                WriteByte(Save+0x3FF5, 0x03)
                WriteByte(Save+0x326, 0x15)
                WriteByte(Save+0x32C, 0x15)
                WriteByte(Save+0x338, 0x02)
                WriteByte(Save+0x33E, 0x15)
                WriteInt(Save+0x344, 0x00010015)
                WriteByte(Save+0x34A, 0x15)
                BitOr(Save+0x1CD6, 0xC0)
                BitOr(Save+0x1CD7, 0xFF)
                BitOr(Save+0x1CD8, 0x03)
                WriteInt(Save+0x207C, 0x9F5F9F4C)
                WriteShort(Save+0x20DC, 0x0000)
                WriteInt(Save+0x20EC, 0xC49FC44C)
                WriteInt(Save+0x2114, 0xC4A1C44E)
                WriteByte(Save+0x1D0E, 0x03)
                WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
                WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
                WriteShort(Save+0x24FC, 0x0000)
                WriteShort(Save+0x3524, 0x0000)
                WriteByte(Save+0x3528, 0x64)
                WriteByte(Save+0x3529,ReadByte(Save+0x352A))
            end
        end
        if ReadByte(Now+0x08) == 0x15 then --Munny Pouch Cutscene 2
            if ReadByte(Now+0x38) > 0x58 and ReadByte(Now+0x38) < 0x67 then
                WriteShort(Now+0x01, 0x3202)
                WriteByte(Now+0x08, 0x00)
                WriteByte(Save+0x0D, 0x3202)
            end
        end
        if ReadByte(Now+0x08) == 0x71 then --Post Setzer Cutscene 2
            WriteShort(Now+0x01, 0x3202)
            WriteInt(Now+0x04, 0x00000001)
            WriteByte(Now+0x08, 0x0C)
            WriteShort(Save+0x0D, 0x3202)
        end
	end
    if ReadShort(Now+0x00) == 0x0902 and ReadShort(CutLen) == 0x035C then --Post Station Plaza Nobodies Cutscene 2
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x346, 0x05)
            WriteByte(Save+0x34A, 0x04)
            BitOr(Save+0x1CE3, 0x20)
            WriteByte(Save+0x1D0D, 0x02)
            WriteInt(Save+0x207C, 0xCA40CA3F)
            WriteInt(Save+0x20F4, 0xCC6BCC6A)
        end
	end
    if ReadInt(Now+0x00) == 0x00000902 and ReadByte(Now+0x38) == 0x06C then --Post Station Plaza Nobodies Cutscene 3
        if ReadByte(Now+0x08) == 0x04 then
            WriteByte(Now+0x02, 0x33)
            WriteByte(Save+0x0E, 0x33)
        end
    end
    if ReadShort(Now+0x00) == 0x0902 and ReadShort(CutLen) == 0x09B1 then --Before Mysterious Tower Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x3A6, 0x02)
        WriteByte(Save+0x3AA, 0x01)
        BitOr(Save+0x1CE3, 0xC0)
        BitOr(Save+0x1CE4, 0x07)
        WriteByte(Save+0x1D0D, 0x03)
        WriteShort(Save+0x207C, 0x0000)
        WriteShort(Save+0x20E4, 0x0000)
        WriteShort(Save+0x20F4, 0x0000)
        WriteShort(Save+0x2120, 0x0000)
        WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
        WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
        WriteShort(Save+0x24FC, 0x0000)
        WriteShort(Save+0x3524, 0x0000)
        WriteByte(Save+0x3528, 0x64)
        WriteByte(Save+0x3529,ReadByte(Save+0x352A))
	end
    if ReadShort(Now+0x00) == 0x2302 and ReadByte(Now+0x08) == 0x09E then --Before Mysterious Tower Cutscene 2
        WriteShort(Now+0x01, 0x3219)
        WriteInt(Now+0x04, 0x00000002)
        WriteByte(Now+0x08, 0x01)
        WriteShort(Save+0x0D, 0x3219)
    end
    if ReadShort(Now+0x00) == 0x1902 then --The Tower Cutscenes
        if ReadShort(CutLen) == 0x1125 or ReadShort(CutLen) == 0x053A then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x1D02 and ReadShort(CutLen) == 0x010E then --Post Tower: Star Chamber Shadows Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1E02 and ReadShort(CutLen) == 0x0296 then --Post Tower: Moon Chamber Heartless Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1B02 then --Tower: Sorcerer's Loft Cutscenes
        if ReadShort(CutLen) == 0x11FA or ReadShort(CutLen) == 0x2385 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) > 0xCD and ReadByte(Now+0x08) < 0xD1 then --Optional Book Cutscenes
            WriteShort(Now+0x01, 0x321B)
            WriteInt(Now+0x04, 0x00000003)
            WriteByte(Now+0x08, 0x02)
            WriteShort(Save+0x0D, 0x321B)
        end
        if ReadShort(CutLen) == 0x1293 then --End of Twilight Town 1 Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x364, 0x04)
            WriteByte(Save+0x3B8, 0x01)
            WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
            WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
            WriteShort(Save+0x24FC, 0x0000)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
            WriteByte(Save+0x2608,ReadByte(Save+0x2609))
            WriteByte(Save+0x260A,ReadByte(Save+0x260B))
            WriteByte(Save+0x271C,ReadByte(Save+0x271D))
            WriteByte(Save+0x271E,ReadByte(Save+0x271F))
            if ReadByte(Save+0x3649) == 0x01 then --Normal
                BitOr(Save+0x1CE5, 0x30)
                WriteByte(Save+0x1D0D, 0x06)
            elseif ReadByte(Save+0x3649) >= 0x02 then
                WriteByte(Save+0x310, 0x00)
                WriteByte(Save+0x326, 0x10)
                WriteByte(Save+0x32C, 0x01)
                WriteByte(Save+0x334, 0x00)
                WriteInt(Save+0x338, 0x00000010)
                WriteInt(Save+0x33C, 0x00160016)
                WriteByte(Save+0x344, 0x10)
                WriteByte(Save+0x34A, 0x10)
                WriteByte(Save+0x350, 0x10)
                WriteByte(Save+0x356, 0x10)
                WriteByte(Save+0x35C, 0x10)
                WriteByte(Save+0x362, 0x00)
                BitOr(Save+0x1CE5, 0xB0)
                WriteByte(Save+0x1D0D, 0x07)
            end
        end
	end
    if ReadShort(Now+0x00) == 0x1C02 then
        if ReadShort(CutLen) == 0x035D or ReadShort(CutLen) == 0x10FF then --Meeting the Three Good Fairies Cutscene
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0xE4 then --Puzzle Tutorial Cutscene
            WriteInt(Now+0x02, 0x00000034)
            WriteInt(Now+0x06, 0x00040000)
            WriteByte(Save+0x0E, 0x34)
            WriteByte(Save+0x52C, 0x04)
            BitOr(Save+0x1CEB, 0x40)
        end
	end
    if ReadInt(Now+0x00) == 0x00001C02 and ReadByte(Now+0x38) == 0x04 then --End of Twilight Town 1 Cutscene 2
        WriteInt(Now+0x00, 0x001C1A04)
        WriteByte(Now+0x04, 0x00)
        WriteByte(Now+0x08, 0x02)
        WriteInt(Save+0x0C, 0x001C1A04)
    end
    if ReadShort(Now+0x00) == 0x0112 and ReadByte(Now+0x08) == 0x40 then --Twilight Town 2 1st Cutscene
        WriteInt(Now+0x00, 0x00360702)
        WriteInt(Now+0x04, 0x00160000)
        WriteByte(Now+0x08, 0x10)
        WriteInt(Save+0x0C, 0x00360702)
    end
    if ReadInt(Now+0x00) == 0x00360702 and ReadShort(Now+0x30) == 0x1A04 then --Back-Up 1 because TT is dumb (can probably delete eventually)
        WriteInt(Now+0x04, 0x00160000)
        WriteByte(Now+0x08, 0x10)
        WriteByte(Save+0x326, 0x10)
        WriteByte(Save+0x32C, 0x01)
        WriteByte(Save+0x334, 0x00)
        WriteInt(Save+0x338, 0x00000010)
        WriteInt(Save+0x33C, 0x00100016)
        WriteByte(Save+0x344, 0x00)
        WriteByte(Save+0x34A, 0x10)
        WriteByte(Save+0x350, 0x10)
        WriteByte(Save+0x356, 0x10)
        WriteByte(Save+0x35C, 0x10)
        WriteByte(Save+0x362, 0x00)
        BitOr(Save+0x1CE5, 0x40)
        BitOr(Save+0x1CE6, 0x03)
        BitOr(Save+0x1CE9, 0x20)
        BitOr(Save+0x1CEC, 0x08)
        BitOr(Save+0x1CED, 0x10)
        WriteByte(Save+0x1D0D, 0x08)
        WriteInt(Save+0x207C, 0xCA40CA3F)
        WriteInt(Save+0x2080, 0xC664C663)
        WriteInt(Save+0x20E4, 0xC66EC66D)
        WriteInt(Save+0x20F4, 0xC664C663)
        WriteInt(Save+0x2120, 0xC666C665)
    end
    if ReadShort(Now+0x00) == 0x0012 and ReadByte(Now+0x08) == 0x75 then --End of Twilight Town 2 4th Cutscene
        WriteInt(Now+0x00, 0x001C1A04)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x02)
        WriteInt(Save+0x0C, 0x001C1A04)
    end
    if ReadShort(Now+0x00) == 0x0902 and ReadByte(Now+0x08) == 0x77 then --Twilight Town 3 1st Cutscene
        WriteInt(Now+0x02, 0x00060034)
        WriteInt(Now+0x06, 0x00000000)
        WriteByte(Save+0x0E, 0x34)
    end
    if ReadInt(Now+0x00) == 0x00340902 and ReadShort(Now+0x30) == 0x1A04 then --Back-Up 2 because TT is dumb (can probably delete eventually)
        WriteInt(Now+0x04, 0x00000006)
        WriteByte(Now+0x08, 0x00)
        WriteByte(Save+0x312, 0x07)
        WriteInt(Save+0x322, 0x00070006)
        WriteByte(Save+0x326, 0x00)
        WriteInt(Save+0x334, 0x00070006)
        WriteInt(Save+0x338, 0x00060000)
        WriteInt(Save+0x33C, 0x00000007)
        WriteInt(Save+0x340, 0x00070006)
        WriteInt(Save+0x344, 0x00060000)
        WriteInt(Save+0x34A, 0x00060000)
        WriteByte(Save+0x352, 0x06)
        WriteByte(Save+0x358, 0x06)
        WriteInt(Save+0x360, 0x00000007)
        WriteInt(Save+0x366, 0x00050000)
        WriteByte(Save+0x3EA, 0x07)
        WriteByte(Save+0x3F0, 0x07)
        BitOr(Save+0x1CE7, 0x04)
        BitOr(Save+0x1CED, 0x60)
        WriteByte(Save+0x1D0D, 0x0C)
        WriteShort(Save+0x207C, 0x0000)
        WriteShort(Save+0x20E4, 0x0000)
        WriteInt(Save+0x20EC, 0xCB77CB76)
        WriteShort(Save+0x2020, 0x0000)
    end
    if ReadShort(Now+0x00) == 0x0E02 then --The Old Mansion Cutscenes
        if ReadShort(CutLen) == 0x100B then --Pre-Old Mansion Nobodies Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x368, 0x06)
            WriteByte(Save+0x36E, 0x01)
            WriteByte(Save+0x372, 0x07)
            WriteByte(Save+0x378, 0x07)
            BitOr(Save+0x1CE7, 0x20)
            WriteByte(Save+0x1D0D, 0x0D)
        end
        if ReadByte(Now+0x38) == 0xBA then --Post Old Mansion Nobodies Cutscene
            WriteByte(Now+0x02, 0x34)
            WriteByte(Save+0x0E, 0x34)
        end
        if ReadShort(CutLen) == 0x01C1 or ReadShort(CutLen) == 0x032B or ReadShort(CutLen) == 0x05FB then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0216 then --Post The Old Mansion Dusk Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x3FF5, 0x02)
            WriteInt(Save+0x31C, 0x00020002)
            WriteByte(Save+0x320, 0x02)
            BitOr(Save+0x1CD5, 0xFF)
            BitOr(Save+0x1CD6, 0x03)
            WriteByte(Save+0x1D0E, 0x01)
            WriteInt(Save+0x20E0, 0x9F5A9F47)
            WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
            WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
            WriteShort(Save+0x24FC, 0x0000)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        end
        if ReadShort(CutLen) == 0x06B7 then --End of Day 5 Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteShort(Save+0x3FF5, 0x0006)
            WriteByte(Save+0x322, 0x03)
            WriteInt(Save+0x326, 0x00030003)
            WriteByte(Save+0x334, 0x03)
            WriteByte(Save+0x33A, 0x03)
            WriteInt(Save+0x33E, 0x00030000)
            WriteByte(Save+0x346, 0x03)
            WriteByte(Save+0x34A, 0x00)
            BitOr(Save+0x1CDE, 0x80)
            BitOr(Save+0x1CDF, 0xFF)
            BitOr(Save+0x1CE0, 0x01)
            WriteByte(Save+0x1D0E, 0x0A)
            WriteByte(Save+0x23EE, 0x02)
            WriteShort(Save+0x2080, 0x0000)
            WriteInt(Save+0x2114, 0xC547C546)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        end
	end
    if ReadShort(Now+0x00) == 0x0F02 and ReadShort(CutLen) == 0x0356 then --Entering the Mansion Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1502 then --Mansion: Computer Room Cutscenes
        if ReadShort(CutLen) == 0x0667 or ReadShort(CutLen) == 0x01F3 or ReadShort(CutLen) == 0x010E or ReadShort(CutLen) == 0x04A2 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0329 then --Entering Computer Room Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x382, 0x03)
            WriteByte(Save+0x386, 0x01)
            WriteByte(Save+0x38E, 0x02)
            BitOr(Save+0x1CE1, 0x02)
        end
	end
    if ReadShort(Now+0x00) == 0x1302 then --Mansion: Basement Hall Cutscenes
        if ReadShort(CutLen) == 0x0231 or ReadShort(CutLen) == 0x00DC or ReadShort(CutLen) == 0x0445 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x87 then --Post Axel II Cutscene
            WriteInt(Now+0x02, 0x00010032)
            WriteInt(Now+0x06, 0x00020000)
            WriteByte(Save+0x0E, 0x32)
            WriteByte(Save+0x346, 0x02)
            WriteByte(Save+0x34A, 0x13)
            WriteByte(Save+0x378, 0x00)
            WriteByte(Save+0x382, 0x01)
            WriteByte(Save+0x386, 0x02)
            BitOr(Save+0x1CE1, 0x30)
            BitOr(Save+0x1CF9, 0x90)
            WriteByte(Save+0x1D0E, 0x0D)
            WriteShort(Save+0x2114, 0x0000)
            WriteShort(Save+0x211C, 0x0000)
        end
	end
    if ReadShort(Now+0x00) == 0x2802 then --Betwixt and Between Cutscenes
        if ReadShort(CutLen) == 0x0368 or ReadShort(CutLen) == 0x0528 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0E9F then --Post Betwixt and Between Nobodies Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteShort(Save+0x353D, 0x0201)
            WriteInt(Save+0x320, 0x00000012)
            WriteInt(Save+0x324, 0x00100000)
            WriteInt(Save+0x334, 0x00160000)
            WriteInt(Save+0x338, 0x00000010)
            WriteInt(Save+0x33C, 0x00100016)
            WriteInt(Save+0x340, 0x00000000)
            WriteInt(Save+0x344, 0x00000010)
            WriteInt(Save+0x34A, 0x00000010)
            WriteByte(Save+0x352, 0x00)
            WriteByte(Save+0x358, 0x00)
            WriteInt(Save+0x360, 0x00120000)
            WriteByte(Save+0x366, 0x02)
            WriteInt(Save+0x382, 0x00070000)
            WriteByte(Save+0x38E, 0x03)
            WriteByte(Save+0x392, 0x0F)
            WriteByte(Save+0x3A8, 0x07)
            WriteByte(Save+0x3C0, 0x07)
            WriteByte(Save+0x3C6, 0x07)
            WriteByte(Save+0x3CC, 0x07)
            WriteInt(Save+0x3E8, 0x00010004)
            WriteByte(Save+0x3F6, 0x07)
            WriteByte(Save+0x3FC, 0x07)
            WriteByte(Save+0x400, 0x0D)
            WriteByte(Save+0x404, 0x00)
            BitOr(Save+0x1CE9, 0x0C)
            WriteByte(Save+0x1CFD, 0x01)
            WriteShort(Save+0x20EC, 0x0000)
            WriteShort(Save+0x20FC, 0x0000)
            WriteShort(Save+0x2100, 0x0000)
            WriteShort(Save+0x24FC, 0x0000)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        end
        if ReadByte(Now+0x38) == 0xA1 then --Post Betwixt and Between Nobodies Cutscene 2
            if ReadShort(Now+0x04) == 0x0D then
                WriteInt(Now+0x00, 0x001C1A04)
                WriteByte(Now+0x04, 0x00)
                WriteByte(Now+0x08, 0x02)
                WriteInt(Save+0x0C, 0x001C1A04)
            end
        end
        if ReadShort(ARDEvent+0x216B4) == 0xFFFF then --Normal
            WriteShort(ARDEvent+0x216B4, 0x01)
        end
        if ReadShort(ARDEvent+0x20EB4) == 0xFFFF then --Boss/Enemy
            WriteShort(ARDEvent+0x20EB4, 0x01)
        end
    end
    if ReadShort(Now+0x00) == 0x1402 and ReadShort(CutLen) == 0x00DC then --Post Data Axel Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x1402 and ReadByte(Now+0x08) == 0xD3 then --Data Axel (1 Hour)
        if ReadShort(Now+0x30) == 0x1A04 then
            WriteInt(Now+0x04, 0x00D500D5)
            WriteByte(Now+0x08, 0xD5)
        end
    end
    if ReadShort(Now+0x00) == 0x0004 and ReadByte(Now+0x08) == 0x01 then --Hollow Bastion 1 1st Cutscene
        WriteShort(Now+0x01, 0x320A)
        WriteByte(Now+0x04, 0x01)
        WriteByte(Now+0x08, 0x16)
        WriteByte(Save+0x0D, 0x320A)
        WriteByte(Save+0x614, 0x00)
        WriteByte(Save+0x64A, 0x01)
        WriteByte(Save+0x650, 0x16)
        BitOr(Save+0x1D10, 0x06)
        BitOr(Save+0x1D15, 0x60)
        BitOr(Save+0x1D1B, 0x20)
        BitOr(Save+0x1D1E, 0x06)
    end
    if ReadShort(Now+0x00) == 0x0A04 then --Marketplace Cutscenes
        if ReadShort(CutLen) == 0x02C6 or ReadShort(CutLen) == 0x00F0 or ReadShort(CutLen) == 0x1051 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x02 then --Hollow Bastion 2 1st Cutscene
            WriteByte(Now+0x02, 0x32)
            WriteByte(Now+0x08, 0x10)
            WriteByte(Save+0x0E, 0x32)
            WriteByte(Save+0x648, 0x02)
            WriteByte(Save+0x650, 0x10)
            WriteByte(Save+0x662, 0x02)
            BitOr(Save+0x1D10, 0x04)
            BitOr(Save+0x1D1E, 0x20)
        end
        if ReadByte(Now+0x38) == 0x4B then --Post Sephiroth Cutscene 2
            WriteShort(Now+0x01, 0x3201)
            WriteByte(Now+0x04, 0x01)
            WriteByte(Now+0x08, 0x14)
            WriteShort(Save+0x0D, 0x3201)
        end
	end
    if ReadShort(Now+0x00) == 0x0904 then --Borough Cutscenes
        if ReadShort(CutLen) == 0x03C3 or ReadShort(CutLen) == 0x05D0 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0D04 then --Merlin's House Cutscenes
        if ReadShort(CutLen) == 0x1732 or ReadShort(CutLen) == 0x02ED then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0804 and ReadShort(CutLen) == 0x0214 then --Pre-Bailey Nobodies Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x61A, 0x00)
        BitOr(Save+0x1D1F, 0x03)
        WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
        WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
        WriteShort(Save+0x24FC, 0x0000)
        if ReadShort(Save+0x3524) > 0 then
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        end
	end
    if ReadShort(Now+0x00) == 0x0104 then --The Dark Depths Cutscenes
        if ReadShort(Now+0x30) == 0x0904 then --Bailey Nobodies
            if ReadShort(Now+0x38) == 0x00 then
                WriteByte(Now+0x01, 0x08)
                WriteByte(Now+0x04, 0x34)
                WriteByte(Now+0x06, 0x34)
                WriteByte(Now+0x08, 0x34)
                WriteByte(Save+0x0D, 0x08)
            end
        end
        if ReadShort(CutLen) == 0x35EA then --Post 1,000 Heartless Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x616, 0x01)
            WriteByte(Save+0x61A, 0x16)
            WriteInt(Save+0x61E, 0x00030002)
            WriteByte(Save+0x62A, 0x01)
            WriteByte(Save+0x62E, 0x0E)
            WriteByte(Save+0x638, 0x12)
            WriteByte(Save+0x63C, 0x00)
            WriteByte(Save+0x642, 0x00)
            WriteByte(Save+0x648, 0x0B)
            WriteInt(Save+0x650, 0x00010006)
            WriteByte(Save+0x654, 0x0B)
            WriteByte(Save+0x65C, 0x16)
            WriteInt(Save+0x662, 0x00000010)
            WriteByte(Save+0x668, 0x00)
            WriteByte(Save+0x66C, 0x00)
            WriteByte(Save+0x672, 0x0B)
            WriteInt(Save+0x67C, 0x000B000D)
            WriteInt(Save+0x684, 0x0000000B)
            BitOr(Save+0x1D15, 0x18)
            BitOr(Save+0x1D19, 0x70)
            BitOr(Save+0x1D1A, 0x7C)
            BitOr(Save+0x1D1C, 0x7C)
            BitOr(Save+0x1D1D, 0x7B)
            BitOr(Save+0x1D1E, 0x40)
            BitOr(Save+0x1D20, 0x20)
            BitOr(Save+0x1D21, 0x0C)
            BitOr(Save+0x1D22, 0x60)
            BitOr(Save+0x1D24, 0x02)
            WriteInt(Save+0x2032, 0x0000C687)
            WriteShort(Save+0x2038, 0x0000)
            WriteInt(Save+0x203C, 0xC6890000)
            WriteInt(Save+0x2040, 0xC68D0000)
            WriteShort(Save+0x20D4, 0x0000)
            WriteShort(Save+0x20D8, 0x0000)
            WriteShort(Save+0x210A, 0xA8CD)
            WriteShort(Save+0x2126, 0xC68B)
        end
        if ReadShort(CutLen) == 0x136B or ReadShort(CutLen) == 0x053E or ReadShort(CutLen) == 0x1649 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x02A9 then --Post Sephiroth Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x61A, 0x14)
            WriteByte(Save+0x650, 0x0D)
            BitOr(Save+0x1D20, 0x01)
        end
    end
    if ReadShort(Now+0x00) == 0x0804 and ReadShort(CutLen) == 0x1DDA then --Post Bailey Nobodies Cutscene 1
		WriteByte(CutSkp, 0x01)
        if ReadByte(Save+0x3643) == 0x01 then
            WriteByte(Save+0x1D2F, 0x02)
        elseif ReadByte(Save+0x3643) >= 0x02 then
            WriteByte(Save+0x1D2F, 0x03)
            WriteByte(Save+0x64C, 0x02)
            WriteByte(Save+0x650, 0x02)
            BitOr(Save+0x1D11, 0x02)
            BitOr(Save+0x1D1E, 0x10)
        end
	end
    if ReadShort(Now+0x00) == 0x0012 and ReadShort(Now+0x30) == 0x0804 then --Post Bailey Nobodies Cutscene 2
        WriteInt(Now+0x00, 0x001D1A04)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x02)
        WriteInt(Save+0x0C, 0x001D1A04)
    end
    if ReadShort(Now+0x00) == 0x0804 and ReadShort(CutLen) == 0x06E9 then --Meeting Gull Wings Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0604 then --Postern Cutscenes
        if ReadShort(CutLen) == 0x06A5 or ReadShort(CutLen) == 0x0BEE then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0B04 and ReadShort(CutLen) == 0x0123 then --Stitch on Ceiling Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0504 and ReadShort(CutLen) == 0x0A33 then --Entering Ansem's Study Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0504 and ReadShort(CutLen) == 0x0253 then --Talking to Leon Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x62E, 0x04)
        WriteByte(Save+0x632, 0x06)
        BitOr(Save+0x1D12, 0x38)
        BitOr(Save+0x1D18, 0x20)
        WriteByte(Save+0x1D2F, 0x06)
        WriteInt(Save+0x203C, 0xC5B8C5B7)
        WriteInt(Save+0x2040, 0xC5BCC5BB)
        WriteInt(Save+0x2124, 0xC5BAC5B9)
        WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
        WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
        WriteShort(Save+0x24FC, 0x0000)
        if ReadShort(Save+0x3524) > 0 then
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        end
        WriteByte(Save+0x2608,ReadByte(Save+0x2609))
        WriteByte(Save+0x260A,ReadByte(Save+0x260B))
        WriteByte(Save+0x271C,ReadByte(Save+0x271D))
        WriteByte(Save+0x271E,ReadByte(Save+0x271F))
	end
    if ReadInt(Now+0x00) == 0x00360504 and ReadByte(Now+0x38) == 0x02 then --Ansem's Study Cutscenes 2
        WriteByte(Now+0x02, 0x33)
    end
    if ReadShort(Now+0x00) == 0x0504 and ReadShort(CutLen) == 0x155F then --"Door to Darkness" Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x62E, 0x07)
        WriteByte(Save+0x632, 0x09)
        BitOr(Save+0x1D13, 0x02)
        WriteInt(Save+0x2124, 0xC979C978)
	end
    if ReadInt(Now+0x00) == 0x00340504 and ReadByte(Now+0x38) == 0x06 then --Ansem's Study Cutscenes 3
        WriteByte(Now+0x02, 0x32)
    end
    if ReadShort(Now+0x00) == 0x0504 and ReadShort(CutLen) == 0x0F33 then --"He wasn't really Ansem!" Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x62E, 0x0F)
        WriteByte(Save+0x632, 0x14)
        BitOr(Save+0x1D20, 0x06)
        WriteByte(Save+0x1D2D, 0x01)
        WriteShort(Save+0x2124, 0x0000)
	end
    if ReadInt(Now+0x00) == 0x00000504 and ReadByte(Now+0x38) == 0x09 then --"He wasn't really Ansem!" Cutscene 2
        WriteByte(Now+0x02, 0x37)
    end
    if ReadByte(Save+0x1D2D) == 0x01 and ReadByte(HBBGM+0x00) == 0x98 then --Ansem's Study Music Fix
        WriteByte(HBBGM+0x0000, 0x99) --Ansem's Study
        WriteByte(HBBGM+0x0040, 0x99) --Postern
        WriteByte(HBBGM+0x0100, 0x99) --Borough
        WriteByte(HBBGM+0x0140, 0x99) --Marketplace
        WriteByte(HBBGM+0x0180, 0x99) --Corridors
        WriteByte(HBBGM+0x01C0, 0x99) --Heartless Manufactory
        WriteByte(HBBGM+0x0200, 0x99) --Merlin's House
        WriteByte(HBBGM+0x0340, 0x99) --Restoration Site
        WriteByte(HBBGM+0x0380, 0x99) --Bailey (After Destruction)
    elseif ReadByte(Save+0x1D2D) == 0x00 and ReadByte(HBBGM+0x00) == 0x99 then --Post FF Fights Music Fix
        WriteByte(HBBGM+0x0000, 0x98) --Ansem's Study
        WriteByte(HBBGM+0x0040, 0x98) --Postern
        WriteByte(HBBGM+0x0100, 0x98) --Borough
        WriteByte(HBBGM+0x0140, 0x98) --Marketplace
        WriteByte(HBBGM+0x0180, 0x98) --Corridors
        WriteByte(HBBGM+0x01C0, 0x98) --Heartless Manufactory
        WriteByte(HBBGM+0x0200, 0x98) --Merlin's House
        WriteByte(HBBGM+0x0340, 0x98) --Restoration Site
        WriteByte(HBBGM+0x0380, 0x98) --Bailey (After Destruction)
    elseif ReadByte(Save+0x1D2D) == 0x01 and ReadByte(HBBGM+0x0C80) == 0x98 then --Ansem's Study Music Fix (Chest Cosmetics)
        WriteByte(HBBGM+0x0C80, 0x99) --Ansem's Study
        WriteByte(HBBGM+0x0CC0, 0x99) --Postern
        WriteByte(HBBGM+0x0D80, 0x99) --Borough
        WriteByte(HBBGM+0x0DC0, 0x99) --Marketplace
        WriteByte(HBBGM+0x0E00, 0x99) --Corridors
        WriteByte(HBBGM+0x0E40, 0x99) --Heartless Manufactory
        WriteByte(HBBGM+0x0E80, 0x99) --Merlin's House
        WriteByte(HBBGM+0x0FC0, 0x99) --Restoration Site
        WriteByte(HBBGM+0x1000, 0x99) --Bailey (After Destruction)
    elseif ReadByte(Save+0x1D2D) == 0x00 and ReadByte(HBBGM+0x0C80) == 0x99 then --Post FF Fights Music Fix (Chest Cosmetics)
        WriteByte(HBBGM+0x0C80, 0x98) --Ansem's Study
        WriteByte(HBBGM+0x0CC0, 0x98) --Postern
        WriteByte(HBBGM+0x0D80, 0x98) --Borough
        WriteByte(HBBGM+0x0DC0, 0x98) --Marketplace
        WriteByte(HBBGM+0x0E00, 0x98) --Corridors
        WriteByte(HBBGM+0x0E40, 0x98) --Heartless Manufactory
        WriteByte(HBBGM+0x0E80, 0x98) --Merlin's House
        WriteByte(HBBGM+0x0FC0, 0x98) --Restoration Site
        WriteByte(HBBGM+0x1000, 0x98) --Bailey (After Destruction)
	end
    if ReadShort(Now+0x00) == 0x1304 and ReadShort(Now+0x30) == 0x0504 then --Corridors Fight
        if ReadByte(Now+0x08) == 0x3D then
            WriteByte(Now+0x01, 0x14)
            WriteInt(Now+0x04, 0x00560056)
            WriteByte(Now+0x08, 0x56)
            WriteByte(Save+0x0D, 0x14)
            WriteByte(Save+0x62E, 0x0D)
            WriteInt(Save+0x632, 0x00030000)
            WriteByte(Save+0x638, 0x15)
            WriteByte(Save+0x654, 0x02)
            WriteInt(Save+0x67C, 0x00020002)
            WriteByte(Save+0x680, 0x01)
            WriteByte(Save+0x692, 0x01)
            BitOr(Save+0x1D13, 0x50)
            BitOr(Save+0x1D18, 0x40)
            BitOr(Save+0x1D20, 0x40)
            WriteByte(Save+0x1D2F, 0x07)
            WriteShort(Save+0x203C, 0x0000)
        end
    end
    if ReadShort(Now+0x00) == 0x0B04 and ReadByte(Now+0x38) == 0x56 then --Post Corridors Fight
        WriteShort(Now+0x01, 0x3406)
        WriteInt(Now+0x04, 0x00000003)
        WriteByte(Now+0x08, 0x15)
        WriteShort(Save+0x0D, 0x3406)
    end
    if ReadShort(Now+0x00) == 0x1204 then --Restoration Site Cutscenes
        if ReadShort(CutLen) == 0x011F then --Pre-Restoration Site Nobodies Cutscene
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x010A then --Post Restoration Site Nobodies Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteInt(Save+0x646, 0x00030000)
            WriteByte(Save+0x64C, 0x00)
            WriteByte(Save+0x662, 0x0D)
            WriteByte(Save+0x67C, 0x03)
            WriteByte(Save+0x686, 0x04)
            BitOr(Save+0x1D14, 0x02)
            WriteShort(Save+0x2040, 0x0000)
        end
        if ReadShort(ARDEvent+0x27890) == 0xFFFF then --Normal & Boss Enemy
            WriteShort(ARDEvent+0x27890, 0x01)
        end
    end
    if ReadInt(Now+0x00) == 0x00001304 and ReadByte(Now+0x38) == 0x49 then --Post Restoration Site Nobodies Cutscene 2
        WriteByte(Now+0x02, 0x32)
        WriteByte(Save+0x0E, 0x32)
    end
    if ReadShort(Now+0x00) == 0x1304 and ReadShort(CutLen) == 0x0B4F then --Pre-Demyx Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x62C, 0x00)
        BitOr(Save+0x1D14, 0x08)
        WriteByte(Save+0x1D2F, 0x08)
	end
    if ReadShort(Now+0x00) == 0x1B04 and ReadShort(Now+0x30) == 0x1304 then --Demyx (Hollow Bastion)
        WriteByte(Now+0x01, 0x04)
        WriteInt(Now+0x04, 0x00370037)
        WriteShort(Now+0x08, 0x0037)
        WriteByte(Save+0x0D, 0x04)
    end
    if ReadShort(Now+0x00) == 0x0404 and ReadShort(CutLen) == 0x10B5 then --Post Demyx Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0304 and ReadShort(CutLen) == 0x07F4 then --Post Ravine Trail Heartless Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1D2D, 0x00)
	end
    if ReadShort(Now+0x00) == 0x0204 and ReadShort(CutLen) == 0x0583 then --Pre-1,000 Heartless Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x62E, 0x08)
        WriteByte(Save+0x66E, 0x00)
        BitOr(Save+0x1D15, 0x03)
        WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
        WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
        WriteShort(Save+0x24FC, 0x0000)
        if ReadShort(Save+0x3524) > 0 then
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        end
	end
    if ReadShort(Now+0x00) == 0x0F04 and ReadShort(Now+0x30) == 0x0304 then --1,000 Heartless
        WriteByte(Now+0x01, 0x11)
        WriteInt(Now+0x04, 0x00420042)
        WriteByte(Now+0x08, 0x42)
        WriteByte(Save+0x0D, 0x11)
    end
    if ReadShort(Now+0x00) == 0x1304 and ReadByte(Now+0x38) == 0x42 then --Post 1,000 Heartless Cutscene 2
        WriteByte(Now+0x01, 0x01)
        WriteInt(Now+0x04, 0x005C005C)
        WriteByte(Now+0x08, 0x5C)
        WriteByte(Save+0x0D, 0x01)
    end
    if ReadShort(Now+0x00) == 0x1504 and ReadShort(CutLen) == 0x0187 then --Entering Cavern of Remembrance Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1604 and ReadShort(CutLen) == 0x01B0 then --Steam Wheels Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0404 and ReadShort(CutLen) == 0x00DC then --Post Data Demyx Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0010 and ReadByte(Now+0x08) == 0x01 then --Port Royal 1 1st Cutscene
        WriteByte(Now+0x02, 0x32)
        WriteByte(Now+0x08, 0x00)
        WriteByte(Save+0x0E, 0x32)
        WriteShort(Save+0x3575, 0x0201)
        WriteByte(Save+0x1814, 0x00)
        WriteByte(Save+0x181A, 0x01)
        BitOr(Save+0x1E90, 0x10)
        BitOr(Save+0x1E99, 0x10)
        WriteInt(Save+0x20A0, 0x85468545)
    end
    if ReadShort(Now+0x00) == 0x0110 then --Harbor Cutscenes
        if ReadShort(CutLen) == 0x0A81 or ReadShort(CutLen) == 0x0327 or ReadShort(CutLen) == 0x030A or ReadShort(CutLen) == 0x0242 or ReadShort(CutLen) == 0x059C then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0807 then --Post Grim Reaper II Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteInt(Save+0x1814, 0x00020015)
            WriteInt(Save+0x1818, 0x0000000B)
            WriteInt(Save+0x181C, 0x000B0001)
            WriteByte(Save+0x1832, 0x13)
            WriteByte(Save+0x1838, 0x00)
            WriteByte(Save+0x1848, 0x0A)
            WriteInt(Save+0x184C, 0x000A000D)
            WriteByte(Save+0x185A, 0x0A)
            WriteByte(Save+0x1860, 0x0A)
            WriteByte(Save+0x1866, 0x0A)
            WriteByte(Save+0x186C, 0x0B)
            WriteByte(Save+0x187E, 0x0B)
            WriteByte(Save+0x1884, 0x0C)
            WriteByte(Save+0x188A, 0x0B)
            BitOr(Save+0x1E95, 0x40)
            BitOr(Save+0x1E96, 0x01)
            BitOr(Save+0x1E98, 0x01)
            BitOr(Save+0x1E99, 0x02)
            BitOr(Save+0x1E9A, 0x01)
            BitOr(Save+0x1E9B, 0x20)
            WriteByte(Save+0x1E9E, 0x02)
            BitNot(Save+0x239E, 0x10)
            WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
            WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
            WriteShort(Save+0x24FC, 0x0000)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
            WriteByte(Save+0x2608,ReadByte(Save+0x2609))
            WriteByte(Save+0x260A,ReadByte(Save+0x260B))
            WriteByte(Save+0x271C,ReadByte(Save+0x271D))
            WriteByte(Save+0x271E,ReadByte(Save+0x271F))
        end
	end
    if ReadShort(Now+0x00) == 0x0210 then --Town Cutscenes
        if ReadShort(CutLen) == 0x02B2 or ReadShort(CutLen) == 0x02E8 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x1810 and ReadShort(CutLen) == 0x0E2F then --Meeting Jack Sparrow Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1710 and ReadByte(Now+0x08) == 0x4F then --Elizabeth & Barbossa Cutscene
        WriteShort(Now+0x01, 0x3303)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x15)
        WriteShort(Save+0x0D, 0x3303)
        WriteInt(Save+0x1816, 0x00010001)
        WriteByte(Save+0x181A, 0x00)
        WriteByte(Save+0x1826, 0x15)
        WriteByte(Save+0x182C, 0x14)
        WriteByte(Save+0x1834, 0x01)
        WriteByte(Save+0x1838, 0x00)
        WriteInt(Save+0x1890, 0x00010001)
        WriteInt(Save+0x1896, 0x00010001)
        BitOr(Save+0x1E91, 0x08)
        WriteByte(Save+0x1E9F, 0x01)
        WriteShort(Save+0x2098, 0x0000)
    end
    if ReadShort(Now+0x00) == 0x0310 and ReadShort(CutLen) == 0x02F2 then --After 1st Ambush Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1910 and ReadShort(CutLen) == 0x5CF then --Before 1 Minute Fight Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1844, 0x00)
        WriteInt(Save+0x1848, 0x00020001)
        BitOr(Save+0x1E92, 0x02)
        WriteByte(Save+0x1E9F, 0x02)
	end
    if ReadShort(Now+0x00) == 0x1110 and ReadByte(Now+0x08) == 0x3D then --Before 1 Minute Fight Cutscene 2
        WriteShort(Now+0x01, 0x3208)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x00)
        WriteShort(Save+0x0D, 0x3208)
    end
    if ReadShort(Now+0x00) == 0x0910 then --Isla de Muerta: Cave Mouth Cutscenes
        if ReadShort(CutLen) == 0x0202 or ReadShort(CutLen) == 0x0104 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x1110 and ReadShort(CutLen) == 0x0F2C then --Post 1 Minute Fight Cutscene 2
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0410 and ReadShort(CutLen) == 0x082F then --Pre-Medallion Fight Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1826, 0x12)
        WriteByte(Save+0x182C, 0x02)
        WriteByte(Save+0x1832, 0x00)
        WriteByte(Save+0x1892, 0x04)
        BitOr(Save+0x1E92, 0xC0)
        BitOr(Save+0x1E93, 0x01)
	end
    if ReadInt(Now+0x00) == 0x00000510 and ReadByte(Now+0x08) == 0x00 then --Pre-Medallion Fight Cutscene 2
        WriteByte(Now+0x01, 0x07)
        WriteInt(Now+0x04, 0x003A003A)
        WriteByte(Now+0x08, 0x3A)
        WriteByte(Save+0x0D, 0x07)
    end
    if ReadShort(Now+0x00) == 0x0710 and ReadByte(Now+0x08) == 0x51 then --Post Medallion Fight Cutscene 1
        WriteByte(Now+0x01, 0x04)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x02)
        WriteByte(Save+0x0D, 0x04)
    end
    if ReadShort(Now+0x00) == 0x0410 and ReadShort(CutLen) == 0x033F then --Post Medallion Fight Cutscene 2
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0310 and ReadShort(CutLen) == 0x0180 then --Post Barrels Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1826, 0x11)
        WriteByte(Save+0x182C, 0x15)
        WriteByte(Save+0x1844, 0x05)
        WriteByte(Save+0x1848, 0x02)
        WriteByte(Save+0x1850, 0x02)
        WriteByte(Save+0x185A, 0x01)
        WriteByte(Save+0x1860, 0x01)
        WriteByte(Save+0x1874, 0x01)
        WriteByte(Save+0x1890, 0x03)
        WriteByte(Save+0x1896, 0x03)
        BitOr(Save+0x1E93, 0x01)
        BitNot(Save+0x2398, 0x80)
	end
    if ReadInt(Now+0x00) == 0x00000810 and ReadByte(Now+0x38) == 0x38 then --Post Barrels Cutscene 1
        WriteByte(Now+0x02, 0x32)
        WriteByte(Save+0x0E, 0x32)
    end
    if ReadShort(Now+0x00) == 0x0A10 then --Isla de Muerta: Treasure Heap Cutscenes
        if ReadShort(CutLen) == 0x0F1E or ReadShort(CutLen) == 0x0845 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x0A then --Port Royal 2 1st Cutscene
            WriteShort(Now+0x01, 0x3300)
            WriteByte(Now+0x04, 0x02)
            WriteByte(Now+0x08, 0x14)
            WriteShort(Save+0x0D, 0x3300)
            WriteInt(Save+0x3574, 0x12020100)
            WriteByte(Save+0x1814, 0x14)
            WriteByte(Save+0x181A, 0x0A)
            WriteByte(Save+0x184C, 0x02)
            WriteByte(Save+0x1850, 0x00)
            BitOr(Save+0x1E93, 0x80)
            BitOr(Save+0x1E94, 0x01)
            BitOr(Save+0x1E99, 0x80)
            WriteByte(Save+0x1E9F, 0x07)
            WriteInt(Save+0x20A0, 0x85528551)
        end
        if ReadShort(ARDEvent+0x13F10) == 0xFFFF then --Normal & Boss/Enemy
            WriteShort(ARDEvent+0x13F10, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0810 and ReadShort(CutLen) == 0x0EB2 then --Post Captain Barbossa Cutscene 2
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0510 and ReadShort(CutLen) == 0x035D then --Before Grim Reaper I Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x182E, 0x02)
        WriteInt(Save+0x1832, 0x0002000B)
        WriteByte(Save+0x1838, 0x15)
        BitOr(Save+0x1E94, 0x20)
        WriteInt(Save+0x205C, 0xC1C2C1C1)
	end
    if ReadShort(Now+0x00) == 0x0610 and ReadByte(Now+0x08) == 0x015 then
        if ReadShort(Now+0x30) == 0x1310 and ReadByte(Now+0x38) == 0x0A then --Won Ambush Before GR1
            WriteByte(Now+0x02, 0x32)
            WriteByte(Save+0x0E, 0x32)
        elseif ReadShort(Now+0x30) == 0x0510 and ReadByte(Now+0x38) == 0x12 then --Fled Ambush before GR1
            WriteByte(Now+0x02, 0x32)
            WriteByte(Save+0x0E, 0x32)
        end
    end
    if ReadShort(Now+0x00) == 0x0510 and ReadShort(CutLen) == 0x04F2 then --Pre-Grim Reaper I Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0510 and ReadByte(Now+0x38) == 0x55 then --Post Grim Reaper I Cutscene
        WriteShort(Now+0x01, 0x320B)
        WriteInt(Now+0x04, 0x00000001)
        WriteByte(Now+0x08, 0x16)
        WriteShort(Save+0x0D, 0x320B)
        WriteByte(Save+0x1856, 0x16)
        WriteByte(Save+0x1868, 0x0A)
        WriteByte(Save+0x186C, 0x0A)
        BitOr(Save+0x1E95, 0x01)
        BitNot(Save+0x1E98, 0x01)
        BitOr(Save+0x1E9B, 0x10)
        BitOr(Save+0x1E9C, 0x04)
        WriteByte(Save+0x1E9F, 0x09)
        WriteInt(Save+0x2060, 0xC1C2C1C1)
        WriteByte(Save+0x2397, 0x0E)
    end
    if ReadShort(Now+0x00) == 0x0E10 and ReadShort(CutLen) == 0x01D6 then --Pre-Gambler Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0E10 and ReadShort(CutLen) == 0x045C then --Post Gambler Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1832, 0x16)
        WriteByte(Save+0x1838, 0x14)
        WriteByte(Save+0x1848, 0x16)
        WriteByte(Save+0x184E, 0x16)
        WriteInt(Save+0x1852, 0x00160000)
        WriteInt(Save+0x1858, 0x00160001)
        WriteByte(Save+0x1860, 0x16)
        WriteInt(Save+0x1864, 0x00160000)
        WriteByte(Save+0x186C, 0x16)
        WriteInt(Save+0x188A, 0x000A000A)
        BitOr(Save+0x1E95, 0x08)
        WriteShort(Save+0x205C, 0x0000)
        BitOr(Save+0x2398, 0x40)
	end
    if ReadInt(Now+0x00) == 0x00000510 and ReadByte(Now+0x38) == 0x3E then --Post Gambler Cutscene 2
        WriteByte(Now+0x02, 0x33)
        WriteByte(Save+0x0E, 0x33)
    end
    if ReadShort(Now+0x00) == 0x0510 and ReadByte(Now+0x08) == 0x0D then --Post Medallion Collection Cutscene
        WriteByte(Now+0x02, 0x33)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x14)
        WriteByte(Save+0x0E, 0x33)
        WriteByte(Save+0x1816, 0x05)
        WriteByte(Save+0x181A, 0x0B)
        WriteByte(Save+0x1832, 0x14)
        WriteByte(Save+0x1838, 0x13)
        WriteByte(Save+0x1848, 0x15)
        WriteByte(Save+0x184E, 0x15)
        WriteByte(Save+0x1854, 0x15)
        WriteByte(Save+0x185A, 0x15)
        WriteByte(Save+0x1860, 0x15)
        WriteByte(Save+0x1866, 0x15)
        WriteByte(Save+0x186C, 0x15)
        BitOr(Save+0x1E95, 0x20)
        BitOr(Save+0x1E97, 0x20)
        BitNot(Save+0x2398, 0x40)
        BitOr(Save+0x239E, 0x10)
    end
    if ReadShort(Now+0x00) == 0x1810 and ReadByte(Now+0x08) == 0x52 then --Pre-Grim Reaper II Cutscene
        WriteByte(Now+0x01, 0x01)
        WriteInt(Now+0x04, 0x00360036)
        WriteByte(Now+0x08, 0x36)
        WriteByte(Save+0x0D, 0x01)
    end
    if ReadShort(Now+0x00) == 0x0510 and ReadByte(Now+0x08) == 0x13 then --Post Grim Reaper II Cutscene 2
        if ReadByte(Now+0x38) == 0x36 then
            WriteInt(Now+0x00, 0x001E1A04)
            WriteByte(Now+0x08, 0x02)
            WriteInt(Save+0x0C, 0x001E1A04)
        end
    end
    if ReadShort(Now+0x00) == 0x0E12 and ReadShort(CutLen) == 0x00DC then --Post Data Luxord Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x010C and ReadByte(Now+0x08) == 0x35 then --Disney Castle 1st Cutscene
        WriteInt(Now+0x00, 0x0032060C)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x16)
        WriteInt(Save+0x0C, 0x0032060C)
        WriteShort(Save+0x3565, 0x0201)
        WriteByte(Save+0x1226, 0x01)
        WriteByte(Save+0x1238, 0x16)
        BitOr(Save+0x1E10, 0x04)
        BitOr(Save+0x1E12, 0x01)
        WriteByte(Save+0x1E1F, 0x01)
    end
    if ReadShort(Now+0x00) == 0x030C and ReadShort(CutLen) == 0x022C then --DC Courtyard Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x010C and ReadShort(CutLen) == 0x0C6C then --Meeting Queen Minnie Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x020C and ReadShort(CutLen) == 0x0350 then --Post Minnie Escort 1 Cutscene
        WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x000C and ReadShort(CutLen) == 0x0155 then --Pre-Minnie Escort 2 Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x000C and ReadShort(CutLen) == 0x07C5 then --Post Minnie Escort 2 Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x672,ReadByte(Save+0x662))
	end
    if ReadShort(Now+0x00) == 0x040C and ReadShort(CutLen) == 0x0EC2 then --Post Minnie Escort 2 Cutscene 2
        WriteByte(CutSkp, 0x01)
        if ReadByte(Save+0x365D) == 0x01 then
            WriteByte(Save+0x1228, 0x01)
            WriteByte(Save+0x122C, 0x16)
            WriteByte(Save+0x1238, 0x14)
        end
	end
    if ReadInt(Now+0x00) == 0x0032040C and ReadByte(Now+0x08) == 0x04 then --Before Start of TR in DC
        WriteByte(Now+0x02, 0x33)
        WriteByte(Now+0x04, 0x0002)
        WriteByte(Now+0x08, 0x0003)
        WriteInt(Save+0x0E, 0x33)
        WriteByte(Save+0x1228, 0x02)
        WriteByte(Save+0x122C, 0x03)
        WriteByte(Save+0x1238, 0x13)
        BitOr(Save+0x1D26, 0x01)
        BitOr(Save+0x1E11, 0x10)
        BitOr(Save+0x1E12, 0x02)
        WriteByte(Save+0x1E1F, 0x03)
        WriteByte(Save+0x662,ReadByte(Save+0x672))
    end
    if ReadShort(Now+0x00) == 0x1A04 and ReadByte(Save+0x122C) == 0x04 then --Before Start of TR in GoA
        if ReadByte(Save+0x365D) >= 0x02 then
            WriteByte(Save+0x1228, 0x02)
            WriteByte(Save+0x122C, 0x03)
            WriteInt(Save+0x1238, 0x00010013)
            BitOr(Save+0x1D26, 0x01)
            BitOr(Save+0x1E11, 0x10)
            BitOr(Save+0x1E12, 0x02)
            WriteByte(Save+0x1E1F, 0x03)
            WriteByte(Save+0x662,ReadByte(Save+0x672))
        end
    end
    if ReadInt(Now+0x00) == 0x0063040C and ReadByte(Save+0x123A) == 0x01 then --Correct Spawn from GoA
        WriteByte(Now+0x02, 0x33)
        WriteByte(Save+0x123A, 0x00)
    end
    if ReadInt(Now+0x00) == 0x0033040C and ReadByte(Save+0x672) > 0 then --Clear Copied Flag for Merlin's House
        WriteByte(Save+0x672, 0x00)
    end
    if ReadShort(Now+0x00) == 0x040C and ReadShort(CutLen) == 0x0187 then --Entering Timeless River Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1390, 0x01)
        WriteInt(Save+0x1394, 0x00010016)
        WriteByte(Save+0x139A, 0x01)
        BitOr(Save+0x1E30, 0x02)
        BitOr(Save+0x1E34, 0x40)
        WriteInt(Save+0x1FE0, 0x859D859C)
        WriteInt(Save+0x1FE8, 0x859B859A)
	end
    if ReadInt(Now+0x00) == 0x0000000D and ReadByte(Now+0x08) == 0x16 then --Timeless River 1st Cutscene
        if ReadShort(Now+0x30) == 0x040C then
            WriteByte(Now+0x02, 0x32)
            WriteByte(Save+0x0E, 0x32)
        end
    end
    if ReadShort(Now+0x00) == 0x010D and ReadShort(CutLen) == 0x0282 then --Pre-Past Pete Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x010D and ReadShort(CutLen) == 0x0937 then --Post Past Pete Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x1394, 0x15)
        WriteByte(Save+0x139E, 0x01)
        WriteByte(Save+0x13A4, 0x01)
        WriteByte(Save+0x13AC, 0x01)
        WriteByte(Save+0x13B2, 0x01)
        WriteByte(Save+0x13B8, 0x01)
        WriteByte(Save+0x13BE, 0x01)
        BitOr(Save+0x1E30, 0x10)
        WriteShort(Save+0x1FE0, 0x0000)
        WriteShort(Save+0x1FE8, 0x0000)
	end
    if ReadInt(Now+0x00) == 0x0000000D and ReadByte(Now+0x38) == 0x3A then --Post Past Pete Cutscene 2
        WriteByte(Now+0x02, 0x33)
        WriteByte(Save+0x0E, 0x33)
    end
    if ReadShort(Now+0x00) == 0x050D and ReadShort(CutLen) == 0x0322 then
		WriteByte(CutSkp, 0x01) --Pre-Building Site Heartless Cutscene (1st Window)
        WriteByte(Save+0x1E3F, 0x01)
	end
    if ReadShort(Now+0x00) == 0x050D and ReadShort(CutLen) == 0x02D5 then
		BitOr(CutSkp, 0x01) --Pre-Building Site Heartless Cutscene (After 1st Window)
        if ReadByte(Save+0x1E3F) == 0x02 then --2nd Window
            WriteByte(Save+0x1E3F, 0x03)
        end
        if ReadByte(Save+0x1E3F) == 0x04 then --3rd Window
            WriteByte(Save+0x1E3F, 0x05)
        end
        if ReadByte(Save+0x1E3F) == 0x06 then --4th Window
            WriteByte(Save+0x1E3F, 0x07)
        end
	end
    if ReadShort(Now+0x00) == 0x050D and ReadShort(CutLen) == 0x0245 then
		WriteByte(CutSkp, 0x01) --Post Building Site Heartless Cutscene 1
        if ReadByte(Save+0x1E3F) == 0x01 then --1st Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x02)
            WriteByte(Save+0x1E3F, 0x02)
        elseif ReadByte(Save+0x1E3F) == 0x03 then --2nd Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x06)
            WriteByte(Save+0x1E3F, 0x04)
        elseif ReadByte(Save+0x1E3F) == 0x05 then --3rd Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x0E)
            WriteByte(Save+0x1E3F, 0x06)
        end
	end
    if ReadShort(Now+0x00) == 0x050D then --Post Building Site Heartless Cutscene 2
        if ReadByte(ARDEvent+0x276B6) == 0x08 then --Normal
            WriteByte(ARDEvent+0x276B6, 0x00)
            WriteByte(ARDEvent+0x276BC, 0x01)
            if ReadByte(Save+0x1E32) <= 0x0E then
                WriteByte(ARDEvent+0x276B8, 0x35)
            end
        end
        if ReadByte(ARDEvent+0x27672) == 0x08 then
            WriteByte(ARDEvent+0x27672, 0x00)
            WriteByte(ARDEvent+0x27678, 0x01)
            if ReadByte(Save+0x1E32) <= 0x0E then
                WriteByte(ARDEvent+0x27674, 0x35)
            end
        end
    end
    if ReadShort(Now+0x00) == 0x040D and ReadShort(CutLen) == 0x0507 then
		WriteByte(CutSkp, 0x01) --Pre-Lilliput Heartless Cutscene (1st Window)
        WriteByte(Save+0x1E3F, 0x01)
	end
        if ReadShort(Now+0x00) == 0x040D and ReadShort(CutLen) == 0x048E then
		WriteByte(CutSkp, 0x01) --Pre-Lilliput Heartless Cutscene (After 1st Window)
        if ReadByte(Save+0x1E3F) == 0x02 then --2nd Window
            WriteByte(Save+0x1E3F, 0x03)
        end
        if ReadByte(Save+0x1E3F) == 0x04 then --3rd Window
            WriteByte(Save+0x1E3F, 0x05)
        end
        if ReadByte(Save+0x1E3F) == 0x06 then --4th Window
            WriteByte(Save+0x1E3F, 0x07)
        end
	end
    if ReadShort(Now+0x00) == 0x040D and ReadShort(CutLen) == 0x0243 then
		WriteByte(CutSkp, 0x01) --Post Lilliput Heartless Cutscene 1
        if ReadByte(Save+0x1E3F) == 0x01 then --1st Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x02)
            WriteByte(Save+0x1E3F, 0x02)
        elseif ReadByte(Save+0x1E3F) == 0x03 then --2nd Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x06)
            WriteByte(Save+0x1E3F, 0x04)
        elseif ReadByte(Save+0x1E3F) == 0x05 then --3rd Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x0E)
            WriteByte(Save+0x1E3F, 0x06)
        end
	end
    if ReadShort(Now+0x00) == 0x040D then --Post Lilliput Heartless Cutscene 2
        if ReadByte(ARDEvent+0x28DAE) == 0x08 then --Normal
            WriteByte(ARDEvent+0x28DAE, 0x00)
            WriteByte(ARDEvent+0x28DB4, 0x01)
            if ReadByte(Save+0x1E32) <= 0x0E then
                WriteByte(ARDEvent+0x28DB0, 0x35)
            end
        end
        if ReadByte(ARDEvent+0x28D3E) == 0x08 then --Boss/Enemy
            WriteByte(ARDEvent+0x28D3E, 0x00)
            WriteByte(ARDEvent+0x28D44, 0x01)
            if ReadByte(Save+0x1E32) <= 0x0E then
                WriteByte(ARDEvent+0x28D40, 0x35)
            end
        end
    end
    if ReadShort(Now+0x00) == 0x060D and ReadShort(CutLen) == 0x0255 then
		WriteByte(CutSkp, 0x01) --Pre-Scene of the Fire Heartless Cutscene (1st Window)
        WriteByte(Save+0x1E3F, 0x01)
	end
    if ReadShort(Now+0x00) == 0x060D and ReadShort(CutLen) == 0x0219 then
		WriteByte(CutSkp, 0x01) --Pre-Scene of the Fire Heartless Cutscene (After 1st Window)
        if ReadByte(Save+0x1E3F) == 0x02 then --2nd Window
            WriteByte(Save+0x1E3F, 0x03)
        end
        if ReadByte(Save+0x1E3F) == 0x04 then --3rd Window
            WriteByte(Save+0x1E3F, 0x05)
        end
        if ReadByte(Save+0x1E3F) == 0x06 then --4th Window
            WriteByte(Save+0x1E3F, 0x07)
        end
	end
    if ReadShort(Now+0x00) == 0x060D and ReadShort(CutLen) == 0x02E3 then
		WriteByte(CutSkp, 0x01) --Post Scene of the Fire Heartless Cutscene 1
        if ReadByte(Save+0x1E3F) == 0x01 then --1st Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x02)
            WriteByte(Save+0x1E3F, 0x02)
        elseif ReadByte(Save+0x1E3F) == 0x03 then --2nd Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x06)
            WriteByte(Save+0x1E3F, 0x04)
        elseif ReadByte(Save+0x1E3F) == 0x05 then --3rd Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x0E)
            WriteByte(Save+0x1E3F, 0x06)
        end
	end
    if ReadShort(Now+0x00) == 0x060D then --Post Scene of the Fire Heartless Cutscene 2
        if ReadByte(ARDEvent+0x2926E) == 0x08 then --Normal
            WriteByte(ARDEvent+0x2926E, 0x00)
            WriteByte(ARDEvent+0x29274, 0x01)
            if ReadByte(Save+0x1E32) <= 0x0E then
                WriteByte(ARDEvent+0x29270, 0x35)
            end
        end
        if ReadByte(ARDEvent+0x29212) == 0x08 then --Boss/Enemy
            WriteByte(ARDEvent+0x29212, 0x00)
            WriteByte(ARDEvent+0x29218, 0x01)
            if ReadByte(Save+0x1E32) <= 0x0E then
                WriteByte(ARDEvent+0x29214, 0x35)
            end
        end
    end
    if ReadShort(Now+0x00) == 0x070D and ReadShort(CutLen) == 0x023E then
		WriteByte(CutSkp, 0x01) --Pre-Mickey's House Heartless Cutscene
        if ReadByte(Save+0x1E3F) == 0x00 then --1st Window
            WriteByte(Save+0x1E3F, 0x01)
        end
        if ReadByte(Save+0x1E3F) == 0x02 then --2nd Window
            WriteByte(Save+0x1E3F, 0x03)
        end
        if ReadByte(Save+0x1E3F) == 0x04 then --3rd Window
            WriteByte(Save+0x1E3F, 0x05)
        end
        if ReadByte(Save+0x1E3F) == 0x06 then --4th Window
            WriteByte(Save+0x1E3F, 0x07)
        end
	end
    if ReadShort(Now+0x00) == 0x070D and ReadShort(CutLen) == 0x01E4 then
		WriteByte(CutSkp, 0x01) --Post Mickey's House Heartless Cutscene 1
        if ReadByte(Save+0x1E3F) == 0x01 then --1st Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x02)
            WriteByte(Save+0x1E3F, 0x02)
        elseif ReadByte(Save+0x1E3F) == 0x03 then --2nd Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x06)
            WriteByte(Save+0x1E3F, 0x04)
        elseif ReadByte(Save+0x1E3F) == 0x05 then --3rd Window Done
            WriteByte(Save+0x1394, 0x12)
            WriteByte(Save+0x1E32, 0x0E)
            WriteByte(Save+0x1E3F, 0x06)
        end
	end
    if ReadShort(Now+0x00) == 0x070D then --Post Mickey's House Heartless Cutscene 2
        if ReadByte(ARDEvent+0x29D5E) == 0x08 then --Normal
            WriteByte(ARDEvent+0x29D5E, 0x00)
            WriteByte(ARDEvent+0x29D64, 0x01)
            if ReadByte(Save+0x1E32) < 0x0E then
                WriteByte(ARDEvent+0x29D60, 0x35)
            end
        end
        if ReadByte(ARDEvent+0x29D32) == 0x08 then --Boss/Enemy
            WriteByte(ARDEvent+0x29D32, 0x00)
            WriteByte(ARDEvent+0x29D38, 0x01)
            if ReadByte(Save+0x1E32) < 0x0E then
                WriteByte(ARDEvent+0x29D34, 0x35)
            end
        end
    end
    if ReadShort(Now+0x00) == 0x000D then --Cornerstone Hill Cutscenes
        if ReadByte(ARDEvent+0x1CC40) == 0x03 then --Normal
            WriteByte(ARDEvent+0x1CC40, 0x02)
        end
        if ReadByte(ARDEvent+0x1D364) == 0x03 then --Boss/Enemy
            WriteByte(ARDEvent+0x1D364, 0x02)
        end
        if ReadShort(CutLen) == 0x0752 then --Post Windows of Time Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x1E3F, 0x00)
        end
    end
    if ReadShort(Now+0x00) == 0x020D then --Waterway Cutscenes
        if ReadShort(CutLen) == 0x0239 or ReadShort(CutLen) == 0x039D then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0252 then --Post Wharf Pete Cutscene 2
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x1210, 0x04)
            WriteByte(Save+0x1232, 0x01)
            WriteByte(Save+0x1390, 0x03)
            WriteInt(Save+0x1394, 0x00020013)
            WriteInt(Save+0x139C, 0x000A0000)
            WriteByte(Save+0x13A2, 0x01)
            BitOr(Save+0x1E11, 0x40)
            BitOr(Save+0x1E33, 0x08)
        end
	end
    if ReadShort(Now+0x00) == 0x030D then --Wharf Cutscenes
        if ReadShort(CutLen) == 0x0247 or ReadShort(CutLen) == 0x094F then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadInt(Now+0x00) == 0x0000000D and ReadByte(Now+0x38) == 0x35 then --Post Wharf Pete Cutscene 3
        WriteShort(Now+0x00, 0x050C)
        WriteByte(Now+0x04, 0x00)
        WriteByte(Now+0x08, 0x01)
        WriteShort(Save+0x0C, 0x050C)
    end
    if ReadShort(Now+0x00) == 0x050C then --Hall of the Cornerstone (Light) Cutscenes
        if ReadByte(ARDEvent+0x24FD4) == 0x43 then --Normal & Boss/Enemy
            WriteByte(ARDEvent+0x24FD4, 0x02)
        end
        if ReadShort(CutLen) == 0x15C2 then --End of Disney Castle Cutscene
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x02 then --Lingering Will's Portal Cutscene
            WriteInt(Now+0x02, 0x00010000)
            WriteByte(Now+0x08, 0x15)
            WriteByte(Save+0x0E, 0x00)
            WriteByte(Save+0x122E, 0x01)
            WriteByte(Save+0x1232, 0x15)
            BitOr(Save+0x1E14, 0x02)
        end
    end
    if ReadShort(Now+0x00) == 0x2604 then --Marluxia Cutscenes
        if ReadByte(Now+0x08) == 0x7E then --Pre-AS Marluxia Cutscene
            WriteInt(Now+0x04, 0x00910091)
            WriteByte(Now+0x08, 0x91)
        end
        if ReadShort(CutLen) == 0x0125 or ReadShort(CutLen) == 0x00DC then --Post Marluxia Cutscenes
            if ReadShort(CutNow) >= 0x0002 then
                WriteByte(CutSkp, 0x01)
            end
        end
        if ReadByte(Now+0x08) == 0x88 then --Pre-Data Marluxia Cutscene
            WriteInt(Now+0x04, 0x00960096)
            WriteByte(Now+0x08, 0x96)
        end
	end
    if ReadShort(Now+0x00) == 0x070C then --Lingering Will Cutscenes
        if ReadByte(Now+0x08) == 0x44 then --Pre-Lingering Will Cutscene (1st Fight)
            WriteInt(Now+0x04, 0x00430043)
            WriteByte(Now+0x08, 0x43)
        end
        if ReadShort(CutLen) == 0x02EC or ReadShort(CutLen) == 0x016E then --Post Lingering Will Cutscenes
            if ReadShort(CutNow) >= 0x0002 then
                WriteByte(CutSkp, 0x01)
            end
        end
        if ReadByte(Now+0x08) == 0x46 then --Pre-Lingering Will Cutscene (Rematch)
            WriteInt(Now+0x04, 0x00490049)
            WriteByte(Now+0x08, 0x49)
        end
    end
    if ReadShort(Now+0x00) == 0x0111 then --Canyon Cutscenes
        if ReadByte(Now+0x08) == 0x01 then --Space Paranoids 1 1st Cutscene
            WriteShort(Now+0x01, 0x3400)
            WriteInt(Now+0x04, 0x00010000)
            WriteByte(Now+0x08, 0x02)
            WriteShort(Save+0x0D, 0x3400)
            WriteShort(Save+0x3579, 0x0201)
            WriteInt(Save+0x1992, 0x00020001)
            WriteByte(Save+0x199A, 0x00)
            BitOr(Save+0x1EB0, 0x06)
            BitOr(Save+0x1EB5, 0x80)
            WriteByte(Save+0x1EBF, 0x01)
        end
        if ReadShort(CutLen) == 0x01E0 or ReadShort(CutLen) == 0x0851 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x0A then --Space Paranoids 2 1st Cutscene
            WriteShort(Now+0x01, 0x3700)
            WriteByte(Now+0x04, 0x03)
            WriteByte(Now+0x08, 0x0B)
            WriteShort(Save+0x0D, 0x3700)
            WriteInt(Save+0x3578, 0x12020100)
            WriteByte(Save+0x1994, 0x0B)
            WriteInt(Save+0x1998, 0x0000000A)
            WriteByte(Save+0x19A0, 0x0A)
            WriteByte(Save+0x19A4, 0x0A)
            WriteByte(Save+0x19AA, 0x0A)
            WriteByte(Save+0x19B6, 0x0A)
            BitOr(Save+0x1EB2, 0x60)
            BitOr(Save+0x1EB5, 0x01)
            BitOr(Save+0x1EB6, 0x04)
            WriteByte(Save+0x1EBF, 0x05)
            WriteInt(Save+0x210C, 0xC97DC97C)
            BitOr(Save+0x2398, 0x10)
        end
    end
    if ReadShort(Now+0x00) == 0x0011 then --Pit Cell Cutscenes
        if ReadShort(CutLen) == 0x0535 or ReadShort(CutLen) == 0x0186 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x03F7 then --Post Game Grid Heartless Cutscene
            if ReadShort(CutNow) >= 0x0002 then
                WriteByte(CutSkp, 0x01)
            end
        end
	end
    if ReadShort(Now+0x00) == 0x0311 then --Dataspace Cutscenes
        if ReadShort(CutLen) == 0x0694 or ReadShort(CutLen) == 0x0985 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0511 then --I/O Tower: Communications Room Cutscenes
        if ReadShort(CutLen) == 0x02CB or ReadShort(CutLen) == 0x05CC or ReadShort(CutLen) == 0x0B64 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0411 and ReadShort(CutLen) == 0x0649 then --Pre-Hostile Program Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0411 and ReadShort(CutLen) == 0x01CC then --Post Hostile Program Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x19AA, 0x02)
        WriteByte(Save+0x19B2, 0x03)
        BitOr(Save+0x1EB2, 0x04)
        WriteInt(Save+0x210C, 0xB6B5B6B4)
        WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
        WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
        WriteShort(Save+0x24FC, 0x0000)
        WriteShort(Save+0x3524, 0x0000)
        WriteByte(Save+0x3528, 0x64)
        WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        WriteByte(Save+0x2608,ReadByte(Save+0x2609))
        WriteByte(Save+0x260A,ReadByte(Save+0x260B))
        WriteByte(Save+0x271C,ReadByte(Save+0x271D))
        WriteByte(Save+0x271E,ReadByte(Save+0x271F))
        if ReadShort(Save+0x3579) == 0x0103 or ReadShort(Save+0x3579) == 0x0301 then
            WriteInt(Save+0x3578, 0x12020100)
        elseif ReadShort(Save+0x3579) == 0x0203 or ReadShort(Save+0x3579) == 0x0302 then
            WriteInt(Save+0x3578, 0x12010200)
        elseif ReadByte(Save+0x357B) == 0x03 then
            WriteByte(Save+0x357B, 0x12)
        end
	end
    if ReadInt(Now+0x00) == 0x00000511 and ReadByte(Now+0x38) == 0x37 then --Post Hostile Program Cutscene 2
        WriteByte(Now+0x02, 0x33)
        WriteByte(Save+0x0E, 0x33)
    end
    if ReadShort(Now+0x00) == 0x0211 and ReadByte(Now+0x08) == 0x0A then --Game Grid Heartless
        WriteInt(Now+0x04, 0x00350035)
        WriteByte(Now+0x08, 0x35)
        WriteByte(Save+0x1994, 0x00)
        WriteByte(Save+0x19A0, 0x00)
        BitOr(Save+0x1EB2, 0x80)
    end
    if ReadShort(Now+0x00) == 0x0411 and ReadByte(Now+0x08) == 0x0A then --I/O Tower: Hallway Heartless
        WriteInt(Now+0x04, 0x00380038)
        WriteByte(Now+0x08, 0x38)
        WriteByte(Save+0x199A, 0x00)
        WriteByte(Save+0x19AC, 0x00)
        BitOr(Save+0x1EB3, 0x04)
    end
    if ReadShort(Now+0x00) == 0x0A11 and ReadShort(CutLen) == 0x02F0 then --Pre-Solar Sailer Heartless Cutscene
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x19BA, 0x01)
        WriteByte(Save+0x19BE, 0x00)
        BitOr(Save+0x1EB3, 0x40)
	end
    if ReadShort(Now+0x00) == 0x0711 and ReadByte(Now+0x38) == 0x0A then --Solar Sailer Heartless
        if ReadByte(Now+0x04) == 0x01 then
            WriteInt(Now+0x04, 0x00390039)
            WriteByte(Now+0x08, 0x39)
        end
    end
    if ReadShort(Now+0x00) == 0x0811 and ReadByte(Now+0x08) == 0x0A then --Before Sark & MCP
        WriteByte(Now+0x02, 0x33)
        WriteByte(Now+0x04, 0x00)
        WriteByte(Now+0x06, 0x00)
        WriteByte(Now+0x08, 0x16)
        WriteByte(Save+0x0E, 0x33)
        WriteByte(Save+0x19C4, 0x16)
        WriteByte(Save+0x19CA, 0x0A)
        BitOr(Save+0x1EB4, 0x01)
        WriteByte(Save+0x1EBF, 0x07)
        BitOr(Save+0x2394, 0x80)
    end
    if ReadShort(Now+0x00) == 0x0911 then --Central Computer Core Cutscenes
        if ReadShort(CutLen) == 0x03D4 or ReadShort(CutLen) == 0x0AC5 or ReadShort(CutLen) == 0x1175 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x0102 and ReadByte(Now+0x08) == 0x34 then --Simulated Twilight Town 1st Cutscene
        WriteInt(Now+0x00, 0x00000702)
        WriteInt(Now+0x04, 0x005F005F)
        WriteByte(Now+0x08, 0x5F)
        WriteInt(Save+0x0C, 0x00000702)
        BitOr(Save+0x1CD2, 0x40)
        BitOr(Save+0x1CD3, 0x07)
    end
    if ReadShort(Now+0x00) == 0x0702 then --Market Street: Tram Common Cutscenes
        if ReadByte(Now+0x08) == 0x5F then --1st Tutorial
            if ReadShort(Save+0x20E8) == 0x0000 then
                WriteInt(Save+0x20DC, 0x9F539F40)
                WriteInt(Save+0x20E0, 0x9F519F3E)
                WriteInt(Save+0x20E6, 0x9F419F55)
                WriteInt(Save+0x20EA, 0x9F3F9F54)
                WriteShort(Save+0x20EE, 0x9F52)
            end
        end
        if ReadShort(CutLen) == 0x01C2 then --Post 1st Tutorial Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x33E, 0x00)
            BitOr(Save+0x1CD3, 0x10)
        end
        if ReadByte(Now+0x38) == 0x5F then --Post 1st Tutorial
            if ReadByte(Now+0x08) == 0x00 then
                WriteInt(Now+0x04, 0x00610061)
                WriteByte(Now+0x08, 0x61)
            end
        end
        if ReadShort(CutLen) == 0x016D then --Post 2nd Tutorial Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x33E, 0x00)
            BitOr(Save+0x1CD3, 0x40)
        end
        if ReadByte(Now+0x38) == 0x61 then --Post 2nd Tutorial
            if ReadByte(Now+0x08) == 0x00 then
                WriteInt(Now+0x04, 0x00630063)
                WriteByte(Now+0x08, 0x63)
            end
        end
        if ReadShort(CutLen) == 0x02D3 then --Post 3rd Tutorial Cutscene
            WriteByte(CutSkp, 0x01)
            BitOr(Save+0x1CD4, 0x01)
        end
        if ReadShort(CutLen) == 0x00A0 or ReadShort(CutLen) == 0x00BE then --Post Tram Common Minigames Cutscene
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x38) == 0x15 then --Pre-Sandlot Dusk Cutscene 2
            if ReadShort(Now+0x30) == 0x0302 then
                WriteByte(Now+0x01, 0x04)
                WriteInt(Now+0x04, 0x004F004F)
                WriteByte(Now+0x08, 0x4F)
                WriteByte(Save+0x0D, 0x04)
            end
        end
    end
    if ReadShort(Now+0x00) == 0x0D02 and ReadByte(Now+0x08) == 0x7E then --Post Seifer Cutscene 2
        WriteInt(Now+0x02, 0x00010032)
        WriteInt(Now+0x06, 0x00160001)
        WriteByte(Save+0x0E, 0x32)
    end
    if ReadShort(Now+0x00) == 0x0202 and ReadByte(Now+0x08) == 0x40 then --Post Old Mansion Dusk Cutscene 2
        WriteInt(Now+0x02, 0x00020033)
        WriteInt(Now+0x06, 0x00020002)
        WriteByte(Save+0x0E, 0x33)
    end
    if ReadShort(Now+0x00) == 0x0202 and ReadShort(CutLen) == 0x0140 then --Post Save Point Tutorial Cutscene 1
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0602 then --Market Street: Station Heights Cutscenes
        if ReadShort(CutLen) == 0x080E or ReadShort(CutLen+0x00) == 0x009D or ReadShort(CutLen+0x00) == 0x009C or ReadShort(CutLen+0x00) == 0x009E or ReadShort(CutLen+0x00) == 0x00A5 or ReadShort(CutLen+0x00) == 0x00AF or ReadShort(CutLen+0x00) == 0x00B4 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0783 then --Pre-Sandlot Dusk Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x326, 0x00)
            WriteByte(Save+0x32C, 0x00)
            WriteByte(Save+0x338, 0x00)
            WriteByte(Save+0x33E, 0x00)
            WriteByte(Save+0x362, 0x00)
            BitOr(Save+0x1CD8, 0x38)
            WriteShort(Save+0x20EC, 0x0000)
            WriteShort(Save+0x2014, 0x0000)
            WriteByte(Save+0x1D0E, 0x04)
        end
	end
    if ReadShort(Now+0x00) == 0x2002 then --Post Station of Serenity Dusks Cutscenes
        if ReadShort(CutLen) == 0x015E or ReadShort(CutLen) == 0x02CA then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x2202 and ReadShort(CutLen) == 0x047B then --Pre-Twilight Thorn Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x2202 and ReadShort(CutLen) == 0x01B2 then --Post Twilight Thorn Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x3FF5, 0x04)
        WriteByte(Save+0x322, 0x02)
        WriteByte(Save+0x326, 0x06)
        WriteInt(Save+0x332, 0x00020002)
        WriteInt(Save+0x338, 0x00020014)
        WriteByte(Save+0x33E, 0x14)
        WriteByte(Save+0x344, 0x14)
        WriteByte(Save+0x34A, 0x14)
        WriteByte(Save+0x362, 0x14)
        WriteByte(Save+0x368, 0x14)
        BitOr(Save+0x1CD9, 0xE0)
        BitOr(Save+0x1CDA, 0xFF)
        WriteByte(Save+0x1D0E, 0x05)
        WriteInt(Save+0x20E8, 0xC543C542)
        WriteInt(Save+0x2114, 0xC4A1C44E)
        WriteShort(Save+0x3524, 0x0000)
        WriteByte(Save+0x3528, 0x64)
        WriteByte(Save+0x3529,ReadByte(Save+0x352A))
	end
    if ReadShort(Now+0x00) == 0x0002 and ReadByte(Now+0x08) == 0x33 then --Post Twilight Thorn Cutscene 2
        WriteShort(Now+0x01, 0x3205)
        WriteInt(Now+0x04, 0x00000000)
        WriteByte(Now+0x08, 0x02)
        WriteShort(Save+0x0D, 0x3205)
    end
    if ReadShort(Now+0x00) == 0x0502 then --Sandlot (Struggle Tournament) Cutscenes
        if ReadShort(CutLen) == 0x011C or ReadShort(CutLen) == 0x05EF or ReadShort(CutLen) == 0x1209 or ReadShort(CutLen) == 0x02A3 or ReadShort(CutLen) == 0x0412 or ReadShort(CutLen) == 0x0C24 or ReadShort(CutLen) == 0x0A65 or ReadShort(CutLen) == 0x069B then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0516 or ReadShort(CutLen) == 0x05E8 then --Post Setzer Cutscene 1
            WriteByte(Save+0x3FF5, 0x05)
            WriteByte(CutSkp, 0x01)
            WriteInt(Save+0x320, 0x0001000C)
            WriteByte(Save+0x326, 0x13)
            WriteByte(Save+0x32C, 0x13)
            WriteByte(Save+0x334, 0x02)
            WriteInt(Save+0x338, 0x00010011)
            WriteByte(Save+0x33E, 0x14)
            WriteByte(Save+0x344, 0x0F)
            WriteInt(Save+0x348, 0x000C0016)
            BitOr(Save+0x1CDC, 0xF8)
            BitOr(Save+0x1CDD, 0x07)
            WriteByte(Save+0x1D0E, 0x06)
            WriteShort(Save+0x20E8, 0x0000)
            WriteShort(Save+0x2114, 0x0000)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        end
	end
    if ReadShort(Now+0x00) == 0x0902 and ReadShort(CutLen) == 0x039D then --Pre-Seven Wonders Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x346, 0x02)
        WriteInt(Save+0x34A, 0x00020013)
        WriteInt(Save+0x34E, 0x000D0016)
        WriteByte(Save+0x352, 0x01)
        WriteInt(Save+0x356, 0x00030013)
        WriteByte(Save+0x35C, 0x01)
        BitOr(Save+0x1CDD, 0xF0)
        BitOr(Save+0x1CDE, 0x07)
        BitOr(Save+0x1CED, 0x01)
        BitOr(Save+0x1CEF, 0x80)
        WriteShort(Save+0x207C, 0x0000)
        WriteShort(Save+0x2112, 0xB792)
        WriteByte(Save+0x2394, 0x1E)
	end
    if ReadShort(Now+0x00) == 0x1802 and ReadByte(Now+0x08) == 0x94 then --Pre-Seven Wonders Cutscene 2
        WriteShort(Now+0x01, 0x320B)
        WriteInt(Now+0x04, 0x00000001)
        WriteByte(Now+0x08, 0x13)
        WriteShort(Save+0x0D, 0x320B)
    end
    if ReadShort(Now+0x00) == 0x0C02 and ReadShort(CutLen) == 0x1018 then --Post Seven Wonders Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x32C, 0x0E)
        WriteByte(Save+0x338, 0x0E)
        WriteByte(Save+0x344, 0x11)
        WriteByte(Save+0x368, 0x02)
        BitOr(Save+0x1CDE, 0x30)
        WriteByte(Save+0x1D0E, 0x09)
        WriteInt(Save+0x2080, 0xC545C544)
	end
    if ReadShort(Now+0x00) == 0x0B02 and ReadByte(Now+0x08) == 0x7C then --Post Seven Wonders Cutscene 1
        WriteShort(Now+0x01, 0x3408)
        WriteInt(Now+0x04, 0x00000001)
        WriteByte(Now+0x08, 0x11)
        WriteShort(Save+0x0D, 0x3408)
    end
    if ReadShort(Now+0x00) == 0x1202 and ReadByte(Now+0x08) == 0x84 then --End of Day 5 Cutscene 2
        WriteShort(Now+0x01, 0x3202)
        WriteInt(Now+0x04, 0x00000001)
        WriteByte(Now+0x08, 0x00)
        WriteShort(Save+0x0D, 0x3202)
    end
    if ReadShort(Now+0x00) == 0x1202 and ReadByte(Now+0x08) == 0x01 then --Entering Namine's Room Cutscene 1
        WriteInt(Now+0x04, 0x00850085)
        WriteByte(Now+0x08, 0x85)
        WriteByte(Save+0x380, 0x00)
        BitOr(Save+0x1CE0, 0x20)
    end
    if ReadShort(Now+0x00) == 0x1202 and ReadShort(CutLen) == 0x0EF3 then --Entering Namine's Room Cutscene 3
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1102 and ReadShort(CutLen) == 0x0442 then --Using Namine's Sketches Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x0012 and ReadByte(Now+0x08) == 0x33 then --Entering Computer Room Cutscene 2
        WriteInt(Now+0x00, 0x00321502)
        WriteInt(Now+0x04, 0x00000002)
        WriteByte(Now+0x08, 0x00)
        WriteInt(Save+0x0C, 0x00321502)
    end
    if ReadShort(Now+0x00) == 0x1602 and ReadShort(CutLen) == 0x0272 then --After Axel II Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x1702 then --Mansion: Pod Room
        if ReadShort(CutLen) == 0x0AB0 then --End of STT Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x39A, 0x0D)
            WriteByte(Save+0x39E, 0x00)
            BitOr(Save+0x1CE2, 0x06)
            WriteByte(Save+0x1CFE, 0x05)
            WriteByte(Save+0x24F4,ReadByte(Save+0x24F5))
            WriteByte(Save+0x24F6,ReadByte(Save+0x24F7))
            WriteShort(Save+0x24FC, 0x0000)
            WriteShort(Save+0x3524, 0x0000)
            WriteByte(Save+0x3528, 0x64)
            WriteByte(Save+0x3529,ReadByte(Save+0x352A))
        end
        if ReadByte(Now+0x04) == 0x0D then --End of STT Cutscene 2
            if ReadShort(Now+0x31) == 0x3216 then
                WriteInt(Now+0x00, 0x00211A04)
                WriteByte(Now+0x04, 0x00)
                WriteByte(Now+0x08, 0x02)
                WriteInt(Save+0x0C, 0x00211A04)
            end
        end
        if ReadShort(ARDEvent+0x20E84) == 0xFFFF then
            WriteShort(ARDEvent+0x20E84, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x1512 and ReadShort(CutLen) == 0x00DC then --Post Data Roxas Cutscene
        if ReadShort(CutNow) >= 0x0002 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x1512 and ReadByte(Now+0x08) == 0x71 then --Data Roxas (1 Hour)
        if ReadShort(Now+0x30) == 0x1A04 then
            WriteInt(Now+0x04, 0x00630063)
            WriteByte(Now+0x08, 0x63)
        end
    end
    if ReadShort(Now+0x00) == 0x0009 and ReadByte(Now+0x08) == 0x03 then --Before Piglet's House Cutscene
		WriteInt(Now+0x02, 0x00040033)
        WriteByte(Now+0x08, 0x00)
        WriteByte(Save+0x0E, 0x33)
        WriteByte(Save+0xD90, 0x04)
        WriteByte(Save+0xD94, 0x00)
        WriteByte(Save+0xDA0, 0x15)
        WriteByte(Save+0xDAC, 0x01)
        BitOr(Save+0x1DB1, 0x02)
        BitOr(Save+0x1DB7, 0x10)
        WriteByte(Save+0x3598, ReadByte(Save+0x3598)-1)
	end
    if ReadShort(Now+0x00) == 0x0409 then --Piglet's House Cutscenes
        if ReadShort(CutLen) == 0x07B3 or ReadShort(CutLen) == 0x0485 or ReadShort(CutLen) == 0x0064 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x04 then --Post Blustery Rescue Cutscene
            WriteShort(Now+0x00, 0x1A04)
            WriteInt(Now+0x04, 0x00000000)
            WriteByte(Now+0x08, 0x02)
            WriteShort(Save+0x0C, 0x1A04)
            WriteByte(Save+0xDA0, 0x14)
            WriteByte(Save+0xDAC, 0x14)
            BitOr(Save+0x1DB1, 0x80)
            BitOr(Save+0x1DB6, 0x10)
            BitOr(Save+0x1DB7, 0x40)
            if ReadByte(Save+0x3598) == 0x00 then
                WriteByte(Save+0xD90, 0x05)
            elseif ReadByte(Save+0x3598) > 0x00 then
                WriteByte(Save+0xD90, 0x06)
                WriteByte(Save+0xD94, 0x05)
                BitOr(Save+0x1DB2, 0x01)
                BitOr(Save+0x1DB8, 0x01)
            end
        end
	end
    if ReadShort(Now+0x00) == 0x0009 and ReadByte(Now+0x08) == 0x05 then --Before Rabbit's House Cutscene
		WriteInt(Now+0x02, 0x00070034)
        WriteByte(Now+0x08, 0x00)
        WriteByte(Save+0x0E, 0x34)
        WriteByte(Save+0xD90, 0x07)
        WriteByte(Save+0xD94, 0x00)
        WriteByte(Save+0xDA0, 0x13)
        WriteByte(Save+0xDA6, 0x01)
        WriteByte(Save+0xDAC, 0x13)
        BitOr(Save+0x1DB2, 0x02)
        BitOr(Save+0x1DB7, 0x80)
        WriteByte(Save+0x3598, ReadByte(Save+0x3598)-1)
	end
    if ReadShort(Now+0x00) == 0x0309 then --Rabbit's House Cutscenes
        if ReadShort(CutLen) == 0x0F24 or ReadShort(CutLen) == 0x0AC4 or ReadShort(CutLen) == 0x0064 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x04 then --Post Hunny Slider Cutscene
            WriteShort(Now+0x00, 0x1A04)
            WriteInt(Now+0x04, 0x00000000)
            WriteByte(Now+0x08, 0x02)
            WriteShort(Save+0x0C, 0x1A04)
            WriteByte(Save+0xDA0, 0x12)
            WriteByte(Save+0xDA6, 0x12)
            WriteByte(Save+0xDAC, 0x12)
            BitOr(Save+0x1DB2, 0x80)
            BitOr(Save+0x1DB6, 0x20)
            BitOr(Save+0x1DB9, 0x04)
            if ReadByte(Save+0x3598) == 0x00 then
                WriteByte(Save+0xD90, 0x08)
            elseif ReadByte(Save+0x3598) > 0x00 then
                WriteByte(Save+0xD90, 0x09)
                WriteByte(Save+0xD94, 0x07)
                BitOr(Save+0x1DB3, 0x01)
                BitOr(Save+0x1DB8, 0x08)
            end
        end
	end
    if ReadShort(Now+0x00) == 0x0009 and ReadByte(Now+0x08) == 0x07 then --Before Kanga's House Cutscene
		WriteInt(Now+0x02, 0x000A0035)
        WriteByte(Now+0x08, 0x00)
        WriteByte(Save+0x0E, 0x35)
        WriteByte(Save+0xD90, 0x0A)
        WriteByte(Save+0xD94, 0x00)
        WriteByte(Save+0xDA0, 0x11)
        WriteByte(Save+0xDA6, 0x11)
        WriteByte(Save+0xDAC, 0x11)
        WriteByte(Save+0xDB2, 0x01)
        BitOr(Save+0x1DB3, 0x02)
        BitOr(Save+0x1DB8, 0x04)
        WriteByte(Save+0x3598, ReadByte(Save+0x3598)-1)
	end
    if ReadShort(Now+0x00) == 0x0509 then --Kanga's House Cutscenes
        if ReadShort(CutLen) == 0x0623 or ReadShort(CutLen) == 0x02ED then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x08) == 0x04 then --Post Balloon Bounce Cutscene
            WriteShort(Now+0x00, 0x1A04)
            WriteInt(Now+0x04, 0x00000000)
            WriteByte(Now+0x08, 0x02)
            WriteShort(Save+0x0C, 0x1A04)
            WriteByte(Save+0xDA0, 0x10)
            WriteByte(Save+0xDA6, 0x10)
            WriteByte(Save+0xDAC, 0x10)
            WriteByte(Save+0xDB2, 0x10)
            BitOr(Save+0x1DB3, 0x80)
            BitOr(Save+0x1DB6, 0x40)
            if ReadByte(Save+0x3598) == 0x00 then
                WriteByte(Save+0xD90, 0x0B)
                BitOr(Save+0x1DB8, 0x02)
            elseif ReadByte(Save+0x3598) > 0x00 then
                WriteByte(Save+0xD90, 0x0C)
                WriteByte(Save+0xD94, 0x09)
                BitOr(Save+0x1DB4, 0x01)
                BitOr(Save+0x1DB8, 0x22)
            end
        end
	end
    if ReadShort(Now+0x00) == 0x0809 and ReadShort(CutLen) == 0x0073 then --Lost Balloon Bounce Cutscene
        WriteByte(CutSkp, 0x01)
    end
    if ReadShort(Now+0x00) == 0x0009 and ReadByte(Now+0x08) == 0x09 then --Before Spooky Cave Cutscene
		WriteInt(Now+0x02, 0x000D0036)
        WriteByte(Now+0x08, 0x00)
        WriteByte(Save+0x0E, 0x36)
        WriteByte(Save+0xD90, 0x0D)
        WriteByte(Save+0xD94, 0x00)
        WriteByte(Save+0xDA0, 0x0F)
        WriteByte(Save+0xDA6, 0x0F)
        WriteByte(Save+0xDAC, 0x0F)
        WriteByte(Save+0xDB2, 0x0F)
        WriteByte(Save+0xDCA, 0x01)
        BitOr(Save+0x1DB4, 0x02)
        BitOr(Save+0x1DB8, 0x10)
        WriteByte(Save+0x3598, ReadByte(Save+0x3598)-1)
	end
    if ReadShort(Now+0x00) == 0x0909 then --Spooky Cave Cutscenes
        if ReadShort(CutLen) == 0x0491 or ReadShort(CutLen) == 0x0064 then --Pre-The Expotition Cutscene
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x0BD7 then --Post The Expotition Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0xDA0, 0x0E)
            WriteByte(Save+0xDA6, 0x0E)
            WriteByte(Save+0xDAC, 0x0E)
            WriteByte(Save+0xDB2, 0x0E)
            WriteByte(Save+0xDCA, 0x0E)
            BitOr(Save+0x1DB6, 0x80)
            BitOr(Save+0x1DB8, 0x40)
            WriteShort(Save+0x202C, 0x0000)
            if ReadByte(Save+0x3598) == 0x00 then
                WriteByte(Save+0xD90, 0x0E)
                WriteByte(Save+0xD94, 0x00)
                BitOr(Save+0x1DB8, 0x02)
            elseif ReadByte(Save+0x3598) > 0x00 then
                WriteByte(Save+0xD90, 0x0F)
                WriteByte(Save+0xD94, 0x0B)
                BitOr(Save+0x1DB4, 0x80)
                BitOr(Save+0x1DB9, 0x01)
            end
        end
	end
    if ReadShort(Now+0x00) == 0x0009 and ReadByte(Now+0x38) == 0x3D then --Post The Expotition Cutscene 2
        WriteShort(Now+0x00, 0x1A04)
        WriteByte(Now+0x04, 0x00)
        WriteByte(Now+0x08, 0x02)
        WriteShort(Save+0x0C, 0x1A04)
    end
    if ReadShort(Now+0x00) == 0x0009 and ReadByte(Now+0x08) == 0x0B then --Before Starry Hill Cutscene
		WriteInt(Now+0x02, 0x00100037)
        WriteByte(Now+0x08, 0x00)
        WriteByte(Save+0x0E, 0x37)
        WriteByte(Save+0xD90, 0x10)
        WriteByte(Save+0xD94, 0x00)
        WriteByte(Save+0xD9A, 0x01)
        WriteByte(Save+0xDA0, 0x0D)
        WriteByte(Save+0xDA6, 0x0D)
        WriteByte(Save+0xDAC, 0x0D)
        WriteByte(Save+0xDB2, 0x0D)
        WriteByte(Save+0xDCA, 0x0D)
        BitOr(Save+0x1DB5, 0x01)
        BitOr(Save+0x1DB8, 0x80)
        WriteByte(Save+0x3598, ReadByte(Save+0x3598)-1)
	end
    if ReadShort(Now+0x00) == 0x0109 then --Starry Hill Cutscenes
        if ReadShort(CutLen) == 0x012E or ReadShort(CutLen) == 0x0065 or ReadShort(CutLen) == 0x128A then
            WriteByte(CutSkp, 0x01)
        end
    end
    if ReadShort(Now+0x00) == 0x070B and ReadByte(Now+0x08) == 0x01 then --Atlantica 1st Cutscene
        WriteByte(Now+0x01, 0x02)
        WriteInt(Now+0x04, 0x00340034)
        WriteByte(Now+0x08, 0x34)
        WriteByte(Save+0x0D, 0x02)
        WriteByte(Save+0x109C, 0x01)
        WriteByte(Save+0x10BE, 0x00)
        BitOr(Save+0x1DF0, 0x06)
        BitOr(Save+0x1DF5, 0x80)
        WriteInt(Save+0x209C, 0x857E857D)
    end
    if ReadShort(Now+0x00) == 0x020B then --Undersea Courtyard Cutscenes
        if ReadShort(CutLen) == 0x0356 or ReadShort(CutLen) == 0x00C4 or ReadShort(CutLen) == 0x0106 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadByte(Now+0x04) == 0x05 then --Post Ursula's Revenge Cutscene 3
            if ReadShort(Now+0x30) == 0x020B and ReadShort(Now+0x38) == 0x0A then
                WriteInt(Now+0x00, 0x00011A04)
                WriteByte(Now+0x04, 0x00)
                WriteByte(Now+0x08, 0x02)
                WriteInt(Save+0x0C, 0x00011A04)
            end
        end
	end
    if ReadShort(Now+0x00) == 0x040B then --The Palace: Performance Hall Cutscenes
        if ReadByte(Now+0x08) == 0x01 then --Pre-Swim This Way Cutscene
            WriteInt(Now+0x04, 0x00400040)
            WriteByte(Now+0x08, 0x40)
            BitOr(Save+0x1DF4, 0x08)
        end
        if ReadShort(CutLen) == 0x00C4 or ReadShort(CutLen) == 0x0084 then
            WriteByte(CutSkp, 0x01)
        end
        if ReadShort(CutLen) == 0x07D0 then --Post Swim This Way Cutscene 1
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x109C, 0x02)
            WriteInt(Save+0x10AC, 0x00010000)
            WriteByte(Save+0x10B8, 0x00)
            BitOr(Save+0x1DF1, 0x03)
            WriteShort(Save+0x209C, 0x0000)
            if ReadByte(Save+0x35CF) == 0x00 then
                WriteByte(Save+0x1094, 0x16)
                WriteByte(Save+0x10A0, 0x04)
                BitOr(Save+0x1DF4, 0x20)
                BitOr(Save+0x1DF6, 0x02)
            elseif ReadByte(Save+0x35CF) > 0x00 then
                WriteByte(Save+0x1094, 0x11)
                WriteByte(Save+0x10A0, 0x16)
                BitOr(Save+0x1DF4, 0x60)
                BitOr(Save+0x1DF6, 0x0A)
            end
        end
        if ReadByte(Now+0x08) == 0x02 then --Pre-A New Day is Dawning Cutscene
            WriteInt(Now+0x04, 0x00370037)
            WriteByte(Now+0x08, 0x37)
            WriteByte(Save+0x1094, 0x00)
            WriteByte(Save+0x10B2, 0x00)
            WriteByte(Save+0x10B8, 0x00)
            BitOr(Save+0x1DF4, 0x01)
            BitOr(Save+0x1DF7, 0x1C)
        end
        if ReadShort(CutLen) == 0x0A46 then --Post A New Day is Dawning Cutscene
            WriteByte(CutSkp, 0x01)
            WriteByte(Save+0x10AC, 0x00)
        end
    end
    if ReadShort(Now+0x00) == 0x060B then --The Shore (Day Cutscenes)
        if ReadByte(Now+0x38) == 0x02 or ReadByte(Now+0x38) == 0x15 then --Post Swim This Way Cutscene 2
            if ReadShort(Now+0x30) == 0x020B then
                WriteInt(Now+0x00, 0x00011A04)
                WriteByte(Now+0x08, 0x02)
                WriteInt(Save+0x0C, 0x00011A04)
            end
        end
        if ReadByte(Now+0x08) == 0x03 then --Pre-Ursula's Revenge Cutscene
            WriteShort(Now+0x01, 0x09)
            WriteInt(Now+0x04, 0x00410041)
            WriteByte(Now+0x08, 0x41)
            WriteByte(Save+0x0D, 0x09)
            WriteByte(Save+0x10B2, 0x03)
            BitOr(Save+0x1DF3, 0x2C)
            BitOr(Save+0x1DF5, 0x02)
        end
    end
    if ReadShort(Now+0x00) == 0x050B and ReadByte(Now+0x08) == 0x02 then --Pre-Part of Your World Cutscene
        WriteByte(Now+0x01, 0x01)
        WriteInt(Now+0x04, 0x00330033)
        WriteByte(Now+0x08, 0x33)
        WriteByte(Save+0x0D, 0x01)
        WriteByte(Save+0x1094, 0x00)
        WriteByte(Save+0x10AE, 0x00)
        BitOr(Save+0x1DF1, 0x18)
        BitOr(Save+0x1DF6, 0x04)
    end
    if ReadShort(Now+0x00) == 0x010B and ReadShort(CutLen) == 0x0085 then --Lost Part of Your World Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x010B and ReadShort(CutLen) == 0x020B then --Post Part of Your World Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x109C, 0x03)
        WriteByte(Save+0x10AE, 0x00)
        WriteByte(Save+0x10B8, 0x00)
        BitOr(Save+0x1DF1, 0xC0)
        if ReadByte(MaxDriveGauge+0x00) < 0x05 then
            WriteByte(Save+0x1094, 0x15)
            WriteByte(Save+0x10A0, 0x06)
            BitOr(Save+0x1DF6, 0x10)
        elseif ReadByte(MaxDriveGauge+0x00) > 0x04 then
            WriteByte(Save+0x1094, 0x10)
            WriteByte(Save+0x10A0, 0x15)
            BitOr(Save+0x1DF4, 0x80)
            BitOr(Save+0x1DF6, 0x50)
        end
	end
    if ReadShort(Now+0x00) == 0x000B and ReadByte(Now+0x08) == 0x10 then --Post Part of Your World Cutscene 2
        if ReadShort(Now+0x30) == 0x020B and ReadByte(Now+0x38) == 0x16 then
            WriteInt(Now+0x00, 0x00011A04)
            WriteByte(Now+0x08, 0x02)
            WriteInt(Save+0x0C, 0x00011A04)
        end
    end
    if ReadShort(Now+0x00) == 0x030B and ReadByte(Now+0x08) == 0x01 then --Pre-Under the Sea Cutscene
        WriteInt(Now+0x04, 0x00350035)
        WriteByte(Now+0x08, 0x35)
        WriteByte(Save+0x1094, 0x15)
        WriteByte(Save+0x10B2, 0x00)
        BitOr(Save+0x1DF2, 0x02)
        BitOr(Save+0x1DF6, 0x20)
    end
    if ReadShort(Now+0x00) == 0x030B and ReadShort(CutLen) == 0x0079 then --Lost Under the Sea Cutscene
		WriteByte(CutSkp, 0x01)
	end
    if ReadShort(Now+0x00) == 0x030B and ReadShort(CutLen) == 0x06AE then --Post Under the Sea Cutscene 1
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x109C, 0x04)
        WriteByte(Save+0x10A6, 0x00)
        WriteByte(Save+0x10B8, 0x00)
        BitOr(Save+0x1DF2, 0x08)
        BitOr(Save+0x1DF6, 0x80)
        if ReadByte(Save+0x35CF) < 0x02 then
            WriteByte(Save+0x1094, 0x14)
            WriteByte(Save+0x10A0, 0x07)
        elseif ReadByte(Save+0x35CF) > 0x01 then
            WriteByte(Save+0x1094, 0x0F)
            WriteByte(Save+0x10A0, 0x14)
            BitOr(Save+0x1DF5, 0x01)
            BitOr(Save+0x1DF7, 0x02)
        end
	end
    if ReadShort(Now+0x00) == 0x010B and ReadByte(Now+0x08) == 0x02 then --Before Ursula's Revenge Cutscene
        WriteShort(Now+0x01, 0x3202)
        WriteByte(Now+0x04, 0x04)
        WriteByte(Now+0x08, 0x0A)
        WriteShort(Save+0x0D, 0x3202)
        WriteByte(Save+0x1094, 0x0E)
        WriteByte(Save+0x109A, 0x00)
        WriteByte(Save+0x10A0, 0x0A)
        WriteByte(Save+0x10B8, 0x03)
        BitOr(Save+0x1DF2, 0xE0)
        BitOr(Save+0x1DF3, 0x01)
        BitOr(Save+0x1DF7, 0x01)
    end
    if ReadShort(Now+0x00) == 0x090B then --Wrath of the Sea Cutscenes
        if ReadShort(CutLen) == 0x0056 or ReadShort(CutLen) == 0x05E1 then
            WriteByte(CutSkp, 0x01)
        end
	end
    if ReadShort(Now+0x00) == 0x070B and ReadShort(CutLen) == 0x08A3 then --Post Ursula's Revenge Cutscene 2
		WriteByte(CutSkp, 0x01)
        WriteByte(Save+0x109C, 0x05)
        if ReadByte(Save+0x3596) < 0x03 then
            WriteByte(Save+0x1094, 0x13)
            WriteByte(Save+0x10A0, 0x0C)
            BitOr(Save+0x1DF5, 0x10)
            BitOr(Save+0x1DF7, 0x04)
        elseif ReadByte(Save+0x3596) > 0x02 then
            WriteByte(Save+0x1094, 0x0D)
            WriteByte(Save+0x10A0, 0x13)
            BitOr(Save+0x1DF5, 0x20)
            BitOr(Save+0x1DF7, 0x14)
        end
	end
end