
first=true
w=16
h=16
function mem(addr, r)
	str = ""
	c = memory.readbyte(addr)
	i = 1
	while c ~= 0 do
		str = str .. string.char(c)
		c = memory.readbyte(addr+i)
		i = i + 1
	end
	gui.drawString(254,r*h,str)
end
function bigletter(addr, r, s)
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
	gui.drawString(254,r*h, s .. str)
end
function draw(i)
	x=i[2]
	y=i[3]
	gui.drawImage(i[1],254+x*w,y*h,w,h)
end
function drawequip(i)
	x=i[2]
	y=i[3]
	gui.drawRectangle(254+x*w-1,y*h-1,w+2,h+2,0,0x01888888)
end
function text(i)
	x=i[2]
	y=i[3]
	gui.drawString(254+x*w,y*h,i[1],i[4],nil,h)
end
--items, 09A4
function items()
	val=mainmemory.read_u16_le(0x09A4)
	i=1
	while i <= 0xF000 do
		if (val&i)~=0 and itemenum[i] then
			draw(itemenum[i])
			eq=mainmemory.read_u16_le(0x09A2)
			if (eq&i)==0 then
				drawequip(itemenum[i])
			end
		end
		i = i * 2
	end
end
--beams, 09A8
function beams()
	val=mainmemory.read_u16_le(0x09A8)
	i=1
	while i <= 0x2000 do
		if (val&i)~=0 and beamenum[i] then
			draw(beamenum[i])
			eq=mainmemory.read_u16_le(0x09A6)
			if (eq&i)==0 then
				drawequip(beamenum[i])
			end
		end
		i = i * 2
	end
end
--boss, flag loc 8FEBC0, flag 8FEBC8 indexed
function boss()
	for i = 0,3 do
		m = memory.read_u16_le(0x8FEBC0+i*2)
		f = memory.read_u16_le(0x8FEBC8+i*2)
		val=mainmemory.read_u16_le(m)
		for j = 1,19 do
			
			if bossenum[j] and bossenum[j][2] == m and bossenum[j][3] == f then
				draw({bossenum[j][1], bosspos[i][1], bosspos[i][2]})
				if val&f==0 then
					drawequip({bossenum[j][1], bosspos[i][1], bosspos[i][2]})
				end
			end
		end
	end
end
--map D908
pauseloc=-1
function map(r)
	gui.drawString(254,r*h+2, "MAPS:", "yellow")
	for i = 1,6 do
		val=mainmemory.readbyte(0xD908+i-1)
		if val == 0xFF and mapenum[i] then
			text({mapenum[i][1], mapenum[i][2], r, mapenum[i][3]})
		else
			text({mapenum[i][1], mapenum[i][2], r, "gray"})
		end
	end
	loc = mainmemory.readbyte(0x1F5B)
	gs=mainmemory.readbyte(0x0998)
	if gs==0xF then
		if pauseloc == -1 then
			pauseloc = loc
		end
		loc = mainmemory.readbyte(0x1F5B)
		gui.drawRectangle(254+mapenum[loc+1][2]*w+2, r*h+2, w-2, h-2,0,"white")
		gui.drawRectangle(254+mapenum[pauseloc+1][2]*w+2, r*h+2, w-2, h-2,0,"orange")
	else
		pauseloc =-1
		gui.drawRectangle(254+mapenum[loc+1][2]*w+2, r*h+2, w-2, h-2,0,"white")
	end
end

itemenum = {}
itemenum[1]={"varia.png",2,0}
itemenum[0x20]={"gravity.png",3,0}
itemenum[4]={"morph.png",4,0}
itemenum[0x1000]={"bombs.png",5,0}
itemenum[2]={"spring.png",6,0}
itemenum[0x100]={"hijump.png",2,1}
itemenum[0x2000]={"speed.png",3,1}
itemenum[0x200]={"space.png",4,1}
itemenum[8]={"screw.png",5,1}
itemenum[0xF000]={"walljump.png",6,1}

beamenum = {}
beamenum[0x1000]={"charge.png",0,2}
beamenum[4]={"spazer.png",0,0}
beamenum[2]={"ice.png",0,1}
beamenum[1]={"wave.png",1,0}
beamenum[8]={"plasma.png",1,1}


bossenum = {
	{"kraid.png",0xD829, 1},
	{"ridley.png",0xD82A, 1},
	{"phantoon.png",0xD82B, 1},
	{"draygon.png",0xD82C, 1},
	{"sporespawn.png",0xD829, 2},
	{"crocomire.png",0xD82A, 2},
	{"botwoon.png",0xD82C, 2},
	{"goldentorizo.png",0xD82A, 4},
	{"metroidroom.png",0xD822, 1},
	{"metroidroom.png",0xD822, 2},
	{"metroidroom.png",0xD822, 4},
	{"metroidroom.png",0xD822, 8},
	{"bombtorizo.png",0xD828, 4},
	{"bowlingstatue.png",0xD823, 1},
	{"acidchozostatue.png",0xD821, 0x10},
	{"pitroom.png",0xD823, 2},
	{"babykraidroom.png",0xD823, 4},
	{"plasmaroom.png",0xD823, 8},
	{"metalpiratesroom.png",0xD823, 0x10}
}

bosspos={}
bosspos[0]={7,0}
bosspos[1]={7,1}
bosspos[2]={8,0}
bosspos[3]={8,1}

mapenum = {}
mapenum[1]={"C",3,"purple"}
mapenum[2]={"B",4,"green"}
mapenum[3]={"N",5,"red"}
mapenum[4]={"W",6,"brown"}
mapenum[5]={"M",7,"blue"}
mapenum[6]={"T",8,"pink"}
while true do
	if emu.getsystemid() == "SNES" then
		if first then
			client.SetGameExtraPadding(0,0,142,0)
			first = false
		end
		gui.clearGraphics()
		items()
		beams()
		boss()
		map(3)
		mem(0xdffef0,4)
		bigletter(0xceb240 + (224 - 128) * 0x40, 5, "DIF: ")
		bigletter(0xceb240 + (226 - 128) * 0x40, 6, "PRO: ")
		bigletter(0xceb240 + (228 - 128) * 0x40, 7, "QOL: ")
	end
	emu.frameadvance()

end
