local module = {}
module.Camera = workspace.CurrentCamera
module.ReplicatedStorage = game:GetService("ReplicatedStorage")
module.RunService = game:GetService("RunService")
module.Players = game:GetService("Players")
module.UserInputService = game:GetService("UserInputService")
module.CollectionService = game:GetService('CollectionService')
module.TweenService = game:GetService("TweenService")
module.TeleportService = game:GetService("TeleportService")
module.Utilities = module.ReplicatedStorage.Utilities
module.spring = module.spring
module.FastCastRedux = module.Utilities.FastCastRedux
module.Weapons = module.ReplicatedStorage.Weapons
module.Client = module.ReplicatedStorage.Client
return module
