
--[[
    UNIVERSAL DELTA HUB
    Theme: Black + Purple Neon
    Executor: Delta Android
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GUI = Instance.new("ScreenGui")
GUI.Name = "UniversalDeltaHub"
GUI.ResetOnSpawn = false

pcall(function()
    GUI.Parent = game:GetService("CoreGui")
end)

if not GUI.Parent then
    GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 390)
Main.Position = UDim2.new(0.5, -140, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(15, 12, 23)
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(160, 70, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(75, 25, 130)
Title.Text = "UNIVERSAL DELTA HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- Draggable
local dragging, dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local ESP = false
local Lines = false

local function createButton(name, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.88, 0, 0, 36)
    button.Position = UDim2.new(0.06, 0, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(45, 25, 65)
    button.TextColor3 = Color3.new(1,1,1)
    button.Text = name .. " : OFF"
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = Main

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    local enabled = false

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = name .. (enabled and " : ON" or " : OFF")
        callback(enabled)
    end)

    return button
end

local function removeESP(player)
    if player.Character then
        local h = player.Character:FindFirstChild("DeltaHighlight")
        if h then h:Destroy() end

        local head = player.Character:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("DeltaName")
            if tag then tag:Destroy() end
        end
    end
end

local function applyESP(player)
    if not ESP or player == LocalPlayer then return end

    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    if not character:FindFirstChild("DeltaHighlight") then
        local h = Instance.new("Highlight")
        h.Name = "DeltaHighlight"
        h.FillColor = Color3.fromRGB(155, 50, 255)
        h.OutlineColor = Color3.fromRGB(210, 150, 255)
        h.Parent = character
    end

    if not head:FindFirstChild("DeltaName") then
        local tag = Instance.new("BillboardGui")
        tag.Name = "DeltaName"
        tag.Size = UDim2.new(0, 180, 0, 35)
        tag.StudsOffset = Vector3.new(0, 2.5, 0)
        tag.AlwaysOnTop = true
        tag.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(210, 150, 255)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = tag

        RunService.RenderStepped:Connect(function()
            if not tag.Parent then return end
            local distance = LocalPlayer:DistanceFromCharacter(head.Position)
            label.Text = player.Name .. " [" ..
                math.floor(distance) .. "m]"
        end)
    end
end

createButton("PLAYER ESP", 65, function(value)
    ESP = value

    for _, player in ipairs(Players:GetPlayers()) do
        if value then
            applyESP(player)
        else
            removeESP(player)
        end
    end
end)

createButton("TRACER LINE", 110, function(value)
    Lines = value
    -- Tracer requires a separate Drawing API;
    -- not supported by every executor.
end)

createButton("SPEED BOOST", 155, function(value)
    local humanoid = LocalPlayer.Character and
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = value and 32 or 16
    end
end)

createButton("JUMP BOOST", 200, function(value)
    local humanoid = LocalPlayer.Character and
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value and 100 or 50
    end
end)

createButton("HIDE GUI", 245, function(value)
    Main.Visible = not value
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        applyESP(player)
    end)
end)

Players.PlayerRemoving:Connect(removeESP)

for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        task.wait(1)
        applyESP(player)
    end)
end

print("UNIVERSAL DELTA HUB LOADED!")
