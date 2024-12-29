-- Place this script in a LocalScript inside StarterGui

-- Create the main GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Name = "AimbotMenu"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  -- Ensure it is always above other UI elements

-- Main Frame (the menu background)
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0.3, 0, 0.4, 0)
mainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Dark background
mainFrame.BackgroundTransparency = 0.5
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 10  -- Make sure the menu is on top

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "Aimbot Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextAlign = Enum.TextAlign.Center

-- Create Buttons to simulate aimbot features
local buttonHeight = 0.15

local function createButton(name, position)
    local button = Instance.new("TextButton")
    button.Parent = mainFrame
    button.Size = UDim2.new(1, 0, buttonHeight, 0)
    button.Position = position
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextTransparency = 0.5
    button.TextAlign = Enum.TextAlign.Center

    return button
end

-- Create Buttons
local enableButton = createButton("Enable Aimbot", UDim2.new(0, 0, 0.1, 0))
local targetLockButton = createButton("Target Lock", UDim2.new(0, 0, 0.3, 0))
local distanceButton = createButton("Distance: 100m", UDim2.new(0, 0, 0.5, 0))

-- Toggle functionality (Simulating the feature toggle)
local aimbotEnabled = false
local targetLockEnabled = false
local distance = 100

-- Button click handlers to simulate toggling
enableButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        enableButton.Text = "Disable Aimbot"
        enableButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Red when enabled
    else
        enableButton.Text = "Enable Aimbot"
        enableButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  -- Reset to normal
    end
end)

targetLockButton.MouseButton1Click:Connect(function()
    targetLockEnabled = not targetLockEnabled
    if targetLockEnabled then
        targetLockButton.Text = "Target Locked"
        targetLockButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- Green when locked
    else
        targetLockButton.Text = "Target Lock"
        targetLockButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  -- Reset to normal
    end
end)

distanceButton.MouseButton1Click:Connect(function()
    distance = distance == 100 and 200 or 100
    distanceButton.Text = "Distance: " .. tostring(distance) .. "m"
end)

-- Optional: Animation for hovering over buttons
local function onHover(button)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)
    button.MouseLeave:Connect(function()
        if not button.Text:find("Disabled") then
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end)
end

onHover(enableButton)
onHover(targetLockButton)
onHover(distanceButton)

-- Optional: Background image (to give it a more "hacker" aimbot look)
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Parent = mainFrame
backgroundImage.Size = UDim2.new(1, 0, 1, 0)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = "rbxassetid://11310633869"  -- Example image (you can replace with any)
backgroundImage.ImageTransparency = 0.8
backgroundImage.ZIndex = 1

-- Optional: Add a close button to hide the menu
local closeButton = Instance.new("TextButton")
closeButton.Parent = mainFrame
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.TextTransparency = 0.2

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()  -- Close the menu
end)

-- Draggable functionality
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

-- Function to handle drag start
titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

-- Function to handle dragging
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Function to stop dragging
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
