-- LightAI Controller GUI - Windows 11 Style
-- Copy and paste this entire script into Roblox Studio command bar

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clear any existing GUI
if playerGui:FindFirstChild("LightAIController") then
    playerGui.LightAIController:Destroy()
end

-- Color scheme
local colors = {
    background = Color3.fromRGB(32, 32, 32),
    surface = Color3.fromRGB(40, 40, 40),
    surfaceLighter = Color3.fromRGB(48, 48, 48),
    accent = Color3.fromRGB(0, 120, 215),
    textPrimary = Color3.fromRGB(240, 240, 240),
    textSecondary = Color3.fromRGB(180, 180, 180),
    divider = Color3.fromRGB(55, 55, 55)
}

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightAIController"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main window container
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 700, 0, 500)
mainWindow.Position = UDim2.new(0.5, -350, 0.5, -250)
mainWindow.BackgroundColor3 = colors.background
mainWindow.BackgroundTransparency = 0.1 -- Slight transparency
mainWindow.BorderSizePixel = 0
mainWindow.Parent = screenGui

-- Main window corner rounding
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainWindow

-- Drop shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805" -- Soft shadow image
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainWindow
shadow.ZIndex = -1

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = colors.surface
titleBar.BorderSizePixel = 0
titleBar.Parent = mainWindow

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 8)
titleBarCorner.Parent = titleBar

-- Title text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0, 300, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🌟 LightAI Controller | Slap Battles 🌟"
titleText.TextColor3 = colors.textPrimary
titleText.TextSize = 12
titleText.Font = Enum.Font.GothamSemibold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Window controls (minimize, maximize, close)
local windowControls = Instance.new("Frame")
windowControls.Name = "WindowControls"
windowControls.Size = UDim2.new(0, 90, 1, 0)
windowControls.Position = UDim2.new(1, -90, 0, 0)
windowControls.BackgroundTransparency = 1
windowControls.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(0, 0, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = colors.textPrimary
minimizeBtn.TextSize = 14
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = windowControls

local maximizeBtn = Instance.new("TextButton")
maximizeBtn.Name = "MaximizeBtn"
maximizeBtn.Size = UDim2.new(0, 30, 1, 0)
maximizeBtn.Position = UDim2.new(0, 30, 0, 0)
maximizeBtn.BackgroundTransparency = 1
maximizeBtn.Text = "□"
maximizeBtn.TextColor3 = colors.textPrimary
maximizeBtn.TextSize = 12
maximizeBtn.Font = Enum.Font.GothamBold
maximizeBtn.Parent = windowControls

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(0, 60, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = colors.textPrimary
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = windowControls

-- Main content area (sidebar + content)
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, 0, 1, -32)
contentArea.Position = UDim2.new(0, 0, 0, 32)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainWindow

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = colors.surface
sidebar.BorderSizePixel = 0
sidebar.Parent = contentArea

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = sidebar

-- Sidebar navigation items
local navItems = {
    {Name = "Home", Icon = "🏠"},
    {Name = "Combat", Icon = "⚔️"},
    {Name = "Learning", Icon = "🧠"},
    {Name = "Settings", Icon = "⚙️"},
    {Name = "Players", Icon = "👥"}
}

local selectedNav = "Learning"
local navButtons = {}

for i, item in ipairs(navItems) do
    local navButton = Instance.new("TextButton")
    navButton.Name = item.Name .. "Nav"
    navButton.Size = UDim2.new(1, -10, 0, 36)
    navButton.Position = UDim2.new(0, 5, 0, 10 + (i-1) * 40)
    navButton.BackgroundColor3 = colors.surface
    navButton.Text = "   " .. item.Icon .. "  " .. item.Name
    navButton.TextColor3 = colors.textSecondary
    navButton.TextSize = 12
    navButton.Font = Enum.Font.Gotham
    navButton.TextXAlignment = Enum.TextXAlignment.Left
    navButton.Parent = sidebar
    
    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = UDim.new(0, 6)
    navCorner.Parent = navButton
    
    navButton.MouseButton1Click:Connect(function()
        selectedNav = item.Name
        updateNavigation()
        updateContent()
    end)
    
    table.insert(navButtons, navButton)
end

-- Main content frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -160, 1, 0)
contentFrame.Position = UDim2.new(0, 160, 0, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = contentArea

-- Content pages
local pages = {
    Home = createHomePage(),
    Combat = createCombatPage(),
    Learning = createLearningPage(),
    Settings = createSettingsPage(),
    Players = createPlayersPage()
}

for name, page in pairs(pages) do
    page.Visible = (name == selectedNav)
    page.Parent = contentFrame
end

-- Function to create home page
function createHomePage()
    local page = Instance.new("Frame")
    page.Name = "HomePage"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "LightAI Dashboard"
    title.TextColor3 = colors.textPrimary
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = page
    
    local statusCard = createCard("AI Status", UDim2.new(0, 300, 0, 120), UDim2.new(0, 20, 0, 60))
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -20, 0.6, 0)
    statusText.Position = UDim2.new(0, 10, 0, 40)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Status: Ready\nMode: Balanced"
    statusText.TextColor3 = colors.textSecondary
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    statusText.Parent = statusCard
    
    return page
