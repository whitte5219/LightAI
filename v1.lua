--========================================================--
--                 L I G H T A I   V3.0 (Part 1)          --
--             FULL GUI SYSTEM + MEMORY + LEARNING        --
--========================================================--

-- PART 1 OF 5 — DO NOT RUN UNTIL ALL PARTS ARE MERGED --

-----------------------
-- SERVICES
-----------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer

-----------------------
-- GLOBALS (shared across parts)
-----------------------
ControlCharacterEnabled = false
SelfLearningEnabled = false
LightAI_Memory = {
    map = {},
    objects = {},
    stats = {},
    gameplay = {}
}
LIGHTAI_VERSION = "3.0"

-----------------------
-- GUI ROOT
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
    if localPlayer:FindFirstChild("PlayerGui") then
        screenGui.Parent = localPlayer.PlayerGui
    else
        screenGui.Parent = game:GetService("CoreGui")
    end
end

-----------------------
-- MAIN WINDOW
-----------------------
local WINDOW_WIDTH = 700
local WINDOW_HEIGHT = 480
local SIDEBAR_WIDTH = 160

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
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Thickness = 1
mainStroke.Transparency = 0.65
mainStroke.Parent = mainFrame

-----------------------
-- TITLE BAR
-----------------------
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 12)
tbCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(0, 200, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "LightAI v3.0"
titleLabel.Parent = titleBar

-----------------------
-- DRAGGING
-----------------------
local dragging = false
local dragStart
local startPos

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
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-----------------------
-- SIDEBAR
-----------------------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -42)
sidebar.Position = UDim2.new(0, 0, 0, 42)
sidebar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 12)
sbCorner.Parent = sidebar

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 6)
sidebarLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 14)
sidebarPadding.PaddingLeft = UDim.new(0, 10)
sidebarPadding.Parent = sidebar

-----------------------
-- PAGE CONTAINER
-----------------------
local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, -SIDEBAR_WIDTH - 20, 1, -62)
pageContainer.Position = UDim2.new(0, SIDEBAR_WIDTH + 10, 0, 52)
pageContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
pageContainer.BorderSizePixel = 0
pageContainer.Parent = mainFrame

local pcCorner = Instance.new("UICorner")
pcCorner.CornerRadius = UDim.new(0, 14)
pcCorner.Parent = pageContainer

local pcPadding = Instance.new("UIPadding")
pcPadding.PaddingTop = UDim.new(0, 12)
pcPadding.PaddingLeft = UDim.new(0, 12)
pcPadding.PaddingRight = UDim.new(0, 12)
pcPadding.PaddingBottom = UDim.new(0, 12)
pcPadding.Parent = pageContainer

-----------------------
-- PAGES
-----------------------
local pages = {}
local tabButtons = {}

local tabNames = {
    "AI Control",
    "AI Output",
    "GUI Appearance",
    "Info",
    "Memory"
}

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
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = name
    title.Parent = p
end

for _, name in ipairs(tabNames) do
    createPage(name)
end

-----------------------
-- TAB BUTTONS
-----------------------
local function createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BorderSizePixel = 0
    btn.Text = "   " .. name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.AutoButtonColor = false
    btn.Parent = sidebar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = btn

    tabButtons[name] = btn
end

for _, name in ipairs(tabNames) do
    createTabButton(name)
end

-----------------------
-- TAB SWITCHING
-----------------------
local function activateTab(name)
    for tab, page in pairs(pages) do
        page.Visible = (tab == name)
        local btn = tabButtons[tab]
        if btn then
            if tab == name then
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end
end

for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        activateTab(name)
    end)
end

activateTab("AI Output") -- default page

-----------------------
-- MEMORY PAGE UI
-----------------------
local memoryPage = pages["Memory"]

local memoryList = Instance.new("ScrollingFrame")
memoryList.Size = UDim2.new(1, -10, 1, -40)
memoryList.Position = UDim2.new(0, 5, 0, 35)
memoryList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
memoryList.BorderSizePixel = 0
memoryList.ScrollBarThickness = 6
memoryList.Parent = memoryPage

local memCorner = Instance.new("UICorner")
memCorner.CornerRadius = UDim.new(0, 10)
memCorner.Parent = memoryList

local memoryLayout = Instance.new("UIListLayout")
memoryLayout.Parent = memoryList
memoryLayout.Padding = UDim.new(0, 6)

-----------------------
-- PLACEHOLDERS FOR PART 2–5
-----------------------
AIOutput_LogFrame = nil
AIOutput_InputBox = nil
AIOutput_SendButton = nil
AIOutput_ActionLabel = nil
AIOutput_StopButton = nil
AICtrl_SelfLearnButton = nil
AICtrl_ModeButtons = {}

