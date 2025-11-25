---------------------------------------------------------
--  LIGHTAI — COHERE VERSION (WORKING)
--  Put this at the top of your script:
---------------------------------------------------------

local HttpService = game:GetService("HttpService")

local COHERE_KEY = (getgenv and getgenv().LIGHTAI_KEY) or "NO_KEY_SET"

local API_URL = "https://api.cohere.ai/v1/chat"

---------------------------------------------------------
--  HTTP FUNCTION (WORKS WITH EXECUTORS + ROBLOX)
---------------------------------------------------------
local function httpPostJson(url, jsonBody)
    local httpRequest =
        (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or (fluxus and fluxus.request)

    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. COHERE_KEY,
        ["Cohere-Version"] = "2022-12-06"
    }

    if httpRequest then
        local resp = httpRequest({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = jsonBody
        })
        return resp and (resp.Body or resp.body)
    else
        return HttpService:PostAsync(
            url,
            jsonBody,
            Enum.HttpContentType.ApplicationJson,
            false,
            headers
        )
    end
end

---------------------------------------------------------
--  COHERE RESPONSE PARSER
---------------------------------------------------------
local function extractCohereReply(json)
    if not json then return nil end
    if not json.text then return nil end
    return json.text
end

---------------------------------------------------------
--  YOUR AI CALL FUNCTION
---------------------------------------------------------
function CallLightAI(userText)
    if sending then
        Log("system", "Still responding…")
        return
    end
    if not userText or userText == "" then return end

    sending = true
    Log("user", userText)

    task.spawn(function()
        local ok, result = pcall(function()

            ---------------------------------------------------------
            -- BUILD COHERE PAYLOAD
            ---------------------------------------------------------
            local messages = {}

            table.insert(messages, {
                role = "system",
                content = AI.Instructions
            })

            for _, h in ipairs(AI.History) do
                table.insert(messages, {
                    role = (h.role == "ai" and "assistant" or "user"),
                    content = h.text
                })
            end

            table.insert(messages, {
                role = "user",
                content = userText
            })

            local payload = {
                model = "command-r", -- Cohere's chat model
                messages = messages,
            }

            local body = HttpService:JSONEncode(payload)
            local raw = httpPostJson(API_URL, body)

            if not raw then
                error("No response from Cohere")
            end

            print("RAW:", raw)

            local decoded = HttpService:JSONDecode(raw)
            local reply = extractCohereReply(decoded)

            return reply, raw
        end)

        if ok then
            local reply, raw = result[1], result[2]

            if reply then
                Log("ai", reply)
            else
                Log("ai", "(no reply from Cohere)")
                Log("system", "Raw: " .. tostring(raw))
            end
        else
            Log("system", "Error: " .. tostring(result))
        end

        sending = false
    end)
end

---------------------------------------------------------
--  END COHERE ENGINE
---------------------------------------------------------

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
local tabs = { "AI Control", "AI Output", "GUI Appearance" }

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

local msgLabel = Instance.new("TextLabel")
msgLabel.BackgroundTransparency = 1
msgLabel.Size = UDim2.new(1, 0, 0, 20)
msgLabel.Position = UDim2.new(0, 0, 0, 80)
msgLabel.Font = Enum.Font.Gotham
msgLabel.TextSize = 14
msgLabel.TextXAlignment = Enum.TextXAlignment.Left
msgLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
msgLabel.Text = "Your message:"
msgLabel.Parent = aiControlPage

local msgBox = Instance.new("TextBox")
msgBox.Name = "MessageBox"
msgBox.Size = UDim2.new(1, 0, 0, 120)
msgBox.Position = UDim2.new(0, 0, 0, 100)
msgBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
msgBox.BorderSizePixel = 0
msgBox.ClearTextOnFocus = false
msgBox.Font = Enum.Font.Gotham
msgBox.TextSize = 14
msgBox.TextColor3 = Color3.fromRGB(255, 255, 255)
msgBox.TextXAlignment = Enum.TextXAlignment.Left
msgBox.TextYAlignment = Enum.TextYAlignment.Top
msgBox.TextWrapped = true
msgBox.MultiLine = true
msgBox.PlaceholderText = "Type something for LightAI..."
msgBox.Parent = aiControlPage

local msgCorner = Instance.new("UICorner")
msgCorner.CornerRadius = UDim.new(0, 10)
msgCorner.Parent = msgBox

local msgStroke = Instance.new("UIStroke")
msgStroke.Color = Color3.fromRGB(255, 255, 255)
msgStroke.Transparency = 0.8
msgStroke.Thickness = 1
msgStroke.Parent = msgBox

local sendButton = Instance.new("TextButton")
sendButton.Name = "SendButton"
sendButton.Size = UDim2.new(0, 100, 0, 32)
sendButton.Position = UDim2.new(1, -110, 0, 230)
sendButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sendButton.BorderSizePixel = 0
sendButton.AutoButtonColor = false
sendButton.Font = Enum.Font.GothamBold
sendButton.TextSize = 14
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.Text = "Send"
sendButton.Parent = aiControlPage

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
    local text = msgBox.Text
    msgBox.Text = ""
    CallLightAI(text)
end)

msgBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local text = msgBox.Text
        msgBox.Text = ""
        CallLightAI(text)
    end
end)

-----------------------
-- PAGE: AI OUTPUT
-----------------------
local aiOutputPage = pages["AI Output"]

local outputBg = Instance.new("Frame")
outputBg.Name = "OutputBackground"
outputBg.Size = UDim2.new(1, 0, 1, -40)
outputBg.Position = UDim2.new(0, 0, 0, 40)
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

Log("system", "LightAI (OpenAI Responses) ready. Type a message in the AI Control tab.")

-----------------------
-- PAGE: GUI APPEARANCE (empty)
-----------------------
local guiAppearancePage = pages["GUI Appearance"]
-- (Add appearance options later if you want.)

-----------------------
-- DEFAULT TAB
-----------------------
setActiveTab("AI Control")
