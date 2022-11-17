local modules = script:GetDescendants()

local module = {}
module.LoadServerModules = function()
	for _, modules in ipairs(modules) do
		if modules:IsA("ModuleScript") and not modules.Parent:IsA("ModuleScript") then
			local requiredModule = require(modules)
			requiredModule.LoadModule()
		end
	end
end
return module