--========================================================--
-- END OF PART 1 / 5
--========================================================--
--========================================================--
--                 L I G H T A I   V3.0 (Part 2)          --
--                     ACTION SYSTEM                       --
--========================================================--

-- PART 2 OF 5 — MOVEMENT + ACTIONS + UNTIL_STOP --

local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-----------------------------------------------------------
-- ACTION STATE
-----------------------------------------------------------
local currentAction = nil
local actionRunning = false
local stopRequested = false
SavedPosition = nil -- globally visible

-----------------------------------------------------------
-- HELPERS FOR PART 2
-----------------------------------------------------------
local function keyDown(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
end

local function keyUp(key)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function releaseKeys()
    keyUp(Enum.KeyCode.W)
    keyUp(Enum.KeyCode.A)
    keyUp(Enum.KeyCode.S)
    keyUp(Enum.KeyCode.D)
end

local function lookDelta(dx, dy)
    local cam = workspace.CurrentCamera
    if not cam then return end
    cam.CFrame = cam.CFrame * CFrame.Angles(0, -dx * 0.002, 0)
end

local function mouseClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    RunService.Heartbeat:Wait()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-----------------------------------------------------------
-- PLAYER + POSITION HELPERS
-----------------------------------------------------------
local function getRoot()
    local char = Players.LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getNearestPlayer()
    local myRoot = getRoot()
    if not myRoot then return nil end

    local closest, dist = nil, math.huge
    local myPos = myRoot.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos = plr.Character.HumanoidRootPart.Position
            local d = (myPos - pos).Magnitude
            if d < dist then
                closest = plr
                dist = d
            end
        end
    end
    return closest
end

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

-----------------------------------------------------------
-- CAMERA-RELATIVE WASD WALKING ENGINE
-----------------------------------------------------------
local function walkToPosition(targetPos, reachDist)
    reachDist = reachDist or 2
    local root = getRoot()
    if not root then return end

    releaseKeys()
    local startTime = tick()

    while not stopRequested do
        root = getRoot()
        if not root then break end

        local diff = targetPos - root.Position
        if diff.Magnitude <= reachDist then break end

        local cam = workspace.CurrentCamera
        local forward = (cam.CFrame.LookVector * Vector3.new(1,0,1)).Unit
        local right   = (cam.CFrame.RightVector * Vector3.new(1,0,1)).Unit
        local dir = diff.Unit

        local fDot = dir:Dot(forward)
        local rDot = dir:Dot(right)

        releaseKeys()

        if fDot > 0.2 then keyDown(Enum.KeyCode.W)
        elseif fDot < -0.2 then keyDown(Enum.KeyCode.S) end

        if rDot > 0.2 then keyDown(Enum.KeyCode.D)
        elseif rDot < -0.2 then keyDown(Enum.KeyCode.A) end

        RunService.Heartbeat:Wait()
    end

    releaseKeys()
end

local function walkToPlayer(plr)
    if not plr or not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if root then walkToPosition(root.Position, 3) end
end

local function randomWalk(seconds)
    seconds = tonumber(seconds) or 4
    local root = getRoot()
    if not root then return end

    releaseKeys()

    local angle = math.random() * math.pi * 2
    local dir = Vector3.new(math.cos(angle),0,math.sin(angle))

    local start = tick()
    while tick() - start < seconds and not stopRequested do
        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.new(cam.CFrame.Position, root.Position + dir * 20)

        releaseKeys()
        keyDown(Enum.KeyCode.W)
        RunService.Heartbeat:Wait()
    end

    releaseKeys()
end

-----------------------------------------------------------
-- UNTIL_STOP: NEW ACTION TYPE
-----------------------------------------------------------
local function doUntilStop(action)
    local dir = (action.direction or ""):lower()

    releaseKeys()

    if dir == "forward" then keyDown(Enum.KeyCode.W)
    elseif dir == "back" then keyDown(Enum.KeyCode.S)
    elseif dir == "left" then keyDown(Enum.KeyCode.A)
    elseif dir == "right" then keyDown(Enum.KeyCode.D)
    end

    -- Loop until stopRequested toggles ON
    while not stopRequested do
        RunService.Heartbeat:Wait()
    end

    releaseKeys()
end

-----------------------------------------------------------
-- MAIN ACTION EXECUTOR
-----------------------------------------------------------
function executeActions(actionList)
    if type(actionList) ~= "table" then
        actionRunning = false
        return
    end

    actionRunning = true
    stopRequested = false

    for _, action in ipairs(actionList) do
        if stopRequested then break end

        currentAction = action.type or "UNKNOWN"
        if AIOutput_ActionLabel then
            AIOutput_ActionLabel.Text = "Action: " .. currentAction
        end

        ---------------------------------------------------
        -- ACTION HANDLING
        ---------------------------------------------------
        if action.type == "MOVE" then
            local t = tonumber(action.time) or 0.3
            local d = (action.direction or ""):lower()

            if d == "forward" then keyDown(Enum.KeyCode.W)
            elseif d == "back" then keyDown(Enum.KeyCode.S)
            elseif d == "left" then keyDown(Enum.KeyCode.A)
            elseif d == "right" then keyDown(Enum.KeyCode.D)
            end

            local start = tick()
            while tick() - start < t and not stopRequested do
                RunService.Heartbeat:Wait()
            end
            releaseKeys()

        elseif action.type == "WAIT" then
            local t = tonumber(action.time) or 1
            local start = tick()
            while tick() - start < t and not stopRequested do
                RunService.Heartbeat:Wait()
            end

        elseif action.type == "JUMP" then
            keyDown(Enum.KeyCode.Space)
            RunService.Heartbeat:Wait()
            keyUp(Enum.KeyCode.Space)

        elseif action.type == "CLICK" then
            mouseClick()

        elseif action.type == "LOOK" then
            lookDelta(action.x or 0, action.y or 0)

        elseif action.type == "SAVE_POSITION" then
            local root = getRoot()
            if root then
                SavedPosition = root.Position
            end

        elseif action.type == "WALK_TO" then
            local mode = (action.mode or "nearest"):lower()

            if mode == "nearest" then
                local p = getNearestPlayer()
                walkToPlayer(p)

            elseif mode == "object" then
                local obj = findObjectByName(action.objectName)
                if obj then walkToPosition(obj.Position) end

            elseif mode == "saved" then
                if SavedPosition then walkToPosition(SavedPosition) end

            elseif mode == "random_baseplate" then
                local bp = workspace:FindFirstChild("Baseplate")
                if bp then
                    local rx = math.random(-bp.Size.X/2, bp.Size.X/2)
                    local rz = math.random(-bp.Size.Z/2, bp.Size.Z/2)
                    walkToPosition(bp.Position + Vector3.new(rx,0,rz))
                end

            elseif mode == "random_radius" then
                local root = getRoot()
                if root then
                    local radius = tonumber(action.radius) or 10
                    local angle = math.random() * math.pi * 2
                    local r = radius * math.sqrt(math.random())
                    local target = root.Position + Vector3.new(math.cos(angle)*r, 0, math.sin(angle)*r)
                    walkToPosition(target)
                end
            end

        ---------------------------------------------------
        -- NEW ACTION: UNTIL_STOP
        ---------------------------------------------------
        elseif action.type == "UNTIL_STOP" then
            doUntilStop(action)

        ---------------------------------------------------
        -- RANDOM WALK EXTENSION
        ---------------------------------------------------
        elseif action.type == "RANDOM_WALK" then
            randomWalk(action.duration or 4)

        end
    end

    releaseKeys()
    actionRunning = false
    if AIOutput_ActionLabel then
        AIOutput_ActionLabel.Text = "Action: Idle"
    end
end

-----------------------------------------------------------
-- STOP BUTTON CONNECTION (used in Part 1)
-----------------------------------------------------------
-- This is linked in Part 1 but logic lives here:
function LightAI_StopCurrentAction()
    stopRequested = true
end

--========================================================--
-- END OF PART 2 / 5
--========================================================--
--========================================================--
--                 L I G H T A I   V3.0 (Part 3)          --
--          MEMORY SYSTEM + SCANNING ENGINE               --
--========================================================--

-- PART 3 OF 5 — MEMORY + MAP SCANNER + STATS --

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-----------------------------------------------------------
-- MEMORY DATABASE (FULL INTERNAL STRUCTURE)
-----------------------------------------------------------
LightAI_Memory = {
    map = {
        scannedObjects = {},     -- { [name] = { size, pos, anchored, canCollide } }
        areas = {},              -- discovered areas/regions
        pointsOfInterest = {},   -- special objects (doors, buttons, etc.)
        visitedPositions = {},   -- path memory
        lastScanTime = 0,
    },

    players = {
        seen = {},               -- { [playerName] = { firstSeen, lastSeen, healthHistory = {} } }
    },

    stats = {
        distanceWalked = 0,
        jumps = 0,
        clicks = 0,
        actionsExecuted = 0,
        startTime = tick(),
    },

    gameplay = {
        events = {},             -- "Player died", "Teleported", etc.
        interactions = {},       -- { objectName = count }
    }
}

-----------------------------------------------------------
-- UTILITY FUNCTIONS
-----------------------------------------------------------
local function vecToString(v)
    return string.format("(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z)
end

local function storeEvent(text)
    table.insert(LightAI_Memory.gameplay.events, 1, os.date("[%H:%M:%S] ") .. text)
    if #LightAI_Memory.gameplay.events > 40 then
        table.remove(LightAI_Memory.gameplay.events)
    end
end

-----------------------------------------------------------
-- MAP SCANNING ENGINE
-----------------------------------------------------------
local SCAN_INTERVAL = 1.0   -- seconds between scans
local MAX_OBJECTS = 200     -- safety limit

local function scanMap()
    local now = tick()
    local mem = LightAI_Memory.map

    -- throttle scanning
    if now - mem.lastScanTime < SCAN_INTERVAL then
        return
    end
    mem.lastScanTime = now

    local count = 0

    for _, obj in ipairs(workspace:GetDescendants()) do
        if count >= MAX_OBJECTS then break end
        if obj:IsA("BasePart") then
            count += 1
            local info = {
                position = obj.Position,
                size = obj.Size,
                anchored = obj.Anchored,
                canCollide = obj.CanCollide
            }

            mem.scannedObjects[obj.Name] = info

            -- detect POIs
            if obj.Name:lower():find("door") or obj.Name:lower():find("button") then
                mem.pointsOfInterest[obj.Name] = info
            end
        end
    end
end

-----------------------------------------------------------
-- PLAYER SCANNING ENGINE
-----------------------------------------------------------
local function scanPlayers()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos = plr.Character.HumanoidRootPart.Position
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")

            if not LightAI_Memory.players.seen[plr.Name] then
                LightAI_Memory.players.seen[plr.Name] = {
                    firstSeen = tick(),
                    lastSeen = tick(),
                    healthHistory = {}
                }
                storeEvent("First saw player: " .. plr.Name)
            else
                LightAI_Memory.players.seen[plr.Name].lastSeen = tick()
            end

            local hp = hum and hum.Health or 0
            local record = LightAI_Memory.players.seen[plr.Name]
            table.insert(record.healthHistory, hp)
            if #record.healthHistory > 50 then
                table.remove(record.healthHistory, 1)
            end
        end
    end
end

-----------------------------------------------------------
-- STATS TRACKING
-----------------------------------------------------------
local lastRootPos = nil
RunService.Heartbeat:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- distance walked
    if lastRootPos then
        LightAI_Memory.stats.distanceWalked += (root.Position - lastRootPos).Magnitude
    end
    lastRootPos = root.Position
end)

function LightAI_RecordJump()
    LightAI_Memory.stats.jumps += 1
end

function LightAI_RecordClick()
    LightAI_Memory.stats.clicks += 1
end

function LightAI_RecordAction()
    LightAI_Memory.stats.actionsExecuted += 1
end

-----------------------------------------------------------
-- VISITED POSITIONS (PATH MEMORY)
-----------------------------------------------------------
local function recordVisited()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    table.insert(LightAI_Memory.map.visitedPositions, root.Position)
    if #LightAI_Memory.map.visitedPositions > 200 then
        table.remove(LightAI_Memory.map.visitedPositions, 1)
    end
end

-----------------------------------------------------------
-- MEMORY PAGE UPDATER
-----------------------------------------------------------
local function safeText(str)
    return (str:gsub("[^%w%s%p]", "?"))
end

function LightAI_RefreshMemoryUI(scrollFrame)
    if not scrollFrame then return end
    scrollFrame:ClearAllChildren()

    local function addLine(text)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        lbl.TextSize = 14
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.TextWrapped = true
        lbl.Text = text
        lbl.Parent = scrollFrame
    end

    -------------------------------------------------------
    -- MAP SECTION
    -------------------------------------------------------
    addLine("=== MAP OBJECTS ===")
    for name, info in pairs(LightAI_Memory.map.scannedObjects) do
        addLine(name .. " | pos=" .. vecToString(info.position) .. " size=" .. vecToString(info.size))
    end

    addLine("")
    addLine("=== POINTS OF INTEREST ===")
    for name, info in pairs(LightAI_Memory.map.pointsOfInterest) do
        addLine("[POI] " .. name .. " at " .. vecToString(info.position))
    end

    addLine("")
    addLine("Visited positions: " .. tostring(#LightAI_Memory.map.visitedPositions))

    -------------------------------------------------------
    -- PLAYERS SECTION
    -------------------------------------------------------
    addLine("")
    addLine("=== PLAYERS SEEN ===")
    for name, data in pairs(LightAI_Memory.players.seen) do
        addLine(name .. " (health samples: " .. #data.healthHistory .. ")")
    end

    -------------------------------------------------------
    -- STATS SECTION
    -------------------------------------------------------
    addLine("")
    addLine("=== STATS ===")
    addLine("Distance walked: " .. math.floor(LightAI_Memory.stats.distanceWalked) .. " studs")
    addLine("Jumps: " .. LightAI_Memory.stats.jumps)
    addLine("Clicks: " .. LightAI_Memory.stats.clicks)
    addLine("Actions executed: " .. LightAI_Memory.stats.actionsExecuted)

    -------------------------------------------------------
    -- EVENTS
    -------------------------------------------------------
    addLine("")
    addLine("=== RECENT EVENTS ===")
    for _, e in ipairs(LightAI_Memory.gameplay.events) do
        addLine(e)
    end
end

-----------------------------------------------------------
-- SCANNING LOOP (used in Self-Learning mode)
-----------------------------------------------------------
spawn(function()
    while true do
        if SelfLearningEnabled then
            scanMap()
            scanPlayers()
            recordVisited()
        end
        task.wait(0.2)
    end
end)

--========================================================--
-- END OF PART 3 / 5
--========================================================--
--========================================================--
--                 L I G H T A I   V3.0 (Part 4)          --
--         SELF-LEARNING MODE + AUTONOMOUS ENGINE         --
--========================================================--

-- PART 4 OF 5 — SELF-LEARNING CORE --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-----------------------------------------------------------
-- SELF LEARNING STATE
-----------------------------------------------------------
SelfLearningEnabled = false
local selfLearningThread = nil
local selfLearningRunning = false

-----------------------------------------------------------
-- UI HOOKS (defined in Part 1)
-----------------------------------------------------------
local aiControlPage = pages["AI Control"]
local aiOutputPage = pages["AI Output"]
local memoryPage = pages["Memory"]

-----------------------------------------------------------
-- CREATE SELF-LEARNING UI
-----------------------------------------------------------
-- AI Control Page: Self-Learning toggle
AICtrl_SelfLearnButton = Instance.new("TextButton")
AICtrl_SelfLearnButton.Size = UDim2.new(0, 160, 0, 32)
AICtrl_SelfLearnButton.Position = UDim2.new(0, 10, 0, 60)
AICtrl_SelfLearnButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AICtrl_SelfLearnButton.Text = "[ Self-Learning: OFF ]"
AICtrl_SelfLearnButton.Font = Enum.Font.GothamBold
AICtrl_SelfLearnButton.TextSize = 14
AICtrl_SelfLearnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AICtrl_SelfLearnButton.Parent = aiControlPage

local slCorner = Instance.new("UICorner")
slCorner.CornerRadius = UDim.new(0, 8)
slCorner.Parent = AICtrl_SelfLearnButton

-- AI Output Page: Start/Stop Learning
AIOutput_LearnButton = Instance.new("TextButton")
AIOutput_LearnButton.Size = UDim2.new(0, 160, 0, 32)
AIOutput_LearnButton.Position = UDim2.new(0, 10, 0, 70)
AIOutput_LearnButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AIOutput_LearnButton.Text = "Start Learning"
AIOutput_LearnButton.Font = Enum.Font.GothamBold
AIOutput_LearnButton.TextSize = 14
AIOutput_LearnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AIOutput_LearnButton.Parent = aiOutputPage

local sl2Corner = Instance.new("UICorner")
sl2Corner.CornerRadius = UDim.new(0, 8)
sl2Corner.Parent = AIOutput_LearnButton

-----------------------------------------------------------
-- LEARNING EVENT LOGGING
-----------------------------------------------------------
local function learnLog(msg)
    storeEvent("LEARN: " .. msg)
    if AIOutput_LogFrame then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 18)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Color3.fromRGB(170, 200, 255)
        label.Text = "[LEARN] " .. msg
        label.Parent = AIOutput_LogFrame
    end
end

-----------------------------------------------------------
-- BASIC LOW-LEVEL AUTONOMOUS MOVEMENTS
-----------------------------------------------------------
local function autoMoveRandom()
    local dirs = { "forward", "left", "right", "back" }
    local d = dirs[math.random(1, #dirs)]
    local time = math.random(1, 3)

    learnLog("Exploring: moving " .. d .. " for " .. time .. "s")

    executeActions({
        { type = "MOVE", direction = d, time = time }
    })
end

local function autoRandomTurn()
    local dx = math.random(-100, 100)
    local dy = math.random(-30, 30)
    learnLog("Turning camera slightly")
    executeActions({
        { type = "LOOK", x = dx, y = dy }
    })
end

local function autoWalkToPOI()
    local poiList = LightAI_Memory.map.pointsOfInterest
    local names = {}

    for n,_ in pairs(poiList) do
        table.insert(names, n)
    end

    if #names == 0 then return false end

    local pick = names[math.random(1, #names)]
    local pos = poiList[pick].position

    learnLog("Walking to POI: ".. pick)

    executeActions({
        { type = "WALK_TO", mode = "object", objectName = pick }
    })

    return true
end

local function autoWalkToNearestPlayer()
    local plr = getNearestPlayer()
    if not plr then return end

    learnLog("Walking to nearest player: ".. plr.Name)

    executeActions({
        { type = "WALK_TO", mode = "nearest" }
    })
end

-----------------------------------------------------------
-- DECISION ENGINE
-----------------------------------------------------------
local function pickLearningAction()
    -- PRIORITY: objects -> players -> explore -> random move

    -- 1. Explore points of interest
    if autoWalkToPOI() then
        return
    end

    -- 2. Approach nearest player
    if math.random() < 0.35 then
        autoWalkToNearestPlayer()
        return
    end

    -- 3. Random exploring
    if math.random() < 0.5 then
        autoMoveRandom()
    end

    if math.random() < 0.4 then
        autoRandomTurn()
    end
end

-----------------------------------------------------------
-- SELF LEARNING MAIN LOOP
-----------------------------------------------------------
local function startLearningLoop()
    if selfLearningRunning then return end
    selfLearningRunning = true

    learnLog("Self-learning loop started.")

    while SelfLearningEnabled do
        -- automatic scanning in Part 3 already active
        LightAI_RefreshMemoryUI(memoryPage:FindFirstChildOfClass("ScrollingFrame"))

        pickLearningAction()

        RunService.Heartbeat:Wait()
        task.wait(math.random(0.5, 1.7))
    end

    learnLog("Self-learning loop stopped.")
    selfLearningRunning = false
end

-----------------------------------------------------------
-- TOGGLE SELF LEARNING
-----------------------------------------------------------
local function updateSelfLearnUI()
    if SelfLearningEnabled then
        AICtrl_SelfLearnButton.Text = "[ Self-Learning: ON ]"
        AICtrl_SelfLearnButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
        AIOutput_LearnButton.Text = "Stop Learning"
        AIOutput_LearnButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    else
        AICtrl_SelfLearnButton.Text = "[ Self-Learning: OFF ]"
        AICtrl_SelfLearnButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        AIOutput_LearnButton.Text = "Start Learning"
        AIOutput_LearnButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end

AICtrl_SelfLearnButton.MouseButton1Click:Connect(function()
    SelfLearningEnabled = not SelfLearningEnabled
    updateSelfLearnUI()

    if SelfLearningEnabled then
        spawn(startLearningLoop)
    end
end)

AIOutput_LearnButton.MouseButton1Click:Connect(function()
    SelfLearningEnabled = not SelfLearningEnabled
    updateSelfLearnUI()

    if SelfLearningEnabled then
        spawn(startLearningLoop)
    end
end)

updateSelfLearnUI()

--========================================================--
-- END OF PART 4 / 5
--========================================================--
--========================================================--
--                 L I G H T A I   V3.0 (Part 5)          --
--              AI API + COMMAND ENGINE + FINAL           --
--========================================================--

-- PART 5 OF 5 — FINAL SECTION OF LIGHTAI v3 --

local HttpService = game:GetService("HttpService")

-----------------------------------------------------------
-- HTTP REQUEST WRAPPER (Executor Compatible)
-----------------------------------------------------------
local function httpRequest(tbl)
    if syn and syn.request then return syn.request(tbl) end
    if http and http.request then return http.request(tbl) end
    if request then return request(tbl) end

    if game:GetService("HttpService").RequestAsync then
        return game:GetService("HttpService"):RequestAsync(tbl)
    end

    return nil
end

-----------------------------------------------------------
-- UPDATED CONTROL INSTRUCTIONS for AI
-----------------------------------------------------------
local CONTROL_INSTRUCTIONS = [[
You control the Roblox player's character.

You MUST output **ONLY a JSON object** shaped like:
{"actions":[ ... ]}

Never add any explanation, text, markdown, or comments outside the JSON.

ALLOWED ACTIONS:
MOVE:
  {"type":"MOVE","direction":"forward|back|left|right","time":0.1-2.0}

JUMP:
  {"type":"JUMP"}

WAIT:
  {"type":"WAIT","time":seconds}

CLICK:
  {"type":"CLICK"}

LOOK:
  {"type":"LOOK","x":pixels,"y":pixels}

WALK_TO:
  {
    "type":"WALK_TO",
    "mode":"nearest|random|furthest|object|saved|random_baseplate|random_radius|random_radius_player",
    "objectName":"optional",
    "radius":number,
    "playerName":"optional"
  }

WALK_TO_NEAREST:
  {"type":"WALK_TO_NEAREST"}

SAVE_POSITION:
  {"type":"SAVE_POSITION"}

RANDOM_WALK:
  {"type":"RANDOM_WALK","duration":seconds}

UNTIL_STOP:
  {
    "type":"UNTIL_STOP",
    "direction":"forward|back|left|right"
  }

WHILE:
  {
    "type":"WHILE",
    "duration":seconds,
    "actions":[ ... ]
  }

RULES:
- Your reply **must be valid JSON**.
- NO trailing commas.
- NO comments.
- NO text outside the JSON.
- Always consider GAME_INFO_JSON to understand the world.
]]

-----------------------------------------------------------
-- CHAT INSTRUCTIONS
-----------------------------------------------------------
local CHAT_INSTRUCTIONS = [[
You are LightAI, a friendly Roblox assistant.
Keep messages short, casual, helpful.
Do NOT output JSON in chat mode.
Do NOT control the player unless user enables Control Mode.
]]

-----------------------------------------------------------
-- AI OUTPUT LOGGING (hooking GUI from Part 1)
-----------------------------------------------------------

-- Create log frame in AI Output page
do
    local outputPage = pages["AI Output"]

    AIOutput_LogFrame = Instance.new("ScrollingFrame")
    AIOutput_LogFrame.Size = UDim2.new(1, -20, 1, -150)
    AIOutput_LogFrame.Position = UDim2.new(0, 10, 0, 100)
    AIOutput_LogFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    AIOutput_LogFrame.ScrollBarThickness = 6
    AIOutput_LogFrame.Parent = outputPage

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = AIOutput_LogFrame

    local l = Instance.new("UIListLayout")
    l.Parent = AIOutput_LogFrame
    l.Padding = UDim.new(0, 4)

    -- Action Label
    AIOutput_ActionLabel = Instance.new("TextLabel")
    AIOutput_ActionLabel.Size = UDim2.new(0, 300, 0, 22)
    AIOutput_ActionLabel.Position = UDim2.new(0, 10, 0, 72)
    AIOutput_ActionLabel.BackgroundTransparency = 1
    AIOutput_ActionLabel.Font = Enum.Font.GothamBold
    AIOutput_ActionLabel.TextXAlignment = Enum.TextXAlignment.Left
    AIOutput_ActionLabel.TextSize = 15
    AIOutput_ActionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    AIOutput_ActionLabel.Text = "Action: Idle"
    AIOutput_ActionLabel.Parent = outputPage

    -- STOP ACTION BUTTON
    AIOutput_StopButton = Instance.new("TextButton")
    AIOutput_StopButton.Size = UDim2.new(0, 110, 0, 28)
    AIOutput_StopButton.Position = UDim2.new(1, -120, 0, 70)
    AIOutput_StopButton.BackgroundColor3 = Color3.fromRGB(130, 20, 20)
    AIOutput_StopButton.Text = "Stop Action"
    AIOutput_StopButton.TextSize = 14
    AIOutput_StopButton.Font = Enum.Font.GothamBold
    AIOutput_StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AIOutput_StopButton.Parent = outputPage

    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 8)
    c2.Parent = AIOutput_StopButton

    AIOutput_StopButton.MouseButton1Click:Connect(function()
        LightAI_StopCurrentAction()
        if AIOutput_LogFrame then
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -10, 0, 18)
            l.BackgroundTransparency = 1
            l.Font = Enum.Font.Gotham
            l.TextSize = 13
            l.TextColor3 = Color3.fromRGB(255, 150, 150)
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text = "[SYSTEM] Action interrupted by user"
            l.Parent = AIOutput_LogFrame
        end
    end)
end

-----------------------------------------------------------
-- OUTPUT LOG (helper)
-----------------------------------------------------------
local function logMessage(role, text)
    if not AIOutput_LogFrame then return end

    local color =
        role == "user" and Color3.fromRGB(80,120,255) or
        role == "ai" and Color3.fromRGB(150,90,255) or
        Color3.fromRGB(200,200,200)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(1, -10, 0, 18)
    label.TextSize = 14
    label.TextColor3 = color
    label.Text = (role == "system" and "[SYSTEM] " or role == "user" and "[YOU] " or "[AI] ") .. text
    label.Parent = AIOutput_LogFrame
end

-----------------------------------------------------------
-- BUILD GAME INFO FOR AI (connect to Part 3 memory)
-----------------------------------------------------------
local function buildGameInfo()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    local info = {
        self = {
            name = LocalPlayer.Name,
            health = hum and hum.Health or 0,
            position = root and {x=root.Position.X,y=root.Position.Y,z=root.Position.Z}
        },
        memory = LightAI_Memory
    }

    return info
end

-----------------------------------------------------------
-- CALL AI (CHAT OR CONTROL MODE)
-----------------------------------------------------------
function CallLightAI(userText)
    if not userText or userText == "" then return end

    logMessage("user", userText)

    if SelfLearningEnabled then
        logMessage("system", "Cannot send messages in Self-Learning mode.")
        return
    end

    local gameInfoJson = HttpService:JSONEncode(buildGameInfo())

    local payload = {
        model = "command-a-vision-07-2025",
        preamble = ControlCharacterEnabled and CONTROL_INSTRUCTIONS or CHAT_INSTRUCTIONS,
        message = userText .. "\n\nGAME_INFO_JSON:\n" .. gameInfoJson,
        chat_history = {},
        max_tokens = 800,
        temperature = ControlCharacterEnabled and 0.1 or 0.4,
        stream = false
    }

    local response = httpRequest({
        Url = "https://api.cohere.ai/v1/chat",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. tostring(getgenv().LIGHTAI_KEY)
        },
        Body = HttpService:JSONEncode(payload)
    })

    if not response then
        logMessage("system", "No response from API.")
        return
    end

    if response.StatusCode ~= 200 then
        logMessage("system", "API error: " .. tostring(response.StatusCode))
        return
    end

    local decoded
    pcall(function()
        decoded = HttpService:JSONDecode(response.Body)
    end)

    if not decoded then
        logMessage("system", "Invalid JSON from API.")
        return
    end

    local text = decoded.text or decoded.reply or ""
    if text == "" then
        logMessage("system", "Empty AI response.")
        return
    end

    logMessage("ai", text)

    -- control mode: parse JSON
    if ControlCharacterEnabled then
        local ok, parsed = pcall(function()
            return HttpService:JSONDecode(text)
        end)

        if ok and parsed and type(parsed.actions) == "table" then
            executeActions(parsed.actions)
        else
            logMessage("system", "AI did not output valid JSON actions.")
        end
    end
end

-----------------------------------------------------------
-- CONNECT CHAT INPUT (from Part 1)
-----------------------------------------------------------
do
    local outputPage = pages["AI Output"]

    AIOutput_InputBox = Instance.new("TextBox")
    AIOutput_InputBox.Size = UDim2.new(1, -140, 0, 32)
    AIOutput_InputBox.Position = UDim2.new(0, 10, 1, -40)
    AIOutput_InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    AIOutput_InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    AIOutput_InputBox.PlaceholderText = "Type message..."
    AIOutput_InputBox.Font = Enum.Font.Gotham
    AIOutput_InputBox.TextSize = 14
    AIOutput_InputBox.ClearTextOnFocus = false
    AIOutput_InputBox.Parent = outputPage

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = AIOutput_InputBox

    AIOutput_SendButton = Instance.new("TextButton")
    AIOutput_SendButton.Size = UDim2.new(0, 120, 0, 32)
    AIOutput_SendButton.Position = UDim2.new(1, -130, 1, -40)
    AIOutput_SendButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    AIOutput_SendButton.Font = Enum.Font.GothamBold
    AIOutput_SendButton.Text = "Send"
    AIOutput_SendButton.TextColor3 = Color3.fromRGB(255,255,255)
    AIOutput_SendButton.TextSize = 14
    AIOutput_SendButton.Parent = outputPage

    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 8)
    c2.Parent = AIOutput_SendButton

    AIOutput_SendButton.MouseButton1Click:Connect(function()
        local msg = AIOutput_InputBox.Text
        AIOutput_InputBox.Text = ""
        CallLightAI(msg)
    end)
end

-----------------------------------------------------------
-- CONTROL MODE BUTTON  
-----------------------------------------------------------
do
    local outputPage = pages["AI Output"]

    local controlButton = Instance.new("TextButton")
    controlButton.Size = UDim2.new(0, 160, 0, 32)
    controlButton.Position = UDim2.new(0, 10, 0, 30)
    controlButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    controlButton.Font = Enum.Font.GothamBold
    controlButton.Text = "Control Mode: OFF"
    controlButton.TextSize = 14
    controlButton.TextColor3 = Color3.fromRGB(255,255,255)
    controlButton.Parent = outputPage

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = controlButton

    controlButton.MouseButton1Click:Connect(function()
        ControlCharacterEnabled = not ControlCharacterEnabled
        if ControlCharacterEnabled then
            controlButton.Text = "Control Mode: ON"
            controlButton.BackgroundColor3 = Color3.fromRGB(80,120,255)
        else
            controlButton.Text = "Control Mode: OFF"
            controlButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
        end
    end)
end

-----------------------------------------------------------
-- FINAL STARTUP MESSAGE
-----------------------------------------------------------
logMessage("system", "LightAI v3 successfully loaded.")
logMessage("system", "Parts 1–5 merged. System ready.")

--========================================================--
-- END OF PART 5 / 5 — SCRIPT COMPLETE
--========================================================--
