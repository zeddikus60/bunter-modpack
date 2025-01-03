local GameVersion = 0
local canExecute = false

function _OnInit()
  GameVersion = 0
end

function GetVersion() --Define anchor addresses
  if GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
    if ReadString(0x09A70B0 - 0x56454E,4) == 'KH2J' then --EGS 1.0.0.8
      GameVersion = 1
      print('GoA Epic Version 1.0.0.8_WW Detected - 2fmRemoveSwarm')
      Now = 0x0714DB8 - 0x56454E
			RTSwarm = 0x29C4940 - 0x56454E
			canExecute = true
    elseif ReadString(0x09A92F0,4) == 'KH2J' then --EGS 1.0.0.9
			GameVersion = 2
			print('GoA Epic Version 1.0.0.9_WW Detected - 2fmRemoveSwarm')
			Now = 0x716DF8
			RTSwarm = 0x29C6C80
			canExecute = true
		elseif ReadString(0x09A9830,4) == 'KH2J' then --Steam Global
			GameVersion = 3
			print('GoA Steam Global Version Detected - 2fmRemoveSwarm')
			Now = 0x717008
			RTSwarm = 0x29C7380
			canExecute = true
		elseif ReadString(0x09A8830,4) == 'KH2J' then --Steam JP
			GameVersion = 4
			print('GoA Steam JP Version Detected - 2fmRemoveSwarm')
			Now = 0x716008
			RTSwarm = 0x29C6380
			canExecute = true
		end
	end
end

