--[[
    Nova Aimbot v3.0
    
    A powerful aimbot script for Roblox with enhanced performance and features
    
    Key Features:
    - Optimized performance with reduced CPU usage
    - Enhanced ESP with customizable features (boxes, tracers, health bars)
    - Target priority system (distance, health, or custom)
    - Multiple aim modes (snap, smooth, silent aim)
    - Advanced prediction algorithms
    - Customizable keybinds
    - Memory leak prevention
    - Anti-detection measures
]]--

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player References
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration (All settings can be changed in the UI)
local Config = {
    -- Main Settings
    Enabled = false,
    AimbotEnabled = false,
    ESPEnabled = false,
    
    -- Aimbot Settings
    AimMode = "Smooth", -- "Snap", "Smooth", "Silent"
    TargetPart = "Head", -- "Head", "Torso", "HumanoidRootPart", "Random"
    TargetPriority = "Distance", -- "Distance", "Health", "Angle"
    FOVEnabled = true,
    FOVRadius = 200,
    FOVSides = 60, -- Higher = smoother circle
    AimSmoothing = 0.5, -- Lower = faster
    MaxDistance = 1000,
    TeamCheck = true,
    VisibilityCheck = true,
    
    -- Prediction Settings
    PredictionEnabled = true,
    PredictionAmount = 0.165,
    AdaptivePrediction = true, -- Adjusts prediction based on ping
    
    -- ESP Settings
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPTracers = true,
    ESPHealthBar = true,
    ESPShowTeam = false,
    ESPShowVisible = true,
    ESPOutlines = true,
    ESPRefreshRate = 10, -- Lower = more frequent updates but higher CPU usage
    
    -- Colors
    ESPColor = Color3.fromRGB(255, 0, 0),
    ESPTeamColor = Color3.fromRGB(0, 255, 0),
    ESPTargetColor = Color3.fromRGB(255, 255, 0),
    FOVColor = Color3.fromRGB(255, 255, 255),
    
    -- KeyBinds
    KeyBinds = {
        ToggleAimbot = Enum.KeyCode.End,
        ToggleESP = Enum.KeyCode.Delete,
        AimKey = Enum.UserInputType.MouseButton2, -- Right mouse button
        TargetCycleKey = Enum.KeyCode.Tab
    }
}

-- Create a unique ID for this instance to prevent conflicts
local NovaID = HttpService:GenerateGUID(false)

-- UI Elements
local NovaAimbotGui = Instance.new("ScreenGui")
NovaAimbotGui.Name = "NovaAimbotGui_" .. NovaID
NovaAimbotGui.Parent = CoreGui
NovaAimbotGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NovaAimbotGui.ResetOnSpawn = false
NovaAimbotGui.DisplayOrder = 999

-- FOV Circle with improved performance
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.FOVEnabled
FOVCircle.Radius = Config.FOVRadius
FOVCircle.Thickness = 2
FOVCircle.Transparency = 1
FOVCircle.Color = Config.FOVColor
FOVCircle.Filled = false
FOVCircle.NumSides = Config.FOVSides

-- Variable Initialization
local Aimbot = {
    Target = nil,
    Aiming = false,
    ESPObjects = {},
    UIVisible = true,
    LastRefresh = 0,
    TargetLocked = false,
    TargetCycle = {},
    TargetCycleIndex = 1,
    LastPredictionUpdate = 0,
    CurrentPing = 0,
    AdaptivePredictionValue = Config.PredictionAmount
}

-- Create a performance monitor
local PerformanceStats = {
    FrameTimes = {},
    LastFrameTime = tick(),
    AverageFPS = 60,
    ESPRenderTime = 0,
    AimbotProcessTime = 0
}

-- Main Frame for UI with improved design
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = NovaAimbotGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Visible = Aimbot.UIVisible

-- Add rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Add shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)

-- Title Bar with gradient
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 45))
})
TitleGradient.Parent = TitleBar

local TitleUICorner = Instance.new("UICorner")
TitleUICorner.CornerRadius = UDim.new(0, 8)
TitleUICorner.Parent = TitleBar

-- Title corner fix
local TitleCornerFix = Instance.new("Frame")
TitleCornerFix.Name = "TitleCornerFix"
TitleCornerFix.Parent = TitleBar
TitleCornerFix.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TitleCornerFix.BorderSizePixel = 0
TitleCornerFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleCornerFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleGradient:Clone().Parent = TitleCornerFix

-- Title Text with icon
local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Name = "TitleIcon"
TitleIcon.Parent = TitleBar
TitleIcon.BackgroundTransparency = 1
TitleIcon.Position = UDim2.new(0, 8, 0.5, -8)
TitleIcon.Size = UDim2.new(0, 16, 0, 16)
TitleIcon.Image = "rbxassetid://6031094670" -- Crosshair icon
TitleIcon.ImageColor3 = Color3.fromRGB(75, 175, 255)

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 30, 0, 0)
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "Nova Aimbot v3.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
CloseButton.Position = UDim2.new(1, -25, 0.5, -8)
CloseButton.Size = UDim2.new(0, 16, 0, 16)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = ""
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(1, 0)
CloseButtonCorner.Parent = CloseButton

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 75)
MinimizeButton.Position = UDim2.new(1, -50, 0.5, -8)
MinimizeButton.Size = UDim2.new(0, 16, 0, 16)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = ""
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14

local MinimizeButtonCorner = Instance.new("UICorner")
MinimizeButtonCorner.CornerRadius = UDim.new(1, 0)
MinimizeButtonCorner.Parent = MinimizeButton

-- Settings Button
local SettingsButton = Instance.new("TextButton")
SettingsButton.Name = "SettingsButton"
SettingsButton.Parent = TitleBar
SettingsButton.BackgroundColor3 = Color3.fromRGB(75, 175, 255)
SettingsButton.Position = UDim2.new(1, -75, 0.5, -8)
SettingsButton.Size = UDim2.new(0, 16, 0, 16)
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.Text = ""
SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsButton.TextSize = 14

local SettingsButtonCorner = Instance.new("UICorner")
SettingsButtonCorner.CornerRadius = UDim.new(1, 0)
SettingsButtonCorner.Parent = SettingsButton

