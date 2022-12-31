local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)
local fpsServer = require(script.FPS_Server)
local remotesFolder = game:GetService("ServerStorage").Remotes

local module = {}
module.LoadModule = function()
	local bulletFolder = Instance.new("Folder")
	bulletFolder.Name = "BulletFolder"
	bulletFolder.Parent = workspace
	
	globals.Players.PlayerAdded:Connect(function(plr)
		--Plr weapon data
		local weaponInfo = Instance.new("Folder")
		weaponInfo.Name = "WeaponInfo"
		weaponInfo.Parent = plr
		
		local primary = Instance.new("StringValue")
		primary.Name = "Primary"
		primary.Value = "HK416"
		primary:SetAttribute("Ammo", 0)
		primary.Parent = weaponInfo
		
		local secondary = Instance.new("StringValue")
		secondary.Name = "Secondary"
		secondary:SetAttribute("Ammo", 0)
		secondary.Parent = weaponInfo
		
		local currentWeapon = Instance.new("StringValue")
		currentWeapon.Name = "CurrentWeapon"
		currentWeapon.Value = "Primary"
		currentWeapon.Parent = weaponInfo
		
		local plrRemotesFolder = remotesFolder:Clone()
		plrRemotesFolder.Parent = plr

		local characterState = Instance.new("Folder")
		characterState.Name = "CharacterState"
		characterState.Parent = plr
		
		local stance = Instance.new("StringValue")
		stance.Name = "Stance"
		stance.Parent = characterState

		local leaning = Instance.new("StringValue")
		leaning.Name = "Leaning"
		leaning.Parent = characterState
		
		fpsServer.LoadModule(plr, weaponInfo, plrRemotesFolder)
		
		plr.CharacterAdded:Connect(function(char)
			local humanoid = char:WaitForChild("Humanoid")
			humanoid.Died:Connect(function()
				task.wait(1)
				plr:LoadCharacter()
			end)
		end)
		
		task.wait(3)
		
		plr:LoadCharacter()
		
	end)
end
return module
