local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local GiftRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("GiftRE")
local CharacterRE = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("CharacterRE")

local function fireServer(arg)
	CharacterRE:FireServer(unpack(arg))
end

local fruits = {
	{name="volt ginkgo", fullname="VoltGinkgo"},
	{name="deepsea pearl", fullname="DeepseaPearlFruit"},
	{name="colossal pinecone", fullname="ColossalPinecone"},
	{name="gold mango", fullname="GoldMango"},
	{name="bloodstone cycad", fullname="BloodstoneCycad"}
}

local localPlayer = Players.LocalPlayer
local isRunning = false
local isPaused = false
local runId = 0 -- cancel token
local delayTime = 0.001
local dupeRunning = false
local autofarm = false

-- Targets for dupe mode
local nameTarget = { "marlevina17", "rahadkai020", "tprx_Elwyn" }
local islandName = localPlayer:GetAttribute("AssignedIslandName")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 340)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Selectable = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Always-visible Toggle Button (top-right corner)
local ToggleUiBtn = Instance.new("TextButton")
ToggleUiBtn.Size = UDim2.new(0, 80, 0, 30)
ToggleUiBtn.AnchorPoint = Vector2.new(1, 0)
ToggleUiBtn.Position = UDim2.new(1, -10, 0, 10)
ToggleUiBtn.Text = "Toggle UI"
ToggleUiBtn.TextScaled = true
ToggleUiBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
ToggleUiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleUiBtn.Parent = ScreenGui

local ToggleAFBtn = Instance.new("TextButton")
ToggleAFBtn.Size = UDim2.new(0, 80, 0, 30)
ToggleAFBtn.AnchorPoint = Vector2.new(1, 0)
ToggleAFBtn.Position = UDim2.new(1, -10, 0, 40)
ToggleAFBtn.Text = "Toggle AF"
ToggleAFBtn.TextScaled = true
ToggleAFBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
ToggleAFBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAFBtn.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "Gift Sender"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Parent = Frame

-- Player Name Input
local PlayerBox = Instance.new("TextBox")
PlayerBox.Size = UDim2.new(1, -20, 0, 30)
PlayerBox.Position = UDim2.new(0, 10, 0, 35)
PlayerBox.PlaceholderText = "Enter player name"
PlayerBox.Text = ""
PlayerBox.TextScaled = true
PlayerBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
PlayerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerBox.Parent = Frame

-- Select Player Button
local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(1, -20, 0, 30)
SelectBtn.Position = UDim2.new(0, 10, 0, 70)
SelectBtn.Text = "Select Player"
SelectBtn.TextScaled = true
SelectBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.Parent = Frame

-- Select Fruit
local StartTradeBtn = Instance.new("TextButton")
StartTradeBtn.Size = UDim2.new(1, -20, 0, 30)
StartTradeBtn.Position = UDim2.new(0, 10, 0, 110)
StartTradeBtn.Text = "Select Fruit"
StartTradeBtn.TextScaled = true
StartTradeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
StartTradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartTradeBtn.Parent = Frame

-- Pause Button
local PauseBtn = Instance.new("TextButton")
PauseBtn.Size = UDim2.new(1, -20, 0, 30)
PauseBtn.Position = UDim2.new(0, 10, 0, 190)
PauseBtn.Text = "Pause"
PauseBtn.TextScaled = true
PauseBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
PauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PauseBtn.Parent = Frame
PauseBtn.Visible = false

-- Cancel Button
local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(1, -20, 0, 30)
CancelBtn.Position = UDim2.new(0, 10, 0, 230)
CancelBtn.Text = "Cancel Loop"
CancelBtn.TextScaled = true
CancelBtn.BackgroundColor3 = Color3.fromRGB(170, 170, 0)
CancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CancelBtn.Parent = Frame
CancelBtn.Visible = false

-- Popup Frame for player list
local PopupFrame = Instance.new("Frame")
PopupFrame.Size = UDim2.new(0, 200, 0, 250)
PopupFrame.Position = UDim2.fromOffset(Frame.AbsolutePosition.X + Frame.AbsoluteSize.X + 10, Frame.AbsolutePosition.Y)
PopupFrame.AnchorPoint = Vector2.new(0, 0)
PopupFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PopupFrame.Visible = false
PopupFrame.Active = true
PopupFrame.Draggable = true
PopupFrame.Selectable = true
PopupFrame.Parent = ScreenGui

