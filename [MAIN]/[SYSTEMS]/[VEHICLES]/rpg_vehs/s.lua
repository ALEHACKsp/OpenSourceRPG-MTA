RPu = exports.rpg_utilities
SQL = exports.rpg_db

function createVeh(table)
    if not table then return end
    if type(table) ~= "table" then return end
    local gid = table.gid
    local model = table.model
    local x,y,z = table.x,table.y,table.z
    local rx,ry,rz = table.rx,table.ry,table.zr
    local plate = table.plate
    local mileage = table.milage
    local fuel = table.fuel
    local health = table.health
    local owner = table.owner

    if gid~= 0 then
        veh = createVehicle(model,x,y,z,rx,ry,rz,plate,false)
        setElementHealth(veh,health)
        setElementData(veh,"v:info",{
            ["gid"] = gid,
            ["mileage"] = mileage,
            ["fuel"] = fuel,
            ["owner"] = owner,
        })
    else
        veh = createVehicle(model,x,y,z,rx,ry,rz,plate,false)
        setElementHealth(veh,health)
        setElementData(veh,"v:info",{
            ["gid"] = 0,
            ["mileage"] = 100,
            ["fuel"] = 100,
            ["owner"] = 0,
        })
    end
    return veh
end