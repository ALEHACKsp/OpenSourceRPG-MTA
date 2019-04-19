Matte = inherit(Class)

function Matte:constructor(Element, cubeBlurry, cubeSharp)
	self.properites = {}
	self.this = dxCreateShader("res/fx/matte.fx", 0, 0, false, "vehicle");
	self.element = Element
	self.properites["texture"] = self:createTexture(64, 64, 255, 255, 255, 255)
	self.properites["cubeBlurry"] = cubeBlurry;
	self.properites["cubeSharp"] = cubeSharp;
	self:init()
end

function Matte:updateValue()
	dxSetShaderValue( self.this, "gTexture", self.properites["texture"])
	dxSetShaderValue( self.this, "cubeBlurry", self.properites["cubeBlurry"])
	dxSetShaderValue( self.this, "cubeSharp", self.properites["cubeSharp"])
end

function Matte:init()
	self:updateValue()
	if Settings.model[self.element:getModel()] and Settings.model[self.element:getModel()].main then
		engineApplyShaderToWorldTexture( self.this, Settings.model[self.element:getModel()].main, self.element )
	else
		error("Matte shader init error not find main texture model "..tostring(self.element:getModel()))
	end
end

function Matte:destructor()
	if isElement(self.this) then
		engineRemoveShaderFromWorldTexture( self.this, Settings.model[self.element:getModel()].main, self.element )
		destroyElement( self.this )
	end
end