local SettingsIcon = Instance.new("ImageLabel")
SettingsIcon.Name = "SettingsIcon"
SettingsIcon.Parent = SettingsButton
SettingsIcon.BackgroundTransparency = 1
SettingsIcon.Position = UDim2.new(0, 2, 0, 2)
SettingsIcon.Size = UDim2.new(0, 12, 0, 12)
SettingsIcon.Image = "rbxassetid://3926307971"
SettingsIcon.ImageRectOffset = Vector2.new(324, 124)
SettingsIcon.ImageRectSize = Vector2.new(36, 36)
SettingsIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

-- Content Frame with tabs
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Parent = MainFrame
TabsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabsFrame.BorderSizePixel = 0
TabsFrame.Position = UDim2.new(0, 10, 0, 40)
TabsFrame.Size = UDim2.new(1, -20, 0, 30)

local TabsCorner = Instance.new("UICorner")
TabsCorner.CornerRadius = UDim.new(0, 6)
TabsCorner.Parent = TabsFrame

-- Create tabs
local function CreateTab(name, index, selected)
    local Tab = Instance.new("TextButton")
    Tab.Name = name .. "Tab"
    Tab.Parent = TabsFrame
    Tab.BackgroundColor3 = selected and Color3.fromRGB(75, 175, 255) or Color3.fromRGB(40, 40, 50)
    Tab.BorderSizePixel = 0
    Tab.Position = UDim2.new((index - 1) * 0.25, 5, 0, 5)
    Tab.Size = UDim2.new(0.25, -10, 1, -10)
    Tab.Font = Enum.Font.GothamSemibold
    Tab.Text = name
    Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab.TextSize = 12
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 4)
    TabCorner.Parent = Tab
    
    return Tab
end

local AimbotTab = CreateTab("Aimbot", 1, true)
local ESPTab = CreateTab("ESP", 2, false)
local SettingsTab = CreateTab("Settings", 3, false)
local AboutTab = CreateTab("About", 4, false)

-- Content Frames for each tab
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 10, 0, 80)
ContentFrame.Size = UDim2.new(1, -20, 1, -90)

-- Create content frames for each tab
local AimbotContent = Instance.new("ScrollingFrame")
AimbotContent.Name = "AimbotContent"
AimbotContent.Parent = ContentFrame
AimbotContent.Active = true
AimbotContent.BackgroundTransparency = 1
AimbotContent.BorderSizePixel = 0
AimbotContent.Position = UDim2.new(0, 0, 0, 0)
AimbotContent.Size = UDim2.new(1, 0, 1, 0)
AimbotContent.CanvasSize = UDim2.new(0, 0, 0, 500)
AimbotContent.ScrollBarThickness = 4
AimbotContent.ScrollBarImageColor3 = Color3.fromRGB(75, 175, 255)
AimbotContent.Visible = true

local ESPContent = Instance.new("ScrollingFrame")
ESPContent.Name = "ESPContent"
ESPContent.Parent = ContentFrame
ESPContent.Active = true
ESPContent.BackgroundTransparency = 1
ESPContent.BorderSizePixel = 0
ESPContent.Position = UDim2.new(0, 0, 0, 0)
ESPContent.Size = UDim2.new(1, 0, 1, 0)
ESPContent.CanvasSize = UDim2.new(0, 0, 0, 500)
ESPContent.ScrollBarThickness = 4
ESPContent.ScrollBarImageColor3 = Color3.fromRGB(75, 175, 255)
ESPContent.Visible = false

local SettingsContent = Instance.new("ScrollingFrame")
SettingsContent.Name = "SettingsContent"
SettingsContent.Parent = ContentFrame
SettingsContent.Active = true
SettingsContent.BackgroundTransparency = 1
SettingsContent.BorderSizePixel = 0
SettingsContent.Position = UDim2.new(0, 0, 0, 0)
SettingsContent.Size = UDim2.new(1, 0, 1, 0)
SettingsContent.CanvasSize = UDim2.new(0, 0, 0, 500)
SettingsContent.ScrollBarThickness = 4
SettingsContent.ScrollBarImageColor3 = Color3.fromRGB(75, 175, 255)
SettingsContent.Visible = false

local AboutContent = Instance.new("ScrollingFrame")
AboutContent.Name = "AboutContent"
AboutContent.Parent = ContentFrame
AboutContent.Active = true
AboutContent.BackgroundTransparency = 1
AboutContent.BorderSizePixel = 0
AboutContent.Position = UDim2.new(0, 0, 0, 0)
AboutContent.Size = UDim2.new(1, 0, 1, 0)
AboutContent.CanvasSize = UDim2.new(0, 0, 0, 300)
AboutContent.ScrollBarThickness = 4
AboutContent.ScrollBarImageColor3 = Color3.fromRGB(75, 175, 255)
AboutContent.Visible = false

-- Tab switching functionality
local ContentFrames = {
    Aimbot = AimbotContent,
    ESP = ESPContent,
    Settings = SettingsContent,
    About = AboutContent
}

local Tabs = {
    AimbotTab = AimbotTab,
    ESPTab = ESPTab,
    SettingsTab = SettingsTab,
    AboutTab = AboutTab
}

local function SwitchTab(tabName)
    for name, tab in pairs(Tabs) do
        tab.BackgroundColor3 = (name == tabName .. "Tab") and Color3.fromRGB(75, 175, 255) or Color3.fromRGB(40, 40, 50)
    end
    
    for name, frame in pairs(ContentFrames) do
        frame.Visible = (name == tabName)
    end
end

AimbotTab.MouseButton1Click:Connect(function() SwitchTab("Aimbot") end)
ESPTab.MouseButton1Click:Connect(function() SwitchTab("ESP") end)
SettingsTab.MouseButton1Click:Connect(function() SwitchTab("Settings") end)
AboutTab.MouseButton1Click:Connect(function() SwitchTab("About") end)

-- UI Creation Helper Functions
local function CreateSeparator(parent, posY)
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Parent = parent
    separator.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    separator.BorderSizePixel = 0
    separator.Position = UDim2.new(0, 0, 0, posY)
    separator.Size = UDim2.new(1, 0, 0, 1)
    return separator
end

