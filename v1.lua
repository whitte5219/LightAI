--========================================================--
--                 L I G H T A I   V2.2                   --
--              FULL GUI + VISUAL OVERHAUL                --
--========================================================--

--[[
    PART 1 / 3  (GUI SYSTEM + VISUALS)
    DO NOT EXECUTE UNTIL ALL PARTS ARE MERGED.
]]

-----------------------
-- CONFIG
-----------------------
local WINDOW_WIDTH = 650
local WINDOW_HEIGHT = 430
local SIDEBAR_WIDTH = 150
local PAGE_MARGIN = 10

-----------------------
-- SERVICES
-----------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

-----------------------
-- GLOBAL STATE
-----------------------
local ControlCharacterEnabled = false
local actionRunning = false
local stopRequested = false
local SavedPosition = nil

-----------------------
-- GUI HIGHLIGHT COLORS
-----------------------
local COLOR_USER = Color3.fromRGB(80, 120, 255)      -- blue-ish
local COLOR_AI   = Color3.fromRGB(150, 90, 255)      -- purple-ish
local COLOR_SYS  = Color3.fromRGB(180, 180, 180)     -- gray-ish

local COLOR_TAB_ACTIVE   = Color3.fromRGB(45, 45, 45)
local COLOR_TAB_INACTIVE = Color3.fromRGB(15, 15, 15)

-----------------------
-- SCREEN GUI
-----------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightAI"
screenGui.ResetOnSpawn = false

pcall(function()
    if gethui then
        screenGui.Parent = gethui()
    end
end)

if not screenGui.Parent then
    if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
        screenGui.Parent = localPlayer.PlayerGui
    else
        screenGui.Parent = game:GetService("CoreGui")
    end
end

-----------------------
-- MAIN FRAME
-----------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT)
mainFrame.Position = UDim2.new(0.5, -WINDOW_WIDTH/2, 0.5, -WINDOW_HEIGHT/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Thickness = 1
mainStroke.Transparency = 0.75
mainStroke.Parent = mainFrame

-----------------------
-- TITLE BAR
-----------------------
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 12)
tbCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "LightAI"
titleLabel.Parent = titleBar

-----------------------
-- MINIMIZE / CLOSE BUTTONS
-----------------------
local function createTitleButton(txt)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 26, 0, 26)
    b.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.AutoButtonColor = false
    b.BorderSizePixel = 0

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Transparency = 0.75
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Parent = b

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        }):Play()
    end)

    return b
end

local closeButton = createTitleButton("×")
closeButton.Position = UDim2.new(1, -36, 0.5, -13)
closeButton.Parent = titleBar

local minimizeButton = createTitleButton("–")
minimizeButton.Position = UDim2.new(1, -68, 0.5, -13)
minimizeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame, TweenInfo.new(0.15), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.15)
    screenGui:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame, TweenInfo.new(0.2), {
        Size = UDim2.new(0, WINDOW_WIDTH, 0, 42)
    }):Play()
end)

-----------------------
-- DRAGGING WINDOW
-----------------------
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-----------------------
-- MAIN CONTENT AREA
-----------------------
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -42)
contentFrame.Position = UDim2.new(0, 0, 0, 42)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-----------------------
-- SIDEBAR
-----------------------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
sidebar.BorderSizePixel = 0
sidebar.Parent = contentFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 14)
sidebarCorner.Parent = sidebar

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Thickness = 1
sidebarStroke.Transparency = 0.85
sidebarStroke.Color = Color3.fromRGB(255, 255, 255)
sidebarStroke.Parent = sidebar

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 20)
sidebarPadding.PaddingLeft = UDim.new(0, 10)
sidebarPadding.Parent = sidebar

-----------------------
-- PAGE CONTAINER
-----------------------
local pageContainer = Instance.new("Frame")
pageContainer.Name = "PageContainer"
pageContainer.Size = UDim2.new(
    1, -SIDEBAR_WIDTH - PAGE_MARGIN*2,
    1, -PAGE_MARGIN*2
)
pageContainer.Position = UDim2.new(
    0, SIDEBAR_WIDTH + PAGE_MARGIN,
    0, PAGE_MARGIN
)
pageContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pageContainer.BorderSizePixel = 0
pageContainer.Parent = contentFrame

