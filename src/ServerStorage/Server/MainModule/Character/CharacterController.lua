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

            plr.CharacterAdded:Connect(function(char)
                repeat task.wait() until char.Parent ~= nil
                local humanoid = char:WaitForChild("Humanoid")
                if humanoid then
                    local leaningTracks = {
                        ["LeanRightTrack"] = humanoid.Animator:LoadAnimation(globals.CharacterAnimations.LeanRight);
                        ["LeanLeftTrack"] = humanoid.Animator:LoadAnimation(globals.CharacterAnimations.LeanLeft);
                    }

                    local stanceTracks = {
                        ["CrouchingTrack"] = humanoid.Animator:LoadAnimation(globals.CharacterAnimations.Crouch);
                        ["ProneTrack"] = humanoid.Animator:LoadAnimation(globals.CharacterAnimations.Prone);
                    }

                    local animationHandler = function(newStance, animationsTable)
                        task.spawn(function()
                            for _, track in pairs(animationsTable) do
                                track:Stop()
                            end
                        end)
                        if newStance ~= "" and newStance ~= "Sprinting" then
                            animationsTable[newStance.."Track"]:Play()
                        end
                    end

                    local charStateChanges = {
                        ["Stance"] = stance.Changed:Connect(function(newStance)
                            animationHandler(newStance, stanceTracks)
                        end);

                        ["Leaning"] =  leaning.Changed:Connect(function(newStance)
                            animationHandler(newStance, leaningTracks)
                        end);
                    }

                    humanoid.Died:Connect(function()
                        for _, connections in pairs(charStateChanges) do
                            connections:Disconnect()
                        end
                    end) 
                end
            end)

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
                else
                    stance.Value = ""
                    leaning.Value = ""
                end
            end)
        end)
    end)
end

return module