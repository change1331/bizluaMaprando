-- first run through
first=true
-- width and height of icons
xoffset=256
xmax=256+144
w=16
h=16
require("cfg")
function snes2pc(addr)
	a = addr >> 1
	a = a & 0x3F8000
	a = a | (addr & 0x7FFF)
	return a
end
function rom_readbyte(addr)
	return memory.readbyte(snes2pc(addr))
end
function rom_read_u16(addr)
	return memory.read_u16_le(snes2pc(addr))
end
function rom_read_u32(addr)
	return memory.read_u32_le(snes2pc(addr))
end
function mem(addr, zero)
	str = ""
	c = rom_readbyte(addr)
	i = 1
	-- 0 terminated strings
	while c ~= zero do
		str = str .. string.char(c)
		c = rom_readbyte(addr+i)
		i = i + 1
	end
	return str
end
function mem0(addr)
	str = ""
	c = rom_readbyte(addr)
	i = 1
	-- 0 terminated strings
	font = {}
	font[64] = "-"
	font[65] = "'"
	font[66] = "."
	while c ~= 0 do
		if c == 1 then
			str = str .. " "
		elseif c < 28 then
			str = str .. string.char(c+63)
		elseif c > 53 and c < 64 then
			str = str .. string.char(c-6)
		else
			str = str .. font[c]
		end
		c = rom_readbyte(addr+i)
		i = i + 1
	end
	return str
end
function bigletter(addr)
	str = ""
	c = rom_readbyte(addr)
	i = 2
	lastc = c
	while i < 0x40 do
		if c < 0x0040 then
			-- a-p
			c=c+0x41
			str = str .. string.char(c)
		elseif c == 127 then
			-- we only care about the last part of the string
			if lastc ==c then
				str = ""
			end
		else
			--q-z
			c=c+17
			if c == 108 then
				--allow +
				c=43
			end
			str = str .. string.char(c)
		end
		lastc = c
		c = rom_read_u16(addr+i)
		i = i + 2
	end
	return string.upper(str)
end
function drawequip(x,y, scale)
	draw(x, y, "equip", scale)
end
function draw(x,y,img, scale)
	sc = (scale == nil and 1) or scale
	if win ~= 0 then
		forms.drawImage(win,img ..".png",xoffset+x*w,y*h,w*sc,h*sc)
	else
		gui.drawImage(img ..".png",xoffset+x*w,y*h,w*sc,h*sc)
	end
end
function text(x,y,str,clr,size)
	sz = (size == nil and 10) or size
	if win ~= 0 then
		forms.drawString(win,xoffset+x*w,y*h,str,clr,nil,sz)
	else
		gui.drawString(xoffset+x*w,y*h,str,clr,nil,sz)
	end
end
function textright(x, y, str, clr, size)
	sz = (size == nil and 10) or size
	if win ~= 0 then
		forms.drawString(win,xmax-x*w,y*h,str,clr,nil,sz,nil,nil,"right")
	else
		gui.drawString(xmax-x*w,y*h,str,clr,nil,sz,nil, nil, "right")
	end
end
function rect(x,y,color, size)
	sz = (size == nil and 10) or size
	if win ~= 0 then
		forms.drawRectangle(win, xoffset+x*w, y*h+2, sz, sz,color, "black")
	else
		gui.drawRectangle(xoffset+x*w, y*h+2, sz, sz,color, "black")
	end
end
--items 09A4-collected 09A2-equiped, walljump enabled dfff05
function items()
	val=mainmemory.read_u16_le(0x09A4)
	eq=mainmemory.read_u16_le(0x09A2)
	for i, item in pairs(itemenum) do
		drawEq(val,eq,i,item)
	end

end
--beams 09A8, hyperbeam 0A76
function beams()
	val=mainmemory.read_u16_le(0x09A8)
	eq=mainmemory.read_u16_le(0x09A6)
	for i,beam in pairs(beamenum) do
		drawEq(val,eq,i,beam)
	end
	if vanilla == false then
		return
	end
	val=mainmemory.read_u16_le(0x0A76)
	if val==0x8000 then
		draw(cfg[hyper][1], cfg[hyper][2], hyper, cfg[hyper][3])
	end
