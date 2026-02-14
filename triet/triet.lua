-- Roblox Mobile Native GUI Utility - Assassins vs Sheriffs DUELS
-- Native GUI Version - Không cần loadstring
-- Tạo bởi: AI Assistant

-- BẢO MẬT: Game ID Lock - Chỉ hoạt động trên 2 ID game
local ValidGameIds = {15385224902, 12355337193}
local IsValidGame = false

for _, Id in pairs(ValidGameIds) do
    if game.PlaceId == Id then
        IsValidGame = true
        break
    end
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

-- LocalPlayer
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHumanoid = LocalCharacter:WaitForChild("Humanoid")
local LocalRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")

-- Variables
local MenuOpen = false
local ESPEnabled = false
local TriggerbotEnabled = false
local AntiBlindEnabled = false
local HitboxEnabled = false
local HitboxSize = 4
local TargetPlayer = nil
local ESPHighlights = {}
local ESPColor = Color3.fromRGB(255, 0, 0) -- Màu đỏ
local IsAiming = false

-- Tạo GUI Native (Không cần loadstring)
local function CreateNativeGUI()
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NativeMenuGUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Nút Menu (Tròn nhỏ)
    local MenuButton = Instance.new("ImageButton")
    MenuButton.Name = "MenuButton"
    MenuButton.Size = UDim2.new(0, 60, 0, 60)
    MenuButton.Position = UDim2.new(0, 50, 0, 100)
    MenuButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MenuButton.BorderSizePixel = 0
    MenuButton.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    MenuButton.Parent = ScreenGui
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 30)
    ButtonCorner.Parent = MenuButton
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Thickness = 2
    ButtonStroke.Color = Color3.fromRGB(0, 170, 255) -- Xanh dương neon
    ButtonStroke.Transparency = 0.3
    ButtonStroke.Parent = MenuButton
    
    -- Menu chính
    local MenuFrame = Instance.new("Frame")
    MenuFrame.Name = "MenuFrame"
    MenuFrame.Size = UDim2.new(0, 300, 0, 400)
    MenuFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MenuFrame.BorderSizePixel = 0
    MenuFrame.Visible = false
    MenuFrame.Parent = ScreenGui
    
    local MenuCorner = Instance.new("UICorner")
    MenuCorner.CornerRadius = UDim.new(0, 15)
    MenuCorner.Parent = MenuFrame
    
    local MenuStroke = Instance.new("UIStroke")
    MenuStroke.Thickness = 2
    MenuStroke.Color = Color3.fromRGB(0, 170, 255)
    MenuStroke.Transparency = 0.5
    MenuStroke.Parent = MenuFrame
    
    -- Tiêu đề
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    TitleLabel.BorderSizePixel = 0
    TitleLabel.Text = "🎯 Zephyr Style Utility"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.Parent = MenuFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = TitleLabel
    
    -- Tab Buttons
    local TabButtons = {}
    local Tabs = {"Combat", "Visuals", "Settings"}
    local TabWidth = 1 / #Tabs
    
    for i, TabName in pairs(Tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton_" .. TabName
        TabButton.Size = UDim2.new(TabWidth, -2, 0, 30)
        TabButton.Position = UDim2.new((i-1) * TabWidth, 1, 0, 45)
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.BorderSizePixel = 0
        TabButton.Text = TabName
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextScaled = true
        TabButton.Font = Enum.Font.Gotham
        TabButton.Parent = MenuFrame
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 5)
        TabCorner.Parent = TabButton
        
        TabButtons[TabName] = TabButton
    end
    
    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -20, 1, -100)
    ContentFrame.Position = UDim2.new(0, 10, 0, 85)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MenuFrame
    
    -- Combat Tab Content
    local CombatContent = Instance.new("ScrollingFrame")
    CombatContent.Name = "CombatContent"
    CombatContent.Size = UDim2.new(1, 0, 1, 0)
    CombatContent.Position = UDim2.new(0, 0, 0, 0)
    CombatContent.BackgroundTransparency = 1
    CombatContent.Visible = true
    CombatContent.ScrollBarThickness = 5
    CombatContent.Parent = ContentFrame
    
    local CombatLayout = Instance.new("UIListLayout")
    CombatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CombatLayout.Padding = UDim.new(0, 10)
    CombatLayout.Parent = CombatContent
    
    -- Triggerbot Toggle
    local TriggerbotFrame = CreateToggle("Triggerbot (Auto Shoot)", false, function(Value)
        TriggerbotEnabled = Value
        ShowNotification("Triggerbot", Value and "Đã bật" or "Đã tắt")
    end)
    TriggerbotFrame.LayoutOrder = 1
    TriggerbotFrame.Parent = CombatContent
    
    -- Visuals Tab Content
    local VisualsContent = Instance.new("ScrollingFrame")
    VisualsContent.Name = "VisualsContent"
    VisualsContent.Size = UDim2.new(1, 0, 1, 0)
    VisualsContent.Position = UDim2.new(0, 0, 0, 0)
    VisualsContent.BackgroundTransparency = 1
    VisualsContent.Visible = false
    VisualsContent.ScrollBarThickness = 5
    VisualsContent.Parent = ContentFrame
    
    local VisualsLayout = Instance.new("UIListLayout")
    VisualsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    VisualsLayout.Padding = UDim.new(0, 10)
    VisualsLayout.Parent = VisualsContent
    
    -- ESP Toggle
    local ESPFrame = CreateToggle("ESP Highlight", false, function(Value)
        ESPEnabled = Value
        if Value then
            CreateESP()
        else
            RemoveESP()
        end
        ShowNotification("ESP", Value and "Đã bật" or "Đã tắt")
    end)
    ESPFrame.LayoutOrder = 1
    ESPFrame.Parent = VisualsContent
    
    -- Anti-Blind Toggle
    local AntiBlindFrame = CreateToggle("Anti-Blind", false, function(Value)
        AntiBlindEnabled = Value
        ShowNotification("Anti-Blind", Value and "Đã bật" or "Đã tắt")
    end)
    AntiBlindFrame.LayoutOrder = 2
    AntiBlindFrame.Parent = VisualsContent
    
    -- Settings Tab Content
    local SettingsContent = Instance.new("ScrollingFrame")
    SettingsContent.Name = "SettingsContent"
    SettingsContent.Size = UDim2.new(1, 0, 1, 0)
    SettingsContent.Position = UDim2.new(0, 0, 0, 0)
    SettingsContent.BackgroundTransparency = 1
    SettingsContent.Visible = false
    SettingsContent.ScrollBarThickness = 5
    SettingsContent.Parent = ContentFrame
    
    local SettingsLayout = Instance.new("UIListLayout")
    SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SettingsLayout.Padding = UDim.new(0, 10)
    SettingsLayout.Parent = SettingsContent
    
    -- Hitbox Toggle
    local HitboxFrame = CreateToggle("Hitbox Expander (Safe)", false, function(Value)
        HitboxEnabled = Value
        UpdateHitbox()
        ShowNotification("Hitbox", Value and "Đã bật" or "Đã tắt")
    end)
    HitboxFrame.LayoutOrder = 1
    HitboxFrame.Parent = SettingsContent
    
    -- Tab switching logic
    local function SwitchTab(TabName)
        for _, Tab in pairs(Tabs) do
            local Content = ContentFrame:FindFirstChild(TabName .. "Content")
            if Content then
                Content.Visible = (Tab == TabName)
            end
            
            local Button = TabButtons[Tab]
            if Button then
                if Tab == TabName then
                    Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
        end
    end
    
    -- Tab button events
    for TabName, Button in pairs(TabButtons) do
        Button.MouseButton1Click:Connect(function()
            SwitchTab(TabName)
        end)
    end
    
    -- Menu button events
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
            MenuFrame.Visible = MenuOpen
            ButtonStroke.Color = MenuOpen and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 170, 255)
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
    
    -- Initialize first tab
    SwitchTab("Combat")
    
    return ScreenGui
