RPu = exports.rpg_utilities
SQL = exports.rpg_db

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

addCommandHandler("checkadmin",function(plr,cmd)
    print(isPlayerAdmin(plr))
end)