end

function drawEq(val,eq,f,name)
	x = cfg[name][1]
	y = cfg[name][2]
	sc = cfg[name][3]
	if (val&f)==f then
		draw(x, y, name, sc)
		if (eq&f)~=f then
			drawequip(x, y, sc)
		end
	else
		draw(x, y, "b" .. name, sc)
	end
end

-- flag loc 8FEBC0, flag 8FEBC8 indexed
function bossesdead()
	bn = 0
	if #objflags == 0 then
		return bn
	end
	for i = 1, #objflags do
		val=mainmemory.read_u16_le(objflags[i][2])
		f= objflags[i][3]
		if val&f~=0 then
			bn = bn+1
		end
	end
	return bn
end
bossset =0
bossrefresh = 0
function boss()
	-- objectives
	if noobj or #objflags == 0 or bossesdead() == #objflags then
		motherbrain()
	else
		if #objflags > 4  and bossrefresh > 5 then
			bossset = bossset +4
			if bossset > #objflags then
				bossset = 0
			end
			bossrefresh = 0
		end
		for i = 1, 4 do
			seti = i+bossset
			if seti <= #objflags then
				val=mainmemory.read_u16_le(objflags[seti][2])
				f= objflags[seti][3]
				b = "boss"..i
				x = cfg[b][1]
				y = cfg[b][2]
				sc = cfg[b][3]
				if val&f~=0 then
					--text(x,y,i, "white")
					draw(x, y, objflags[seti][1], sc)
					drawequip(x, y, sc)
				else
					--text(x,y,i+1, "white", 56)
					draw(x, y, objflags[seti][1], sc)
				end
			end
		end
	end
	bossrefresh = bossrefresh +1
end
function motherbrain()
	mb2 = mainmemory.readbyte(mb[2])
	if mb2&mb[3] ~= 0 then
		val = mainmemory.readbyte(animals[2])
		if reqanimals and val&animals[3]==0 then
			anim = animals[1]
			x = cfg[anim][1]
			y = cfg[anim][2]
			sc = cfg[anim][3]
			draw(x,y,anim, sc)
		else
			x = cfg["ship"][1]
			y = cfg["ship"][2]
			sc = cfg["ship"][3]
			draw(x,y,"ship", sc)
		end
	else
		m = mb[1]
		x = cfg[m][1]
		y = cfg[m][2]
		sc = cfg[m][3]
		draw(x,y,m,sc)
	end
end
--map D908, loc 1F5B

pauseloc=-1
function map(r)
	text(0,r, "MAPS:", "yellow")
	mapflags = 0xFF
	if vanilla == false then
		mapflags = memory.readbyte(0x2600, "CARTRAM")
	end
	
	loc = mainmemory.readbyte(0x1F5B)+3
	gs=mainmemory.readbyte(0x0998)
	-- pausing: track current position move map icon.  could read 0x1F62 instead of storing pause loc
	if gs==0xF then
		if pauseloc == -1 then
			pauseloc = loc
		end
		rect(pauseloc,r,"orange")
	else
		pauseloc =-1
	end
	rect(loc, r,"white")
	
	flag = 1
	for i = 1,#mapenum do
		if mapflags&flag ~= 0 then
			val=mainmemory.readbyte(0xD908+i-1)
			
			if val ~= 0 then
				text(i+2, r,mapenum[i][1], mapenum[i][2])
			else
				text(i+2, r,mapenum[i][1], "white")
			end
		end
		flag = flag * 2
	end
end
function room()
	r=mainmemory.read_u16_le(0x079b)
	r=r+11
	state = rom_read_u16(0x8F0000+r)
	while (state ~= 0xE5E6) do 
		r=r+1
		state = rom_read_u16(0x8F0000+r)
	end
	r = r+2
	-- r is now E5E6 room state addr
	xtra = rom_read_u16(0x8F0000+r+16);
	room_name_addr = rom_read_u16(0xb80000+xtra+9)
	return mem0(0xE30000+room_name_addr+1)
