client.SetGameExtraPadding(0,0,142,0)

w=16
h=16
function mem(addr)
	str = ""
	c = memory.readbyte(addr)
	i = 1
	while c ~= 0 do
		str = str .. string.char(c)
		c = memory.readbyte(addr+i)
		i = i + 1
	end
	gui.drawString(256,175,str)
end

function bigletter(addr, y, s)
	str = ""
	c = memory.readbyte(addr)
	i = 2
	b = 0;
	while i < 0x40 do
		if c < 0x0040 then
			c = c -0x0020
			str = str .. string.char(c+97)
		elseif c == 127 then
			str = ""
		else
			c = c -0x0030
			str = str .. string.char(c+97)
		end
		c = memory.read_u16_le(addr+i)
		i = i + 2
	end
	gui.drawString(256,185+y, s .. str)
end

function draw(i)
	x=i[2]
	y=i[3]
	gui.drawImage(i[1],256+x*w,y*h,w,h)
end
function text(i)
	x=i[2]
	y=i[3]
	gui.drawString(256+x*w,y*h,i[1],i[4],nil,h)
end
--items, 09A4
function items()
	val=mainmemory.read_u16_le(0x09A4)
	i=1
	while i ~= 0x4000 do
		if (val&i)~=0 and itemenum[i] then
			draw(itemenum[i])
		end
		i = i * 2
	end
end
--beams, 09A8
function beams()
	val=mainmemory.read_u16_le(0x09A8)
	i=1
	while i ~= 0x2000 do
		if (val&i)~=0 and beamenum[i] then
			draw(beamenum[i])
		end
		i = i * 2
	end
end
--boss, D828
function boss(b)
	val=mainmemory.read_u16_le(0xD828+(b-1)*2)
	i=1
	while i ~= 512 do
		if (val&i)~=0 and bossenum[b][i] then
			draw(bossenum[b][i])
		end
		i = i * 2
	end
end
--map D908
function map()
	i=1
	while i ~= 7 do
		val=mainmemory.readbyte(0xD908+i-1)
		if val == 0xFF and mapenum[i] then
			text(mapenum[i])
		end
		i = i+1
	end
end

itemenum = {}
itemenum[1]={"varia.png",0,0}
itemenum[0x20]={"gravity.png",1,0}
itemenum[4]={"morph.png",2,0}
itemenum[0x1000]={"bombs.png",3,0}
itemenum[2]={"spring.png",4,0}
itemenum[0x100]={"hijump.png",5,0}
itemenum[0x2000]={"speed.png",6,0}
itemenum[0x200]={"space.png",7,0}
itemenum[8]={"screw.png",8,0}

beamenum = {}
beamenum[0x1000]={"charge.png",0,1}
beamenum[4]={"spazer.png",1,1}
beamenum[2]={"ice.png",2,1}
beamenum[1]={"wave.png",3,1}
beamenum[8]={"plasma.png",4,1}


bossenum = {}
for i = 1, 4 do
	bossenum[i] = {}
end
bossenum[1][256]={"kraid.png",5,1}
bossenum[2][1]={"phantoon.png",6,1}
bossenum[2][256]={"draygon.png",7,1}
bossenum[3][1]={"ridley.png",8,1}

mapenum = {}
mapenum[1]={"C",3,2,"white"}
mapenum[2]={"B",4,2,"green"}
mapenum[3]={"N",5,2,"red"}
mapenum[4]={"W",6,2,"brown"}
mapenum[5]={"M",7,2,"blue"}
mapenum[6]={"T",8,2,"gray"}



while true do
	items()
	beams()
	boss(1)
	boss(2)
	boss(3)
	gui.drawString(256,2*h, "MAP:")
	map()
	mem(0xdffef0)
	bigletter(0xceb240 + (224 - 128) * 0x40, 0, "DIF: ")
	bigletter(0xceb240 + (226 - 128) * 0x40, 10, "PRO: ")
	bigletter(0xceb240 + (228 - 128) * 0x40, 20, "QOL: ")
	emu.frameadvance()
end