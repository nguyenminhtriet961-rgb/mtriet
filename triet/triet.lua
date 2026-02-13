--[[
    TRIET HUB - PHIÊN BẢN ULTIMATE MOBILE 2026
    Sửa lỗi: Trả lại Teleport, Aimbot FOV bự, Ghìm mục tiêu cực mạnh
    Chủ sở hữu: NGUYỄN MINH TRIẾT
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- =================== CÀI ĐẶT HỆ THỐNG ===================
local Settings = {
    AimbotEnabled = false,
    AimbotFOV = 250, -- Vòng tròn bự hơn theo ý Triết
    AutoAttackEnabled = false,
    TeleportSpeed = 350,
    Prediction = 0.15,
    CurrentTarget = nil
}

-- Tự động nhận diện Sea
local SeaName = "Sea 1"
if game.PlaceId == 444227216 then SeaName = "Sea 2"
elseif game.PlaceId == 744942363 then SeaName = "Sea 3" end

-- Dữ liệu tọa độ Sea 1, 2, 3
local Locations = {
    ["Sea 1"] = {
        ["Đảo Khởi Đầu"] = CFrame.new(973, 16, 1413),
        ["Đảo Khỉ"] = CFrame.new(-1612, 37, 149),
        ["Đảo Tuyết"] = CFrame.new(1386, 87, -1298),
        ["Đảo Trời"] = CFrame.new(-4839, 717, -2622)
    },
    ["Sea 2"] = {
        ["Vương Quốc Rose"] = CFrame.new(-424, 73, 1836),
        ["Green Bit"] = CFrame.new(-2435, 73, -3158),
        ["Nghĩa Địa"] = CFrame.new(-5422, 14, -750)
    },
    ["Sea 3"] = {
        ["Dinh Thự"] = CFrame.new(-12463, 375, -7551),
        ["Đảo Rùa"] = CFrame.new(-13274, 532, -7583),
        ["Hydra Island"] = CFrame.new(5756, 610, -253)
    }
}

-- =================== VÒNG TRÒN AIMBOT (FOV) ===================
local Circle = Drawing.new("Circle")
Circle.Visible = false
Circle.Thickness = 2
Circle.Color = Color3.fromRGB(255, 0, 0) -- Màu đỏ cho ngầu
Circle.Radius = Settings.AimbotFOV
Circle.Filled = false

-- =================== GIAO DIỆN MOBILE ===================
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "TrietHub_Final_Mobile"
ScreenGui.ResetOnSpawn = false

-- Nút Avatar Toggle
local AvatarBtn = Instance.new("ImageButton", ScreenGui)
AvatarBtn.Size = UDim2.new(0, 60, 0, 60)
AvatarBtn.Position = UDim2.new(0, 15, 0.45, 0)
AvatarBtn.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
Instance.new("UICorner", AvatarBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", AvatarBtn).Color = Color3.fromRGB(163, 106, 255)

-- Khung Menu
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 340, 0, 0)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundTransparency = 1
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 5)

-- =================== HÀM XỬ LÝ ===================

local function TweenTP(cf)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local dist = (char.HumanoidRootPart.Position - cf.Position).Magnitude
        TweenService:Create(char.HumanoidRootPart, TweenInfo.new(dist/Settings.TeleportSpeed, Enum.EasingStyle.Linear), {CFrame = cf * CFrame.new(0,50,0)}):Play()
    end
end

-- Logic Aimbot Ghìm Chặt Mục Tiêu
RunService.RenderStepped:Connect(function()
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Circle.Position = Center
    Circle.Visible = Settings.AimbotEnabled
    
    if Settings.AimbotEnabled then
        local target = nil
        local maxDist = Settings.AimbotFOV
        
        -- Tìm mục tiêu trong tầm mắt
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                local pos, vis = Camera:WorldToScreenPoint(root.Position)
                
                if vis then
                    local mag = (Center - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < maxDist then
                        maxDist = mag
                        target = p
                    end
                end
            end
        end
        
        -- Nếu tìm thấy mục tiêu, sẽ ghìm chặt tâm vào đó
        if target then
            local pPos = target.Character.HumanoidRootPart.Position + (target.Character.HumanoidRootPart.Velocity * Settings.Prediction)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, pPos)
        end
    end
end)

-- Tạo Giao diện Gấp (Dropdown)
local function CreateDropdown(text)
    local Frame = Instance.new("Frame", Content)
    Frame.Size = UDim2.new(1, -5, 0, 35); Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Frame.ClipsDescendants = true
    Instance.new("UICorner", Frame)
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, 0, 0, 35); Btn.Text = "▼ " .. text; Btn.TextColor3 = Color3.new(1, 1, 1); Btn.Font = Enum.Font.GothamBold; Btn.BackgroundTransparency = 1

    local Container = Instance.new("Frame", Frame)
    Container.Size = UDim2.new(1, 0, 0, 0); Container.Position = UDim2.new(0, 0, 0, 35); Container.BackgroundTransparency = 1
    Instance.new("UIListLayout", Container).Padding = UDim.new(0, 3)

    local open = false
    Btn.MouseButton1Click:Connect(function()
        open = not open
        Frame:TweenSize(UDim2.new(1, -5, 0, open and (40 + (35 * #Container:GetChildren())) or 35), "Out", "Quart", 0.3, true)
        Btn.Text = (open and "▲ " or "▼ ") .. text
    end)
    return Container
end

-- =================== TRIỂN KHAI NỘI DUNG ===================

local CombatTab = CreateDropdown("CHỨC NĂNG CHIẾN ĐẤU")
-- Nút bật Aimbot FOV to
local AimToggle = Instance.new("TextButton", CombatTab)
AimToggle.Size = UDim2.new(1, 0, 0, 30); AimToggle.Text = "Ghim Tâm (FOV TO): TẮT"; AimToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AimToggle.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    AimToggle.Text = "Ghim Tâm (FOV TO): " .. (Settings.AimbotEnabled and "BẬT" or "TẮT")
    AimToggle.BackgroundColor3 = Settings.AimbotEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

local TeleTab = CreateDropdown("DỊCH CHUYỂN " .. SeaName:upper())
if Locations[SeaName] then
    for name, cf in pairs(Locations[SeaName]) do
        local b = Instance.new("TextButton", TeleTab)
        b.Size = UDim2.new(1, 0, 0, 30); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1, 1, 1)
        b.MouseButton1Click:Connect(function() TweenTP(cf) end)
    end
end

-- Mở/Đóng Menu
AvatarBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    local open = MainFrame.Size.Y.Offset == 0
    MainFrame:TweenSize(UDim2.new(0, 340, 0, open and 300 or 0), "Out", "Back", 0.3, true, function() if not open then MainFrame.Visible = false end end)
end)

print("TRIET HUB MOBILE FINAL ĐÃ SẴN SÀNG!")
