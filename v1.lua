-- Copy and paste this entire script into Roblox Studio command bar or a LocalScript
-- This will create the AI Controller GUI only for your client

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clear any existing GUI
if playerGui:FindFirstChild("AIController") then
    playerGui.AIController:Destroy()
end

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AIController"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 550)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "AI Learning Controller"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Title corner
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 12
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- AI Mode Selection
local modeFrame = Instance.new("Frame")
modeFrame.Name = "ModeFrame"
modeFrame.Size = UDim2.new(0.9, 0, 0, 150)
modeFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
modeFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
modeFrame.Parent = mainFrame

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 6)
modeCorner.Parent = modeFrame

local modeTitle = Instance.new("TextLabel")
modeTitle.Name = "ModeTitle"
modeTitle.Size = UDim2.new(1, 0, 0, 25)
modeTitle.Position = UDim2.new(0, 0, 0, 0)
modeTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
modeTitle.Text = "AI Learning Mode"
modeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
modeTitle.TextSize = 14
modeTitle.Font = Enum.Font.GothamBold
modeTitle.Parent = modeFrame

local modeTitleCorner = Instance.new("UICorner")
modeTitleCorner.CornerRadius = UDim.new(0, 6)
modeTitleCorner.Parent = modeTitle

-- Modes
local modes = {
    {Name = "Quick Learning", Value = "quick"},
    {Name = "Balanced", Value = "balanced"}, 
    {Name = "Advanced", Value = "advanced"},
    {Name = "Experimental", Value = "experimental"}
}

local currentMode = "balanced"

for i, mode in ipairs(modes) do
    local modeButton = Instance.new("TextButton")
    modeButton.Name = mode.Value
    modeButton.Size = UDim2.new(0.9, 0, 0, 25)
    modeButton.Position = UDim2.new(0.05, 0, 0, 30 + (i-1) * 30)
    modeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    modeButton.Text = mode.Name
    modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeButton.TextSize = 12
    modeButton.Font = Enum.Font.Gotham
    modeButton.Parent = modeFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = modeButton
    
    modeButton.MouseButton1Click:Connect(function()
        currentMode = mode.Value
        -- Update all buttons
        for _, btn in ipairs(modeFrame:GetChildren()) do
            if btn:IsA("TextButton") and btn.Name ~= "CloseButton" then
                if btn.Name == currentMode then
                    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
            end
        end
        print("Mode set to: " .. mode.Name)
    end)
end

-- Initialize first button as selected
wait(0.1)
if modeFrame:FindFirstChild("balanced") then
    modeFrame.balanced.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
end

-- Instructions Frame
local instructionsFrame = Instance.new("Frame")
instructionsFrame.Name = "InstructionsFrame"
instructionsFrame.Size = UDim2.new(0.9, 0, 0, 120)
instructionsFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
instructionsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
instructionsFrame.Parent = mainFrame

local instructionsCorner = Instance.new("UICorner")
instructionsCorner.CornerRadius = UDim.new(0, 6)
instructionsCorner.Parent = instructionsFrame

local instructionsTitle = Instance.new("TextLabel")
instructionsTitle.Name = "InstructionsTitle"
instructionsTitle.Size = UDim2.new(1, 0, 0, 25)
instructionsTitle.Position = UDim2.new(0, 0, 0, 0)
instructionsTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
instructionsTitle.Text = "AI Instructions"
instructionsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
instructionsTitle.TextSize = 14
instructionsTitle.Font = Enum.Font.GothamBold
instructionsTitle.Parent = instructionsFrame

local instructionsTitleCorner = Instance.new("UICorner")
instructionsTitleCorner.CornerRadius = UDim.new(0, 6)
instructionsTitleCorner.Parent = instructionsTitle

local instructionsBox = Instance.new("TextBox")
instructionsBox.Name = "InstructionsBox"
instructionsBox.Size = UDim2.new(0.9, 0, 0, 60)
instructionsBox.Position = UDim2.new(0.05, 0, 0.3, 0)
instructionsBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
instructionsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
instructionsBox.PlaceholderText = "Enter instructions for the AI..."
instructionsBox.TextSize = 12
instructionsBox.Font = Enum.Font.Gotham
instructionsBox.TextWrapped = true
instructionsBox.ClearTextOnFocus = false
instructionsBox.MultiLine = true
instructionsBox.Parent = instructionsFrame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 4)
boxCorner.Parent = instructionsBox

-- Control Buttons Frame
local controlFrame = Instance.new("Frame")
controlFrame.Name = "ControlFrame"
controlFrame.Size = UDim2.new(0.9, 0, 0, 40)
controlFrame.Position = UDim2.new(0.05, 0, 0.75, 0)
controlFrame.BackgroundTransparency = 1
controlFrame.Parent = mainFrame

-- Control Buttons
local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Size = UDim2.new(0.3, 0, 1, 0)
startButton.Position = UDim2.new(0, 0, 0, 0)
startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
startButton.Text = "Start AI"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.TextSize = 14
startButton.Font = Enum.Font.GothamBold
startButton.Parent = controlFrame

local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(0.3, 0, 1, 0)
stopButton.Position = UDim2.new(0.35, 0, 0, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
stopButton.Text = "Stop AI"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.TextSize = 14
stopButton.Font = Enum.Font.GothamBold
stopButton.Parent = controlFrame

local applyButton = Instance.new("TextButton")
applyButton.Name = "ApplyButton"
applyButton.Size = UDim2.new(0.3, 0, 1, 0)
applyButton.Position = UDim2.new(0.7, 0, 0, 0)
applyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
applyButton.Text = "Apply"
applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyButton.TextSize = 14
applyButton.Font = Enum.Font.GothamBold
applyButton.Parent = controlFrame

-- Add corners to buttons
for _, button in ipairs(controlFrame:GetChildren()) do
    if button:IsA("TextButton") then
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = button
    end
end

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.88, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Button functionality
startButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Status: AI Started - Mode: " .. currentMode
    print("AI Learning Started")
    print("Mode: " .. currentMode)
    print("Instructions: " .. instructionsBox.Text)
end)

stopButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Status: AI Stopped"
    print("AI Learning Stopped")
end)

applyButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Status: Settings Applied"
    print("Settings Applied")
    print("Mode: " .. currentMode)
    print("Instructions: " .. instructionsBox.Text)
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
    print("GUI Closed")
end)

print("AI Controller GUI created successfully!")
print("Current Mode: " .. currentMode)
