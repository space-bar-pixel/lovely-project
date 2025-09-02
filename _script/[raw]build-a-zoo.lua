-- Fixed UI Framework
-- Put this LocalScript inside StarterGui
local TOGGLE_KEY = Enum.KeyCode.K

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local virtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled

-- init
print("[big hub]loaded...")

local assetId
local success, thumb = pcall(function()
	return Players:GetUserThumbnailAsync(
		player.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size150x150
	)
end)

if success then
	assetId = thumb -- use player headshot
else
	assetId = "rbxassetid://6031094678" -- fallback asset ID
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "iloveRoblox"
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Create a separate ScreenGui for the toggle button
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ToggleButtonGui"
toggleGui.Parent = game:GetService("CoreGui")
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
toggleGui.ResetOnSpawn = false

local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, 640, 0, 640)
mainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
mainPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainPanel.BorderSizePixel = 0
mainPanel.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 4)
mainCorner.Parent = mainPanel

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(90, 0, 0)
mainStroke.Thickness = 2
mainStroke.Parent = mainPanel

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 70, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainPanel

local sidebarPadding = Instance.new("UIPadding", sidebar)
sidebarPadding.PaddingTop = UDim.new(0, 12)
sidebarPadding.PaddingBottom = UDim.new(0, 12)
sidebarPadding.PaddingLeft = UDim.new(0, 6)
sidebarPadding.PaddingRight = UDim.new(0, 6)

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 12)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Logo
local logoContainer = Instance.new("Frame")
logoContainer.Name = "LogoContainer"
logoContainer.Size = UDim2.new(1, 0, 0, 44)
logoContainer.BackgroundTransparency = 1
logoContainer.LayoutOrder = 0
logoContainer.Parent = sidebar

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 48, 0, 48)
logo.AnchorPoint = Vector2.new(0.5, 0.5)
logo.Position = UDim2.new(0.5, 0, 0.5, 0)
logo.BackgroundTransparency = 1
logo.Image = assetId -- ✅ now loads player headshot or fallback
logo.Parent = logoContainer

local uc = Instance.new("UICorner", logo)
uc.CornerRadius = UDim.new(0, 8)
local ar = Instance.new("UIAspectRatioConstraint", logo)
ar.AspectRatio = 1

-- Resize UI for mobile/desktop
local function resizeUI()
    if UserInputService.TouchEnabled then
        mainPanel.Size = UDim2.new(0.9, 0, 0.9, 0)
        sidebar.Size = UDim2.new(0.15, 0, 1, 0)
    else
        mainPanel.Size = UDim2.new(0, 640, 0, 640)
        sidebar.Size = UDim2.new(0, 70, 1, 0)
    end
end

resizeUI() -- initial

UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(resizeUI)

-- Dragging (supports mouse and touch)
local dragging, dragStart, startPos, moveConn

local function stopDrag()
	dragging = false
	if moveConn then
		moveConn:Disconnect()
		moveConn = nil
	end
end

local function startDrag(input)
	dragging = true
	dragStart = input.Position
	startPos = mainPanel.Position

	moveConn = UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == input.UserInputType then
			local delta = i.Position - dragStart
			mainPanel.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			stopDrag()
		end
	end)
end

mainPanel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or
	   input.UserInputType == Enum.UserInputType.Touch then
		startDrag(input)
	end
end)

-- Tabs
local tabs, activeTab = {}, nil

local function addSidebarIcon(assetId, tabName)
	local iconBtn = Instance.new("ImageButton")
	iconBtn.Size = UDim2.new(0, 34, 0, 34)
	iconBtn.BackgroundTransparency = 1
	iconBtn.Image = "rbxassetid://" .. tostring(assetId)
	iconBtn.Parent = sidebar
	Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0, 8)

	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, -80, 1, -20)
	page.Position = UDim2.new(0, 80, 0, 10)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = mainPanel
	Instance.new("UIListLayout", page).Padding = UDim.new(0, 12)

	tabs[tabName] = {Button = iconBtn, Page = page}

	iconBtn.MouseButton1Click:Connect(function()
		if activeTab and tabs[activeTab] then
			tabs[activeTab].Page.Visible = false
			tabs[activeTab].Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		end
		activeTab = tabName
		page.Visible = true
		iconBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	end)

	return page
end

