--[[
    TRIET HUB - ULTIMATE VERSION 2026
    Owner: NGUYỄN MINH TRIẾT
    Features: Avatar Toggle, Advanced Aimbot, Auto Attack, Sea Teleport
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- =================== CÀI ĐẶT HỆ THỐNG ===================
local Settings = {
    AimbotEnabled = false,
    AutoAttackEnabled = false,
    MaxDistance = 500,
    PredictionFactor = 1.0,
    AimbotKeybinds = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.UserInputType.MouseButton1},
    AimbotSpeed = 0.2,
    TeleportSpeed = 300 -- Tốc độ bay khi dịch chuyển (Studs/s)
}

-- =================== GIAO DIỆN (GUI) ===================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrietHub_Ultimate"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- 1. Nút Avatar Toggle
local AvatarBtn = Instance.new("ImageButton")
AvatarBtn.Size = UDim2.new(0, 65, 0, 65)
AvatarBtn.Position = UDim2.new(0, 20, 0.5, -32)
AvatarBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AvatarBtn.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
AvatarBtn.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = AvatarBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(163, 106, 255)
BtnStroke.Thickness = 2
BtnStroke.Parent = AvatarBtn

-- 2. Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Sidebar.Parent = MainFrame

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, 0, 0, 60)
HubTitle.Text = "TRIET HUB"
HubTitle.TextColor3 = Color3.fromRGB(163, 106, 255)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 20
HubTitle.BackgroundTransparency = 1
HubTitle.Parent = Sidebar

-- Khu vực chứa nội dung (Scrolling)
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -155, 1, -20)
Content.Position = UDim2.new(0, 150, 0, 10)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Content
Layout.Padding = UDim.new(0, 8)

-- =================== HÀM HỖ TRỢ (UTILITIES) ===================

-- Hàm Dịch chuyển (Tween Teleport)
local function TweenTeleport(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local dist = (root.Position - targetCFrame.Position).Magnitude
        local tweenInfo = TweenInfo.new(dist / Settings.TeleportSpeed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
    end
end

-- Hàm tạo Nút Toggle
local function CreateToggle(name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    Button.Text = name .. ": OFF"
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = Button

    local active = false
    Button.MouseButton1Click:Connect(function()
        active = not active
        Button.BackgroundColor3 = active and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        Button.Text = name .. (active and ": ON" or ": OFF")
        callback(active)
    end)
end

-- Hàm tạo Nút Dịch Chuyển (Teleport Button)
local function CreateTeleportBtn(name, targetPos)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Button.Text = "Bay đến: " .. name
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.Gotham
    Button.Parent = Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        TweenTeleport(CFrame.new(targetPos + Vector3.new(0, 50, 0)))
    end)
end

-- =================== THIẾT LẬP CHỨC NĂNG ===================

-- Tab 1: Combat & Farm
local Section1 = Instance.new("TextLabel")
Section1.Size = UDim2.new(1, 0, 0, 20); Section1.Text = "-- COMBAT & FARM --"; Section1.TextColor3 = Color3.new(0.6, 0.6, 0.6); Section1.BackgroundTransparency = 1; Section1.Font = Enum.Font.GothamSemibold; Section1.Parent = Content

CreateToggle("Aimbot Skill", function(state) Settings.AimbotEnabled = state end)
CreateToggle("Auto Attack", function(state) Settings.AutoAttackEnabled = state end)

-- Tab 2: Teleport Sea 1 (Ví dụ)
local Section2 = Instance.new("TextLabel")
Section2.Size = UDim2.new(1, 0, 0, 20); Section2.Text = "-- TELEPORT SEA 1 --"; Section2.TextColor3 = Color3.fromRGB(163, 106, 255); Section2.BackgroundTransparency = 1; Section2.Font = Enum.Font.GothamSemibold; Section2.Parent = Content

-- Triết hãy thay tọa độ thật vào đây nhé
CreateTeleportBtn("Đảo Khởi Đầu", Vector3.new(100, 50, 200))
CreateTeleportBtn("Đảo Khỉ", Vector3.new(-1500, 40, 200))
CreateTeleportBtn("Đảo Tuyết", Vector3.new(1200, 60, -1000))

-- =================== LOGIC VẬN HÀNH ===================

-- Ẩn/Hiện Menu qua Avatar
local MenuVisible = false
AvatarBtn.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    MainFrame.Visible = true
    if MenuVisible then
        MainFrame:TweenSize(UDim2.new(0, 550, 0, 350), "Out", "Back", 0.3, true)
        TweenService:Create(AvatarBtn, TweenInfo.new(0.3), {ImageTransparency = 0.5}):Play()
    else
        MainFrame:TweenSize(UDim2.new(0, 550, 0, 0), "In", "Back", 0.3, true, function() MainFrame.Visible = false end)
        TweenService:Create(AvatarBtn, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
    end
end)

-- Loop Aimbot & Auto Attack
RunService.Heartbeat:Connect(function()
    if Settings.AimbotEnabled then
        local anyKey = false
        for _, k in ipairs(Settings.AimbotKeybinds) do
            if (k.EnumType == Enum.KeyCode and UserInputService:IsKeyDown(k)) or (k.EnumType == Enum.UserInputType and UserInputService:IsMouseButtonPressed(k)) then
                anyKey = true; break
            end
        end
        if anyKey then
            local target = nil; local minMag = Settings.MaxDistance
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, onScreen = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if mag < minMag then minMag = mag; target = p end
                    end
                end
            end
            if target then
                local root = target.Character.HumanoidRootPart
                local screenPos = Camera:WorldToScreenPoint(root.Position + (root.Velocity * Settings.PredictionFactor * 0.13))
                pcall(function() if getgenv().movemouse then getgenv().movemouse(screenPos.X, screenPos.Y) end end)
            end
        end
    end
    if Settings.AutoAttackEnabled then
        pcall(function()
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool and not LocalPlayer.Character:FindFirstChild(tool.Name) then LocalPlayer.Character.Humanoid:EquipTool(tool) end
            VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new(850, 500))
        end)
    end
end)

-- Kéo thả AvatarBtn
local drag, dragS, startP
AvatarBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; dragS = i.Position; startP = AvatarBtn.Position end end)
UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragS; AvatarBtn.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)

print("TRIET HUB ULTIMATE LOADED!")