end

-- Tạo Toggle UI
function CreateToggle(Text, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Name = "Toggle_" .. Text
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextScaled = true
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleButton.BackgroundColor3 = Default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(100, 100, 100)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.Parent = Frame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleButton
    
    local State = Default
    
    ToggleButton.MouseButton1Click:Connect(function()
        State = not State
        ToggleButton.BackgroundColor3 = State and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(100, 100, 100)
        if Callback then
            Callback(State)
        end
    end)
    
    return Frame
end

-- Show Notification
function ShowNotification(Title, Text)
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "Notification_" .. tick()
    NotificationGui.Parent = game:GetService("CoreGui")
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Size = UDim2.new(0, 250, 0, 80)
    NotificationFrame.Position = UDim2.new(1, -270, 1, -100)
    NotificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = NotificationGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 10)
    NotifCorner.Parent = NotificationFrame
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Thickness = 1
    NotifStroke.Color = Color3.fromRGB(0, 170, 255)
    NotifStroke.Transparency = 0.5
    NotifStroke.Parent = NotificationFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotificationFrame
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "TextLabel"
    TextLabel.Size = UDim2.new(1, -20, 0, 40)
    TextLabel.Position = UDim2.new(0, 10, 0, 30)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = Text
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextWrapped = true
    TextLabel.Parent = NotificationFrame
    
    -- Animation
    local TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local FadeIn = TweenService:Create(NotificationFrame, TweenInfo, {Position = UDim2.new(1, -270, 1, -100)})
    FadeIn:Play()
    
    -- Auto remove
    game:GetService("Debris"):AddItem(NotificationGui, 3)
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

