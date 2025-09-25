local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

local Window = MacLib:Window({
	Title = "Pizza Hub",
	Subtitle = "Free | V0.1",
	Size = UDim2.fromOffset(868, 650),
	DragStyle = 1,
	DisabledWindowControls = {},
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true,
})

Window:Notify({
	Title = "Pizza Hub",
	Description = "let's get ban soon",
	Lifetime = 5
})

-- Tabs
local MainGroup = Window:TabGroup()
local SettingGroup = Window:TabGroup()

local Main = MainGroup:Tab({ Name = "Main", Image = "" })
local Teleport = MainGroup:Tab({ Name = "Teleport", Image = "" })
local Setting = SettingGroup:Tab({ Name = "Setting", Image = "" })

-- Sections
local mainSec1 = Main:Section({ Side = "Left" })
local mainSec2 = Main:Section({ Side = "Left" })
local mainSec3 = Main:Section({ Side = "Right" })
local mainSec4 = Main:Section({ Side = "Right" })

local tpSec1 = Teleport:Section({ Side = "Left" })
local tpSec2 = Teleport:Section({ Side = "Right" })

local settingSec1 = Setting:Section({ Side = "Left" })
local settingSec2 = Setting:Section({ Side = "Left" })
local settingSec3 = Setting:Section({ Side = "Right" })



-- Menu data
local Menu = {
	playerData = {
        player = player,
        humanoidRootPart = player.Character:WaitForChild("HumanoidRootPart"),
        userName = player.Name,
        userId = player.UserId
    },
	config = {
		lastTeleport = nil
	},
	tabs = {
		main = { mainSec1 = mainSec1, mainSec2 = mainSec2, mainSec3 = mainSec3, mainSec4 = mainSec4 },
		teleport = { tpSec1 = tpSec1, tpSec2 = tpSec2 },
		setting = { settingSec1 = settingSec1, settingSec2 = settingSec2, settingSec3 = settingSec3 }
	},
	system = {
		keyBind = Enum.KeyCode.K
	}
}

local function updateChar(char)
	Menu.playerData.humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end
	
player.CharacterAdded:Connect(updateChar)

-- Main function
local ClaimLoopThread
local autoClaimEnabled = false


Menu.tabs.main.mainSec1:Toggle({
	Name = "Auto Claim",
	Default = false,
	Callback = function(value)
		autoClaimEnabled = value
		local userId = Menu.playerData.userId
		
		if value then
			ClaimLoopThread = task.spawn(function()
				local remote1 = game:GetService("ReplicatedStorage").Connections:WaitForChild("Claim_Sam")
				local remote2 = game:GetService("Workspace").UserData["User" .. userId].ClaimRewardHourly.Connections:WaitForChild("Claim_Sam")

				while autoClaimEnabled do
					remote1:FireServer("Claim1")
					remote2:FireServer("RewardMark")
					task.wait(math.random(2, 4))
				end
			end)
		else
			if ClaimLoopThread then
				task.cancel(ClaimLoopThread)
			end
		end
	end,
}, "AutoClaim")

local hakiLoopThread
local autoHakiEnabled = false

Menu.tabs.main.mainSec1:Toggle({
	Name = "Auto Haki",
	Default = false,
	Callback = function(value)
		autoHakiEnabled = value
		local userId = Menu.playerData.userId

		if value then
			hakiLoopThread = task.spawn(function()
				while autoHakiEnabled do
					local args = { "On", 1 }
					workspace.UserData["User" .. userId].III:FireServer(unpack(args))
					task.wait(1)
				end
			end)
		else
			if hakiLoopThread then
				task.cancel(hakiLoopThread)
			end
			local args = { "Off", 9 }
			workspace.UserData["User" .. userId].III:FireServer(unpack(args))
		end
		
		Window:Notify({
			Title = "Pizza Hub",
			Description = (value and "Enabled " or "Disabled ") .. "Auto Haki"
		})
	end,
}, "AutoHaki")