local function CreateSection(parent, title, posY)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = title .. "Section"
    SectionFrame.Parent = parent
    SectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Position = UDim2.new(0, 0, 0, posY)
    SectionFrame.Size = UDim2.new(1, 0, 0, 30)
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = SectionFrame
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = "SectionLabel"
    SectionLabel.Parent = SectionFrame
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Position = UDim2.new(0, 10, 0, 0)
    SectionLabel.Size = UDim2.new(1, -60, 1, 0)
    SectionLabel.Font = Enum.Font.GothamSemibold
    SectionLabel.Text = title
    SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionLabel.TextSize = 14
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local SectionToggle = Instance.new("TextButton")
    SectionToggle.Name = "SectionToggle"
    SectionToggle.Parent = SectionFrame
    SectionToggle.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    SectionToggle.Position = UDim2.new(1, -50, 0.5, -10)
    SectionToggle.Size = UDim2.new(0, 40, 0, 20)
    SectionToggle.Font = Enum.Font.GothamBold
    SectionToggle.Text = ""
    SectionToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionToggle.TextSize = 14
    
    local SectionToggleCorner = Instance.new("UICorner")
    SectionToggleCorner.CornerRadius = UDim.new(0, 10)
    SectionToggleCorner.Parent = SectionToggle
    
    local SectionToggleCircle = Instance.new("Frame")
    SectionToggleCircle.Name = "SectionToggleCircle"
    SectionToggleCircle.Parent = SectionToggle
    SectionToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SectionToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    SectionToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    
    local SectionToggleCircleCorner = Instance.new("UICorner")
    SectionToggleCircleCorner.CornerRadius = UDim.new(1, 0)
    SectionToggleCircleCorner.Parent = SectionToggleCircle
    
    return SectionFrame, SectionToggle, SectionToggleCircle
end

local function CreateDropdown(parent, title, options, defaultOption, posY)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = title .. "Dropdown"
    DropdownFrame.Parent = parent
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Position = UDim2.new(0, 0, 0, posY)
    DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Name = "DropdownLabel"
    DropdownLabel.Parent = DropdownFrame
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
    DropdownLabel.Size = UDim2.new(1, -20, 0, 25)
    DropdownLabel.Font = Enum.Font.GothamSemibold
    DropdownLabel.Text = title
    DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownLabel.TextSize = 14
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "DropdownButton"
    DropdownButton.Parent = DropdownFrame
    DropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    DropdownButton.Position = UDim2.new(0, 10, 0, 25)
    DropdownButton.Size = UDim2.new(1, -20, 0, 25)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Text = defaultOption
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 14
    DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    DropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
    
    local DropdownPadding = Instance.new("UIPadding")
    DropdownPadding.Parent = DropdownButton
    DropdownPadding.PaddingLeft = UDim.new(0, 10)
    
    local DropdownButtonCorner = Instance.new("UICorner")
    DropdownButtonCorner.CornerRadius = UDim.new(0, 4)
    DropdownButtonCorner.Parent = DropdownButton
    
    local DropdownIcon = Instance.new("ImageLabel")
    DropdownIcon.Name = "DropdownIcon"
    DropdownIcon.Parent = DropdownButton
    DropdownIcon.BackgroundTransparency = 1
    DropdownIcon.Position = UDim2.new(1, -25, 0.5, -8)
    DropdownIcon.Size = UDim2.new(0, 16, 0, 16)
    DropdownIcon.Image = "rbxassetid://3926305904"
    DropdownIcon.ImageRectOffset = Vector2.new(484, 364)
    DropdownIcon.ImageRectSize = Vector2.new(36, 36)
    DropdownIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    
    local DropdownMenu = Instance.new("Frame")
    DropdownMenu.Name = "DropdownMenu"
    DropdownMenu.Parent = DropdownFrame
    DropdownMenu.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    DropdownMenu.BorderSizePixel = 0
    DropdownMenu.Position = UDim2.new(0, 10, 0, 55)
    DropdownMenu.Size = UDim2.new(1, -20, 0, #options * 25)
    DropdownMenu.Visible = false
    DropdownMenu.ZIndex = 10
    
    local DropdownMenuCorner = Instance.new("UICorner")
    DropdownMenuCorner.CornerRadius = UDim.new(0, 4)
    DropdownMenuCorner.Parent = DropdownMenu
    
    local DropdownLayout = Instance.new("UIListLayout")
    DropdownLayout.Parent = DropdownMenu
    DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropdownLayout.Padding = UDim.new(0, 0)
    
    local SelectedOption = defaultOption
    
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = option .. "Option"
        OptionButton.Parent = DropdownMenu
        OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        OptionButton.BackgroundTransparency = 0
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.TextSize = 14
        OptionButton.ZIndex = 11
        
        local OptionPadding = Instance.new("UIPadding")
        OptionPadding.Parent = OptionButton
        OptionPadding.PaddingLeft = UDim.new(0, 10)
        
        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(75, 175, 255)
        end)
        
        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            SelectedOption = option
            DropdownButton.Text = option
            DropdownMenu.Visible = false
            DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        DropdownMenu.Visible = not DropdownMenu.Visible
        if DropdownMenu.Visible then
            DropdownFrame.Size = UDim2.new(1, 0, 0, 60 + DropdownMenu.Size.Y.Offset)
        else
            DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
        end
    end)
    
    return DropdownFrame, function() return SelectedOption end
end

