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
cfg["zebes"] = {8,0,1}

cfg["wave"] = {0,1,1}
cfg["plasma"] = {1,1,1}
cfg["hyper"] = {2,1,1}
cfg["hijump"] = {3,1,1}
cfg["speed"] = {4,1,1}
cfg["space"] = {5,1,1}
cfg["screw"] = {6,1,1}
cfg["walljump"] = {7,1,1}
cfg["tube"] = {8,1,1}

cfg["motherbrain2"] = {0,2,8}
cfg["animals"] = {0,2,8}
cfg["boss0"] = {0,2,4}
cfg["boss1"] = {4,2,4}
cfg["shak"] = {8,2,1}

cfg["atomic"] = {8,3,1}

cfg["boss2"] = {0,6,4}
cfg["boss3"] = {4,6,4}

cfg["maprow"]= 10
cfg["seedrow"] = 11
cfg["diffrow"] = 12

cfg["window"] = true


function getconfig() 
    f = io.open("config.json", "r")
    if f ~= nil then
        s = f:read("*all")
        f:close()
        cfg = json.decode(s)
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