--[[
    TRIET HUB - PHIÊN BẢN MOBILE FIX MẤT MENU
    Sửa lỗi: Không mất menu khi chết, Auto Click chuẩn, Aimbot FOV, Tự nhận Sea
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- =================== CÀI ĐẶT ===================
local Settings = {
    AimbotEnabled = false,
    AimbotFOV = 120,
    AutoAttackEnabled = false,
    TeleportSpeed = 300,
    Prediction = 0.12
}

-- Tự động nhận Sea
local SeaName = "Sea 1"
if game.PlaceId == 444227216 then SeaName = "Sea 2"
elseif game.PlaceId == 744942363 then SeaName = "Sea 3" end

-- =================== VÒNG TRÒN AIMBOT (FOV) ===================
local Circle = Drawing.new("Circle")
Circle.Visible = false
Circle.Thickness = 2
Circle.Color = Color3.fromRGB(163, 106, 255)
Circle.Radius = Settings.AimbotFOV
Circle.Filled = false

-- =================== GIAO DIỆN MOBILE ===================
-- Đảm bảo ResetOnSpawn = false để không mất menu khi chết
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrietHub_Official"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false 

-- Nút Avatar Tròn (Dùng để mở lại nếu lỡ tay ẩn)
local AvatarBtn = Instance.new("ImageButton", ScreenGui)
AvatarBtn.Size = UDim2.new(0, 55, 0, 55)
AvatarBtn.Position = UDim2.new(0, 10, 0.4, 0)
AvatarBtn.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
AvatarBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", AvatarBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", AvatarBtn).Color = Color3.fromRGB(163, 106, 255)

-- Khung Menu Chính
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 250)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = true -- Mặc định hiện khi mới chạy
Instance.new("UICorner", MainFrame)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 40)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 5)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "TRIET HUB - " .. SeaName
Title.TextColor3 = Color3.fromRGB(163, 106, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- =================== CHỨC NĂNG ===================

-- 1. Auto Attack Mobile (Đánh nhanh, không lỗi Delta)
local function AutoAttack()
    if Settings.AutoAttackEnabled then
        pcall(function()
            -- Gửi lệnh đánh chuẩn cho Blox Fruit trên Mobile
            ReplicatedStorage.RigControllerEvent:FireServer("weaponClick")
        end)
    end
end

-- 2. Aimbot Ghìm Tâm mượt
RunService.RenderStepped:Connect(function()
    Circle.Position = UserInputService:GetMouseLocation()
    Circle.Visible = Settings.AimbotEnabled
    
    if Settings.AimbotEnabled then
        local target = nil
        local maxDist = Settings.AimbotFOV
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, vis = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (UserInputService:GetMouseLocation() - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < maxDist then
                        maxDist = mag
                        target = p
                    end
                end
            end
        end
        
        -- Ghìm tâm khi có mục tiêu trong vòng tròn
        if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local pPos = target.Character.HumanoidRootPart.Position + (target.Character.HumanoidRootPart.Velocity * Settings.Prediction)
            local sPos = Camera:WorldToScreenPoint(pPos)
            if getgenv().mousemoverel then
                getgenv().mousemoverel((sPos.X - Mouse.X) * 0.3, (sPos.Y - Mouse.Y) * 0.3)
            end
        end
    end
end)

-- Vòng lặp tấn công
spawn(function()
    while true do
        task.wait(0.1)
        AutoAttack()
    end
end)

-- Hàm tạo Nút Gạt
local function CreateToggle(name, callback)
    local TBtn = Instance.new("TextButton", Content)
    TBtn.Size = UDim2.new(1, -5, 0, 35)
    TBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    TBtn.Text = name .. ": TẮT"
    TBtn.TextColor3 = Color3.new(1, 1, 1)
    TBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", TBtn)

    local act = false
    TBtn.MouseButton1Click:Connect(function()
        act = not act
        TBtn.BackgroundColor3 = act and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        TBtn.Text = name .. (act and ": BẬT" or ": TẮT")
        callback(act)
    end)
end

CreateToggle("Ghim Tâm (Aimbot)", function(s) Settings.AimbotEnabled = s end)
CreateToggle("Tự Đánh (Auto Attack)", function(s) Settings.AutoAttackEnabled = s end)

-- Mở/Đóng Menu
AvatarBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Cho phép kéo nút Avatar để không vướng màn hình
local dragging, dragStart, startPos
AvatarBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = AvatarBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        AvatarBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

print("TRIET HUB MOBILE FINAL LOADED!")