-- Section builder
local function createSection(parent, titleText)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, -20, 0, 0)
	section.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	section.BorderSizePixel = 0
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.Parent = parent
	Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
	Instance.new("UIPadding", section).PaddingLeft = UDim.new(0, 10)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 24)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = section

	Instance.new("UIListLayout", section).Padding = UDim.new(0, 8)

	return section
end

-- Toggle
local function createToggle(parent, labelText, stage, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 36)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -80, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.new(0, 52, 0, 26)
	switch.Position = UDim2.new(1, -52, 0.5, -13)
	switch.AnchorPoint = Vector2.new(0, 0)
	switch.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	switch.Text = ""
	switch.Parent = container

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(0, 14)
	switchCorner.Parent = switch

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 22, 0, 22)
	knob.Position = UDim2.new(0, 2, 0.5, -11)
	knob.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	knob.Parent = switch

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(0, 12)
	knobCorner.Parent = knob

	local enabled = stage
	switch.MouseButton1Click:Connect(function()
		enabled = not enabled
		if enabled then
			switch.BackgroundColor3 = Color3.fromRGB(20, 160, 20)
			knob:TweenPosition(UDim2.new(1, -24, 0.5, -11), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
		else
			switch.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			knob:TweenPosition(UDim2.new(0, 2, 0.5, -11), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
		end
		if callback then
			pcall(callback, enabled)
		end
	end)
end

-- Slider
local function createSlider(parent, text, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. default
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local slider = Instance.new("TextButton")
	slider.Size = UDim2.new(1, 0, 0, 10)
	slider.Position = UDim2.new(0, 0, 0, 20)
	slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	slider.Text = ""
	slider.Parent = frame

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	fill.Parent = slider

	local dragging = false
	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
	end)
	slider.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X)/slider.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(rel,0,1,0)
			local val = math.floor(min + (max-min)*rel)
			label.Text = text .. ": " .. val
			if callback then callback(val) end
		end
	end)
end

-- Toggle UI
local uiEnabled = true
local function toggleUI()
	uiEnabled = not uiEnabled
	screenGui.Enabled = uiEnabled
end

-- Toggle Button (always visible)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(1, -110, 0, 20)
toggleButton.AnchorPoint = Vector2.new(1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Draggable = true
toggleButton.Active = true
toggleButton.TextSize = 18
toggleButton.Text = "Toggle UI"
toggleButton.Parent = toggleGui -- ✅ FIX: separate GUI
toggleButton.ZIndex = 999

-- Optional: Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(toggleUI)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == TOGGLE_KEY then
		toggleUI()
	end
end)

-- Example tabs
local homePage = addSidebarIcon(6031094678, "Home")
local sec = createSection(homePage, "Main Options")

createToggle(sec, "AutoFarm", true, function(enabled)
	if enabled then
		-- run asynchronously
		task.spawn(function()
			while sec and sec.Parent and enabled do
				local Pets = workspace:FindFirstChild("Pets")
				if not Pets then continue end

				for _, pet in pairs(Pets:GetChildren()) do
					local root = pet:FindFirstChild("RootPart")
					if not root then continue end

					-- Prefer RemoteFunction if available
					local RF = root:FindFirstChild("RF")
					if RF and RF:IsA("RemoteFunction") then
						pcall(function() RF:InvokeServer("Claim") end)
					elseif root:FindFirstChild("RE") and root.RE:IsA("RemoteEvent") then
						pcall(function() root.RE:FireServer("Claim") end)
					end
				end
				task.wait(10)
			end
		end)
	end
end)

createToggle(sec, "Anti-AFK", false, function(enabled)
	if enabled then
		game:GetService("Players").LocalPlayer.Idled:Connect(function()
			virtualUser:CaptureController()
			virtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

createSlider(sec, "Health %", 0, 100, 50, function(v) print("Health:", v) end)

local profilePage = addSidebarIcon(6031094678, "Profile")
local sec2 = createSection(profilePage, "Profile Section")
local sec3 = createSection(profilePage, "Menu Setting")
createSlider(sec3, "Main UI Transparency", 0, 100, 100, function(value)
    local transparency = value / 100
    mainPanel.BackgroundTransparency = transparency
    mainStroke.Transparency = transparency
    sidebar.Transparency = transparency
end)
createToggle(sec2, "Show Avatar", false, function(s) print("Avatar: ", s) end)

-- Start on home
tabs["Home"].Button.BackgroundColor3 = Color3.fromRGB(100,0,0)
tabs["Home"].Page.Visible = true
activeTab = "Home"