local pageCorner = Instance.new("UICorner")
pageCorner.CornerRadius = UDim.new(0, 14)
pageCorner.Parent = pageContainer

local pageStroke = Instance.new("UIStroke")
pageStroke.Color = Color3.fromRGB(255, 255, 255)
pageStroke.Transparency = 0.85
pageStroke.Thickness = 1
pageStroke.Parent = pageContainer

local pagePadding = Instance.new("UIPadding")
pagePadding.PaddingTop = UDim.new(0, 16)
pagePadding.PaddingLeft = UDim.new(0, 16)
pagePadding.PaddingRight = UDim.new(0, 16)
pagePadding.PaddingBottom = UDim.new(0, 16)
pagePadding.Parent = pageContainer

-----------------------
-- TABS
-----------------------
local tabs = { "AI Control", "AI Output", "GUI Appearance", "Info" }
local pages = {}
local tabButtons = {}

local function createPage(name)
    local p = Instance.new("Frame")
    p.Name = name .. "Page"
    p.BackgroundTransparency = 1
    p.Size = UDim2.new(1, 0, 1, 0)
    p.Visible = false
    p.Parent = pageContainer
    pages[name] = p

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 28)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Text = name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = p

    return p
end

local function createTabButton(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 32)
    b.BackgroundColor3 = COLOR_TAB_INACTIVE
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = 15
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Text = "   " .. name
    b.AutoButtonColor = false
    b.Parent = sidebar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 1
    s.Thickness = 1
    s.Parent = b

    b.MouseEnter:Connect(function()
        if pages[name].Visible then return end
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)

    b.MouseLeave:Connect(function()
        if pages[name].Visible then return end
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = COLOR_TAB_INACTIVE,
            TextColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
    end)

    tabButtons[name] = b
end

local function setActiveTab(name)
    for tab, pg in pairs(pages) do
        local btn = tabButtons[tab]
        local active = (tab == name)

        pg.Visible = active

        if btn then
            if active then
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = COLOR_TAB_ACTIVE,
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()

                for _, ch in ipairs(btn:GetChildren()) do
                    if ch:IsA("UIStroke") then
                        ch.Transparency = 0.4
                    end
                end
            else
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = COLOR_TAB_INACTIVE,
                    TextColor3 = Color3.fromRGB(200, 200, 200)
                }):Play()

                for _, ch in ipairs(btn:GetChildren()) do
                    if ch:IsA("UIStroke") then
                        ch.Transparency = 1
                    end
                end
            end
        end
    end
end

-- Create tabs + pages
for _, name in ipairs(tabs) do
    createTabButton(name)
    createPage(name)
end

--========================================================--
-- PART 1 ENDS HERE — WAIT FOR PART 2
--========================================================--
--========================================================--
--                 L I G H T A I   V2.2                   --
--              MOVEMENT + ACTION SYSTEM                  --
--========================================================--

--[[
    PART 2 / 3
    DO NOT EXECUTE UNTIL ALL PARTS ARE MERGED.
    Continues from PART 1.
]]

-----------------------
-- REFERENCES FROM PART 1
-----------------------
local outputFrame
local outputListLayout
local currentActionLabel
local stopActionButton
local chatBox
local sendButton
local COLOR_USER = Color3.fromRGB(80, 120, 255)
local COLOR_AI   = Color3.fromRGB(150, 90, 255)
local COLOR_SYS  = Color3.fromRGB(180, 180, 180)

-----------------------
-- MORE SERVICES
-----------------------
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-----------------------
-- HISTORY + LOGGING
-----------------------
local AI = {
    History = {},
    MaxHistory = 20,
    Mode = "Advanced"
}

local function addToHistory(role, text)
    table.insert(AI.History, { role = role, text = text })
    if #AI.History > AI.MaxHistory then
        table.remove(AI.History, 1)
    end
end

