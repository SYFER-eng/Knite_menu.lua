local WAIT = task.wait
local TBINSERT = table.insert
local V2 = Vector2.new
local ROUND = math.round

local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local To2D = Camera.WorldToViewportPoint
local LocalPlayer = game.Players.LocalPlayer

local Library = {}
Library.__index = Library

-- Create a line with specific parameters
function Library:NewLine(info)
    local l = Drawing.new("Line")
    l.Visible = info.Visible or true
    l.Color = info.Color or Color3.fromRGB(0, 255, 0)
    l.Transparency = info.Transparency or 1
    l.Thickness = info.Thickness or 1
    return l
end

-- Smoothen a vector (rounding the coordinates)
function Library:Smoothen(v)
    return V2(ROUND(v.X), ROUND(v.Y))
end

-- Skeleton Object (holds the structure)
local Skeleton = {
    Removed = false,
    Player = nil,
    Visible = false,
    Lines = {},
    Color = Color3.fromRGB(0, 255, 0),
    Alpha = 1,
    Thickness = 1,
    DoSubsteps = true
}
Skeleton.__index = Skeleton

-- Update the skeleton structure (lines, joints, etc.)
function Skeleton:UpdateStructure()
    if not self.Player.Character then return end

    self:RemoveLines()

    for _, part in next, self.Player.Character:GetChildren() do
        if not part:IsA("BasePart") then
            continue
        end

        for _, link in next, part:GetChildren() do
            if not link:IsA("Motor6D") then
                continue
            end

            TBINSERT(self.Lines, {
                Library:NewLine({
                    Visible = self.Visible,
                    Color = self.Color,
                    Transparency = self.Alpha,
                    Thickness = self.Thickness
                }),
                Library:NewLine({
                    Visible = self.Visible,
                    Color = self.Color,
                    Transparency = self.Alpha,
                    Thickness = self.Thickness
                }),
                part.Name,
                link.Name
            })
        end
    end
end

-- Set visibility for all lines in the skeleton
function Skeleton:SetVisible(State)
    for _, l in pairs(self.Lines) do
        l[1].Visible = State
        l[2].Visible = State
    end
end

-- Set the color for all lines in the skeleton
function Skeleton:SetColor(Color)
    self.Color = Color
    for _, l in pairs(self.Lines) do
        l[1].Color = Color
        l[2].Color = Color
    end
end

-- Set the transparency for all lines in the skeleton
function Skeleton:SetAlpha(Alpha)
    self.Alpha = Alpha
    for _, l in pairs(self.Lines) do
        l[1].Transparency = Alpha
        l[2].Transparency = Alpha
    end
end

-- Set the thickness for all lines in the skeleton
function Skeleton:SetThickness(Thickness)
    self.Thickness = Thickness
    for _, l in pairs(self.Lines) do
        l[1].Thickness = Thickness
        l[2].Thickness = Thickness
    end
end

-- Set whether substeps should be drawn
function Skeleton:SetDoSubsteps(State)
    self.DoSubsteps = State
end

-- Check if a part is visible to the camera using raycasting
function Skeleton:IsVisible(part)
    local ray = Ray.new(Camera.CFrame.p, (part.Position - Camera.CFrame.p).unit * 1000) -- Create a ray from the camera to the part
    local hit, position = workspace:FindPartOnRay(ray, self.Player.Character)
    return hit == nil -- If the ray doesn't hit anything, the part is visible
end

-- Update the skeleton in the main loop
function Skeleton:Update()
    if self.Removed then
        return
    end

    local Character = self.Player.Character
    if not Character then
        self:SetVisible(false)
        if not self.Player.Parent then
            self:Remove()
        end
        return
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then
        self:SetVisible(false)
        return
    end

    self:SetColor(self.Color)
    self:SetAlpha(self.Alpha)
    self:SetThickness(self.Thickness)

    local update = false
    for _, l in pairs(self.Lines) do
        local part = Character:FindFirstChild(l[3])
        if not part then
            l[1].Visible = false
            l[2].Visible = false
            update = true
            continue
        end

        local link = part:FindFirstChild(l[4])
        if not (link and link.part0 and link.part1) then
            l[1].Visible = false
            l[2].Visible = false
            update = true
            continue
        end

        local part0 = link.Part0
        local part1 = link.Part1

        local isPart0Visible = self:IsVisible(part0)
        local isPart1Visible = self:IsVisible(part1)

        -- If part is visible and it's a teammate, color it blue
        if self.Player.Team == LocalPlayer.Team then
            if isPart0Visible then
                l[1].Color = Color3.fromRGB(0, 0, 255) -- Blue for teammates
                l[1].Visible = true
            else
                l[1].Color = Color3.fromRGB(255, 0, 0) -- Red for teammates if not visible
                l[1].Visible = true
            end

            if isPart1Visible then
                l[2].Color = Color3.fromRGB(0, 0, 255) -- Blue for teammates
                l[2].Visible = true
            else
                l[2].Color = Color3.fromRGB(255, 0, 0) -- Red for teammates if not visible
                l[2].Visible = true
            end
        else
            -- If part is visible and it's an enemy, color it green
            if isPart0Visible then
                l[1].Color = Color3.fromRGB(0, 255, 0) -- Green for enemies
                l[1].Visible = true
            else
                l[1].Color = Color3.fromRGB(255, 0, 0) -- Red for enemies if not visible
                l[1].Visible = true
            end

            if isPart1Visible then
                l[2].Color = Color3.fromRGB(0, 255, 0) -- Green for enemies
                l[2].Visible = true
            else
                l[2].Color = Color3.fromRGB(255, 0, 0) -- Red for enemies if not visible
                l[2].Visible = true
            end
        end
    end

    if update or #self.Lines == 0 then
        self:UpdateStructure()
    end
end

-- Toggle the visibility of the skeleton
function Skeleton:Toggle()
    self.Visible = not self.Visible

    if self.Visible then
        self:RemoveLines()
        self:UpdateStructure()

        local c
        c = RS.Heartbeat:Connect(function()
            if not self.Visible then
                self:SetVisible(false)
                c:Disconnect()
                return
            end

            self:Update()
        end)
    end
end

-- Remove all lines from the skeleton
function Skeleton:RemoveLines()
    for _, l in pairs(self.Lines) do
        l[1]:Remove()
        l[2]:Remove()
    end
    self.Lines = {}
end

-- Remove the skeleton entirely
function Skeleton:Remove()
    self.Removed = true
    self:RemoveLines()
end

-- Create a new Skeleton for a player
function Library:NewSkeleton(Player, Visible, Color, Alpha, Thickness, DoSubsteps)
    if not Player then
        error("Missing Player argument (#1)")
    end

    local s = setmetatable({}, Skeleton)

    s.Player = Player
    s.Bind = Player.UserId

    if DoSubsteps ~= nil then
        s.DoSubsteps = DoSubsteps
    end

    if Color then
        s:SetColor(Color)
    end

    if Alpha then
        s:SetAlpha(Alpha)
    end

    if Thickness then
        s:SetThickness(Thickness)
    end

    if Visible then
        s:Toggle()
    end

    return s
end

-- Returning the Library to make it usable
return Library
