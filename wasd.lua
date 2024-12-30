-- LocalScript inside ScreenGui

-- Fetch the button data from Pastebin using HttpGet
local buttonDataScript = loadstring(game:HttpGet("https://pastebin.com/raw/5UtYzCFP", true))()

-- References to the player and the screen GUI
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

-- Creating the main frame of the GUI
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 4
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Parent = screenGui

-- Adding a title label to the GUI
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 400, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "Enhanced Dynamic GUI"
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextFont = Enum.Font.GothamBold
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleLabel.TextAlign = Enum.TextAlign.Center
titleLabel.Parent = mainFrame

-- Function to dynamically create buttons from the table
local function createButton(name, position, size, text, onClickCallback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.Text = text
    button.TextSize = 18
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 2
    button.BorderColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = mainFrame

    -- Set up button click event
    button.MouseButton1Click:Connect(onClickCallback)
end

-- Dynamically load and create buttons based on the fetched data
for _, buttonInfo in ipairs(buttonDataScript) do
    createButton(
        buttonInfo.name,
        buttonInfo.position,
        buttonInfo.size,
        buttonInfo.text,
        buttonInfo.onClickCallback
    )
end

-- Function to create a slider
local function createSlider(name, position, minValue, maxValue, initialValue, onChanged)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 300, 0, 40)
    sliderFrame.Position = position
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderFrame.BorderSizePixel = 2
    sliderFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    sliderFrame.Parent = mainFrame

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 4)
    sliderTrack.Position = UDim2.new(0, 0, 0.5, -2)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    sliderTrack.Parent = sliderFrame

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new(0, initialValue / maxValue * 280, 0.5, -10)
    sliderButton.Text = ""
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 100, 0, 20)
    valueLabel.Position = UDim2.new(0, 320, 0.5, -10)
    valueLabel.Text = tostring(initialValue)
    valueLabel.TextSize = 18
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = mainFrame

    -- Handle slider dragging
    local dragging = false
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position.X - sliderTrack.AbsolutePosition.X
            local newValue = math.clamp(delta / sliderTrack.AbsoluteSize.X, 0, 1) * (maxValue - minValue) + minValue
            sliderButton.Position = UDim2.new(0, delta, 0.5, -10)
            valueLabel.Text = tostring(math.floor(newValue))
            onChanged(newValue)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Function to create a color picker (simplified)
local function createColorPicker(name, position, initialColor, onColorChanged)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0, 300, 0, 40)
    colorFrame.Position = position
    colorFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    colorFrame.BorderSizePixel = 2
    colorFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    colorFrame.Parent = mainFrame

    local colorDisplay = Instance.new("Frame")
    colorDisplay.Size = UDim2.new(0, 100, 0, 30)
    colorDisplay.Position = UDim2.new(0, 10, 0.5, -15)
    colorDisplay.BackgroundColor3 = initialColor
    colorDisplay.Parent = colorFrame

    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0, 80, 0, 30)
    colorButton.Position = UDim2.new(0, 120, 0.5, -15)
    colorButton.Text = "Pick Color"
    colorButton.TextSize = 16
    colorButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    colorButton.Parent = colorFrame

    -- Color selection functionality (simple example)
    colorButton.MouseButton1Click:Connect(function()
        local colorPicker = Instance.new("Color3Value")
        colorPicker.Color = initialColor
        -- Color picker UI (simplified)
        -- In a real scenario, you'd want to use a more advanced color picker UI, 
        -- but for simplicity, let's just cycle through some colors on click.
        local newColor = Color3.fromHSV(math.random(), 1, 1) -- Random color for example
        colorDisplay.BackgroundColor3 = newColor
        onColorChanged(newColor)
    end)
end

-- Function to create a dropdown menu
local function createDropdownMenu(name, position, options, onSelected)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, 300, 0, 40)
    dropdownFrame.Position = position
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdownFrame.BorderSizePixel = 2
    dropdownFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    dropdownFrame.Parent = mainFrame

    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Size = UDim2.new(0, 200, 0, 40)
    dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
    dropdownLabel.Text = "Select Option"
    dropdownLabel.TextSize = 18
    dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Parent = dropdownFrame

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0, 80, 0, 40)
    dropdownButton.Position = UDim2.new(1, -90, 0, 0)
    dropdownButton.Text = "▼"
    dropdownButton.TextSize = 18
    dropdownButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    dropdownButton.Parent = dropdownFrame

    local dropdownMenu = Instance.new("Frame")
    dropdownMenu.Size = UDim2.new(0, 300, 0, 0)
    dropdownMenu.Position = UDim2.new(0, 0, 1, 0)
    dropdownMenu.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    dropdownMenu.Visible = false
    dropdownMenu.Parent = dropdownFrame

    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Position = UDim2.new(0, 0, (i - 1) * 0.1, 0)
        optionButton.Text = option
        optionButton.TextSize = 18
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        optionButton.Parent = dropdownMenu

        optionButton.MouseButton1Click:Connect(function()
            dropdownLabel.Text = "Selected: " .. option
            dropdownMenu.Visible = false
            onSelected(option)
        end)
    end

    -- Show/hide dropdown menu on button click
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownMenu.Visible = not dropdownMenu.Visible
    end)
end

-- Call the functions to create UI elements
createSlider("Slider1", UDim2.new(0, 50, 0, 60), 0, 100, 50, function(value)
    print("Slider Value: " .. value)
end)

createColorPicker("ColorPicker1", UDim2.new(0, 50, 0, 120), Color3.fromRGB(255, 0, 0), function(color)
    print("Color Selected: " .. tostring(color))
end)

createDropdownMenu("Dropdown1", UDim2.new(0, 50, 0, 180), {"Option 1", "Option 2", "Option 3"}, function(selectedOption)
    print("Dropdown Selected: " .. selectedOption)
end)

-- Adding a draggable feature to the frame (same as before)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

local function onInputBegan(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if dragging then
                update(input)
            end
        end)
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end

screenGui.InputBegan:Connect(onInputBegan)
screenGui.InputEnded:Connect(onInputEnded)

-- Add a stylish background gradient to the GUI
local gradient = Instance.new("UIGradient")
gradient.Parent = mainFrame
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100)),
}
gradient.Rotation = 45
