-- Place this script in a LocalScript under the StarterGui or any GUI object.

-- Create the main GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Name = "CoolReactiveGui"

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  -- Dark background
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true

-- Add Gradient Effect
local gradient = Instance.new("UIGradient")
gradient.Parent = mainFrame
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255)),
})
gradient.Rotation = 45

-- Add Border Effect
local uiStroke = Instance.new("UIStroke")
uiStroke.Parent = mainFrame
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Thickness = 2
uiStroke.Transparency = 0.5

-- TextButton (Interactive button)
local button = Instance.new("TextButton")
button.Parent = mainFrame
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.Text = "Click Me!"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 24
button.BackgroundColor3 = Color3.fromRGB(0, 123, 255)  -- Bright blue background
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBold
button.TextTransparency = 0.2

-- Button Hover Effects (Visual Feedback)
button.MouseEnter:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)  -- Darker blue when hovering
    button.TextSize = 26  -- Increase text size on hover
    button.TextTransparency = 0  -- Fully visible text
    -- Animation (Scaling effect)
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local goal = {Size = UDim2.new(0, 220, 0, 60)}  -- Slightly larger size
    local tween = tweenService:Create(button, tweenInfo, goal)
    tween:Play()
end)

button.MouseLeave:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(0, 123, 255)  -- Reset to original color
    button.TextSize = 24  -- Reset text size
    button.TextTransparency = 0.2  -- Slightly transparent text
    -- Reset Scale animation
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    local goal = {Size = UDim2.new(0, 200, 0, 50)}  -- Original size
    local tween = tweenService:Create(button, tweenInfo, goal)
    tween:Play()
end)

-- Button Click Effects (Action on Click)
button.MouseButton1Click:Connect(function()
    local buttonText = "Thank You!"
    button.Text = buttonText
    button.TextSize = 20  -- Slightly smaller text when clicked
    button.BackgroundColor3 = Color3.fromRGB(40, 167, 69)  -- Success green background

    -- Animation after clicking
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
    local goal = {Size = UDim2.new(0, 240, 0, 70)}  -- Bigger size on click
    local tween = tweenService:Create(button, tweenInfo, goal)
    tween:Play()

    -- Reset button after a short delay
    wait(2)
    button.Text = "Click Me!"
    button.TextSize = 24
    button.BackgroundColor3 = Color3.fromRGB(0, 123, 255)
    local resetTween = tweenService:Create(button, tweenInfo, {Size = UDim2.new(0, 200, 0, 50)})
    resetTween:Play()
end)

-- Add cool bouncing effect to the frame
local function bounceFrame()
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, -1, true)
    local goal = {Position = UDim2.new(0.25, 0, 0.2, 0)}
    local tween = tweenService:Create(mainFrame, tweenInfo, goal)
    tween:Play()
end

-- Activate bounce effect on startup
bounceFrame()
