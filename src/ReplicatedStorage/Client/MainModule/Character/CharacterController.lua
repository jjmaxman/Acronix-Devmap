local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera
local plr = globals.Players.LocalPlayer
local remotesFolder = plr:WaitForChild("Remotes")
local characterState = plr:WaitForChild("CharacterState")
local stance = characterState.Stance
local leaning = characterState.Leaning
local changeState = remotesFolder.ChangeState
local headMovement = remotesFolder:WaitForChild("HeadMovement")
local userInputList = {}

local module = {}
function module.LoadModule()
    task.spawn(function()
        plr.CharacterAdded:Connect(function(char)
            local humanoid = char:WaitForChild("Humanoid")
            local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
            local lowerTorso = char:WaitForChild("LowerTorso")
            local head = char:WaitForChild("Head")
            local rightUpperArm = char:WaitForChild("RightUpperArm")
            local leftUpperArm = char:WaitForChild("LeftUpperArm")

            local rightShoulder: Motor6D = rightUpperArm.RightShoulder
            local leftShoulder: Motor6D = leftUpperArm.LeftShoulder
            local neck: Motor6D = head.Neck

            --Prelim animations (Might change this later)--
            local weaponHoldTrack = humanoid.Animator:LoadAnimation(globals.CharacterAnimations.WeaponHold)
            weaponHoldTrack:Play()

            --User input--
            local inputBegan = globals.UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe then
                    --Make sure these get replaced with player's custom keybinds--
                    if input.KeyCode == Enum.KeyCode.LeftShift then
                        changeState:FireServer("Sprint")
                    end

                    if input.KeyCode == Enum.KeyCode.C then
                        changeState:FireServer("LowerStance")
                    end

                    if input.KeyCode == Enum.KeyCode.X then
                        changeState:FireServer("RaiseStance")
                    end
                    
                    if input.KeyCode == Enum.KeyCode.E then
                        changeState:FireServer("LeanRight")
                    end

                    if input.KeyCode == Enum.KeyCode.Q then
                        changeState:FireServer("LeanLeft")
                    end
                end
            end)

            local inputEnded = globals.UserInputService.InputEnded:Connect(function(input, gpe)
                if not gpe then
                    if input.KeyCode == Enum.KeyCode.LeftShift then
                        changeState:FireServer("SprintEnd")
                    end
                end
            end)

            userInputList["HeadMovement"] = globals.RunService.RenderStepped:Connect(function(dt)
                local cameraDir = camera.CFrame.LookVector - Vector3.new(0,math.rad(lowerTorso.Orientation.X),0)
                neck.C0 = CFrame.new(0,.8,0) * CFrame.Angles(cameraDir.Y,0,0)
            end)

            task.spawn(function()
                while humanoid.Health > 0 do
                    headMovement:FireServer(neck.C0)
                    task.wait(.075)
                end
            end)

            userInputList["InputBegan"] = inputBegan
            userInputList["InputEnded"] = inputEnded

            --Memory management--
            humanoid.Died:Connect(function()
                for _, connection in pairs(userInputList) do
                    connection:Disconnect()
                end
            end)
        end)
    end)

    headMovement.OnClientEvent:Connect(function(neck, rotation)
        local tween = TweenService:Create(neck, TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {C0 = rotation})

        tween:Play()
    end)
end
return module