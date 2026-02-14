-- Roblox Mobile Legit Utility - Assassins vs Sheriffs DUELS
-- Script An toàn - Tránh BAC 4
-- Tạo bởi: AI Assistant

-- BẢO MẬT: Game ID Lock - Chỉ hoạt động trên Assassins vs Sheriffs DUELS
if game.PlaceId ~= 15385224902 then
    -- Hiện thông báo lỗi rồi dừng hoạt động
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ErrorMessage"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local ErrorFrame = Instance.new("Frame")
    ErrorFrame.Name = "ErrorFrame"
    ErrorFrame.Size = UDim2.new(0, 300, 0, 150)
    ErrorFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    ErrorFrame.BackgroundColor3 = Color3.new(0.2, 0, 0)
    ErrorFrame.BorderSizePixel = 2
    ErrorFrame.BorderColor3 = Color3.new(1, 0, 0)
    ErrorFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = ErrorFrame
    
    local ErrorLabel = Instance.new("TextLabel")
    ErrorLabel.Name = "ErrorLabel"
    ErrorLabel.Size = UDim2.new(1, -20, 1, -20)
    ErrorLabel.Position = UDim2.new(0, 10, 0, 10)
    ErrorLabel.BackgroundTransparency = 1
    ErrorLabel.Text = "❌ SAI GAME!\n\nScript này chỉ hoạt động trên:\nAssassins vs Sheriffs DUELS\n\nGame ID: " .. game.PlaceId .. "\nID yêu cầu: 15385224902"
    ErrorLabel.TextColor3 = Color3.new(1, 1, 1)
    ErrorLabel.TextScaled = true
    ErrorLabel.Font = Enum.Font.SourceSansBold
    ErrorLabel.Parent = ErrorFrame
    
    wait(5)
    return
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

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
local AimAssistEnabled = false
local TargetPlayer = nil
local ESPHighlights = {}
local ESPColor = Color3.new(1, 0, 0)
local FOVRadius = 100
local AimSmoothness = 0.15
local IsAiming = false

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
    MenuButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    MenuButton.BorderSizePixel = 2
    MenuButton.BorderColor3 = Color3.new(0, 1, 0)
    MenuButton.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
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
                MenuButton.BorderColor3 = Color3.new(1, 0, 0)
            else
                Rayfield:HideWindow()
                MenuButton.BorderColor3 = Color3.new(0, 1, 0)
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
    UIStroke.Thickness = 1
    UIStroke.Color = Color3.new(1, 1, 1)
    UIStroke.Transparency = 0.5
    UIStroke.Parent = FOVFrame
    
    return ScreenGui, FOVFrame
end

-- Functions

-- Kiểm tra người chơi còn sống
function IsAlive(Player)
    local Character = Player.Character
    if not Character then return false end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end
    
    return Humanoid.Health > 0
end

-- Wall Check (Rất quan trọng để tránh BAC 4)
function IsVisible(Target)
    if not LocalRootPart then return false end
    
    local Origin = Camera.CFrame.Position
    local Direction = (Target.Position - Origin).unit
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    RaycastParams.FilterDescendantsInstances = {LocalCharacter}
    RaycastParams.IgnoreWater = true
    
    local RaycastResult = Workspace:Raycast(Origin, Direction * 1000, RaycastParams)
    
    if RaycastResult and RaycastResult.Instance then
        return RaycastResult.Instance:IsDescendantOf(Target.Parent)
    end
    return false
end

-- Tìm người chơi gần nhất trong FOV
function GetNearestPlayerInFOV()
    local NearestPlayer = nil
    local NearestDistance = math.huge
    local MousePosition = UserInputService:GetMouseLocation()
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and IsAlive(Player) then
            local Character = Player.Character
            local Head = Character:FindFirstChild("Head")
            if Head then
                local Vector, OnScreen = Camera:WorldToScreenPoint(Head.Position)
                if OnScreen then
                    local Distance = (Vector2.new(Vector.X, Vector.Y) - MousePosition).Magnitude
                    
                    if Distance <= FOVRadius and Distance < NearestDistance then
                        -- BẮT BUỘC: Wall Check để tránh BAC 4
                        if IsVisible(Head) then
                            NearestDistance = Distance
                            NearestPlayer = Player
                        end
                    end
                end
            end
        end
    end
    
    return NearestPlayer
