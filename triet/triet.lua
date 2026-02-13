--[[
    TRIET HUB - PHIÊN BẢN CHIẾN THẦN MOBILE 2026
    Sửa lỗi: Gim người chơi cực chắc, Full 3 Sea, Đánh nhanh & xa
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
    AimbotFOV = 280, -- Vòng tròn cực bự để gim người
    AutoAttackEnabled = false,
    AttackRange = 35, -- Đánh siêu xa
    TeleportSpeed = 350,
    Target = nil
}

-- Hệ thống tọa độ Full 3 Sea
local AllSeas = {
    ["Sea 1"] = {
        ["Đảo Khởi Đầu"] = CFrame.new(973, 16, 1413),
        ["Đảo Khỉ"] = CFrame.new(-1612, 37, 149),
        ["Làng Hải Tặc"] = CFrame.new(-1146, 22, 3814),
        ["Sa Mạc"] = CFrame.new(1094, 6, 4400),
        ["Đảo Tuyết"] = CFrame.new(1386, 87, -1298),
        ["Đảo Trời"] = CFrame.new(-4839, 717, -2622),
        ["Nhà Ngục"] = CFrame.new(4875, 5, 745),
        ["Đảo Núi Lửa"] = CFrame.new(-5242, 8, 8462)
    },
    ["Sea 2"] = {
        ["Vương Quốc Rose"] = CFrame.new(-424, 73, 1836),
        ["Green Bit"] = CFrame.new(-2435, 73, -3158),
        ["Nghĩa Địa"] = CFrame.new(-5422, 14, -750),
        ["Đảo Tuyết (Hot/Cold)"] = CFrame.new(-6061, 15, -4902),
        ["Đảo Zombie"] = CFrame.new(-5622, 15, -450)
    },
    ["Sea 3"] = {
        ["Dinh Thự (Mansion)"] = CFrame.new(-12463, 375, -7551),
        ["Đảo Phụ Nữ (Hydra)"] = CFrame.new(5756, 610, -253),
        ["Đảo Rùa (Turtle)"] = CFrame.new(-13274, 532, -7583),
        ["Lâu Đài Trên Không"] = CFrame.new(-11843, 807, -1521)
    }
}

-- =================== VÒNG TRÒN FOV ===================
local Circle = Drawing.new("Circle")
Circle.Visible = false
Circle.Thickness = 3
Circle.Color = Color3.fromRGB(163, 106, 255)
Circle.Radius = Settings.AimbotFOV
Circle.Filled = false

-- =================== GIAO DIỆN MOBILE ===================
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "TrietHub_Ultimate_Mobile"
ScreenGui.ResetOnSpawn = false

local AvatarBtn = Instance.new("ImageButton", ScreenGui)
AvatarBtn.Size = UDim2.new(0, 60, 0, 60)
AvatarBtn.Position = UDim2.new(0, 15, 0.4, 0)
AvatarBtn.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
Instance.new("UICorner", AvatarBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 340, 0, 300)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -10, 1, -50); Content.Position = UDim2.new(0, 5, 0, 45); Content.BackgroundTransparency = 1
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 5)

-- =================== HÀM CHỨC NĂNG ===================

-- 1. Auto Attack & Đánh Xa
local function DoAttack()
    pcall(function()
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if tool and not LocalPlayer.Character:FindFirstChild(tool.Name) then LocalPlayer.Character.Humanoid:EquipTool(tool) end
        
        -- Mở rộng tầm đánh (Long Range)
        if tool and tool:FindFirstChild("Handle") then
            tool.Handle.Size = Vector3.new(Settings.AttackRange, Settings.AttackRange, Settings.AttackRange)
            tool.Handle.CanCollide = false
        end
        ReplicatedStorage.RigControllerEvent:FireServer("weaponClick")
    end)
end

-- 2. Aimbot Hard Lock (Gim người chơi)
RunService.RenderStepped:Connect(function()
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    Circle.Position = Center
    Circle.Visible = Settings.AimbotEnabled
    
    if Settings.AimbotEnabled then
        local target = nil; local dist = Settings.AimbotFOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, vis = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Center - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < dist then dist = mag; target = p end
                end
            end
        end
        
        if target then
            -- Gim chặt Camera vào mục tiêu
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end
end)

-- 3. Tween Teleport
local function TweenTP(cf)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local d = (char.HumanoidRootPart.Position - cf.Position).Magnitude
        TweenService:Create(char.HumanoidRootPart, TweenInfo.new(d/Settings.TeleportSpeed, Enum.EasingStyle.Linear), {CFrame = cf * CFrame.new(0,60,0)}):Play()
    end
end

-- =================== TẠO MENU ===================

local function CreateDropdown(text)
    local F = Instance.new("Frame", Content); F.Size = UDim2.new(1, -5, 0, 35); F.BackgroundColor3 = Color3.fromRGB(25, 25, 25); F.ClipsDescendants = true
    local B = Instance.new("TextButton", F); B.Size = UDim2.new(1, 0, 0, 35); B.Text = "▼ " .. text; B.TextColor3 = Color3.new(1, 1, 1); B.BackgroundTransparency = 1
    local C = Instance.new("Frame", F); C.Size = UDim2.new(1, 0, 0, 0); C.Position = UDim2.new(0, 0, 0, 35); C.BackgroundTransparency = 1; Instance.new("UIListLayout", C)
    
    local op = false
    B.MouseButton1Click:Connect(function()
        op = not op
        F:TweenSize(UDim2.new(1, -5, 0, op and (40 + (35 * #C:GetChildren())) or 35), "Out", "Quart", 0.3, true)
        B.Text = (op and "▲ " or "▼ ") .. text
    end)
    return C
end

-- Tab Chiến Đấu
local Combat = CreateDropdown("CHIẾN ĐẤU & FARM")
local function AddToggle(parent, name, cb)
    local t = Instance.new("TextButton", parent); t.Size = UDim2.new(1, 0, 0, 30); t.Text = name .. ": TẮT"; t.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    local a = false
    t.MouseButton1Click:Connect(function() a = not a; t.BackgroundColor3 = a and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0); t.Text = name .. (a and ": BẬT" or ": TẮT"); cb(a) end)
end

AddToggle(Combat, "Gim Người Chơi", function(s) Settings.AimbotEnabled = s end)
AddToggle(Combat, "Tự Đánh Xa", function(s) Settings.AutoAttackEnabled = s end)

-- Tab Dịch Chuyển (Full 3 Sea)
for seaName, islands in pairs(AllSeas) do
    local SeaTab = CreateDropdown(seaName)
    for name, cf in pairs(islands) do
        local b = Instance.new("TextButton", SeaTab); b.Size = UDim2.new(1, 0, 0, 30); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1, 1, 1)
        b.MouseButton1Click:Connect(function() TweenTP(cf) end)
    end
end

-- Vận hành Auto Attack
spawn(function() while true do task.wait(0.1) if Settings.AutoAttackEnabled then DoAttack() end end end)
AvatarBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

print("TRIET HUB MOBILE FINAL LOADED!")
