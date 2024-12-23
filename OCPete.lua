function _OnInit()
    GameVersion = 0
end

function _OnFrame()

if GameVersion==0 then 
	if ReadString(0x09A92F0,4) == 'KH2J' then --EGS
		Now = 0x0716DF8
		Timer = 0x0ABB290
		GameVersion=1
	end
	if ReadString(0x09A9830,4) == 'KH2J' then --Steam Global 
		Now = 0x0717008
		GameVersion=2
		Timer = 0x0ABB7D0
	end
end
if GameVersion==0 then
	return
end

World  = ReadByte(Now+0x00)
Room   = ReadByte(Now+0x01)
Place  = ReadShort(Now+0x00)
Door   = ReadShort(Now+0x02)
Map    = ReadShort(Now+0x04)
Btl    = ReadShort(Now+0x06)
Evt    = ReadShort(Now+0x08)
PrevPlace = ReadShort(Now+0x30)
if Place == 0x0806 then
	WriteInt(Timer, 0) -- should always keep timer at 23 minutes??
	end
end
