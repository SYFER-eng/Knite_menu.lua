local CoolMenuFramework = {}

-- Function to create a menu section with animations
function CoolMenuFramework.createMenu(title, items, position, parent)
    -- Main frame for the menu
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 0) -- Start small for animation
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = parent

    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    -- Add a shadow effect
    local shadow = Instance.new("Frame")
    shadow.Size = frame.Size
    shadow.Position = UDim2.new(0, 5, 0, 5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.6
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Parent = parent

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 10)
    shadowCorner.Parent = shadow

    -- Add a gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
    }
    gradient.Rotation = 90
    gradient.Parent = frame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Add item labels
    for i, item in ipairs(items) do
        local itemLabel = Instance.new("TextLabel")
        itemLabel.Text = item
        itemLabel.Size = UDim2.new(1, -10, 0, 25)
        itemLabel.Position = UDim2.new(0, 5, 0, 30 + (i - 1) * 30)
        itemLabel.BackgroundTransparency = 1
        itemLabel.Font = Enum.Font.SourceSans
        itemLabel.TextSize = 16
        itemLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        itemLabel.Parent = frame
    end

    -- Animation: Smoothly scale the menu
    frame:TweenSize(UDim2.new(0, 200, 0, 30 + (#items * 30)), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
    shadow:TweenSize(frame.Size, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

    return frame
end

return CoolMenuFramework
