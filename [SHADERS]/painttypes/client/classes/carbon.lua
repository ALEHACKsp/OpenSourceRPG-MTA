Carbon = inherit(Class)

function Carbon:constructor(Element, gTextureCarbon, gMultipler)
	self.properites = {}
	self.this = dxCreateShader("res/fx/carbon.fx", 0, 0, false, "vehicle");
	self.element = Element
	self.properites["texture"] = gTextureCarbon;
	self.properites["gMultipler"] = gMultipler;
	self:init()
end

function Carbon:updateValue()
	dxSetShaderValue( self.this, "gTexture", self.properites["texture"])
	dxSetShaderValue( self.this, "gMultipler", self.properites["gMultipler"])
end

function Carbon:init()
	self:updateValue()
	if Settings.model[self.element:getModel()] and Settings.model[self.element:getModel()].main then
		engineApplyShaderToWorldTexture( self.this, Settings.model[self.element:getModel()].main, self.element )
	else
		error("Carbon shader init error not find main texture model "..tostring(self.element:getModel()))
	end
end

function Carbon:destructor()
	if isElement(self.this) then
		engineRemoveShaderFromWorldTexture( self.this, Settings.model[self.element:getModel()].main, self.element )
		destroyElement( self.this )
	end
end