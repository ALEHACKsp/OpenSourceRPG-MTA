--[[
@author Lukasz Biegaj <wielebny@bestplay.pl>
@author Karer <karer.programmer@gmail.com>
@author WUBE <wube@lss-rp.pl>
@author RootKiller <rootkiller.programmer@gmail.com>
@copyright 2011-2013 Lukasz Biegaj <wielebny@bestplay.pl>
@license Dual GPLv2/MIT
@package MTA-XyzzyRP
@link https://github.com/lpiob/MTA-XyzzyRP GitHub
]]--


icons={}


RPu = exports.rpg_utilities
local sw,sh=guiGetScreenSize()
local scale = RPu:scaleScreen(0,0,32,32)


--local nametagFont = "default"
local nametagFont = dxCreateFont( "arial.ttf", 11 )
if not nametagFont then nametagFont = "default-bold" end

local nametagScale = 1
local nametagAlpha = 255
local nametagColor =
{
	r = 255,
	g = 192,
	b = 203,
} 

	createElement("text")

namet= {}
visible = true

function getIconPositions(amount, iconW, iconH)
    local positions = {}
    
    local offset = 3
    
    local startx, starty = 0, -iconH/2
    local maxWidth = (iconW+offset)*amount
    startx = (maxWidth/2 + iconW/2 + offset)
    
    local x, y = startx, starty
    for i=1, amount do 
        local progress = 1/amount 
        x = x - (maxWidth+offset)*progress
        positions[#positions+1] = {x=x, y=y}
    end 
    
    return positions
end 

addEventHandler("onClientKey",root,function(key,state)
	if state then
		if key == "F11" then
			cancelEvent();
			visible = not visible
		end
	end
end)

offset = 30
addEventHandler("onClientRender", getRootElement(), 
function()
	if not visible then return end
	local rootx, rooty, rootz = getCameraMatrix()--getElementPosition(getLocalPlayer())
	for i, ped in ipairs(getElementsByType("player",root,true)) do
		icons = {}
		number = 0
		if getElementData(ped, "p:info") and getElementDimension(localPlayer)==getElementDimension(ped) and getElementInterior(localPlayer)==getElementInterior(ped) then
			local x,y,z = getPedBonePosition(ped,4)					
			local sx, sy = getScreenFromWorldPosition(x,y,z+0.4)		
			if sx then
				local posx,posy,posz = getElementPosition(ped)
				local name = getElementData(ped, "p:info").name
				if not name then return end
				local distance = getDistanceBetweenPoints3D(rootx, rooty, rootz, x, y, z)
				local fX = math.floor(sx)
				local fY = math.floor(sy)
				local alpha = 191.25    	
				if(isLineOfSightClear(rootx,rooty,rootz,posx,posy,posz,true,true,false)) then
					local info = getElementData(ped,"p:duty")
					if not getElementData(ped,"p:mask") then
						if info then
							text = "#999999["..getElementData(ped,"p:info").gid.."] #FFFFFF"..name..""..info.color.."("..info.name..")"
							text2 = "["..getElementData(ped,"p:info").gid.."] "..name.."("..info.name..")"
							else
							text = "#999999["..getElementData(ped,"p:info").gid.."] #FFFFFF"..name
							text2 = "["..getElementData(ped,"p:info").gid.."] "..name
						end
					else
						if info then
							text = "#FFFFFFNieznajomy "..getElementData(ped,"p:mask")
							text2 = "Nieznajomy "..getElementData(ped,"p:mask")
						end
					end
					if getElementType(ped) == "ped" then
						text = "#FFFFFF"..name.." [BOT]"
					end
					dxDrawText(text2, fX+4, fY+4, fX, fY, tocolor(0,0,0, alpha), nametagScale, nametagFont, "center", "center",false,false,false,false)	
					dxDrawText(text, fX, fY, fX, fY, tocolor(199,21,133, alpha), nametagScale, nametagFont, "center", "center",false,false,false,true)	
					if getElementData(ped,"p:typing") == true then
						pos = #icons
						pos = pos+1
						icons[pos] = "chat"
					end
					if getElementData(ped,"p:console") == true then
						pos = #icons
						pos = pos+1
						icons[pos] = "console"
					end
					if getElementData(ped,"p:bw") then
						pos = #icons
						pos = pos+1
						pos2 = pos+1
						icons[pos] = "bw"
						icons[pos2] = "beer"
					end
					tablica = getIconPositions(#icons, unpack(scale,3),unpack(scale,4))
					fX=fX-5
					if #icons ~= 0 then
						for i,v in pairs(icons) do
								dxDrawImage(fX+(tablica[i].x),fY-40,unpack(scale,3),unpack(scale,4),""..v..".png")
						end
					end
				end
				
			end
		end
	end	

	for i, ped in ipairs(getElementsByType("ped",root,true)) do
		icons = {}
		number = 0
		if getElementData(ped, "p:info") and getElementDimension(localPlayer)==getElementDimension(ped) and getElementInterior(localPlayer)==getElementInterior(ped) then
			local x,y,z = getPedBonePosition(ped,4)					
			local sx, sy = getScreenFromWorldPosition(x,y,z+0.4)		
			if sx then
				local posx,posy,posz = getElementPosition(ped)
				local name = getElementData(ped, "p:info").name
				if not name then return end
				local distance = getDistanceBetweenPoints3D(rootx, rooty, rootz, x, y, z)
				local fX = math.floor(sx)
				local fY = math.floor(sy)
				local alpha = 191.25    	
				if isLineOfSightClear(rootx,rooty,rootz,posx,posy,posz,true,true,false) and distance<80 then
					if getElementType(ped) == "ped" then
						text = "#FFFFFF"..name.." [BOT]"
						text2 = ""..name.." [BOT]"
					end
					dxDrawText(text2, fX+4, fY+4, fX, fY, tocolor(0,0,0, alpha), nametagScale, nametagFont, "center", "center",false,false,false,false)	
					dxDrawText(text, fX, fY, fX, fY, tocolor(199,21,133, alpha), nametagScale, nametagFont, "center", "center",false,false,false,true)
				end
			end
		end
	end
	if isChatBoxInputActive() then
		if not getElementData(localPlayer,"p:typing") == true then
			setElementData(localPlayer,"p:typing",true)
		end
	else
		if not getElementData(localPlayer,"p:typing") == false then
			setElementData(localPlayer,"p:typing",false)
		end
	end
	if isConsoleActive() then
		if not getElementData(localPlayer,"p:console") == true then
			setElementData(localPlayer,"p:console",true)
		end
	else
		if not getElementData(localPlayer,"p:console") == false then
			setElementData(localPlayer,"p:console",false)
		end
	end
end)




addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), 
	function()
		-- Usuwamy nametagi.
		for k, v in ipairs(getElementsByType("player")) do
			setPlayerNametagShowing ( v, false )
		end
	local ped = createPed(0,1936.03125, -1794.6357421875, 13.546875)
	setElementData(ped,"p:info",{
		["name"] = "Angelo Jebiecigira"
	})
end)

addEventHandler("onClientPlayerSpawn", getRootElement(), 
	function()
		-- Usuwamy nametagi.
		setPlayerNametagShowing ( source, false )
	end
)

--[[
setTimer(function()
		for i, player in ipairs(getElementsByType("player",root,true)) do
			if player ~= localPlayer and getElementDimension(localPlayer)==getElementDimension(player) and getElementInterior(localPlayer)==getElementInterior(player) and getElementAlpha(player)>0 then
				local x,y,z = getPedBonePosition(player,8)
				local lookAt=getElementData(player, "lookAt")
				if (lookAt and lookAt[1]) then
--				  outputDebugString("x"..lookAt[1] .. " " .. lookAt[2] .. " " .. lookAt[3])
				  setPedLookAt(player, lookAt[1], lookAt[2], lookAt[3],-1,nil)
--				  setPedLookAt(player, 2000, -2000, -1)
				  dxDrawLine3D(x,y,z, lookAt[1], lookAt[2], lookAt[3], tocolor(255,0,0,255))
				end
			end
		end
end, 1000, 0)
]]--