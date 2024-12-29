-- Destroy any existing GUI elements before creating new ones
if ScreenGui_ then
    ScreenGui_:Destroy()
end

if Scathe_ then
    Scathe_:Destroy()
end

-- GUI's
local gui = script.Parent

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

-- Local Player
local lplayer = Players.LocalPlayer
local lhum = lplayer.Character:FindFirstChildWhichIsA("Humanoid")
local lhump = lplayer.Character:FindFirstChild("HumanoidRootPart")
local Mouse = lplayer:GetMouse()

-- Determine CoreGui based on environment (Studio or Game)
local CoreGui
if RunService:IsStudio() then
    CoreGui = lplayer:WaitForChild("PlayerGui")
else
    CoreGui = game.CoreGui
end

local Lib = {}

-- Function to find a player by name prefix
function Lib:ReturnPlayer(text)
    for _, v in pairs(Players:GetPlayers()) do
        if string.sub(string.lower(v.Name), 1, #text) == string.lower(text) then
            return v
        end
    end
end

-- Function to generate a random string of a random length
function Lib:Randomized()
    local length = math.random(10, 20)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

-- Function to create a UI corner
function Lib:UICorner(instance, num)
    num = num or 8
    local UIC = Instance.new("UICorner")
    UIC.CornerRadius = UDim.new(0, num)
    UIC.Parent = instance
    return UIC
end

-- Function to add padding to a UI element
function Lib:UIPad(instance, num)
    local UIP = Instance.new("UIPadding")
    UIP.Parent = instance
    return UIP
end

-- Function to create a UI list layout
function Lib:UIList(instance, num, align)
    local UIL = Instance.new("UIListLayout")
    UIL.Padding = UDim.new(0, num)
    UIL.HorizontalAlignment = align or "Center"
    UIL.SortOrder = Enum.SortOrder.LayoutOrder
    UIL.Parent = instance
    return UIL
end

-- Preload notification icons
local Warning_ = "http://www.roblox.com/asset/?id=3192540038"
local Success_ = "http://www.roblox.com/asset/?id=279548030"
local Error_ = "http://www.roblox.com/asset/?id=2022095309"

ContentProvider:PreloadAsync({Success_, Warning_, Error_})

-- Creating the ScreenGui for notifications
local ScreenGuis = Instance.new("ScreenGui")
getgenv().Scathe_ = ScreenGuis

local Frame_ = Instance.new("Frame")
local List = Instance.new("UIListLayout", Frame_)
local Icon_ = Instance.new("ImageLabel")

-- Notification function
function Lib:Notification(type, name, content, time)
    time = time or 4

    -- Create the notification frame
    local notification = Instance.new("Frame")
    notification.Name = "notification"
    notification.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    notification.BorderSizePixel = 0
    notification.AnchorPoint = Vector2.new(0.5, 0.5)
    notification.Position = UDim2.new(0.5, 0, 0, 0)
    notification.Size = UDim2.new(0, 363, 0, 72)
    notification.ZIndex = 10

    -- Apply corner radius
    Lib:UICorner(notification, 3)

    -- Bottom frame
    local bottomFrame = Instance.new("Frame")
    bottomFrame.Name = "bottomFrame"
    bottomFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    bottomFrame.BorderSizePixel = 0
    bottomFrame.Position = UDim2.new(0, 0, 0.665, 0)
    bottomFrame.Size = UDim2.new(0, 362, 0, 24)
    bottomFrame.ZIndex = 10

    -- Apply corner radius to the bottom frame
    Lib:UICorner(bottomFrame, 3)

    -- Notification name
    local notificationName = Instance.new("TextLabel")
    notificationName.Name = "notificationName"
    notificationName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notificationName.BackgroundTransparency = 1
    notificationName.Position = UDim2.new(0.14, 0, 0.1, 0)
    notificationName.Size = UDim2.new(0, 300, 0, 17)
    notificationName.Font = Enum.Font.GothamBold
    notificationName.Text = tostring(name)
    notificationName.TextScaled = true
    notificationName.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationName.TextSize = 13
    notificationName.TextXAlignment = Enum.TextXAlignment.Left
    notificationName.TextYAlignment = Enum.TextYAlignment.Top
    notificationName.ZIndex = 10

    -- Notification content
    local notificationContent = Instance.new("TextLabel")
    notificationContent.Name = "notificationContent"
    notificationContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notificationContent.BackgroundTransparency = 1
    notificationContent.Position = UDim2.new(0.14, 0, 0.31, 0)
    notificationContent.Size = UDim2.new(0, 312, 0, 26)
    notificationContent.Font = Enum.Font.Gotham
    notificationContent.Text = tostring(content)
    notificationContent.TextScaled = true
    notificationContent.TextColor3 = Color3.fromRGB(150, 150, 150)
    notificationContent.TextSize = 13
    notificationContent.TextXAlignment = Enum.TextXAlignment.Left
    notificationContent.ZIndex = 10

    -- Set notification icon based on type
    local Icon = Instance.new("ImageLabel")
    Icon.Parent = notification
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0, 10, 0.1, 0)
    if type == "Success" then
        Icon.Image = Success_
    elseif type == "Warning" then
        Icon.Image = Warning_
    elseif type == "Error" then
        Icon.Image = Error_
    end

    -- Parent everything to the ScreenGui
    notification.Parent = Frame_
    bottomFrame.Parent = notification
    notificationName.Parent = notification
    notificationContent.Parent = notification
    Icon.Parent = notification

    -- Show the notification
    ScreenGuis.Parent = CoreGui
    ScreenGuis.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGuis.Enabled = true

    -- Tweening the notification in and out
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {Position = UDim2.new(0.5, 0, -0.1, 0)}

    local tween = TweenService:Create(notification, tweenInfo, goal)
    tween:Play()

    -- Destroy the notification after the duration
    tween.Completed:Connect(function()
        notification:Destroy()
    end)
