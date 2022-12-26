local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)
local plr = globals.Players.LocalPlayer
local remotesFolder = plr:WaitForChild("Remotes")
local changeState = remotesFolder.ChangeState
local userInputList = {}

local module = {}
function module.LoadModule()
    task.spawn(function()
        plr.CharacterAdded:Connect(function(char)
            local humanoid = char:WaitForChild("Humanoid")
            local inputBegan = globals.UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe then
                    if input.KeyCode == Enum.KeyCode.LeftShift then
                        changeState:FireServer()
                    end
                end
            end)

            local inputEnded = globals.UserInputService.InputEnded:Connect(function(input, gpe)
                if not gpe then
                    
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