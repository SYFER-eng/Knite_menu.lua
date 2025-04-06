local Settings = {
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Tracer_Origin = "Bottom", -- Middle or Bottom if FollowMouse is on this won't matter...
    Tracer_FollowMouse = false,
    Tracers = true,
    Text_Size = 14,
    Text_Color = Color3.fromRGB(255, 255, 255)
}

local Team_Check = {
    TeamCheck = false, -- if TeamColor is on this won't matter...
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}

local TeamColor = true

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// VARIABLES
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Store all connections and drawing objects for cleanup
local Connections = {}
local AllDrawings = {}
local PlayerESP = {} -- Store ESP data for each player

local function NewDrawing(type, properties)
    local drawing = Drawing.new(type)
    
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    
    table.insert(AllDrawings, drawing)
    return drawing
end

local function NewQuad(thickness, color)
    return NewDrawing("Quad", {
        Visible = false,
        PointA = Vector2.new(0,0),
        PointB = Vector2.new(0,0),
        PointC = Vector2.new(0,0),
        PointD = Vector2.new(0,0),
        Color = color,
        Filled = false,
        Thickness = thickness,
        Transparency = 1
    })
end

local function NewLine(thickness, color)
    return NewDrawing("Line", {
        Visible = false,
        From = Vector2.new(0, 0),
        To = Vector2.new(0, 0),
        Color = color,
        Thickness = thickness,
        Transparency = 1
    })
end

local function NewText(text, color, size)
    return NewDrawing("Text", {
        Visible = false,
        Text = text,
        Size = size,
        Color = color,
        Center = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Position = Vector2.new(0, 0)
    })
end

local function CleanupPlayerESP(playerName)
    if PlayerESP[playerName] then
        for _, drawing in pairs(PlayerESP[playerName].drawings) do
            if drawing then
                drawing.Visible = false
            end
        end
        
        PlayerESP[playerName] = nil
    end
end

local function ESP(plr)
    if plr == player then return end
    if PlayerESP[plr.Name] then return end
    
    local drawings = {
        -- Box and border
        black = NewQuad(Settings.Box_Thickness*2, Color3.fromRGB(0, 0, 0)),
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        
        -- Tracer and border
        blacktracer = NewLine(Settings.Tracer_Thickness*2, Color3.fromRGB(0, 0, 0)),
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
        
        -- Health bar
        healthbar = NewLine(3, Color3.fromRGB(0, 0, 0)),
        greenhealth = NewLine(1.5, Color3.fromRGB(0, 255, 0)),
        
        -- Text
        name = NewText(plr.Name, Settings.Text_Color, Settings.Text_Size),
        distance = NewText("0m", Settings.Text_Color, Settings.Text_Size)
    }
    
    -- Store ESP data for this player
    PlayerESP[plr.Name] = {
        drawings = drawings,
        visible = false
    }
end

