local MenuFramework = {}

-- Function to create a menu section
function MenuFramework.createMenuSection(title, items, position)
    -- Create a main frame for the menu section
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 30 + (#items * 30))
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
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

    return frame
end

return MenuFramework
