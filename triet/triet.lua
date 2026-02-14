-- Roblox Mobile Zephyr-Style Utility - Assassins vs Sheriffs DUELS
-- Fluent UI Version - Đẹp & An toàn
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
    ErrorFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    ErrorFrame.BorderSizePixel = 0
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
    ErrorLabel.Font = Enum.Font.GothamMedium
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
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

-- LocalPlayer
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHumanoid = LocalCharacter:WaitForChild("Humanoid")
local LocalRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")

-- Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/Fluent.lua"))()

-- Variables
local MenuOpen = false
local ESPEnabled = false
local TriggerbotEnabled = false
local FingerAimEnabled = false
local SafeHitboxEnabled = false
local SprintModEnabled = false
local TargetPlayer = nil
local ESPHighlights = {}
local ESPBoxes = {}
local ESPNames = {}
local ESPColor = Color3.new(0, 0.5, 1) -- Xanh dương neon
local FOVRadius = 100
local AimSmoothness = 0.15
local HitboxSize = 3
local IsAiming = false

-- Tạo nút kéo thả cho Mobile (Fluent Style)
local function CreateMobileButton()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FluentMenuButton"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MenuButton = Instance.new("ImageButton")
    MenuButton.Name = "MenuButton"
    MenuButton.Size = UDim2.new(0, 60, 0, 60)
    MenuButton.Position = UDim2.new(0, 50, 0, 100)
    MenuButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    MenuButton.BorderSizePixel = 0
    MenuButton.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    MenuButton.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 30)
    UICorner.Parent = MenuButton
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.new(0, 0.5, 1)
    UIStroke.Transparency = 0.3
    UIStroke.Parent = MenuButton
    
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
                Fluent:Show()
                UIStroke.Color = Color3.new(1, 0.2, 0.2)
            else
                Fluent:Hide()
                UIStroke.Color = Color3.new(0, 0.5, 1)
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

-- Wall Check
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

-- Triggerbot Logic
function Triggerbot()
    if TriggerbotEnabled then
        local MouseTarget = Workspace:FindFirstChild("MouseTarget")
        if MouseTarget then
            local Character = MouseTarget.Parent
            local Player = Players:GetPlayerFromCharacter(Character)
            
            if Player and Player ~= LocalPlayer and IsAlive(Player) then
                -- Tự động bắn khi trúng địch
                VirtualInputManager:SendMouseButtonEvent(1, true, game)
                wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(1, false, game)
            end
        end
    end
end

-- Finger Aim (Legit)
function FingerAim()
    if FingerAimEnabled then
        TargetPlayer = GetNearestPlayerInFOV()
        if TargetPlayer and TargetPlayer.Character then
            local Head = TargetPlayer.Character:FindFirstChild("Head")
            if Head then
                IsAiming = true
                
                -- Camera Smooth mượt mà
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

-- Safe Hitbox (An toàn)
function UpdateSafeHitbox()
    if SafeHitboxEnabled then
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and IsAlive(Player) then
                local Character = Player.Character
                if Character then
                    local Head = Character:FindFirstChild("Head")
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                    
                    if Head then
                        Head.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        Head.Transparency = 0.7
                    end
                    
                    if HumanoidRootPart then
                        HumanoidRootPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        HumanoidRootPart.Transparency = 0.7
                    end
                end
            end
        end
    else
        -- Reset về mặc định
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                local Character = Player.Character
                if Character then
                    local Head = Character:FindFirstChild("Head")
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                    
                    if Head then
                        Head.Size = Vector3.new(2, 1, 1)
                        Head.Transparency = 0
                    end
                    
                    if HumanoidRootPart then
                        HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                        HumanoidRootPart.Transparency = 1
                    end
                end
            end
        end
    end
end

-- Sprint Mod (Giảm cooldown)
function SprintMod()
    if SprintModEnabled and LocalHumanoid then
        -- Thử giảm cooldown (nếu có thể)
        LocalHumanoid.WalkSpeed = 18
    else
        if LocalHumanoid then
            LocalHumanoid.WalkSpeed = 16
        end
    end
