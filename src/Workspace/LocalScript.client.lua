local laser = workspace:WaitForChild("LAZER")
local runservice = game:GetService("RunService")

local laserDot = Instance.new("Part")
laserDot.Shape = Enum.PartType.Ball
laserDot.Size = Vector3.new(.25,.25,.25)
laserDot.Color = Color3.fromRGB(255,0,0)
laserDot.Material = Enum.Material.Neon
laserDot.CanCollide = false
laserDot.CanTouch = false
laserDot.Anchored = true

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {laser}

runservice.RenderStepped:Connect(function(dt)
	if laserDot.Parent ~= laser then
		laserDot.Parent = laser
	end
	local laserRay = workspace:Raycast(laser.Attachment.WorldPosition, (laser.Attachment1.WorldPosition - laser.Attachment.WorldPosition)*1000, raycastParams)
	
	if laserRay then
		laserDot.Position = laserRay.Position
	else 
		laserDot.Position = (laser.Attachment1.WorldPosition - laser.Attachment.WorldPosition)* 1000
	end
end)