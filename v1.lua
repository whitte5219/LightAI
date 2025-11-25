--[[  
    LightAI - GUI ONLY (no AI yet)
    Single-file, black & white, Windows-like panel with:
    - Title bar + smooth dragging
    - Left tab sidebar
    - Main content area with "Combat" tab
    - Aura Cooldown slider
    - Warning panel
]]

-----------------------
-- SERVICES
-----------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-----------------------
-- ROOT GUI
-----------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightAI"
screenGui.ResetOnSpawn = false

-- Try to parent safely (exploit / plugin / normal)
local parentOk = false
pcall(function()
	if gethui then
		screenGui.Parent = gethui()
		parentOk = true
	end
end)
if not parentOk then
	if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
		screenGui.Parent = localPlayer:FindFirstChild("PlayerGui")
	else
		screenGui.Parent = game:GetService("CoreGui")
	end
end

-----------------------
-- MAIN WINDOW FRAME
-----------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 420)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- fully black
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Thickness = 1
mainStroke.Transparency = 0.8
mainStroke.Parent = mainFrame

local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, 0)
mainPadding.PaddingLeft = UDim.new(0, 0)
mainPadding.PaddingRight = UDim.new(0, 0)
mainPadding.PaddingBottom = UDim.new(0, 0)
mainPadding.Parent = mainFrame

-----------------------
-- TITLE BAR
-----------------------
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleBarBottom = Instance.new("Frame")
titleBarBottom.Name = "TitleBarBottom"
titleBarBottom.AnchorPoint = Vector2.new(0.5, 1)
titleBarBottom.Position = UDim2.new(0.5, 0, 1, 0)
titleBarBottom.Size = UDim2.new(1, -20, 0, 1)
titleBarBottom.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
titleBarBottom.BorderSizePixel = 0
titleBarBottom.BackgroundTransparency = 0.9
titleBarBottom.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "LightAI"
titleLabel.Parent = titleBar

-- Window controls (minimalistic, no emojis)
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "ControlsFrame"
controlsFrame.BackgroundTransparency = 1
controlsFrame.Size = UDim2.new(0, 80, 1, 0)
controlsFrame.Position = UDim2.new(1, -80, 0, 0)
controlsFrame.Parent = titleBar

local uiListControls = Instance.new("UIListLayout")
uiListControls.FillDirection = Enum.FillDirection.Horizontal
uiListControls.HorizontalAlignment = Enum.HorizontalAlignment.Right
uiListControls.VerticalAlignment = Enum.VerticalAlignment.Center
uiListControls.Padding = UDim.new(0, 8)
uiListControls.Parent = controlsFrame

local function createWindowButton(name, hint)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 20, 0, 20)
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 14
	btn.Text = hint
	btn.Parent = controlsFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.4
	stroke.Thickness = 1
	stroke.Parent = btn

	-- Hover animation
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		}):Play()
	end)

	return btn
end

local minimizeButton = createWindowButton("MinimizeButton", "-")
local closeButton = createWindowButton("CloseButton", "x")

minimizeButton.MouseButton1Click:Connect(function()
	TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 700, 0, 40)
	}):Play()
end)

closeButton.MouseButton1Click:Connect(function()
	TweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
	wait(0.16)
	screenGui:Destroy()
end)

-----------------------
-- DRAGGING (SMOOTHISH)
-----------------------
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	local goal = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)

	TweenService:Create(mainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = goal
	}):Play()
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or 
	   input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or 
	   input.UserInputType == Enum.UserInputType.Touch then
		if dragging then
			updateDrag(input)
		end
	end
end)

-----------------------
-- MAIN CONTENT AREA
-----------------------
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-----------------------
-- SIDEBAR TABS
-----------------------
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 180, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sidebar.BorderSizePixel = 0
sidebar.Parent = contentFrame

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = Color3.fromRGB(255, 255, 255)
sidebarStroke.Transparency = 0.85
sidebarStroke.Thickness = 1
sidebarStroke.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 16)
sidebarPadding.PaddingLeft = UDim.new(0, 10)
sidebarPadding.Parent = sidebar

local sidebarList = Instance.new("UIListLayout")
sidebarList.FillDirection = Enum.FillDirection.Vertical
sidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Left
sidebarList.VerticalAlignment = Enum.VerticalAlignment.Top
sidebarList.Padding = UDim.new(0, 6)
sidebarList.Parent = sidebar

local tabs = {
	"Home",
	"Combat",
	"Unlimited Slaps",
	"Anti Fling",
	"Anti Void",
	"Misc",
	"Players",
}

local pages = {}
local tabButtons = {}

local pageContainer = Instance.new("Frame")
pageContainer.Name = "PageContainer"
pageContainer.Size = UDim2.new(1, -180, 1, -20)
pageContainer.Position = UDim2.new(0, 190, 0, 10)
pageContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pageContainer.BorderSizePixel = 0
pageContainer.Parent = contentFrame

local pageCorner = Instance.new("UICorner")
pageCorner.CornerRadius = UDim.new(0, 12)
pageCorner.Parent = pageContainer