end

return Lib

    local typer = tostring(types)
    local types = string.lower(typer)

    if types == "warning" or types == "warn" then
    Icon.Name = "warningIcon"
    Icon.Parent = notification
    Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Icon.BackgroundTransparency = 1.000
    Icon.Position = UDim2.new(0.0192837473, 0, 0.0985912755, 0)
    Icon.Size = UDim2.new(0, 38, 0, 40)
    Icon.Image = Warning_
    elseif types == "success" or types == "check" then
    Icon.Name = "SuccessIcon"
    Icon.Parent = notification
    Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Icon.BackgroundTransparency = 1.000
    Icon.Position = UDim2.new(0.0192837473, 0, 0.0985912755, 0)
    Icon.Size = UDim2.new(0, 38, 0, 38)
    Icon.Image = Success_
    elseif types == "error" or types == "fail" then
    Icon.Name = "SuccessIcon"
    Icon.Parent = notification
    Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Icon.BackgroundTransparency = 1.000
    Icon.Position = UDim2.new(0.0302837473, 0, 0.1085912755, 0)
    Icon.Size = UDim2.new(0, 33, 0, 33)
    Icon.Image = Error_
    end

    local TweenInfo = TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)

    local Tween_ = Ts:Create(notification, TweenInfo, {
        Position = UDim2.new(0.5, 0, 0.005, 0)})
    local Tweened_ = Ts:Create(notification, TweenInfo, {
        Position = UDim2.new(0.5, 0, -0.15, 0)})

    Tween_:Play()
    delay(time,function()
        Tweened_:Play()
        wait(0.5)
        notification:Destroy()
        end)

    end)
end

function Lib:CreateWindow(name)
local ScreenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local tabPreview = Instance.new("Frame")
local topBar = Instance.new("Frame")
local TelligencesLib = Instance.new("TextLabel")
local Hubname = Instance.new("TextLabel")
local tabList = Instance.new("ScrollingFrame")

getgenv().ScreenGui_ = ScreenGui

ScreenGui.Name = "ScreenGui"
ScreenGui.Parent = CoreGui

ScreenGui.Enabled = true


