local modules = script:GetDescendants()

local main = {}
main.LoadModules = function()
	repeat task.wait() until game:IsLoaded()
	for _, module in ipairs(modules) do
		if module:IsA("ModuleScript") and not module.Parent:IsA("ModuleScript") then
			local loadedModule = require(module)
			loadedModule.LoadModule()
		end
	end
end
return main