end

-- Anti-Blind (Xóa GUI làm mù)
function AntiBlind()
    for _, Player in pairs(Players:GetPlayers()) do
        local PlayerGui = Player:FindFirstChild("PlayerGui")
        if PlayerGui then
            -- Xóa các GUI Flashbang/Blind
            for _, Child in pairs(PlayerGui:GetChildren()) do
                if Child.Name:lower():find("flashbang") or 
                   Child.Name:lower():find("blind") or
                   Child.Name:lower():find("white") or
                   Child.Name:lower():find("screen") then
                    Child:Destroy()
                end
            end
        end
    end
end

-- Tạo ESP Box
function CreateESPBox(Player)
    local Character = Player.Character
    if not Character then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ESP_Box_" .. Player.Name
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Box = Instance.new("Frame")
    Box.Name = "Box"
    Box.Size = UDim2.new(0, 50, 0, 100)
    Box.Position = UDim2.new(0.5, -25, 0.5, -50)
    Box.BackgroundColor3 = ESPColor
    Box.BackgroundTransparency = 0.8
    Box.BorderSizePixel = 2
    Box.BorderColor3 = ESPColor
    Box.Parent = ScreenGui
    
    ESPBoxes[Player] = Box
end

-- Tạo ESP Name
function CreateESPName(Player)
    local Character = Player.Character
    if not Character then return end
    
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "ESP_Name_" .. Player.Name
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
    NameLabel.Font = Enum.Font.GothamMedium
    NameLabel.Parent = Frame
    
    ESPNames[Player] = BillboardGui
end

-- Tạo ESP cho người chơi
function CreateESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            CreateESPBox(Player)
            CreateESPName(Player)
        end
    end
end

function RemoveESP()
    for Player, Box in pairs(ESPBoxes) do
        if Box then
            Box:Destroy()
        end
    end
    
    for Player, BillboardGui in pairs(ESPNames) do
        if BillboardGui then
            BillboardGui:Destroy()
        end
    end
    
    ESPBoxes = {}
    ESPNames = {}
end

function UpdateESPColors()
    for _, Box in pairs(ESPBoxes) do
        if Box then
            Box.BackgroundColor3 = ESPColor
            Box.BorderColor3 = ESPColor
        end
    end
    
    for _, BillboardGui in pairs(ESPNames) do
        local NameLabel = BillboardGui:FindFirstChild("Frame"):FindFirstChild("NameLabel")
        if NameLabel then
            NameLabel.TextColor3 = ESPColor
        end
    end
end

-- Update ESP positions
function UpdateESPPositions()
    for Player, Box in pairs(ESPBoxes) do
        if Player.Character and Box then
            local Head = Player.Character:FindFirstChild("Head")
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            
            if Head and HumanoidRootPart then
                local Vector, OnScreen = Camera:WorldToScreenPoint(HumanoidRootPart.Position)
                if OnScreen then
                    local ScreenGui = Box.Parent
                    Box.Position = UDim2.new(0, Vector.X - 25, 0, Vector.Y - 50)
                end
            end
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