local function messageBubble(role, text)
    if not outputFrame then return end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 =
        role == "user" and COLOR_USER
        or role == "ai" and COLOR_AI
        or COLOR_SYS
    frame.BackgroundTransparency = 0.15
    frame.Size = UDim2.new(1, -10, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.ClipsDescendants = true
    frame.Parent = outputFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = frame

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Text = text
    label.Parent = frame

    task.wait()
    outputFrame.CanvasSize = UDim2.new(0, 0, 0, outputListLayout.AbsoluteContentSize.Y + 15)
    outputFrame.CanvasPosition = Vector2.new(0, math.max(0, outputFrame.CanvasSize.Y.Offset))
end

local function Log(role, text)
    addToHistory(role, text)
    messageBubble(role, text)
end

-----------------------
-- ACTION MULTISTATE
-----------------------
local actionRunning = false
local stopRequested = false

local function setCurrentAction(text)
    if currentActionLabel then
        currentActionLabel.Text = "Action: " .. text
    end
end

local function clearCurrentAction()
    actionRunning = false
    stopRequested = false
    setCurrentAction("Idle")
end

stopActionButton.MouseButton1Click:Connect(function()
    if not actionRunning then return end
    stopRequested = true
    Log("system", "Stopping current action...")
end)

-----------------------
-- PLAYER + CAMERA HELPERS
-----------------------
local function pressKeyDown(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
end

local function pressKeyUp(key)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function pressKey(key, time)
    pressKeyDown(key)
    local start = tick()
    while tick() - start < (time or 0.3) do
        if stopRequested then break end
        RunService.Heartbeat:Wait()
    end
    pressKeyUp(key)
end

local function pressMouse(duration)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    local t0 = tick()
    while tick() - t0 < (duration or 0.1) do
        if stopRequested then break end
        RunService.Heartbeat:Wait()
    end
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function releaseMovementKeys()
    pressKeyUp(Enum.KeyCode.W)
    pressKeyUp(Enum.KeyCode.A)
    pressKeyUp(Enum.KeyCode.S)
    pressKeyUp(Enum.KeyCode.D)
end

local function lookAt(dx, dy)
    local cam = workspace.CurrentCamera
    if not cam then return end
    cam.CFrame = cam.CFrame * CFrame.Angles(0, -dx * 0.002, 0)
end

-----------------------
-- PLAYER SEARCHERS
-----------------------
local function getNearestPlayer()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local myPos = root.Position
    local nearest, dist = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local p = plr.Character.HumanoidRootPart.Position
            local d = (myPos - p).Magnitude
            if d < dist then
                dist = d
                nearest = plr
            end
        end
    end
    return nearest
end

local function getRandomPlayer()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, plr)
        end
    end
    if #list == 0 then return nil end
    return list[math.random(1, #list)]
end

local function getFurthestPlayer()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local myPos = root.Position
    local furthest, dist = nil, 0

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local p = plr.Character.HumanoidRootPart.Position
            local d = (myPos - p).Magnitude
            if d > dist then
                dist = d
                furthest = plr
            end
        end
    end
    return furthest
end

local function findPlayerByName(partial)
    if not partial then return nil end
    partial = partial:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Name:lower():find(partial, 1, true) then
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                return plr
            end
        end
    end
    return nil
end

-----------------------
-- MAP INFO / OBJECTS
-----------------------
local function findObjectByName(partial)
    if not partial then return nil end
    partial = partial:lower()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(partial, 1, true) then
            return obj
        end
    end
    return nil
end

local function getBaseplate()
    local bp = workspace:FindFirstChild("Baseplate")
    if bp and bp:IsA("BasePart") then return bp end

    local best, area = nil, 0
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and o.Anchored then
            local a = o.Size.X * o.Size.Z
            if a > area then
                area = a
                best = o
            end
        end
    end
    return best
end

local function randomPointWithin(center, radius)
    local r = radius * math.sqrt(math.random())
    local t = math.random() * math.pi * 2
    return center + Vector3.new(math.cos(t)*r, 0, math.sin(t)*r)
end

-----------------------
-- WALKING SYSTEMS
-----------------------
local function walkToPosition(targetPos, maxTime, reachDist)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root then return end

    reachDist = reachDist or 2

    -- auto-determine time if needed
    if not maxTime then
        maxTime = (targetPos - root.Position).Magnitude / (hum and hum.WalkSpeed or 16) + 6
    end

    local t0 = tick()
    releaseMovementKeys()

    while tick() - t0 < maxTime do
        if stopRequested then break end
        if not root.Parent then break end

        local pos = root.Position
        local diff = targetPos - pos

        if diff.Magnitude <= reachDist then
            break
        end

        -- camera-relative walking
        local cam = workspace.CurrentCamera
        local forward = cam.CFrame.LookVector * Vector3.new(1,0,1)
        local right = cam.CFrame.RightVector * Vector3.new(1,0,1)

        if forward.Magnitude > 0 then forward = forward.Unit end
        if right.Magnitude > 0 then right = right.Unit end

        local dir = diff.Unit
        local fDot = dir:Dot(forward)
        local rDot = dir:Dot(right)

        releaseMovementKeys()

        if fDot > 0.2 then pressKeyDown(Enum.KeyCode.W)
        elseif fDot < -0.2 then pressKeyDown(Enum.KeyCode.S) end

        if rDot > 0.2 then pressKeyDown(Enum.KeyCode.D)
        elseif rDot < -0.2 then pressKeyDown(Enum.KeyCode.A) end

        RunService.Heartbeat:Wait()
    end

    releaseMovementKeys()
end

local function walkToPlayer(plr)
    if not plr or not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    walkToPosition(root.Position, 30, 3)
end

local function randomWalk(duration)
    duration = tonumber(duration) or 5
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local angle = math.random()*math.pi*2
    local dir = Vector3.new(math.cos(angle),0,math.sin(angle))
    local t0 = tick()
    releaseMovementKeys()

    while tick() - t0 < duration do
        if stopRequested then break end

        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.new(cam.CFrame.Position, root.Position + dir * 20)

        releaseMovementKeys()
        pressKeyDown(Enum.KeyCode.W)
        RunService.Heartbeat:Wait()
    end

    releaseMovementKeys()
end

-----------------------
-- ACTION DESCRIBER
-----------------------
local function describeAction(a)
    if not a or type(a) ~= "table" then return "Idle" end
    local t = a.type

    if t == "MOVE" then
        return "walking " .. tostring(a.direction)
    elseif t == "JUMP" then
        return "jumping"
    elseif t == "WAIT" then
        return "waiting"
    elseif t == "CLICK" then
        return "clicking"
    elseif t == "LOOK" then
        return "looking"
    elseif t == "WALK_TO_NEAREST" then
        return "walking to nearest player"
    elseif t == "WALK_TO" then
        return "walking to " .. tostring(a.mode)
    elseif t == "SAVE_POSITION" then
        return "saving position"
    elseif t == "RANDOM_WALK" then
        return "random walk"
    elseif t == "WHILE" then
        return "parallel-block"
    end
    return "unknown"
end

-----------------------
-- WALK MODE DISPATCH
-----------------------
local function walkToMode(action)
    local mode = (action.mode or "nearest"):lower()

    if mode == "nearest" then
        local p = getNearestPlayer()
        if p then walkToPlayer(p) end

    elseif mode == "random" then
        local p = getRandomPlayer()
        if p then walkToPlayer(p) end

    elseif mode == "furthest" then
        local p = getFurthestPlayer()
        if p then walkToPlayer(p) end

    elseif mode == "object" then
        local obj = findObjectByName(action.objectName)
        if obj then walkToPosition(obj.Position) end

    elseif mode == "saved" then
        if SavedPosition then walkToPosition(SavedPosition) end

    elseif mode == "random_baseplate" then
        local bp = getBaseplate()
        if bp then
            local rx = math.random(-bp.Size.X/2, bp.Size.X/2)
            local rz = math.random(-bp.Size.Z/2, bp.Size.Z/2)
            walkToPosition(bp.Position + Vector3.new(rx,0,rz))
        end

    elseif mode == "random_radius" then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local pos = randomPointWithin(root.Position, tonumber(action.radius) or 10)
            walkToPosition(pos)
        end

    elseif mode == "random_radius_player" then
        local p = findPlayerByName(action.playerName)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local center = p.Character.HumanoidRootPart.Position
            local pos = randomPointWithin(center, tonumber(action.radius) or 10)
            walkToPosition(pos)
        end
    end
end

-----------------------
-- WHILE BLOCK EXECUTOR
-----------------------
local function executeWhileAction(duration, acts)
    duration = tonumber(duration) or 1
    local t0 = tick()

    local move = {forward=false,back=false,left=false,right=false}
    for _, a in ipairs(acts or {}) do
        if a.type == "MOVE" then
            move[(a.direction or ""):lower()] = true
        end
    end

    if move.forward then pressKeyDown(Enum.KeyCode.W) end
    if move.back    then pressKeyDown(Enum.KeyCode.S) end
    if move.left    then pressKeyDown(Enum.KeyCode.A) end
    if move.right   then pressKeyDown(Enum.KeyCode.D) end

    local lastJump = 0
    while tick() - t0 < duration do
        if stopRequested then break end

        for _, a in ipairs(acts or {}) do
            if a.type == "JUMP" and tick() - lastJump > 0.8 then
                pressKey(Enum.KeyCode.Space, 0.1)
                lastJump = tick()
            end
        end

        RunService.Heartbeat:Wait()
    end

    releaseMovementKeys()
end

-----------------------
-- MAIN ACTION EXECUTOR
-----------------------
function executeActions(actions)
    if type(actions) ~= "table" then
        clearCurrentAction()
        return
    end

    actionRunning = true
    stopRequested = false

    for _, a in ipairs(actions) do
        if stopRequested then break end

        setCurrentAction(describeAction(a))

        local t = a.type

        if t == "MOVE" then
            local dir = (a.direction or ""):lower()
            local time = tonumber(a.time) or 0.4
            if dir == "forward" then pressKey(Enum.KeyCode.W, time)
            elseif dir == "back" then pressKey(Enum.KeyCode.S, time)
            elseif dir == "left" then pressKey(Enum.KeyCode.A, time)
            elseif dir == "right" then pressKey(Enum.KeyCode.D, time)
            end

        elseif t == "JUMP" then
            pressKey(Enum.KeyCode.Space, 0.1)

        elseif t == "WAIT" then
            local dur = tonumber(a.time) or 0.5
            local t0 = tick()
            while tick() - t0 < dur do
                if stopRequested then break end
                RunService.Heartbeat:Wait()
            end

        elseif t == "CLICK" then
            pressMouse(0.1)

        elseif t == "LOOK" then
            lookAt(a.x, a.y)

        elseif t == "WALK_TO_NEAREST" then
            local p = getNearestPlayer()
            if p then walkToPlayer(p) end

        elseif t == "WALK_TO" then
            walkToMode(a)

        elseif t == "SAVE_POSITION" then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                SavedPosition = root.Position
            end

        elseif t == "RANDOM_WALK" then
            randomWalk(a.duration)

        elseif t == "WHILE" then
            executeWhileAction(a.duration, a.actions)
        end
    end

    releaseMovementKeys()
    clearCurrentAction()
end

-----------------------
-- BUILD GAME STATE FOR AI
-----------------------
local function buildGameInfo()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    local info = {
        self = {
            name = player.Name,
            health = hum and hum.Health or 0,
            maxHealth = hum and hum.MaxHealth or 0,
            position = root and {x=root.Position.X,y=root.Position.Y,z=root.Position.Z} or nil,
        },
        nearbyPlayers = {},
        nearestPlayer = nil,
        map = {
            obstacles = {},
        }
    }

    -- nearest player
    local nearest = getNearestPlayer()
    if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
        local r = nearest.Character.HumanoidRootPart.Position
        local nh = nearest.Character:FindFirstChildOfClass("Humanoid")

        info.nearestPlayer = {
            name = nearest.Name,
            health = nh and nh.Health or 0,
            distance = root and (root.Position - r).Magnitude or nil,
            position = {x=r.X,y=r.Y,z=r.Z}
        }
    end

    -- all players
    if root then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local r = plr.Character.HumanoidRootPart.Position
                local h = plr.Character:FindFirstChildOfClass("Humanoid")
                table.insert(info.nearbyPlayers, {
                    name = plr.Name,
                    distance = (root.Position - r).Magnitude,
                    health = h and h.Health or 0,
                    position = {x=r.X,y=r.Y,z=r.Z}
                })
            end
        end
    end

    -- obstacles
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CanCollide and obj.Size.Magnitude > 3 then
            table.insert(info.map.obstacles, {
                name = obj.Name,
                position = {x=obj.Position.X,y=obj.Position.Y,z=obj.Position.Z},
                size = {x=obj.Size.X,y=obj.Size.Y,z=obj.Size.Z}
            })
            count += 1
            if count >= 40 then break end
        end
    end

    return info
end

--========================================================--
-- PART 2 ENDS HERE — WAIT FOR PART 3
--========================================================--
--========================================================--
--                 L I G H T A I   V2.2                   --
--                AI SYSTEM + FINAL ASSEMBLY              --
--========================================================--

--[[
    PART 3 / 3
    Combine Parts 1 + 2 + 3 in order into ONE script.
]]

-----------------------
-- COHERE API CONFIG
-----------------------
local COHERE_ENDPOINT = "https://api.cohere.ai/v1/chat"
local COHERE_MODEL = "command-a-vision-07-2025"

-----------------------
-- HTTP REQUEST WRAPPER
-----------------------
local function doRequest(req)
    if syn and syn.request then
        return syn.request(req)
    elseif http and http.request then
        return http.request(req)
    elseif request then
        return request(req)
    elseif game:GetService("HttpService").RequestAsync then
        return game:GetService("HttpService"):RequestAsync(req)
    else
        return nil
    end
end

-----------------------
-- CONTROL INSTRUCTIONS
-----------------------
local CONTROL_INSTRUCTIONS = [[
You control the player's Roblox character.

You MUST output ONLY a single JSON object and NOTHING ELSE.
No explanations, no extra text.

Format:
{"actions":[ ... ]}

Allowed Actions:
MOVE: {"type":"MOVE","direction":"forward|back|left|right","time":0.1–2.0}
JUMP: {"type":"JUMP"}
WAIT: {"type":"WAIT","time":seconds}
CLICK: {"type":"CLICK"}
LOOK: {"type":"LOOK","x":pixels,"y":pixels}
WALK_TO: {
  "type":"WALK_TO",
  "mode":"nearest|random|furthest|object|saved|random_baseplate|random_radius|random_radius_player",
  "objectName":"optional",
  "radius":number,
  "playerName":"optional"
}
WALK_TO_NEAREST: {"type":"WALK_TO_NEAREST"}
SAVE_POSITION: {"type":"SAVE_POSITION"}
RANDOM_WALK: {"type":"RANDOM_WALK","duration":seconds}
WHILE: {"type":"WHILE","duration":seconds,"actions":[ ... ]}

Rules:
- Never invent new action types or fields.
- Use GAME_INFO_JSON to choose targets.
- If the user is unclear, choose the simplest safe interpretation.
- "walk in a random direction for X seconds" → RANDOM_WALK
- "walk to random position" → WALK_TO random_baseplate
- "within N studs" → random_radius
- For "random around PLAYER" → random_radius_player

Your entire reply MUST be:
{"actions":[ ... ]}
]]

-----------------------
-- CHAT INSTRUCTIONS
-----------------------
local CHAT_INSTRUCTIONS = [[
You are LightAI, a friendly conversational assistant inside Roblox.
Keep responses short, casual, helpful. Do NOT output JSON in chat mode.
]]

-----------------------
-- AI REQUEST BUILDER
-----------------------
function CallLightAI(userText)
    if not userText or userText == "" then return end

    Log("user", userText)

    local gameInfo = buildGameInfo()
    local gameInfoJson = HttpService:JSONEncode(gameInfo)

    local preamble = ControlCharacterEnabled and CONTROL_INSTRUCTIONS or CHAT_INSTRUCTIONS

    local payload = {
        model = COHERE_MODEL,
        preamble = preamble,
        message = "MODE: " .. (ControlCharacterEnabled and "CONTROL" or "CHAT")
            .. "\nUSER_REQUEST:\n" .. userText
            .. "\n\nGAME_INFO_JSON:\n" .. gameInfoJson,
        chat_history = AI.History,
        temperature = ControlCharacterEnabled and 0.1 or 0.4,
        stream = false
    }

    local json = HttpService:JSONEncode(payload)

    local resp = doRequest({
        Url = COHERE_ENDPOINT,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. tostring(getgenv().LIGHTAI_KEY)
        },
        Body = json
    })

    if not resp then
        Log("system", "HTTP request failed.")
        return
    end

    if resp.StatusCode ~= 200 then
        Log("system", "API returned status " .. tostring(resp.StatusCode))
        return
    end

    local decoded = nil
    pcall(function()
        decoded = HttpService:JSONDecode(resp.Body)
    end)

    if not decoded then
        Log("system", "Failed to decode API response.")
        return
    end

    local reply = decoded.text or decoded.reply or ""
    if reply == "" then
        Log("system", "Empty AI response.")
        return
    end

    -- logging AI text
    Log("ai", reply)

    -- If control mode → parse JSON
    if ControlCharacterEnabled then
        local ok, parsed = pcall(function()
            return HttpService:JSONDecode(reply)
        end)

        if not ok or type(parsed) ~= "table" or type(parsed.actions) ~= "table" then
            Log("system", "Invalid JSON from AI.")
            return
        end

        executeActions(parsed.actions)
    end
end

-----------------------
-- GUI CONNECTION (From Part 1)
-----------------------
-- We rebuild references now that GUI exists:

local pageContainer = screenGui.MainFrame.ContentFrame.PageContainer

local aiControlPage = pageContainer["AI ControlPage"]
local aiOutputPage = pageContainer["AI OutputPage"]
local guiAppearancePage = pageContainer["GUI AppearancePage"]
local infoPage = pageContainer["InfoPage"]

-----------------------
-- AI CONTROL PAGE UI
-----------------------
local modeLabel = Instance.new("TextLabel")
modeLabel.BackgroundTransparency = 1
modeLabel.Size = UDim2.new(1, -20, 0, 20)
modeLabel.Position = UDim2.new(0, 0, 0, 40)
modeLabel.Text = "Mode:"
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextSize = 16
modeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
modeLabel.Parent = aiControlPage

local advancedButton = Instance.new("TextButton")
advancedButton.Size = UDim2.new(0, 100, 0, 28)
advancedButton.Position = UDim2.new(0, 0, 0, 70)
advancedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
advancedButton.Text = "Advanced"
advancedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
advancedButton.Font = Enum.Font.Gotham
advancedButton.TextSize = 14
advancedButton.Parent = aiControlPage

local advCorner = Instance.new("UICorner")
advCorner.CornerRadius = UDim.new(0, 8)
advCorner.Parent = advancedButton

local quickButton = Instance.new("TextButton")
quickButton.Size = UDim2.new(0, 100, 0, 28)
quickButton.Position = UDim2.new(0, 110, 0, 70)
quickButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
quickButton.Text = "Quick"
quickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
quickButton.Font = Enum.Font.Gotham
quickButton.TextSize = 14
quickButton.Parent = aiControlPage

local quickCorner = Instance.new("UICorner")
quickCorner.CornerRadius = UDim.new(0, 8)
quickCorner.Parent = quickButton

advancedButton.MouseButton1Click:Connect(function()
    AI.Mode = "Advanced"
    Log("system", "AI mode set to Advanced.")
end)
quickButton.MouseButton1Click:Connect(function()
    AI.Mode = "Quick"
    Log("system", "AI mode set to Quick.")
end)

-----------------------
-- AI OUTPUT PAGE UI
-----------------------
outputFrame = Instance.new("ScrollingFrame")
outputFrame.Size = UDim2.new(1, -20, 1, -120)
outputFrame.Position = UDim2.new(0, 10, 0, 10)
outputFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
outputFrame.BorderSizePixel = 0
outputFrame.ScrollBarThickness = 6
outputFrame.Parent = aiOutputPage

local ofCorner = Instance.new("UICorner")
ofCorner.CornerRadius = UDim.new(0, 12)
ofCorner.Parent = outputFrame

outputListLayout = Instance.new("UIListLayout")
outputListLayout.SortOrder = Enum.SortOrder.LayoutOrder
outputListLayout.Padding = UDim.new(0, 6)
outputListLayout.Parent = outputFrame

-----------------------
-- ACTION LABEL + STOP BUTTON
-----------------------
currentActionLabel = Instance.new("TextLabel")
currentActionLabel.BackgroundTransparency = 1
currentActionLabel.Size = UDim2.new(1, -20, 0, 24)
currentActionLabel.Position = UDim2.new(0, 10, 0, outputFrame.AbsoluteSize.Y + 20)
currentActionLabel.Text = "Action: Idle"
currentActionLabel.Font = Enum.Font.GothamBold
currentActionLabel.TextSize = 16
currentActionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
currentActionLabel.TextXAlignment = Enum.TextXAlignment.Left
currentActionLabel.Parent = aiOutputPage

stopActionButton = Instance.new("TextButton")
stopActionButton.Size = UDim2.new(0, 100, 0, 26)
stopActionButton.Position = UDim2.new(1, -110, 0, outputFrame.AbsoluteSize.Y + 20)
stopActionButton.BackgroundColor3 = Color3.fromRGB(70, 20, 20)
stopActionButton.Text = "Stop Action"
stopActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopActionButton.Font = Enum.Font.GothamBold
stopActionButton.TextSize = 14
stopActionButton.Parent = aiOutputPage

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopActionButton

-----------------------
-- CHAT INPUT + SEND BUTTON
-----------------------
chatBox = Instance.new("TextBox")
chatBox.Size = UDim2.new(1, -120, 0, 32)
chatBox.Position = UDim2.new(0, 10, 1, -40)
chatBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
chatBox.TextColor3 = Color3.fromRGB(255, 255, 255)
chatBox.PlaceholderText = "Type a message..."
chatBox.Font = Enum.Font.Gotham
chatBox.TextSize = 14
chatBox.ClearTextOnFocus = false
chatBox.Parent = aiOutputPage

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 10)
cbCorner.Parent = chatBox

sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(0, 90, 0, 32)
sendButton.Position = UDim2.new(1, -100, 1, -40)
sendButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
sendButton.Text = "Send"
sendButton.Font = Enum.Font.GothamBold
sendButton.TextSize = 14
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.Parent = aiOutputPage

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 10)
sbCorner.Parent = sendButton

