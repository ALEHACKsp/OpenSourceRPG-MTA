
--Ten zasób służy do przechowywania różnych często używanych funkcji.
SQL = exports.rpg_db

function reserveID()
    local id = 1
    while getPlayerByID(id) do
        id = id+1
    end
    return id
end

function doCheckID( player )
    local id = getElementData( player, "p:id" )
    if not id then
        setElementData( player, "p:id", reserveID() )
    end
end

function getPlayerByID( id )
    if not id or id == true then return false end
    if type(id) == "table" then return false end
    id = tonumber(id) or id
    if type(id) == "number" then
        for i,v in ipairs(getElementsByType("player")) do
            if getPlayerID(v) == id then
                return v
            end
        end
        return false
    else
        return false
    end
end

function getPlayerID( player )
    return getElementData( player, "p:id" )
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

 function RGBToHex(red, green, blue, alpha)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function moneyLog(nick,money,type)
if not type or not tonumber(money) or not tostring(type) then return end
    SQL:query("INSERT INTO money_logs (nick,money,type,date=NOW())",tostring(nick),tonumber(money),tostring(type))
end

addEventHandler("onPlayerChangeNick", getRootElement(),function()
    cancelEvent()
end)

