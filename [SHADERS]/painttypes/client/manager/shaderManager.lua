shaderManager = inherit(Singleton)

function shaderManager:constructor()
	self.event = {}
	self.instances = {}
	self.texture = {}
	self:initManager();
end

function shaderManager:initManager()
	if not self.texture["cubeBlurry"] then
		self.texture["cubeBlurry"] = dxCreateTexture( "res/texture/cubeBlurry.dds" );
	end
	if not self.texture["cubeSharp"] then
		self.texture["cubeSharp"] = dxCreateTexture( "res/texture/cubeSharp.dds" );
	end
	if not self.texture["carbon"] then
		self.texture["carbon"] = dxCreateTexture("res/texture/carbon.png");
	end


	self:sync();
	self.event.onClientStreamIn = bind(self.onClientStreamIn, self);
	self.event.onClientStreamOut = bind(self.onClientStreamOut, self);
	self.event.onClientDataChange = bind(self.onClientDataChange, self);
	self.event.onClientDestroy = bind(self.onClientDestroy, self);
	addEventHandler( "onClientElementStreamIn", root, self.event.onClientStreamIn);
	addEventHandler( "onClientElementStreamOut", root, self.event.onClientStreamOut);
	addEventHandler( "onClientElementDataChange", root, self.event.onClientDataChange);
	addEventHandler("onClientElementDestroy", root, self.event.onClientDestroy);
end

function shaderManager:onClientDataChange(dataName, prevValue)
	if source:getType() == "vehicle" and dataName == "v:info" then
		info = source:getData("v:info")
		 nowValue = info.paint
		if prevValue ~= info then
			if not prevValue then
				self:engineApplyShaderToVehicle(source, nowValue)
			elseif nowValue == false then
				self:engineRemoveShaderFromVehicle(source)
			else
				self:engineRemoveShaderFromVehicle(source)
				self:engineApplyShaderToVehicle(source, nowValue) 
			end
		end
	end
end

function shaderManager:onClientDestroy()

	if source and isElement(source) and getElementType(source) == "vehicle" then
		info = source:getData("v:info")
		if not info then return end
		self:engineRemoveShaderFromVehicle(source, info.paint );
	end
end

function shaderManager:onClientStreamIn()
	info = source:getData("v:info")
	if not info then return end
	if source:getType() == "vehicle" and info.paint then
		self:engineApplyShaderToVehicle(source, info.paint );
	end
end

function shaderManager:onClientStreamOut()
	 info = source:getData("v:info")
	 if not info then return end
	if source:getType() == "vehicle" and info.paint then
		self:engineRemoveShaderFromVehicle(source, info.paint );
	end
end

function shaderManager:sync()
	for i,v in ipairs( Element.getAllByType("vehicle") ) do
		 info = v:getData("v:info")
		 if not info then return end
		if ( v == getPedOccupiedVehicle( localPlayer ) or isElementStreamable(v) ) and info.paint then
			self:engineApplyShaderToVehicle(v, info.paint );
		end
	end
end

function shaderManager:engineRemoveShaderFromVehicle(Element)
	if self.instances[Element] then
		self.instances[Element]:destructor();
		self.instances[Element] = nil
	end
end

function shaderManager:engineApplyShaderToVehicle(Element, shaderName)
	if not self.instances[Element] then
		if shaderName == "pearl" then
			self.instances[Element] = Pearl:new(Element, self.texture["cubeBlurry"], self.texture["cubeSharp"]);
			return true, self.instances[Element];
		elseif shaderName == "matte" then
			self.instances[Element] = Matte:new(Element, self.texture["cubeBlurry"], self.texture["cubeSharp"]);
			return true, self.instances[Element];
		elseif shaderName == "gloss" then
			self.instances[Element] = Gloss:new(Element, self.texture["cubeBlurry"], self.texture["cubeSharp"]);
			return true, self.instances[Element];
		elseif shaderName == "carbon" then
			self.instances[Element] = Carbon:new(Element, self.texture["carbon"], 245.0);
			return true, self.instances[Element];
		elseif shaderName == "cameleon" then
			self.instances[Element] = Cameleon:new(Element, self.texture["cubeBlurry"], self.texture["cubeSharp"]);
			return true, self.instances[Element];			
		else
			error("[shaderManager] Call function engineApplyShaderToVehicle bad argument @2 "..tostring(shaderName));
		end
	end
	return false, nil;
end

function shaderManager:destructor()
	removeEventHandler( "onClientElementStreamIn", getRootElement( ), self.event.onClientStreamIn);
	removeEventHandler( "onClientElementStreamOut", getRootElement( ), self.event.onClientStreamOut);
	removeEventHandler( "onClientElementDataChange", getRootElement( ), self.event.onClientDataChange);
	for key,instance in pairs(self.instances) do
		instance:destructor();
	end
end