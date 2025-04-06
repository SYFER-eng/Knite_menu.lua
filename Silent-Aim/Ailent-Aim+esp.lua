local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Knite_menu.lua/refs/heads/main/Trackingesp.lua",true))()
end)

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()

local targetPlayer = nil
local ClickInterval = 0.10
local isLeftMouseDown = false
local isRightMouseDown = false
local autoClickConnection = nil

local autoFireEnabled = false
local fovSize = 120
local showFOV = true
local teamCheckEnabled = false

local targetBodyParts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local selectedBodyPart = "Head"

local drawingObjects = {
    fovCircle = nil
}

drawingObjects.fovCircle = Drawing.new("Circle")
drawingObjects.fovCircle.Visible = showFOV
drawingObjects.fovCircle.Color = Color3.fromRGB(255, 0, 127)
drawingObjects.fovCircle.Thickness = 1.5
drawingObjects.fovCircle.Transparency = 1
drawingObjects.fovCircle.NumSides = 60
drawingObjects.fovCircle.Radius = fovSize
drawingObjects.fovCircle.Filled = false

local miniDisplay = {
    background = Drawing.new("Square"),
    targetText = Drawing.new("Text"),
    statusText = Drawing.new("Text")
}

miniDisplay.background.Size = Vector2.new(150, 45)
miniDisplay.background.Position = Vector2.new(camera.ViewportSize.X - 160, 10)
miniDisplay.background.Color = Color3.fromRGB(25, 25, 25)
miniDisplay.background.Filled = true
miniDisplay.background.Transparency = 0.7
miniDisplay.background.Visible = false

miniDisplay.targetText = Drawing.new("Text")
miniDisplay.targetText.Text = "Target: None"
miniDisplay.targetText.Size = 16
miniDisplay.targetText.Color = Color3.fromRGB(255, 255, 255)
miniDisplay.targetText.Center = false
miniDisplay.targetText.Position = Vector2.new(camera.ViewportSize.X - 150, 15)
miniDisplay.targetText.Outline = true
miniDisplay.targetText.Visible = false

miniDisplay.statusText = Drawing.new("Text")
miniDisplay.statusText.Text = "Status: Active"
miniDisplay.statusText.Size = 16
miniDisplay.statusText.Color = Color3.fromRGB(0, 255, 0)
miniDisplay.statusText.Center = false
miniDisplay.statusText.Position = Vector2.new(camera.ViewportSize.X - 150, 35)
miniDisplay.statusText.Outline = true
miniDisplay.statusText.Visible = false

local gui = Instance.new("ScreenGui")
gui.Name = "SilentAimGUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = localPlayer:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 290)
mainFrame.Position = UDim2.new(1, -220, 0.5, -145)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Silent Aim Pro"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleLabel

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Active"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

local targetLabel = Instance.new("TextLabel")
targetLabel.Name = "TargetLabel"
targetLabel.Size = UDim2.new(1, 0, 0, 20)
targetLabel.Position = UDim2.new(0, 0, 0, 60)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Target: None"
targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
targetLabel.Font = Enum.Font.SourceSans
targetLabel.TextSize = 14
targetLabel.Parent = mainFrame

local function createButton(name, text, posY, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.9, 0, 0, 25)
    button.Position = UDim2.new(0.05, 0, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(
            math.min(button.BackgroundColor3.R * 255 + 20, 255),
            math.min(button.BackgroundColor3.G * 255 + 20, 255),
            math.min(button.BackgroundColor3.B * 255 + 20, 255)
        )
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(
            math.max(button.BackgroundColor3.R * 255 - 20, 0),
            math.max(button.BackgroundColor3.G * 255 - 20, 0),
            math.max(button.BackgroundColor3.B * 255 - 20, 0)
        )
    end)
    
    return button
end