local pagePadding = Instance.new("UIPadding")
pagePadding.PaddingTop = UDim.new(0, 16)
pagePadding.PaddingLeft = UDim.new(0, 16)
pagePadding.PaddingRight = UDim.new(0, 16)
pagePadding.PaddingBottom = UDim.new(0, 16)
pagePadding.Parent = pageContainer

local function createPage(name)
	local page = Instance.new("Frame")
	page.Name = name .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = pageContainer
	pages[name] = page
	return page
end

local function createTabButton(name)
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Tab"
	btn.Size = UDim2.new(1, -20, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Text = "   " .. name
	btn.Parent = sidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 1
	stroke.Thickness = 1
	stroke.Parent = btn

	-- Hover animation
	btn.MouseEnter:Connect(function()
		if pages[name] and pages[name].Visible then return end
		TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		if pages[name] and pages[name].Visible then return end
		TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			TextColor3 = Color3.fromRGB(220, 220, 220)
		}):Play()
	end)

	tabButtons[name] = btn
	return btn
end

local function setActiveTab(name)
	for tabName, page in pairs(pages) do
		local isActive = (tabName == name)
		page.Visible = isActive

		local btn = tabButtons[tabName]
		if btn then
			if isActive then
				TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
				for _, child in ipairs(btn:GetChildren()) do
					if child:IsA("UIStroke") then
						child.Transparency = 0.4
					end
				end
			else
				TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					TextColor3 = Color3.fromRGB(220, 220, 220)
				}):Play()
				for _, child in ipairs(btn:GetChildren()) do
					if child:IsA("UIStroke") then
						child.Transparency = 1
					end
				end
			end
		end
	end
end

-- Create all tabs + empty pages
for _, name in ipairs(tabs) do
	local btn = createTabButton(name)
	local page = createPage(name)

	btn.MouseButton1Click:Connect(function()
		setActiveTab(name)
	end)

	-- Basic placeholder text for non-Combat pages
	if name ~= "Combat" then
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, 30)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamSemibold
		label.TextSize = 20
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = name
		label.Parent = page
	end
end

-----------------------
-- COMBAT PAGE CONTENT
-----------------------
local combatPage = pages["Combat"]

-- Title
local combatTitle = Instance.new("TextLabel")
combatTitle.Name = "CombatTitle"
combatTitle.BackgroundTransparency = 1
combatTitle.Size = UDim2.new(1, 0, 0, 32)
combatTitle.Font = Enum.Font.GothamBold
combatTitle.TextSize = 24
combatTitle.TextXAlignment = Enum.TextXAlignment.Left
combatTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
combatTitle.Text = "Combat"
combatTitle.Parent = combatPage

-----------------------
-- AURA COOLDOWN PANEL
-----------------------
local auraPanel = Instance.new("Frame")
auraPanel.Name = "AuraPanel"
auraPanel.Size = UDim2.new(1, 0, 0, 120)
auraPanel.Position = UDim2.new(0, 0, 0, 48)
auraPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
auraPanel.BorderSizePixel = 0
auraPanel.Parent = combatPage

local auraCorner = Instance.new("UICorner")
auraCorner.CornerRadius = UDim.new(0, 10)
auraCorner.Parent = auraPanel

local auraStroke = Instance.new("UIStroke")
auraStroke.Color = Color3.fromRGB(255, 255, 255)
auraStroke.Transparency = 0.8
auraStroke.Thickness = 1
auraStroke.Parent = auraPanel

local auraPadding = Instance.new("UIPadding")
auraPadding.PaddingTop = UDim.new(0, 10)
auraPadding.PaddingLeft = UDim.new(0, 12)
auraPadding.PaddingRight = UDim.new(0, 12)
auraPadding.Parent = auraPanel

local auraTitle = Instance.new("TextLabel")
auraTitle.BackgroundTransparency = 1
auraTitle.Size = UDim2.new(0.6, 0, 0, 24)
auraTitle.Font = Enum.Font.GothamSemibold
auraTitle.TextSize = 18
auraTitle.TextXAlignment = Enum.TextXAlignment.Left
auraTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
auraTitle.Text = "Aura Cooldown"
auraTitle.Parent = auraPanel

local auraDesc = Instance.new("TextLabel")
auraDesc.BackgroundTransparency = 1
auraDesc.Position = UDim2.new(0, 0, 0, 26)
auraDesc.Size = UDim2.new(1, 0, 0, 18)
auraDesc.Font = Enum.Font.Gotham
auraDesc.TextSize = 14
auraDesc.TextXAlignment = Enum.TextXAlignment.Left
auraDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
auraDesc.Text = "Adjust how quickly the aura can trigger between hits."
auraDesc.Parent = auraPanel

local auraValueLabel = Instance.new("TextLabel")
auraValueLabel.BackgroundTransparency = 1
auraValueLabel.AnchorPoint = Vector2.new(1, 0)
auraValueLabel.Position = UDim2.new(1, 0, 0, 0)
auraValueLabel.Size = UDim2.new(0, 80, 0, 24)
auraValueLabel.Font = Enum.Font.GothamBold
auraValueLabel.TextSize = 18
auraValueLabel.TextXAlignment = Enum.TextXAlignment.Right
auraValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
auraValueLabel.Text = "0.70"
auraValueLabel.Parent = auraPanel

