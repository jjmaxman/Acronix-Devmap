--Documentation needed like seriously holy shit--


--Variables and modules--
local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)
local folder = script.Parent.Parent
local weaponModel = folder.Model.Weapon
local weapon = weaponModel.weapon
local aimPart = weapon.AimPart
local springModule = require(game:GetService("ReplicatedStorage").Utilities.spring)
local utilities = require(game:GetService("ReplicatedStorage").Utilities.UsefulFunctions)
local aimPartOffset = weapon.AimPart.CFrame:Inverse() * weapon.PrimaryPart.CFrame


--Spring class--
local springs = {}
springs.__index = springs
springs.WeaponLinearRecoilSpring = springModule.create()
springs.WeaponRotRecoilSpring = springModule.create()
springs.CameraRecoilSpring = springModule.create()
springs.SwaySpring = springModule.create()
springs.BobSpring = springModule.create()
springs.IdleSpring = springModule.create()
springs.AimSpring = springModule.create()

function springs:UpdateRecoilSprings(dt)
	return self.WeaponLinearRecoilSpring:update(dt), self.WeaponRotRecoilSpring:update(dt), self.CameraRecoilSpring:update(dt)
end

function springs:ShoveRecoilSpring(springToShove)

end

function springs.CreateSprings()
	local self = {}
	
	return setmetatable(self, springs)
end

local lastWorkingHeatValue = 1


--Weapon Settings + Functions--
local module = {}
module.__index = module
module.currentSprings = springs.CreateSprings()

module.HeatValue = 1 --Higher = Lower Spread

module.AimIn = .7
module.AimOut = .5
module.RPM = 780
module.WalkSpeed = 21
module.WeaponOffsetCF = weapon.CameraPart.CFrame:Inverse() * weapon.PrimaryPart.CFrame
module.BulletVelocity = 3003
module.AimOffsetCF = (aimPartOffset:Inverse() * module.WeaponOffsetCF):Inverse()

--Important Instances
module.Animations = weaponModel.Animations
--(LMAO nvm am stupid these aren't replicated XD)--
--[[module.Hole = weapon.Hole
module.BarrelHole = weapon.BarrelHole]]--


--//Tables\\--
--Lerps--
module.Lerps = {
	Aim = 0
}

--Damage Settings--
module.Damage = {
	["Head"] = 100;
	["UpperTorso"] = 45;
	["LowerTorso"] = 35;
	["UpperArm"] = 27;
	["LowerArm"] = 24;
	["Hand"] = 12;
	["UpperLeg"] = 31;
	["LowerLeg"] = 26;
	["Foot"] = 15;
}

--Animation Functions--
function module.IdleViewModel(humanoid: Humanoid)
	local track: AnimationTrack = humanoid.Animator:LoadAnimation(module.Animations.Idle)
	track:Play()
end
function module.EquipViewModel(humanoid: Humanoid)
	local track: AnimationTrack = humanoid.Animator:LoadAnimation(module.Animations.Equip)
	track.Ended:Once(function()
		print("Track Ended")
		module.IdleViewModel(humanoid)
	end)
	track:Play()
end

--Recoil Settings--
module.recoil = {
	viewModel = {translation = Vector3.new(0,0,.5), rotational = {min = Vector3.new(-0.45,1.49,0.45), max = Vector3.new(0.31,2.04,0.45)}},

	Auto = {
		[1] = {min = Vector3.new(4,0,-10), max = Vector3.new(4.5,0,10)};
		[2] = {min = Vector3.new(3,-.25,-10), max = Vector3.new(4,.25,10)};
		[3] = {min = Vector3.new(2,-.5,-10), max = Vector3.new(3,.5,10)};
		[5] = {min = Vector3.new(1,-.65,-10), max = Vector3.new(1.5,.65,10)};
		[15] = {min = Vector3.new(.75,-.7,-10), max = Vector3.new(1, .7,10)};
	}
}

--External + Recoil functions--
function module:CreateOffsets(parent, offsets)
	if parent:FindFirstChild("Offsets") then
		parent:FindFirstChild("Offsets"):Destroy()
	end

	local offsetFolder = Instance.new("Folder")
	offsetFolder.Name = "Offsets"
	offsetFolder.Parent = parent

	for name, value in pairs(offsets) do
		local newOffsetValue = Instance.new("CFrameValue")
		newOffsetValue.Name = name
		newOffsetValue.Value = value
		newOffsetValue.Parent = offsetFolder
	end

	return true
end

function module:CreateLerps(parent, lerps)
	if parent:FindFirstChild("Lerps") then
		parent:FindFirstChild("Lerps"):Destroy()
	end

	local lerpsFolder = Instance.new("Folder")
	lerpsFolder.Name = "Lerps"
	lerpsFolder.Parent = parent

	for lerp, _ in pairs(lerps) do
		local newLerpVal = Instance.new("NumberValue")
		newLerpVal.Name = lerp
		newLerpVal.Value = 0
		newLerpVal.Parent = lerpsFolder
	end

	return true
end

local function RaiseHeatValue()
	module.HeatValue += 1
end

function module:GenerateRecoil(spring,dt) --Camera recoil
	RaiseHeatValue()
	local currentRecoilValue = module.recoil.Auto[module.HeatValue]
	if currentRecoilValue == nil then
		currentRecoilValue = module.recoil.Auto[lastWorkingHeatValue]
	else
		lastWorkingHeatValue = module.HeatValue
	end

	local conversion = utilities.RandomVector3Angle(currentRecoilValue.min, currentRecoilValue.max,3)
	--local minorEdit = conversion.Z*dt*60

	spring:shove(conversion*dt*60)
end

function module:GenerateWeapRecoil(spring, dt)
	local currentRecoilValue = module.recoil.viewModel.translation
	spring:shove(currentRecoilValue)
end

function module:GenerateWeapRotRecoil(spring, dt)
	local currentRecoilValue = module.recoil.viewModel.rotational
	local newWeapRecoil = utilities.RandomVector3Angle(currentRecoilValue.min, currentRecoilValue.max, 3)
	spring:shove(newWeapRecoil)
end

function module:GetOffsets()
	return {["WeaponOffsetCF"] = module.WeaponOffsetCF, ["AimOffsetCF"] = module.AimOffsetCF}
end
return module