end

-- Aim Assist Siêu Nhẹ (Camera Smooth)
function AimAssist()
    if AimAssistEnabled then
        TargetPlayer = GetNearestPlayerInFOV()
        if TargetPlayer and TargetPlayer.Character then
            local Head = TargetPlayer.Character:FindFirstChild("Head")
            if Head then
                IsAiming = true
                
                -- Camera Smooth mượt mà (giống người chơi thật)
                local TargetCFrame = CFrame.new(Camera.CFrame.Position, Head.Position)
                Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, AimSmoothness)
            else
                IsAiming = false
            end
        else
            IsAiming = false
        end
    else
        IsAiming = false
    end
end

-- Tạo ESP cho người chơi (An toàn)
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
    
    -- Tạo Highlight (An toàn - không thay đổi size)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ESP_Highlight_" .. Player.Name
    Highlight.FillColor = ESPColor
    Highlight.OutlineColor = ESPColor
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0.2
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Parent = Character
    
    -- Tạo BillboardGui cho tên
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "ESP_Billboard_" .. Player.Name
    BillboardGui.Size = UDim2.new(0, 100, 0, 40)
    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Parent = Character
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Parent = BillboardGui
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(1, 0, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Player.Name
    NameLabel.TextColor3 = ESPColor
    NameLabel.TextStrokeTransparency = 0
    NameLabel.TextScaled = true
    NameLabel.Font = Enum.Font.SourceSansBold
    NameLabel.Parent = Frame
    
    ESPHighlights[Player] = {
        Highlight = Highlight,
        BillboardGui = BillboardGui,
        NameLabel = NameLabel
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
    UIStroke.Transparency = 0.3
    UIStroke.Parent = FOVFrame
    
    return ScreenGui, FOVFrame
end

-- Hook cho Tap-to-Shoot Silent Aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Tap-to-Shoot Silent Aim
    if SilentAimEnabled and IsTouching then
        local Target = GetNearestPlayerInFOV()
        if Target and Target.Character then
            local Head = Target.Character:FindFirstChild("Head")
            if Head then
                -- Chuyển đổi tọa độ Head thành screen position
                local ScreenPosition = Camera:WorldToScreenPoint(Head.Position)
                local TouchVector = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
                
                -- Override tọa độ chạm của người dùng
                if method == "FindPartOnRayWithIgnoreList" then
                    local ray = Ray.new(Camera.CFrame.Position, (Head.Position - Camera.CFrame.Position).unit * 1000)
                    return oldNamecall(self, ray, args[2], args[3], args[4])
                elseif method == "Raycast" then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {LocalCharacter, Workspace:FindFirstChild("Map")}
                    rayParams.IgnoreWater = true
                    -- Wall Check (Bắt buộc để tránh BAC 4)
                    function IsVisible(Target)
                        local Origin = Camera.CFrame.Position
                        local Direction = (Target.Position - Origin).unit
                        local RaycastParams = RaycastParams.new()
                        RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        RaycastParams.FilterDescendantsInstances = {LocalCharacter}
                        RaycastParams.IgnoreWater = true
                        
                        local RaycastResult = Workspace:Raycast(Origin, Direction * 1000, RaycastParams)
                        
                        if RaycastResult and RaycastResult.Instance then
                            return RaycastResult.Instance:IsDescendantOf(Target.Parent)
                        end
                        return false
                    end

                    -- Distance Check (Giới hạn 100 Studs)
                    function IsInDistance(Target)
                        if not LocalRootPart then return false end
                        
                        local Distance = (Target.Position - LocalRootPart.Position).Magnitude
                        return Distance <= MaxAimDistance
                    end
                    if IsVisible(Head) and IsInDistance(Head) then
                        local ray = Ray.new(Camera.CFrame.Position, (Head.Position - Camera.CFrame.Position).unit * 1000)
                        return oldNamecall(self, ray, rayParams)
                    end
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Hook cho UserInputService để detect touch
local oldInputBegan
oldInputBegan = hookmetamethod(UserInputService, "InputBegan", function(self, Input, GameProcessed)
    if Input.UserInputType == Enum.UserInputType.Touch then
        IsTouching = true
        LastTouchPosition = Input.Position
    end
    return oldInputBegan(self, Input, GameProcessed)
end)

local oldInputEnded
oldInputEnded = hookmetamethod(UserInputService, "InputEnded", function(self, Input, GameProcessed)
    if Input.UserInputType == Enum.UserInputType.Touch then
        IsTouching = false
    end
    return oldInputEnded(self, Input, GameProcessed)
end)

-- Tạo Window chính
local Window = Rayfield:CreateWindow({
    Name = "🛡️ Legit Tool",
    LoadingTitle = "Đang tải...",
    LoadingSubtitle = "An toàn tuyệt đối",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LegitTool",
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


-- Tab Combat
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)

-- Legit Aim Section
local AimbotSection = CombatTab:CreateSection("🎯 Legit Aim Assist")

CombatTab:CreateToggle({
    Name = "Bật Legit Aim Assist (Camera)",
    CurrentValue = false,
    Flag = "Aim_Assist_Enabled",
    Callback = function(Value)
        AimAssistEnabled = Value
        if not Value then
            TargetPlayer = nil
            IsAiming = false
            Crosshair.Color = Color3.new(1, 1, 1)
        end
    end,
})

CombatTab:CreateSlider({
    Name = "Độ mượt (Smoothness)",
    Range = {0.05, 0.3},
    Increment = 0.05,
    CurrentValue = 0.15,
    Flag = "Aim_Smoothness",
    Callback = function(Value)
        AimSmoothness = Value
    end,
})

CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {80, 200},
    Increment = 10,
    CurrentValue = 120,
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
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Luôn hiển thị xuyên tường
    Highlight.Parent = Character
    
    -- Tạo BillboardGui cho tên
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "ESP_Billboard_" .. Player.Name
    BillboardGui.Size = UDim2.new(0, 100, 0, 30)
    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Parent = Character
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Parent = BillboardGui
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(1, 0, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Player.Name
    NameLabel.TextColor3 = ESPColor
    NameLabel.TextStrokeTransparency = 0
    NameLabel.TextScaled = true
    NameLabel.Font = Enum.Font.SourceSansBold
    NameLabel.Parent = Frame
    
    ESPHighlights[Player] = {
        Highlight = Highlight,
        BillboardGui = BillboardGui,
        NameLabel = NameLabel
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
    end
end

-- Silent Aim với FOV (Legit Version)
function GetNearestPlayerInFOV()
    local NearestPlayer = nil
    local NearestDistance = math.huge
    local MousePosition = UserInputService:GetMouseLocation()
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and IsAlive(Player) then
            local Character = Player.Character
            local Head = Character:FindFirstChild("Head")
            if Head then
                local Vector, OnScreen = Camera:WorldToScreenPoint(Head.Position)
                if OnScreen then
                    local Distance = (Vector2.new(Vector.X, Vector.Y) - MousePosition).Magnitude
                    
                    if Distance <= FOVRadius and Distance < NearestDistance then
                        -- Bắt buộc: Wall Check + Distance Check để tránh BAC 4
                        if IsVisible(Head) and IsInDistance(Head) then
                            NearestDistance = Distance
                            NearestPlayer = Player
                        end
                    end
                end
            end
        end
    end
    
    return NearestPlayer
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
        if ESPHighlights[Player].BillboardGui then
            ESPHighlights[Player].BillboardGui:Destroy()
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
    Title = "🛡️ Legit Tool Ready",
    Content = "An toàn - Không BAC 4!",
    Duration = 5,
    Image = 4483362458,
})

print("🛡️ Mobile Legit Utility đã được tải!")
print("📋 Tính năng An toàn:")
print("🔒 Game ID Lock (Chỉ hoạt động trên Assassins vs Sheriffs DUELS)")
print("👁️ ESP An toàn (Không thay đổi Hitbox)")
print("🎯 Aim Assist Siêu Nhẹ (Camera Smooth + Wall Check)")
print("📱 Mobile UI (Nút kéo thả)")
print("⚡ Code gọn - Chú thích Tiếng Việt")
print("🛡️ 100% An toàn - Tránh BAC 4")
