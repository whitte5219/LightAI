-- AI Controller GUI Script for Roblox
-- Place this in a ScreenGui in StarterGui

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AIController"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 800)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -400)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "AI Learning Controller"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

-- AI Mode Selection Frame
local modeFrame = createLabelFrame("AI Learning Mode", UDim2.new(0.9, 0, 0, 150), UDim2.new(0.05, 0, 0.07, 0))
local modeLayout = Instance.new("UIListLayout")
modeLayout.Padding = UDim.new(0, 5)
modeLayout.Parent = modeFrame

local modes = {
    {Name = "Quick Learning", Value = "quick", Desc = "Fast learning, focuses on main patterns"},
    {Name = "Balanced", Value = "balanced", Desc = "Balanced between speed and depth"},
    {Name = "Advanced Analysis", Value = "advanced", Desc = "Detailed study, deep pattern recognition"},
    {Name = "Experimental", Value = "experimental", Desc = "Tries unconventional approaches"}
}

local currentMode = "balanced"

for i, mode in ipairs(modes) do
    local modeButton = Instance.new("TextButton")
    modeButton.Name = mode.Value
    modeButton.Size = UDim2.new(1, 0, 0, 30)
    modeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    modeButton.Text = mode.Name
    modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeButton.TextSize = 14
    modeButton.Font = Enum.Font.Gotham
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Desc"
    descLabel.Size = UDim2.new(1, 0, 0, 15)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = mode.Desc
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.Parent = modeButton
    
    modeButton.Parent = modeFrame
    
    modeButton.MouseButton1Click:Connect(function()
        currentMode = mode.Value
        updateModeButtons()
    end)
end

-- Learning Parameters Frame
local paramsFrame = createLabelFrame("Learning Parameters", UDim2.new(0.9, 0, 0, 120), UDim2.new(0.05, 0, 0.3, 0))

-- Learning Speed Slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0, 5)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Learning Speed: 50%"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = paramsFrame

local speedSlider = createSlider(UDim2.new(0, 0, 0, 30), 0.5)
speedSlider.Parent = paramsFrame

-- Exploration Rate Slider
local exploreLabel = Instance.new("TextLabel")
exploreLabel.Size = UDim2.new(1, 0, 0, 20)
exploreLabel.Position = UDim2.new(0, 0, 0, 65)
exploreLabel.BackgroundTransparency = 1
exploreLabel.Text = "Exploration Rate: 70%"
exploreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
exploreLabel.TextSize = 14
exploreLabel.Font = Enum.Font.Gotham
exploreLabel.TextXAlignment = Enum.TextXAlignment.Left
exploreLabel.Parent = paramsFrame

local exploreSlider = createSlider(UDim2.new(0, 0, 0, 90), 0.7)
exploreSlider.Parent = paramsFrame

-- Instructions Frame
local instructionsFrame = createLabelFrame("AI Instructions & Hints", UDim2.new(0.9, 0, 0, 150), UDim2.new(0.05, 0, 0.5, 0))

local instructionsBox = Instance.new("TextBox")
instructionsBox.Name = "InstructionsBox"
instructionsBox.Size = UDim2.new(0.95, 0, 0, 80)
instructionsBox.Position = UDim2.new(0.025, 0, 0.1, 0)
instructionsBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
instructionsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
instructionsBox.Text = "Enter instructions for the AI here..."
instructionsBox.TextSize = 12
instructionsBox.Font = Enum.Font.Gotham
instructionsBox.TextWrapped = true
instructionsBox.ClearTextOnFocus = false
instructionsBox.MultiLine = true
instructionsBox.Parent = instructionsFrame

-- Quick Hints Buttons
local hintsFrame = Instance.new("Frame")
hintsFrame.Name = "HintsFrame"
hintsFrame.Size = UDim2.new(0.95, 0, 0, 30)
hintsFrame.Position = UDim2.new(0.025, 0, 0.7, 0)
hintsFrame.BackgroundTransparency = 1
hintsFrame.Parent = instructionsFrame

local hints = {"Focus on defense", "Be aggressive", "Learn combos", "Watch patterns"}
for i, hint in ipairs(hints) do
    local hintButton = Instance.new("TextButton")
    hintButton.Name = hint
    hintButton.Size = UDim2.new(0.23, 0, 1, 0)
    hintButton.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
    hintButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    hintButton.Text = hint
    hintButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    hintButton.TextSize = 10
    hintButton.Font = Enum.Font.Gotham
    hintButton.TextWrapped = true
    hintButton.Parent = hintsFrame
    
    hintButton.MouseButton1Click:Connect(function()
        instructionsBox.Text = instructionsBox.Text .. "\n" .. hint
    end)
end

-- Control Buttons Frame
local controlFrame = Instance.new("Frame")
controlFrame.Name = "ControlFrame"
controlFrame.Size = UDim2.new(0.9, 0, 0, 50)
controlFrame.Position = UDim2.new(0.05, 0, 0.85, 0)
controlFrame.BackgroundTransparency = 1
controlFrame.Parent = mainFrame

local startButton = createControlButton("Start AI Learning", UDim2.new(0, 0, 0, 0))
local stopButton = createControlButton("Stop AI", UDim2.new(0.34, 0, 0, 0))
local applyButton = createControlButton("Apply Settings", UDim2.new(0.68, 0, 0, 0))

startButton.Parent = controlFrame
stopButton.Parent = controlFrame
applyButton.Parent = controlFrame

-- Function to create labeled frames
function createLabelFrame(title, size, position)
    local frame = Instance.new("Frame")
    frame.Name = title .. "Frame"
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = frame
    
    return frame
end

-- Function to create sliders
function createSlider(position, initialValue)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.Size = UDim2.new(1, 0, 0, 20)
    sliderFrame.Position = position
    sliderFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    sliderFrame.BorderSizePixel = 0
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(initialValue, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(1, 0, 1, 0)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Text = ""
    sliderButton.Parent = sliderFrame
    
    return sliderFrame
end

-- Function to create control buttons
function createControlButton(text, position)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = UDim2.new(0.3, 0, 1, 0)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    
    return button
end

-- Function to update mode buttons appearance
function updateModeButtons()
    for _, child in ipairs(modeFrame:GetChildren()) do
        if child:IsA("TextButton") then
            if child.Name == currentMode then
                child.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            else
                child.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end
    end
end

-- Initialize mode buttons
updateModeButtons()

-- Button functionality
startButton.MouseButton1Click:Connect(function()
    print("AI Learning Started - Mode: " .. currentMode)
    -- This is where you'll connect to your AI system
end)

stopButton.MouseButton1Click:Connect(function()
    print("AI Learning Stopped")
    -- Stop AI functionality
end)

applyButton.MouseButton1Click:Connect(function()
    print("Settings Applied")
    print("Mode: " .. currentMode)
    print("Instructions: " .. instructionsBox.Text)
    -- Apply settings to AI
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Add GUI to player
screenGui.Parent = playerGui

print("AI Controller GUI loaded successfully!")
print("Current Mode: " .. currentMode)

return screenGui