end

-- Function to create learning page (main AI controls)
function createLearningPage()
    local page = Instance.new("Frame")
    page.Name = "LearningPage"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "AI Learning Controls"
    title.TextColor3 = colors.textPrimary
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = page
    
    -- AI Mode Selection Card
    local modeCard = createCard("Learning Mode", UDim2.new(0, 300, 0, 180), UDim2.new(0, 20, 0, 60))
    
    local modes = {
        {Name = "Quick Learning", Desc = "Fast learning, focuses on main patterns"},
        {Name = "Balanced", Desc = "Balanced between speed and depth"},
        {Name = "Advanced Analysis", Desc = "Detailed study, deep pattern recognition"},
        {Name = "Experimental", Desc = "Tries unconventional approaches"}
    }
    
    local currentMode = "Balanced"
    
    for i, mode in ipairs(modes) do
        local modeBtn = Instance.new("TextButton")
        modeBtn.Name = mode.Name
        modeBtn.Size = UDim2.new(1, -20, 0, 30)
        modeBtn.Position = UDim2.new(0, 10, 0, 30 + (i-1) * 35)
        modeBtn.BackgroundColor3 = colors.surface
        modeBtn.Text = mode.Name
        modeBtn.TextColor3 = colors.textSecondary
        modeBtn.TextSize = 11
        modeBtn.Font = Enum.Font.Gotham
        modeBtn.Parent = modeBtn
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = modeBtn
        
        modeBtn.MouseButton1Click:Connect(function()
            currentMode = mode.Name
            -- Update button states
            for _, btn in ipairs(modeCard:GetChildren()) do
                if btn:IsA("TextButton") then
                    if btn.Name == currentMode then
                        btn.BackgroundColor3 = colors.accent
                        btn.TextColor3 = colors.textPrimary
                    else
                        btn.BackgroundColor3 = colors.surface
                        btn.TextColor3 = colors.textSecondary
                    end
                end
            end
        end)
        
        modeBtn.Parent = modeCard
    end
    
    -- Initialize first button as selected
    if modeCard:FindFirstChild("Balanced") then
        modeCard.Balanced.BackgroundColor3 = colors.accent
        modeCard.Balanced.TextColor3 = colors.textPrimary
    end
    
    -- Instructions Card
    local instructionsCard = createCard("AI Instructions", UDim2.new(0, 300, 0, 150), UDim2.new(0, 20, 0, 260))
    
    local instructionsBox = Instance.new("TextBox")
    instructionsBox.Size = UDim2.new(1, -20, 1, -50)
    instructionsBox.Position = UDim2.new(0, 10, 0, 30)
    instructionsBox.BackgroundColor3 = colors.surfaceLighter
    instructionsBox.TextColor3 = colors.textPrimary
    instructionsBox.PlaceholderText = "Enter instructions for the AI..."
    instructionsBox.TextSize = 11
    instructionsBox.Font = Enum.Font.Gotham
    instructionsBox.TextWrapped = true
    instructionsBox.ClearTextOnFocus = false
    instructionsBox.MultiLine = true
    instructionsBox.Text = ""
    instructionsBox.Parent = instructionsCard
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = instructionsBox
    
    -- Control Buttons Card
    local controlCard = createCard("AI Controls", UDim2.new(0, 300, 0, 80), UDim2.new(0, 20, 0, 430))
    
    local startBtn = Instance.new("TextButton")
    startBtn.Name = "StartBtn"
    startBtn.Size = UDim2.new(0.45, 0, 0, 32)
    startBtn.Position = UDim2.new(0.025, 0, 0, 35)
    startBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    startBtn.Text = "START AI"
    startBtn.TextColor3 = colors.textPrimary
    startBtn.TextSize = 12
    startBtn.Font = Enum.Font.GothamBold
    startBtn.Parent = controlCard
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Name = "StopBtn"
    stopBtn.Size = UDim2.new(0.45, 0, 0, 32)
    stopBtn.Position = UDim2.new(0.525, 0, 0, 35)
    stopBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    stopBtn.Text = "STOP AI"
    stopBtn.TextColor3 = colors.textPrimary
    stopBtn.TextSize = 12
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.Parent = controlCard
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = startBtn
    btnCorner:Clone().Parent = stopBtn
    
    -- Warning Card
    local warningCard = createCard("Warning", UDim2.new(0, 300, 0, 80), UDim2.new(0, 340, 0, 60))
    warningCard.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
    
    local warningText = Instance.new("TextLabel")
    warningText.Size = UDim2.new(1, -20, 1, -30)
    warningText.Position = UDim2.new(0, 10, 0, 25)
    warningText.BackgroundTransparency = 1
    warningText.Text = "MAKE SURE TO CONFIGURE AI SETTINGS BEFORE STARTING. IMPROPER CONFIGURATION MAY LEAD TO UNEXPECTED BEHAVIOR."
    warningText.TextColor3 = Color3.fromRGB(255, 100, 100)
    warningText.TextSize = 10
    warningText.Font = Enum.Font.GothamBold
    warningText.TextWrapped = true
    warningText.TextYAlignment = Enum.TextYAlignment.Top
    warningText.Parent = warningCard
    
    return page
