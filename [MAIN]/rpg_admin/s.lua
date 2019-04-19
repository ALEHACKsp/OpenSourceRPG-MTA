RPu = exports.rpg_utilities
SQL = exports.rpg_db
RPv = exports.rpg_vehs

function isPlayerAdmin(plr)
    if not plr then return false end
    if  getElementData(plr,"p:info").groupid ~= 4 then 
        return false
    else
        return true
    end
end


function commandLog(plr,cmd,target,text)
    if not text then return end
    print("test")
    SQL:query("INSERT INTO rpg_adminlogs (command,admin,target,other) VALUES(?,?,?,?)",cmd,plr,target,text)
end

addCommandHandler("skick",function(plr,cmd,target,...)
    if not ... then return end
    if not isPlayerAdmin(plr) then return end
    local reason =  table.concat({...}," ")
    target = RPu:getPlayerFromPartialName(target)
    if target then
        commandLog(getPlayerName(plr),cmd,getPlayerName(target),reason)
        kickPlayer(target,plr,reason)
    end
end)

addCommandHandler("sban",function(plr,cmd,target,time,bantype,...)
    if not ... then return end
    if not tonumber(time) then return end
    if not isPlayerAdmin(plr) then return end
    local reason =  table.concat({...}," ")
    target = RPu:getPlayerFromPartialName(target)
    if target then
        if (not getElementData(target,"p:info")) then return end
        if bantype == "m" then
            SQL:query("INSERT INTO rpg_bans (name,serial,time,reason,admin) VALUES(?,?,NOW() + INTERVAL ? minute,?,?)",getPlayerName(target),getPlayerSerial(target),time,reason,getPlayerName(plr))
        elseif bantype == "h" then
            SQL:query("INSERT INTO rpg_bans (name,serial,time,reason,admin) VALUES(?,?,NOW() + INTERVAL ? hour,?,?)",getPlayerName(target),getPlayerSerial(target),time,reason,getPlayerName(plr))
        elseif bantype == "d" then
            SQL:query("INSERT INTO rpg_bans (name,serial,time,reason,admin) VALUES(?,?,NOW() + INTERVAL ? day,?,?)",getPlayerName(target),getPlayerSerial(target),time,reason,getPlayerName(plr))
        elseif bantype == "m2" then
            SQL:query("INSERT INTO rpg_bans (name,serial,time,reason,admin) VALUES(?,?,NOW() + INTERVAL ? month,?,?)",getPlayerName(target),getPlayerSerial(target),time,reason,getPlayerName(plr))
        end
        commandLog(getPlayerName(plr),cmd,getPlayerName(target),reason)
        kickPlayer(target,"\nZostałeś zbanowany przez: "..getPlayerName(plr).."\nPowód: "..reason)
    end
end)

addCommandHandler("swarn",function(plr,cmd,target,...)
    if not ... then return end
    if not isPlayerAdmin(plr) then return end
    local reason =  table.concat({...}," ")
    target = RPu:getPlayerFromPartialName(target)
    if target then
        commandLog(getPlayerName(plr),cmd,getPlayerName(target),reason)
        for i=1,10 do
            outputChatBox("#FF0000Dostałeś ostrzeżenie, powód:"..reason.."["..i.."/10]",target,255, 255, 255, true)
        end
    end
end)


addCommandHandler("checkadmin",function(plr,cmd)
    print(isPlayerAdmin(plr))
end)

addCommandHandler("vc",function(plr,cmd,...)
	if isPlayerAdmin(plr) then
		if not ... then return outputChatBox("Użyj: /vc [model]/[nazwa]",plr) end
		local x,y,z = getElementPosition(plr)
		model = table.concat({...}," ")
		if tonumber(model) then
			model = tonumber(model)
			model = getVehicleNameFromModel(tostring(model)) 
			if not model then return outputChatBox("Nie ma takiego pojazdu",plr) end
		end
		model = getVehicleModelFromName(model)
		if not model then return outputChatBox("Nie ma takiego pojazdu",plr) end
		local x,y,z = getElementPosition(plr)
		local rx,ry,rz = getElementRotation(plr)
		local table = {
			["gid"] = 0,
			["model"] = model,
			["x"] = x,
			["y"] = y,
			["z"] = z,
			["rx"] = rx,
			["ry"] = ry,
			["rz"] = rz,
			["plate"] = "test",
			["health"] = 500,
		}
		if getPedOccupiedVehicle(plr) then destroyElement(getPedOccupiedVehicle(plr)) end
		local veh = RPv:createVeh(table)
		outputDebugString(""..getPlayerName(plr).." Respi Pojazd")
		warpPedIntoVehicle(plr,veh)
		setElementDimension(veh, getElementDimension(plr))
	end
end)