-- Triggerbot Logic
function Triggerbot()
    if TriggerbotEnabled then
        pcall(function()
            local Mouse = LocalPlayer:GetMouse()
            if Mouse.Target then
                local Character = Mouse.Target.Parent
                local Player = Players:GetPlayerFromCharacter(Character)
                
                if Player and Player ~= LocalPlayer and IsAlive(Player) then
                    -- Tự động bắn
                    VirtualUser:Button1Down(Vector2.new())
                    wait(0.1)
                    VirtualUser:Button1Up(Vector2.new())
                end
            end
        end)
    end
end

-- Tạo ESP Highlight
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
    
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ESP_Highlight_" .. Player.Name
    Highlight.FillColor = ESPColor
    Highlight.OutlineColor = ESPColor
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0.2
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Parent = Character
    
    ESPHighlights[Player] = Highlight
end

function RemoveESP()
    for Player, Highlight in pairs(ESPHighlights) do
        if Highlight then
            Highlight:Destroy()
        end
    end
    ESPHighlights = {}
end

-- Anti-Blind
function AntiBlind()
    if AntiBlindEnabled then
        pcall(function()
            for _, Player in pairs(Players:GetPlayers()) do
                local PlayerGui = Player:FindFirstChild("PlayerGui")
                if PlayerGui then
                    for _, Child in pairs(PlayerGui:GetChildren()) do
                        if Child.Name:lower():find("flashbang") or 
                           Child.Name:lower():find("blind") or
                           Child.Name:lower():find("white") or
                           Child.Name:lower():find("screen") or
                           Child.Name:lower():find("flash") then
                            Child:Destroy()
                        end
                    end
                end
            end
        end)
    end
end

-- Hitbox Expander (Safe)
function UpdateHitbox()
    pcall(function()
        if HitboxEnabled then
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and IsAlive(Player) then
                    local Character = Player.Character
                    if Character then
                        local Head = Character:FindFirstChild("Head")
                        if Head then
                            Head.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                            Head.Transparency = 0.7
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
                        if Head then
                            Head.Size = Vector3.new(2, 1, 1)
                            Head.Transparency = 0
                        end
                    end
                end
            end
        end
    end)
end

-- Game ID Check (Warn only)
function CheckGameID()
    if not IsValidGame then
        ShowNotification("⚠️ Warning", "Game không được hỗ trợ!")
        return false
    end
    return true
end

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
                Library:Show()
                UIStroke.Color = Color3.new(1, 0.2, 0.2)
            else
                Library:Hide()
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

-- Triggerbot Logic (VIP Feature)
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

