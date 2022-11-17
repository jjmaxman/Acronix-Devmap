local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)
local usefulFunctions = require(game:GetService("ReplicatedStorage").Utilities.UsefulFunctions)
local plr = globals.Players.LocalPlayer
local weaponInfo = plr:WaitForChild('WeaponInfo')
local primary = weaponInfo.Primary
local secondary = weaponInfo.Secondary
local currentWeapon = weaponInfo.CurrentWeapon
local currentWeaponValue
local remotes = plr.Remotes
local shoot = remotes.Shoot
local weaponsFolder = globals.Weapons
local humanoidRootpart
local currentModule
local currentViewModel
local modifier = 0
local aimModifier = 1
local charSpeed = 0

local walking = false
local aiming = false
local shooting = false
local canShoot = true

local weaponWalkingMovementCF = CFrame.new()
local idleSwayCF = CFrame.new()
local movementRotCF = CFrame.new()
local lastHumanoidRootCF = CFrame.new()
local aimCF = Vector3.new()

local module = {}
module.LoadModule = function()

	local char
	plr.CharacterAdded:Connect(function(character)
		char = character
		currentWeaponValue = weaponInfo:FindFirstChild(currentWeapon.Value)
		currentModule = require(weaponsFolder:FindFirstChild(currentWeaponValue.Value).Module.MainModule)
		if currentModule:CreateOffsets(currentWeaponValue, currentModule:GetOffsets()) and currentModule:CreateLerps(currentWeaponValue, currentModule.Lerps) then
			currentViewModel = weaponsFolder:FindFirstChild(currentWeaponValue.Value).Model.Weapon:Clone()
			currentViewModel.Parent = globals.Camera
			humanoidRootpart = char:WaitForChild("HumanoidRootPart")
		end

		char:WaitForChild("Humanoid").Running:Connect(function(speed)
			--modifier = usefulFunctions.lerpNumber(modifier,(speed/160)*aimModifier,1)
			charSpeed = speed
			if speed > 1 and speed <= 16 then
				walking = true
			else
				walking = false
			end
		end)
	end)
	
	--Main Run Service loop I'll clean this shit up later--
	globals.RunService.RenderStepped:Connect(function(dt)
		if currentViewModel ~= nil then
			local delta = globals.UserInputService:GetMouseDelta()
			currentModule.currentSprings.SwaySpring:shove(Vector3.new(delta.X/600,delta.Y/600))


			currentViewModel:PivotTo(globals.Camera.CFrame
				*currentWeaponValue.Offsets.WeaponOffsetCF.Value
				*weaponWalkingMovementCF
				*idleSwayCF
				*movementRotCF
			)
			
			local weapLin, weapRot, camRot = currentModule.currentSprings:UpdateRecoilSprings(dt)
			
			
			if aiming then
				aimCF = currentWeaponValue.Offsets.AimOffsetCF.Value.Position * currentWeaponValue.Lerps.Aim.Value
			else
				aimCF = currentWeaponValue.Offsets.AimOffsetCF.Value.Position * currentWeaponValue.Lerps.Aim.Value
			end

			modifier = usefulFunctions.lerpNumber(modifier, (charSpeed/160)*aimModifier, 1)

			local swayer = currentModule.currentSprings.SwaySpring:update(dt)
			local bobMovement = Vector3.new(usefulFunctions.getBobbing(5, 1, modifier), usefulFunctions.getBobbing(2.5,4,modifier), usefulFunctions.getBobbing(5,4,modifier))
			currentModule.currentSprings.BobSpring:shove(bobMovement*dt*60)
			local walkCycle = currentModule.currentSprings.BobSpring:update(dt)
			currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(walkCycle.x/2,walkCycle.y/2,0)) --* CFrame.Angles(0,walkCycle.y/2, walkCycle.x/2)) No clue how I'm gonna impliment angles yet
			
			globals.Camera.CFrame = globals.Camera.CFrame * CFrame.Angles(camRot.X,camRot.Y,camRot.Z)
			currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(weapLin.X,weapLin.Y,weapLin.Z) * CFrame.Angles(weapRot.X,weapRot.Y,weapRot.Z))
			currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.Angles(-swayer.y,-swayer.x,swayer.y))
			currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(aimCF.x,aimCF.y,aimCF.z))

			if not walking then
				currentModule.currentSprings.IdleSpring:shove(Vector3.new(usefulFunctions.getBobbing(5, 1, modifier), usefulFunctions.getBobbing(2.5,4,modifier), usefulFunctions.getBobbing(5,4,modifier)))
				local idleSpring = currentModule.currentSprings.IdleSpring:update(dt)
				currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(idleSpring.x,idleSpring.y,0))
			end
		end
	end)
	
	
	--User Input--
	globals.UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe then
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				if currentWeapon ~= nil then
					aiming = true
					aimModifier = .35
					usefulFunctions.tweenVal(currentModule.AimIn, currentWeaponValue.Lerps.Aim, 1)
				end
			end
			
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				shooting = true
			end
		end
	end)

	globals.UserInputService.InputEnded:Connect(function(input, gpe)
		if not gpe then
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				if currentWeapon ~= nil then
					aiming = false
					aimModifier = 1
					usefulFunctions.tweenVal(currentModule.AimOut, currentWeaponValue.Lerps.Aim, 0)
				end
			end
			
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				shooting = false
			end
		end
	end)

	
	globals.RunService.RenderStepped:Connect(function(dt)
		if currentModule and currentWeapon then
			if canShoot then
				while true do
					canShoot = false
					if not shooting then
						currentModule.HeatValue = 1
						canShoot = true
						break
					end
					canShoot = false
					shoot:FireServer(currentViewModel.Hole.Position, currentViewModel.BarrelHole.Position)
					currentModule:GenerateRecoil(currentModule.currentSprings.CameraRecoilSpring, dt)
					currentModule:GenerateWeapRecoil(currentModule.currentSprings.WeaponLinearRecoilSpring, dt)
					currentModule:GenerateWeapRotRecoil(currentModule.currentSprings.WeaponRotRecoilSpring, dt)
					task.wait(60/currentModule.RPM)
					currentModule.currentSprings.CameraRecoilSpring:shove(Vector3.new())
					currentModule.currentSprings.WeaponRotRecoilSpring:shove(Vector3.new())
					currentModule.currentSprings.WeaponLinearRecoilSpring:shove(Vector3.new())
					
					canShoot = true
				end
			end
		end
	end)
	
end
return module