-- Title for popup
local PopupTitle = Instance.new("TextLabel")
PopupTitle.Size = UDim2.new(1, 0, 0, 30)
PopupTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PopupTitle.Text = "Select a Player"
PopupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PopupTitle.TextScaled = true
PopupTitle.Parent = PopupFrame

-- Close (X) button for popup
local PopupClose = Instance.new("TextButton")
PopupClose.Size = UDim2.new(0, 28, 0, 24)
PopupClose.AnchorPoint = Vector2.new(1, 0)
PopupClose.Position = UDim2.new(1, -6, 0, 3)
PopupClose.Text = "×"
PopupClose.TextScaled = true
PopupClose.BackgroundTransparency = 1
PopupClose.ZIndex = 52
PopupClose.Parent = PopupFrame

PopupClose.MouseButton1Click:Connect(function()
	PopupFrame.Visible = false
end)

-- Refresh Button
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1, -12, 0, 28)
RefreshBtn.Position = UDim2.new(0, 6, 0, 36)
RefreshBtn.Text = "Refresh List"
RefreshBtn.TextScaled = true
RefreshBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.ZIndex = 51
RefreshBtn.Parent = PopupFrame

-- ScrollingFrame
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -12, 1, -80)
PlayerList.Position = UDim2.new(0, 6, 0, 70)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.ScrollBarThickness = 6
PlayerList.BackgroundTransparency = 1
PlayerList.ZIndex = 51
PlayerList.Parent = PopupFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = PlayerList
ListLayout.Padding = UDim.new(0, 6)

-- Dupe Button
local DupeBtn = Instance.new("TextButton")
DupeBtn.Size = UDim2.new(1, -20, 0, 30)
DupeBtn.Position = UDim2.new(0, 10, 0, 270)
DupeBtn.Text = "Start Dupe"
DupeBtn.TextScaled = true
DupeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 170)
DupeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DupeBtn.Parent = Frame

local TradePopup = Instance.new("Frame")
TradePopup.Size = UDim2.new(0, 200, 0, 250)
TradePopup.Position = UDim2.fromOffset(Frame.AbsolutePosition.X + Frame.AbsoluteSize.X + 10, Frame.AbsolutePosition.Y)
TradePopup.AnchorPoint = Vector2.new(0, 0)
TradePopup.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TradePopup.Visible = false
TradePopup.Active = true
TradePopup.Draggable = true
TradePopup.Selectable = true
TradePopup.Parent = ScreenGui

local TradePopup2 = Instance.new("Frame")
TradePopup2.Size = UDim2.new(0, 200, 0, 80)
TradePopup2.Position = UDim2.fromOffset(0, 260)
TradePopup2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TradePopup2.Parent = TradePopup

-- Title for popup
local TradeTitle = Instance.new("TextLabel")
TradeTitle.Size = UDim2.new(1, 0, 0, 30)
TradeTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TradeTitle.Text = "Select Fruit to Trade"
TradeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TradeTitle.TextScaled = true
TradeTitle.Parent = TradePopup

local TradeList = Instance.new("Frame")
TradeList.Size = UDim2.new(1, -10, 1, -50) -- adjust height for padding
TradeList.Position = UDim2.new(0, 5, 0, 40)
TradeList.BackgroundTransparency = 1
TradeList.Parent = TradePopup

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = TradeList
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Close (X) button for popup
local TradeClose = Instance.new("TextButton")
TradeClose.Size = UDim2.new(0, 28, 0, 24)
TradeClose.AnchorPoint = Vector2.new(1, 0)
TradeClose.Position = UDim2.new(1, -6, 0, 3)
TradeClose.Text = "×"
TradeClose.TextScaled = true
TradeClose.BackgroundTransparency = 1
TradeClose.ZIndex = 52
TradeClose.Parent = TradePopup

-- Start Button
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(1, -20, 0, 30)
StartBtn.Position = UDim2.new(0, 10, 0, 270)
StartBtn.Text = "Start Loop"
StartBtn.TextScaled = true
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Parent = TradePopup

-- Given count label
local GivenLabel = Instance.new("TextLabel")
GivenLabel.Size = UDim2.new(1, -20, 0, 20)
GivenLabel.Position = UDim2.new(0, -40, 0, 310) -- just below GiftBox
GivenLabel.BackgroundTransparency = 1
GivenLabel.Text = "Given: 0"
GivenLabel.TextScaled = true
GivenLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GivenLabel.Parent = TradePopup