end

-- Function to create combat page
function createCombatPage()
    local page = Instance.new("Frame")
    page.Name = "CombatPage"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Combat Settings"
    title.TextColor3 = colors.textPrimary
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = page
    
    return page
end

-- Function to create settings page
function createSettingsPage()
    local page = Instance.new("Frame")
    page.Name = "SettingsPage"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Settings"
    title.TextColor3 = colors.textPrimary
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = page
    
    return page
end

-- Function to create players page
function createPlayersPage()
    local page = Instance.new("Frame")
    page.Name = "PlayersPage"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Players"
    title.TextColor3 = colors.textPrimary
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = page
    
    return page
end

-- Utility function to create cards
function createCard(title, size, position)
    local card = Instance.new("Frame")
    card.Size = size
    card.Position = position
    card.BackgroundColor3 = colors.surfaceLighter
    card.BorderSizePixel = 0
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, 0, 0, 25)
    cardTitle.Position = UDim2.new(0, 0, 0, 0)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = title
    cardTitle.TextColor3 = colors.textPrimary
    cardTitle.TextSize = 14
    cardTitle.Font = Enum.Font.GothamSemibold
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = card
    
    local titlePadding = Instance.new("Frame")
    titlePadding.Size = UDim2.new(1, 0, 0, 1)
    titlePadding.Position = UDim2.new(0, 0, 0, 25)
    titlePadding.BackgroundColor3 = colors.divider
    titlePadding.BorderSizePixel = 0
    titlePadding.Parent = card
    
    return card
end

-- Function to update navigation highlights
function updateNavigation()
    for _, button in ipairs(navButtons) do
        local itemName = button.Name:gsub("Nav", "")
        if itemName == selectedNav then
            button.BackgroundColor3 = colors.accent
            button.TextColor3 = colors.textPrimary
        else
            button.BackgroundColor3 = colors.surface
            button.TextColor3 = colors.textSecondary
        end
    end
end

-- Function to update content visibility
function updateContent()
    for name, page in pairs(pages) do
        page.Visible = (name == selectedNav)
    end
end

-- Initialize navigation
updateNavigation()

-- Window control functionality
minimizeBtn.MouseButton1Click:Connect(function()
    contentArea.Visible = not contentArea.Visible
end)

maximizeBtn.MouseButton1Click:Connect(function()
    if mainWindow.Size == UDim2.new(0, 700, 0, 500) then
        mainWindow.Size = UDim2.new(0, 900, 0, 600)
        mainWindow.Position = UDim2.new(0.5, -450, 0.5, -300)
    else
        mainWindow.Size = UDim2.new(0, 700, 0, 500)
        mainWindow.Position = UDim2.new(0.5, -350, 0.5, -250)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Make window draggable
local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainWindow.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("🌟 LightAI Controller loaded successfully!")
print("Windows 11 style GUI created with sidebar navigation")
