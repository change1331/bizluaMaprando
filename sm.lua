-- first run through
first=true
-- width and height of icons
w=16
h=16
function mem(addr)
	str = ""
	c = memory.readbyte(addr)
	i = 1
	-- 0 terminated strings
	while c ~= 0 do
		str = str .. string.char(c)
		c = memory.readbyte(addr+i)
		i = i + 1
	end
	return str
end
function bigletter(addr)
	str = ""
	c = memory.readbyte(addr)
	i = 2
	b = 0
	-- length of all big letter strings
	while i < 0x40 do
		if c < 0x0040 then
			c = c -0x0020
			str = str .. string.char(c+97)
		elseif c == 127 then
			-- we only care about the last part of the string
			str = ""
		else
			c = c -0x0030
			str = str .. string.char(c+97)
		end
		c = memory.read_u16_le(addr+i)
		i = i + 2
	end
	return str
end
function draw(x,y,img)
	gui.drawImage(img,254+x*w,y*h,w,h)
end
function drawequip(x,y)
	gui.drawImage("equip.png",254+x*w,y*h,w,h)
end
function draw2(x,y,img)
	gui.drawImage(img,254+x*w,y*h,w*4,h*4)
end
function drawequip2(x,y)
	gui.drawImage("equip.png",254+x*w,y*h,w*4,h*4)
end
function draw4(x,y,img)
	gui.drawImage(img,254+x*w,y*h,w*8,h*8)
end
function drawequip4(x,y)
	gui.drawImage("equip.png",254+x*w,y*h,w*8,h*8)
end
function text(x,y,str,clr)
	gui.drawString(254+x*w,y*h,str,clr,nil,h)
end
--items 09A4, walljump enabled dfff05
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
	else
		--wj icon?
		--draw(walljump[2], walljump[3], walljump[1])
	end
end
--beams 09A8, hyperbeam 0A76
function beam()
	f = false
	val=mainmemory.read_u16_le(0x0A76)
	if val==0x8000 then
		draw(hyper[2],hyper[3],hyper[1])
		f = true
	end
	val=mainmemory.read_u16_le(0x09A8)
	i=1
	while i ~= 0x2000 do
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
-- flag loc 8FEBC0, flag 8FEBC8 indexed
function boss()
	val=memory.read_u16_le(0x83AAD2)
	if val~=0xECA0 then 
		-- objectives
		bossesdead = 0
		for i = 0, 3 do
			m = memory.read_u16_le(0x8FEBC0+i*2)
			f = memory.read_u16_le(0x8FEBC8+i*2)
			val=mainmemory.read_u16_le(m)
			if val&f~=0 then
				bossesdead = bossesdead+1
			end
		end
		if bossesdead == 4 then
			motherbrain()
		else
			for i = 0, 3 do
				m = memory.read_u16_le(0x8FEBC0+i*2)
				f = memory.read_u16_le(0x8FEBC8+i*2)
				val=mainmemory.read_u16_le(m)
				draw2(bosspos[i][1],bosspos[i][2],objicons[i])
				if val&f~=0 then
					drawequip2(bosspos[i][1],bosspos[i][2])
				end
			end
		end
	else
		motherbrain()
	end
end
function motherbrain()
	x=bosspos[0][1]
	y=bosspos[0][2]
	mb2dead = mainmemory.readbyte(mb[2])&mb[3]~=0
	if mb2dead then
		draw4(x,y,animals[1], w2, h2)
		val = mainmemory.readbyte(animals[2])
		if val&animals[3]~=0 then
			drawequip4(x,y)
		end
	else
		draw4(x,y,mb[1])
	end
end
--map D908, loc 1F5B
pauseloc=-1
function map(r)
	gui.drawString(254,r*h+2, "MAPS:", "yellow")
	for i = 1,#mapenum do
		val=mainmemory.readbyte(0xD908+i-1)
		if val == 0xFF and mapenum[i] then
			text(i+2, r,mapenum[i][1], mapenum[i][2])
		else
			text(i+2, r,mapenum[i][1], "gray")
		end
	end
	loc = mainmemory.readbyte(0x1F5B)+3
	gs=mainmemory.readbyte(0x0998)
	-- pausing: track current position move map icon.  could read 0x1F62 instead of storing pause loc
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
--general gameplay flags
function flags()
	for i = 1,#flagenum do
		val=mainmemory.read_u16_le(flagenum[i][2])
		f=flagenum[i][3]
		draw(flagcol,i-1,flagenum[i][1])
		if val&f==0 then
			drawequip(flagcol, i-1, flagenum[i][1])
		end
	end