-- Left count label
local LeftLabel = Instance.new("TextLabel")
LeftLabel.Size = UDim2.new(1, -20, 0, 20)
LeftLabel.Position = UDim2.new(0, 60, 0, 310) -- below GivenLabel
LeftLabel.BackgroundTransparency = 1
LeftLabel.Text = "Left: 0"
LeftLabel.TextScaled = true
LeftLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LeftLabel.Parent = TradePopup

TradeClose.MouseButton1Click:Connect(function()
	TradePopup.Visible = false
end)

local fruitAmountBoxes = {}

-- Create UI rows dynamically
for _, fruit in ipairs(fruits) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundTransparency = 1
	row.Parent = TradeList  -- add to container with UIListLayout

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = fruit.name
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Parent = row

	local amountBox = Instance.new("TextBox")
	amountBox.Size = UDim2.new(0.2, -5, 1, 0)
	amountBox.Position = UDim2.new(0.75, 5, 0, 0)
	amountBox.PlaceholderText = "0"
	amountBox.Text = ""
	amountBox.Parent = row

	fruitAmountBoxes[fruit.fullname] = amountBox
end

-- Pause
PauseBtn.MouseButton1Click:Connect(function()
	isPaused = not isPaused
	PauseBtn.Text = isPaused and "Resume" or "Pause"
end)

