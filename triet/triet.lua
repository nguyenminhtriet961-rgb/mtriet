--[[
    TRIET HUB - FIX LỖI TOÀN DIỆN 2026
    Sửa lỗi: Auto Click (không spam Delta), Tự nhận diện Sea, Aimbot có vòng tròn FOV
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- =================== CÀI ĐẶT HỆ THỐNG ===================
local Settings = {
    AimbotEnabled = false,
    AimbotFOV = 150, -- Độ rộng vòng tròn Aimbot
    AutoAttackEnabled = false,
    TeleportSpeed = 350,
    Prediction = 0.15
}

-- Tọa độ các Sea (Tự động lọc theo Sea bạn đang đứng)
local AllLocations = {
    [275369177] = "Sea 1", -- ID Map Sea 1
    [444227216] = "Sea 2", -- ID Map Sea 2
    [744942363] = "Sea 3"  -- ID Map Sea 3
}
local MySea = AllLocations[game.PlaceId] or "Sea 1"

-- =================== GIAO DIỆN (FIX LỖI) ===================
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "TrietHub_Fix_Loi"
ScreenGui.ResetOnSpawn = false

-- Vòng tròn Aimbot (FOV)
local FOVCircle = Instance.new("CircleValue", ScreenGui) -- Giả lập vòng tròn
local Circle = Drawing.new("Circle")
Circle.Visible = false
Circle.Thickness = 2
Circle.Color = Color3.fromRGB(163, 106, 255)
Circle.Filled = false
Circle.Radius = Settings.AimbotFOV

-- Nút Avatar Toggle
local AvatarBtn = Instance.new("ImageButton", ScreenGui)
AvatarBtn.Size = UDim2.new(0, 60, 0, 60)
AvatarBtn.Position = UDim2.new(0, 20, 0.5, -30)
AvatarBtn.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
Instance.new("UICorner", AvatarBtn).CornerRadius = UDim.new(1, 0)

-- Khung Menu
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 5)

-- =================== FIX LỖI CHỨC NĂNG ===================

-- 1. Sửa Auto Click (Dùng phương thức Click không chạm vào UI Delta)
local function DoAttack()
    pcall(function()
        local char = LocalPlayer.Character
        local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if tool and not char:FindFirstChild(tool.Name) then char.Humanoid:EquipTool(tool) end
        
        -- Dùng RemoteEvent của game thay vì VirtualUser để tránh spam menu
        local combatPath = char:FindFirstChild("Combat") or tool
        if combatPath then
            -- Tùy vào game Blox Fruit, đây là lệnh đánh chuẩn:
            game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponClick")
        end
    end)
end

-- 2. Logic Aimbot với Vòng tròn (Ghim khi mục tiêu trong vòng)
RunService.RenderStepped:Connect(function()
    Circle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    Circle.Visible = Settings.AimbotEnabled
    
    if Settings.AimbotEnabled then
        local target = nil
        local maxDist = Settings.AimbotFOV
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, vis = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < maxDist then
                        maxDist = mag
                        target = p
                    end
                end
            end
        end
        
        if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local pPos = target.Character.HumanoidRootPart.Position + (target.Character.HumanoidRootPart.Velocity * Settings.Prediction)
            local sPos = Camera:WorldToScreenPoint(pPos)
            -- Ghìm tâm mượt mà
            mousemoverel((sPos.X - Mouse.X) * 0.4, (sPos.Y - Mouse.Y) * 0.4)
        end
    end
end)

-- Vòng lặp Auto Attack
spawn(function()
    while true do
        task.wait(0.1) -- Tốc độ đánh cực nhanh
        if Settings.AutoAttackEnabled then DoAttack() end
    end
end)

-- Mở/Đóng Menu
AvatarBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

print("TRIET HUB ĐÃ FIX LỖI! BẠN ĐANG Ở: " .. MySea)