local fovSizeLabel = Instance.new("TextLabel")
fovSizeLabel.Name = "FOVSizeLabel"
fovSizeLabel.Size = UDim2.new(0.9, 0, 0, 20)
fovSizeLabel.Position = UDim2.new(0.05, 0, 0, 90)
fovSizeLabel.BackgroundTransparency = 1
fovSizeLabel.Text = "FOV Size: " .. fovSize
fovSizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fovSizeLabel.Font = Enum.Font.SourceSans
fovSizeLabel.TextSize = 14
fovSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
fovSizeLabel.Parent = mainFrame

local sliderBackground = Instance.new("Frame")
sliderBackground.Name = "SliderBackground"
sliderBackground.Size = UDim2.new(0.9, 0, 0, 10)
sliderBackground.Position = UDim2.new(0.05, 0, 0, 110)
sliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sliderBackground.BorderSizePixel = 0
sliderBackground.Parent = mainFrame

local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(fovSize/300, 0, 1, 0)
sliderFill.Position = UDim2.new(0, 0, 0, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 127)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBackground

local sliderButton = Instance.new("TextButton")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0.05, 0, 1.5, 0)
sliderButton.Position = UDim2.new(fovSize/300 - 0.025, 0, -0.25, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.Text = ""
sliderButton.Parent = sliderBackground

local sliderBackgroundCorner = Instance.new("UICorner")
sliderBackgroundCorner.CornerRadius = UDim.new(0, 4)
sliderBackgroundCorner.Parent = sliderBackground

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 4)
sliderFillCorner.Parent = sliderFill

local sliderButtonCorner = Instance.new("UICorner")
sliderButtonCorner.CornerRadius = UDim.new(0, 4)
sliderButtonCorner.Parent = sliderButton

local isDragging = false

sliderButton.MouseButton1Down:Connect(function()
    isDragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePosition = UserInputService:GetMouseLocation()
        local sliderPosition = sliderBackground.AbsolutePosition
        local sliderSize = sliderBackground.AbsoluteSize
        
        local percentage = math.clamp((mousePosition.X - sliderPosition.X) / sliderSize.X, 0, 1)
        
        fovSize = math.floor(20 + (percentage * 280))
        
        fovSizeLabel.Text = "FOV Size: " .. fovSize
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderButton.Position = UDim2.new(percentage - 0.025, 0, -0.25, 0)
        
        drawingObjects.fovCircle.Radius = fovSize
    end
end)

local autoFireButton = createButton("AutoFireButton", "Auto-Fire: OFF", 130, mainFrame)
autoFireButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

local teamCheckButton = createButton("TeamCheckButton", "Team Check: OFF", 160, mainFrame)
teamCheckButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

local fovToggleButton = createButton("FOVToggleButton", "FOV Circle: ON", 190, mainFrame)
fovToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

local targetPartLabel = Instance.new("TextLabel")
targetPartLabel.Name = "TargetPartLabel"
targetPartLabel.Size = UDim2.new(0.9, 0, 0, 20)
targetPartLabel.Position = UDim2.new(0.05, 0, 0, 220)
targetPartLabel.BackgroundTransparency = 1
targetPartLabel.Text = "Target Body Part:"
targetPartLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
targetPartLabel.Font = Enum.Font.SourceSans
targetPartLabel.TextSize = 14
targetPartLabel.TextXAlignment = Enum.TextXAlignment.Left
targetPartLabel.Parent = mainFrame

