-- ButtonLib Module (Cooler Design)
local ButtonLib = {}

-- Function to create a button with more modern effects
function ButtonLib.createButton(parent, position, size, buttonText, callback)
    -- Create the button
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
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 205, 255)),  -- Start color (light blue)
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 136, 255))    -- End color (dark blue)
    })
    gradient.Parent = button

    -- Hover effect to change the color when mouse enters and leaves
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

    -- Button click animation with scaling and color transition
    button.MouseButton1Click:Connect(function()
        -- Button click animation (scale up then down)
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

return ButtonLib
