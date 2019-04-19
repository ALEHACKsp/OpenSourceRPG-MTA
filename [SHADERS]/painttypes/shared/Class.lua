Class = {}

function Class:new(...)
	return new(self, ...)
end

function Class:createTexture(width, height, r, g, b, a)
	local texture = dxCreateTexture (width, height)
    local pixels = dxGetTexturePixels (texture)
    for x=0,width do
        for y=0,height do
            dxSetPixelColor (pixels, x, y, r, g, b, a)
        end;
    end;
    dxSetTexturePixels (texture, pixels)
    return texture
end

function Class:delete(...)
	return delete(self, ...)
end

Class.__call = Class.new
setmetatable(Class, {__call = Class.__call})