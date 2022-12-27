local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)
local camera = workspace.CurrentCamera
local plr = globals.Players.LocalPlayer
local remotesFolder = plr:WaitForChild("Remotes")
local characterState = plr:WaitForChild("CharacterState")
local stance = characterState.Stance
local leaning = characterState.Leaning
local changeState = remotesFolder.ChangeState
local userInputList = {}

local module = {}
function module.LoadModule()
    task.spawn(function()
        plr.CharacterAdded:Connect(function(char)
            print("Character Has been added")
            local humanoid = char:WaitForChild("Humanoid")
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
end
return module