-- Roblox Mobile Client Utility Tool - Gun Game Debug & Training
-- Tối ưu cho màn hình cảm ứng Mobile
-- Tạo bởi: AI Assistant

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- LocalPlayer
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHumanoid = LocalCharacter:WaitForChild("Humanoid")
local LocalRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")

-- Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local MenuOpen = false
local ESPEnabled = false
local HitboxExpanderEnabled = false
local AimbotEnabled = false
local TargetPlayer = nil
local ESPHighlights = {}
local ESPColor = Color3.new(1, 0, 0)
local FOVRadius = 200 -- Kích thước vòng tròn FOV

-- Tạo nút kéo thả cho Mobile
local function CreateMobileButton()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileMenuButton"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MenuButton = Instance.new("ImageButton")
    MenuButton.Name = "MenuButton"
    MenuButton.Size = UDim2.new(0, 60, 0, 60)
    MenuButton.Position = UDim2.new(0, 50, 0, 100)
    MenuButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    MenuButton.BorderSizePixel = 2
    MenuButton.BorderColor3 = Color3.new(1, 1, 1)
    MenuButton.Image = "rbxasset://textures/ui/InspectMenu/focus.png"
    MenuButton.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 30)
    UICorner.Parent = MenuButton
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    MenuButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MenuButton.Position
        elseif input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            MenuOpen = not MenuOpen
            if MenuOpen then
                Rayfield:ShowWindow()
                MenuButton.ImageColor3 = Color3.new(0, 1, 0)
            else
                Rayfield:HideWindow()
                MenuButton.ImageColor3 = Color3.new(1, 1, 1)
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            MenuButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return ScreenGui
end

-- Tạo FOV Circle
local function CreateFOVCircle()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FOVCircle"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local FOVFrame = Instance.new("Frame")
    FOVFrame.Name = "FOVFrame"
    FOVFrame.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
    FOVFrame.Position = UDim2.new(0.5, -FOVRadius, 0.5, -FOVRadius)
    FOVFrame.BackgroundTransparency = 1
    FOVFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.5, 0)
    UICorner.Parent = FOVFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.new(1, 0, 0)
    UIStroke.Transparency = 0.5
    UIStroke.Parent = FOVFrame
    
    return ScreenGui, FOVFrame
end

-- Tạo Window chính
local Window = Rayfield:CreateWindow({
    Name = "📱 Mobile Utility Tool",
    LoadingTitle = "Đang tải...",
    LoadingSubtitle = "Mobile Version",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MobileUtilityTool",
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false,
})

-- Tab Visuals
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)

-- Player ESP Section
local ESPSection = VisualsTab:CreateSection("🎯 Player ESP")

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

-- Hitbox Expander Section
local HitboxSection = VisualsTab:CreateSection("📦 Hitbox Expander")

VisualsTab:CreateToggle({
    Name = "Bật Hitbox Expander",
    CurrentValue = false,
    Flag = "Hitbox_Expander",
    Callback = function(Value)
        HitboxExpanderEnabled = Value
    end,
})

-- Tab Combat
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)

-- Aimbot Section
local AimbotSection = CombatTab:CreateSection("🎯 Aimbot")

CombatTab:CreateToggle({
    Name = "Bật Aimbot (FOV Auto Lock)",
    CurrentValue = false,
    Flag = "Aimbot_Enabled",
    Callback = function(Value)
        AimbotEnabled = Value
        if not Value then
            TargetPlayer = nil
        end
    end,
})

CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {100, 400},
    Increment = 10,
    CurrentValue = 200,
    Flag = "FOV_Radius",
    Callback = function(Value)
        FOVRadius = Value
        UpdateFOVSize()
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
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0.2
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Parent = Character
    
    ESPHighlights[Player] = {
        Highlight = Highlight
    }
end

function RemoveESP()
    for Player, ESPData in pairs(ESPHighlights) do
        if ESPData.Highlight then
            ESPData.Highlight:Destroy()
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
    end