end
--general gameplay flags
function flags()
	for i = 1,#flagenum do
		val=mainmemory.read_u16_le(flagenum[i][2])
		f=flagenum[i][3]
		flag = flagenum[i][1]
		x = cfg[flag][1]
		y = cfg[flag][2]
		sc = cfg[flag][3]
		draw(x, y, flag, sc)
		if val&f==0 then
			drawequip(x, y)
		end
	end
end
function timer()
	msecperframe = 100 / 60.09881186
	frames = memory.readbyte(0x1E10, "CARTRAM")
	tmsecs = frames * msecperframe
	secs = tmsecs / 100
	msecs = tmsecs % 100
	mins = secs / 60
	secs = secs % 60
	hours = mins / 60
	mins = mins % 60

	time = string.format("%02d:%02d:%02d:%02d",math.floor(hours),
		math.floor(mins),math.floor(secs),math.floor(msecs))
	return time
end

beamenum = {}
--c 1-3 r1-2
beamenum[0x1000]="charge"
beamenum[4]="spazer"
beamenum[8]="plasma"

beamenum[2]="ice"
beamenum[1]="wave"
hyper="hyper"

itemenum = {}
--c 4-8, r1-2
itemenum[1]="varia"
itemenum[0x20]="gravity"
itemenum[4]="morph"
itemenum[0x1000]="bombs"
itemenum[2]="spring"
itemenum[0x4000]="grapple"
itemenum[0x100]="hijump"
itemenum[0x200]="space"
itemenum[8]="screw"
itemenum[0x8000]="xray"

speed="speed"
blue="blue"
spark="spark"
walljump="walljump"
-- icon, mem loc for flag, flag
flagenum = {
	{"zebes", 0xD820, 1},
	{"tube", 0xd821, 8},
	{"shak", 0xd821, 0x20},
	{"atomic", 0xD82B, 1},
}
bossenum = {
	{"pitroom",0xD823, 2},
	{"bombtorizo",0xD828, 4},
	{"sporespawn",0xD829, 2},
	{"babykraidroom",0xD823, 4},
	{"kraid",0xD829, 1},
	{"crocomire",0xD82A, 2},
	{"phantoon",0xD82B, 1},
	{"bowlingstatue",0xD823, 1},
	{"botwoon",0xD82C, 2},
	{"draygon",0xD82C, 1},
	{"plasmaroom",0xD823, 8},
	{"goldentorizo",0xD82A, 4},
	{"metalpiratesroom",0xD823, 0x10},
	{"acidchozostatue",0xD821, 0x10},
	{"ridley",0xD82A, 1},
	{"metroidroom",0xD822, 1},
	{"metroidroom",0xD822, 2},
	{"metroidroom",0xD822, 4},
	{"metroidroom",0xD822, 8},
}
mb={"motherbrain2",0xD82D, 1}
animals={"animals",0xD821, 0x80}
-- maps & color
mapenum = {
	{"C","purple"},
	{"B","green"},
	{"N","red"},
	{"W","orange"},
	{"M","blue"},
	{"T","brown"},
}
frames = 0
hash = ""
diff = ""
met = ""
objflags = {}
vanilla = false
noobj = false
reqanimals = false
function vansetup()
	vanilla = true
	hash = "SuperMetroid"
	diff = "Vanilla"
	objflags[1] = bossenum[5]
	objflags[2] = bossenum[7]
	objflags[3] = bossenum[10]
	objflags[4] = bossenum[15]
	itemenum[0x2000]="speed"
