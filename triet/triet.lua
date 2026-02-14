-- Roblox Client Utility Tool - Gun Game Debug & Training
-- Sử dụng Rayfield UI Library
-- Tạo bởi: AI Assistant

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- LocalPlayer
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHumanoid = LocalCharacter:WaitForChild("Humanoid")
local LocalRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")

-- Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local CameraLockEnabled = false
local TargetPlayer = nil
local InfiniteJumpEnabled = false
local ESPHighlights = {}
local HitboxParts = {}

-- Tạo Window chính
local Window = Rayfield:CreateWindow({
    Name = "🎯 Client Utility Tool - Gun Game Debug",
    LoadingTitle = "Đang tải bộ công cụ...",
    LoadingSubtitle = "Chờ xíu nhé...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ClientUtilityTool",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Tab Visuals
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)

-- Player ESP Section
local ESPSection = VisualsTab:CreateSection("🎯 Player ESP")

local ESPEnabled = false
local ESPColor = Color3.new(1, 0, 0) -- Màu đỏ

VisualsTab:CreateToggle({
    Name = "Bật Player ESP",
    CurrentValue = false,
    Flag = "ESP_Enabled",
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            CreateESP()
        else
            RemoveESP()
        end
    end,
})

VisualsTab:CreateColorPicker({
    Name = "Màu ESP",
    Color = Color3.new(1, 0, 0),
    Flag = "ESP_Color",
    Callback = function(Value)
        ESPColor = Value
        UpdateESPColors()
    end,
})

-- Hitbox Visualizer Section
local HitboxSection = VisualsTab:CreateSection("📦 Hitbox Visualizer")

local HitboxEnabled = false

VisualsTab:CreateToggle({
    Name = "Bật Hitbox Visualizer",
    CurrentValue = false,
    Flag = "Hitbox_Enabled",
    Callback = function(Value)
        HitboxEnabled = Value
        if Value then
            CreateHitboxes()
        else
            RemoveHitboxes()
        end
    end,
})

VisualsTab:CreateSlider({
    Name = "Kích thước Hitbox",
    Range = {10, 30},
    Increment = 1,
    CurrentValue = 20,
    Flag = "Hitbox_Size",
    Callback = function(Value)
        UpdateHitboxSize(Value)
    end,
})

-- Tab Assist
local AssistTab = Window:CreateTab("🎮 Assist", 4483362458)

-- Camera Lock Section
local CameraSection = AssistTab:CreateSection("📷 Camera Lock")

VisualsTab:CreateToggle({
    Name = "Camera Lock (Nhấn Q)",
    CurrentValue = false,
    Flag = "Camera_Lock",
    Callback = function(Value)
        CameraLockEnabled = Value
        if not Value then
            TargetPlayer = nil
        end
    end,
})

AssistTab:CreateKeybind({
    Name = "Phím Camera Lock",
    CurrentKeybind = "Q",
    HoldToInteract = false,
    Flag = "Camera_Lock_Key",
    Callback = function(Keybind)
        -- Keybind đã được thiết lập
    end,
})

-- Tab LocalPlayer
local PlayerTab = Window:CreateTab("👤 LocalPlayer", 4483362458)

-- Movement Section
local MovementSection = PlayerTab:CreateSection("🏃 Movement")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Flag = "Walk_Speed",
    Callback = function(Value)
        if LocalHumanoid then
            LocalHumanoid.WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Flag = "Jump_Power",
    Callback = function(Value)
        if LocalHumanoid then
            LocalHumanoid.JumpPower = Value
        end
    end,
})

-- Jump Section
local JumpSection = PlayerTab:CreateSection("🦘 Jump")

PlayerTab:CreateToggle({
    Name = "Vô hạn nhảy",
    CurrentValue = false,
    Flag = "Infinite_Jump",
    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end,
})

-- Functions

-- Tạo ESP cho người chơi
function CreateESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            CreatePlayerESP(Player)
        end
    end
