local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)
local usefulFunctions = require(game:GetService("ReplicatedStorage").Utilities.UsefulFunctions)
local springModule = require(game:GetService("ReplicatedStorage").Utilities.spring)
local plr = globals.Players.LocalPlayer
local plrGui = plr.PlayerGui
local weaponInfo = plr:WaitForChild('WeaponInfo')
local characterState = plr:WaitForChild("CharacterState")
local stance = characterState.Stance
local leaning = characterState.Leaning
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
local sprinting = false
local aiming = false
local shooting = false
local canShoot = true

local weaponWalkingMovementCF = CFrame.new()
local idleSwayCF = CFrame.new()
local movementRotCF = CFrame.new()
local lastHumanoidRootCF = CFrame.new()
local aimCF = Vector3.new()
local sprintV3Lin = Vector3.new()
local sprintV3Rot = Vector3.new

--Springs--
local springs = {
	["LeanSpring"] = springModule.create();
	["StanceSpring"] = springModule.create();
	["WalkSpring"] = springModule.create();
	["MovementRot"] = springModule.create();
	["CollisionSpring"] = springModule.create();
}


local module = {}
module.LoadModule = function()
	task.spawn(function()

		globals.UserInputService.MouseIconEnabled = false

		local char
		local humanoidRootPart
		local animationTracks
		plr.CharacterAdded:Connect(function(character)
			char = character
			currentWeaponValue = weaponInfo:FindFirstChild(currentWeapon.Value)
			currentModule = require(weaponsFolder:FindFirstChild(currentWeaponValue.Value).Module.MainModule)
			if currentModule:CreateOffsets(currentWeaponValue, currentModule:GetOffsets()) and currentModule:CreateLerps(currentWeaponValue, currentModule.Lerps) then
				currentViewModel = weaponsFolder:FindFirstChild(currentWeaponValue.Value).Model.Weapon:Clone()
				currentViewModel.Parent = globals.Camera
				local animationController = currentModule.AnimationController.Create(currentViewModel.AnimationController)
				animationController.AnimationController = currentViewModel.AnimationController
				animationTracks = animationController:LoadAnimations()

				animationController:PlayAnimation(animationTracks.IdleTrack, currentViewModel)

				--currentModule.EquipViewModel(currentViewModel.Humanoid)
				humanoidRootPart = char:WaitForChild("HumanoidRootPart")
			end
			remotes.EquipWeapon:FireServer(currentWeaponValue.Value, currentWeapon.Value)
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

		--Functions--
		local function fireSequence(dt)
			shoot:FireServer(currentViewModel.weapon.Hole.Position, currentViewModel.weapon.BarrelHole.Position)
			currentModule:GenerateRecoil(currentModule.currentSprings.CameraRecoilSpring, dt)
			currentModule:GenerateWeapRecoil(currentModule.currentSprings.WeaponLinearRecoilSpring, dt)
			currentModule:GenerateWeapRotRecoil(currentModule.currentSprings.WeaponRotRecoilSpring, dt)
			task.wait(60/currentModule.RPMs[currentModule.CurrentFireMode])
			currentModule.currentSprings.CameraRecoilSpring:shove(Vector3.new())
			currentModule.currentSprings.WeaponRotRecoilSpring:shove(Vector3.new())
			currentModule.currentSprings.WeaponLinearRecoilSpring:shove(Vector3.new())
		end


		repeat task.wait() until humanoidRootPart ~= nil
		local oldHRPpos = humanoidRootPart.CFrame

		local collisionsDetectionParams = RaycastParams.new()
		collisionsDetectionParams.FilterDescendantsInstances = {globals.Camera, char}

		--Main Run Service loop I'll clean this shit up later--
		globals.RunService.RenderStepped:Connect(function(dt)
			if currentViewModel ~= nil then
				local delta = globals.UserInputService:GetMouseDelta()
				currentModule.currentSprings.SwaySpring:shove(Vector3.new(delta.X/400,delta.Y/400))


				local camLean = springs.LeanSpring:update(dt)
				local camStance = springs.StanceSpring:update(dt)
				globals.Camera.CFrame = globals.Camera.CFrame * CFrame.new(camLean.x,0,0) * CFrame.new(0,camStance.y,0) * CFrame.Angles(0,0,math.rad(camLean.z))

				currentViewModel:PivotTo(globals.Camera.CFrame
					*currentWeaponValue.Offsets.WeaponOffsetCF.Value
					*weaponWalkingMovementCF
					*idleSwayCF
					*movementRotCF
				)
				
				local hRootDelta = humanoidRootPart.CFrame:Inverse() * oldHRPpos
				springs.MovementRot:shove(hRootDelta)
				local answer = springs.MovementRot:update(dt)
				currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.Angles(-answer.Z/6,0,answer.X/4))
				oldHRPpos = humanoidRootPart.Position
				
				if walking then
					local camBob = Vector3.new(math.rad(.1* math.sin(tick()*10)),0,math.rad(.1*math.sin(tick()*10)))*dt*60
					springs.WalkSpring:shove(camBob)
					
				elseif sprinting then
					local camBob = Vector3.new(math.rad(.3* math.sin(tick()*14)),0,math.rad(.3*math.sin(tick()*14)))*dt*60
					springs.WalkSpring:shove(camBob)
					currentModule.currentSprings.IdleSpring:shove(Vector3.new(usefulFunctions.getBobbing(10, 27, modifier), usefulFunctions.getBobbing(2.5,12,modifier), usefulFunctions.getBobbing(5,27,modifier)))
					local idleSpring = currentModule.currentSprings.IdleSpring:update(dt)
					currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(idleSpring.x,idleSpring.y,0))
				elseif not walking and not sprinting then
					local camBob = Vector3.new(0,0,0)
					springs.WalkSpring:shove(camBob)
				end

				local camBobupdated = springs.WalkSpring:update(dt)
				globals.Camera.CFrame = globals.Camera.CFrame * CFrame.Angles(camBobupdated.X,0,camBobupdated.Z)


				local weapLin, weapRot, camRot = currentModule.currentSprings:UpdateRecoilSprings(dt)


				aimCF = currentWeaponValue.Offsets.AimOffsetCF.Value.Position * currentWeaponValue.Lerps.Aim.Value --Aiming
				local camAimCF = Vector3.new(0,0,math.rad(-7))*currentWeaponValue.Lerps.Aim.Value -- Camera Aiming
				sprintV3Rot = currentWeaponValue.Offsets.SprintOffsetV3Rot.Value * currentWeaponValue.Lerps.Sprint.Value
				sprintV3Lin = currentWeaponValue.Offsets.SprintOffsetV3Lin.Value * currentWeaponValue.Lerps.Sprint.Value

				modifier = usefulFunctions.lerpNumber(modifier, (charSpeed/160)*aimModifier, 1)

				local swayer = currentModule.currentSprings.SwaySpring:update(dt)
				local bobMovement = Vector3.new(usefulFunctions.getBobbing(5, 1, modifier), usefulFunctions.getBobbing(2.5,4,modifier), usefulFunctions.getBobbing(5,4,modifier))
				currentModule.currentSprings.BobSpring:shove(bobMovement*dt*60)
				local walkCycle = currentModule.currentSprings.BobSpring:update(dt)
				currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(walkCycle.x/2,walkCycle.y/2,0)) --* CFrame.Angles(0,walkCycle.y/2, walkCycle.x/2)) No clue how I'm gonna impliment angles yet

				globals.Camera.CFrame = globals.Camera.CFrame * CFrame.Angles(camRot.X,camRot.Y,camRot.Z)
				currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(weapLin.X,weapLin.Y,weapLin.Z) * CFrame.Angles(weapRot.X,weapRot.Y,weapRot.Z))
				currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.Angles(-swayer.y,-swayer.x,swayer.y))
				currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(aimCF.X,aimCF.Y,aimCF.Z))
				currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.Angles(sprintV3Rot.X,sprintV3Rot.Y,sprintV3Rot.Z) * CFrame.new(sprintV3Lin.X, sprintV3Lin.Y, sprintV3Lin.Z))

				globals.Camera.CFrame = globals.Camera.CFrame * CFrame.Angles(0,0,camAimCF.Z)

				if walking then

				elseif not walking and not sprinting then
					currentModule.currentSprings.IdleSpring:shove(Vector3.new(0,0,0))
					local idleSpring = currentModule.currentSprings.IdleSpring:update(dt)
					currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(idleSpring.x,idleSpring.y,0))
				end

				--Viewmodel Collision detection--
				local collisionCast = workspace:Raycast(currentViewModel.weapon.Back.Position, (currentViewModel.weapon.BarrelHole.Position - currentViewModel.weapon.Back.Position), collisionsDetectionParams)
				
				if collisionCast then
					if sprinting ~= true then
						local castDist = collisionCast.Distance
						local holeDist = (currentViewModel.weapon.BarrelHole.Position - currentViewModel.weapon.Back.Position).Magnitude
						if castDist <= holeDist and castDist > 6 then
							local dist = castDist - holeDist
							local vector = Vector3.new(0,-dist,0)
							--Vector3.new(0,1,60) Rotation thingy lol
							springs.CollisionSpring:shove(vector)
						elseif castDist <= holeDist and castDist < 6 then
							local vector = Vector3.new(0,1,60)
							springs.CollisionSpring:shove(vector)
						end
					end
				end

				local updatedCollisionSpring = springs.CollisionSpring:update(dt)
				currentViewModel:PivotTo(currentViewModel.PrimaryPart.CFrame * CFrame.new(0,0,updatedCollisionSpring.Y) * CFrame.Angles(0,math.rad(updatedCollisionSpring.Z),0))
			end
		end)


		--User Input--
		globals.UserInputService.InputBegan:Connect(function(input, gpe)
			if not gpe then
				if input.KeyCode == Enum.KeyCode.LeftShift then -- Replace with player keybind in the future.
					sprinting = true

					usefulFunctions.tweenVal(1.5, currentWeaponValue.Lerps.Sprint, 1, Enum.EasingStyle.Exponential)
					char.Humanoid.WalkSpeed = currentModule.WalkSpeed
				end

				if input.KeyCode == Enum.KeyCode.V then --Fire Mode switching (Replace with player keybind in the future)--
					shooting = false
					for index, mode in next, currentModule.FireModes do
						if currentModule.CurrentFireMode == mode then
							local numOfFireModes = #currentModule.FireModes
							if index < numOfFireModes then
								currentModule.CurrentFireMode = currentModule.FireModes[index + 1]
								break
							elseif index == numOfFireModes then
								currentModule.CurrentFireMode = currentModule.FireModes[1]
								break
							end
						end
					end
				end

				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					if currentWeapon ~= nil then
						aiming = true
						aimModifier = .35
						usefulFunctions.tweenVal(currentModule.AimIn, currentWeaponValue.Lerps.Aim, 1, Enum.EasingStyle.Quint)
					end
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					shooting = true
				end
			end
		end)

		globals.UserInputService.InputEnded:Connect(function(input, gpe)
			if not gpe then
				if input.KeyCode == Enum.KeyCode.LeftShift then
					sprinting = false
					usefulFunctions.tweenVal(1, currentWeaponValue.Lerps.Sprint, 0, Enum.EasingStyle.Exponential)
					char.Humanoid.WalkSpeed = 7
				end

				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					if currentWeapon ~= nil then
						aiming = false
						aimModifier = 1
						usefulFunctions.tweenVal(currentModule.AimOut, currentWeaponValue.Lerps.Aim, 0, Enum.EasingStyle.Quint)
					end
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					shooting = false
				end
			end
		end)

		--Shooting--
		globals.RunService.RenderStepped:Connect(function(dt)
			if currentModule and currentWeapon then
				if canShoot then
					if currentModule.CurrentFireMode == "Auto" then --Auto--
						while true do
							canShoot = false
							if not shooting then
								currentModule.HeatValue = 1
								canShoot = true
								break
							end
							canShoot = false
							fireSequence(dt)

							canShoot = true
						end
					elseif currentModule.CurrentFireMode == "Semi" then --Semi--
						if shooting then
							canShoot = false
							shooting = false
							fireSequence(dt)
							canShoot = true
						end
					elseif currentModule.CurrentFireMode == "Burst" then --Burst--
						if shooting then
							canShoot = false
							for i = 1,3,1 do
								if shooting == false then
									break
								end
								fireSequence(dt)
							end
							task.wait(currentModule.BurstDelayTime)
							shooting = false
							canShoot = true
						end
					end
				end
			end
		end)

		--Character Code--
		local leaningValue = leaning.Value
		local stanceValue = stance.Value
		globals.RunService.RenderStepped:Connect(function(dt)
			if leaning.Value ~= leaningValue then
				if leaning.Value == "LeanRight" then
					springs.LeanSpring:shove(Vector3.new(1,0,-10)*dt*60)
				elseif leaning.Value == "LeanLeft" then
					springs.LeanSpring:shove(Vector3.new(-1,0,10)*dt*60)
				end
			end

			if stance.Value ~= stanceValue then
				if stance.Value == "Crouching" then
					springs.StanceSpring:shove(Vector3.new(0,-1,0)*dt*60)
				elseif stance.Value == "Prone" then
					springs.StanceSpring:shove(Vector3.new(0,-2,0)*dt*60)
				end
			end
		end)


		--Gui Code--
		--Temp--
		local fireModeIndicatorGui = plrGui:WaitForChild("ScreenGui")
		local label = fireModeIndicatorGui.FireModeIndicator
		local lastName = label.Text
		globals.RunService.Heartbeat:Connect(function()
			if lastName ~= currentModule.CurrentFireMode then
				lastName = currentModule.CurrentFireMode
				label.Text = currentModule.CurrentFireMode
			end
		end)
		--Temp--

	end)
end
return module