local targetPartButton = Instance.new("TextButton")
targetPartButton.Name = "TargetPartButton"
targetPartButton.Size = UDim2.new(0.9, 0, 0, 25)
targetPartButton.Position = UDim2.new(0.05, 0, 0, 240)
targetPartButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
targetPartButton.Text = "Head"
targetPartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
targetPartButton.Font = Enum.Font.SourceSans
targetPartButton.TextSize = 14
targetPartButton.BorderSizePixel = 0
targetPartButton.Parent = mainFrame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 6)
dropdownCorner.Parent = targetPartButton

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Name = "DropdownFrame"
dropdownFrame.Size = UDim2.new(0.9, 0, 0, #targetBodyParts * 25)
dropdownFrame.Position = UDim2.new(0.05, 0, 0, 270)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.Visible = false
dropdownFrame.ZIndex = 10
dropdownFrame.Parent = mainFrame

local dropdownFrameCorner = Instance.new("UICorner")
dropdownFrameCorner.CornerRadius = UDim.new(0, 6)
dropdownFrameCorner.Parent = dropdownFrame

for i, part in ipairs(targetBodyParts) do
    local option = Instance.new("TextButton")
    option.Name = part .. "Option"
    option.Size = UDim2.new(1, 0, 0, 25)
    option.Position = UDim2.new(0, 0, 0, (i-1) * 25)
    option.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    option.BackgroundTransparency = 0.5
    option.Text = part
    option.TextColor3 = Color3.fromRGB(255, 255, 255)
    option.Font = Enum.Font.SourceSans
    option.TextSize = 14
    option.BorderSizePixel = 0
    option.ZIndex = 11
    option.Parent = dropdownFrame
    
    option.MouseEnter:Connect(function()
        option.BackgroundTransparency = 0.2
    end)
    
    option.MouseLeave:Connect(function()
        option.BackgroundTransparency = 0.5
    end)
    
    option.MouseButton1Click:Connect(function()
        selectedBodyPart = part
        targetPartButton.Text = part
        dropdownFrame.Visible = false
    end)
end

targetPartButton.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
end)

local function isTeammate(player)
    if not teamCheckEnabled then
        return false
    end
    
    if not player or not localPlayer then
        return false
    end
    
    if player.Team and localPlayer.Team then
        return player.Team == localPlayer.Team
    end
    
    if player.TeamColor and localPlayer.TeamColor then
        return player.TeamColor == localPlayer.TeamColor
    end
    
    return false
end

local function isLobbyVisible()
    local success, result = pcall(function()
        local playerGui = localPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return false end
        
        local mainGui = playerGui:FindFirstChild("MainGui")
        if not mainGui then return false end
        
        local mainFrame = mainGui:FindFirstChild("MainFrame")
        if not mainFrame then return false end
        
        local lobby = mainFrame:FindFirstChild("Lobby")
        if not lobby then return false end
        
        local currency = lobby:FindFirstChild("Currency")
        if not currency then return false end
        
        return currency.Visible == true
    end)
    
    return success and result or false
end

local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePosition = UserInputService:GetMouseLocation()
    local centerPosition = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if teamCheckEnabled and isTeammate(player) then
                continue
            end
            
            local head = player.Character.Head
            local headPosition, onScreen = camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local screenPosition = Vector2.new(headPosition.X, headPosition.Y)
                local distanceFromCenter = (screenPosition - centerPosition).Magnitude
                
                if distanceFromCenter <= fovSize then
                    local distanceFromMouse = (screenPosition - mousePosition).Magnitude
                    if distanceFromMouse < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distanceFromMouse
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function getTargetBodyPart(character)
    if not character then return nil end
    
    local part = character:FindFirstChild(selectedBodyPart)
    
    if not part then
        local partMap = {
            ["Torso"] = {"UpperTorso", "LowerTorso"},
            ["Left Arm"] = {"LeftUpperArm", "LeftLowerArm", "LeftHand"},
            ["Right Arm"] = {"RightUpperArm", "RightLowerArm", "RightHand"},
            ["Left Leg"] = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
            ["Right Leg"] = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
        }
        
        if partMap[selectedBodyPart] then
            for _, altName in ipairs(partMap[selectedBodyPart]) do
                part = character:FindFirstChild(altName)
                if part then break end
            end
        end
    end
    
    return part or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

local function lockCameraToHead()
    if targetPlayer and targetPlayer.Character then
        local targetPart = getTargetBodyPart(targetPlayer.Character)
        if not targetPart then return end
        
        local headPosition = camera:WorldToViewportPoint(targetPart.Position)
        
        if headPosition.Z > 0 then
            local cameraPosition = camera.CFrame.Position
            local direction = (targetPart.Position - cameraPosition).Unit
            camera.CFrame = CFrame.new(cameraPosition, targetPart.Position)
        end
    end