end

function CreatePlayerESP(Player)
    local Character = Player.Character
    if not Character then return end
    
    -- Tạo Highlight
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ESP_Highlight_" .. Player.Name
    Highlight.FillColor = ESPColor
    Highlight.OutlineColor = ESPColor
    Highlight.FillTransparency = 0.3
    Highlight.OutlineTransparency = 0
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Luôn hiển thị trên cùng
    Highlight.Parent = Character
    
    -- Tạo BillboardGui cho tên và khoảng cách
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "ESP_Billboard_" .. Player.Name
    BillboardGui.Size = UDim2.new(0, 100, 0, 50)
    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Parent = Character
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Parent = BillboardGui
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    NameLabel.Position = UDim2.new(0, 0, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Player.Name
    NameLabel.TextColor3 = ESPColor
    NameLabel.TextStrokeTransparency = 0
    NameLabel.TextScaled = true
    NameLabel.Font = Enum.Font.SourceSansBold
    NameLabel.Parent = Frame
    
    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Name = "DistanceLabel"
    DistanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    DistanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.Text = "0m"
    DistanceLabel.TextColor3 = ESPColor
    DistanceLabel.TextStrokeTransparency = 0
    DistanceLabel.TextScaled = true
    DistanceLabel.Font = Enum.Font.SourceSans
    DistanceLabel.Parent = Frame
    
    ESPHighlights[Player] = {
        Highlight = Highlight,
        BillboardGui = BillboardGui,
        NameLabel = NameLabel,
        DistanceLabel = DistanceLabel
    }
end

function RemoveESP()
    for Player, ESPData in pairs(ESPHighlights) do
        if ESPData.Highlight then
            ESPData.Highlight:Destroy()
        end
        if ESPData.BillboardGui then
            ESPData.BillboardGui:Destroy()
        end
    end
    ESPHighlights = {}
end

function UpdateESPColors()
    for Player, ESPData in pairs(ESPHighlights) do
        if ESPData.Highlight then
            ESPData.Highlight.FillColor = ESPColor
            ESPData.Highlight.OutlineColor = ESPColor
        end
        if ESPData.NameLabel then
            ESPData.NameLabel.TextColor3 = ESPColor
        end
        if ESPData.DistanceLabel then
            ESPData.DistanceLabel.TextColor3 = ESPColor
        end
    end
end

-- Tạo Hitbox Visualizer
function CreateHitboxes()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            CreatePlayerHitbox(Player)
        end
    end
end

function CreatePlayerHitbox(Player)
    local Character = Player.Character
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    -- Tạo Part cho hitbox
    local HitboxPart = Instance.new("Part")
    HitboxPart.Name = "Hitbox_" .. Player.Name
    HitboxPart.Size = Vector3.new(20, 20, 20) -- Kích thước lớn như yêu cầu
    HitboxPart.Material = Enum.Material.ForceField
    HitboxPart.BrickColor = BrickColor.new("Really red")
    HitboxPart.Transparency = 0.7
    HitboxPart.CanCollide = false -- Quan trọng: không va chạm với tường
    HitboxPart.Anchored = false
    HitboxPart.Massless = true
    
    -- Weld để gắn vào HumanoidRootPart
    local Weld = Instance.new("Weld")
    Weld.Part0 = RootPart
    Weld.Part1 = HitboxPart
    Weld.C0 = CFrame.new(0, 0, 0)
    Weld.Parent = HitboxPart
    
    HitboxPart.Parent = Character
    
    HitboxParts[Player] = HitboxPart
end

function RemoveHitboxes()
    for Player, HitboxPart in pairs(HitboxParts) do
        if HitboxPart then
            HitboxPart:Destroy()
        end
    end
    HitboxParts = {}
end

function UpdateHitboxSize(Size)
    for Player, HitboxPart in pairs(HitboxParts) do
        if HitboxPart then
            HitboxPart.Size = Vector3.new(Size, Size, Size)
        end
    end
end

-- Camera Lock
function GetNearestPlayer()
    local NearestPlayer = nil
    local NearestDistance = math.huge
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Character = Player.Character
            local Head = Character:FindFirstChild("Head")
            if Head then
                local Distance = (LocalRootPart.Position - Head.Position).Magnitude
                if Distance < NearestDistance then
                    NearestDistance = Distance
                    NearestPlayer = Player
                end
            end
        end
    end
    
    return NearestPlayer
end

function CameraLock()
    if CameraLockEnabled and TargetPlayer and TargetPlayer.Character then
        local Head = TargetPlayer.Character:FindFirstChild("Head")
        if Head then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, Head.Position)
        end
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    
    -- Camera Lock với phím Q
    if Input.KeyCode == Enum.KeyCode.Q then
        if CameraLockEnabled then
            TargetPlayer = GetNearestPlayer()
        end
    end
    
    -- Infinite Jump
    if Input.KeyCode == Enum.KeyCode.Space and InfiniteJumpEnabled then
        if LocalHumanoid then
            LocalHumanoid.Jump = true
        end
    end
