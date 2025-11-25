-- LightAI Controller - Premium Black & White Design
-- Copy and paste this entire script into Roblox Studio command bar

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clear any existing GUI
if playerGui:FindFirstChild("LightAIController") then
    playerGui.LightAIController:Destroy()
end

-- Color scheme - Black, White, Gray only
local colors = {
    background = Color3.fromRGB(15, 15, 15),
    surface = Color3.fromRGB(25, 25, 25),
    surfaceLight = Color3.fromRGB(40, 40, 40),
    surfaceLighter = Color3.fromRGB(60, 60, 60),
    textPrimary = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(200, 200, 200),
    textTertiary = Color3.fromRGB(150, 150, 150),
    accent = Color3.fromRGB(255, 255, 255),
    divider = Color3.fromRGB(50, 50, 50)
}

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightAIController"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main window container
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 900, 0, 650)
mainWindow.Position = UDim2.new(0.5, -450, 0.5, -325)
mainWindow.BackgroundColor3 = colors.background
mainWindow.BackgroundTransparency = 0
mainWindow.BorderSizePixel = 0
mainWindow.ClipsDescendants = true
mainWindow.Parent = screenGui

-- Main window corner rounding
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainWindow

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = colors.surface
titleBar.BorderSizePixel = 0
titleBar.Parent = mainWindow

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 12)
titleBarCorner.Parent = titleBar

-- Title text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0, 300, 1, 0)
titleText.Position = UDim2.new(0, 20, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "LightAI Controller"
titleText.TextColor3 = colors.textPrimary
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close button with smooth hover
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 6)
closeBtn.BackgroundColor3 = colors.surface
closeBtn.TextColor3 = colors.textSecondary
closeBtn.TextSize = 16
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Main content area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, 0, 1, -45)
contentArea.Position = UDim2.new(0, 0, 0, 45)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainWindow

-- Sidebar Navigation
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = colors.surface
sidebar.BorderSizePixel = 0
sidebar.Parent = contentArea

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 12)
sidebarCorner.Parent = sidebar

-- Sidebar navigation items
local navItems = {
    {Name = "Dashboard", Icon = "📊"},
    {Name = "AI Learning", Icon = "🧠"}, 
    {Name = "Combat Settings", Icon = "⚔️"},
    {Name = "Configuration", Icon = "⚙️"},
    {Name = "Player Data", Icon = "👥"}
}

local currentPage = "AI Learning"
local navButtons = {}

-- Create smooth selection indicator
local selectionIndicator = Instance.new("Frame")
selectionIndicator.Name = "SelectionIndicator"
selectionIndicator.Size = UDim2.new(0, 4, 0, 40)
selectionIndicator.Position = UDim2.new(1, -2, 0, 10)
selectionIndicator.BackgroundColor3 = colors.accent
selectionIndicator.BorderSizePixel = 0
selectionIndicator.Visible = false
selectionIndicator.Parent = sidebar

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, 2)
indicatorCorner.Parent = selectionIndicator

for i, item in ipairs(navItems) do
    local navButton = Instance.new("TextButton")
    navButton.Name = item.Name .. "Button"
    navButton.Size = UDim2.new(1, -10, 0, 50)
    navButton.Position = UDim2.new(0, 5, 0, 15 + (i-1) * 55)
    navButton.BackgroundColor3 = colors.surface
    navButton.Text = "    " .. item.Name
    navButton.TextColor3 = colors.textSecondary
    navButton.TextSize = 14
    navButton.Font = Enum.Font.GothamSemibold
    navButton.TextXAlignment = Enum.TextXAlignment.Left
    navButton.Parent = sidebar
    
    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = UDim.new(0, 8)
    navCorner.Parent = navButton
    
    -- Icon label
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 10, 0, 10)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = item.Icon
    iconLabel.TextColor3 = colors.textSecondary
    iconLabel.TextSize = 16
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.Parent = navButton
    
    -- Hover animation
    navButton.MouseEnter:Connect(function()
        if currentPage ~= item.Name then
            animateButtonHover(navButton, true)
        end
    end)
    
    navButton.MouseLeave:Connect(function()
        if currentPage ~= item.Name then
            animateButtonHover(navButton, false)
        end
    end)
    
    navButton.MouseButton1Click:Connect(function()
        switchPage(item.Name, navButton)
    end)
    
    table.insert(navButtons, {button = navButton, name = item.Name})
    
    -- Set initial active state
    if item.Name == currentPage then
        navButton.BackgroundColor3 = colors.surfaceLight
        navButton.TextColor3 = colors.textPrimary
        iconLabel.TextColor3 = colors.textPrimary
        selectionIndicator.Visible = true
        selectionIndicator.Position = UDim2.new(1, -2, 0, navButton.Position.Y.Offset)
    end
