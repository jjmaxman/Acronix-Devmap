local module = {}
module.ReplicatedStorage = game:GetService("ReplicatedStorage")
module.ServerScriptService = game:GetService("ServerScriptService")
module.ServerStorage = game:GetService("ServerStorage")
module.Players = game:GetService("Players")
module.KeyBinds = module.ServerStorage.Keybinds
module.Remotes = module.ReplicatedStorage.Remotes
module.KeyBindRemotes = module.Remotes.KeyBindRemotes
module.ChangeKeyBind = module.KeyBindRemotes.ChangeKeyBind
module.UserInputService = game:GetService("UserInputService")
return module
