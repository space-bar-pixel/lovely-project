local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "iloveRoblox"
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling


-- Main Frame
local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
frame.Selectable = true

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Build A Zoo"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Speed Input
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.6, 0, 0, 30)
speedLabel.Position = UDim2.new(0, 10, 0, 40)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "claimCooldown !<100"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 16
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = frame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.3, 0, 0, 30)
speedInput.Position = UDim2.new(0.65, 0, 0, 40)
speedInput.Text = "120"
speedInput.ClearTextOnFocus = false
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.SourceSans
speedInput.TextSize = 16
speedInput.Parent = frame

-- Enable Boost Toggle
local enableBoostLabel = Instance.new("TextLabel")
enableBoostLabel.Size = UDim2.new(0.7, 0, 0, 30)
enableBoostLabel.Position = UDim2.new(0, 10, 0, 80)
enableBoostLabel.BackgroundTransparency = 1
enableBoostLabel.Text = "Enable Claim"
enableBoostLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
enableBoostLabel.Font = Enum.Font.SourceSans
enableBoostLabel.TextSize = 16
enableBoostLabel.TextXAlignment = Enum.TextXAlignment.Left
enableBoostLabel.Parent = frame

local enableClaimToggle = Instance.new("TextButton")
enableClaimToggle.Size = UDim2.new(0, 40, 0, 20)
enableClaimToggle.Position = UDim2.new(0.8, 0, 0, 80)
enableClaimToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
enableClaimToggle.Text = ""
enableClaimToggle.Parent = frame


-- Auto-claim variables
local Pets = workspace:WaitForChild("Pets")
local autoClaimEnabled = false

enableClaimToggle.MouseButton1Click:Connect(function()
    autoClaimEnabled = not autoClaimEnabled
    if autoClaimEnabled then
        enableClaimToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        enableClaimToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

local function getClaimCooldown()
    local value = tonumber(speedInput.Text)
    if value then
        value = math.clamp(value, 20, 180)
        return value / 100
    else
        return 100
    end
end

local function tryClaim(pet)
    local root = pet:FindFirstChild("RootPart")
    if not root then return end

    pcall(function()
        local RF = root:FindFirstChild("RF")
        if RF then
            if RF:InvokeServer("Claim") then
            end
        elseif root:FindFirstChild("RE") then
            root.RE:FireServer("Claim")
        end
    end)
end

local virtualUser = game:GetService("VirtualUser")

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
end)

local lastClaimTime = 0

task.spawn(function()
    while true do
        if autoClaimEnabled then
            local claimCooldown = getClaimCooldown()
            local now = tick()
            if now - lastClaimTime >= claimCooldown then
                local petsList = Pets:GetChildren()
                for i = 1, #petsList do
                    tryClaim(petsList[i])
                end
                lastClaimTime = now
            end
        end
        task.wait(1)
    end
end)