end

-- Main content frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -220, 1, 0)
contentFrame.Position = UDim2.new(0, 220, 0, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.Parent = contentArea

-- Create pages
local pages = {}

-- Dashboard Page
local dashboardPage = createDashboardPage()
dashboardPage.Name = "DashboardPage"
dashboardPage.Parent = contentFrame
pages["Dashboard"] = dashboardPage

-- AI Learning Page (Main Page)
local aiLearningPage = createAILearningPage()
aiLearningPage.Name = "AILearningPage"
aiLearningPage.Parent = contentFrame
pages["AI Learning"] = aiLearningPage

-- Combat Settings Page
local combatPage = createCombatPage()
combatPage.Name = "CombatPage"
combatPage.Parent = contentFrame
pages["Combat Settings"] = combatPage

-- Configuration Page
local configPage = createConfigPage()
configPage.Name = "ConfigPage"
configPage.Parent = contentFrame
pages["Configuration"] = configPage

-- Player Data Page
local playerPage = createPlayerPage()
playerPage.Name = "PlayerPage"
playerPage.Parent = contentFrame
pages["Player Data"] = playerPage

-- Initially show only AI Learning page
for pageName, page in pairs(pages) do
    page.Visible = (pageName == currentPage)
end

-- Function to create dashboard page
function createDashboardPage()
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = createSectionTitle("Dashboard", page)
    
    -- Stats cards
    local statsGrid = Instance.new("Frame")
    statsGrid.Name = "StatsGrid"
    statsGrid.Size = UDim2.new(1, -40, 0, 120)
    statsGrid.Position = UDim2.new(0, 20, 0, 70)
    statsGrid.BackgroundTransparency = 1
    statsGrid.Parent = page
    
    local stats = {
        {"Learning Sessions", "12"},
        {"Games Analyzed", "47"},
        {"Success Rate", "89%"},
        {"Current Mode", "Balanced"}
    }
    
    for i, stat in ipairs(stats) do
        local card = createStatCard(stat[1], stat[2], UDim2.new(0.23, 0, 0, 120), UDim2.new((i-1) * 0.25, 0, 0, 0))
        card.Parent = statsGrid
    end
    
    return page
end

-- Function to create AI Learning page (main functionality)
function createAILearningPage()
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = createSectionTitle("AI Learning Controls", page)
    
    -- Learning Mode Section
    local modeSection = createSection("Learning Mode", UDim2.new(0, 400, 0, 200), UDim2.new(0, 20, 0, 70))
    modeSection.Parent = page
    
    local modes = {
        {"Quick Learning", "Fast adaptation, focuses on core mechanics"},
        {"Balanced", "Optimal balance between speed and depth"},
        {"Advanced Analysis", "Comprehensive pattern recognition"},
        {"Experimental", "Innovative approaches and strategies"}
    }
    
    local currentMode = "Balanced"
    local modeButtons = {}
    
    for i, mode in ipairs(modes) do
        local modeButton = Instance.new("TextButton")
        modeButton.Name = mode[1]
        modeButton.Size = UDim2.new(1, -20, 0, 35)
        modeButton.Position = UDim2.new(0, 10, 0, 30 + (i-1) * 42)
        modeButton.BackgroundColor3 = colors.surface
        modeButton.Text = mode[1]
        modeButton.TextColor3 = colors.textSecondary
        modeButton.TextSize = 13
        modeButton.Font = Enum.Font.Gotham
        modeButton.Parent = modeSection
        
        local modeCorner = Instance.new("UICorner")
        modeCorner.CornerRadius = UDim.new(0, 6)
        modeCorner.Parent = modeButton
        
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -20, 0, 14)
        descLabel.Position = UDim2.new(0, 10, 0, 30 + (i-1) * 42 + 25)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = mode[2]
        descLabel.TextColor3 = colors.textTertiary
        descLabel.TextSize = 10
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = modeSection
        
        modeButton.MouseButton1Click:Connect(function()
            currentMode = mode[1]
            for _, btn in ipairs(modeButtons) do
                if btn.Name == currentMode then
                    animateSelection(btn, true)
                    btn.TextColor3 = colors.textPrimary
                else
                    animateSelection(btn, false)
                    btn.TextColor3 = colors.textSecondary
                end
            end
        end)
        
        table.insert(modeButtons, modeButton)
        
        if mode[1] == currentMode then
            modeButton.BackgroundColor3 = colors.surfaceLight
            modeButton.TextColor3 = colors.textPrimary
        end
    end
    
    -- Instructions Section
    local instructionsSection = createSection("AI Instructions", UDim2.new(0, 400, 0, 180), UDim2.new(0, 20, 0, 290))
    instructionsSection.Parent = page
    
    local instructionsBox = Instance.new("TextBox")
    instructionsBox.Size = UDim2.new(1, -20, 1, -50)
    instructionsBox.Position = UDim2.new(0, 10, 0, 30)
    instructionsBox.BackgroundColor3 = colors.surface
    instructionsBox.TextColor3 = colors.textPrimary
    instructionsBox.PlaceholderText = "Provide instructions, strategies, or goals for the AI..."
    instructionsBox.TextSize = 12
    instructionsBox.Font = Enum.Font.Gotham
    instructionsBox.TextWrapped = true
    instructionsBox.ClearTextOnFocus = false
    instructionsBox.MultiLine = true
    instructionsBox.Text = ""
    instructionsBox.Parent = instructionsSection
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = instructionsBox
    
    -- Control Section
    local controlSection = createSection("AI Controls", UDim2.new(0, 400, 0, 100), UDim2.new(0, 20, 0, 490))
    controlSection.Parent = page
    
    local startBtn = createControlButton("START AI LEARNING", UDim2.new(0, 10, 0, 30), UDim2.new(0.48, -5, 0, 50))
    startBtn.BackgroundColor3 = colors.surfaceLight
    startBtn.Parent = controlSection
    
    local stopBtn = createControlButton("STOP AI", UDim2.new(0.52, 5, 0, 30), UDim2.new(0.48, -5, 0, 50))
    stopBtn.BackgroundColor3 = colors.surfaceLight
    stopBtn.Parent = controlSection
    
    -- Status Section
    local statusSection = createSection("System Status", UDim2.new(0, 400, 0, 120), UDim2.new(0, 440, 0, 70))
    statusSection.Parent = page
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -20, 1, -40)
    statusText.Position = UDim2.new(0, 10, 0, 30)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Status: Ready\nCurrent Mode: Balanced\nLearning Sessions: 12\nSuccess Rate: 89%"
    statusText.TextColor3 = colors.textSecondary
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    statusText.Parent = statusSection
    
    return page