end
function setup()
	met = mem(0x7fc0, 0x30)
	if met ~= "SUPERMETROID MAPRANDO" then
		vansetup()
		return
	end
	hash = mem(0xdffef0, 0)
	skill = bigletter(0xceb240 + (226 - 128) * 0x40)
	plus = ""
	if string.find(skill, "+") ~= nil then
		skill = string.sub(skill, 1,string.len(skill)-1)
		plus = "+"
	end
	if skill == "VERYHARD" then
		skill = "VHARD"
	elseif skill == "CUSTOM" then
		skill = "CUST"
	elseif skill == "EXTREME" then
		skill = "XTRM"
	elseif skill == "INSANE" then
		skill = "INSN"
	end
	skill = skill .. plus
	prog = bigletter(0xceb240 + (228 - 128) * 0x40)
	if prog == "TECHNICAL" then
		prog = "TECH"
	elseif prog == "NORMAL" then
		prog = "NORM"
	elseif prog == "CHALLENGE" then
		prog = "CHAL"
	elseif prog == "DESOLATE" then
		prog = "DESO"
	elseif prog == "CUSTOM" then
		prog = "CUST"
	end
	qol = bigletter(0xceb240 + (230 - 128) * 0x40)
	if qol == "DEFAULT" then
		qol = "DEF"
	elseif qol == "CUSTOM" then
		qol = "CUST"
	end

	nophantoon = true
	reqanimals= rom_read_u32(0xa1f000)==0xffff
	val=rom_read_u16(0x83AAD2)
	if val==0xECA0 then 
		noobj = true
	else
		i=0
		m = rom_read_u16(0x8FEBC0+i*2)
		f = rom_read_u16(0x8FEBE8+i*2)
		while m ~= 0xFFFF do
			for j, boss in pairs(bossenum) do
				if boss[2] == m and boss[3] == f then
					objflags[i+1] = boss
				end
				if m == 0xD82B and f == 1 then
					--nophantoon = false
				end
			end
			i=i+1
			m = rom_read_u16(0x8FEBC0+i*2)
			f = rom_read_u16(0x8FEBE8+i*2)
		end
	end
	extras=rom_readbyte(0xdfff05)
	if extras&1~=0 then
		itemenum[0x400]="walljump"
	end
	if extras&2~=0 then
		--split boosters
		itemenum[0x40]="blue"
		itemenum[0x80]="spark"
	else
		itemenum[0x2000]="speed"
	end
	diff = skill .. " " .. prog .. " " .. qol
end

goodcore = true
function done()
	if win ~= 0 then
		forms.destroy(win)
	end
	client.SetGameExtraPadding(0,0,0,0)
	event.unregisterbyname("done")
end
win = 0
roomsegment = 1
dir = 1
prevname = ""
roomdelay = 0
while true do
	if emu.getsystemid() ~= "SNES" then
		goto continue
	end
	if frames ~= 30 then
		goto continue
	end
	if first then
		memory.usememorydomain("CARTROM")
		first = false
		if hash == "" or hash:match("%W") then
			setup()
			if hash == "" then
				client.SetGameExtraPadding(0,0,0,0)
				goto continue
			end
		end
		getconfig()
		if cfg["window"] then
			if win == 0 then
				form = forms.newform(144,225)
				win = forms.pictureBox(form, nil, nil, 144, 225)
				client.SetGameExtraPadding(0,0,0,0)
			end
			xoffset = 0
			xmax = 142
		else
			client.SetGameExtraPadding(0,0,144,1)
		end
		event.onexit(done, "done")
	end
	forms.clear(win, "black")
	map(cfg["maprow"])
	items()
	beams()
	flags()
	totobj = ((noobj or #objflags) == 0 and 0) or #objflags
	ob = bossesdead() .. "/" .. totobj
	textright(0,cfg["seedrow"],hash,"white")
	textright(0,cfg["diffrow"],ob .. " "..diff,"white")
	boss()
	if vanilla == false then
		room_name = room()
		if room_name ~= prevname then
			prevname = room_name
			roomsegment = 1
			dir = 1
		end
		rlen = string.len(room_name)
		shortname = room_name
		maxlen = 22
		if rlen > maxlen then
			roomsegment = roomsegment +dir
			if roomsegment + maxlen == rlen then
				if dir ~= 0 then
					dir = -1
				else
					-- stall longer at the ends
					dir = 0
				end
			elseif roomsegment == 1 then
				if dir ~= 0 then
					dir = 1
				else
					-- stall longer at the ends
					dir = 0
				end
			end
			shortname = string.sub(room_name, roomsegment, roomsegment+maxlen)
		end
		
		if cfg["window"] then
			textright(0,cfg["roomrow"],shortname,"white")
		else
			textright(0,cfg["roomrow"],room_name,"white")
		end
	end
	forms.refresh(win)
	frames = 0
	::continue::
	frames = frames + 1
	emu.frameadvance()
end