mainFrame.Name = "mainFrame"
mainFrame.Parent = ScreenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Position = UDim2.new(0.5,0,0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
mainFrame.Size = UDim2.new(0, 547, 0, 385)
mainFrame.ZIndex = 1

Lib:UICorner(mainBar,4)

tabPreview.Name = "tabPreview"
tabPreview.Parent = mainFrame
tabPreview.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tabPreview.Position = UDim2.new(0.304744512, 0, 0.0834914595, 0)
tabPreview.Size = UDim2.new(0, 372, 0, 350)

Lib:UICorner(tabPreview,4)

topBar.Name = "topBar"
topBar.Parent = mainFrame
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.Size = UDim2.new(0, 548, 0, 26)

Lib:UICorner(topBar,4)

TelligencesLib.Name = "TelligencesLib"
TelligencesLib.Parent = topBar
TelligencesLib.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TelligencesLib.BackgroundTransparency = 1.000
TelligencesLib.Position = UDim2.new(0.0164233577, 0, 0, 0)
TelligencesLib.Size = UDim2.new(0, 147, 0, 33)
TelligencesLib.Font = Enum.Font.Gotham
TelligencesLib.Text = "Telligences Lib"
TelligencesLib.TextColor3 = Color3.fromRGB(255, 255, 255)
TelligencesLib.TextSize = 14.000
TelligencesLib.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
TelligencesLib.TextXAlignment = Enum.TextXAlignment.Left

Hubname.Name = "Hubname"
Hubname.Parent = topBar
Hubname.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Hubname.BackgroundTransparency = 1.000
Hubname.Position = UDim2.new(0.208029211, 0, 0, 0)
Hubname.Size = UDim2.new(0, 147, 0, 33)
Hubname.Font = Enum.Font.Gotham
Hubname.Text = "- ".. tostring(name)
Hubname.TextColor3 = Color3.fromRGB(213, 213, 213)
Hubname.TextSize = 11.000
Hubname.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
Hubname.TextWrapped = true
Hubname.TextXAlignment = Enum.TextXAlignment.Left

tabList.Name = "tabList"
tabList.Parent = mainFrame
tabList.Active = true
tabList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tabList.BorderSizePixel = 0
tabList.Position = UDim2.new(0.0148540139, 0, 0.0829999968, 0)
tabList.Size = UDim2.new(0, 147, 0, 350)
tabList.ScrollBarThickness = 4
tabList.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left

tabCorner = Lib:UICorner(tabList,4)
tabCanvas = Lib:UIList(tabList,6)

local UIPadA = Lib:UIPad(tabList)
UIPadA.PaddingTop = UDim.new(0,4)

local visibles = {}

local tabsCreated = 0

function Lib:CreateTab(name, clicked)
    -- Default clicked callback function
    clicked = clicked or function() end

    -- Creating the Tab Button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "TabButton"
    tabBtn.Parent = tabList
    tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Position = UDim2.new(0.102, 0, 0.0137, 0)
    tabBtn.Size = UDim2.new(0, 118, 0, 26)
    tabBtn.Selectable = false
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.Text = tostring(name)
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.TextSize = 11
    tabBtn.TextWrapped = true

    -- Adding corner radius
    Lib:UICorner(tabBtn, 4)

    -- Create additional label for design purposes (appears to be a shadow effect)
    local designLabel = Instance.new("TextLabel")
    designLabel.Name = "DesignLabel"
    designLabel.Parent = tabBtn
    designLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    designLabel.BackgroundTransparency = 1
    designLabel.Position = UDim2.new(0, 0, 0, 0)
    designLabel.Size = UDim2.new(0, 118, 0, 26)
    designLabel.Font = Enum.Font.Gotham
    designLabel.Text = tostring(name)
    designLabel.TextWrapped = true
    designLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    designLabel.TextSize = 11

    -- Adding corner radius to design label
    Lib:UICorner(designLabel, 4)

    -- Creating the tab content frame
    local contentTab = Instance.new("ScrollingFrame")
    contentTab.Name = "ContentTab"
    contentTab.Parent = mainFrame
    contentTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentTab.BorderSizePixel = 0
    contentTab.Position = UDim2.new(0.3047, 0, 0.0835, 0)
    contentTab.Size = UDim2.new(0, 372, 0, 350)

    -- Handling content list inside the tab
    local contentList = Lib:UIList(contentTab, 8)
    local extraPadding = 0

    -- Update canvas size when new UI elements are added
    contentTab.ChildAdded:Connect(function(child)
        if not string.find(child.ClassName, "UI") then
            contentTab.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + contentList.Padding.Offset + extraPadding)
        end
    end)

    -- Hiding all tabs initially if more than one tab is created
    if tabsCreated >= 2 then
        contentTab.Visible = false
    end

    -- Add gradient effect to the tab button
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 26, 165)),
        ColorSequenceKeypoint.new(0.001, Color3.fromRGB(31, 29, 33)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 30, 30))
    })
    uiGradient.Rotation = 15
    uiGradient.Parent = tabBtn

    -- Add the content tab to the visible tabs list
    table.insert(visibles, contentTab)

    -- Apply padding to the tab content
    local padding = Lib:UIPad(contentTab)
    padding.PaddingTop = UDim.new(0, 8)

    -- Function to handle tab click event
    local function onTabClick()
        -- Hide all other tabs and their content
        for _, tab in pairs(visibles) do
            for _, v in pairs(tab:GetDescendants()) do
                if not string.find(v.ClassName, "UI") and not string.find(v.Name, "Exceptionally") then
                    v.Visible = false
                end
            end
            tab.Visible = false
        end

        -- Show the current tab content
        for _, v in pairs(contentTab:GetDescendants()) do
            if not string.find(v.ClassName, "UI") then
                v.Visible = true
            end
        end
        contentTab.Visible = true
    end

    -- Connect the tab button to the tab click function
    tabBtn.MouseButton1Click:Connect(onTabClick)
