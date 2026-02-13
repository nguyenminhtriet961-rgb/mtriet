--[[
    TRIET HUB - PHIÊN BẢN VIỆT HÓA 2026
    Chủ sở hữu: NGUYỄN MINH TRIẾT
    Tính năng: Avatar Toggle, Dropdown Menu, Full Sea 1-2-3, Fast & Long Attack, Fix Aimbot
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
    FastAttack = true, -- Đánh nhanh
    AttackRange = 30, -- Đánh xa (Studs)
    MaxDistance = 500,
    Prediction = 0.15,
    TeleportSpeed = 350
}

-- Tọa độ các Sea
local Locations = {
    ["Sea 1"] = {
        ["Đảo Khởi Đầu"] = CFrame.new(973, 16, 1413),
        ["Đảo Khỉ (Jungle)"] = CFrame.new(-1612, 37, 149),
        ["Làng Hải Tặc"] = CFrame.new(-1146, 22, 3814),
        ["Sa Mạc"] = CFrame.new(1094, 6, 4400),
        ["Đảo Tuyết"] = CFrame.new(1386, 87, -1298),
        ["Đảo Trời (Sky)"] = CFrame.new(-4839, 717, -2622),
        ["Nhà Ngục (Prison)"] = CFrame.new(4875, 5, 745)
    },
    ["Sea 2"] = {
        ["Vương Quốc Rose"] = CFrame.new(-424, 73, 1836),
        ["Đảo Ussop"] = CFrame.new(-2062, 37, -592),
        ["Green Bit"] = CFrame.new(-2435, 73, -3158),
        ["Nghĩa Địa (Graveyard)"] = CFrame.new(-5422, 14, -750),
        ["Đảo Tuyết (Hot/Cold)"] = CFrame.new(-6061, 15, -4902)
    },
    ["Sea 3"] = {
        ["Dinh Thự (Mansion)"] = CFrame.new(-12463, 375, -7551),
        ["Đảo Phụ Nữ (Hydra)"] = CFrame.new(5756, 610, -253),
        ["Đảo Rùa (Turtle)"] = CFrame.new(-13274, 532, -7583),
        ["Lâu Đài Trên Không"] = CFrame.new(-11843, 807, -1521)
    }
}

-- =================== GIAO DIỆN (VIỆT HÓA) ===================
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "TrietHub_Pro"
ScreenGui.ResetOnSpawn = false

-- Nút Avatar
local AvatarBtn = Instance.new("ImageButton", ScreenGui)
AvatarBtn.Size = UDim2.new(0, 65, 0, 65)
AvatarBtn.Position = UDim2.new(0, 20, 0.5, -32)
AvatarBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AvatarBtn.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
Instance.new("UICorner", AvatarBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", AvatarBtn).Color = Color3.fromRGB(163, 106, 255)

-- Khung Chính
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 0)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 60); Title.Text = "TRIET HUB"; Title.TextColor3 = Color3.fromRGB(163, 106, 255); Title.Font = Enum.Font.GothamBold; Title.TextSize = 22; Title.BackgroundTransparency = 1

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -155, 1, -20); Content.Position = UDim2.new(0, 150, 0, 10); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 8)

-- =================== HÀM CHỨC NĂNG ===================

local function TweenTP(cf)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local dist = (char.HumanoidRootPart.Position - cf.Position).Magnitude
        TweenService:Create(char.HumanoidRootPart, TweenInfo.new(dist/Settings.TeleportSpeed, Enum.EasingStyle.Linear), {CFrame = cf * CFrame.new(0,50,0)}):Play()
    end
end

local function CreateDropdown(text)
    local Frame = Instance.new("Frame", Content)
    Frame.Size = UDim2.new(1, -10, 0, 40); Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Frame.ClipsDescendants = true
    Instance.new("UICorner", Frame)
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, 0, 0, 40); Btn.Text = "▼  " .. text; Btn.TextColor3 = Color3.new(1, 1, 1); Btn.Font = Enum.Font.GothamBold; Btn.BackgroundTransparency = 1

    local Container = Instance.new("Frame", Frame)
    Container.Size = UDim2.new(1, 0, 0, 0); Container.Position = UDim2.new(0, 0, 0, 40); Container.BackgroundTransparency = 1
    Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)

    local open = false
    Btn.MouseButton1Click:Connect(function()
        open = not open
        Frame:TweenSize(UDim2.new(1, -10, 0, open and (45 + (38 * #Container:GetChildren())) or 40), "Out", "Quart", 0.3, true)
        Btn.Text = (open and "▲  " or "▼  ") .. text
    end)
    return Container
end

local function CreateToggle(parent, name, callback)
    local TBtn = Instance.new("TextButton", parent)
    TBtn.Size = UDim2.new(1, -10, 0, 35); TBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); TBtn.Text = name .. ": TẮT"; TBtn.TextColor3 = Color3.new(1, 1, 1); TBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", TBtn)

    local act = false
    TBtn.MouseButton1Click:Connect(function()
        act = not act
        TBtn.BackgroundColor3 = act and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        TBtn.Text = name .. (act and ": BẬT" or ": TẮT")
        callback(act)
    end)
end

-- =================== CÀI ĐẶT NỘI DUNG ===================

local CombatTab = CreateDropdown("CHỨC NĂNG CHÍNH")
CreateToggle(CombatTab, "Aimbot Kỹ Năng", function(s) Settings.AimbotEnabled = s end)
CreateToggle(CombatTab, "Tự Động Đánh (Fast)", function(s) Settings.AutoAttackEnabled = s end)

for sea, islands in pairs(Locations) do
    local SeaTab = CreateDropdown("DỊCH CHUYỂN " .. sea)
    for name, cf in pairs(islands) do
        CreateToggle(SeaTab, name, function(s) if s then TweenTP(cf) end end)
    end
end

-- =================== LOGIC VẬN HÀNH ===================

-- Fix Auto Attack (Đánh Nhanh & Đánh Xa)
RunService.Stepped:Connect(function()
    if Settings.AutoAttackEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool and not char:FindFirstChild(tool.Name) then char.Humanoid:EquipTool(tool) end
            
            -- Sửa lỗi đánh xa: Tăng kích thước Handle vũ khí tạm thời
            if tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Vector3.new(Settings.AttackRange, Settings.AttackRange, Settings.AttackRange)
                tool.Handle.CanCollide = false
            end
            
            VirtualUser:Button1Down(Vector2.new(1,1))
            if Settings.FastAttack then task.wait() VirtualUser:Button1Up(Vector2.new(1,1)) end
        end)
    end
end)

-- Fix Aimbot Dự Đoán
RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target = nil; local dist = Settings.MaxDistance
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, vis = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < dist then dist = mag; target = p end
                end
            end
        end
        if target then
            local predictedPos = target.Character.HumanoidRootPart.Position + (target.Character.HumanoidRootPart.Velocity * Settings.Prediction)
            local sPos = Camera:WorldToScreenPoint(predictedPos)
            if getgenv().movemouse then getgenv().movemouse(sPos.X, sPos.Y) end
        end
    end
end)

-- Mở/Đóng Menu
AvatarBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    local open = MainFrame.Size.Y.Offset == 0
    MainFrame:TweenSize(UDim2.new(0, 550, 0, open and 350 or 0), "Out", "Back", 0.3, true, function() if not open then MainFrame.Visible = false end end)
end)

print("TRIET HUB ĐÃ SẴN SÀNG!")