end

-- Function to create combat page
function createCombatPage()
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = createSectionTitle("Combat Settings", page)
    
    local comingSoon = Instance.new("TextLabel")
    comingSoon.Size = UDim2.new(1, 0, 0, 100)
    comingSoon.Position = UDim2.new(0, 0, 0.4, 0)
    comingSoon.BackgroundTransparency = 1
    comingSoon.Text = "Combat Settings\n(Coming Soon)"
    comingSoon.TextColor3 = colors.textTertiary
    comingSoon.TextSize = 20
    comingSoon.Font = Enum.Font.Gotham
    comingSoon.Parent = page
    
    return page
end

-- Function to create config page
function createConfigPage()
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = createSectionTitle("Configuration", page)
    
    local comingSoon = Instance.new("TextLabel")
    comingSoon.Size = UDim2.new(1, 0, 0, 100)
    comingSoon.Position = UDim2.new(0, 0, 0.4, 0)
    comingSoon.BackgroundTransparency = 1
    comingSoon.Text = "Configuration Settings\n(Coming Soon)"
    comingSoon.TextColor3 = colors.textTertiary
    comingSoon.TextSize = 20
    comingSoon.Font = Enum.Font.Gotham
    comingSoon.Parent = page
    
    return page
end

-- Function to create player page
function createPlayerPage()
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    
    local title = createSectionTitle("Player Data", page)
    
    local comingSoon = Instance.new("TextLabel")
    comingSoon.Size = UDim2.new(1, 0, 0, 100)
    comingSoon.Position = UDim2.new(0, 0, 0.4, 0)
    comingSoon.BackgroundTransparency = 1
    comingSoon.Text = "Player Data Analysis\n(Coming Soon)"
    comingSoon.TextColor3 = colors.textTertiary
    comingSoon.TextSize = 20
    comingSoon.Font = Enum.Font.Gotham
    comingSoon.Parent = page
    
    return page