sendButton.MouseButton1Click:Connect(function()
    local t = chatBox.Text
    if t ~= "" then
        CallLightAI(t)
        chatBox.Text = ""
    end
end)

-----------------------
-- CONTROL CHARACTER TOGGLE
-----------------------
local controlButton = Instance.new("TextButton")
controlButton.Size = UDim2.new(0, 150, 0, 32)
controlButton.Position = UDim2.new(0, 10, 0, 48)
controlButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
controlButton.Font = Enum.Font.GothamBold
controlButton.TextSize = 14
controlButton.Text = "Control Character: OFF"
controlButton.TextColor3 = Color3.fromRGB(255, 255, 255)
controlButton.Parent = aiOutputPage

local ccCorner = Instance.new("UICorner")
ccCorner.CornerRadius = UDim.new(0, 10)
ccCorner.Parent = controlButton

controlButton.MouseButton1Click:Connect(function()
    ControlCharacterEnabled = not ControlCharacterEnabled
    if ControlCharacterEnabled then
        controlButton.Text = "Control Character: ON"
        controlButton.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    else
        controlButton.Text = "Control Character: OFF"
        controlButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

-----------------------
-- INFO PAGE
-----------------------
local infoText = Instance.new("TextLabel")
infoText.BackgroundTransparency = 1
infoText.Size = UDim2.new(1, -20, 1, -20)
infoText.Position = UDim2.new(0, 10, 0, 10)
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 15
infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Text = [[
LightAI Information:

• Two modes:
   - Chat Mode: Normal conversation
   - Control Mode: Executes actions in JSON

• Supported Actions:
   MOVE, JUMP, WAIT, CLICK, LOOK
   WALK_TO, WALK_TO_NEAREST, RANDOM_WALK, SAVE_POSITION
   WHILE (parallel-style block)

• Uses GAME INFO (players, obstacles, positions)
  to understand what is around you.

• Type messages normally. Example:
  "walk to nearest player"
  "jump twice"
  "walk in a random direction for 5 seconds"

• All movement is simulated via input keys (WASD).
]]
infoText.Parent = infoPage

-----------------------
-- FINAL: DEFAULT TAB
-----------------------
local sidebar = screenGui.MainFrame.ContentFrame.Sidebar
local tabButtons = {}
for _, child in ipairs(sidebar:GetChildren()) do
    if child:IsA("TextButton") then
        tabButtons[child.Text:sub(4)] = child
    end
end

local function setActiveTab(name)
    for pageName, page in pairs(pageContainer:GetChildren()) do
        if page:IsA("Frame") then
            page.Visible = (page.Name == name .. "Page")
        end
    end
end

-- apply tab switching
for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        setActiveTab(name)
    end)
end

setActiveTab("AI Output")  -- default

--========================================================--
--                L I G H T A I   L O A D E D             --
--========================================================--
Log("system", "LightAI Loaded Successfully!")
