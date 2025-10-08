-- Load MacLib
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes
local GiftRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("GiftRE")
local DeployRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("DeployRE")
local CharacterRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("CharacterRE")

-- Helpers
local function fireServer(arg)
	if type(arg) == "table" and arg[1] then
		CharacterRE:FireServer(unpack(arg))
	else
		CharacterRE:FireServer(arg)
	end
end

-- Fruits
local fruits = {
	{name="volt ginkgo", fullname="VoltGinkgo"},
	{name="deepsea pearl", fullname="DeepseaPearlFruit"},
	{name="colossal pinecone", fullname="ColossalPinecone"},
	{name="gold mango", fullname="GoldMango"},
	{name="bloodstone cycad", fullname="BloodstoneCycad"}
}

-- State vars
local isRunning = false
local isPaused = false
local runId = 0
local dupeRunning = false
local dupePaused = false
local autofarm = false
local fruitAmounts = {}

local selectedPlayerName = nil
local selectedEggName = nil
local selectedMutName = nil

local menuVisible = true

local autofarmThread


-- safe humanoidRootPart getter
local function getHumanoidRoot()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return player.Character.HumanoidRootPart
	end
	return nil
end

-- Window (MacLib)
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

-- Tabs & sections
local MainGroup = Window:TabGroup()
local SettingGroup = Window:TabGroup()

local mainTab = MainGroup:Tab({ Name = "Main", Image = "" })
local DupeTab = MainGroup:Tab({ Name = "Dupe", Image = "" })
local AutoTab = MainGroup:Tab({ Name = "AutoFarm", Image = "" })
local Setting = SettingGroup:Tab({ Name = "Setting", Image = "" })

local mainSecLeft1 = mainTab:Section({ Side = "Left" })
local mainSecLeft2 = mainTab:Section({ Side = "Left" })
local mainSecRight = mainTab:Section({ Side = "Right" })

local dupeSec1 = DupeTab:Section({ Side = "Left" })
local autoSec1 = AutoTab:Section({ Side = "Left" })

local settingSec1 = Setting:Section({ Side = "Left" })
local settingSec2 = Setting:Section({ Side = "Left" })
local settingSec3 = Setting:Section({ Side = "Right" })

-- MENU meta (for convenience later)
local Menu = {
	playerData = {
        player = player,
        humanoidRootPart = getHumanoidRoot(),
        userName = player.Name,
        userId = player.UserId
    },
	tabs = {
		main = { left1 = mainSecLeft1, left2 = mainSecLeft2, right = mainSecRight },
		dupe = { dupeSec1 = dupeSec1 },
		auto = { autoSec1 = autoSec1 },
		setting = { settingSec1 = settingSec1, settingSec2 = settingSec2, settingSec3 = settingSec3 }
	},
	system = {
		keyBind = Enum.KeyCode.K
	}
}

-- Live player dropdown
local playerDropdown = Menu.tabs.main.left1:Dropdown({
	Name = "Select Player",
	Options = {},
	Multi = false,
	Callback = function(selected)
		selectedPlayerName = selected
		Window:Notify({
			Title = "Player Selected",
			Description = tostring(selected),
			Lifetime = 2
		})
	end
})

-- Now define RefreshPlayers
local function RefreshPlayers()
	local items = {}
	for _, p in ipairs(Players:GetPlayers()) do
		table.insert(items, p.Name)
	end

	local found = false
	if selectedPlayerName then
		for _, n in ipairs(items) do
			if n == selectedPlayerName then
				found = true
				break
			end
		end
	end
	if not found then
		selectedPlayerName = nil
	end

	-- Update dropdown
	pcall(function()
		playerDropdown:ClearOptions()
		playerDropdown:InsertOptions(items)
	end)
end

-- Connect events
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

-- Initial populate
RefreshPlayers()



for _, fruit in ipairs(fruits) do
	Menu.tabs.main.left2:Input({
		Name = fruit.name,
		Placeholder = "                   ",
		AcceptedCharacters = "Numeric",
		Callback = function(val)
			fruitAmounts[fruit.fullname] = val
		end
	})
