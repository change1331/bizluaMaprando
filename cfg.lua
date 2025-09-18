json = require("json")

--x,y,scale
cfg = {}
cfg["charge"] = {0,0,1}
cfg["ice"] = {1,0,1}
cfg["spazer"] = {2,0,1}
cfg["varia"] = {3,0,1}
cfg["gravity"] = {4,0,1}
cfg["morph"] = {5,0,1}
cfg["bombs"] = {6,0,1}
cfg["spring"] = {7,0,1}
cfg["grapple"] = {8,0,1}


cfg["wave"] = {0,1,1}
cfg["plasma"] = {1,1,1}
cfg["hyper"] = {2,1,1}
cfg["hijump"] = {3,1,1}
cfg["speed"] = {4,1,1}
cfg["space"] = {5,1,1}
cfg["screw"] = {6,1,1}
cfg["xray"] = {7,1,1}
cfg["walljump"] = {8,1,1}


cfg["motherbrain2"] = {0,2,8}
cfg["ship"] = {0,2,8}
cfg["animals"] = {0,2,8}
cfg["boss1"] = {0,2,4}
cfg["boss2"] = {4,2,4}
cfg["zebes"] = {8,2,1}
cfg["tube"] = {8,3,1}
cfg["shak"] = {8,4,1}
cfg["atomic"] = {8,5,1}

cfg["boss3"] = {0,6,4}
cfg["boss4"] = {4,6,4}

cfg["maprow"]= 10
cfg["seedrow"] = 11
cfg["diffrow"] = 12
cfg["roomrow"] = 13

cfg["window"] = false
cfg["version"] = "1.0"


function getconfig() 
    f = io.open("config.json", "r")
    if f ~= nil then
        s = f:read("*all")
        f:close()
        newcfg = json.decode(s)
		if newcfg["version"] == cfg["version"] then
			cfg = newcfg
		else
			--Console.log("Old config.json detected, using default settings.")
		end
    end
end

function writeconfig()
    f = io.open("config.json", "w")
    if f ~= nil then
        s = json.encode(cfg)
        f:write(s)
        f:close()
    end
end