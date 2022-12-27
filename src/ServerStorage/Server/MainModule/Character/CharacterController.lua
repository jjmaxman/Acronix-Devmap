local globals = require(game:GetService("ReplicatedStorage").Utilities.Globals)

local module = {}

function module.LoadModule()
    task.spawn(function()
        globals.Players.PlayerAdded:Connect(function(plr)
            local remotes = plr:WaitForChild("Remotes")
            local characterState = plr:WaitForChild("CharacterState")
            local stance = characterState.Stance
            local leaning = characterState.Leaning
            local changeState = remotes.ChangeState

            changeState.OnServerEvent:Connect(function(plr, action)
                local char = plr.Character
                if char ~= nil and char:FindFirstChild("Humanoid") then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid.Health > 0 then
                        
                        if action == "Sprint" then
                            stance.Value = "Sprinting"
                            leaning.Value = ""
                        elseif action == "SprintEnd" then
                            if stance.Value == "Sprinting" then
                                stance.Value = ""
                            end
                        elseif action == "LowerStance" then
                            if stance.Value == "" then
                                stance.Value = "Crouching"
                            elseif stance.Value == "Crouching" then
                                stance.Value = "Prone"
                                leaning.Value = ""
                            elseif stance.Value == "Prone" then
                                stance.Value = "Crouching"
                            end
                        elseif action == "RaiseStance" then
                            if stance.Value == "Prone" then
                                stance.Value = "Crouching" 
                            elseif stance.Value == "Crouching" then
                                stance.Value = ""
                            elseif stance.Value == "" then
                                stance.Value = "Crouching"
                            end
                        elseif action == "LeanRight" then
                            if stance.Value ~= "Prone" then
                                if leaning.Value == "LeanLeft" or leaning.Value == "LeanRight" then
                                    leaning.Value = ""
                                else
                                    leaning.Value = "LeanRight"
                                end
                            end
                        elseif action == "LeanLeft" then
                            if stance.Value ~= "Prone" then
                                if leaning.Value == "LeanLeft" or leaning.Value == "LeanRight" then
                                    leaning.Value = ""
                                else
                                    leaning.Value = "LeanLeft"
                                end
                            end
                        end
                    end
                end
            end)

            stance.Changed:Connect(function(newStance)
                
            end)

            leaning.Changed:Connect(function(newStance)
                
            end)

        end)
    end)
end

return module