end
    
tabBtn.MouseButton1Click:Connect(tabClick)
tabBtn.MouseButton1Click:Connect(clicked)

local Tab = {}

function Tab:CreateButton(name,clicked)
local name = name or "Button"
local clicked = clicked or function() end
local UIGradient = Instance.new("UIGradient")
local UIGradients = Instance.new("UIGradient")
local designA = Instance.new("TextLabel")
local inBtn = Instance.new("TextButton")

inBtn.AutoButtonColor = false
inBtn.Name = "inBtn"
inBtn.Parent = inTab
inBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inBtn.BorderSizePixel = 0
inBtn.Position = UDim2.new(0.10204082, 0, 0.0136783719, 0)
inBtn.Size = UDim2.new(0, 325, 0, 35)
inBtn.Selectable = false
inBtn.Font = Enum.Font.Gotham
inBtn.Text = tostring(name)
inBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
inBtn.TextSize = 11.000
inBtn.TextWrapped = true

Lib:UICorner(inBtn,6)

designA.Active = false
designA.Name = "designA"
designA.Parent = inBtn
designA.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
designA.BackgroundTransparency = 1
designA.Position = UDim2.new(0, 0, 0, 0)
designA.Size = UDim2.new(0, 325, 0, 35)
designA.Font = Enum.Font.Gotham
designA.Text = tostring(name)
designA.TextWrapped = true
designA.TextColor3 = Color3.fromRGB(255, 255, 255)
designA.TextSize = 11.000

Lib:UICorner(designA,4)

UIGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 26, 165)),
    ColorSequenceKeypoint.new(0.001, Color3.fromRGB(31, 29, 33)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 30, 30))
}
UIGradient.Rotation = 15
UIGradient.Offset = Vector2.new(-0.225,0)
UIGradient.Parent = inBtn

local TweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local TweenService = game:GetService("TweenService")
local inBtn = script.Parent -- Example: Change this to the button you want to animate
local TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut) -- Smoother transition

-- Hover states
local toHover = {
    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
    Size = UDim2.new(0, 335, 0, 40),
    Rotation = 5, -- Adds a subtle rotation when hovered
    Transparency = 0.1 -- Optionally add transparency
}

local toLeave = {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(0, 325, 0, 35),
    Rotation = 0,
    Transparency = 0
}

-- Create tweens for hover-in and hover-out actions
local onHover = TweenService:Create(inBtn, TweenInfo, toHover)
local onLeave = TweenService:Create(inBtn, TweenInfo, toLeave)

-- Hover event listeners
inBtn.MouseEnter:Connect(function()
    onHover:Play() -- Play hover-in animation when mouse enters
end)

inBtn.MouseLeave:Connect(function()
    onLeave:Play() -- Play hover-out animation when mouse leaves
end)


local function leave()
onLeave:Play()
end

local function click()
leave()
pcall(function()
    clicked(inBtn)
    end)
end

local btn = inBtn

function button_click()

local normal_size = UDim2.new(0,325,0,35)
local bigger_size = UDim2.new(0, 335, 0, 38)

local normal_position = btn.Position
local corrected_position = btn.Position - UDim2.new(0.017, 0, 0.008, 0)

btn:TweenSizeAndPosition(bigger_size, corrected_position, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.25, true)
wait(0.2)
btn:TweenSizeAndPosition(normal_size, normal_position, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.25, true)
end

btn.MouseButton1Click:Connect(button_click)

inBtn.MouseEnter:Connect(hover)
inBtn.MouseLeave:Connect(leave)
inBtn.InputBegan:Connect(hover)
inBtn.InputEnded:Connect(leave)
inBtn.MouseButton1Click:Connect(click)
end

function Tab:CreateBlank(name,clicked)
local name = name or ""
local clicked = clicked or function() end
local designA = Instance.new("TextLabel")
local inBtn = Instance.new("TextButton")

