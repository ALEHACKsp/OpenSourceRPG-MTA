function onClientResourceStartShaderVehicle()
	Manager = shaderManager:new();
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStartShaderVehicle)

function onClientResourceStopShaderVehicle()
	if Manager then
		Manager:destructor();
	end
end
addEventHandler( "onClientResourceStop", resourceRoot, onClientResourceStopShaderVehicle)