local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)
local fastCast = require(game.ReplicatedStorage.Utilities.FastCastRedux)
local usefulFunctions = require(game.ReplicatedStorage.Utilities.UsefulFunctions)

local module = {}
module.LoadModule = function(plr, weaponInfo, remotesFolder)
	task.spawn(function()
		print("FPS module has been loaded for "..plr.Name)
		local primary = weaponInfo.Primary
		local secondary = weaponInfo.Secondary
		local currentWeapon = weaponInfo.CurrentWeapon

		local char

		local currentModule

		plr.CharacterAdded:Connect(function(chararacter)
			char = chararacter
			local currentWeaponValue = weaponInfo:FindFirstChild(currentWeapon.Value)
			currentModule = require(globals.Weapons:FindFirstChild(currentWeaponValue.Value).Module.MainModule)
			currentWeaponValue:SetAttribute("Ammo", currentModule.MaxAmmo)
		end)

		--//Functions\\--
		local function LengthChanged(cast, lastPoint, dir, length, velocity, bullet)
			if bullet then
				local bulletLength = bullet.Size.Z/2
				local offset = CFrame.new(0,0,-(length-bulletLength))
				bullet.CFrame = CFrame.lookAt(lastPoint, lastPoint + dir):ToWorldSpace(offset)
			end
		end

		local function onRayHit(cast, result, velocity, bullet)
			local char = result.Instance.Parent
			if char:FindFirstChild("Humanoid") then
				local humanoid = char:FindFirstChild("Humanoid")
				local listName = usefulFunctions.GetInstanceWithPartialString(result.Instance, currentModule.Damage)
				
				if listName then
					humanoid:TakeDamage(currentModule.Damage[listName])
				end
			end
		end

		repeat task.wait() until char ~= nil

		local newCast = fastCast.new()
		local behaivior = fastCast.newBehavior()

		local castParams = RaycastParams.new()
		castParams.FilterType = Enum.RaycastFilterType.Blacklist
		castParams.FilterDescendantsInstances = {workspace.BulletFolder, workspace.Terrain, plr.Character or plr.CharacterAdded:Wait()}
		castParams.IgnoreWater = true

		--fastCast.VisualizeCasts = true

		behaivior.RaycastParams = castParams
		behaivior.AutoIgnoreContainer = true
		behaivior.Acceleration = Vector3.new(0,-workspace.Gravity, 0)
		behaivior.CosmeticBulletTemplate = game.ServerStorage.GameInstances.BulletTemplate:Clone()
		behaivior.CosmeticBulletContainer = workspace.BulletFolder
		behaivior.MaxDistance = 100000

		remotesFolder.Shoot.OnServerEvent:Connect(function(_plr, startPos, endPos)
			if _plr == plr then
				newCast:Fire(startPos, (endPos-startPos).Unit, currentModule.BulletVelocity, behaivior)
			end
		end)

		newCast.RayHit:Connect(onRayHit)
		newCast.LengthChanged:Connect(LengthChanged)
	end)
end
return module