end

-- Utility function to create section titles
function createSectionTitle(text, parent)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = colors.textPrimary
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = parent
    return title
end

-- Utility function to create sections
function createSection(title, size, position)
    local section = Instance.new("Frame")
    section.Size = size
    section.Position = position
    section.BackgroundColor3 = colors.surface
    section.BorderSizePixel = 0
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 10)
    sectionCorner.Parent = section
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, 0, 0, 25)
    sectionTitle.Position = UDim2.new(0, 0, 0, 0)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = title
    sectionTitle.TextColor3 = colors.textPrimary
    sectionTitle.TextSize = 16
    sectionTitle.Font = Enum.Font.GothamSemibold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section
    
    local titlePadding = Instance.new("Frame")
    titlePadding.Size = UDim2.new(1, -20, 0, 1)
    titlePadding.Position = UDim2.new(0, 10, 0, 25)
    titlePadding.BackgroundColor3 = colors.divider
    titlePadding.BorderSizePixel = 0
    titlePadding.Parent = section
    
    return section
end

-- Utility function to create stat cards
function createStatCard(title, value, size, position)
    local card = Instance.new("Frame")
    card.Size = size
    card.Position = position
    card.BackgroundColor3 = colors.surface
    card.BorderSizePixel = 0
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = colors.textSecondary
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -20, 0, 30)
    valueLabel.Position = UDim2.new(0, 10, 0, 35)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = value
    valueLabel.TextColor3 = colors.textPrimary
    valueLabel.TextSize = 20
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = card
    
    return card
end

-- Utility function to create control buttons
function createControlButton(text, position, size)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = colors.surface
    button.Text = text
    button.TextColor3 = colors.textPrimary
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        animateButtonHover(button, true)
    end)
    
    button.MouseLeave:Connect(function()
        animateButtonHover(button, false)
    end)
    
    return button
end

-- Animation functions
function animateButtonHover(button, isHover)
    local targetColor = isHover and colors.surfaceLighter or colors.surface
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = targetColor})
    tween:Play()
end

function animateSelection(button, isSelected)
    local targetColor = isSelected and colors.surfaceLight or colors.surface
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = targetColor})
    tween:Play()
end

-- Page switching function
function switchPage(pageName, navButton)
    if currentPage == pageName then return end
    
    -- Update navigation
    for _, nav in ipairs(navButtons) do
        if nav.name == currentPage then
            animateSelection(nav.button, false)
            nav.button.TextColor3 = colors.textSecondary
            nav.button:FindFirstChild("Icon").TextColor3 = colors.textSecondary
        end
        
        if nav.name == pageName then
            animateSelection(nav.button, true)
            nav.button.TextColor3 = colors.textPrimary
            nav.button:FindFirstChild("Icon").TextColor3 = colors.textPrimary
            
            -- Animate selection indicator
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(selectionIndicator, tweenInfo, {Position = UDim2.new(1, -2, 0, nav.button.Position.Y.Offset)})
            tween:Play()
        end
    end
    
    -- Hide current page, show new page
    pages[currentPage].Visible = false
    pages[pageName].Visible = true
    
    currentPage = pageName
end

-- Window dragging functionality
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

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Close button functionality
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Close button hover effects
closeBtn.MouseEnter:Connect(function()
    animateButtonHover(closeBtn, true)
end)

closeBtn.MouseLeave:Connect(function()
    animateButtonHover(closeBtn, false)
end)

print("🎯 LightAI Controller loaded successfully!")
print("📱 Premium black & white design with smooth animations")
print("🖱️ Drag the title bar to move the window")
print("⚡ Use sidebar to navigate between sections")