end

beamenum = {}
--c 1-3 r1-2
beamenum[0x1000]={"charge.png",0,0}
beamenum[4]={"spazer.png",1,0}
beamenum[8]={"plasma.png",2,0}

beamenum[2]={"ice.png",0,1}
beamenum[1]={"wave.png",1,1}
hyper={"hyper.png",2,1}

itemenum = {}
--c 4-8, r1-2
itemenum[1]={"varia.png",3,0}
itemenum[0x20]={"gravity.png",4,0}
itemenum[4]={"morph.png",5,0}
itemenum[0x1000]={"bombs.png",6,0}
itemenum[2]={"spring.png",7,0}

itemenum[0x100]={"hijump.png",3,1}
itemenum[0x2000]={"speed.png",4,1}
itemenum[0x200]={"space.png",5,1}
itemenum[8]={"screw.png",6,1}
walljump={"walljump.png",7,1}

-- c9, r1-
flagcol=8

bosspos={}
--c 1-8, r3
bosspos[0]={0,2}
bosspos[1]={4,2}
bosspos[2]={0,6}
bosspos[3]={4,6}

--r
maprow=10
seedrow=12
diffrow=13

-- icon, mem loc for flag, flag
flagenum = {
	{"zebes.png", 0xD820, 1},
	{"tube.png", 0xd821, 8},
	{"shak.png", 0xd821, 0x20},
	--{"acid.png", 0xd821, 0x10},
	--{"bowling.png", 0xD823, 1},
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
	{"metroidroom.png",0xD822, 8},
}
mb={"motherbrain2.png",0xD82A, 2}
animals={"animals.png",0xD821, 0x80}
-- maps & color
mapenum = {
	{"C","purple"},
	{"B","green"},
	{"N","red"},
	{"W","brown"},
	{"M","blue"},
	{"T","pink"},
}
frame = 0
seed = ""
diff = ""
objicons = {}
function setup()
	seed = mem(0xdffef0)
	diff = bigletter(0xceb240 + (224 - 128) * 0x40)
	diff = diff .. " " .. bigletter(0xceb240 + (226 - 128) * 0x40)
	diff = diff .. " " .. bigletter(0xceb240 + (228 - 128) * 0x40)
	nophantoon = true;
	for i = 0,3 do
		m = memory.read_u16_le(0x8FEBC0+i*2)
		f = memory.read_u16_le(0x8FEBC8+i*2)
		val=mainmemory.read_u16_le(m)
		for j = 1,#bossenum do
			if bossenum[j] and bossenum[j][2] == m and bossenum[j][3] == f then
				objicons[i] = bossenum[j][1]
			end
			if m == 0xD82B and f == 1 then 
				nophantoon = false;
			end
		end
	end
	if nophantoon then
		flagenum[#flagenum] = {"atomic.png", 0xD82B, 1}
	end
	items()
	beam()
	boss()
	flags()
	map(maprow)
end
goodcore = true;
while true do
	if emu.getsystemid() == "SNES" then
		if first then
			client.SetGameExtraPadding(0,0,142,0)
			first = false
			goodcore = memory.usememorydomain("System Bus")
			if goodcore == false then
				console.log("Current core unsupported.")
			end
		end
		
		if frame == 30 and goodcore then
			if seed ~= mem(0xdffef0) then
				setup()
			end
			items()
			beam()
			boss()
			flags()
			map(maprow)
			
			gui.drawString(330,seedrow*h,seed,"white",nil,12, nil, nil, "center")
			gui.drawString(400,diffrow*h,diff,"white",nil,12, nil, nil, "right")
			frame = 0
		end
	end
	frame = frame+1
	emu.frameadvance()
end