inBtn.AutoButtonColor = false
inBtn.Name = "inBtn"
inBtn.Parent = inTab
inBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inBtn.BackgroundTransparency = 0
inBtn.BorderSizePixel = 0
inBtn.Position = UDim2.new(0.10204082, 0, 0.0136783719, 0)
inBtn.Size = UDim2.new(0, 325, 0, 35)
inBtn.Selectable = false
inBtn.Font = Enum.Font.Gotham
inBtn.Text = name
inBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
inBtn.TextSize = 11.000
inBtn.TextWrapped = true

Lib:UICorner(inBtn,6)

designA.Active = false
designA.Name = "designA"
designA.Parent = inBtn
designA.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
designA.BackgroundTransparency = 1
designA.Position = UDim2.new(0, 0, 0, 0)
designA.Size = UDim2.new(0, 325, 0, 35)
designA.Font = Enum.Font.Gotham
designA.Text = name
designA.TextWrapped = true
designA.TextColor3 = Color3.fromRGB(255, 255, 255)
designA.TextSize = 11.000

Lib:UICorner(designA,4)

return inBtn
end

function Tab:CreateToggle(name,state,clicked)
local name = name or "Toggle"
local clicked = clicked or function() end
local inBtn = Instance.new("TextButton")
local box = Instance.new("TextButton")
local highlight = Instance.new("TextButton")
local UIGradient = Instance.new("UIGradient")
local UIGradients = Instance.new("UIGradient")
local designA = Instance.new("TextLabel")
local state = state or false

inBtn.AutoButtonColor = false
inBtn.Name = "inBtn"
inBtn.Parent = inTab
inBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inBtn.BorderSizePixel = 0
inBtn.Position = UDim2.new(0.10204082, 0, 0.0136783719, 0)
inBtn.Size = UDim2.new(0, 325, 0, 35)
inBtn.Font = Enum.Font.Gotham
inBtn.Text = tostring(name)
inBtn.TextWrapped = true
inBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
inBtn.TextSize = 11.000

Lib:UICorner(inBtn,6)

designA.Active = false
designA.Name = "designA"
designA.Parent = inBtn
designA.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
designA.BackgroundTransparency = 1
designA.Position = UDim2.new(0, 0, 0, 0)
designA.Size = UDim2.new(0, 325, 0, 35)
designA.Font = Enum.Font.Gotham
designA.Text = tostring(name)
designA.TextWrapped = true
designA.TextColor3 = Color3.fromRGB(255, 255, 255)
designA.TextSize = 11.000

Lib:UICorner(designA,4)

box.Active = false
box.AutoButtonColor = false
box.Name = "box"
box.Parent = inBtn
box.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
box.BorderSizePixel = 0
box.Position = UDim2.new(0.915, 0, 0.08, 0)
box.Size = UDim2.new(0.07,0,0.65,0)
box.Font = Enum.Font.Gotham
box.Text = ""
box.TextWrapped = true
box.TextColor3 = Color3.fromRGB(255, 255, 255)

Lib:UICorner(box,20)

highlight.Active = false
highlight.AutoButtonColor = false
highlight.Name = "highlight"
highlight.Parent = inBtn
highlight.BackgroundColor3 = Color3.fromRGB(25,125,25)
highlight.BorderSizePixel = 0
highlight.Position = UDim2.new(0.928, 0, 0.19, 0)
highlight.Size = UDim2.new(0.045, 0, 0.4, 0)
highlight.Font = Enum.Font.Gotham
highlight.Text = ""
highlight.TextWrapped = true
highlight.TextColor3 = Color3.fromRGB(255, 255, 255)

Lib:UICorner(highlight,25)

UIGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 26, 165)),
    ColorSequenceKeypoint.new(0.001, Color3.fromRGB(31, 29, 33)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 30, 30))
}
UIGradient.Rotation = 15
UIGradient.Offset = Vector2.new(-0.225,0)
UIGradient.Parent = inBtn

local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local toOpen = {
    BackgroundColor3 = Color3.fromRGB(25,255,25),
}

local toClose = {
    BackgroundColor3 = Color3.fromRGB(75,18,18),
}

local toHover = {
    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
    Size = UDim2.new(0, 335, 0, 40)
}

local toLeave = {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(0, 325, 0, 35)
}

local onHover = TweenService:Create(inBtn, TweenInfo, toHover)
local onLeave = TweenService:Create(inBtn, TweenInfo, toLeave)
local onOpen = TweenService:Create(highlight, TweenInfo, toOpen)
local onClose = TweenService:Create(highlight, TweenInfo, toClose)

