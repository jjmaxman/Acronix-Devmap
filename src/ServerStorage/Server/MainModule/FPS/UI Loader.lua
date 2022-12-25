local players = game:GetService("Players")
local starterGui = game:GetService("StarterGui")

local function LoadGuis(player, addAll)
    for _, gui in ipairs(starterGui:GetChildren()) do
        task.spawn(function()
            if gui.ResetOnSpawn or addAll == true then
                gui:Clone().Parent = player:WaitForChild("PlayerGui")
            end
        end)
    end
end

local module = {}
function module.LoadModule() 
    print("poo")
    --[[players.PlayerAdded:Connect(function(player)
        LoadGuis(player, true)
        player.CharacterAdded:Connect(function(char)
            LoadGuis(player, false)
        end)
    end)]]--
end
return module