end

local function autoClick()
    if autoClickConnection then
        autoClickConnection:Disconnect()
        autoClickConnection = nil
    end
    
    if autoFireEnabled then
        autoClickConnection = RunService.Heartbeat:Connect(function()
            if targetPlayer and not isLobbyVisible() then
                mouse1click()
            end
        end)
    end
end

local function updateMiniDisplay()
    if not gui.Enabled then
        miniDisplay.background.Visible = true
        miniDisplay.targetText.Visible = true
        miniDisplay.statusText.Visible = true
        
        if targetPlayer then
            miniDisplay.targetText.Text = "Target: " .. targetPlayer.Name
            miniDisplay.targetText.Color = Color3.fromRGB(255, 0, 0)
        else
            miniDisplay.targetText.Text = "Target: None"
            miniDisplay.targetText.Color = Color3.fromRGB(255, 255, 255)
        end
        
        miniDisplay.statusText.Text = "Status: Active"
    else
        miniDisplay.background.Visible = false
        miniDisplay.targetText.Visible = false
        miniDisplay.statusText.Visible = false
    end
end

local function cleanupDrawings()
    if drawingObjects.fovCircle then 
        drawingObjects.fovCircle:Remove()
        drawingObjects.fovCircle = nil
    end
    
    if miniDisplay.background then
        miniDisplay.background:Remove()
        miniDisplay.background = nil
    end
    
    if miniDisplay.targetText then
        miniDisplay.targetText:Remove()
        miniDisplay.targetText = nil
    end
    
    if miniDisplay.statusText then
        miniDisplay.statusText:Remove()
        miniDisplay.statusText = nil
    end
end

local function cleanupScript()
    cleanupDrawings()
    
    if autoClickConnection then
        autoClickConnection:Disconnect()
        autoClickConnection = nil
    end
    
    if gui then
        gui:Destroy()
    end
end

UserInputService.InputBegan:Connect(function(input, isProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        gui.Enabled = not gui.Enabled
        updateMiniDisplay()
    elseif input.KeyCode == Enum.KeyCode.End then
        cleanupScript()
    end
end)

autoFireButton.MouseButton1Click:Connect(function()
    autoFireEnabled = not autoFireEnabled
    
    if autoFireEnabled then
        autoFireButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        autoFireButton.Text = "Auto-Fire: ON"
        autoClick()
    else
        autoFireButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        autoFireButton.Text = "Auto-Fire: OFF"
        
        if autoClickConnection then
            autoClickConnection:Disconnect()
            autoClickConnection = nil
        end
    end
end)

teamCheckButton.MouseButton1Click:Connect(function()
    teamCheckEnabled = not teamCheckEnabled
    
    if teamCheckEnabled then
        teamCheckButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        teamCheckButton.Text = "Team Check: ON"
    else
        teamCheckButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        teamCheckButton.Text = "Team Check: OFF"
    end
end)

fovToggleButton.MouseButton1Click:Connect(function()
    showFOV = not showFOV
    
    if showFOV then
        fovToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        fovToggleButton.Text = "FOV Circle: ON"
    else
        fovToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        fovToggleButton.Text = "FOV Circle: OFF"
    end
    
    drawingObjects.fovCircle.Visible = showFOV
end)

RunService.Heartbeat:Connect(function()
    drawingObjects.fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    local lobbyCheck = false
    pcall(function() lobbyCheck = isLobbyVisible() end)
    
    if not lobbyCheck then
        targetPlayer = getClosestPlayerToMouse()
        
        if targetPlayer then
            targetLabel.Text = "Target: " .. targetPlayer.Name
            targetLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            
            lockCameraToHead()
        else
            targetLabel.Text = "Target: None"
            targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    else
        targetLabel.Text = "Target: In Lobby"
        targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    pcall(function() updateMiniDisplay() end)
end)