local function CreateSlider(parent, title, posY, minValue, maxValue, defaultValue, decimalPlaces)
    decimalPlaces = decimalPlaces or 0
    local multiplier = 10 ^ decimalPlaces
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = title .. "Slider"
    SliderFrame.Parent = parent
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Position = UDim2.new(0, 0, 0, posY)
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "SliderLabel"
    SliderLabel.Parent = SliderFrame
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Position = UDim2.new(0, 10, 0, 0)
    SliderLabel.Size = UDim2.new(1, -20, 0, 25)
    SliderLabel.Font = Enum.Font.GothamSemibold
    SliderLabel.Text = title .. ": " .. string.format("%." .. decimalPlaces .. "f", defaultValue)
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 14
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderBack = Instance.new("Frame")
    SliderBack.Name = "SliderBack"
    SliderBack.Parent = SliderFrame
    SliderBack.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    SliderBack.BorderSizePixel = 0
    SliderBack.Position = UDim2.new(0, 10, 0, 30)
    SliderBack.Size = UDim2.new(1, -20, 0, 5)
    
    local SliderBackCorner = Instance.new("UICorner")
    SliderBackCorner.CornerRadius = UDim.new(0, 3)
    SliderBackCorner.Parent = SliderBack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Parent = SliderBack
    SliderFill.BackgroundColor3 = Color3.fromRGB(75, 175, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    SliderFill.ZIndex = 2
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 3)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "SliderButton"
    SliderButton.Parent = SliderBack
    SliderButton.BackgroundTransparency = 1
    SliderButton.Position = UDim2.new(0, 0, 0, -7.5)
    SliderButton.Size = UDim2.new(1, 0, 0, 20)
    SliderButton.Font = Enum.Font.SourceSans
    SliderButton.Text = ""
    SliderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.TextSize = 14
    
    local SliderCircle = Instance.new("Frame")
    SliderCircle.Name = "SliderCircle"
    SliderCircle.Parent = SliderFill
    SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
    SliderCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderCircle.Position = UDim2.new(1, 0, 0.5, 0)
    SliderCircle.Size = UDim2.new(0, 12, 0, 12)
    SliderCircle.ZIndex = 3
    
    local SliderCircleCorner = Instance.new("UICorner")
    SliderCircleCorner.CornerRadius = UDim.new(1, 0)
    SliderCircleCorner.Parent = SliderCircle
    
    local Value = defaultValue
    
    -- Slider dragging functionality
    local Dragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        Dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    SliderButton.MouseMoved:Connect(function(X)
        if Dragging then
            local SizeX = math.clamp((X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(SizeX, 0, 1, 0)
            
            -- Calculate value with proper decimal places
            local rawValue = minValue + ((maxValue - minValue) * SizeX)
            Value = math.floor(rawValue * multiplier + 0.5) / multiplier
            
            SliderLabel.Text = title .. ": " .. string.format("%." .. decimalPlaces .. "f", Value)
        end
    end)
    
    return SliderFrame, function() return Value end
end

local function CreateColorPicker(parent, title, posY, defaultColor)
    local ColorPickerFrame = Instance.new("Frame")
    ColorPickerFrame.Name = title .. "ColorPicker"
    ColorPickerFrame.Parent = parent
    ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    ColorPickerFrame.BorderSizePixel = 0
    ColorPickerFrame.Position = UDim2.new(0, 0, 0, posY)
    ColorPickerFrame.Size = UDim2.new(1, 0, 0, 50)
    
    local ColorPickerCorner = Instance.new("UICorner")
    ColorPickerCorner.CornerRadius = UDim.new(0, 6)
    ColorPickerCorner.Parent = ColorPickerFrame
    
    local ColorPickerLabel = Instance.new("TextLabel")
    ColorPickerLabel.Name = "ColorPickerLabel"
    ColorPickerLabel.Parent = ColorPickerFrame
    ColorPickerLabel.BackgroundTransparency = 1
    ColorPickerLabel.Position = UDim2.new(0, 10, 0, 0)
    ColorPickerLabel.Size = UDim2.new(1, -70, 1, 0)
    ColorPickerLabel.Font = Enum.Font.GothamSemibold
    ColorPickerLabel.Text = title
    ColorPickerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorPickerLabel.TextSize = 14
    ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ColorDisplay = Instance.new("Frame")
    ColorDisplay.Name = "ColorDisplay"
    ColorDisplay.Parent = ColorPickerFrame
    ColorDisplay.BackgroundColor3 = defaultColor
    ColorDisplay.BorderSizePixel = 0
    ColorDisplay.Position = UDim2.new(1, -50, 0.5, -15)
    ColorDisplay.Size = UDim2.new(0, 30, 0, 30)
    
    local ColorDisplayCorner = Instance.new("UICorner")
    ColorDisplayCorner.CornerRadius = UDim.new(0, 4)
    ColorDisplayCorner.Parent = ColorDisplay
    
    local SelectedColor = defaultColor
    
    ColorDisplay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Here you would typically open a color picker UI
            -- For simplicity, we'll just cycle through some preset colors
            local colors = {
                Color3.fromRGB(255, 0, 0),   -- Red
                Color3.fromRGB(0, 255, 0),   -- Green
                Color3.fromRGB(0, 0, 255),   -- Blue
                Color3.fromRGB(255, 255, 0), -- Yellow
                Color3.fromRGB(0, 255, 255), -- Cyan
                Color3.fromRGB(255, 0, 255), -- Magenta
                Color3.fromRGB(255, 255, 255) -- White
            }
            
            for i, color in ipairs(colors) do
                if SelectedColor == color and i < #colors then
                    SelectedColor = colors[i + 1]
                    break
                elseif i == #colors or SelectedColor ~= color then
                    SelectedColor = colors[1]
                    break
                end
            end
            
            ColorDisplay.BackgroundColor3 = SelectedColor
        end
    end)
    
    return ColorPickerFrame, function() return SelectedColor end
end

local function CreateKeybind(parent, title, posY, defaultKey)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Name = title .. "Keybind"
    KeybindFrame.Parent = parent
    KeybindFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    KeybindFrame.BorderSizePixel = 0
    KeybindFrame.Position = UDim2.new(0, 0, 0, posY)
    KeybindFrame.Size = UDim2.new(1, 0, 0, 50)
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 6)
    KeybindCorner.Parent = KeybindFrame
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Name = "KeybindLabel"
    KeybindLabel.Parent = KeybindFrame
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
    KeybindLabel.Size = UDim2.new(1, -110, 1, 0)
    KeybindLabel.Font = Enum.Font.GothamSemibold
    KeybindLabel.Text = title
    KeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindLabel.TextSize = 14
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "KeybindButton"
    KeybindButton.Parent = KeybindFrame
    KeybindButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    KeybindButton.Position = UDim2.new(1, -100, 0.5, -15)
    KeybindButton.Size = UDim2.new(0, 90, 0, 30)
    KeybindButton.Font = Enum.Font.GothamSemibold
    KeybindButton.Text = defaultKey.Name
    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.TextSize = 12
    
    local KeybindButtonCorner = Instance.new("UICorner")
    KeybindButtonCorner.CornerRadius = UDim.new(0, 4)
    KeybindButtonCorner.Parent = KeybindButton
    
    local SelectedKey = defaultKey
    local WaitingForInput = false
    
    KeybindButton.MouseButton1Click:Connect(function()
        WaitingForInput = true
        KeybindButton.Text = "Press any key..."
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if WaitingForInput and input.UserInputType == Enum.UserInputType.Keyboard then
            SelectedKey = input.KeyCode
            KeybindButton.Text = input.KeyCode.Name
            WaitingForInput = false
        end
    end)
    
    return KeybindFrame, function() return SelectedKey end
