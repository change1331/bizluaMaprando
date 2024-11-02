
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
function draw(x,y,img)
	gui.drawImage(img,254+x*w,y*h,w,h)
end
function drawequip(x,y)
	gui.drawRectangle(254+x*w-1,y*h-1,w+2,h+2,0,0x01888888)
end
function text(x,y,str,clr)
	gui.drawString(254+x*w,y*h,str,clr,nil,h)
end
--items, 09A4
function items()
	val=mainmemory.read_u16_le(0x09A4)
	i=1
	
	while i <= 0x2000 do
		if (val&i)~=0 and itemenum[i] then
			draw(itemenum[i][2], itemenum[i][3], itemenum[i][1])
			eq=mainmemory.read_u16_le(0x09A2)
			if (eq&i)==0 then
				drawequip(itemenum[i][2], itemenum[i][3])
			end
		end
		i = i * 2
	end
	wj=memory.readbyte(0xdfff05)
	if wj==1 then
		i=0x400
		if (val&i)~=0 then
			draw(walljump[2], walljump[3], walljump[1])

		else
			draw(walljump[2], walljump[3], walljump[1])
			drawequip(walljump[2], walljump[3])
		end
		
	end
end
--beams, 09A8
function beams()
	f = false
	val=mainmemory.read_u16_le(0x0A76)
	if val==0x8000 then
		draw(hyper[2],hyper[3],hyper[1])
		eq=mainmemory.read_u16_le(0x09A6)
		f = true
	end
	val=mainmemory.read_u16_le(0x09A8)
	i=1
	while i <= 0x2000 do
		if (val&i)~=0 and beamenum[i] then
			draw(beamenum[i][2],beamenum[i][3],beamenum[i][1])
			eq=mainmemory.read_u16_le(0x09A6)
			if (eq&i)==0 or f then
				drawequip(beamenum[i][2],beamenum[i][3])
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
				draw(bosspos[i][1], bosspos[i][2],bossenum[j][1])
				if val&f==0 then
					drawequip(bosspos[i][1], bosspos[i][2])
				end
			end
		end
	end
	val=mainmemory.read_u16_le(mb[2])
	draw(mbpos[1],mbpos[2],mb[1])
	if val&mb[3]==0 then
		drawequip(mbpos[1],mbpos[2])
	else
		val=memory.read_u16_le(0xA1F000)
		if val== 0xFFFF then
			val=mainmemory.readbyte(animals[2])
			draw(animalpos[1],animalpos[2],animals[1])
			if val&animals[3]==0 then
				drawequip(animalpos[1],animalpos[2])
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
			text(i+2, r,mapenum[i][1], mapenum[i][2])
		else
			text(i+2, r,mapenum[i][1], "gray")
		end
	end
	
	loc = mainmemory.readbyte(0x1F5B)+3
	gs=mainmemory.readbyte(0x0998)
	if gs==0xF then
		if pauseloc == -1 then
			pauseloc = loc
		end
		gui.drawRectangle(254+pauseloc*w, r*h+2, w-2, h-2,0,"orange")
	else
		pauseloc =-1
	end
	gui.drawRectangle(254+loc*w, r*h+2, w-2, h-2,0,"white")
end
function flags()
	for i = 1,3 do
		val=mainmemory.read_u16_le(flagenum[i][2])
		f=flagenum[i][3]
		draw(flagpos[i][1], flagpos[i][2],flagenum[i][1])
		if val&f==0 then
			drawequip(flagpos[i][1], flagpos[i][2])
		end
	end
end
beamenum = {}
--c 1 r1,3
beamenum[4]={"spazer.png",0,0}
beamenum[2]={"ice.png",0,1}
beamenum[0x1000]={"charge.png",0,2}
--c 2 r1,2
beamenum[1]={"wave.png",1,0}
beamenum[8]={"plasma.png",1,1}
hyper={"hyper.png",1,2}


itemenum = {}
--c 3,7, r1
itemenum[1]={"varia.png",2,0}
itemenum[0x20]={"gravity.png",3,0}
itemenum[4]={"morph.png",4,0}
itemenum[0x1000]={"bombs.png",5,0}
itemenum[2]={"spring.png",6,0}
--c 3,7, r2
itemenum[0x100]={"hijump.png",2,1}
itemenum[0x2000]={"speed.png",3,1}
itemenum[0x200]={"space.png",4,1}
itemenum[8]={"screw.png",5,1}
walljump={"walljump.png",6,1}

bosspos={}
--c 8,9, r1
bosspos[0]={7,0}
bosspos[1]={8,0}
--c 8,9, r2
bosspos[2]={7,1}
bosspos[3]={8,1}
-- c5,6,7, r3
flagpos = {
	{4,2},
	{5,2},
	{6,2}
}
--c 8,9, r3
animalpos={7,2}
mbpos={8,2}

--r4,8
maprow=3
seedrow=4
diffrow=5
progrow=6
qolrow=7

flagenum = {
	{"zebes.png", 0xD820, 1},
	{"shak.png", 0xd821, 0x20},
	{"tube.png", 0xd821, 8}
}
bossenum = {
	{"pitroom.png",0xD823, 2},
	{"bombtorizo.png",0xD828, 4},
	{"sporespawn.png",0xD829, 2},
	{"babykraidroom.png",0xD823, 4},
	{"kraid.png",0xD829, 1},
	{"crocomire.png",0xD82A, 2},
	{"phantoon.png",0xD82B, 1},
	{"bowlingstatue.png",0xD823, 1},
	{"botwoon.png",0xD82C, 2},
	{"draygon.png",0xD82C, 1},
	{"plasmaroom.png",0xD823, 8},
	{"goldentorizo.png",0xD82A, 4},
	{"metalpiratesroom.png",0xD823, 0x10},
	{"acidchozostatue.png",0xD821, 0x10},
	{"ridley.png",0xD82A, 1},
	{"metroidroom.png",0xD822, 1},
	{"metroidroom.png",0xD822, 2},
	{"metroidroom.png",0xD822, 4},
	{"metroidroom.png",0xD822, 8}
}
mb={"motherbrain.png",0xD82A, 2}
animals={"animals.png",0xD821, 0x80}

mapenum = {
	{"C","purple"},
	{"B","green"},
	{"N","red"},
	{"W","brown"},
	{"M","blue"},
	{"T","pink"}
}
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
		flags()
		map(maprow)
		mem(0xdffef0,seedrow)
		bigletter(0xceb240 + (224 - 128) * 0x40, diffrow, "DIF: ")
		bigletter(0xceb240 + (226 - 128) * 0x40, progrow, "PRO: ")
		bigletter(0xceb240 + (228 - 128) * 0x40, qolrow, "QOL: ")
	end
	emu.frameadvance()

end
