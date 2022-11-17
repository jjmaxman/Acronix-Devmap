local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)
local clientModules = require(globals.Client.MainModule)

clientModules.LoadModules()






--[[local collectionService = game:GetService("CollectionService")

collectionService:GetInstanceAddedSignal("Laser"):Connect(function(laser)
	local dot = Instance.new("Part")
	dot.Material = Enum.Material.Neon
	dot.Shape = Enum.PartType.Ball
	dot.Size = Vector3.new(.25,.25,.25)
	dot.Anchored = true
	dot.Color = Color3.fromRGB(0,255,0)
	dot.CanCollide = false
	dot.CanTouch = false

	local beam = Instance.new("Part")
	beam.Material = Enum.Material.Neon
	beam.Transparency = 1
	beam.Size = Vector3.new(.01,.01,.01)
	beam.Anchored = true
	beam.Color = Color3.fromRGB(0,255,0)
	beam.CanCollide = false
	beam.CanTouch = false

	local castParams = RaycastParams.new()
	castParams.FilterType = Enum.RaycastFilterType.Blacklist
	castParams.FilterDescendantsInstances = {dot, beam, laser}


	game:GetService("RunService").RenderStepped:Connect(function(dt)
		if dot.Parent ~= laser then
			dot.Parent = laser
			beam.Parent = laser
		end

		local ray = workspace:Raycast(laser.Attachment.WorldPosition, (laser.Attachment1.WorldPosition - laser.Attachment.WorldPosition)*1000, castParams)

		if ray then
			local pos = ray.Position
			local dist = ray.Distance
			dot.Position = pos
			beam.Size = Vector3.new(.01,.01,dist)
			beam.CFrame = CFrame.new(laser.Attachment.WorldPosition, pos) * CFrame.new(0,0,-dist/2)
		else
			local pos = (laser.Attachment1.WorldPosition - laser.Attachment.WorldPosition).Unit * 1000
			local dist = pos.magnitude
			local rayDir = laser.CFrame.LookVector
			dot.CFrame = laser.CFrame * CFrame.new(0,0,-dist)
			beam.Size = Vector3.new(.01,.01,dist)
			beam.PivotOffset = CFrame.new(0,0,-dist/2)
			beam.CFrame = laser.CFrame * CFrame.new(0,0,-dist/2)
		end
	end)
end)]]--