-- Function to update all ESP elements efficiently
local function UpdateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and PlayerESP[plr.Name] then
            local espData = PlayerESP[plr.Name]
            local drawings = espData.drawings
            
            -- Check if player's character exists and is alive
            local character = plr.Character
            if not character or 
               not character:FindFirstChild("Humanoid") or 
               not character:FindFirstChild("HumanoidRootPart") or 
               character.Humanoid.Health <= 0 then
                
                -- Hide ESP if character is invalid
                if espData.visible then
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                    espData.visible = false
                end
                continue
            end
            
            -- Get positions
            local rootPart = character.HumanoidRootPart
            local HumPos, OnScreen = camera:WorldToViewportPoint(rootPart.Position)
            
            if not OnScreen then
                -- Hide ESP if not on screen
                if espData.visible then
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                    espData.visible = false
                end
                continue
            end
            
            -- Character is valid and on screen, update ESP
            local head = camera:WorldToViewportPoint(character.Head.Position)
            local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)
            
            -- Calculate distance
            local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
            local distanceText = math.floor(distance) .. " studs"
            
            -- Update box
            local boxPoints = {
                Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY*2),
                Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2),
                Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2),
                Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY*2)
            }
            
            drawings.box.PointA = boxPoints[1]
            drawings.box.PointB = boxPoints[2]
            drawings.box.PointC = boxPoints[3]
            drawings.box.PointD = boxPoints[4]
            
            drawings.black.PointA = boxPoints[1]
            drawings.black.PointB = boxPoints[2]
            drawings.black.PointC = boxPoints[3]
            drawings.black.PointD = boxPoints[4]
            
            -- Update tracers
            if Settings.Tracers then
                local origin
                if Settings.Tracer_FollowMouse then
                    origin = Vector2.new(mouse.X, mouse.Y+36)
                elseif Settings.Tracer_Origin == "Middle" then
                    origin = camera.ViewportSize*0.5
                else -- Bottom
                    origin = Vector2.new(camera.ViewportSize.X*0.5, camera.ViewportSize.Y)
                end
                
                drawings.tracer.From = origin
                drawings.blacktracer.From = origin
                drawings.tracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                drawings.blacktracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                
                drawings.tracer.Visible = true
                drawings.blacktracer.Visible = true
            else
                drawings.tracer.Visible = false
                drawings.blacktracer.Visible = false
            end
            
            -- Update health bar
            local humanoid = character.Humanoid
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            
            local barHeight = DistanceY * 4
            local barPosX = HumPos.X - DistanceY - 4
            
            drawings.healthbar.From = Vector2.new(barPosX, HumPos.Y + DistanceY*2)
            drawings.healthbar.To = Vector2.new(barPosX, HumPos.Y - DistanceY*2)
            
            drawings.greenhealth.From = Vector2.new(barPosX, HumPos.Y + DistanceY*2)
            drawings.greenhealth.To = Vector2.new(barPosX, HumPos.Y + DistanceY*2 - barHeight * healthPercent)
            
            -- Color gradient from red to green based on health
            local green = Color3.fromRGB(0, 255, 0)
            local red = Color3.fromRGB(255, 0, 0)
            drawings.greenhealth.Color = red:lerp(green, healthPercent)
            
            -- Update text
            drawings.name.Position = Vector2.new(HumPos.X, HumPos.Y - DistanceY*2 - 15)
            drawings.name.Text = plr.Name
            
            drawings.distance.Position = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2 + 15)
            drawings.distance.Text = distanceText
            
            -- Apply team colors
            if Team_Check.TeamCheck then
                if plr.TeamColor == player.TeamColor then
                    drawings.box.Color = Team_Check.Green
                    drawings.tracer.Color = Team_Check.Green
                else 
                    drawings.box.Color = Team_Check.Red
                    drawings.tracer.Color = Team_Check.Red
                end
            elseif TeamColor then
                drawings.box.Color = plr.TeamColor.Color
                drawings.tracer.Color = plr.TeamColor.Color
            else
                drawings.box.Color = Settings.Box_Color
                drawings.tracer.Color = Settings.Tracer_Color
            end
            
            -- Make everything visible
            drawings.box.Visible = true
            drawings.black.Visible = true
            drawings.name.Visible = true
            drawings.distance.Visible = true
            drawings.healthbar.Visible = true
            drawings.greenhealth.Visible = true
            
            espData.visible = true
        end
    end
end

-- Function to clean up all ESP elements
local function UnloadESP()
    -- Disconnect all connections
    for _, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Remove all drawings
    for _, drawing in pairs(AllDrawings) do
        if drawing then
            drawing:Remove()
        end
    end
    
    -- Clear tables
    Connections = {}
    AllDrawings = {}
    PlayerESP = {}
    
end

-- Set up End key to unload ESP
local endKeyConnection = UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.End then
        UnloadESP()
        endKeyConnection:Disconnect()
    end
end)
table.insert(Connections, endKeyConnection)

-- Initialize ESP for existing players
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= player then
        ESP(plr)
    end
end

-- Set up connection for new players
local playerAddedConnection = Players.PlayerAdded:Connect(function(plr)
    ESP(plr)
end)

-- Set up connection for players leaving
local playerRemovingConnection = Players.PlayerRemoving:Connect(function(plr)
    CleanupPlayerESP(plr.Name)
end)

-- Main update loop
local updateConnection = RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

table.insert(Connections, playerAddedConnection)
table.insert(Connections, playerRemovingConnection)
table.insert(Connections, updateConnection)