-- Refresh player list
local function RefreshPlayerList()
	for _, child in ipairs(PlayerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local plrs = Players:GetPlayers()
	for _, plr in ipairs(plrs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 28)
		btn.Text = plr.Name
		btn.TextScaled = true
		btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.ZIndex = 52
		btn.Parent = PlayerList

		btn.MouseButton1Click:Connect(function()
			PlayerBox.Text = plr.Name
			PopupFrame.Visible = false
		end)
	end

	PlayerList.CanvasSize = UDim2.new(0, 0, 0, #plrs * 34)
end

RefreshBtn.MouseButton1Click:Connect(RefreshPlayerList)

-- Select player button opens popup
SelectBtn.MouseButton1Click:Connect(function()
	RefreshPlayerList()
	local mainPos = Frame.AbsolutePosition
	local mainSize = Frame.AbsoluteSize
	PopupFrame.Position = UDim2.fromOffset(mainPos.X + mainSize.X + 10, mainPos.Y)
	PopupFrame.Visible = true
end)

StartTradeBtn.MouseButton1Click:Connect(function()
	local mainPos = Frame.AbsolutePosition
	local mainSize = Frame.AbsoluteSize
	TradePopup.Position = UDim2.fromOffset(mainPos.X - mainSize.X + 30, mainPos.Y)
	TradePopup.Visible = true
end)

-- Normal loop
StartBtn.MouseButton1Click:Connect(function()
	local playerName = PlayerBox.Text
	if playerName == "" then
		warn("Please enter a player name.")
		return
	end

	local targetPlayer = Players:FindFirstChild(playerName)
	if not targetPlayer then
		warn("Player not found: " .. playerName)
		return
	end

	if isRunning then
		warn("Already running!")
		return
	end

	-- build a queue of trades
	local tradeQueue = {}
	for _, fruit in ipairs(fruits) do
		local box = fruitAmountBoxes[fruit.fullname]
		local count = tonumber(box.Text) or 0
		for i = 1, count do
			table.insert(tradeQueue, fruit.fullname)
		end
	end

	if #tradeQueue == 0 then
		warn("No fruits selected to trade")
		return
	end

	-- run as usual
	runId += 1
	local myId = runId
	isRunning = true
	isPaused = false
	PauseBtn.Text = "Pause"
	PauseBtn.Visible = true
	CancelBtn.Visible = true

	task.spawn(function()
		local given = 0
		for i, fruitFullName in ipairs(tradeQueue) do
			while isPaused and isRunning and myId == runId do
				task.wait(0.1)
			end
			if not isRunning or myId ~= runId then break end
			fireServer({"Focus",fruitFullName})
			GiftRE:FireServer(targetPlayer, fruitFullName) -- <- send fruit fullname

			given += 1
			GivenLabel.Text = "Given: " .. given
			LeftLabel.Text = "Left: " .. (#tradeQueue - given)

			task.wait(0.2)
		end

		if myId == runId then
			isRunning = false
			isPaused = false
			PauseBtn.Visible = false
			CancelBtn.Visible = false
			GivenLabel.Text = "Given: 0"
			LeftLabel.Text = "Left: 0"
		end
	end)
end)

-- Cancel
CancelBtn.MouseButton1Click:Connect(function()
	runId += 1
	isRunning = false
	isPaused = false
	PauseBtn.Visible = false
	CancelBtn.Visible = false
	GivenLabel.Text = "Given: 0"
	LeftLabel.Text = "Left: 0"
end)


-- Dupe loop
local function getNil(objType, objName)
	for _, v in getnilinstances() do
		if v.ClassName == objType and v.Name == objName then
			return v
		end
	end
end

local function toggleDupe()
	dupeRunning = not dupeRunning
	if dupeRunning then
		DupeBtn.Text = "Stop Dupe"
		DupeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		task.spawn(function()
			while dupeRunning do
				for _, targetName in ipairs(nameTarget) do
					local target = getNil("Player", targetName)
					if target then
						GiftRE:FireServer(target)
					end
				end
				task.wait(delayTime)
			end
		end)
	else
		DupeBtn.Text = "Start Dupe"
		DupeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 170)
	end
end


DupeBtn.MouseButton1Click:Connect(toggleDupe)

-- Anti-AFK (Mobile + PC)
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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

ToggleAFBtn.MouseButton1Click:Connect(function()
	autofarm = not autofarm
	if autofarm then
		ToggleAFBtn.Text = "Stop AutoFarm"
		ToggleAFBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		print("AutoFarm started")

		task.spawn(function()
			while autofarm do
				local Pets = workspace:FindFirstChild("Pets")
				if Pets then
					for _, pet in pairs(Pets:GetChildren()) do
						if not autofarm then break end

						local petOwner = pet:GetAttribute("UserId")
						if petOwner == LocalPlayer.UserId then
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
			print("AutoFarm stopped")
		end)
	else
		ToggleAFBtn.Text = "Start AutoFarm"
		ToggleAFBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	end
end)

-- Auto refresh list if popup open
Players.PlayerAdded:Connect(function()
	if PopupFrame.Visible then RefreshPlayerList() end
end)
Players.PlayerRemoving:Connect(function()
	if PopupFrame.Visible then RefreshPlayerList() end
end)


-- Cache references
local purchasedEggs = {}

local buylist = {
	egg = {
		"UnicornEgg"
	},
	mutate = {
		"Jurassic"
	}
}

local island = workspace.Art:FindFirstChild(islandName)
local conveyor9, belt

if island and island:FindFirstChild("ENV") then
	local conveyor = island.ENV:FindFirstChild("Conveyor")
	if conveyor then
		conveyor9 = conveyor:FindFirstChild("Conveyor9")
		if conveyor9 then
			belt = conveyor9:FindFirstChild("Belt")
		end
	end
end

local function getAllMutates()
	local results = {}

	for _, obj in ipairs(belt:GetChildren()) do
		local rootPart = obj:FindFirstChild("RootPart")
		local gui = rootPart and rootPart:FindFirstChild("GUI/EggGUI")
		local mutateObj = gui and gui:FindFirstChild("Mutate")
		if mutateObj and mutateObj:IsA("TextLabel") then
			local mutateValue = mutateObj.Text
			if mutateValue == "" then
				mutateValue = "null"
			end
			local typeName = obj:GetAttribute("Type") or "Unknown"
			results[#results + 1] = {fullname = obj.Name, name = typeName, mutate = mutateValue}
		end
	end

	return results
end

local function inList(list, value)
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

local function buyEgg(eggName)
	if purchasedEggs[eggName] then return end
	fireServer("BuyEgg", eggName)
end

task.spawn(function()
	while true do
		local eggs = getAllMutates()
		for _, egg in ipairs(eggs) do
			if inList(buylist.egg, egg.name) and inList(buylist.mutate, egg.mutate) then
				buyEgg(egg.fullname)
			end
		end
		task.wait(0.3)
	end
end)

task.spawn(function()
	while true do
		task.wait(300)
		purchasedEggs = {}
	end
end)

-- Toggle UI
ToggleUiBtn.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
	if not Frame.Visible then
		PopupFrame.Visible = false
		TradePopup.Visible = false
	end
end)

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.K then
		Frame.Visible = not Frame.Visible
		if not Frame.Visible then
			PopupFrame.Visible = false
			TradePopup.Visible = false
		end
	end

	if input.KeyCode == Enum.KeyCode.Escape and PopupFrame.Visible then
		PopupFrame.Visible = false
		TradePopup.Visible = false
	end
end)