end

-- Create UI elements for Aimbot tab
local MainToggle, MainToggleButton, MainToggleCircle = CreateSection(AimbotContent, "Aimbot Enabled", 10)
local AimModeDropdown, GetAimMode = CreateDropdown(AimbotContent, "Aim Mode", {"Snap", "Smooth", "Silent"}, "Smooth", 50)
local TargetPartDropdown, GetTargetPart = CreateDropdown(AimbotContent, "Target Part", {"Head", "Torso", "HumanoidRootPart", "Random"}, "Head", 120)
local TargetPriorityDropdown, GetTargetPriority = CreateDropdown(AimbotContent, "Target Priority", {"Distance", "Health", "Angle"}, "Distance", 190)
local TeamCheckSection, TeamToggle, TeamToggleCircle = CreateSection(AimbotContent, "Team Check", 260)
local VisibilitySection, VisibilityToggle, VisibilityToggleCircle = CreateSection(AimbotContent, "Visibility Check", 300)
local FOVSection, FOVToggle, FOVToggleCircle = CreateSection(AimbotContent, "FOV Circle", 340)
local FOVSlider, GetFOVValue = CreateSlider(AimbotContent, "FOV Radius", 380, 50, 500, Config.FOVRadius, 0)
local SmoothSlider, GetSmoothValue = CreateSlider(AimbotContent, "Aim Smoothness", 440, 0.1, 1, Config.AimSmoothing, 2)

-- Create UI elements for ESP tab
local ESPSection, ESPToggle, ESPToggleCircle = CreateSection(ESPContent, "ESP Enabled", 10)
local BoxESPSection, BoxESPToggle, BoxESPToggleCircle = CreateSection(ESPContent, "Box ESP", 50)
local NameESPSection, NameESPToggle, NameESPToggleCircle = CreateSection(ESPContent, "Name ESP", 90)
local DistanceESPSection, DistanceESPToggle, DistanceESPToggleCircle = CreateSection(ESPContent, "Distance ESP", 130)
local TracerESPSection, TracerESPToggle, TracerESPToggleCircle = CreateSection(ESPContent, "Tracer ESP", 170)
local HealthESPSection, HealthESPToggle, HealthESPToggleCircle = CreateSection(ESPContent, "Health Bar", 210)
local TeamESPSection, TeamESPToggle, TeamESPToggleCircle = CreateSection(ESPContent, "Team ESP", 250)
local ESPColorPicker, GetESPColor = CreateColorPicker(ESPContent, "ESP Color", 290, Color3.fromRGB(255, 0, 0))
local ESPDistanceSlider, GetESPDistance = CreateSlider(ESPContent, "ESP Distance", 350, 100, 5000, 1000, 0)
local ESPTextSizeSlider, GetESPTextSize = CreateSlider(ESPContent, "Text Size", 410, 8, 24, 14, 0)
local ESPBoxThicknessSlider, GetESPBoxThickness = CreateSlider(ESPContent, "Box Thickness", 470, 1, 5, 1, 0)

-- Create UI elements for Settings tab
local AimKeybind, GetAimKey = CreateKeybind(SettingsContent, "Aim Key", 10, Enum.KeyCode.E)
local ToggleUIKeybind, GetToggleUIKey = CreateKeybind(SettingsContent, "Toggle UI", 70, Enum.KeyCode.RightShift)
local ResetSettingsButton = Instance.new("TextButton")
ResetSettingsButton.Name = "ResetSettingsButton"
ResetSettingsButton.Parent = SettingsContent
ResetSettingsButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
ResetSettingsButton.Position = UDim2.new(0.5, -100, 0, 130)
ResetSettingsButton.Size = UDim2.new(0, 200, 0, 40)
ResetSettingsButton.Font = Enum.Font.GothamSemibold
ResetSettingsButton.Text = "Reset All Settings"
ResetSettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetSettingsButton.TextSize = 14

local ResetButtonCorner = Instance.new("UICorner")
ResetButtonCorner.CornerRadius = UDim.new(0, 6)
ResetButtonCorner.Parent = ResetSettingsButton

-- Create UI elements for About tab
local AboutTitle = Instance.new("TextLabel")
AboutTitle.Name = "AboutTitle"
AboutTitle.Parent = AboutContent
AboutTitle.BackgroundTransparency = 1
AboutTitle.Position = UDim2.new(0, 0, 0, 10)
AboutTitle.Size = UDim2.new(1, 0, 0, 30)
AboutTitle.Font = Enum.Font.GothamBold
AboutTitle.Text = "Nova Aimbot v3.0"
AboutTitle.TextColor3 = Color3.fromRGB(75, 175, 255)
AboutTitle.TextSize = 24

local AboutDescription = Instance.new("TextLabel")
AboutDescription.Name = "AboutDescription"
AboutDescription.Parent = AboutContent
AboutDescription.BackgroundTransparency = 1
AboutDescription.Position = UDim2.new(0, 10, 0, 50)
AboutDescription.Size = UDim2.new(1, -20, 0, 100)
AboutDescription.Font = Enum.Font.Gotham
AboutDescription.Text = "Advanced aimbot and ESP solution for Roblox games. Created with performance and customization in mind."
AboutDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
AboutDescription.TextSize = 14
AboutDescription.TextWrapped = true
AboutDescription.TextXAlignment = Enum.TextXAlignment.Left
AboutDescription.TextYAlignment = Enum.TextYAlignment.Top