end)

-- RenderStepped loop
RunService.RenderStepped:Connect(function()
    -- Cập nhật khoảng cách ESP
    for Player, ESPData in pairs(ESPHighlights) do
        if Player.Character and ESPData.DistanceLabel then
            local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if RootPart then
                local Distance = math.floor((LocalRootPart.Position - RootPart.Position).Magnitude)
                ESPData.DistanceLabel.Text = tostring(Distance) .. "m"
            end
        end
    end
    
    -- Camera Lock
    CameraLock()
end)

-- Player events
Players.PlayerAdded:Connect(function(Player)
    if ESPEnabled then
        Player.CharacterAdded:Connect(function()
            CreatePlayerESP(Player)
        end)
    end
    if HitboxEnabled then
        Player.CharacterAdded:Connect(function()
            CreatePlayerHitbox(Player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    -- Dọn dẹp ESP
    if ESPHighlights[Player] then
        if ESPHighlights[Player].Highlight then
            ESPHighlights[Player].Highlight:Destroy()
        end
        if ESPHighlights[Player].BillboardGui then
            ESPHighlights[Player].BillboardGui:Destroy()
        end
        ESPHighlights[Player] = nil
    end
    
    -- Dọn dẹp Hitbox
    if HitboxParts[Player] then
        HitboxParts[Player]:Destroy()
        HitboxParts[Player] = nil
    end
    
    -- Xóa target nếu là người chơi đã thoát
    if TargetPlayer == Player then
        TargetPlayer = nil
    end
end)

-- Character added events cho local player
LocalPlayer.CharacterAdded:Connect(function(Character)
    LocalCharacter = Character
    LocalHumanoid = Character:WaitForChild("Humanoid")
    LocalRootPart = Character:WaitForChild("HumanoidRootPart")
end)

-- Initialize cho người chơi hiện có
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        Player.CharacterAdded:Connect(function(Character)
            if ESPEnabled then
                CreatePlayerESP(Player)
            end
            if HitboxEnabled then
                CreatePlayerHitbox(Player)
            end
        end)
    end
end

-- Thông báo
Rayfield:Notify({
    Title = "✅ Client Utility Tool",
    Content = "Đã tải xong bộ công cụ! Sử dụng các tab để điều chỉnh tính năng.",
    Duration = 5,
    Image = 4483362458,
})

print("🎯 Client Utility Tool đã được tải thành công!")
print("📝 Các tính năng:")
print("- Player ESP với Highlight và BillboardGui")
print("- Hitbox Visualizer với kích thước lớn")
print("- Camera Lock (nhấn Q)")
print("- Walk Speed và Jump Power điều chỉnh")
print("- Infinite Jump")