end

-- Counters (right side)
local givenLabel = Menu.tabs.main.left2:Label({ Text = "Given: 0                                             Left: 0" })

-- Start Gift Loop button
Menu.tabs.main.left2:Button({
	Name = "Start Gift Loop",
	Callback = function()
		local playerName = selectedPlayerName
		if not playerName or playerName == "" then
			Window:Notify({ Title = "Error", Description = "Please select a player.", Lifetime = 3 })
			return
		end

		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer then
			Window:Notify({ Title = "Error", Description = "Player not found: " .. tostring(playerName), Lifetime = 3 })
			return
		end

		if isRunning then
			Window:Notify({ Title = "Busy", Description = "Gift loop already running.", Lifetime = 3 })
			return
		end

		-- Build queue
		local queue = {}
		for _, fruit in ipairs(fruits) do
			local count = fruitAmounts[fruit.fullname] or 0
			for i = 1, count do
				table.insert(queue, fruit.fullname)
			end
		end

		if #queue == 0 then
			Window:Notify({ Title = "Error", Description = "No fruits selected!", Lifetime = 3 })
			return
		end

		isRunning = true
		isPaused = false
		runId += 1
		local myId = runId

		task.spawn(function()
			local given = 0
			for _, fruitFullName in ipairs(queue) do
				if not isRunning or myId ~= runId then break end
				while isPaused and isRunning and myId == runId do task.wait(0.1) end

				-- focus then send
				pcall(function()
					fireServer({"Focus", fruitFullName})
				end)
				task.wait(0.1)
				pcall(function()
					GiftRE:FireServer(targetPlayer)
				end)

				given += 1
				local ok, _ = pcall(function() givenLabel:UpdateName("Given: " .. given .. "                                             Left: " .. (#queue - given)) end)
				if not ok then pcall(function() givenLabel.Text = "Given: " .. given .. "                                             Left: " .. (#queue - given) end) end

				task.wait(0.3)
			end

			if myId == runId then
				isRunning = false
				isPaused = false
				pcall(function() givenLabel:UpdateName("Given: 0") end)
				pcall(function() leftLabel:UpdateName("Left: 0") end)
				Window:Notify({ Title = "Done!", Description = "Gift loop finished.", Lifetime = 4 })
			end
		end)
	end
})

-- Pause/Resume
Menu.tabs.main.left2:Button({
	Name = "Pause / Resume",
	Callback = function()
		if not isRunning then
			Window:Notify({ Title = "Info", Description = "Not currently running.", Lifetime = 2 })
			return
		end
		isPaused = not isPaused
		Window:Notify({ Title = isPaused and "Paused" or "Resumed", Description = "", Lifetime = 2 })
	end
})

-- Cancel Loop
Menu.tabs.main.left2:Button({
	Name = "Cancel Loop",
	Callback = function()
		runId += 1
		isRunning = false
		isPaused = false
		pcall(function() givenLabel:UpdateName("Given: 0                                             Left: 0") end)
		Window:Notify({ Title = "Cancelled", Text = "Gift loop stopped.", Lifetime = 2 })
	end
})

-- Give Egg
local EggInventory = {}

-- Function to get eggs from player's GUI
local function GetEggsInv()
	local scrollingFrame = player.PlayerGui.ScreenStorage.Frame.Content:FindFirstChild("ScrollingFrame")
	local eggs = {}

	if not scrollingFrame then
		warn("ScrollingFrame not found.")
		return eggs
	end

	dupeRunning = true
	dupePaused = false

	task.spawn(function()
		for _, item in pairs(scrollingFrame:GetChildren()) do
			local btn = item:FindFirstChild("BTN")
			if btn then
				local stat = btn:FindFirstChild("Stat")
				local mutsFolder = btn:FindFirstChild("Muts")

				local eggName = "Unknown"
				if stat and stat:FindFirstChild("NAME") and stat.NAME:FindFirstChild("Value") then
					local nameValue = stat.NAME.Value
					if nameValue:IsA("TextLabel") then
						eggName = nameValue.Text
					end
				end

				local visibleMut = nil
				if mutsFolder then
					for _, mut in pairs(mutsFolder:GetChildren()) do
						if mut:IsA("GuiObject") and mut.Visible then
							visibleMut = mut.Name
							break
						end
					end
				end

				if visibleMut then
					table.insert(eggs, {
						id = item.Name,
						name = eggName,
						mutation = visibleMut
					})
				end
			end
		end
	end)
	return eggs
end

-- Create dropdown UI
local eggDropdown = Menu.tabs.main.right:Dropdown({
	Name = "Eggs List",
	Search = true,
	Multi = false,
	Required = true,
	Options = { "Octopus Egg", "Unicorn Egg", "Unicorn Pro Egg", "General Kong Egg" },
	Default = {  },
	Callback = function(selectedNames)
		selectedEggName = selectedNames
		Window:Notify({ Title = "Selected", Description = "Selected" .. selectedNames .. " Eggs!", Lifetime = 3 })
	end
})

-- Create dropdown UI
local mutsDropdown = Menu.tabs.main.right:Dropdown({
	Name = "Mutation List",
	Search = true,
	Multi = false,
	Required = true,
	Options = { "Dino", "Golden", "Diamon", "Electric", "Fire", "Jurassic", "Snow" },
	Default = {  },
	Callback = function(selectedNames)
		selectedMutName = selectedNames
		Window:Notify({ Title = "Selected", Description = "Selected" .. selectedNames .. " Eggs!", Lifetime = 3 })
	end
})

-- Input box for total to give

local totalInput = Menu.tabs.main.right:Input({
	Name = "Total",
	Placeholder = "Enter total",
	AcceptedCharacters = "Numeric",
	Callback = function(value)
	end
})

-- Start Give Loop button
local dupeLabel = Menu.tabs.main.right:Label({ Text = "Given: 0                                             Left: 0" })

Menu.tabs.main.right:Button({
	Name = "execute dupe",
	Callback = function()
		EggInventory = GetEggsInv()  -- refresh inventory

		local totalToGive = tonumber(totalInput:GetInput()) or 0
		if totalToGive <= 0 then totalToGive = #EggInventory end

		local playerName = selectedPlayerName
		if not playerName or playerName == "" then
			Window:Notify({ Title = "Error", Description = "Please select a player.", Lifetime = 3 })
			return
		end

		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer then
			Window:Notify({ Title = "Error", Description = "Player not found: " .. tostring(playerName), Lifetime = 3 })
			return
		end

		local targetChar = targetPlayer.Character
		if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
		end

		if not selectedEggName or not selectedMutName then
			Window:Notify({Title = "Error", Description = "Select egg and mutation!", Lifetime = 3})
			return
		end

		-- Filter EggInventory by name + mutation
		local queue = {}
		for _, egg in ipairs(EggInventory) do
			if egg.name == selectedEggName and egg.mutation == selectedMutName then
				table.insert(queue, egg.id)
			end
		end

		if #queue == 0 then
			Window:Notify({Title = "Error", Description = "No matching eggs found!", Lifetime = 3})
			return
		end

		while #queue > totalToGive do
			table.remove(queue)
		end

		-- Start give loop
		local given = 0
		dupeRunning = true
		dupePaused = false
		runId += 1
		local myId = runId

		task.spawn(function()
			for _, eggId in ipairs(queue) do
				if not dupeRunning then break end
				while dupePaused and dupeRunning and myId == runId do task.wait(0.1) end
				
				pcall(function() DeployRE:FireServer({ event = "deploy", uid = eggId }) end)
				task.wait(0.1)
				pcall(function() CharacterRE:FireServer("Focus", eggId) end)
				task.wait(0.1)
				pcall(function() GiftRE:FireServer(targetPlayer) end)

				given += 1
				pcall(function()
					dupeLabel:UpdateName("Given: " .. given .. "                                             Left: " .. (#queue - given))
				end)
				task.wait(0.1)
			end

			dupeRunning = false
			Window:Notify({Title = "Done", Description = "Egg give finished.", Lifetime = 3})
			pcall(function() dupeLabel:UpdateName("Given: 0                                             Left: 0") end)
		end)
	end
})

-- Pause / Resume
Menu.tabs.main.right:Button({
	Name = "Pause / Resume",
	Callback = function()
		if not dupeRunning then
			Window:Notify({ Title = "Info", Description = "Not currently running.", Lifetime = 2 })
			return
		end
		dupePaused = not dupePaused
		Window:Notify({ Title = dupePaused and "Paused" or "Resumed", Description = "", Lifetime = 2 })
	end
})

-- Cancel Loop
Menu.tabs.main.right:Button({
	Name = "Cancel Loop",
	Callback = function()
		runId += 1
		dupeRunning = false
		dupePaused = false
		pcall(function() dupeLabel:UpdateName("Given: 0                                             Left: 0") end)
		Window:Notify({ Title = "Cancelled", Text = "Gift loop stopped.", Lifetime = 2 })
	end
})

-----------------------------------------------------------
-- DUPE TAB
-----------------------------------------------------------
Menu.tabs.dupe.dupeSec1:Button({
	Name = "Start Dupe",
	Callback = function()
		if dupeRunning then
			Window:Notify({ Title = "Attention", Description = "Dupe is Already run.", Lifetime = 3 })
			return
		end
		dupeRunning = true

		local ok, object = pcall(function() return ReplicatedStorage.Remote.FishingRE end)
		if not ok or not object then
			Window:Notify({ Title = "Error", Description = "FishingRE not found.", Lifetime = 3 })
			return
		end
		local args = {
			"SetEggQuickSell",
			{
				["1"] = "\255",
				["Diamond"] = false,
				["3"] = true,
				["2"] = false,
				["5"] = false,
				["4"] = false,
				["6"] = false,
				["Golden"] = false,
				["Electirc"] = false,
				["Fire"] = false,
				["Dino"] = false,
				["Snow"] = false
			}
		}
		pcall(function() object:FireServer(unpack(args)) end)
		Window:Notify({ Title = "Dupe Triggered", Description = "Dupe action sent.", Lifetime = 3 })
	end
})

-----------------------------------------------------------
-- AUTOFARM TAB
-----------------------------------------------------------
Menu.tabs.auto.autoSec1:Toggle({
	Name = "AutoFarm",
	Default = false,
	Callback = function(state)
		autofarm = state
		if state then
			Window:Notify({ Title = "AutoFarm", Description = "Started", Lifetime = 2 })
			autofarmThread = task.spawn(function()
				while autofarm do
					local Pets = workspace:FindFirstChild("Pets")
					if Pets then
						for _, pet in pairs(Pets:GetChildren()) do
							if not autofarm then break end
							local petOwner = pet:GetAttribute("UserId")
							if petOwner == player.UserId then
								local root = pet:FindFirstChild("RootPart")
								if root then
									local RF = root:FindFirstChild("RF")
									if RF and RF:IsA("RemoteFunction") then
										pcall(function() RF:InvokeServer("Claim") end)
									elseif root:FindFirstChild("RE") and root.RE:IsA("RemoteEvent") then
										pcall(function() root.RE:FireServer("Claim") end)
									end
								end
							end
						end
					end
					task.wait(10)
				end
				Window:Notify({ Title = "AutoFarm", Description = "Stopped", Lifetime = 2 })
			end)
		else
			if autofarmThread then
				task.cancel(autofarmThread)
			end
			Window:Notify({ Title = "AutoFarm", Description = "Disabled", Lifetime = 2 })
		end
	end
})

-----------------------------------------------------------
-- SETTING TAB
-----------------------------------------------------------
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

-----------------------------------------------------------
-- ANTI-AFK
-----------------------------------------------------------
task.spawn(function()
	while task.wait(240) do
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

player.Idled:Connect(function()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end)

-- Window toggle keybind (K)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Menu.system.keyBind then
		menuVisible = not menuVisible
		pcall(function() Window:SetState(menuVisible) end)
	end
end)

-- Ensure humanoidRootPart updates
player.CharacterAdded:Connect(function(char)
	Menu.playerData.humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Final refresh for players
RefreshPlayers()
