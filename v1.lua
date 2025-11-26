--[[
    LightAI - GUI + Chat + Character Control (Cohere)

    - Cohere API key is read from getgenv().LIGHTAI_KEY
    - No secrets are stored in the script
]]

-----------------------
-- CONFIG
-----------------------
local WINDOW_WIDTH = 650
local WINDOW_HEIGHT = 420
local SIDEBAR_WIDTH = 150
local PAGE_MARGIN = 10

-----------------------
-- SERVICES
-----------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-----------------------
-- AI CORE (CHAT + HISTORY)
-----------------------
local CHAT_INSTRUCTIONS = "You are LightAI, a friendly assistant inside a Roblox GUI. Speak casually, like a normal player. You must still follow safety rules and refuse anything harmful or NSFW, but for normal questions answer directly and naturally."

local CONTROL_INSTRUCTIONS = [[You control the player's Roblox character.

You MUST output ONLY a single JSON object and NOTHING ELSE.
No explanations, no extra text, no code blocks.

You will ALWAYS receive GAME INFO in JSON after the user message.
Use that GAME INFO to decide what actions to output (for example, use distances, health, players, and obstacles).

ALLOWED ACTION TYPES:

MOVE:
  {"type":"MOVE","direction":"forward|back|left|right","time":0.1–2.0}

JUMP:
  {"type":"JUMP"}

WAIT:
  {"type":"WAIT","time":seconds}

CLICK:
  {"type":"CLICK"}

LOOK:
  {"type":"LOOK","x":pixels,"y":pixels}

WALK_TO:
  {"type":"WALK_TO","mode":"nearest|random|furthest|object|saved","objectName":"optional name for object"}

WALK_TO_NEAREST:
  {"type":"WALK_TO_NEAREST"}   (same as WALK_TO with mode = "nearest")

SAVE_POSITION:
  {"type":"SAVE_POSITION"}

WHILE example:
{
  "type":"WHILE",
  "duration":seconds,
  "actions":[
    {"type":"MOVE","direction":"forward"},
    {"type":"JUMP"}
  ]
}

OUTPUT FORMAT EXAMPLE:

{"actions":[
  {"type":"MOVE","direction":"forward","time":0.5},
  {"type":"JUMP"},
  {"type":"WALK_TO","mode":"nearest"}
]}
]]

local AI = {
    ChatInstructions = CHAT_INSTRUCTIONS,
    ControlInstructions = CONTROL_INSTRUCTIONS,
    Mode = "Advanced",
    History = {},
    MaxHistory = 20,
}

local outputFrame
local outputListLayout
local sending = false
local ControlCharacterEnabled = false

-----------------------
-- LOGGING / HISTORY
-----------------------
local function addToHistory(role, text)
    table.insert(AI.History, { role = role, text = text })
    if #AI.History > AI.MaxHistory then
        table.remove(AI.History, 1)
    end
end

local function createLogLabel(role, text)
    if not outputFrame then return end

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -10, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextSize = 14

    local prefix
    if role == "user" then
        prefix = "You: "
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif role == "ai" then
        prefix = "LightAI: "
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
    else
        prefix = "[System]: "
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
    end

    label.Text = prefix .. text
    label.Parent = outputFrame

    task.wait()
    if outputListLayout then
        local contentSize = outputListLayout.AbsoluteContentSize
        outputFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 10)
        outputFrame.CanvasPosition = Vector2.new(0, math.max(0, contentSize.Y - outputFrame.AbsoluteSize.Y))
    end
end

local function Log(role, text)
    addToHistory(role, text)
    createLogLabel(role, text)
end

-----------------------
-- COHERE CONFIG + HTTP
-----------------------
local COHERE_KEY = (getgenv and getgenv().LIGHTAI_KEY) or "NO_KEY_SET"
local COHERE_MODEL = "command-a-vision-07-2025"
local API_URL = "https://api.cohere.ai/v1/chat"