function _OnFrame()
  if GameVersion == 0 then --Get anchor addresses
    GetVersion()
    return
  end

  if ReadShort(Now+0x00) == 0x0708 then
    if ReadShort(RTSwarm+0x0000) == 0x0557 and ReadShort(RTSwarm+0x0004) == 0x99EC then --Normal (Riku)
      WriteShort(RTSwarm+0x0000, 0x0000)
      WriteShort(RTSwarm+0x0040, 0x0000)
      WriteShort(RTSwarm+0x0080, 0x0000)
      WriteShort(RTSwarm+0x00C0, 0x0000)
      WriteShort(RTSwarm+0x0100, 0x0000)
      WriteShort(RTSwarm+0x0140, 0x0000)
      WriteShort(RTSwarm+0x0180, 0x0000)
      WriteShort(RTSwarm+0x01C0, 0x0000)
      WriteShort(RTSwarm+0x0200, 0x0000)
      WriteShort(RTSwarm+0x0240, 0x0000)
      WriteShort(RTSwarm+0x0280, 0x0000)
      WriteShort(RTSwarm+0x02C0, 0x0000)
      WriteShort(RTSwarm+0x0300, 0x0000)
      WriteShort(RTSwarm+0x0340, 0x0000)
      WriteShort(RTSwarm+0x0380, 0x0000)
      WriteShort(RTSwarm+0x03C0, 0x0000)
      WriteShort(RTSwarm+0x0400, 0x0000)
      WriteShort(RTSwarm+0x0440, 0x0000)
      WriteShort(RTSwarm+0x0480, 0x0000)
      WriteShort(RTSwarm+0x04C0, 0x0000)
      WriteShort(RTSwarm+0x0500, 0x0000)
      WriteShort(RTSwarm+0x0540, 0x0000)
      WriteShort(RTSwarm+0x0580, 0x0000)
      WriteShort(RTSwarm+0x05C0, 0x0000)
      WriteShort(RTSwarm+0x0600, 0x0000)
      WriteShort(RTSwarm+0x0640, 0x0000)
      WriteShort(RTSwarm+0x0680, 0x0000)
      WriteShort(RTSwarm+0x06C0, 0x0000)
      WriteShort(RTSwarm+0x0700, 0x0000)
      WriteShort(RTSwarm+0x0740, 0x0000)
    elseif ReadShort(RTSwarm+0x0080) == 0x0557 and ReadShort(RTSwarm+0x0084) == 0x99EC then --Boss/Enemy 1
      WriteShort(RTSwarm+0x0080, 0x0000) --Armor Xemnas II, Axel (All Versions), Banzai (All Versions), Barrel
      WriteShort(RTSwarm+0x00C0, 0x0000) --Blizzard Lord (All Versions), Cerberus (All Versions)
      WriteShort(RTSwarm+0x0100, 0x0000) --Cloud (All Versions), Dark Thorn, Demyx (All Versions)
      WriteShort(RTSwarm+0x0140, 0x0000) --Ed (All Versions), Final Xemnas (Clone Data), Giant Sark
      WriteShort(RTSwarm+0x0180, 0x0000) --Grim Reaper I, Groundshaker, Hades (All Versions), Hayner, Hercules
      WriteShort(RTSwarm+0x01C0, 0x0000) --Jafar, Larxene (All Versions), Leon (All Versions)
      WriteShort(RTSwarm+0x0200, 0x0000) --Lexaeus (All Versions), Lock, Marluxia (All Versions), Oogie Boogie
      WriteShort(RTSwarm+0x0240, 0x0000) --Past Pete, Pete (OC I), Prison Keeper, Roxas (All Versions)
      WriteShort(RTSwarm+0x0280, 0x0000) --Saix (All Versions), Sark, Scar, Seifer (All Versions), Sephiroth
      WriteShort(RTSwarm+0x02C0, 0x0000) --Setzer, Shenzi (All Versions), Shock, Terra, The Experiment
      WriteShort(RTSwarm+0x0300, 0x0000) --Tifa (All Versions), Twilight Thorn, Vexen (All Versions), Vivi
      WriteShort(RTSwarm+0x0340, 0x0000) --Volcanic Lord (All Versions), Xaldin (All Versions)
      WriteShort(RTSwarm+0x0380, 0x0000) --Xemnas (All Versions), Xigbar (All Versions), Yuffie (All Versions)
      WriteShort(RTSwarm+0x03C0, 0x0000) --Zexion (All Versions)
      WriteShort(RTSwarm+0x0400, 0x0000)
      WriteShort(RTSwarm+0x0440, 0x0000)
      WriteShort(RTSwarm+0x0480, 0x0000)
      WriteShort(RTSwarm+0x04C0, 0x0000)
      WriteShort(RTSwarm+0x0500, 0x0000)
      WriteShort(RTSwarm+0x0540, 0x0000)
      WriteShort(RTSwarm+0x0580, 0x0000)
      WriteShort(RTSwarm+0x05C0, 0x0000)
      WriteShort(RTSwarm+0x0600, 0x0000)
      WriteShort(RTSwarm+0x0640, 0x0000)
      WriteShort(RTSwarm+0x0680, 0x0000)
      WriteShort(RTSwarm+0x06C0, 0x0000)
      WriteShort(RTSwarm+0x0700, 0x0000)
      WriteShort(RTSwarm+0x0740, 0x0000)
      WriteShort(RTSwarm+0x0780, 0x0000)
      WriteShort(RTSwarm+0x07C0, 0x0000)
    elseif ReadShort(RTSwarm+0x00C0) == 0x0557 and ReadShort(RTSwarm+0x00C4) == 0x99EC then --Boss/Enemy 2
      WriteShort(RTSwarm+0x00C0, 0x0000) --Barbossa, Final Xemnas (Normal, Clone Normal, Data), Hostile Program
      WriteShort(RTSwarm+0x0100, 0x0000) --Luxord (All Versions), Shan-Yu, The Beast, Thresholder
      WriteShort(RTSwarm+0x0140, 0x0000)
      WriteShort(RTSwarm+0x0180, 0x0000)
      WriteShort(RTSwarm+0x01C0, 0x0000)
      WriteShort(RTSwarm+0x0200, 0x0000)
      WriteShort(RTSwarm+0x0240, 0x0000)
      WriteShort(RTSwarm+0x0280, 0x0000)
      WriteShort(RTSwarm+0x02C0, 0x0000)
      WriteShort(RTSwarm+0x0300, 0x0000)
      WriteShort(RTSwarm+0x0340, 0x0000)
      WriteShort(RTSwarm+0x0380, 0x0000)
      WriteShort(RTSwarm+0x03C0, 0x0000)
      WriteShort(RTSwarm+0x0400, 0x0000)
      WriteShort(RTSwarm+0x0440, 0x0000)
      WriteShort(RTSwarm+0x0480, 0x0000)
      WriteShort(RTSwarm+0x04C0, 0x0000)
      WriteShort(RTSwarm+0x0500, 0x0000)
      WriteShort(RTSwarm+0x0540, 0x0000)
      WriteShort(RTSwarm+0x0580, 0x0000)
      WriteShort(RTSwarm+0x05C0, 0x0000)
      WriteShort(RTSwarm+0x0600, 0x0000)
      WriteShort(RTSwarm+0x0640, 0x0000)
      WriteShort(RTSwarm+0x0680, 0x0000)
      WriteShort(RTSwarm+0x06C0, 0x0000)
      WriteShort(RTSwarm+0x0700, 0x0000)
      WriteShort(RTSwarm+0x0740, 0x0000)
      WriteShort(RTSwarm+0x0780, 0x0000)
      WriteShort(RTSwarm+0x07C0, 0x0000)
      WriteShort(RTSwarm+0x0800, 0x0000)
    elseif ReadShort(RTSwarm+0x00EC) == 0x0557 and ReadShort(RTSwarm+0x00F0) == 0x99EC then --Pete (OC II)
      WriteShort(RTSwarm+0x00EC, 0x0000)
      WriteShort(RTSwarm+0x012C, 0x0000)
      WriteShort(RTSwarm+0x016C, 0x0000)
      WriteShort(RTSwarm+0x01AC, 0x0000)
      WriteShort(RTSwarm+0x01EC, 0x0000)
      WriteShort(RTSwarm+0x022C, 0x0000)
      WriteShort(RTSwarm+0x026C, 0x0000)
      WriteShort(RTSwarm+0x02AC, 0x0000)
      WriteShort(RTSwarm+0x02EC, 0x0000)
      WriteShort(RTSwarm+0x032C, 0x0000)
      WriteShort(RTSwarm+0x036C, 0x0000)
      WriteShort(RTSwarm+0x03AC, 0x0000)
      WriteShort(RTSwarm+0x03EC, 0x0000)
      WriteShort(RTSwarm+0x042C, 0x0000)
      WriteShort(RTSwarm+0x046C, 0x0000)
      WriteShort(RTSwarm+0x04AC, 0x0000)
      WriteShort(RTSwarm+0x04EC, 0x0000)
      WriteShort(RTSwarm+0x052C, 0x0000)
      WriteShort(RTSwarm+0x056C, 0x0000)
      WriteShort(RTSwarm+0x05AC, 0x0000)
      WriteShort(RTSwarm+0x05EC, 0x0000)
      WriteShort(RTSwarm+0x062C, 0x0000)
      WriteShort(RTSwarm+0x066C, 0x0000)
      WriteShort(RTSwarm+0x06AC, 0x0000)
      WriteShort(RTSwarm+0x06EC, 0x0000)
      WriteShort(RTSwarm+0x072C, 0x0000)
      WriteShort(RTSwarm+0x076C, 0x0000)
      WriteShort(RTSwarm+0x07AC, 0x0000)
      WriteShort(RTSwarm+0x07EC, 0x0000)
      WriteShort(RTSwarm+0x082C, 0x0000)
    elseif ReadShort(RTSwarm+0x0100) == 0x0557 and ReadShort(RTSwarm+0x0104) == 0x99EC then --Grim Reaper II
      WriteShort(RTSwarm+0x0100, 0x0000)
      WriteShort(RTSwarm+0x0140, 0x0000)
      WriteShort(RTSwarm+0x0180, 0x0000)
      WriteShort(RTSwarm+0x01C0, 0x0000)
      WriteShort(RTSwarm+0x0200, 0x0000)
      WriteShort(RTSwarm+0x0240, 0x0000)
      WriteShort(RTSwarm+0x0280, 0x0000)
      WriteShort(RTSwarm+0x02C0, 0x0000)
      WriteShort(RTSwarm+0x0300, 0x0000)
      WriteShort(RTSwarm+0x0340, 0x0000)
      WriteShort(RTSwarm+0x0380, 0x0000)
      WriteShort(RTSwarm+0x03C0, 0x0000)
      WriteShort(RTSwarm+0x0400, 0x0000)
      WriteShort(RTSwarm+0x0440, 0x0000)
      WriteShort(RTSwarm+0x0480, 0x0000)
      WriteShort(RTSwarm+0x04C0, 0x0000)
      WriteShort(RTSwarm+0x0500, 0x0000)
      WriteShort(RTSwarm+0x0540, 0x0000)
      WriteShort(RTSwarm+0x0580, 0x0000)
      WriteShort(RTSwarm+0x05C0, 0x0000)
      WriteShort(RTSwarm+0x0600, 0x0000)
      WriteShort(RTSwarm+0x0640, 0x0000)
      WriteShort(RTSwarm+0x0680, 0x0000)
      WriteShort(RTSwarm+0x06C0, 0x0000)
      WriteShort(RTSwarm+0x0700, 0x0000)
      WriteShort(RTSwarm+0x0740, 0x0000)
      WriteShort(RTSwarm+0x0780, 0x0000)
      WriteShort(RTSwarm+0x07C0, 0x0000)
      WriteShort(RTSwarm+0x0800, 0x0000)
      WriteShort(RTSwarm+0x0840, 0x0000)
    elseif ReadShort(RTSwarm+0x016C) == 0x0557 and ReadShort(RTSwarm+0x0170) == 0x99EC then --MCP
      WriteShort(RTSwarm+0x016C, 0x0000)
      WriteShort(RTSwarm+0x01AC, 0x0000)
      WriteShort(RTSwarm+0x01EC, 0x0000)
      WriteShort(RTSwarm+0x022C, 0x0000)
      WriteShort(RTSwarm+0x026C, 0x0000)
      WriteShort(RTSwarm+0x02AC, 0x0000)
      WriteShort(RTSwarm+0x02EC, 0x0000)
      WriteShort(RTSwarm+0x032C, 0x0000)
      WriteShort(RTSwarm+0x036C, 0x0000)
      WriteShort(RTSwarm+0x03AC, 0x0000)
      WriteShort(RTSwarm+0x03EC, 0x0000)
      WriteShort(RTSwarm+0x042C, 0x0000)
      WriteShort(RTSwarm+0x046C, 0x0000)
      WriteShort(RTSwarm+0x04AC, 0x0000)
      WriteShort(RTSwarm+0x04EC, 0x0000)
      WriteShort(RTSwarm+0x052C, 0x0000)
      WriteShort(RTSwarm+0x056C, 0x0000)
      WriteShort(RTSwarm+0x05AC, 0x0000)
      WriteShort(RTSwarm+0x05EC, 0x0000)
      WriteShort(RTSwarm+0x062C, 0x0000)
      WriteShort(RTSwarm+0x066C, 0x0000)
      WriteShort(RTSwarm+0x06AC, 0x0000)
      WriteShort(RTSwarm+0x06EC, 0x0000)
      WriteShort(RTSwarm+0x072C, 0x0000)
      WriteShort(RTSwarm+0x076C, 0x0000)
      WriteShort(RTSwarm+0x07AC, 0x0000)
      WriteShort(RTSwarm+0x07EC, 0x0000)
      WriteShort(RTSwarm+0x082C, 0x0000)
      WriteShort(RTSwarm+0x086C, 0x0000)
      WriteShort(RTSwarm+0x08AC, 0x0000)
    elseif ReadShort(RTSwarm+0x01C0) == 0x0557 and ReadShort(RTSwarm+0x01C4) == 0x99EC then --Shadow Stalker
      WriteShort(RTSwarm+0x01C0, 0x0000)
      WriteShort(RTSwarm+0x0200, 0x0000)
      WriteShort(RTSwarm+0x0240, 0x0000)
      WriteShort(RTSwarm+0x0280, 0x0000)
      WriteShort(RTSwarm+0x02C0, 0x0000)
      WriteShort(RTSwarm+0x0300, 0x0000)
      WriteShort(RTSwarm+0x0340, 0x0000)
      WriteShort(RTSwarm+0x0380, 0x0000)
      WriteShort(RTSwarm+0x03C0, 0x0000)
      WriteShort(RTSwarm+0x0400, 0x0000)
      WriteShort(RTSwarm+0x0440, 0x0000)
      WriteShort(RTSwarm+0x0480, 0x0000)
      WriteShort(RTSwarm+0x04C0, 0x0000)
      WriteShort(RTSwarm+0x0500, 0x0000)
      WriteShort(RTSwarm+0x0540, 0x0000)
      WriteShort(RTSwarm+0x0580, 0x0000)
      WriteShort(RTSwarm+0x05C0, 0x0000)
      WriteShort(RTSwarm+0x0600, 0x0000)
      WriteShort(RTSwarm+0x0640, 0x0000)
      WriteShort(RTSwarm+0x0680, 0x0000)
      WriteShort(RTSwarm+0x06C0, 0x0000)
      WriteShort(RTSwarm+0x0700, 0x0000)
      WriteShort(RTSwarm+0x0740, 0x0000)
      WriteShort(RTSwarm+0x0780, 0x0000)
      WriteShort(RTSwarm+0x07C0, 0x0000)
      WriteShort(RTSwarm+0x0800, 0x0000)
      WriteShort(RTSwarm+0x0840, 0x0000)
      WriteShort(RTSwarm+0x0880, 0x0000)
      WriteShort(RTSwarm+0x08C0, 0x0000)
      WriteShort(RTSwarm+0x0900, 0x0000)
    elseif ReadShort(RTSwarm+0x01EC) == 0x0557 and ReadShort(RTSwarm+0x01F0) == 0x99EC then --Hydra
      WriteShort(RTSwarm+0x01EC, 0x0000)
      WriteShort(RTSwarm+0x022C, 0x0000)
      WriteShort(RTSwarm+0x026C, 0x0000)
      WriteShort(RTSwarm+0x02AC, 0x0000)
      WriteShort(RTSwarm+0x02EC, 0x0000)
      WriteShort(RTSwarm+0x032C, 0x0000)
      WriteShort(RTSwarm+0x036C, 0x0000)
      WriteShort(RTSwarm+0x03AC, 0x0000)
      WriteShort(RTSwarm+0x03EC, 0x0000)
      WriteShort(RTSwarm+0x042C, 0x0000)
      WriteShort(RTSwarm+0x046C, 0x0000)
      WriteShort(RTSwarm+0x04AC, 0x0000)
      WriteShort(RTSwarm+0x04EC, 0x0000)
      WriteShort(RTSwarm+0x052C, 0x0000)
      WriteShort(RTSwarm+0x056C, 0x0000)
      WriteShort(RTSwarm+0x05AC, 0x0000)
      WriteShort(RTSwarm+0x05EC, 0x0000)
      WriteShort(RTSwarm+0x062C, 0x0000)
      WriteShort(RTSwarm+0x066C, 0x0000)
      WriteShort(RTSwarm+0x06AC, 0x0000)
      WriteShort(RTSwarm+0x06EC, 0x0000)
      WriteShort(RTSwarm+0x072C, 0x0000)
      WriteShort(RTSwarm+0x076C, 0x0000)
      WriteShort(RTSwarm+0x07AC, 0x0000)
      WriteShort(RTSwarm+0x07EC, 0x0000)
      WriteShort(RTSwarm+0x082C, 0x0000)
      WriteShort(RTSwarm+0x086C, 0x0000)
      WriteShort(RTSwarm+0x08AC, 0x0000)
      WriteShort(RTSwarm+0x08EC, 0x0000)
      WriteShort(RTSwarm+0x092C, 0x0000)
    elseif ReadShort(RTSwarm+0x0304) == 0x0557 and ReadShort(RTSwarm+0x0308) == 0x99EC then --Storm Rider
      WriteShort(RTSwarm+0x0304, 0x0000)
      WriteShort(RTSwarm+0x0344, 0x0000)
      WriteShort(RTSwarm+0x0384, 0x0000)
      WriteShort(RTSwarm+0x03C4, 0x0000)
      WriteShort(RTSwarm+0x0404, 0x0000)
      WriteShort(RTSwarm+0x0444, 0x0000)
      WriteShort(RTSwarm+0x0484, 0x0000)
      WriteShort(RTSwarm+0x04C4, 0x0000)
      WriteShort(RTSwarm+0x0504, 0x0000)
      WriteShort(RTSwarm+0x0544, 0x0000)
      WriteShort(RTSwarm+0x0584, 0x0000)
      WriteShort(RTSwarm+0x05C4, 0x0000)
      WriteShort(RTSwarm+0x0604, 0x0000)
      WriteShort(RTSwarm+0x0644, 0x0000)
      WriteShort(RTSwarm+0x0684, 0x0000)
      WriteShort(RTSwarm+0x06C4, 0x0000)
      WriteShort(RTSwarm+0x0704, 0x0000)
      WriteShort(RTSwarm+0x0744, 0x0000)
      WriteShort(RTSwarm+0x0784, 0x0000)
      WriteShort(RTSwarm+0x07C4, 0x0000)
      WriteShort(RTSwarm+0x0804, 0x0000)
      WriteShort(RTSwarm+0x0844, 0x0000)
      WriteShort(RTSwarm+0x0884, 0x0000)
      WriteShort(RTSwarm+0x08C4, 0x0000)
      WriteShort(RTSwarm+0x0904, 0x0000)
      WriteShort(RTSwarm+0x0944, 0x0000)
      WriteShort(RTSwarm+0x0984, 0x0000)
      WriteShort(RTSwarm+0x09C4, 0x0000)
      WriteShort(RTSwarm+0x0A04, 0x0000)
      WriteShort(RTSwarm+0x0A44, 0x0000)
    elseif ReadShort(RTSwarm+0x046C) == 0x0557 and ReadShort(RTSwarm+0x0470) == 0x99EC then --Boss/Enemy 9
      WriteShort(RTSwarm+0x046C, 0x0000) --Pete (Cups), Pete (TR)
      WriteShort(RTSwarm+0x04AC, 0x0000)
      WriteShort(RTSwarm+0x04EC, 0x0000)
      WriteShort(RTSwarm+0x052C, 0x0000)
      WriteShort(RTSwarm+0x056C, 0x0000)
      WriteShort(RTSwarm+0x05AC, 0x0000)
      WriteShort(RTSwarm+0x05EC, 0x0000)
      WriteShort(RTSwarm+0x062C, 0x0000)
      WriteShort(RTSwarm+0x066C, 0x0000)
      WriteShort(RTSwarm+0x06AC, 0x0000)
      WriteShort(RTSwarm+0x06EC, 0x0000)
      WriteShort(RTSwarm+0x072C, 0x0000)
      WriteShort(RTSwarm+0x076C, 0x0000)
      WriteShort(RTSwarm+0x07AC, 0x0000)
      WriteShort(RTSwarm+0x07EC, 0x0000)
      WriteShort(RTSwarm+0x082C, 0x0000)
      WriteShort(RTSwarm+0x086C, 0x0000)
      WriteShort(RTSwarm+0x08AC, 0x0000)
      WriteShort(RTSwarm+0x08EC, 0x0000)
      WriteShort(RTSwarm+0x092C, 0x0000)
      WriteShort(RTSwarm+0x096C, 0x0000)
      WriteShort(RTSwarm+0x09AC, 0x0000)
      WriteShort(RTSwarm+0x09EC, 0x0000)
      WriteShort(RTSwarm+0x0A2C, 0x0000)
      WriteShort(RTSwarm+0x0A6C, 0x0000)
      WriteShort(RTSwarm+0x0AAC, 0x0000)
      WriteShort(RTSwarm+0x0AEC, 0x0000)
      WriteShort(RTSwarm+0x0B2C, 0x0000)
      WriteShort(RTSwarm+0x0B6C, 0x0000)
      WriteShort(RTSwarm+0x0BAC, 0x0000)
    elseif ReadShort(RTSwarm+0x0498) == 0x0557 and ReadShort(RTSwarm+0x049C) == 0x99EC then --Armor Xemnas I
      WriteShort(RTSwarm+0x0498, 0x0000)
      WriteShort(RTSwarm+0x04D8, 0x0000)
      WriteShort(RTSwarm+0x0518, 0x0000)
      WriteShort(RTSwarm+0x0558, 0x0000)
      WriteShort(RTSwarm+0x0598, 0x0000)
      WriteShort(RTSwarm+0x05D8, 0x0000)
      WriteShort(RTSwarm+0x0618, 0x0000)
      WriteShort(RTSwarm+0x0658, 0x0000)
      WriteShort(RTSwarm+0x0698, 0x0000)
      WriteShort(RTSwarm+0x06D8, 0x0000)
      WriteShort(RTSwarm+0x0718, 0x0000)
      WriteShort(RTSwarm+0x0758, 0x0000)
      WriteShort(RTSwarm+0x0798, 0x0000)
      WriteShort(RTSwarm+0x07D8, 0x0000)
      WriteShort(RTSwarm+0x0818, 0x0000)
      WriteShort(RTSwarm+0x0858, 0x0000)
      WriteShort(RTSwarm+0x0898, 0x0000)
      WriteShort(RTSwarm+0x08D8, 0x0000)
      WriteShort(RTSwarm+0x0918, 0x0000)
      WriteShort(RTSwarm+0x0958, 0x0000)
      WriteShort(RTSwarm+0x0998, 0x0000)
      WriteShort(RTSwarm+0x09D8, 0x0000)
      WriteShort(RTSwarm+0x0A18, 0x0000)
      WriteShort(RTSwarm+0x0A58, 0x0000)
      WriteShort(RTSwarm+0x0A98, 0x0000)
      WriteShort(RTSwarm+0x0AD8, 0x0000)
      WriteShort(RTSwarm+0x0B18, 0x0000)
      WriteShort(RTSwarm+0x0B58, 0x0000)
      WriteShort(RTSwarm+0x0B98, 0x0000)
      WriteShort(RTSwarm+0x0BD8, 0x0000)
    end
  end
end