function highlighter()
if state then
onOpen:Play()
else
    onClose:Play()
end
end

highlighter()

local function hover()
onHover:Play()
end

local function leave()
onLeave:Play()
end

local function click()
leave()
state = not state
highlighter()
pcall(function()
    clicked(state,inBtn)
    end)
end

local btn = inBtn

function button_click()

local normal_size = UDim2.new(0,325,0,35)
local bigger_size = UDim2.new(0, 335, 0, 38)

local normal_position = btn.Position
local corrected_position = btn.Position - UDim2.new(0.017, 0, 0.008, 0)

btn:TweenSizeAndPosition(bigger_size, corrected_position, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.25, true)
wait(0.2)
btn:TweenSizeAndPosition(normal_size, normal_position, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.25, true)
end

btn.MouseButton1Click:Connect(button_click)

inBtn.MouseEnter:Connect(hover)
inBtn.MouseLeave:Connect(leave)
inBtn.InputBegan:Connect(hover)
inBtn.InputEnded:Connect(leave)
inBtn.MouseButton1Click:Connect(click)
end

function Tab:CreateSlider(name,min,max,sliding,whilst)
local inBtn = Instance.new("TextButton")
local sliderLabel = Instance.new("TextLabel")
local sliderFrame = Instance.new("TextButton")
local sliderPoint = Instance.new("TextButton")
local sliderValue = Instance.new("TextLabel")
local UIGradient = Instance.new("UIGradient")
local name = name or "Slider"
local min = min or "0"
local max = max or "100"
local Whilst = whilst or false

inBtn.AutoButtonColor = false
inBtn.Name = "inBtn"
inBtn.Parent = inTab
inBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inBtn.BorderSizePixel = 0
inBtn.Position = UDim2.new(0.10204082, 0, 0.0136783719, 0)
inBtn.Size = UDim2.new(0, 325, 0, 35)
inBtn.Font = Enum.Font.Gotham
inBtn.Text = tostring(name)
inBtn.TextWrapped = true
inBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
inBtn.TextSize = 11.000

Lib:UICorner(inBtn,6)

UIGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 26, 165)),
    ColorSequenceKeypoint.new(0.001, Color3.fromRGB(31, 29, 33)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 30, 30))
}
UIGradient.Rotation = 15
UIGradient.Offset = Vector2.new(-0.225,0)
UIGradient.Parent = inBtn

sliderLabel.Name = "sliderLabel"
sliderLabel.Parent = sliderFrame
sliderLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Position = UDim2.new(0.0306098592, 0, -3.5, 0)
sliderLabel.Size = UDim2.new(0, 240, 0, 33)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.Text = tostring(name)
sliderLabel.TextColor3 = Color3.fromRGB(213, 213, 213)
sliderLabel.TextSize = 11.000
sliderLabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.TextWrapped = false
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

sliderFrame.Name = "sliderFrame"
sliderFrame.Parent = inBtn
sliderFrame.Text = ""
sliderFrame.BackgroundColor3 = Color3.fromRGB(136, 116, 177)
sliderFrame.Position = UDim2.new(0.06, 0, 0.625, 0)
sliderFrame.Size = UDim2.new(0, 298, 0, 8)

Lib:UICorner(sliderFrame,4)

sliderPoint.Name = "sliderPoint"
sliderPoint.Parent = sliderFrame
sliderPoint.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderPoint.BorderSizePixel = 0
sliderPoint.Position = UDim2.new(0.126344085, 0, -0.5, 0)
sliderPoint.Size = UDim2.new(0, 10, 0, 16)
sliderPoint.Font = Enum.Font.SourceSans
sliderPoint.Text = ""
sliderPoint.TextColor3 = Color3.fromRGB(0, 0, 0)
sliderPoint.TextSize = 14.000

Lib:UICorner(sliderPoint,3)

sliderValue.Name = "sliderValue"
sliderValue.Parent = sliderFrame
sliderValue.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
sliderValue.BackgroundTransparency = 1
sliderValue.BorderSizePixel = 0
sliderValue.Position = UDim2.new(0.825, 0, -3.5, 0)
sliderValue.Size = UDim2.new(0, 45, 0, 33)
sliderValue.Font = Enum.Font.SourceSans
sliderValue.Text = min.." / "..max
sliderValue.TextWrapped = false
sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderValue.TextSize = 13.000

Lib:UICorner(sliderValue,2)

local down = false
local value = min or max