local function httpPostJson(url, jsonBody)
    if COHERE_KEY == "NO_KEY_SET" then
        error("Cohere key not set. Set getgenv().LIGHTAI_KEY in your executor first.")
    end

    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. COHERE_KEY,
        ["Cohere-Version"] = "2022-12-06",
    }

    local httpRequest =
        (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or (fluxus and fluxus.request)

    if httpRequest then
        local resp = httpRequest({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = jsonBody,
        })
        if not resp then
            error("Exploit HTTP returned nil response")
        end
        local body = resp.Body or resp.body
        if not body then
            error("Exploit HTTP response has no Body")
        end
        return body
    else
        local ok, resp = pcall(function()
            return HttpService:RequestAsync({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = jsonBody,
            })
        end)

        if not ok or not resp then
            error("HttpService.RequestAsync failed")
        end

        if not resp.Success then
            error("HTTP " .. tostring(resp.StatusCode) .. " " .. tostring(resp.StatusMessage) ..
                " | " .. tostring(resp.Body))
        end

        return resp.Body
    end
end

-----------------------
-- CHARACTER CONTROL HELPERS
-----------------------
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local SavedPosition = nil

-- action tracking
local currentActionLabel
local stopActionButton
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

-------------------------------------------------
-- LOW-LEVEL INPUT FUNCTIONS
-------------------------------------------------
local function pressKeyDown(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
end

local function pressKeyUp(key)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function releaseMovementKeys()
    pressKeyUp(Enum.KeyCode.W)
    pressKeyUp(Enum.KeyCode.A)
    pressKeyUp(Enum.KeyCode.S)
    pressKeyUp(Enum.KeyCode.D)
end

local function pressMouse(time)
    time = tonumber(time) or 0.1
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    local start = tick()
    while tick() - start < time do
        if stopRequested then break end
        RunService.Heartbeat:Wait()
    end
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function pressKey(keycode, time)
    time = tonumber(time) or 0.3
    pressKeyDown(keycode)
    local start = tick()
    while tick() - start < time do
        if stopRequested then break end
        RunService.Heartbeat:Wait()
    end
    pressKeyUp(keycode)
end

-------------------------------------------------
-- CAMERA ROTATION
-------------------------------------------------
local function lookAt(dx, dy)
    dx = tonumber(dx) or 0
    dy = tonumber(dy) or 0

    local camera = workspace.CurrentCamera
    local cf = camera.CFrame

    cf = cf * CFrame.Angles(0, math.rad(-dx * 0.2), 0)

    local x, y, z = cf:ToEulerAnglesXYZ()
    y = math.clamp(y - math.rad(dy * 0.2), -1.2, 1.2)

    camera.CFrame = CFrame.new(cf.Position) * CFrame.Angles(x, y, z)
end

-------------------------------------------------
-- PLAYER HELPERS
-------------------------------------------------
local function getNearestPlayer()
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

    local myPos = myChar.HumanoidRootPart.Position
    local nearest, nearestDist = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos = plr.Character.HumanoidRootPart.Position
            local dist = (myPos - pos).Magnitude
            if dist < nearestDist then
                nearest = plr
                nearestDist = dist
            end
        end
    end

    return nearest
end

local function getRandomPlayer()
    local others = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(others, plr)
        end
    end
    if #others == 0 then return nil end
    return others[math.random(1, #others)]
end

local function getFurthestPlayer()
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

    local myPos = myChar.HumanoidRootPart.Position
    local furthest, furthestDist = nil, 0

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos = plr.Character.HumanoidRootPart.Position
            local dist = (myPos - pos).Magnitude
            if dist > furthestDist then
                furthest = plr
                furthestDist = dist
            end
        end
    end

    return furthest
end

-------------------------------------------------
-- MAP SCAN + GAME STATE
-------------------------------------------------
local function scanMap()
    local obstacles = {}
    local maxObstacles = 15

    for _, obj in ipairs(workspace:GetDescendants()) do
        if #obstacles >= maxObstacles then break end

        if obj:IsA("BasePart") and obj.CanCollide and obj.Size.Magnitude > 2 then
            table.insert(obstacles, {
                name = obj.Name,
                position = { x = obj.Position.X, y = obj.Position.Y, z = obj.Position.Z },
                size = { x = obj.Size.X, y = obj.Size.Y, z = obj.Size.Z },
            })
        end
    end

    return obstacles
end

local function getGameState()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    local state = {
        self = {
            health = hum and hum.Health or 0,
            position = root and { x = root.Position.X, y = root.Position.Y, z = root.Position.Z } or nil,
        },
        nearestPlayer = nil,
        nearbyPlayers = {},
        map = {
            obstacles = scanMap()
        }
    }

    local nearest = getNearestPlayer()
    if nearest and root and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
        local nroot = nearest.Character.HumanoidRootPart
        local nhum = nearest.Character:FindFirstChildOfClass("Humanoid")

        state.nearestPlayer = {
            name = nearest.Name,
            health = nhum and nhum.Health or 0,
            distance = (root.Position - nroot.Position).Magnitude,
            position = { x = nroot.Position.X, y = nroot.Position.Y, z = nroot.Position.Z },
        }
    end

    if root then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local nroot = plr.Character.HumanoidRootPart
                table.insert(state.nearbyPlayers, {
                    name = plr.Name,
                    distance = (root.Position - nroot.Position).Magnitude
                })
            end
        end
    end

    return state
end

-------------------------------------------------
-- OBJECT FINDER
-------------------------------------------------
local function findObjectByName(name)
    if not name or name == "" then return nil end
    local lowerName = string.lower(name)
    local closest
    local closestDist = math.huge

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local origin = root and root.Position or Vector3.new(0, 0, 0)

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            if string.find(n, lowerName, 1, true) then
                local dist = (obj.Position - origin).Magnitude
                if dist < closestDist then
                    closest = obj
                    closestDist = dist
                end
            end
        end
    end

    return closest
end

-------------------------------------------------
-- WALK HELPERS
-------------------------------------------------
local function walkToPosition(targetPos, maxTime)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    maxTime = maxTime or 10
    local startTime = tick()

    releaseMovementKeys()

    while tick() - startTime < maxTime do
        if stopRequested then break end

        local myPos = root.Position
        local diff = targetPos - myPos

        if diff.Magnitude <= 1.5 then
            break
        end

        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)

        local camera = workspace.CurrentCamera
        local forward = (camera.CFrame.LookVector * Vector3.new(1, 0, 1))
        local right = (camera.CFrame.RightVector * Vector3.new(1, 0, 1))

        if forward.Magnitude > 0 then forward = forward.Unit end
        if right.Magnitude > 0 then right = right.Unit end

        local diffDir = (targetPos - myPos)
        if diffDir.Magnitude > 0 then
            diffDir = diffDir.Unit
        end

        local fDot = diffDir:Dot(forward)
        local rDot = diffDir:Dot(right)

        releaseMovementKeys()

        if fDot > 0.2 then
            pressKeyDown(Enum.KeyCode.W)
        elseif fDot < -0.2 then
            pressKeyDown(Enum.KeyCode.S)
        end

        if rDot > 0.2 then
            pressKeyDown(Enum.KeyCode.D)
        elseif rDot < -0.2 then
            pressKeyDown(Enum.KeyCode.A)
        end

        RunService.Heartbeat:Wait()
    end

    releaseMovementKeys()
end

local function walkToPlayer(targetPlayer, maxTime)
    if not targetPlayer then return end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    maxTime = maxTime or 10
    local startTime = tick()

    while tick() - startTime < maxTime do
        if stopRequested then break end

        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            break
        end

        local targetPos = targetPlayer.Character.HumanoidRootPart.Position
        walkToPosition(targetPos, 0.2)
    end

    releaseMovementKeys()
end

local function walkToMode(mode, objectName)
    mode = (mode or "nearest"):lower()

    if mode == "nearest" then
        local target = getNearestPlayer()
        if target then
            walkToPlayer(target, 10)
        end

    elseif mode == "random" then
        local target = getRandomPlayer()
        if target then
            walkToPlayer(target, 10)
        end

    elseif mode == "furthest" then
        local target = getFurthestPlayer()
        if target then
            walkToPlayer(target, 10)
        end

    elseif mode == "saved" then
        if SavedPosition then
            walkToPosition(SavedPosition, 10)
        end

    elseif mode == "object" then
        local obj = findObjectByName(objectName or "")
        if obj then
            walkToPosition(obj.Position, 10)
        end
    end
end

local function walkToNearest()
    walkToMode("nearest")
end

-------------------------------------------------
-- WHILE ACTIONS
-------------------------------------------------
local function executeWhileAction(duration, actions)
    duration = tonumber(duration) or 1.0
    local endTime = tick() + duration
    local lastJump = 0

    local moveDirs = {}

    for _, act in ipairs(actions) do
        if act.type == "MOVE" then
            local dir = (act.direction or ""):lower()
            moveDirs[dir] = true
        end
    end

    if moveDirs["forward"] then pressKeyDown(Enum.KeyCode.W) end
    if moveDirs["back"] then pressKeyDown(Enum.KeyCode.S) end
    if moveDirs["left"] then pressKeyDown(Enum.KeyCode.A) end
    if moveDirs["right"] then pressKeyDown(Enum.KeyCode.D) end

    while tick() < endTime do
        if stopRequested then break end

        for _, act in ipairs(actions) do
            if act.type == "JUMP" then
                if tick() - lastJump > 0.8 then
                    pressKey(Enum.KeyCode.Space, 0.1)
                    lastJump = tick()
                end
            end
        end
        RunService.Heartbeat:Wait()
    end

    releaseMovementKeys()
end

-------------------------------------------------
-- ACTION DESCRIPTION (FOR UI)
-------------------------------------------------
local function describeAction(action)
    if not action or type(action) ~= "table" then
        return "Idle"
    end

    local t = action.type
    if t == "MOVE" then
        local dir = (action.direction or "unknown"):lower()
        local time = tonumber(action.time) or 0
        if time > 0 then
            return string.format("walking %s (%.1fs)", dir, time)
        else
            return "walking " .. dir
        end
    elseif t == "JUMP" then
        return "jumping"
    elseif t == "WAIT" then
        local time = tonumber(action.time) or 0
        return string.format("waiting (%.1fs)", time)
    elseif t == "CLICK" then
        return "clicking"
    elseif t == "LOOK" then
        return "looking around"
    elseif t == "WALK_TO_NEAREST" then
        return "walking to nearest player"
    elseif t == "WALK_TO" then
        local mode = (action.mode or "nearest"):lower()
        if mode == "object" then
            local name = action.objectName or action.name or action.targetName or "object"
            return "walking to object \"" .. tostring(name) .. "\""
        elseif mode == "saved" then
            return "walking to saved position"
        else
            return "walking to " .. mode .. " player"
        end
    elseif t == "SAVE_POSITION" then
        return "saving position"
    elseif t == "WHILE" then
        local dur = tonumber(action.duration) or 0
        return string.format("running while-block (%.1fs)", dur)
    end

    return "unknown action"
end

-------------------------------------------------
-- MAIN EXECUTION SYSTEM
-------------------------------------------------
function executeActions(actions)
    if type(actions) ~= "table" then
        clearCurrentAction()
        return
    end

    actionRunning = true
    stopRequested = false

    for _, action in ipairs(actions) do
        if stopRequested then
            break
        end

        setCurrentAction(describeAction(action))
        local t = action.type

        if t == "MOVE" then
            local dir = (action.direction or ""):lower()
            local time = tonumber(action.time) or 0.5

            if dir == "forward" then pressKey(Enum.KeyCode.W, time)
            elseif dir == "back" then pressKey(Enum.KeyCode.S, time)
            elseif dir == "left" then pressKey(Enum.KeyCode.A, time)
            elseif dir == "right" then pressKey(Enum.KeyCode.D, time)
            end

        elseif t == "JUMP" then
            pressKey(Enum.KeyCode.Space, 0.1)

        elseif t == "CLICK" then
            pressMouse(0.1)

        elseif t == "LOOK" then
            lookAt(action.x, action.y)

        elseif t == "WAIT" then
            local duration = tonumber(action.time) or 0.5
            local endTime = tick() + duration
            while tick() < endTime do
                if stopRequested then break end
                RunService.Heartbeat:Wait()
            end

        elseif t == "WALK_TO_NEAREST" then
            walkToNearest()

        elseif t == "WALK_TO" then
            walkToMode(action.mode, action.objectName or action.name or action.targetName)

        elseif t == "SAVE_POSITION" then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                SavedPosition = root.Position
            end

        elseif t == "WHILE" then
            executeWhileAction(action.duration, action.actions or {})
        end
    end

    releaseMovementKeys()
    clearCurrentAction()
end

-----------------------
-- CALL COHERE (WITH GAME INFO)
-----------------------
function CallLightAI(userText)
    if sending then
        Log("system", "Please wait, still responding...")
        return
    end
    if not userText or userText == "" then return end

    sending = true
    Log("user", userText)

    task.spawn(function()
        local ok, result = pcall(function()
            local chat_history = {}
            for _, h in ipairs(AI.History) do
                if h.role == "user" then
                    table.insert(chat_history, { role = "USER", message = h.text })
                elseif h.role == "ai" then
                    table.insert(chat_history, { role = "CHATBOT", message = h.text })
                end
            end

            local gameInfo = getGameState()
            local gameInfoJson = ""
            local okGI, encoded = pcall(function()
                return HttpService:JSONEncode(gameInfo)
            end)
            if okGI then
                gameInfoJson = encoded
            else
                gameInfoJson = "{}"
            end

            local preamble = ControlCharacterEnabled and AI.ControlInstructions or AI.ChatInstructions

            local payload = {
                model = COHERE_MODEL,
                message = "USER MESSAGE:\n" .. userText .. "\n\nGAME INFO (JSON):\n" .. gameInfoJson,
                preamble = preamble,
                chat_history = chat_history,
                stream = false,
            }

            local json = HttpService:JSONEncode(payload)
            local body = httpPostJson(API_URL, json)
            if not body then
                error("Empty response body")
            end

            local okDecode, data = pcall(function()
                return HttpService:JSONDecode(body)
            end)
            if not okDecode then
                error("Can't parse JSON. Raw body: " .. tostring(body))
            end

            local reply = data.text
            if not reply or reply == "" then
                reply = "(no reply from Cohere)\nRaw: " .. string.sub(HttpService:JSONEncode(data), 1, 200)
            end

            return reply
        end)

        if ok then
            local reply = result

            if ControlCharacterEnabled then
                local jsonChunk = reply:match("{.*}")
                if not jsonChunk then
                    Log("system", "Couldn't find JSON in control reply:\n" .. tostring(reply))
                else
                    local decodeOK, decoded = pcall(function()
                        return HttpService:JSONDecode(jsonChunk)
                    end)

                    if decodeOK and decoded and decoded.actions then
                        Log("system", "Executing control actions...")
                        executeActions(decoded.actions)
                        Log("ai", "Commands: " .. jsonChunk)
                    else
                        Log("system", "Failed to parse control JSON:\n" .. tostring(jsonChunk))
                    end
                end
            else
                Log("ai", reply)
            end

        else
            Log("system", "Error talking to Cohere: " .. tostring(result))
        end

        sending = false
    end)
end

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
    btn.TextSize = 16
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
local tabs = { "AI Control", "AI Output", "GUI Appearance", "Info" }

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

for _, name in ipairs(tabs) do
    local btn = createTabButton(name)
    createPage(name)
    btn.MouseButton1Click:Connect(function()
        setActiveTab(name)
    end)
end

-----------------------
-- PAGE: AI CONTROL
-----------------------
local aiControlPage = pages["AI Control"]

local modeFrame = Instance.new("Frame")
modeFrame.BackgroundTransparency = 1
modeFrame.Size = UDim2.new(1, 0, 0, 36)
modeFrame.Position = UDim2.new(0, 0, 0, 40)
modeFrame.Parent = aiControlPage

local modeLabel = Instance.new("TextLabel")
modeLabel.BackgroundTransparency = 1
modeLabel.Size = UDim2.new(0, 100, 1, 0)
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextSize = 14
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
modeLabel.Text = "Mode:"
modeLabel.Parent = modeFrame

local function createModeButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 90, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(220, 220, 220)
    b.Text = text
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = b
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.7
    s.Thickness = 1
    s.Parent = b
    return b
end

local advancedButton = createModeButton("Advanced")
advancedButton.Position = UDim2.new(0, 60, 0, 4)
advancedButton.Parent = modeFrame

local quickButton = createModeButton("Quick")
quickButton.Position = UDim2.new(0, 160, 0, 4)
quickButton.Parent = modeFrame

local function updateModeButtons()
    local activeColor = Color3.fromRGB(25, 25, 25)
    local inactiveColor = Color3.fromRGB(0, 0, 0)
    if AI.Mode == "Advanced" then
        advancedButton.BackgroundColor3 = activeColor
        quickButton.BackgroundColor3 = inactiveColor
    else
        advancedButton.BackgroundColor3 = inactiveColor
        quickButton.BackgroundColor3 = activeColor
    end
end

advancedButton.MouseButton1Click:Connect(function()
    AI.Mode = "Advanced"; updateModeButtons()
end)
quickButton.MouseButton1Click:Connect(function()
    AI.Mode = "Quick"; updateModeButtons()
end)
updateModeButtons()

-----------------------
-- PAGE: AI OUTPUT
-----------------------
local aiOutputPage = pages["AI Output"]

-- Action display row
local actionFrame = Instance.new("Frame")
actionFrame.Name = "ActionFrame"
actionFrame.BackgroundTransparency = 1
actionFrame.Size = UDim2.new(1, 0, 0, 24)
actionFrame.Position = UDim2.new(0, 0, 0, 40)
actionFrame.Parent = aiOutputPage

currentActionLabel = Instance.new("TextLabel")
currentActionLabel.BackgroundTransparency = 1
currentActionLabel.Size = UDim2.new(0, 220, 1, 0)
currentActionLabel.Font = Enum.Font.Gotham
currentActionLabel.TextSize = 14
currentActionLabel.TextXAlignment = Enum.TextXAlignment.Left
currentActionLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
currentActionLabel.Text = "Action: Idle"
currentActionLabel.Parent = actionFrame

stopActionButton = Instance.new("TextButton")
stopActionButton.Name = "StopActionButton"
stopActionButton.Size = UDim2.new(0, 100, 0, 22)
stopActionButton.Position = UDim2.new(0, 230, 0, 1)
stopActionButton.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
stopActionButton.BorderSizePixel = 0
stopActionButton.AutoButtonColor = false
stopActionButton.Font = Enum.Font.GothamBold
stopActionButton.TextSize = 14
stopActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopActionButton.Text = "Stop Action"
stopActionButton.Parent = actionFrame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 10)
stopCorner.Parent = stopActionButton

local stopStroke = Instance.new("UIStroke")
stopStroke.Color = Color3.fromRGB(255, 255, 255)
stopStroke.Transparency = 0.7
stopStroke.Thickness = 1
stopStroke.Parent = stopActionButton

stopActionButton.MouseButton1Click:Connect(function()
    if not actionRunning then
        return
    end
    stopRequested = true
    Log("system", "Stop requested. Current and remaining actions will be cancelled.")
    releaseMovementKeys()
end)

-- Control Character toggle UI
local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ControlToggleFrame"
toggleFrame.BackgroundTransparency = 1
toggleFrame.Size = UDim2.new(1, 0, 0, 24)
toggleFrame.Position = UDim2.new(0, 0, 0, 70)
toggleFrame.Parent = aiOutputPage

local toggleLabel = Instance.new("TextLabel")
toggleLabel.BackgroundTransparency = 1
toggleLabel.Size = UDim2.new(0, 180, 1, 0)
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.TextSize = 14
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
toggleLabel.Text = "Control Character:"
toggleLabel.Parent = toggleFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ControlToggle"
toggleButton.Size = UDim2.new(0, 80, 0, 22)
toggleButton.Position = UDim2.new(0, 190, 0, 1)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = false
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "OFF"
toggleButton.Parent = toggleFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Transparency = 0.7
toggleStroke.Thickness = 1
toggleStroke.Parent = toggleButton

local function updateToggleVisual()
    if ControlCharacterEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
        toggleButton.Text = "ON"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        toggleButton.Text = "OFF"
    end
end

toggleButton.MouseButton1Click:Connect(function()
    ControlCharacterEnabled = not ControlCharacterEnabled
    updateToggleVisual()
    if ControlCharacterEnabled then
        Log("system", "Control Character ENABLED. AI will output commands and move your character.")
    else
        Log("system", "Control Character DISABLED. AI is back to chat mode.")
    end
end)

updateToggleVisual()
clearCurrentAction()

-- Output area (chat log)
local outputBg = Instance.new("Frame")
outputBg.Name = "OutputBackground"
outputBg.Size = UDim2.new(1, 0, 1, -160)
outputBg.Position = UDim2.new(0, 0, 0, 100)
outputBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
outputBg.BorderSizePixel = 0
outputBg.Parent = aiOutputPage

local outputCorner = Instance.new("UICorner")
outputCorner.CornerRadius = UDim.new(0, 10)
outputCorner.Parent = outputBg

local outputStroke = Instance.new("UIStroke")
outputStroke.Color = Color3.fromRGB(255, 255, 255)
outputStroke.Transparency = 0.8
outputStroke.Thickness = 1
outputStroke.Parent = outputBg

outputFrame = Instance.new("ScrollingFrame")
outputFrame.Name = "OutputFrame"
outputFrame.BackgroundTransparency = 1
outputFrame.BorderSizePixel = 0
outputFrame.Size = UDim2.new(1, -8, 1, -8)
outputFrame.Position = UDim2.new(0, 4, 0, 4)
outputFrame.ScrollBarThickness = 4
outputFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
outputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
outputFrame.Parent = outputBg

outputListLayout = Instance.new("UIListLayout")
outputListLayout.Padding = UDim.new(0, 4)
outputListLayout.FillDirection = Enum.FillDirection.Vertical
outputListLayout.SortOrder = Enum.SortOrder.LayoutOrder
outputListLayout.Parent = outputFrame

-- Chat-style input at bottom
local inputFrame = Instance.new("Frame")
inputFrame.Name = "InputFrame"
inputFrame.BackgroundTransparency = 1
inputFrame.Size = UDim2.new(1, 0, 0, 50)
inputFrame.Position = UDim2.new(0, 0, 1, -50)
inputFrame.Parent = aiOutputPage

local chatBox = Instance.new("TextBox")
chatBox.Name = "ChatBox"
chatBox.Size = UDim2.new(1, -120, 1, 0)
chatBox.Position = UDim2.new(0, 0, 0, 0)
chatBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
chatBox.BorderSizePixel = 0
chatBox.ClearTextOnFocus = false
chatBox.Font = Enum.Font.Gotham
chatBox.TextSize = 14
chatBox.TextColor3 = Color3.fromRGB(255, 255, 255)
chatBox.TextXAlignment = Enum.TextXAlignment.Left
chatBox.TextYAlignment = Enum.TextYAlignment.Center
chatBox.TextWrapped = true
chatBox.MultiLine = false
chatBox.PlaceholderText = "Type a message for LightAI..."
chatBox.Parent = inputFrame

local chatCorner = Instance.new("UICorner")
chatCorner.CornerRadius = UDim.new(0, 10)
chatCorner.Parent = chatBox

local chatStroke = Instance.new("UIStroke")
chatStroke.Color = Color3.fromRGB(255, 255, 255)
chatStroke.Transparency = 0.8
chatStroke.Thickness = 1
chatStroke.Parent = chatBox

local sendButton = Instance.new("TextButton")
sendButton.Name = "SendButton"
sendButton.Size = UDim2.new(0, 100, 0, 32)
sendButton.Position = UDim2.new(1, -100, 0.5, -16)
sendButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sendButton.BorderSizePixel = 0
sendButton.AutoButtonColor = false
sendButton.Font = Enum.Font.GothamBold
sendButton.TextSize = 14
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.Text = "Send"
sendButton.Parent = inputFrame

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 10)
sendCorner.Parent = sendButton

local sendStroke = Instance.new("UIStroke")
sendStroke.Color = Color3.fromRGB(255, 255, 255)
sendStroke.Transparency = 0.7
sendStroke.Thickness = 1
sendStroke.Parent = sendButton

sendButton.MouseEnter:Connect(function()
    TweenService:Create(sendButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    }):Play()
end)
sendButton.MouseLeave:Connect(function()
    TweenService:Create(sendButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    }):Play()