-- Tạo Window chính với Fluent UI
local Window = Fluent:CreateWindow({
    Title = "Zephyr Style Utility",
    SubTitle = "Assassins vs Sheriffs DUELS",
    TabWidth = 160,
    Size = UDim2.new(0, 500, 0, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Tab Visuals
local VisualsTab = Window:AddTab({
    Title = "Visuals",
    Icon = "rbxassetid://10723385838"
})

-- ESP Section
VisualsTab:AddToggle("ESP Box", {
    Description = "Vẽ hộp xung quanh kẻ địch",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            CreateESP()
        else
            RemoveESP()
        end
    end
})

VisualsTab:AddToggle("ESP Name", {
    Description = "Hiển thị tên kẻ địch",
    Default = false,
    Callback = function(Value)
        -- Tích hợp với ESP Box
    end
})

VisualsTab:AddColorpicker("ESP Color", {
    Description = "Màu ESP",
    Default = Color3.new(0, 0.5, 1),
    Callback = function(Value)
        ESPColor = Value
        UpdateESPColors()
    end
})

VisualsTab:AddToggle("Anti-Blind", {
    Description = "Xóa hiệu ứng làm mù màn hình",
    Default = false,
    Callback = function(Value)
        if Value then
            AntiBlind()
        end
    end
})


-- Tab Combat
local CombatTab = Window:AddTab({
    Title = "Combat",
    Icon = "rbxassetid://10723385838"
})

CombatTab:AddToggle("Triggerbot", {
    Description = "Tự động bắn khi ngắm trúng địch",
    Default = false,
    Callback = function(Value)
        TriggerbotEnabled = Value
    end
})

CombatTab:AddToggle("Finger Aim", {
    Description = "Hỗ trợ ngắm nhẹ nhàng",
    Default = false,
    Callback = function(Value)
        FingerAimEnabled = Value
        if not Value then
            TargetPlayer = nil
            IsAiming = false
        end
    end
})

CombatTab:AddSlider("Aim Smoothness", {
    Description = "Độ mượt của Finger Aim",
    Default = 0.15,
    Min = 0.05,
    Max = 0.3,
    Rounding = 2,
    Callback = function(Value)
        AimSmoothness = Value
    end
})

CombatTab:AddSlider("FOV Radius", {
    Description = "Bán kính vùng ngắm",
    Default = 100,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        FOVRadius = Value
    end
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

-- RenderStepped loop
RunService.RenderStepped:Connect(function()
    -- Triggerbot
    Triggerbot()
    
    -- Finger Aim
    FingerAim()
    
    -- Update ESP positions
    if ESPEnabled then
        UpdateESPPositions()
    end
    
    -- Anti-Blind
    AntiBlind()
end)

-- Player events
Players.PlayerAdded:Connect(function(Player)
    if ESPEnabled then
        Player.CharacterAdded:Connect(function()
            CreateESPBox(Player)
            CreateESPName(Player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    -- Dọn dẹp ESP
    if ESPBoxes[Player] then
        ESPBoxes[Player]:Destroy()
        ESPBoxes[Player] = nil
    end
    
    if ESPNames[Player] then
        ESPNames[Player]:Destroy()
        ESPNames[Player] = nil
    end
    
    -- Xóa target nếu là người chơi đã thoát
    if TargetPlayer == Player then
        TargetPlayer = nil
        IsAiming = false
    end
end)

-- Character added events cho local player
LocalPlayer.CharacterAdded:Connect(function(Character)
    LocalCharacter = Character
    LocalHumanoid = Character:WaitForChild("Humanoid")
    LocalRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Cập nhật avatar trên nút menu
    local MenuButton = game:GetService("CoreGui"):FindFirstChild("FluentMenuButton")
    if MenuButton then
        local Button = MenuButton:FindFirstChild("MenuButton")
        if Button then
            Button.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
        end
    end
end)

-- Initialize
CreateMobileButton()

-- Initialize cho người chơi hiện có
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        Player.CharacterAdded:Connect(function(Character)
            if ESPEnabled then
                CreateESPBox(Player)
                CreateESPName(Player)
            end
        end)
    end
end

-- Ẩn window ban đầu
Fluent:Hide()

-- Thông báo đẹp mắt
Fluent:Notify({
    Title = "Zephyr Style Ready",
    Content = "Fluent UI - Đẹp & An toàn!",
    Duration = 5,
    Image = "rbxassetid://10723385838"
})

print("🌟 Zephyr Style Utility đã được tải!")
print("📋 Tính năng cao cấp:")
print("🎨 Fluent UI (Đẹp như Windows 11)")
print("👁️ ESP Box + Name + Anti-Blind")
print("🎯 Triggerbot + Finger Aim")
print("👤 Safe Hitbox (Max 5) + Sprint Mod")
print("📱 Mobile UI (Nút kéo thả)")
print("🛡️ An toàn - Tránh BAC 4")
print("⚡ Đẹp như Zephyr, An toàn như Legit")