sliderFrame.MouseButton1Down:connect(function()
    down = true
    RunService.RenderStepped:Connect(function()
        if Whilst and down then
        pcall(sliding, math.floor(value))
        end
        end)

    while down and RunService.RenderStepped:wait() do
    percentage = math.clamp(((mouse.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X), 0, 1)
    sliderPoint:TweenPosition(UDim2.new(percentage, 0, -0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.05)
    value = (percentage * (max - min)) + min
    sliderValue.Text = string.format("%d / %d", value, max)
    end
    end)

Mouse.Button1Up:connect(function()
    if down == true then
    down = false
    end
    end)

local InputBeggar
InputBeggar = UserInputService.InputBegan:Connect(function(input)
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
        if down == true then
        task.spawn(function()
            pcall(sliding, math.floor(value))
            end)
        down = false
        end
        end
        end)
    end)
end

function Tab:CreateTextbox(label,callback)
bigChunk = bigChunk + 2
local UICorner = Instance.new("UICorner")
local idkframe = Instance.new("TextBox")
local bottomframe = Instance.new("Frame")
local executeBtn = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")
local clearBtn = Instance.new("TextButton")
local UICorner_3 = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local main = Instance.new("Frame")
local label = label or "Input"

main.Name = "inBtn"
main.Parent = inTab
main.BorderSizePixel = 0
main.BackgroundColor3 = Color3.fromRGB(40,40,40)
main.Position = UDim2.new(0, 0, 0, 0)
main.Size = UDim2.new(0, 325, 0, 71)

UICorner.Parent = main

idkframe.Name = "idkframe"
idkframe.Parent = main
idkframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
idkframe.BorderSizePixel = 1
idkframe.BorderColor3 = Color3.fromRGB(70,26,165)
idkframe.Text = ""
idkframe.PlaceholderText = label
idkframe.TextColor3 = Color3.fromRGB(255,255,255)
idkframe.Position = UDim2.new(0, 0, 0, 0)
idkframe.Size = UDim2.new(0, 325, 0, 40)

bottomframe.Name = "bottomframe"
bottomframe.Parent = idkframe
bottomframe.BackgroundTransparency = 0
bottomframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bottomframe.BorderSizePixel = 0
bottomframe.Position = UDim2.new(0, 0, 1, 0)
bottomframe.Size = UDim2.new(0, 325, 0, 31)

executeBtn.Name = "executeBtn"
executeBtn.Parent = bottomframe
executeBtn.BackgroundColor3 = Color3.fromRGB(112, 0, 168)
executeBtn.Position = UDim2.new(0.8, 0, 0.161290318, 0)
executeBtn.Size = UDim2.new(0, 58, 0, 21)
executeBtn.Font = Enum.Font.GothamBlack
executeBtn.Text = "Execute"
executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
executeBtn.TextSize = 11.000

UICorner_2.CornerRadius = UDim.new(0, 3)
UICorner_2.Parent = executeBtn

clearBtn.Name = "clearBtn"
clearBtn.Parent = bottomframe
clearBtn.BackgroundColor3 = Color3.fromRGB(112, 0, 168)
clearBtn.Position = UDim2.new(0.6, 0, 0.161290318, 0)
clearBtn.Size = UDim2.new(0, 58, 0, 21)
clearBtn.Font = Enum.Font.GothamBlack
clearBtn.Text = "Clear"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 11.000

UICorner_3.CornerRadius = UDim.new(0, 3)
UICorner_3.Parent = clearBtn

UIGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 26, 165)), ColorSequenceKeypoint.new(0.001, Color3.fromRGB(30,30,30)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30,30,30))}
UIGradient.Offset = Vector2.new(-0.225, 0)
UIGradient.Rotation = 15
UIGradient.Parent = bottomframe

clearBtn.MouseButton1Click:Connect(function()
    idkframe.Text = ""
    end)
executeBtn.MouseButton1Click:Connect(function()
    pcall(function()
        callback(idkframe.Text)
        end)
    end)
end

function Tab:CreateDropdown(name,options,callback)
local main = Instance.new("Frame")
local labela = Instance.new("TextLabel")
local labelb = Instance.new("TextLabel")
local stfuCorner = Instance.new("UICorner")
local stfu2 = Instance.new("UIGradient")
local bakaButton = Instance.new("TextButton")
local dropdown = Instance.new("Frame")
local options = options or {"Table"}

main.Name = "main"
main.Parent = inTab
main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
main.Position = UDim2.new(0.39731285, 0, 0.234726697, 0)
main.Size = UDim2.new(0, 325, 0, 35)