end

-- Hitbox Expander - Ép kích thước Head và HumanoidRootPart
function ExpandHitboxes()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Character = Player.Character
            local Head = Character:FindFirstChild("Head")
            local RootPart = Character:FindFirstChild("HumanoidRootPart")
            
            if Head then
                Head.Size = Vector3.new(20, 20, 20)
                Head.Transparency = 0.5
                Head.BrickColor = BrickColor.new("Really red")
                Head.CanCollide = false
                Head.Material = Enum.Material.ForceField
            end
            
            if RootPart then
                RootPart.Size = Vector3.new(20, 20, 20)
                RootPart.Transparency = 0.5
                RootPart.BrickColor = BrickColor.new("Really red")
                RootPart.CanCollide = false
                RootPart.Material = Enum.Material.ForceField
            end
        end
    end
end

-- Aimbot với FOV
function GetNearestPlayerInFOV()
    local NearestPlayer = nil
    local NearestDistance = math.huge
    local Camera = workspace.CurrentCamera
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Character = Player.Character
            local Head = Character:FindFirstChild("Head")
            if Head then
                local Vector, OnScreen = Camera:WorldToScreenPoint(Head.Position)
                if OnScreen then
                    local MousePosition = UserInputService:GetMouseLocation()
                    local Distance = (Vector2.new(Vector.X, Vector.Y) - MousePosition).Magnitude
                    
                    if Distance <= FOVRadius and Distance < NearestDistance then
                        NearestDistance = Distance
                        NearestPlayer = Player
                    end
                end
            end
        end
    end
    
    return NearestPlayer
end

function Aimbot()
    if AimbotEnabled then
        TargetPlayer = GetNearestPlayerInFOV()
        if TargetPlayer and TargetPlayer.Character then
            local Head = TargetPlayer.Character:FindFirstChild("Head")
            if Head then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, Head.Position)
            end
        end
    end
end

function UpdateFOVSize()
    local FOVGui = game:GetService("CoreGui"):FindFirstChild("FOVCircle")
    if FOVGui then
        local FOVFrame = FOVGui:FindFirstChild("FOVFrame")
        if FOVFrame then
            FOVFrame.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
            FOVFrame.Position = UDim2.new(0.5, -FOVRadius, 0.5, -FOVRadius)
        end
    end
end

-- RenderStepped loop - Tối ưu cho Mobile
RunService.RenderStepped:Connect(function()
    -- Hitbox Expander - Luôn ép kích thước
    if HitboxExpanderEnabled then
        ExpandHitboxes()
    end
    
    -- Aimbot
    Aimbot()
end)

-- Player events
Players.PlayerAdded:Connect(function(Player)
    if ESPEnabled then
        Player.CharacterAdded:Connect(function()
            CreatePlayerESP(Player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    -- Dọn dẹp ESP
    if ESPHighlights[Player] then
        if ESPHighlights[Player].Highlight then
            ESPHighlights[Player].Highlight:Destroy()
        end
        ESPHighlights[Player] = nil
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

-- Initialize
CreateMobileButton()
CreateFOVCircle()

-- Initialize cho người chơi hiện có
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        Player.CharacterAdded:Connect(function(Character)
            if ESPEnabled then
                CreatePlayerESP(Player)
            end
        end)
    end
end

-- Ẩn window ban đầu
Rayfield:HideWindow()

-- Thông báo
Rayfield:Notify({
    Title = "📱 Mobile Tool Ready",
    Content = "Nhấn nút tròn để mở menu!",
    Duration = 3,
    Image = 4483362458,
})

print("📱 Mobile Client Utility Tool đã được tải!")
print("🎯 Tính năng:")
print("- Nút kéo thả để mở/đóng menu")
print("- Player ESP tối ưu")
print("- Hitbox Expander (20x20x20)")
print("- FOV Aimbot Auto Lock")
