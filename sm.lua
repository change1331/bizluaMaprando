-- first run through
first=true
-- width and height of icons
xoffset=254
xmax=256+142
w=16
h=16
require("cfg")
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
	lastc = c
	while i < 0x40 do
		if c < 0x0040 then
			c = c -0x0020
			str = str .. string.char(c+97)
		elseif c == 127 then
			-- we only care about the last part of the string
			if lastc ==c then
				str = ""
			end
		else
			c = c -0x0030
			str = str .. string.char(c+97)
		end
		lastc = c
		c = memory.read_u16_le(addr+i)
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
		forms.drawString(win,xmax-x*w,y,str,clr,nil,sz,nil,nil,"right")
	else
		gui.drawString(xmax-x*w,y*h,str,clr,nil,sz, nil, nil, "right")
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
--items 09A4, walljump enabled dfff05
function items()
	val=mainmemory.read_u16_le(0x09A4)
	eq=mainmemory.read_u16_le(0x09A2)
	i=1
	while i <= 0x2000 do
		item = itemenum[i]
		if item then
			x = cfg[item][1]
			y = cfg[item][2]
			sc = cfg[item][3]
			if (val&i)~=0 then
				draw(x, y, item, sc)
				if (eq&i)==0 then
					drawequip(x, y, sc)
				end
			else
				draw(x,y,"b"..item, sc)
			end
		end
		i = i * 2
	end
	wj=memory.readbyte(0xdfff05)
	if wj&1==1 then
		i=0x400
		x = cfg[walljump][1]
		y = cfg[walljump][2]
		sc = cfg[walljump][3]
		if (val&i)~=0 then
			draw(x, y, walljump, sc)
			if (eq&i) == 0 then
				drawequip(x, y, sc)
			end
		else
			draw(x, y, "b"..walljump, sc)
		end
	else
		--wj icon?
		--draw(walljump[2], walljump[3], walljump[1])
	end
end
--beams 09A8, hyperbeam 0A76
function beams()
	f = false
	val=mainmemory.read_u16_le(0x0A76)
	if val==0x8000 then
		draw(cfg[hyper][1], cfg[hyper][2], hyper, cfg[hyper][3])
		f = true
	end
	val=mainmemory.read_u16_le(0x09A8)
	eq=mainmemory.read_u16_le(0x09A6)
	i=1
	while i ~= 0x2000 do
		beam = beamenum[i]
		if beam then
			x = cfg[beam][1]
			y = cfg[beam][2]
			sc = cfg[beam][3]
			if (val&i)~=0 then
				
				draw(x, y, beam, sc)
				
				if (eq&i)==0 or f then
					drawequip(x, y, sc)
				end
			else
				draw(x, y, "b" .. beam, sc)
			end
		end
		i = i * 2
	end
end

-- flag loc 8FEBC0, flag 8FEBC8 indexed
function bossesdead()
	bn = 0
	for i = 0, #objflags do
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
	
	if noobj then
		motherbrain()
	else
		-- objectives
		if bossesdead() == #objflags then
			motherbrain()
		else
			if #objflags > 3  and bossrefresh > 5 then
				bossset = bossset +4
				if bossset > #objflags then
					bossset = 0
				end
				bossrefresh = 0
			end
			for i = 0, 3 do
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
	memory.usememorydomain("CARTRAM")
	mapflags=memory.readbyte(0x2600)
	memory.usememorydomain("System Bus")
	
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
	val = 0x70000 + mainmemory.read_u16_le(0x079B)
	if not rooms then
		return
	end
	for i = 1, #rooms do 
		room = rooms[i]
		if room and room["rom_address"]==val then
			textright(0,cfg["roomrow"],room["name"],"white")
		end
	end
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

itemenum[0x100]="hijump"
itemenum[0x2000]="speed"
itemenum[0x200]="space"
itemenum[8]="screw"
walljump="walljump"
-- icon, mem loc for flag, flag
flagenum = {
	{"zebes", 0xD820, 1},
	{"tube", 0xd821, 8},
	{"shak", 0xd821, 0x20},
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
frame = 0
hash = ""
seed = ""
diff = ""
objflags = {}
noobj = false;
reqanimals = false
function setup()
	hash = mem(0xdffef0)
	if(hash:match("%W")) then
		return
	end
	seed = bigletter(0xceb240 + (224 - 128) * 0x40)
	seed = seed .. " " .. mem(0xdffef0)
	diff = bigletter(0xceb240 + (226 - 128) * 0x40)
	diff = diff .. " " .. bigletter(0xceb240 + (228 - 128) * 0x40)
	nophantoon = true
	reqanimals=memory.read_u32_le(0xa1f000)==0xffff
	val=memory.read_u16_le(0x83AAD2)
	if val==0xECA0 then 
		noobj = true
	else
		i=0
		m = memory.read_u16_le(0x8FEBC0+i*2)
		f = memory.read_u16_le(0x8FEBE8+i*2)
		while m ~= 0xFFFF do
			m = memory.read_u16_le(0x8FEBC0+i*2)
			f = memory.read_u16_le(0x8FEBE8+i*2)
			val=mainmemory.read_u16_le(m)
			for j = 1,#bossenum do
				if bossenum[j] and bossenum[j][2] == m and bossenum[j][3] == f then
					objflags[i] = bossenum[j]
				end
				if m == 0xD82B and f == 1 then
					--nophantoon = false;
				end
			end
			i=i+1
		end
	end
	if nophantoon then
		flagenum[#flagenum+1] = {"atomic", 0xD82B, 1}
	end
end
goodcore = true;
function done()
	writeconfig()
	if win ~= 0 then
		forms.destroy(win)
	end
	event.unregisterbyname("writecfg")
end
win = 0

rooms=nil
f = io.open("rooms.json", "r")
if f ~= nil then
	s = f:read("*all")
	f:close()
	rooms = json.decode(s)
end
while true do
	if emu.getsystemid() == "SNES" then
		if first then
			first = false
			if hash == "" or hash:match("%W") or hash ~= mem(0xdffef0) then
				setup()
				if hash:match("%W") or hash == "" then
					client.SetGameExtraPadding(0,0,0,0)
					goto continue
				end
			end
			getconfig()
			if cfg["window"] then
				if win == 0 then
					form = forms.newform(142,224)
					win = forms.pictureBox(form, nil, nil, 142, 224)
				end
				xoffset = 0
			else
				client.SetGameExtraPadding(0,0,142,0)
			end
			goodcore = memory.usememorydomain("System Bus")
			if goodcore == false then
				console.log("Current core unsupported.")
			end
			event.onexit(done, "writecfg")
		end
		if frame == 30 and goodcore then
			if hash == "" or hash:match("%W") or hash ~= mem(0xdffef0) then
				setup()
				if hash:match("%W") or hash == "" then
					client.SetGameExtraPadding(0,0,0,0)
					goto continue
				end
			end
			forms.clear(win, "black")
			map(cfg["maprow"])
			items()
			beams()
			flags()
			
			textright(0,cfg["seedrow"],seed,"white")
			textright(0,cfg["diffrow"],diff,"white")
			boss()
			forms.refresh(win)
			frame = 0
		end
	end
	::continue::
	frame = frame+1
	emu.frameadvance()
end