-- Slider
local sliderFrame = Instance.new("Frame")
sliderFrame.Name = "SliderFrame"
sliderFrame.Size = UDim2.new(1, -10, 0, 30)
sliderFrame.Position = UDim2.new(0, 0, 0, 58)
sliderFrame.BackgroundTransparency = 1
sliderFrame.Parent = auraPanel

local sliderTrack = Instance.new("Frame")
sliderTrack.Name = "SliderTrack"
sliderTrack.AnchorPoint = Vector2.new(0.5, 0.5)
sliderTrack.Position = UDim2.new(0.5, 0, 0.5, 0)
sliderTrack.Size = UDim2.new(1, -40, 0, 4)
sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = sliderFrame

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = sliderTrack

local sliderKnob = Instance.new("ImageButton")
sliderKnob.Name = "SliderKnob"
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Size = UDim2.new(0, 18, 0, 18)
sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sliderKnob.BorderSizePixel = 0
sliderKnob.AutoButtonColor = false
sliderKnob.Image = ""
sliderKnob.Position = UDim2.new(0.7, 0, 0.5, 0) -- default position
sliderKnob.Parent = sliderTrack

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = sliderKnob

local knobStroke = Instance.new("UIStroke")
knobStroke.Color = Color3.fromRGB(255, 255, 255)
knobStroke.Thickness = 1
knobStroke.Transparency = 0.2
knobStroke.Parent = sliderKnob

local auraValue = 0.70
local sliderMin, sliderMax = 0.10, 2.00

local function setAuraValueFromAlpha(alpha)
	alpha = math.clamp(alpha, 0, 1)
	local value = sliderMin + (sliderMax - sliderMin) * alpha
	-- round to .01
	value = math.floor(value * 100 + 0.5) / 100
	auraValue = value
	auraValueLabel.Text = string.format("%.2f", value)

	TweenService:Create(sliderKnob, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(alpha, 0, 0.5, 0)
	}):Play()
end

local sliding = false

local function getAlphaFromInput(xPos)
	local absPos = sliderTrack.AbsolutePosition
	local absSize = sliderTrack.AbsoluteSize
	local rel = (xPos - absPos.X) / absSize.X
	return rel
end

sliderKnob.MouseButton1Down:Connect(function()
	sliding = true
end)

sliderTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliding = true
		setAuraValueFromAlpha(getAlphaFromInput(input.Position.X))
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not sliding then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		setAuraValueFromAlpha(getAlphaFromInput(input.Position.X))
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliding = false
	end
end)

-- Initial slider state
setAuraValueFromAlpha((auraValue - sliderMin) / (sliderMax - sliderMin))

-----------------------
-- WARNING PANEL
-----------------------
local warningPanel = Instance.new("Frame")
warningPanel.Name = "WarningPanel"
warningPanel.Size = UDim2.new(1, 0, 0, 110)
warningPanel.Position = UDim2.new(0, 0, 0, 180)
warningPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
warningPanel.BorderSizePixel = 0
warningPanel.Parent = combatPage

local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 10)
warningCorner.Parent = warningPanel

local warningStroke = Instance.new("UIStroke")
warningStroke.Color = Color3.fromRGB(255, 255, 255)
warningStroke.Transparency = 0.8
warningStroke.Thickness = 1
warningStroke.Parent = warningPanel

local warningPadding = Instance.new("UIPadding")
warningPadding.PaddingTop = UDim.new(0, 10)
warningPadding.PaddingLeft = UDim.new(0, 12)
warningPadding.PaddingRight = UDim.new(0, 12)
warningPadding.Parent = warningPanel

local warningTitle = Instance.new("TextLabel")
warningTitle.Name = "WarningTitle"
warningTitle.BackgroundTransparency = 1
warningTitle.Size = UDim2.new(1, 0, 0, 24)
warningTitle.Font = Enum.Font.GothamSemibold
warningTitle.TextSize = 18
warningTitle.TextXAlignment = Enum.TextXAlignment.Left
warningTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
warningTitle.Text = "Warning"
warningTitle.Parent = warningPanel

local warningText = Instance.new("TextLabel")
warningText.Name = "WarningText"
warningText.BackgroundTransparency = 1
warningText.Position = UDim2.new(0, 0, 0, 26)
warningText.Size = UDim2.new(1, 0, 1, -28)
warningText.Font = Enum.Font.Gotham
warningText.TextSize = 14
warningText.TextWrapped = true
warningText.TextXAlignment = Enum.TextXAlignment.Left
warningText.TextYAlignment = Enum.TextYAlignment.Top
warningText.TextColor3 = Color3.fromRGB(230, 230, 230)
warningText.Text = "HITTING MULTIPLE PLAYERS TOO QUICKLY CAN BE DETECTED AND MAY RESULT IN A KICK. USE AURA SETTINGS RESPONSIBLY."
warningText.Parent = warningPanel

-----------------------
-- DEFAULT ACTIVE TAB
-----------------------
setActiveTab("Combat")

-- Done: LightAI GUI only (no AI yet)
