DGS = exports.dgs
screenW, screenH = guiGetScreenSize(  )
baseX = 1920
zoom = 1


bindKey("m","down",function()
    showCursor(not isCursorShowing())
end)



local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil
 
local function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end
 
local function camRender()
    if not getElementData(localPlayer,"p:logged") == true then
	    if (sm.moov == 1) then
		    local x1,y1,z1 = getElementPosition(sm.object1)
		    local x2,y2,z2 = getElementPosition(sm.object2)
		    setCameraMatrix(x1,y1,z1,x2,y2,z2)
	    else
		    removeEventHandler("onClientPreRender",root,camRender)
        end
    end
end

 
function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1)then return false end
	sm.object1 = createObject(1337,x1,y1,z1)
	sm.object2 = createObject(1337,x1t,y1t,z1t)
	setElementAlpha(sm.object1,0)
	setElementAlpha(sm.object2,0)
	setObjectScale(sm.object1,0.01)
	setObjectScale(sm.object2,0.01)
	setElementInterior(sm.object1,200)
	setElementInterior(sm.object2,200)
	setElementDimension(sm.object1,1)
	setElementDimension(sm.object2,1)
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
	sm.moov = 1
	setTimer(removeCamHandler,time,1)
	setTimer(destroyElement,time,1,sm.object1)
	setTimer(destroyElement,time,1,sm.object2)
	addEventHandler("onClientPreRender",root,camRender)
	return true
end



if screenW < baseX then
    zoom = math.min(2, baseX/screenW)
end

function getZoom()
    local screenW, screenH = guiGetScreenSize(  )
    if screenW < 1920 then
        return math.min(2, 1920/screenW)
    else
        return 1.0
    end
end

function scaleScreen(x, y, w, h, alignX, alignY)
    assert(x, "Bad argument @ 'scaleScreen' [Execpted number at argument 1, got "..tostring(x).."]")
    assert(tonumber(x), "Bad argument @ 'scaleScreen' [The argument 1 must be a number!]")
    assert(y, "Bad argument @ 'scaleScreen' [Execpted number at argument 2, got "..tostring(y).."]")
    assert(tonumber(y), "Bad argument @ 'scaleScreen' [The argument 2 must be a number!]")
    assert(w, "Bad argument @ 'scaleScreen' [Execpted number at argument 3, got "..tostring(w).."]")
    assert(tonumber(w), "Bad argument @ 'scaleScreen' [The argument 3 must be a number!]")
    assert(h, "Bad argument @ 'scaleScreen' [Execpted number at argument 4, got "..tostring(h).."]")
    assert(tonumber(h), "Bad argument @ 'scaleScreen' [The argument 4 must be a number!]")
    alignX = alignX or "left"
    alignY = alignY or "top"
    w = w/zoom
    h = h/zoom
    assert( (string.lower(alignX) == "left" or string.lower(alignX) == "center" or string.lower(alignX) == "right") , "Bad argument 5 @ scaleScreen (invalid type alignment X)")
    assert( (string.lower(alignY) == "top" or string.lower(alignY) == "center" or string.lower(alignY) == "bottom") , "Bad argument 5 @ scaleScreen (invalid type alignment X)")    
    
    -- assert(alignX, "Bad argument @ 'scaleScreen' [Execpted string at argument 5, got none]")
    -- assert(alignY, "Bad argument @ 'scaleScreen' [Execpted string at argument 5, got none]")
    if alignX == "left" then
        x = x/zoom
    elseif alignX == "center" then
        x = (screenW/2-w/2)-(x/zoom)
    elseif alignX == "right" then
        x = (screenW-w)-(x/zoom)
    end
    if alignY == "top" then
        y = y/zoom
    elseif alignY == "center" then
        y = (screenH/2-h/2)-(y/zoom)
    elseif alignY == "bottom" then
        y = (screenH-h)-(y/zoom)
    end
    return {x, y, w, h}
end