stfuCorner.CornerRadius = UDim.new(0, 6)
stfuCorner.Name = "stfuCorner"
stfuCorner.Parent = main

stfu2.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 26, 165)), ColorSequenceKeypoint.new(0.001, Color3.fromRGB(30,30,30)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30,30,30))}
stfu2.Offset = Vector2.new(-0.225,0)
stfu2.Rotation = 15
stfu2.Name = "stfu2"
stfu2.Parent = main

labela.Name = "inBtn"
labela.Parent = main
labela.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
labela.BackgroundTransparency = 1
labela.Position = UDim2.new(0.075, 0, 0.0136783719, 0)
labela.Size = UDim2.new(0.825, 0, 1, 0)
labela.Selectable = false
labela.Font = Enum.Font.Gotham
labela.Text = tostring(name)
labela.TextColor3 = Color3.fromRGB(255, 255, 255)
labela.TextSize = 11.000
labela.TextWrapped = true

labelb.Visible = false
labelb.Name = "inBtn"
labelb.Parent = main
labelb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
labelb.BackgroundTransparency = 1
labelb.Position = UDim2.new(0.075, 0, 0.1, 0)
labelb.Size = UDim2.new(0.825, 0, 0.2, 0)
labelb.Selectable = false
labelb.Font = Enum.Font.Gotham
labelb.Text = "Chosen:"
labelb.TextColor3 = Color3.fromRGB(125, 125, 125)
labelb.TextSize = 11.000
labelb.TextWrapped = true

bakaButton.Name = "bakaButton"
bakaButton.Parent = main
bakaButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bakaButton.BackgroundTransparency = 0.85
bakaButton.Position = UDim2.new(0.9, 0, 0, 0)
bakaButton.Size = UDim2.new(0.1, 0, 1, 0)
bakaButton.Font = Enum.Font.GothamBold
bakaButton.Text = ">"
bakaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bakaButton.TextSize = 17.000
bakaButton.TextWrapped = true

Lib:UICorner(bakaButton,4)

dropdown.Name = "dropdown"
dropdown.Parent = inTab
dropdown.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
dropdown.BorderSizePixel = 0
dropdown.Visible = false
dropdown.Position = UDim2.new(0.000820050074, 0, 0.974373996, 0)
dropdown.Size = UDim2.new(0, 325, 0, 0)

Lib:UICorner(dropdown,8)

local Pad = Lib:UIPad(dropdown)
Pad.PaddingTop = UDim.new(0,5)
Lib:UIList(dropdown,4)

local t = false
bakaButton.MouseButton1Click:Connect(function()
    t = not t
    if t then
    dropdown.Visible = true
bakaButton.Text = "v"
    else
        dropdown.Visible = false
bakaButton.Text = ">"
    end
end)

for i, v in pairs(options) do
local dropor = Instance.new("TextButton")
local label = Instance.new("TextLabel")
local UIGradient = Instance.new("UIGradient")

dropdown.Size = dropdown.Size + UDim2.new(0,0,0,33)
dropor.AutoButtonColor = false
dropor.Name = "inBtn"
dropor.Parent = dropdown
dropor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dropor.Position = UDim2.new(0.10204082, 0, 0.0136783719, 0)
dropor.Size = UDim2.new(0, 275, 0, 26)
dropor.Selectable = false
dropor.Font = Enum.Font.Gotham
dropor.Text = tostring(v)
dropor.TextColor3 = Color3.fromRGB(255, 255, 255)
dropor.TextSize = 11.000
dropor.TextWrapped = true

label.Name = "inBtn"
label.Parent = dropor
label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
label.BackgroundTransparency = 1
label.Position = UDim2.new(0.10204082, 0, 0.0136783719, 0)
label.Size = UDim2.new(0, 242, 0, 25)
label.Selectable = false
label.Font = Enum.Font.Gotham
label.Text = tostring(v)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 11.000
label.TextWrapped = true

UIGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 26, 165)), ColorSequenceKeypoint.new(0.001, Color3.fromRGB(31, 29, 33)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 30, 30))}
UIGradient.Offset = Vector2.new(-0.225,0) 
UIGradient.Rotation = 15
UIGradient.Parent = dropor

Lib:UICorner(dropor,4)

local function cliche()
    labelb.Visible = true
    pcall(function()
    callback(dropor.Text)
    end)
    labela.Text = dropor.Text
    end

dropor.MouseButton1Click:Connect(cliche)
end
end

return Tab
end
end

return Lib