end)

sendButton.MouseButton1Click:Connect(function()
    local text = chatBox.Text
    chatBox.Text = ""
    CallLightAI(text)
end)

chatBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local text = chatBox.Text
        chatBox.Text = ""
        CallLightAI(text)
    end
end)

Log("system", "LightAI (Cohere) ready. Type a message below.")

-----------------------
-- PAGE: GUI APPEARANCE (empty for now)
-----------------------
local guiAppearancePage = pages["GUI Appearance"]
-- placeholder for future appearance options

-----------------------
-- PAGE: INFO
-----------------------
local infoPage = pages["Info"]

local infoBody = Instance.new("ScrollingFrame")
infoBody.Name = "InfoBody"
infoBody.BackgroundTransparency = 1
infoBody.BorderSizePixel = 0
infoBody.Size = UDim2.new(1, -4, 1, -40)
infoBody.Position = UDim2.new(0, 2, 0, 36)
infoBody.ScrollBarThickness = 4
infoBody.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
infoBody.CanvasSize = UDim2.new(0, 0, 0, 0)
infoBody.Parent = infoPage

local infoListLayout = Instance.new("UIListLayout")
infoListLayout.Padding = UDim.new(0, 8)
infoListLayout.FillDirection = Enum.FillDirection.Vertical
infoListLayout.SortOrder = Enum.SortOrder.LayoutOrder
infoListLayout.Parent = infoBody

