--[[
    TRIET HUB - ULTIMATE DROPDOWN VERSION 2026
    Owner: NGUYỄN MINH TRIẾT
    Features: Avatar Toggle, Dropdown Menu, Sea 1 Teleports, Aimbot, Auto Attack
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
    PredictionFactor = 0.13,
    AimbotKeybinds = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.UserInputType.MouseButton1},
    TeleportSpeed = 300
}

-- Tọa độ Sea 1 chuẩn
local Sea1Locations = {
    ["Starter Island"] = CFrame.new(973, 16, 1413),
    ["Jungle (Đảo Khỉ)"] = CFrame.new(-1612, 37, 149),
    ["Pirate Village"] = CFrame.new(-1146, 22, 3814),
    ["Desert (Sa Mạc)"] = CFrame.new(1094, 6, 4400),
    ["Frozen Village"] = CFrame.new(1386, 87, -1298),
    ["Marineford"] = CFrame.new(-2448, 73, 3999),
    ["Skypiea (Đảo Trời)"] = CFrame.new(-4839, 717, -2622),
    ["Prison (Nhà Ngục)"] = CFrame.new(4875, 5, 745),
    ["Magma Village"] = CFrame.new(-5242, 8, 8462)
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
Instance.new("UICorner", AvatarBtn).CornerRadius = UDim.new(1, 0)
local Stroke = Instance.new("UIStroke", AvatarBtn)
Stroke.Color = Color3.fromRGB(163, 106, 255); Stroke.Thickness = 2

-- 2. Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 0)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Sidebar & Content
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)

local HubTitle = Instance.new("TextLabel", Sidebar)
HubTitle.Size = UDim2.new(1, 0, 0, 60); HubTitle.Text = "TRIET HUB"; HubTitle.TextColor3 = Color3.fromRGB(163, 106, 255); HubTitle.Font = Enum.Font.GothamBold; HubTitle.TextSize = 20; HubTitle.BackgroundTransparency = 1

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -155, 1, -20); Content.Position = UDim2.new(0, 150, 0, 10); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 8)

-- =================== HÀM HỖ TRỢ (UTILITIES) ===================

local function TweenTeleport(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local dist = (char.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
        local info = TweenInfo.new(dist / Settings.TeleportSpeed, Enum.EasingStyle.Linear)
        TweenService:Create(char.HumanoidRootPart, info, {CFrame = targetCFrame}):Play()
    end
end

-- Hàm tạo Dropdown chuyên nghiệp
local function CreateDropdown(parent, text)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 40); Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Frame.ClipsDescendants = true
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, 0, 0, 40); Btn.Text = "▼  " .. text; Btn.TextColor3 = Color3.new(1, 1, 1); Btn.Font = Enum.Font.GothamBold; Btn.BackgroundTransparency = 1

    local Container = Instance.new("Frame", Frame)
    Container.Size = UDim2.new(1, 0, 0, 0); Container.Position = UDim2.new(0, 0, 0, 40); Container.BackgroundTransparency = 1
    local L = Instance.new("UIListLayout", Container); L.Padding = UDim.new(0, 5)

    local expanded = false
    Btn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetH = expanded and (45 + (35 * #Container:GetChildren())) or 40
        TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, targetH)}):Play()
        Btn.Text = (expanded and "▲  " or "▼  ") .. text
    end)
    return Container
end

local function CreateToggle(parent, name, callback)
    local TBtn = Instance.new("TextButton", parent)
    TBtn.Size = UDim2.new(1, -10, 0, 35); TBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); TBtn.Text = name .. ": OFF"; TBtn.TextColor3 = Color3.new(1, 1, 1); TBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 6)

    local active = false
    TBtn.MouseButton1Click:Connect(function()
        active = not active
        TBtn.BackgroundColor3 = active and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        TBtn.Text = name .. (active and ": ON" or ": OFF")
        callback(active)
    end)
end

-- =================== TRIỂN KHAI NỘI DUNG = ===================

local MainSection = CreateDropdown(Content, "MAIN FUNCTIONS")
CreateToggle(MainSection, "Aimbot Skill", function(s) Settings.AimbotEnabled = s end)
CreateToggle(MainSection, "Auto Attack", function(s) Settings.AutoAttackEnabled = s end)

local TeleportSection = CreateDropdown(Content, "TELEPORT SEA 1")
for name, cf in pairs(Sea1Locations) do
    CreateToggle(TeleportSection, name, function(s) 
        if s then TweenTeleport(cf * CFrame.new(0, 50, 0)) end 
    end)
end

-- =================== VẬN HÀNH = ===================

local MenuVis = false
AvatarBtn.MouseButton1Click:Connect(function()
    MenuVis = not MenuVis
    MainFrame.Visible = true
    local targetS = MenuVis and UDim2.new(0, 550, 0, 350) or UDim2.new(0, 550, 0, 0)
    MainFrame:TweenSize(targetS, "Out", "Back", 0.3, true, function() if not MenuVis then MainFrame.Visible = false end end)
    TweenService:Create(AvatarBtn, TweenInfo.new(0.3), {ImageTransparency = MenuVis and 0.5 or 0}):Play()
end)

RunService.Heartbeat:Connect(function()
    if Settings.AutoAttackEnabled then
        pcall(function()
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool and not LocalPlayer.Character:FindFirstChild(tool.Name) then LocalPlayer.Character.Humanoid:EquipTool(tool) end
            VirtualUser:Button1Down(Vector2.new(1,1))
        end)
    end
end)

-- Kéo thả AvatarBtn
local d, ds, sp
AvatarBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = AvatarBtn.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - ds; AvatarBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

print("TRIET HUB DROPDOWN LOADED!")
