-- AI Controller GUI Script for Roblox
-- Place this in a LocalScript within StarterGui

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AIController"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 600) -- Reduced height
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -300)
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

-- Function to create labeled frames
local function createLabelFrame(title, size, position)
    local frame = Instance.new("Frame")
    frame.Name = title .. "Frame"
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
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
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleLabel
    
    return frame
end

-- Function to create sliders
local function createSlider(parent, labelText, initialValue, positionY)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = "SliderContainer"
    sliderContainer.Size = UDim2.new(0.9, 0, 0, 60)
    sliderContainer.Position = UDim2.new(0.05, 0, positionY, 0)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. math.floor(initialValue * 100) .. "%"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderContainer
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.Size = UDim2.new(1, 0, 0, 20)
    sliderFrame.Position = UDim2.new(0, 0, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = sliderContainer
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 10)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(initialValue, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = fill
    
    return {
        container = sliderContainer,
        label = label,
        fill = fill,
        value = initialValue
    }
end

-- Function to create control buttons
local function createControlButton(text, position, size)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = size or UDim2.new(0.3, 0, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    return button
end

-- AI Mode Selection Frame
local modeFrame = createLabelFrame("AI Learning Mode", UDim2.new(0.9, 0, 0, 180), UDim2.new(0.05, 0, 0.1, 0))
modeFrame.Parent = mainFrame

local modes = {
    {Name = "Quick Learning", Value = "quick", Desc = "Fast learning, focuses on main patterns"},
    {Name = "Balanced", Value = "balanced", Desc = "Balanced between speed and depth"},
    {Name = "Advanced Analysis", Value = "advanced", Desc = "Detailed study, deep pattern recognition"},
    {Name = "Experimental", Value = "experimental", Desc = "Tries unconventional approaches"}
}

local currentMode = "balanced"
local modeButtons = {}

local modeLayout = Instance.new("UIListLayout")
modeLayout.Padding = UDim.new(0, 8)
modeLayout.Parent = modeFrame

for i, mode in ipairs(modes) do
    local modeButton = Instance.new("TextButton")
    modeButton.Name = mode.Value
    modeButton.Size = UDim2.new(0.9, 0, 0, 35)
    modeButton.Position = UDim2.new(0.05, 0, 0, (i-1) * 40 + 30)
    modeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    modeButton.Text = mode.Name
    modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeButton.TextSize = 14
    modeButton.Font = Enum.Font.Gotham
    modeButton.Parent = modeFrame
    
    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 6)
    modeCorner.Parent = modeButton
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Desc"
    descLabel.Size = UDim2.new(0.9, 0, 0, 12)
    descLabel.Position = UDim2.new(0.05, 0, 0, (i-1) * 40 + 55)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = mode.Desc
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.TextSize = 9
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = modeFrame
    
    table.insert(modeButtons, modeButton)
    
    modeButton.MouseButton1Click:Connect(function()
        currentMode = mode.Value
        updateModeButtons()
    end)
end

-- Function to update mode buttons appearance
local function updateModeButtons()
    for _, button in ipairs(modeButtons) do
        if button.Name == currentMode then
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        else
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
end

-- Initialize mode buttons
updateModeButtons()

-- Learning Parameters Frame
local paramsFrame = createLabelFrame("Learning Parameters", UDim2.new(0.9, 0, 0, 130), UDim2.new(0.05, 0, 0.4, 0))
paramsFrame.Parent = mainFrame

-- Create sliders
local speedSlider = createSlider(paramsFrame, "Learning Speed", 0.5, 0.1)
local exploreSlider = createSlider(paramsFrame, "Exploration Rate", 0.7, 0.55)

-- Instructions Frame
local instructionsFrame = createLabelFrame("AI Instructions", UDim2.new(0.9, 0, 0, 120), UDim2.new(0.05, 0, 0.65, 0))
instructionsFrame.Parent = mainFrame

local instructionsBox = Instance.new("TextBox")
instructionsBox.Name = "InstructionsBox"
instructionsBox.Size = UDim2.new(0.9, 0, 0, 60)
instructionsBox.Position = UDim2.new(0.05, 0, 0.2, 0)
instructionsBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
instructionsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
instructionsBox.PlaceholderText = "Enter instructions for the AI here..."
instructionsBox.TextSize = 12
instructionsBox.Font = Enum.Font.Gotham
instructionsBox.TextWrapped = true
instructionsBox.ClearTextOnFocus = false
instructionsBox.MultiLine = true
instructionsBox.Parent = instructionsFrame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = instructionsBox

-- Control Buttons Frame
local controlFrame = Instance.new("Frame")
controlFrame.Name = "ControlFrame"
controlFrame.Size = UDim2.new(0.9, 0, 0, 50)
controlFrame.Position = UDim2.new(0.05, 0, 0.9, 0)
controlFrame.BackgroundTransparency = 1
controlFrame.Parent = mainFrame

local startButton = createControlButton("Start AI", UDim2.new(0, 0, 0, 0), UDim2.new(0.32, 0, 1, 0))
local stopButton = createControlButton("Stop AI", UDim2.new(0.34, 0, 0, 0), UDim2.new(0.32, 0, 1, 0))
local applyButton = createControlButton("Apply", UDim2.new(0.68, 0, 0, 0), UDim2.new(0.32, 0, 1, 0))

startButton.Parent = controlFrame
stopButton.Parent = controlFrame
applyButton.Parent = controlFrame

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