local function addInfoLine(text)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -8, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Text = text
    label.Parent = infoBody
end

addInfoLine("• LightAI has two modes:")
addInfoLine("  - Chat Mode: normal conversation, advice, help with Roblox or anything else.")
addInfoLine("  - Control Mode: LightAI sends JSON commands to move your character.")
addInfoLine("• Toggle Control Mode in the AI Output tab using the 'Control Character' switch.")
addInfoLine("• While controlling, the 'Action' line shows what LightAI is doing right now.")
addInfoLine("• Use 'Stop Action' to cancel the current movement and any remaining actions.")
addInfoLine("• Main control actions:")
addInfoLine("  MOVE: walk forward/back/left/right for a short time.")
addInfoLine("  JUMP: make your character jump.")
addInfoLine("  WALK_TO / WALK_TO_NEAREST: move towards players, objects, or a saved spot.")
addInfoLine("  SAVE_POSITION: remember your current position for later WALK_TO 'saved'.")
addInfoLine("  WHILE: combine actions like moving and jumping together for a duration.")
addInfoLine("• You can give natural instructions, like:")
addInfoLine('  "Follow the nearest player and jump every few seconds."')
addInfoLine('  "Walk to the nearest player, save the spot, then walk back to it later."')

task.wait()
infoBody.CanvasSize = UDim2.new(0, 0, 0, infoListLayout.AbsoluteContentSize.Y + 10)

-----------------------
-- DEFAULT TAB
-----------------------
setActiveTab("AI Output")
