--[[  
    LightAI - GUI ONLY (no AI yet)
    Updated:
    - Only 3 tabs: AI Control, AI Output, GUI Appearance
    - Window made less wide + sidebar thinner
    - Centered better so it doesn't stick out on the right
    - Close "X" button made a bit larger / sharper
]]

-----------------------
-- CONFIG
-----------------------
local WINDOW_WIDTH = 600
local WINDOW_HEIGHT = 380
local SIDEBAR_WIDTH = 150
local PAGE_MARGIN = 10

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
mainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT)
mainFrame.Position = UDim2.new(0.5, -WINDOW_WIDTH/2, 0.5, -WINDOW_HEIGHT/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
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

-- Window controls
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

local function createWindowButton(name, textChar)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 22, 0, 22)
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 16      -- slightly larger/clearer
	btn.Text = textChar
	btn.Parent = controlsFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.4
	stroke.Thickness = 1
	stroke.Parent = btn

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
		Size = UDim2.new(0, WINDOW_WIDTH, 0, 40)
	}):Play()
end)

closeButton.MouseButton1Click:Connect(function()
	TweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
	task.wait(0.16)
	screenGui:Destroy()
end)

-----------------------
-- DRAGGING
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
-- SIDEBAR
-----------------------
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0)
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

-----------------------
-- PAGES CONTAINER
-----------------------
local pageContainer = Instance.new("Frame")
pageContainer.Name = "PageContainer"
pageContainer.Size = UDim2.new(1, -SIDEBAR_WIDTH - (PAGE_MARGIN * 2), 1, -20)
pageContainer.Position = UDim2.new(0, SIDEBAR_WIDTH + PAGE_MARGIN, 0, 10)
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

-----------------------
-- TABS / PAGES
-----------------------
local tabs = {
	"AI Control",
	"AI Output",
	"GUI Appearance",
}

local pages = {}
local tabButtons = {}

local function createPage(name)
	local page = Instance.new("Frame")
	page.Name = name .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = pageContainer
	pages[name] = page

	-- Simple heading for each page (rest will stay empty for now)
	local title = Instance.new("TextLabel")
	title.Name = "PageTitle"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 32)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = name
	title.Parent = page

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

-- Build tabs + pages
for _, name in ipairs(tabs) do
	local btn = createTabButton(name)
	createPage(name)

	btn.MouseButton1Click:Connect(function()
		setActiveTab(name)
	end)
end

-----------------------
-- DEFAULT ACTIVE TAB
-----------------------
setActiveTab("AI Control")

-- LightAI GUI ready (no AI logic yet)