-- Teleport function
local ManualLocations = {
	islands = {
		Island1 = CFrame.new(762.77, 216.00, -1377.22),
		Island2 = CFrame.new(-1251.18, 218.00, 633.37),
		Island11 = CFrame.new(-2649.47, 252.64, 1106.48),
		Island14 = CFrame.new(4862.58, 570.00, -7150.02),
		Island15 = CFrame.new(1083.87, 217.00, -257.48),
		Island6  = CFrame.new(1956.24, 217.00, -1956.46),
		Island8  = CFrame.new(1942.90, 218.00, 621.73),
		IslandPirate = CFrame.new(-1283.52, 217.00, -1245.62),
		IslandWindmill = CFrame.new(-8.00, 216.00, -296.00),
		IslandCaver = CFrame.new(-1071.38, 217.00, 1436.36),
		IslandCliffs = CFrame.new(4696.39, 217.00, 5130.73),
		IslandCrescent = CFrame.new(3197.20, 217.00, 1478.55),
		IslandEvil = CFrame.new(-5383.49, 216.00, -7609.54),
		IslandMountain = CFrame.new(2093.91, 216.00, -364.52),
		IslandRocky = CFrame.new(-35.82, 229.00, 2163.29),
		IslandSnowy = CFrame.new(-1814.63, 222.00, 3357.31),
		IslandSnowyMountains = CFrame.new(6199.96, 216.00, -1581.80),
		IslandTiny = CFrame.new(-4006.66, 216.00, -2191.42),
		IslandTown = CFrame.new(-127.42, 216.00, -737.11),
		Z_Island222 = CFrame.new(-1550.89, 217.00, -299.96),
		Z_Marine_Ford = CFrame.new(-2565.21, 216.00, -4459.00)
	},
	merchants = {
		AffinityMerchant = CFrame.new(117.03, 278.00, 4948.39),
		BetterDrinkMerchant = CFrame.new(1501.63, 260.39, 2170.91),
		Boat1Merchant = CFrame.new(-0.16, 216.00, -411.05),
		Boat2Merchant = CFrame.new(-131.44, 216.00, -672.14),
		Boat3Merchant = CFrame.new(2055.65, 216.00, -389.97),
		Boat4Merchant = CFrame.new(625.01, 216.00, 1217.81),
		Boat5Merchant = CFrame.new(-1254.69, 217.00, -1178.14),
		DrinkMerchant = CFrame.new(-1286.61, 218.20, -1368.58),
		EmoteMerchant = CFrame.new(1518.45, 260.39, 2168.10),
		ExpertiseMerchant = CFrame.new(900.46, 270.00, 1219.36),
		FishMerchant = CFrame.new(1983.55, 218.00, 568.37),
		FlailMerchant = CFrame.new(1110.18, 217.00, 3363.34),
		FriendMerchant = CFrame.new(1240.50, 224.20, -3241.34),
		KrizmaMerch = CFrame.new(-1073.88, 361.00, 1670.37),
		QuestFishMerchant = CFrame.new(-1696.06, 216.00, -327.02),
		QuestMerchant = CFrame.new(1543.86, 263.90, 2132.30),
		QuestMerchant2 = CFrame.new(-1300.93, 218.00, -1352.31),
		SniperMerchant = CFrame.new(-1843.44, 222.00, 3406.21),
		SwordMerchant = CFrame.new(1007.34, 224.00, -3338.26)
	}
}

local function teleportTo(locationName)
	local player = Menu.playerData.player
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")

	Menu.config.lastTeleport = locationName
	
	for _, category in pairs(ManualLocations) do
		if category[locationName] then
			root.CFrame = category[locationName] + Vector3.new(0, 5, 0)
			Window:Notify({
				Title = "Teleport",
				Description = "Teleported to custom spot for " .. locationName,
				Lifetime = 3
			})
			return
		end
	end

	local target = workspace:FindFirstChild(locationName)
	if target and target:IsA("Model") then
		local cf
		if target.PrimaryPart then
			cf = target.PrimaryPart.CFrame
		elseif target.WorldPivot then
			cf = target.WorldPivot
		end

		if cf then
			root.CFrame = cf + Vector3.new(0, 5, 0)
			Window:Notify({
				Title = "Teleport",
				Description = "Teleported to " .. locationName,
				Lifetime = 3
			})
		else
			Window:Notify({
				Title = "Teleport",
				Description = "Model " .. locationName .. " has no pivot/primarypart",
				Lifetime = 3
			})
		end
	else
		Window:Notify({
			Title = "Teleport",
			Description = "Location '" .. locationName .. "' not found",
			Lifetime = 3
		})
	end
