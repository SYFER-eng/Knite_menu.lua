-- CoolMenuLib Module Script
local CoolMenuLib = {}

-- Function to create buttons with animation and hover effects
function CoolMenuLib.createButton(parent, position, size, buttonText, callback)
    -- Create button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, size.X, 0, size.Y)
    button.Position = UDim2.new(0, position.X, 0, position.Y)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    button.Text = buttonText
    button.TextSize = 24
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.Parent = parent

    -- Apply a gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 205, 255)),  -- Light blue
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 136, 255))    -- Dark blue
    })
    gradient.Parent = button

    -- Hover effect to change color when mouse enters and leaves
    local function onHover()
        button:TweenBackgroundColor3(Color3.fromRGB(255, 255, 255), "Out", "Quad", 0.2, true)
        button.TextColor3 = Color3.fromRGB(0, 0, 0)
    end

    local function offHover()
        button:TweenBackgroundColor3(Color3.fromRGB(0, 255, 255), "Out", "Quad", 0.2, true)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    button.MouseEnter:Connect(onHover)
    button.MouseLeave:Connect(offHover)

    -- Button click animation (scale and color transition)
    button.MouseButton1Click:Connect(function()
        -- Scale button animation
        button:TweenSize(UDim2.new(0, size.X * 1.1, 0, size.Y * 1.1), "Out", "Quad", 0.2, true, function()
            button:TweenSize(UDim2.new(0, size.X, 0, size.Y), "Out", "Quad", 0.2, true)
        end)
        
        -- Trigger callback on click
        if callback then
            callback()
        end
    end)

    return button
end

-- Function to create a menu frame with background and effects
function CoolMenuLib.createMenu(parent, menuSize, title)
    -- Create a frame for the menu background
    local menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0, menuSize.X, 0, menuSize.Y)
    menuFrame.Position = UDim2.new(0.5, -menuSize.X/2, 0.5, -menuSize.Y/2)
    menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    menuFrame.BackgroundTransparency = 0.8
    menuFrame.BorderSizePixel = 0
    menuFrame.Parent = parent

    -- Add rounded corners to the frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = menuFrame

    -- Add a gradient effect to the background of the menu
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 136, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 205, 255))
    })
    gradient.Parent = menuFrame

    -- Create a title label for the menu
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, menuSize.X, 0, 60)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Menu"
    titleLabel.TextSize = 32
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextAlign = Enum.TextAnchor.MiddleCenter
    titleLabel.Parent = menuFrame

    return menuFrame
end

return CoolMenuLib