-- Safe Hitbox (HBE - An toàn)
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
                   Child.Name:lower():find("screen") or
                   Child.Name:lower():find("flash") then
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
local Window = Library:CreateWindow({
    Title = "Zephyr Style Utility",
    Center = true,
    AutoShow = false,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Tab Combat
local CombatTab = Window:AddTab("Combat")

CombatTab:AddToggle("Triggerbot", {
    Text = "Triggerbot (VIP)",
    Default = false,
    Callback = function(Value)
        TriggerbotEnabled = Value
        Library:Notify({
            Title = "Triggerbot",
            Content = Value and "Đã bật Triggerbot" or "Đã tắt Triggerbot",
            Duration = 2
        })
    end
})

CombatTab:AddToggle("Finger Aim", {
    Text = "Finger Aim",
    Default = false,
    Callback = function(Value)
        FingerAimEnabled = Value
        Library:Notify({
            Title = "Finger Aim",
            Content = Value and "Đã bật Finger Aim" or "Đã tắt Finger Aim",
            Duration = 2
        })
    end
})

CombatTab:AddSlider("Aim Smoothness", {
    Text = "Độ mượt",
    Default = 0.15,
    Min = 0.05,
    Max = 0.3,
    Rounding = 2,
    Callback = function(Value)
        AimSmoothness = Value
    end
})

CombatTab:AddSlider("FOV Radius", {
    Text = "Bán kính FOV",
    Default = 100,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        FOVRadius = Value
    end
})

-- Tab Visuals
local VisualsTab = Window:AddTab("Visuals")

VisualsTab:AddToggle("ESP Box", {
    Text = "ESP Box",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            CreateESP()
        else
            RemoveESP()
        end
        Library:Notify({
            Title = "ESP Box",
            Content = Value and "Đã bật ESP Box" or "Đã tắt ESP Box",
            Duration = 2
        })
    end
})

VisualsTab:AddToggle("ESP Name", {
    Text = "ESP Name",
    Default = false,
    Callback = function(Value)
        Library:Notify({
            Title = "ESP Name",
            Content = Value and "Đã bật ESP Name" or "Đã tắt ESP Name",
            Duration = 2
        })
    end
})

VisualsTab:AddColorpicker("ESP Color", {
    Default = Color3.new(0, 0.5, 1),
    Callback = function(Value)
        ESPColor = Value
        UpdateESPColors()
    end
})

VisualsTab:AddToggle("Anti-Blind", {
    Text = "Anti-Blind",
    Default = false,
    Callback = function(Value)
        Library:Notify({
            Title = "Anti-Blind",
            Content = Value and "Đã bật Anti-Blind" or "Đã tắt Anti-Blind",
            Duration = 2
        })
    end
})


-- Tab Misc (HBE)
local MiscTab = Window:AddTab("Misc")

MiscTab:AddToggle("Safe Hitbox", {
    Text = "Safe Hitbox (HBE)",
    Default = false,
    Callback = function(Value)
        SafeHitboxEnabled = Value
        UpdateSafeHitbox()
        Library:Notify({
            Title = "Safe Hitbox",
            Content = Value and "Đã bật Safe Hitbox" or "Đã tắt Safe Hitbox",
            Duration = 2
        })
    end
})

MiscTab:AddSlider("Hitbox Size", {
    Text = "Hitbox Size",
    Default = 4.0,
    Min = 1.0,
    Max = 5.0,
    Rounding = 1,
    Callback = function(Value)
        HitboxSize = Value
        if SafeHitboxEnabled then
            UpdateSafeHitbox()
        end
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
            end
        end)
    end
end

-- Initialize
if CheckGameID() then
    -- Tạo GUI
    local MainGUI = CreateNativeGUI()
    
    -- RenderStepped loop
    RunService.RenderStepped:Connect(function()
        pcall(function()
            Triggerbot()
            AntiBlind()
        end)
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
        if ESPHighlights[Player] then
            ESPHighlights[Player]:Destroy()
            ESPHighlights[Player] = nil
        end
    end)
    
    -- Character added events cho local player
    LocalPlayer.CharacterAdded:Connect(function(Character)
        LocalCharacter = Character
        LocalHumanoid = Character:WaitForChild("Humanoid")
        LocalRootPart = Character:WaitForChild("HumanoidRootPart")
        
        -- Cập nhật avatar trên nút menu
        local MenuButton = MainGUI:FindFirstChild("MenuButton")
        if MenuButton then
            MenuButton.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
        end
    end)
    
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
    
    -- Thông báo khởi động
    ShowNotification(" Ready", "Zephyr Style đã tải!")
    
    print(" Zephyr Style Utility đã được tải!")
    print(" Tính năng:")
    print(" Native GUI (Không cần loadstring)")
    print(" Triggerbot (Auto Shoot)")
    print(" ESP Highlight (Màu đỏ)")
    print(" Anti-Blind")
    print(" Hitbox Expander (Size 4)")
    print(" Mobile Friendly")
    print(" Game ID Lock (2 ID)")
    print(" Tối ưu cho Delta/Fluxus")
end