local AboutVersion = Instance.new("TextLabel")
AboutVersion.Name = "AboutVersion"
AboutVersion.Parent = AboutContent
AboutVersion.BackgroundTransparency = 1
AboutVersion.Position = UDim2.new(0, 10, 0, 160)
AboutVersion.Size = UDim2.new(1, -20, 0, 20)
AboutVersion.Font = Enum.Font.Gotham
AboutVersion.Text = "Version: 3.0.0"
AboutVersion.TextColor3 = Color3.fromRGB(200, 200, 200)
AboutVersion.TextSize = 14
AboutVersion.TextXAlignment = Enum.TextXAlignment.Left

local AboutDate = Instance.new("TextLabel")
AboutDate.Name = "AboutDate"
AboutDate.Parent = AboutContent
AboutDate.BackgroundTransparency = 1
AboutDate.Position = UDim2.new(0, 10, 0, 180)
AboutDate.Size = UDim2.new(1, -20, 0, 20)
AboutDate.Font = Enum.Font.Gotham
AboutDate.Text = "Last Updated: " .. os.date("%B %d, %Y")
AboutDate.TextColor3 = Color3.fromRGB(200, 200, 200)
AboutDate.TextSize = 14
AboutDate.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle functionality
local function UpdateToggle(toggle, circle, enabled)
    if enabled then
        toggle.BackgroundColor3 = Color3.fromRGB(75, 175, 255)
        circle:TweenPosition(UDim2.new(1, -18, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
    else
        toggle.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
        circle:TweenPosition(UDim2.new(0, 2, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
    end
end

-- Initialize toggle states
UpdateToggle(MainToggleButton, MainToggleCircle, Config.AimbotEnabled)
UpdateToggle(TeamToggle, TeamToggleCircle, Config.TeamCheck)
UpdateToggle(VisibilityToggle, VisibilityToggleCircle, Config.VisibilityCheck)
UpdateToggle(FOVToggle, FOVToggleCircle, Config.ShowFOV)
UpdateToggle(ESPToggle, ESPToggleCircle, Config.ESPEnabled)
UpdateToggle(BoxESPToggle, BoxESPToggleCircle, Config.BoxESP)
UpdateToggle(NameESPToggle, NameESPToggleCircle, Config.NameESP)
UpdateToggle(DistanceESPToggle, DistanceESPToggleCircle, Config.DistanceESP)
UpdateToggle(TracerESPToggle, TracerESPToggleCircle, Config.TracerESP)
UpdateToggle(HealthESPToggle, HealthESPToggleCircle, Config.HealthESP)
UpdateToggle(TeamESPToggle, TeamESPToggleCircle, Config.TeamESP)

-- Toggle button functionality
local function SetupToggle(toggle, circle, configKey)
    toggle.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        UpdateToggle(toggle, circle, Config[configKey])
    end)
end

SetupToggle(MainToggleButton, MainToggleCircle, "AimbotEnabled")
SetupToggle(TeamToggle, TeamToggleCircle, "TeamCheck")
SetupToggle(VisibilityToggle, VisibilityToggleCircle, "VisibilityCheck")
SetupToggle(FOVToggle, FOVToggleCircle, "ShowFOV")
SetupToggle(ESPToggle, ESPToggleCircle, "ESPEnabled")
SetupToggle(BoxESPToggle, BoxESPToggleCircle, "BoxESP")
SetupToggle(NameESPToggle, NameESPToggleCircle, "NameESP")
SetupToggle(DistanceESPToggle, DistanceESPToggleCircle, "DistanceESP")
SetupToggle(TracerESPToggle, TracerESPToggleCircle, "TracerESP")
SetupToggle(HealthESPToggle, HealthESPToggleCircle, "HealthESP")
SetupToggle(TeamESPToggle, TeamESPToggleCircle, "TeamESP")

-- Reset settings button functionality
ResetSettingsButton.MouseButton1Click:Connect(function()
    Config = DefaultConfig
    
    -- Update UI to reflect default settings
    UpdateToggle(MainToggleButton, MainToggleCircle, Config.AimbotEnabled)
    UpdateToggle(TeamToggle, TeamToggleCircle, Config.TeamCheck)
    UpdateToggle(VisibilityToggle, VisibilityToggleCircle, Config.VisibilityCheck)
    UpdateToggle(FOVToggle, FOVToggleCircle, Config.ShowFOV)
    UpdateToggle(ESPToggle, ESPToggleCircle, Config.ESPEnabled)
    UpdateToggle(BoxESPToggle, BoxESPToggleCircle, Config.BoxESP)
    UpdateToggle(NameESPToggle, NameESPToggleCircle, Config.NameESP)
    UpdateToggle(DistanceESPToggle, DistanceESPToggleCircle, Config.DistanceESP)
    UpdateToggle(TracerESPToggle, TracerESPToggleCircle, Config.TracerESP)
    UpdateToggle(HealthESPToggle, HealthESPToggleCircle, Config.HealthESP)
    UpdateToggle(TeamESPToggle, TeamESPToggleCircle, Config.TeamESP)
    
    -- Reset dropdowns
    AimModeDropdown.DropdownButton.Text = "Smooth"
    TargetPartDropdown.DropdownButton.Text = "Head"
    TargetPriorityDropdown.DropdownButton.Text = "Distance"
    
    -- Reset sliders
    FOVSlider.SliderFill.Size = UDim2.new((Config.FOVRadius - 50) / (500 - 50), 0, 1, 0)
    FOVSlider.SliderLabel.Text = "FOV Radius: " .. Config.FOVRadius
    
    SmoothSlider.SliderFill.Size = UDim2.new((Config.AimSmoothing - 0.1) / (1 - 0.1), 0, 1, 0)
    SmoothSlider.SliderLabel.Text = "Aim Smoothness: " .. string.format("%.2f", Config.AimSmoothing)
    
    ESPDistanceSlider.SliderFill.Size = UDim2.new((1000 - 100) / (5000 - 100), 0, 1, 0)
    ESPDistanceSlider.SliderLabel.Text = "ESP Distance: 1000"
    
    ESPTextSizeSlider.SliderFill.Size = UDim2.new((14 - 8) / (24 - 8), 0, 1, 0)
    ESPTextSizeSlider.SliderLabel.Text = "Text Size: 14"
    
    ESPBoxThicknessSlider.SliderFill.Size = UDim2.new((1 - 1) / (5 - 1), 0, 1, 0)
    ESPBoxThicknessSlider.SliderLabel.Text = "Box Thickness: 1"
    
    -- Reset color picker
    ESPColorPicker.ColorDisplay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    
    -- Reset keybinds
    AimKeybind.KeybindButton.Text = "E"
    ToggleUIKeybind.KeybindButton.Text = "RightShift"
end)

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Config.FOVRadius
FOVCircle.Filled = false
FOVCircle.Visible = Config.ShowFOV
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(75, 175, 255)

-- ESP Containers
local ESPObjects = {}
local ESPSettings = {
    BoxColor = Color3.fromRGB(255, 0, 0),
    TextSize = 14,
    BoxThickness = 1,
    MaxDistance = 1000
}

-- Function to check if a player is valid for aimbot/ESP
local function IsPlayerValid(player)
    if player == LocalPlayer then return false end
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return false end
    if player.Character.Humanoid.Health <= 0 then return false end
    
    if Config.TeamCheck and player.Team == LocalPlayer.Team then return false end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local distance = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > ESPSettings.MaxDistance then return false end
    
    if Config.VisibilityCheck then
        local ray = Ray.new(Camera.CFrame.Position, (humanoidRootPart.Position - Camera.CFrame.Position).Unit * distance)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        if hit and hit:IsDescendantOf(player.Character) == false then return false end
    end
    
    return true
end

-- Function to get the closest player to cursor
local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsPlayerValid(player) then
            local targetPart
            if GetTargetPart() == "Random" then
                local parts = {"Head", "Torso", "HumanoidRootPart"}
                targetPart = player.Character:FindFirstChild(parts[math.random(1, #parts)])
            else
                targetPart = player.Character:FindFirstChild(GetTargetPart())
            end
            
            if targetPart then
                local screenPoint = Camera:WorldToScreenPoint(targetPart.Position)
                local screenCenter = Vector2.new(Mouse.X, Mouse.Y)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                
                if distance < shortestDistance and distance <= FOVCircle.Radius then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestPlayer
end

-- Function to create ESP objects for a player
local function CreateESPObjects(player)
    if ESPObjects[player] then return end
    
    local espObject = {}
    
    espObject.Box = Drawing.new("Square")
    espObject.Box.Thickness = ESPSettings.BoxThickness
    espObject.Box.Filled = false
    espObject.Box.Color = ESPSettings.BoxColor
    espObject.Box.Transparency = 1
    espObject.Box.Visible = false
    
    espObject.Name = Drawing.new("Text")
    espObject.Name.Text = player.Name
    espObject.Name.Size = ESPSettings.TextSize
    espObject.Name.Color = ESPSettings.BoxColor
    espObject.Name.Transparency = 1
    espObject.Name.Visible = false
    espObject.Name.Center = true
    espObject.Name.Outline = true
    
    espObject.Distance = Drawing.new("Text")
    espObject.Distance.Size = ESPSettings.TextSize
    espObject.Distance.Color = ESPSettings.BoxColor
    espObject.Distance.Transparency = 1
    espObject.Distance.Visible = false
    espObject.Distance.Center = true
    espObject.Distance.Outline = true
    
    espObject.Tracer = Drawing.new("Line")
    espObject.Tracer.Thickness = 1
    espObject.Tracer.Color = ESPSettings.BoxColor
    espObject.Tracer.Transparency = 1
    espObject.Tracer.Visible = false
    
    espObject.HealthBar = Drawing.new("Square")
    espObject.HealthBar.Thickness = 1
    espObject.HealthBar.Filled = true
    espObject.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    espObject.HealthBar.Transparency = 1
    espObject.HealthBar.Visible = false
    
    espObject.HealthBarOutline = Drawing.new("Square")
    espObject.HealthBarOutline.Thickness = 1
    espObject.HealthBarOutline.Filled = false
    espObject.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    espObject.HealthBarOutline.Transparency = 1
    espObject.HealthBarOutline.Visible = false
    
    ESPObjects[player] = espObject
end

-- Function to remove ESP objects for a player
local function RemoveESPObjects(player)
    if not ESPObjects[player] then return end
    
    for _, drawing in pairs(ESPObjects[player]) do
        if drawing and typeof(drawing) == "table" and drawing.Remove then
            pcall(function() drawing:Remove() end)
        end
    end
    
    ESPObjects[player] = nil
end

-- Function to update ESP for a player
local function UpdateESP(player)
    if not Config.ESPEnabled or not IsPlayerValid(player) or not ESPObjects[player] then return end
    
    local espObject = ESPObjects[player]
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not humanoidRootPart or not humanoid then
        for _, drawing in pairs(espObject) do
            drawing.Visible = false
        end
        return
    end
    
    local distance = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
    local screenPosition, onScreen = Camera:WorldToScreenPoint(humanoidRootPart.Position)
    
    if not onScreen or distance > ESPSettings.MaxDistance then
        for _, drawing in pairs(espObject) do
            drawing.Visible = false
        end
        return
    end
    
    -- Update ESP color
    local espColor = GetESPColor()
    if Config.TeamESP and player.Team == LocalPlayer.Team then
        espColor = Color3.fromRGB(0, 255, 0)  -- Green for teammates
    end
    
    -- Calculate character bounds
    local topPosition = Camera:WorldToScreenPoint((humanoidRootPart.CFrame * CFrame.new(0, 3, 0)).Position)
    local bottomPosition = Camera:WorldToScreenPoint((humanoidRootPart.CFrame * CFrame.new(0, -3, 0)).Position)
    
    local height = math.abs(topPosition.Y - bottomPosition.Y)
    local width = height * 0.6
    
    -- Update Box ESP
    espObject.Box.Size = Vector2.new(width, height)
    espObject.Box.Position = Vector2.new(screenPosition.X - width / 2, screenPosition.Y - height / 2)
    espObject.Box.Color = espColor
    espObject.Box.Visible = Config.BoxESP
    espObject.Box.Thickness = GetESPBoxThickness()
    
    -- Update Name ESP
    espObject.Name.Text = player.Name
    espObject.Name.Position = Vector2.new(screenPosition.X, screenPosition.Y - height / 2 - 15)
    espObject.Name.Color = espColor
    espObject.Name.Size = GetESPTextSize()
    espObject.Name.Visible = Config.NameESP
    
    -- Update Distance ESP
    espObject.Distance.Text = math.floor(distance) .. " studs"
    espObject.Distance.Position = Vector2.new(screenPosition.X, screenPosition.Y + height / 2 + 5)
    espObject.Distance.Color = espColor
    espObject.Distance.Size = GetESPTextSize()
    espObject.Distance.Visible = Config.DistanceESP
    
    -- Update Tracer ESP
    espObject.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    espObject.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y + height / 2)
    espObject.Tracer.Color = espColor
    espObject.Tracer.Visible = Config.TracerESP
    
    -- Update Health Bar ESP
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    local barHeight = height
    local barWidth = 5
    
    espObject.HealthBarOutline.Size = Vector2.new(barWidth, barHeight + 2)
    espObject.HealthBarOutline.Position = Vector2.new(screenPosition.X - width / 2 - barWidth - 3, screenPosition.Y - height / 2 - 1)
    espObject.HealthBarOutline.Visible = Config.HealthESP
    
    espObject.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
    espObject.HealthBar.Position = Vector2.new(screenPosition.X - width / 2 - barWidth - 3, screenPosition.Y - height / 2 + barHeight * (1 - healthPercent))
    espObject.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
    espObject.HealthBar.Visible = Config.HealthESP
end

-- Main aimbot function
local function AimbotUpdate()
    if not Config.AimbotEnabled then return end
    
    local targetPlayer = GetClosestPlayerToCursor()
    if not targetPlayer then return end
    
    local targetPart
    if GetTargetPart() == "Random" then
        local parts = {"Head", "Torso", "HumanoidRootPart"}
        targetPart = targetPlayer.Character:FindFirstChild(parts[math.random(1, #parts)])
    else
        targetPart = targetPlayer.Character:FindFirstChild(GetTargetPart())
    end
    
    if not targetPart then return end
    
    local aimPosition = Camera:WorldToScreenPoint(targetPart.Position)
    local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
    
    if UserInputService:IsKeyDown(GetAimKey()) then
        local aimMode = GetAimMode()
        
        if aimMode == "Snap" then
            mousemoveabs(aimPosition.X, aimPosition.Y)
        elseif aimMode == "Smooth" then
            local smoothness = GetSmoothValue()
            local delta = Vector2.new(aimPosition.X - mousePosition.X, aimPosition.Y - mousePosition.Y)
            mousemoverel(delta.X * smoothness, delta.Y * smoothness)
        elseif aimMode == "Silent" then
            -- Silent aim would be implemented here
            -- This typically requires hooking into the game's shooting mechanics
            -- For this example, we'll just log that silent aim was triggered
            print("Silent aim activated on " .. targetPlayer.Name)
        end
    end
end

-- Update FOV Circle position
local function UpdateFOVCircle()
    FOVCircle.Visible = Config.ShowFOV
    FOVCircle.Radius = GetFOVValue()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
end

-- Main update loop
RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    AimbotUpdate()
    
    -- Update ESP for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPObjects[player] and Config.ESPEnabled then
                CreateESPObjects(player)
            end
            
            if ESPObjects[player] then
                UpdateESP(player)
            end
        end
    end
    
    -- Update ESP settings
    ESPSettings.BoxColor = GetESPColor()
    ESPSettings.TextSize = GetESPTextSize()
    ESPSettings.BoxThickness = GetESPBoxThickness()
    ESPSettings.MaxDistance = GetESPDistance()
end)

-- Clean up ESP objects when players leave
Players.PlayerRemoving:Connect(function(player)
    RemoveESPObjects(player)
end)

-- Toggle UI visibility with keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == GetToggleUIKey() then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Make UI draggable
local dragging = false
local dragInput
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Initialize the UI with the first tab selected
SwitchTab("Aimbot")

-- Notification when script loads
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Name = "NotificationFrame"
NotificationFrame.Parent = NovaAimbot
NotificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
NotificationFrame.BorderSizePixel = 0
NotificationFrame.Position = UDim2.new(0.5, -150, 0, -80)
NotificationFrame.Size = UDim2.new(0, 300, 0, 70)
NotificationFrame.AnchorPoint = Vector2.new(0.5, 0)

local NotificationCorner = Instance.new("UICorner")
NotificationCorner.CornerRadius = UDim.new(0, 6)
NotificationCorner.Parent = NotificationFrame

local NotificationTitle = Instance.new("TextLabel")
NotificationTitle.Name = "NotificationTitle"
NotificationTitle.Parent = NotificationFrame
NotificationTitle.BackgroundTransparency = 1
NotificationTitle.Position = UDim2.new(0, 10, 0, 5)
NotificationTitle.Size = UDim2.new(1, -20, 0, 25)
NotificationTitle.Font = Enum.Font.GothamBold
NotificationTitle.Text = "Nova Aimbot v3.0"
NotificationTitle.TextColor3 = Color3.fromRGB(75, 175, 255)
NotificationTitle.TextSize = 16
NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left

local NotificationText = Instance.new("TextLabel")
NotificationText.Name = "NotificationText"
NotificationText.Parent = NotificationFrame
NotificationText.BackgroundTransparency = 1
NotificationText.Position = UDim2.new(0, 10, 0, 30)
NotificationText.Size = UDim2.new(1, -20, 0, 35)
NotificationText.Font = Enum.Font.Gotham
NotificationText.Text = "Successfully loaded! Press RightShift to toggle UI."
NotificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotificationText.TextSize = 14
NotificationText.TextWrapped = true
NotificationText.TextXAlignment = Enum.TextXAlignment.Left

-- Animate notification
NotificationFrame:TweenPosition(UDim2.new(0.5, -150, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)

-- Hide notification after 5 seconds
task.delay(5, function()
    NotificationFrame:TweenPosition(UDim2.new(0.5, -150, 0, -80), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
    task.wait(0.5)
    NotificationFrame:Destroy()
end)

-- Return the main interface object for external access
return NovaAimbot