end

-- Dropdowns
Menu.tabs.teleport.tpSec1:Dropdown({
	Name = "Teleport to Island",
	Search = true,
	Multi = false,
	Required = false,
	Options = {
		"IslandWindmill","IslandPirate","IslandCaver","IslandCliffs","IslandCrescent",
		"IslandEvil","IslandForest","IslandGrassy","IslandMountain","IslandRocky",
		"IslandSandCastle","IslandSnowy","IslandSnowyMountains","IslandTREEA",
		"IslandTiny","IslandTown","Z_Marine_Ford","Z_Island222",
		"Island1","Island2","Island3","Island5",
		"Island6","Island8",
		"Island11","Island13","Island14","Island15"
	},
	Callback = teleportTo,
}, "IslandDropdown")

Menu.tabs.teleport.tpSec1:Dropdown({
	Name = "Teleport to Merchants",
	Search = true,
	Multi = false,
	Required = false,
	Options = {
		"AffinityMerchant","BetterDrinkMerchant","Boat1Merchant","Boat2Merchant","Boat3Merchant",
		"Boat4Merchant","Boat5Merchant","DrinkMerchant","EmoteMerchant","ExpertiseMerchant",
		"FishMerchant","FlailMerchant","FriendMerchant","KrizmaMerch","QuestFishMerchant",
		"QuestMerchant","QuestMerchant2","SniperMerchant","SwordMerchant"
	},
	Callback = teleportTo,
}, "MerchantDropdown")

Menu.tabs.teleport.tpSec1:Button({
	Name = "Save Current Position as Last Location",
	Callback = function()
		local player = Menu.playerData.player
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root and Menu.config.lastTeleport then
			for _, category in pairs(ManualLocations) do
				if category[Menu.config.lastTeleport] then
					category[Menu.config.lastTeleport] = root.CFrame
					Window:Notify({
						Title = "Teleport",
						Description = "Updated " .. Menu.config.lastTeleport .. " position!",
						Lifetime = 3
					})
					return
				end
			end
			Window:Notify({
				Title = "Teleport",
				Description = "Last location not in ManualLocations!",
				Lifetime = 3
			})
		end
	end,
})

Menu.tabs.teleport.tpSec1:Button({
	Name = "Teleport to Last Location",
	Callback = function()
		if Menu.config.lastTeleport then
			teleportTo(Menu.config.lastTeleport)
		else
			Window:Notify({
				Title = "Teleport",
				Description = "No saved location yet!",
				Lifetime = 3
			})
		end
	end,
})

local chestLoopThread
local autochestEnabled = false

Menu.tabs.teleport.tpSec2:Toggle({
    Name = "Collect All Chests",
    Default = false,
	Callback = function(value)
        autochestEnabled = value
        local chestsFolder = workspace:WaitForChild("Chests")

        if value then
            chestLoopThread = task.spawn(function()
                while autochestEnabled do
                    for _, chest in pairs(chestsFolder:GetChildren()) do
                        if chest:IsA("Model") and chest.Name == "TreasureChest" then
                            local part = chest:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local root = Menu.playerData.humanoidRootPart
                                if root then
                                    root.CFrame = CFrame.new(part.Position)
                                end
                                task.wait(0.5)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            if chestLoopThread then
				task.cancel(chestLoopThread)
				chestLoopThread = nil
			end
        end
	end,
})


-- Settings
Menu.tabs.setting.settingSec3:Keybind({
	Name = "Set Key Bind",
	onBinded = function(bind)
		Menu.system.keyBind = bind or Enum.KeyCode.K
		Window:Notify({
			Title = "Pizza Hub",
			Description = "Rebinded Reset Key Bind to " .. tostring(Menu.system.keyBind),
			Lifetime = 3
		})
	end,
}, "ResetKeyBind")

Menu.tabs.setting.settingSec3:Button({
	Name = "Kill Menu",
	Callback = function()
		Window:Unload()
	end,
})

-- Toggle menu
local menuStage = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Menu.system.keyBind then
		menuStage = not menuStage
		Window:SetState(menuStage)
	end
end)
