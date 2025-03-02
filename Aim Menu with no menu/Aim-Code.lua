local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local isAiming = false
local isEnabled = true

local function getClosestPlayerToCenter()
    local shortestDistance = math.huge
    local closestPlayer = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPoint = Camera:WorldToScreenPoint(player.Character.Head.Position)
            local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

local function county()
    if not isEnabled then return end
    
    local targetPlayer = getClosestPlayerToCenter()
    if targetPlayer and targetPlayer.Character then
        local targetHead = targetPlayer.Character:FindFirstChild("Head")
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightBracket then
        isEnabled = not isEnabled
    end
end)

Mouse.Button2Down:Connect(function()
    isAiming = true
end)

Mouse.Button2Up:Connect(function()
    isAiming = false
end)

RunService.RenderStepped:Connect(function()
    if isAiming then
        county()
    end
end)
